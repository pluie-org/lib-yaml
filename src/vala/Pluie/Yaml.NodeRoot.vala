using Pluie;

/**
 * a class representing a single/pair mapping node
 */
public class Pluie.Yaml.NodeRoot : Yaml.NodeMap
{
    /**
     * construct a single/pair mapping node
     * @param parent the parent node
     * @param indent the current indentation in node representation string
     * @param name the current name (key) of sequence node
     * @param data the current scalar data
     */
    public NodeRoot (Yaml.Node? parent = null, int indent = 0, string? name = null, string? data = null)
    {
        this.standard (null, -4, NODE_TYPE.ROOT);
        this.name = "PluieYamlRootNode";
    }
}
