/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : pluie-yaml  <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.5
 *  @type      : library
 *  @date      : 2018
 *  @licence   : GPLv3.0     <http://www.gnu.org/licenses/>
 *  @author    : a-Sansara   <[dev]at[pluie]dot[org]>
 *  @copyright : pluie.org   <http://www.pluie.org/>
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  This file is part of pluie-yaml.
 *  
 *  pluie-yaml is free software (free as in speech) : you can redistribute it
 *  and/or modify it under the terms of the GNU General Public License as
 *  published by the Free Software Foundation, either version 3 of the License,
 *  or (at your option) any later version.
 *  
 *  pluie-yaml is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with pluie-yaml.  If not, see <http://www.gnu.org/licenses/>.
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
     * default Yaml.Mapping constructor
     * @param parent the parent node
     * @param name the node name
     */
    public Mapping (Yaml.Node? parent = null, string? name = null)
    {
        base (parent, NODE_TYPE.MAPPING, name);
        this.keys = new ArrayList<string> ();
    }

    /**
     * Yaml.Mapping constructor as single pair node with scalar data
     * @param parent the parent node
     * @param name the node name
     * @param data scalar data
     */
    public Mapping.with_scalar (Yaml.Node? parent = null, string? name = null, string? data = null)
    {
        base (parent, NODE_TYPE.SINGLE_PAIR, name);
        var s = new Scalar (null, data);
        this.add (s);
    }

    /**
     * {@inheritDoc}
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
     * {@inheritDoc}
     */
    protected override void on_added (Yaml.Node child)
    {
        base.on_added (child);
        if (this.keys != null) {
            if (!this.ntype.is_single_pair () && this.keys.size == 0 && child.ntype.is_scalar ()) {
                this.ntype = Yaml.NODE_TYPE.SINGLE_PAIR;
            }
            this.keys.add(child.name);
        }
    }

    /**
     * {@inheritDoc}
     */
    protected override void on_removed (Yaml.Node child, bool levelUpdate = true)
    {
        base.on_removed (child, levelUpdate);
        if (!this.empty () && this.keys.contains(child.name)) {
            this.keys.remove(child.name);
        }
    }

    /**
     * retriew a child node throught specifiyed name
     * @param name name of searched child
     * @return the matching child node
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
     * {@inheritDoc}
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

    /**
     * get a collection of chils name
     */
    public Gee.ArrayList<string>? child_names ()
    {
        return this.keys;
    }

}
