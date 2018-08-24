/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : pluie-yaml  <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.5
 *  @type      : library
 *  @date      : 2018
 *  @licence   : GPLv3.0     <http://www.gnu.org/licenses/>
 *  @author    : a-Sansara   <[dev]at[pluie]dot[org]>
 *  @copyright : pluie.org   <http://www.pluie.org/>
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  This file is part of pluie-yaml.
 *  
 *  pluie-yaml is free software (free as in speech) : you can redistribute it
 *  and/or modify it under the terms of the GNU General Public License as
 *  published by the Free Software Foundation, either version 3 of the License,
 *  or (at your option) any later version.
 *  
 *  pluie-yaml is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with pluie-yaml.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 */

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
    Gee.HashMap<string, string> paths           { get; internal set; }

    /**
     * construct a Yaml Config for specifiyed path
     */
    public Config (string? path = null, bool displayFile = false, Yaml.FIND_MODE mode = Yaml.FIND_MODE.DOT)
    {
        Yaml.MODE          = mode;
        this.path          = path;
        this.displayFile   = displayFile;
        if (this.path != null) {
            this.loader = new Yaml.Loader (this.path, displayFile, false);
            Yaml.Node? root = this.loader.get_nodes ();
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
    public Yaml.Root root_node ()
    {
        return this.finder.context as Yaml.Root;
    }

    /**
     * find node matching specifiyed keyPath
     */
    protected void get_imports ()
    {
        var node = this.get("^imports");
        if (node != null) {
            var root = node.parent;
            if (root != null && root.ntype.is_root ()) {
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
    private void import_files (Yaml.Node root)
    {
        Yaml.Node? sub  = null;
        Yaml.Node? n    = null;
        Yaml.Config?  conf = null;
        foreach(var entry in this.paths.entries) {
            conf = new Yaml.Config(entry.value, this.displayFile);
            sub  = conf.loader.get_nodes ();
            n    = new Yaml.Mapping (root, entry.key);
            foreach(var subnode in sub.list) {
                subnode.parent = null;
                n.add(subnode);
            }
        }
    }

    /**
     *
     */
    private void update_var (Yaml.Node node, string path)
    {
        this.varmap.set ("path", path);
        foreach (var child in node.list) {
            if (child.name[0] != IMPORTS_SPE) {
                var val = child.first().data;
                if (!Path.is_absolute (val)) {
                    val = Path.build_filename(path, val);
                }
                this.paths[(string)child.name] = val;
                this.resolve_var (child.name, val);
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
                Yaml.dbg_keyval (key, this.paths[key]);
            }
        }
    }

    /**
     *
     */
    private void get_imports_var (Yaml.Node node)
    {
        this.varmap = new Gee.HashMap<string, string> ();
        this.paths  = new Gee.HashMap<string, string> ();
        foreach (var child in node.list) {
            if (child.name[0] == IMPORTS_SPE) {
                this.varmap.set (child.name.substring (1), child.first().data);
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
