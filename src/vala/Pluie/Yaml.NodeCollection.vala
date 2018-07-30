using GLib;
using Pluie;

/**
 * a class representing a mapping node
 */
public interface Pluie.Yaml.NodeCollection
{

    /**
     * retriew the previous sibling of specifiyed child node
     * @param   child
     */
    public abstract Yaml.Node? child_previous_sibling (Yaml.Node child);

    /**
     * retriew the next sibling of specifiyed child node
     * @param   child
     */
    public abstract Yaml.Node? child_next_sibling (Yaml.Node child);

    /**
     * count childnodes
     */
    public abstract int get_size ();

    /**
     * check if current node contains the specifiyed child node
     * @param child
     */
    public abstract bool contains (Yaml.Node node);
}
