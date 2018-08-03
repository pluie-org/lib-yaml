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
     * retriew the previous sibling of specifiyed child node
     * @param   child
     */
    public abstract Yaml.Node? first_child ();

    /**
     * retriew the next sibling of specifiyed child node
     * @param   child
     */
    public abstract Yaml.Node? last_child ();

    /**
     * check if first chikd
     */
    public abstract bool is_first (Yaml.Node child);

    /**
     * check if last chikd
     */
    public abstract bool is_last (Yaml.Node child);

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
