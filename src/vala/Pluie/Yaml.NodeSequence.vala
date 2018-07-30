using Pluie;
using Gee;

/**
 * a class representing a sequence node
 */
public class Pluie.Yaml.NodeSequence : Yaml.BaseNode, Yaml.NodeCollection
{

    /**
     * sequence collection for Yaml.NodeSequence node
     */
    public ArrayList<Yaml.Node> list { get; internal set; }

    /**
     * construct a sequence node
     * @param parent the parent node
     * @param indent the current indentation in node representation string
     * @param name the current name (key) of sequence node
     */
    public NodeSequence (Yaml.Node? parent = null, int indent = 0, string? name = null)
    {
        base (parent, indent, NODE_TYPE.SEQUENCE);
        this.name = name;
    }

    /**
     * remove a child
     * @param child  the child to remove
     */
    protected override bool remove_child (Yaml.Node child)
    {
        bool done = true;
        if (this.list.contains (child)) {
            done = this.list.remove (child);
        }
        return done;
    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    public override bool add (Yaml.Node node)
    {
        if (this.list == null) {
            this.list = new ArrayList<Yaml.Node> ();
        }
        node.on_change_parent ();
        node.indent = this.indent + 4;
        node.parent = this;
        return this.list.add (node);
    }

    /**
     * add a child Yaml.NodeScalar containing specifiyed data
     * @param data the scalar data
     * @return the scalar node
     */
    public Yaml.Node  add_scalar (string? data = null)
    {
        Yaml.Node scalar = new Yaml.NodeScalar (this, this.indent+4, data); 
        this.add (scalar);
        return scalar;
    }

    /**
     * retriew a child node throught specifiyed index
     * @param index index of searched child
     * @return the child node
     */
    public Yaml.Node item (int index)
    {
        return this.list.get (index);
    }

    /**
     * retriew the first child node
     * @return the first child node
     */
    public Yaml.Node first ()
    {
        return this.list.first ();
    }


    /**
     * retriew the last child node
     * @return the last child node
     */
    public Yaml.Node last ()
    {
        return this.list.last ();
    }

    /**
     * display childs
     */
    public void display_childs ()
    {
        of.action ("display_childs sequence\n");
        of.echo (this.to_string ());
        if (this.list!= null && this.list.size > 0) {
            foreach (Yaml.Node child in this.list) {
                of.echo (child.to_string ());
            }
        }
        else {
            of.echo (of.s_indent ()+"node has no childs");
        }
    }

    /**
     * count childnodes
     */
    public int get_size () {
        return this.list.size;
    }

    /**
     * check if current node contains the specifiyed child node
     * @param child
     */
    public override bool contains (Yaml.Node child) {
        return this.list.contains (child);
    }

    /**
     * retriew the next sibling of specifiyed child node
     * @param   child
     */
    public Yaml.Node? child_next_sibling (Yaml.Node child)
    {
        Yaml.Node? target = null;
        if (this.list.size > 0 && this.list.contains (child)) {
            int index = this.list.index_of (child);
            target = this.list.get(index+1);
        }
        return target;
    }

    /**
     * retriew the previous sibling of specifiyed child node
     * @param   child
     */
    public Yaml.Node? child_previous_sibling (Yaml.Node child)
    {
        Yaml.Node? target = null;
        if (this.list.size > 0 && this.list.contains (child)) {
            int index = this.list.index_of (child);
            if (index > 0) {
                target = this.list.get(index-1);
            }
        }
        return target;
    }
}
