/**
 * a class to manage Yaml configuration files
 */
public class Pluie.Yaml.Config
{
    /**
     * current path
     */
    public string?          path    { get; internal set; default = null; }

    /**
     * Yaml Loader
     */
    public Yaml.Loader      loader  { internal get; internal set; }

    /**
     * Yaml Finder
     */
    public Yaml.Finder      finder  { internal get; internal set; }

    /**
     * construct a Yaml Config for specifiyed path
     */
    public Config (string? path = null, Yaml.FIND_MODE mode = Yaml.FIND_MODE.DOT)
    {
        Yaml.BaseNode.mode = mode;
        this.path          = path;
        if (this.path != null) {
            this.loader = new Yaml.Loader (this.path);
            this.finder = new Yaml.Finder(this.loader.get_nodes ());
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

}
