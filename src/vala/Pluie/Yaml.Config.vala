/**
 * a class to manage Yaml configuration files
 */
public class Pluie.Yaml.Config
{
    /**
     *
     */
    const char                  IMPORTS_SPE = '^';

    /**
     * current path
     */
    public string?              path            { get; internal set; default = null; }

    /**
     *
     */
    public bool                 displayFile     { get; internal set; }

    /**
     * Yaml Loader
     */
    public Yaml.Loader          loader          { internal get; internal set; }

    /**
     * Yaml Finder
     */
    public Yaml.Finder          finder          { internal get; internal set; }

    /**
     * imports var
     */
    Gee.HashMap<string, string> varmap          { get; internal set; }

    /**
     * imports paths
     */
    Gee.HashMap<string, string>  paths          { get; internal set; }

    /**
     * construct a Yaml Config for specifiyed path
     */
    public Config (string? path = null, bool displayFile = false, Yaml.FIND_MODE mode = Yaml.FIND_MODE.DOT)
    {
        Yaml.BaseNode.mode = mode;
        this.path          = path;
        this.displayFile   = displayFile;
        if (this.path != null) {
            this.loader = new Yaml.Loader (this.path, displayFile, false);
            Yaml.NodeRoot? root = this.loader.get_nodes ();
            if (root != null) {
                this.finder = new Yaml.Finder(root);
                this.get_imports ();
            }
        }
    }

    /**
     * find node matching specifiyed keyPath
     */
    public new Yaml.Node? get (string keyPath)
    {
        Yaml.Node? node = null;
        if (this.finder != null) {
            node = this.finder.find (keyPath);
        }
        return node;
    }

    /**
     *
     */
    public Yaml.NodeRoot root_node ()
    {
        return this.finder.context as Yaml.NodeRoot;
    }

    /**
     * find node matching specifiyed keyPath
     */
    public void get_imports ()
    {
        var node = this.get("^imports") as Yaml.NodeMap;
        if (node != null) {
            var root = node.parent as Yaml.NodeRoot;
            if (root != null && root.node_type.is_root ()) {
                this.get_imports_var(node);
                var dir = this.strip_path(Path.get_dirname (this.path));
                if (this.varmap.has_key ("path")) {
                    var p = this.strip_path(this.varmap["path"]);
                    if (p != null) {
                        dir = Path.is_absolute(p) ? p : Path.build_filename(dir, p);
                    }
                }
                this.update_var (node, dir);
                this.import_files(root);
            }
        }
    }

    /**
     *
     */
    private void import_files (Yaml.NodeRoot root)
    {
        Yaml.NodeMap? sub  = null;
        Yaml.NodeMap? n    = null;
        Yaml.Config?  conf = null;
        foreach(var entry in this.paths.entries) {
            conf = new Yaml.Config(entry.value, this.displayFile);
            sub  = conf.loader.get_nodes ();
             n   = new Yaml.NodeMap (root, entry.key);
            foreach(var subnode in sub.map.values) {
                subnode.parent = null;
                n.add(subnode);
            }
            root.add (n);
        }
        root.update_level();
    }

    /**
     *
     */
    private void update_var (Yaml.NodeMap node, string path)
    {
        this.varmap.set ("path", path);
        string? file = null;
        foreach (var entry in node.map.entries) {
            if (entry.key[0] != IMPORTS_SPE) {
                var val = entry.value.val ();
                if (!Path.is_absolute (val)) {
                    val = Path.build_filename(path, val);
                }
                this.resolve_var (entry.key, val);
            }
        }
    }

    /**
     *
     */
    private void resolve_var (string key, string val)
    {
        foreach (var v in this.varmap.entries) {
            if (v.key != "path") {
                this.paths[key] = val.replace ("^%s^".printf (v.key), v.value);
                if (Yaml.Scanner.DEBUG) of.keyval (key, this.paths[key]);
            }
        }
    }

    /**
     *
     */
    private void get_imports_var (Yaml.NodeMap node)
    {
        this.varmap = new Gee.HashMap<string, string> ();
        this.paths  = new Gee.HashMap<string, string> ();
        foreach (var entry in node.map.entries) {
            if (entry.key[0] == IMPORTS_SPE) {
                this.varmap.set (entry.key.substring (1), entry.value.val ());
            }
        }
    }

    /**
     *
     */
    private string? strip_path(string? path)
    {
        string? s = path;
        if (s != null && !Path.is_absolute (s) && s.substring (0, 2) == "./") {
            s = s.substring (2);
        }
        return s;
    }

}
