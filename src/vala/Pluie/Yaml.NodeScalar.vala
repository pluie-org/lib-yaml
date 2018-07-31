using Pluie;

/**
 * a class representing a scalar node
 */
public class Pluie.Yaml.NodeScalar : Yaml.BaseNode
{
    /**
     * construct a scalar node
     * @param parent the parent node
     * @param indent the current indentation in node representation string
     * @param data the current scalar data
     */
    public NodeScalar (Yaml.Node? parent = null, int indent = 0, string? data = null)
    {
        base (parent, indent, NODE_TYPE.SCALAR);
        this.data = data;
    }

    /**
     * clone current node
     * @param   the name of clone
     */
    public override Yaml.Node clone_node (string? name = null)
    {
        return new Yaml.NodeScalar (this.parent, this.indent,  this.data);
    }
}
