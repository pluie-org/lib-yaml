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
using Pluie;
using Gee;

/**
 * abstract class representing a child node
 */
public abstract class Pluie.Yaml.AbstractChild : Yaml.AbstractNode
{
    /**
     * current representation level
     */
    public int          level      { get; internal set; default = 0; }

    /**
     * parent node
     */
    public Yaml.Node?   parent     { get; internal set; default = null; }

    /**
     * anchor
     */
    public string?      anchor     { get; internal set; default = null; }

    /**
     * default Yaml.Node constructor
     * @param parent the parent node
     * @param type the NODE_TYPE of Yaml.Node to create
     */
    public AbstractChild (Yaml.Node ? parent = null, Yaml.NODE_TYPE type = Yaml.NODE_TYPE.UNDEFINED, string? name = null)
    {
        base (type, name);
        this.parent = parent;
        if (this.has_parent ()) {
            this.parent.add(this);
        }
    }

    /**
     * check if has parent
     */
    public bool has_parent ()
    {
        return this.parent != null;
    }

    /**
     * check if first chikd
     */
    public bool is_first ()
    {
        return !this.has_parent () ? false : this.same_node (this.parent.first ());
    }

    /**
     * check if first chikd
     */
    public bool is_last ()
    {
        return !this.has_parent () ? false : this.same_node (this.parent.last ());
    }

    /**
     * check if first chikd
     */
    public Yaml.Node? next_sibling ()
    {
        return !this.has_parent () ? null : this.parent.child_next_sibling (this as Yaml.Node);
    }

    /**
     * check if first chikd
     */
    public Yaml.Node? previous_sibling ()
    {
        return !this.has_parent () ? null : this.parent.child_previous_sibling (this as Yaml.Node);
    }

    /**
     * stuff on changing parent node
     * @param levelUpdate flag indicating if update level is needed
     */
    protected virtual bool on_change_parent (bool levelUpdate = true)
    {
        bool done = true;
        if (this.parent != null && !this.parent.empty ()) {
            done = this.parent.remove_child (this as Yaml.Node, levelUpdate);
        }
        return done;
    }

    public virtual int count ()
    {
        return 0;
    }

    /**
     *
     */
    protected virtual void set_anchor_id (string id)
    {
        this.anchor = id;
    }


}
