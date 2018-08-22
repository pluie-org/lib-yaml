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
using Gee;

/**
 * Yaml.Object bqse class which can be transform to a Yaml.Node structure
 */
public abstract class Pluie.Yaml.Object : GLib.Object
{
    /**
     *
     */
    public string               yaml_name { get; internal set; }

    /**
     *
     */
    public static Yaml.Register register  { get; private set; }

    /**
     *
     */
    public static Yaml.Tag      yaml_tag  { get; internal set; }

    /**
     *
     */
    static construct
    {
        register = new Yaml.Register();
        yaml_tag = new Tag (typeof (Pluie.Yaml.Object).name (), "v");
        register.add_namespace("Pluie", "Pluie.Yaml");
    }

    /**
     *
     */
    public Object ()
    {
        this.yaml_construct ();
    }

    /**
     *
     */
    public virtual void yaml_construct ()
    {
        Dbg.msg ("%s (%s) instantiated".printf (this.yaml_name, this.get_type().name ()), Log.LINE, Log.FILE);
    }

    /**
     *
     */
    public virtual void yaml_init ()
    {
        Dbg.msg ("%s (%s) initialized".printf (this.yaml_name, this.get_type().name ()), Log.LINE, Log.FILE);
    }

    /**
     *
     */
    public virtual signal void populate_from_node (string name, GLib.Type type, Yaml.Node node) {
        if (type.is_a (typeof (Yaml.Object))) {
            this.set (node.name, Yaml.Builder.from_node(node, type));
        }
    }

    /**
     *
     */
    public virtual signal Yaml.Node? populate_to_node (string name, GLib.Type type, Yaml.Node parent) {
        Yaml.Node? node = null;
        if (type.is_a (typeof (Yaml.Object))) {
            var o = (Yaml.Object) GLib.Object.new (type);
            this.get (name, out o);
            node = Yaml.Builder.to_node (o, null, false);
        }
        return node;
    }

}
