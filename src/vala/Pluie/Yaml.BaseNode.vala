/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.3
 *  @date      : 2018
 *  @licence   : GPLv3.0     <http://www.gnu.org/licenses/>
 *  @author    : a-Sansara   <[dev]at[pluie]dot[org]>
 *  @copyright : pluie.org   <http://www.pluie.org/>
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  This file is part of lib-yaml.
 *  
 *  lib-yaml is free software (free as in speech) : you can redistribute it
 *  and/or modify it under the terms of the GNU General Public License as
 *  published by the Free Software Foundation, either version 3 of the License,
 *  or (at your option) any later version.
 *  
 *  lib-yaml is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with lib-yaml.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 */

using GLib;
using Gee;
using Pluie;

/**
 * parent class representing a Yaml Node whenether was his type
 */
public class Pluie.Yaml.BaseNode : Object, Pluie.Yaml.Node, Pluie.Yaml.NodeCollection
{
    /**
     * universal unique identifier
     */
    public string                           uuid       { get; internal set; }

    /**
     * anchor
     */
    public string                           anchor     { get; internal set; }

    /**
     * find mode related to Yaml.FIND_MODE, default is Yaml.FIND_MODE.SQUARE_BRACKETS
     */
    public static Yaml.FIND_MODE            mode       { get; set; default = Yaml.FIND_MODE.DOT; }

    /**
     * node type related to Yaml.NODE_TYPE
     */
    public Yaml.NODE_TYPE                   node_type  { get; internal set; }

    /**
     * current representation level
     */
    public int                              level      { get; internal set; }

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
     * @param type the NODE_TYPE of Yaml.Node to create
     */
    public BaseNode (Yaml.Node? parent = null, NODE_TYPE type = NODE_TYPE.UNDEFINED)
    {
        this.standard (parent, type);
    }

    /**
     * constructor for root Yaml.Node
     */
    public BaseNode.root () {
        this.standard (null, NODE_TYPE.ROOT);
        this.name   = "PluieYamlRootNode";
    }

    /**
     * constructor for standard Yaml.Node
     * @param parent the parent node
     * @param type the NODE_TYPE of Yaml.Node to create
     */
    internal BaseNode.standard (Yaml.Node? parent = null, NODE_TYPE type = NODE_TYPE.UNDEFINED)
    {
        this.parent    = parent;
        this.node_type = type;
        this.level     = parent!=null ? parent.level + 1 : 0;
        this.uuid      = Yaml.uuid ();
    }

    /**
     * test if specifiyed node is current node
     * @param child the Yaml.Node node to test
     */
    public virtual bool same_node (Yaml.Node? node)
    {
        return node != null && node.uuid != this.uuid;
    }
 

    /**
     *
     */
    protected virtual void set_anchor_id (string id)
    {
        this.anchor = id;
    }

    /**
     *
     */
    public string? val ()
    {
        string v = null;
        if (this.node_type.is_single_pair ()) {
            v = (this as Yaml.NodeSinglePair).scalar ().data;
        }
        return v;
    }

    /**
     * clone current node
     * @param   the name of clone
     */
    public virtual Yaml.Node clone_node (string? name = null)
    {
        return new BaseNode.standard (this.parent);
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
     *
     */
    public bool is_last (Yaml.Node child) {
        return true;
    }

    /**
     *
     */
    public bool is_first (Yaml.Node child) {
        return true;
    }

    /**
     *
     */
    public virtual Yaml.Node? first_child ()
    {
        Yaml.Node? child = (this as Yaml.NodeCollection).first_child ();
        return child;
    }

    /**
     *
     */
    public virtual Yaml.Node? last_child ()
    {
        Yaml.Node? child = (this as Yaml.NodeCollection).last_child ();
        return child;
    }

    /**
     * give the next sibling node
     */
    public virtual Yaml.Node? next_sibling ()
    {
        Yaml.Node? sibling = null;
        if (this.parent != null) {
            sibling = (this.parent as Yaml.NodeCollection).child_next_sibling (this);
            if (sibling == this) sibling = null;
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
     * retriew the previous sibling of specifiyed child node
     * @param   child
     */
    public virtual Yaml.Node? child_previous_sibling (Yaml.Node child)
    {
        return null;
    }

    /**
     * retriew the next sibling of specifiyed child node
     * @param   child
     */
    public virtual Yaml.Node? child_next_sibling (Yaml.Node child)
    {
        return null;
    }

    /**
     *
     */
    public virtual int get_size () {
        return this.node_type.is_collection () ? (this as Yaml.NodeCollection).get_size () : 0;
    }

    /**
     * check if node has child nodes
     */
    public virtual bool has_child_nodes ()
    {
        return this.node_type.is_collection () && (this as Yaml.NodeCollection).get_size () > 0;
    }

    /**
     * check if first chikd
     */
    public virtual bool is_first_child ()
    {
        return false;
    }

    /**
     * check if last chikd
     */
    public virtual bool is_last_child ()
    {
        return false;
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
     *
     */
    public virtual void update_level()
    {
        this.level = this.parent != null ? this.parent.level + 1 : 0;
        switch (this.node_type) {
            case NODE_TYPE.SINGLE_PAIR :
                (this as Yaml.NodeSinglePair).scalar ().update_level ();
                break;
            case NODE_TYPE.ROOT    :
            case NODE_TYPE.MAPPING :
                foreach (var child in (this as Yaml.NodeMap).map.values) {
                    child.update_level ();
                }
                break;
            case NODE_TYPE.SEQUENCE :
                foreach (var child in (this as Yaml.NodeSequence).list) {
                    child.update_level ();
                }
                break;
        }
    }

    /**
     * get a presentation string of current Yaml.Node
     */
    public string to_string (bool indentFormat = true, bool withParent = false, bool withUuid = false, bool withLevel = false, bool withRefCount = false)
    {
        return "%s%s%s%s%s%s%s%s".printf (
            this.node_type.is_root () ? "" : of.s_indent ((int8) (indentFormat ? (this.level-1)*4 : 0)),
            of.c (ECHO.OPTION).s ("["),
            this.name != null && !this.node_type.is_scalar ()
                ?  of.c (ECHO.TIME).s ("%s".printf (this.name))
                : (
                    this.node_type.is_scalar ()
                        ? of.c(ECHO.DATE).s ("%s".printf (this.data))
                        : ""
            ),
            withRefCount ? of.c (ECHO.COMMAND).s ("[%lu]".printf (this.ref_count)) : "",
            !withParent || this.parent == null
                ? ""
                : of.c (ECHO.SECTION).s (" "+this.parent.name)+(
                    withLevel ? of.c (ECHO.NUM).s (" %d".printf (this.level)) : " "
                ),
            of.c (ECHO.OPTION_SEP).s (" %s".printf(this.node_type.infos ())),
            withUuid ? of.c (ECHO.COMMENT).s (" %s".printf(this.uuid[0:8]+"...")) : "",
//~             of.c (ECHO.NUM).s ("%d".printf (this.level)),
            of.c (ECHO.OPTION).s ("]")
        );
    }

}
