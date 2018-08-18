/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.4
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

/**
 * a class representing a node
 */
public class Pluie.Yaml.Node : Yaml.AbstractChild, Pluie.Yaml.Collection
{
    /**
     * Yaml.Node collection
     */
    public ArrayList<Yaml.Node>   list        { get; internal set; }

    bool                          container   { get; internal set; default = true; }

    /**
     * default Yaml.Node constructor
     * @param parent the parent node
     * @param type the NODE_TYPE of Yaml.Node to create
     * @param name the node name
     */
    public Node (Yaml.Node? parent = null, Yaml.NODE_TYPE type = Yaml.NODE_TYPE.UNDEFINED, string? name = null)
    {
        
        base (parent, type, name);
        this.list = new ArrayList<Yaml.Node> ();
    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param node the Yaml.Node child to add
     */
    public virtual bool add (Yaml.AbstractChild node)
    {
        bool done = false;
        try {
            var child = node as Yaml.Node;
            if (this.container && child != null) {
                child.on_change_parent (false);
                child.level  = this.level + 1;
                child.parent = this;
                this.before_add (child);
                if ((done = this.list.add (child))) {
                    this.on_added (child);
                }
            }
        }
        catch (Yaml.AddNodeError e) {
            of.warn (e.message);
        }
        return done;
    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    protected virtual void before_add (Yaml.Node child) throws Yaml.AddNodeError
    {

    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    protected virtual void on_added (Yaml.Node child)
    {
        this.update_level ();
    }

    /**
     * remove a child
     * @param child  the child to remove
     */
    public bool remove_child (Yaml.Node child, bool levelUpdate = true)
    {
        bool done = false;
        if (this.container && !this.empty() && this.list.contains (child)) {
            if ((done = this.list.remove (child))) {
                this.on_removed (child, levelUpdate);
            }
        }
        return done;
    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    protected virtual void on_removed (Yaml.Node child, bool levelUpdate = true)
    {
        if (levelUpdate) {
            child.level = 0;
            child.update_level ();
        }
    }

    /**
     * retriew a child node throught specifiyed index
     * @param index index of searched child
     * @return the child node
     */
    public virtual Yaml.Node? item (int index)
    {
        return this.list.get (index);
    }

    /**
     * check if current node contains the specifiyed child node
     * @param   child the child to check 
     */
    public bool contains (Yaml.Node child) {
        return !this.empty () && this.list.contains (child);
    }

    /**
     * count childnodes
     */
    public override int count () {
        return !this.empty () ? this.list.size : 0;
    }

    /**
     * check if empty
     */
    public bool empty () {
        return this.list == null || this.list.size == 0;
    }

    /**
     * get an iterator
     */
    public Gee.Iterator<Yaml.Node> iterator () {
        return this.list.iterator ();
    }

    /**
     * retriew the first child node
     * @return the first child node
     */
    public virtual Yaml.Node? first ()
    {
        return this.list.first ();
    }

    /**
     * retriew the last child node
     * @return the last child node
     */
    public Yaml.Node? last ()
    {
        return this.list.last ();
    }

    /**
     *
     */
    private Yaml.Node? child_sibling (Yaml.Node child, bool forward)
    {
        Yaml.Node? node = null;
        if (!this.empty () && this.list.contains (child)) {
            int index = this.list.index_of (child) + (forward ? 1 : -1);
            if (index >= 0 && index < this.count ()) {
                node = this.list.get(index);
            }
        }
        return node;
    }

    /**
     *
     */
    public Yaml.Node? child_next_sibling (Yaml.Node child)
    {
        return this.child_sibling (child, true);
    }

    /**
     *
     */
    public Yaml.Node? child_previous_sibling (Yaml.Node child)
    {
        return this.child_sibling (child, false);
    }

    /*
     *
     */
    public virtual void update_level()
    {
        this.level = this.parent != null ? this.parent.level + 1 : 0;
        if (!this.empty ()) {
            foreach (var child in this.list) {
                if (child != null) child.update_level ();
            }
        }
    }

    /**
     * clone current node
     * @param name the name of clone
     */
    public virtual Yaml.Node clone_node (string? name = null)
    {
        var key = name != null ? name : this.name;
        Yaml.Node clone = this.get_cloned_instance (key);
        if (!this.empty()) {
            foreach (Yaml.Node child in this.list) {
                clone.add(child.clone_node(null));
            }
        }
        return clone;
    }

    /**
     * clone current node
     * @param name the name of clone
     */
    public virtual Yaml.Node get_cloned_instance (string? name = null)
    {
        return new Yaml.Node (null, this.ntype, name);
    }

    /**
     *
     */
    public GLib.Value val (GLib.Type type)
    {
        var v = GLib.Value(type);
        if (this.ntype.is_single_pair ()) {
            Yaml.Builder.set_basic_type_value (ref v, type, this.first ().data);
        }
        return v;
    }

    /**
     * display childs
     */
    public void display_childs (bool withTitle = true)
    {
        if (withTitle) {
            of.action ("display_childs", this.name);
            of.echo ("");
        }
        of.echo (this.to_string ());
        if (!this.empty ()) {
            foreach (Yaml.Node child in this.list) {
                child.display_childs (false);
            }
        }
    }

    /**
     * get a presentation string of current Yaml.Node
     */
    public override string to_string (
        bool withIndent   = Yaml.DBG_SHOW_INDENT, 
        bool withParent   = Yaml.DBG_SHOW_PARENT, 
        bool withUuid     = Yaml.DBG_SHOW_UUID, 
        bool withLevel    = Yaml.DBG_SHOW_LEVEL, 
        bool withCount    = Yaml.DBG_SHOW_COUNT, 
        bool withRefCount = Yaml.DBG_SHOW_REF, 
        bool withTag      = Yaml.DBG_SHOW_TAG, 
        bool withType     = Yaml.DBG_SHOW_TYPE
    )
    {
        return "%s%s%s%s%s%s%s%s%s%s%s".printf (
            this.level == 0 ? "" : of.s_indent ((int8) (withIndent ? (this.level-1)*4 : 0)),
            of.c (ECHO.OPTION).s ("["),
            this.name != null && !this.ntype.is_scalar ()
                ?  of.c (ntype.is_root () ? ECHO.MICROTIME : ECHO.TIME).s ("%s".printf (this.name))
                : (
                    this.ntype.is_scalar ()
                        ? of.c(ECHO.DATE).s ("%s".printf (this.data))
                        : ""
            ),
            withRefCount ? of.c (ECHO.COMMAND).s ("[%lu]".printf (this.ref_count)) : "",
            !withParent || this.parent == null
                ? withLevel ? of.c (ECHO.NUM).s (" %d".printf (this.level)) : ""
                : of.c (ECHO.SECTION).s (" "+this.parent.name)+(
                    withLevel ? of.c (ECHO.NUM).s (" %d".printf (this.level)) : " "
                ),
            withType  ? of.c (ECHO.OPTION_SEP).s (" %s".printf(this.ntype.infos ())) : "",
            withCount && this.ntype.is_collection () ? of.c (ECHO.MICROTIME).s (" %d".printf(this.count ())) : "",
            withUuid  ? of.c (ECHO.COMMENT).s (" %s".printf(this.uuid[0:8]+"...")) : "",
            this.tag != null && withTag
                ? " %s%s".printf (
                    of.c (ECHO.TITLE).s (" %s ".printf(this.tag.handle)), 
                    of.c (ECHO.DEFAULT).s (" %s".printf(this.tag.value))
                )
                : "",
            of.c (ECHO.OPTION).s ("]"),
            withTag && this.ntype.is_root () ? (this as Yaml.Root).get_display_tag_directives () : ""
        );
    }
}
