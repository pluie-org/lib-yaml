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

using Pluie;

/**
 * a class representing a single/pair mapping node
 */
public class Pluie.Yaml.NodeSinglePair : Yaml.NodeMap
{
    /**
     * construct a single/pair mapping node
     * @param parent the parent node
     * @param name the current name (key) of sequence node
     * @param data the current scalar data
     */
    public NodeSinglePair (Yaml.Node? parent = null, string? name = null, string? data = null)
    {
        this.standard (parent, NODE_TYPE.SINGLE_PAIR);
        this.name = name;
        if (data != null) {
            var scalar = new Yaml.NodeScalar (this, data);
            scalar.name = "singlepair";
            this.add (scalar);
        }
    }

    /**
     * get child scalar node
     * @return the scalar node
     */
    public Yaml.Node? scalar ()
    {
        return this.map["singlepair"];
    }

    /**
     * clone current node
     * @param   the name of clone
     */
    public override Yaml.Node clone_node (string? name = null)
    {
        var key = name != null ? name : this.name;
        Yaml.Node clone = new Yaml.NodeSinglePair (this.parent, key, this.scalar ().data);
        return clone;
    }
}
