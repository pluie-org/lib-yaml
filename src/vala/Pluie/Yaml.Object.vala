/*^* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software    :    pluie-yaml       <https://git.pluie.org/pluie/lib-yaml>
 *  @version     :    0.56
 *  @type        :    library
 *  @date        :    2018
 *  @license     :    GPLv3.0          <http://www.gnu.org/licenses/>
 *  @author      :    a-Sansara        <[dev]at[pluie]dot[org]>
 *  @copyright   :    pluie.org        <http://www.pluie.org>
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
 *  along with pluie-yaml.  If not, see  <http://www.gnu.org/licenses/>.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *^*/

using GLib;
using Gee;

/**
 * Yaml.Object base class which can be transform to a Yaml.Node structure
 */
public abstract class Pluie.Yaml.Object : GLib.Object
{
    /**
     * Yaml node name
     */
    public string               yaml_name { get; internal set; }

    /**
     * associated Yaml.Register for tag resolution (full namespace names)
     */
    public static Yaml.Register register  { get; private set; }

    /**
     * Yaml.Tag definition
     */
    public static Yaml.Tag      yaml_tag  { get; internal set; }

    /**
     *
     */
    static construct
    {
        register = new Yaml.Register();
        yaml_tag = new Tag (typeof (Pluie.Yaml.Object).name (), "v");
        Yaml.Register.add_namespace("Pluie", "Pluie.Yaml");
    }

    /**
     *
     */
    public Object ()
    {
        this.yaml_construct ();
    }

    /**
     * default constructor
     */
    public virtual void yaml_construct ()
    {
        Dbg.msg ("%s (%s) instantiated".printf (this.yaml_name, this.get_type().name ()), Log.LINE, Log.FILE);
    }

    /**
     * initialization method called by Yaml.Builder after instantiation
     * and after properties has been populated
     */
    public virtual void yaml_init ()
    {
        Dbg.msg ("%s (%s) initialized".printf (this.yaml_name, this.get_type().name ()), Log.LINE, Log.FILE);
    }

    /**
     * build property name from a Yaml.Node
     * @param name name the property to build
     * @param type type the property type
     * @param node the Yaml.Node source
     */
    public virtual signal void populate_from_node (string name, GLib.Type type, Yaml.Node node) {
        if (type.is_a(typeof (Yaml.Object))) {
            this.set (node.name, Yaml.Builder.from_node(node, type));
        }
        else {
            message ("base Yaml.Object : %s".printf (Log.METHOD));
            this.set (node.name, (GLib.Object) Yaml.Builder.from_node(node, type));
        }
    }

    /**
     * convert property name to a Yaml.node
     * @param name name of the property to build
     * @param type type of the property to build
     * @param parent parent node of the property
     * @return the resulting Yaml.Node
     */
    public virtual signal Yaml.Node? populate_to_node (string name, GLib.Type type, Yaml.Node parent) {
        Yaml.Node? node = null;
        if (type.is_object ()) {
            var o = (GLib.Object) GLib.Object.new (type);
            this.get (name, out o);
            node = Yaml.Builder.to_node (o, parent, false, null, name);
        }
        return node;
    }

    /**
     * build an object collection (Gee.Collection) to a Yaml.Node
     * @param list the gee collection to transform
     * @param name name of collection sequence node
     * @param parent parent node of the collection
     * @return the resulting Yaml.Node
     */
    public static Yaml.Node? objects_collection_to_node (Gee.Collection list, string name, Yaml.Node? parent = null)
    {
        of.echo (Log.METHOD);
        var node = new Yaml.Sequence (parent, name);
        node.tag = new Yaml.Tag (Yaml.Register.resolve_namespace_type(list.get_type ()), "v");
        var it = list.iterator ();
        var i  = 0;
        while (it.next ()) {
            Yaml.Builder.to_node (
                (GLib.Object) it.get (),
                node, 
                false,
                i++
            );
        }
        return node;
    }
}
