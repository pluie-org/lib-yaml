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
using Pluie;

public interface Pluie.Yaml.Node : Object, Yaml.NodeCollection
{
    /**
     * universal unique identifier
     */
    public abstract string           uuid       { get; internal set; }

    /**
     * node type related to Yaml.NODE_TYPE
     */
    public abstract Yaml.NODE_TYPE   node_type  { get; internal set; }

    public abstract int              level      { get; internal set; }

    /**
     * parent node
     */
    public abstract Yaml.Node?       parent     { get; internal set; }

    /**
     * current node data for Yaml.NodeScalar node
     */
    public abstract string?          data       { get; internal set; default = null; }

    /**
     * current node name (key)
     */
    public abstract string?          name       { get; internal set; default = null; }

    /**
     * test if specifiyed node is current node
     * @param child the Yaml.Node node to test
     */
    public abstract bool same_node (Yaml.Node? node);
 
    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    public abstract bool add (Yaml.Node node);

    /**
     * add a child node to current collection (mapping or sequence) node
     * @param child the Yaml.Node child to add
     */
    public abstract string? val ();

    /**
     * stuff on changing parent node
     * @param child  the childto add
     */
    protected abstract bool on_change_parent ();

    /**
     * remove a child
     * @param child  the child to remove
     */
    protected abstract bool remove_child (Yaml.Node child);

    /**
     * clone curent node
     * @param name  the name of clone node
     */
    public abstract Yaml.Node clone_node (string? name = null);

    /**
     * check if node has child nodes
     */
    public abstract bool has_child_nodes ();

    /**
     * check if first chikd
     */
    public abstract bool is_first_child ();

    /**
     * check if last chikd
     */
    public abstract bool is_last_child ();

    /**
     * give the next sibling node
     */
    public abstract Yaml.Node? next_sibling ();

    /**
     * give the previous sibling node
     */
    public abstract Yaml.Node? previous_sibling ();

    /**
     * give the root parent node
     */
    public abstract Yaml.Node? get_root_node ();

    /**
     * update node level and all childs level
     */
    public abstract void update_level ();

    /**
     * get a presentation string of current Yaml.Node
     */
    public abstract string to_string (bool indentFormat = true, bool withParent = false, bool withUuid = false, bool withIndent = true, bool withRefCount = false);

}
