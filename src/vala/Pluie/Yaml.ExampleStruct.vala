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
/**
 *
 */
public struct Pluie.Yaml.ExampleStruct
{
    /**
     *
     */
    public uint red;
    /**
     *
     */
    public uint green;
    /**
     *
     */
    public uint blue;

    /**
     *
     */
    public static ExampleStruct from_yaml_node (Yaml.Node node)
    {
        ExampleStruct s = {};
        foreach (var child in node) {
            var v = child.val (typeof (uint));
            switch (child.name) {
                case "red"   : s.red   = v.get_uint (); break;
                case "green" : s.green = v.get_uint (); break;
                case "blue"  : s.blue  = v.get_uint (); break;
            }
        }
        return s;
    }

    /**
     *
     */
    public Yaml.Node to_yaml_node (string name)
    {
        var node = new Yaml.Mapping (null, name);
        new Yaml.Mapping.with_scalar (node, "red"  , this.red.to_string ());
        new Yaml.Mapping.with_scalar (node, "green", this.green.to_string ());
        new Yaml.Mapping.with_scalar (node, "blue" , this.blue.to_string ());
        return node;
    }

    /**
     *
     */
    public string to_string ()
    {
        return "%s(red:%u,green:%u,blue:%u)".printf ((typeof (ExampleStruct)).name (), this.red, this.green, this.blue);
    }
}
