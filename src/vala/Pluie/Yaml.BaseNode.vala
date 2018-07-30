using GLib;
using Gee;
using Pluie;

/**
 * parent class representing a Yaml Node whenether was his type
 */
public class Pluie.Yaml.BaseNode : Object, Pluie.Yaml.Node
{
    /**
     * universal unique identifier
     */
    public string                           uuid      { get; internal set; }

    /**
     * find mode related to Yaml.FIND_MODE, default is Yaml.FIND_MODE.SQUARE_BRACKETS
     */
    public static Yaml.FIND_MODE            mode      { get; set; default = Yaml.FIND_MODE.SQUARE_BRACKETS; }

    /**
     * node type related to Yaml.NODE_TYPE
     */
    public Yaml.NODE_TYPE                   node_type { get; internal set; }

    /**
     * current representation indent
     */
    public int                              indent     { get; internal set; }

    /**
     * parent node
     */
    public Yaml.Node?                       parent     { get; internal set; }

    /**
     * current node data for Yaml.NodeScalar node
     */
    public string?                          data       { get; internal set; default = null; }

    /**
     * current node name (key)
     */
    public string?                          name       { get; internal set; default = null; }

    /**
     * default Yaml.Node constructor
     * @param parent the parent node
     * @param indent the current indentation in node representation string
     * @param type the NODE_TYPE of Yaml.Node to create
     */
    public BaseNode (Yaml.Node? parent = null, int indent = 0, NODE_TYPE type = NODE_TYPE.UNDEFINED)
    {
        this.standard (parent, indent, type);
    }

    /**
     * constructor for root Yaml.Node
     */
    public BaseNode.root () {
        this.standard (null, -4, NODE_TYPE.ROOT);
        this.name   = "PluieYamlRootNode";
    }

    /**
     * constructor for standard Yaml.Node
     * @param parent the parent node
     * @param indent the current indentation in node representation string
     * @param type the NODE_TYPE of Yaml.Node to create
     */
    internal BaseNode.standard (Yaml.Node? parent = null, int indent = 0, NODE_TYPE type = NODE_TYPE.UNDEFINED)
    {
        this.parent    = parent;
        this.node_type = type;
        this.indent    = indent;
        this.uuid      = Yaml.uuid ();
    }

    /**
     * stuff on changing parent node
     * @param child  the childto add
     */
    protected virtual bool on_change_parent ()
    {
        bool done = true;
        if (this.parent != null) {
            done = this.parent.remove_child (this);
        }
        return done;
    }

    /**
     * add a child
     * @param child  the childto add
     */
    public virtual bool add (Yaml.Node child)
    {
        child.parent = this;
        return false;
    }

    /**
     * remove a child
     * @param child  the child to remove
     */
    protected virtual bool remove_child (Yaml.Node child)
    {
        return false;
    }

    /**
     * give the next sibling node
     */
    public virtual Yaml.Node? next_sibling ()
    {
        Yaml.Node? sibling = null;
        if (this.parent != null) {
            sibling = (this.parent as Yaml.NodeCollection).child_next_sibling (this);
        }
        return sibling;
    }

    /**
     * give the previous sibling node
     */
    public virtual Yaml.Node? previous_sibling ()
    {
        Yaml.Node? sibling = null;
        if (this.parent != null) {
            sibling = (this.parent as Yaml.NodeCollection).child_previous_sibling (this);
        }
        return sibling;
    }

    /**
     * give the root parent node
     */
    public virtual Yaml.Node? get_root_node ()
    {
        Yaml.Node? parent = this.parent;
        if (parent != null) {
            while(parent.parent != null) {
                parent = parent.parent;
            } 
        }
        return parent;
    }

    /**
     * check if node has child nodes
     */
    public virtual bool has_child_nodes ()
    {
        return this.node_type.is_collection () && (this as Yaml.NodeCollection).get_size () > 0;
    }

    /**
     * check if current node contains the specifiyed child node
     * @param child
     */
    public virtual bool contains (Yaml.Node child)
    {
        bool has = false;
        if (this.node_type.is_collection ()) {
            has = (this as Yaml.NodeCollection).contains (child);
        }
        return has;
    }

    /**
     * get a presentation string of current Yaml.Node
     */
    public string to_string (bool withIndent = true)
    {
        
        return "%s%s%s%s%s%s%s%s".printf (
            this.node_type.is_root () ? "" : of.s_indent ((int8) (withIndent ? this.indent : 0)),
            of.c (ECHO.OPTION).s ("<"),
            of.c (ECHO.OPTION_SEP).s (this.node_type.infos ()),
            this.name != null ? " %s".printf (this.name)
                              : (this.node_type.is_scallar () ? " %s".printf (this.data) : ""),
            "[%x]".printf (this.ref_count),
            this.parent == null ? "" : this.parent.name+"|"+this.indent.to_string(),
//~             " (%d) ".printf (this.indent),
            of.c (ECHO.OPTION).s (">"),
            of.c (ECHO.DATE).s (" %s".printf(this.uuid))
        );
    }

}
