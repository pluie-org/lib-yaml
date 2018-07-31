using GLib;
using Pluie;
using Gee;

/**
 * a class representing a mapping node
 */
public class Pluie.Yaml.NodeMap : Yaml.BaseNode, Yaml.NodeCollection
{
    /**
     * map collection for Yaml.NodeMap node
     */
    public HashMap<string, Yaml.Node>       map        { get; internal set; }

    /**
     * construct a mapping node
     * @param parent the parent node
     * @param indent the current indentation in node representation string
     * @param name the current name (key) of mapping node
     */
    public NodeMap (Yaml.Node? parent = null, int indent = 0, string? name = null)
    {
        base (parent, indent, NODE_TYPE.MAPPING);
        this.map  = new HashMap<string, Yaml.Node> ();
        this.name = name;
    }

    /**
     * remove a child
     * @param child  the child to remove
     */
    protected override bool remove_child (Yaml.Node child)
    {
        bool done = true;
        if (this.map != null && this.map.has_key (child.name)) {
            done = this.map.unset(child.name);
        }
        return done;
    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    public override bool add (Yaml.Node node)
    {
        node.on_change_parent ();
        node.indent = this.indent + 4;
        node.parent = this;
        if (this.map == null) {
            this.map = new HashMap<string, Yaml.Node> ();
        }
        this.map.set (node.name, node);
        return true;
    }

    /**
     * display childs
     */
    public void display_childs (bool root=true)
    {
        if (root == true) {
            of.action ("display root node\n");
        }
        of.echo (this.to_string ());
        if (this.map.size > 0) {
            foreach (string key in this.map.keys) {
                var n = this.map.get(key);
                if (n.node_type.is_mapping ()) (n as Yaml.NodeMap).display_childs (false);
                else if (n.node_type.is_sequence ()) (n as Yaml.NodeSequence).display_childs (false);
                else if (n.node_type.is_single_pair ()) {
                    of.echo (n.to_string ());
                    of.echo ((n as Yaml.NodeSinglePair).scalar ().to_string ());
                }
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
        return this.map.size;
    }

    /**
     * check if current node contains the specifiyed child node
     * @param child
     */
    public override bool contains (Yaml.Node child) {
        bool has = false;
        foreach (Yaml.Node entry in map.values) {
            if (child.uuid == entry.uuid) {
                has = true;
                break;
            }
        }
        return has;
    }

    /**
     * retriew the next sibling of specifiyed child node
     * @param   child
     */
    public virtual Yaml.Node? child_next_sibling (Yaml.Node child)
    {
        Yaml.Node? target = null;
        bool match = false;
        if (this.map.size > 0) {
            foreach (string key in this.map.keys) {
                if (child.name == key) {
                    match = true;
                    continue;
                }
                if (match) {
                    target = this.map.get(key);
                }
            }
        }
        return target;
    }

    /**
     * retriew the previous sibling of specifiyed child node
     * @param   child
     */
    public virtual Yaml.Node? child_previous_sibling (Yaml.Node child)
    {
        Yaml.Node? target = null;
        bool match = false;
        if (this.map.size > 0) {
            foreach (string key in this.map.keys) {
                if (child.name == key) {
                    match = true;
                    break;
                }
                target = this.map.get(key);
            }
        }
        if (!match) {
            target = null;
        }
        return target;
    }

    /**
     * clone current node
     * @param   the name of clone
     */
    public override Yaml.Node clone_node (string? name = null)
    {
        var key = name != null ? name : this.name;
        Yaml.Node clone = new Yaml.NodeMap (this.parent, this.indent, key);
        foreach (string k in this.map.keys) {
            var n = this.map.get(k).clone_node();
            n.parent = clone;
            clone.add(n);
        }
        return clone;
    }

}
