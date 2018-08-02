/**
 * a class to manage Yaml configuration files
 */
public class Pluie.Yaml.Config
{
    const char IMPORTS_SPE = '^';
    /**
     * current path
     */
    public string?              path     { get; internal set; default = null; }

    /**
     * Yaml Loader
     */
    public Yaml.Loader          loader   { internal get; internal set; }

    /**
     * Yaml Finder
     */
    public Yaml.Finder           finder  { internal get; internal set; }

    /**
     * imports var
     */
    Gee.HashMap<string, string>  varmap  { get; internal set; }

    /**
     * imports paths
     */
    Gee.HashMap<string, string>  paths   { get; internal set; }

    /**
     * construct a Yaml Config for specifiyed path
     */
    public Config (string? path = null, Yaml.FIND_MODE mode = Yaml.FIND_MODE.DOT)
    {
        Yaml.BaseNode.mode = mode;
        this.path          = path;
        if (this.path != null) {
            this.loader = new Yaml.Loader (this.path, true, true);
            this.finder = new Yaml.Finder(this.loader.get_nodes ());
            this.get_imports ();
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
     * find node matching specifiyed keyPath
     */
    public void get_imports ()
    {
        var node = this.get("^imports") as Yaml.NodeMap;
        if (node != null) {
            this.get_imports_var(node);
            var dir = this.strip_path(Path.get_dirname (this.path));
            if (this.varmap.has_key ("path")) {
                var p = this.strip_path(this.varmap["path"]);
                if (p != null) {
                    dir = Path.is_absolute(p) ? p : Path.build_filename(dir, p);
                }
            }
            of.keyval ("import path", dir);
            this.update_var (node, dir);
        }
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
                message (entry.key);
                var val = entry.value.val ();
                message ("%s = %s", entry.key, val);
                if (!Path.is_absolute (val)) {
                    val = Path.build_filename(path, val);
                    message ("new relative %s", val);
                }
                message (" == update var == ");
                foreach (var v in this.varmap.entries) {
                    if (v.key != "path") {
                        message ("-- var %s", v.key);
                        entry.value.data = val.replace ("^%s^".printf (v.key), v.value);
                        node.map[entry.key] = entry.value;
                        of.echo ("%s : %s".printf (entry.key, node.map[entry.key].val () ));
                        
                        of.keyval (entry.key, entry.value.data);
//~                         this.paths[entry.key] = entry.value.data;
                    }
                }
            }
        }
        foreach (var entry in this.paths.entries) {
            of.keyval (entry.key, entry.value);
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
        of.echo ("");
        foreach (var entry in this.varmap.entries) {
            of.keyval (entry.key, entry.value);
        }
        of.echo ("");
        of.echo ("");
    }

    private string? strip_path(string? path)
    {
        string? s = path;
        if (s != null && !Path.is_absolute (s) && s.substring (0, 2) == "./") {
            s = s.substring (2);
        }
        return s;
    }

}
