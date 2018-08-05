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
 * a class representing a mapping node
 */
public class Pluie.Yaml.Mapping : Yaml.Node
{
    /**
     *
     */
    Gee.ArrayList<string>?              keys       { internal get; internal set; default = null; }

    /**
     *
     */
    public Mapping (Yaml.Node? parent = null, string? name = null)
    {
        base (parent, NODE_TYPE.MAPPING, name);
        this.keys = new ArrayList<string> ();
    }

    /**
     *
     */
    public Mapping.with_scalar (Yaml.Node? parent = null, string? name = null, string? data = null)
    {
        base (parent, NODE_TYPE.MAPPING, name);
        var s = new Scalar (null, data);
        this.add (s);
    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    protected override void before_add (Yaml.Node child) throws Yaml.AddNodeError
    {
        if (!this.empty ()) {          
            if (this.first().ntype.is_scalar ()) {
                var msg = "can't add child %s to %s (mapping is single pair)".printf (child.uuid[0:8], this.name);
                throw new Yaml.AddNodeError.MAPPING_IS_SINGLE_PAIR (msg);
            }
            else if (child.ntype.is_scalar ()) {
                var msg = "can't add scalar %s to %s (mapping not single pair)".printf (child.uuid[0:8], this.name);
                throw new Yaml.AddNodeError.MAPPING_NOT_SINGLE_PAIR (msg);
            }
            else if (this.keys != null && this.keys.contains(child.name)) {
                var msg = "can't add %s to %s (mapping already contains key)".printf (child.name, this.name);
                throw new Yaml.AddNodeError.MAPPING_CONTAINS_CHILD (msg);
            }
        }
    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    protected override void on_added (Yaml.Node child)
    {
        base.on_added (child);
        if (this.keys != null) {
            this.keys.add(child.name);
        }
    }

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    protected override void on_removed (Yaml.Node child, bool levelUpdate = true)
    {
        base.on_removed (child, levelUpdate);
        if (!this.empty () && this.keys.contains(child.name)) {
            this.keys.remove(child.name);
        }
    }

    /**
     * retriew a child node throught specifiyed index
     * @param index index of searched child
     * @return the child node
     */
    public new Yaml.Node? item (string name)
    {
        Yaml.Node? child = null;
        if (!this.empty ()) {
            int i = this.keys.index_of (name);
            if (i >= 0 && i < this.count ()) {
                child = this.list.get (i);
            }
        }
        return child;
    }

    /**
     * clone current node
     * @param   the name of clone
     */
    public override Yaml.Node clone_node (string? name = null)
    {
        var key = name != null ? name : this.name;
        Yaml.Mapping clone = new Yaml.Mapping (null, key);
        if (!this.empty()) {
            foreach (Yaml.Node child in this.list) {
                clone.add(child.clone_node());
            }
        }
        return clone;
    }

    public Gee.ArrayList<string>? child_names ()
    {
        return this.keys;
    }
}
