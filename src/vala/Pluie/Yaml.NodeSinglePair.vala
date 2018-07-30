using Pluie;

/**
 * a class representing a single/pair mapping node
 */
public class Pluie.Yaml.NodeSinglePair : Yaml.NodeMap
{
    /**
     * construct a single/pair mapping node
     * @param parent the parent node
     * @param indent the current indentation in node representation string
     * @param name the current name (key) of sequence node
     * @param data the current scalar data
     */
    public NodeSinglePair (Yaml.Node? parent = null, int indent = 0, string? name = null, string? data = null)
    {
        this.standard (parent, indent, NODE_TYPE.SINGLE_PAIR);
        this.name = name;
        if (data != null) {
            var scalar = new Yaml.NodeScalar (this, this.indent+4, data);
            scalar.name = "singlepair";
            this.add (scalar);
        }
    }

    /**
     * get child scalar node
     * @return the scalar node
     */
    public Yaml.Node? scalar ()
    {
        return this.map["singlepair"];
    }
}
