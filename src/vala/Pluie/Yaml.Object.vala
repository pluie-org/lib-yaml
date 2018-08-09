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
 * a test class to implements yamlize

 */
public abstract class Pluie.Yaml.Object : GLib.Object
{

    public static string type_name (string name)
    {
        return name.replace(".", "");
    }

    public static GLib.Type? type_from_name (string name)
    {
        GLib.Type? type = Type.from_name (type_name (name));
        return type;
    }

    public string get_type_name ()
    {
        return Type.from_instance (this).name ();
    }

    /**
     *
     */
    public bool yamlize (Yaml.Node node)
    {
        bool done = false;
        try {
            if (node!= null && !node.empty ()) {
                Iterator<Yaml.Node> it = node.iterator ();
                foreach (var child in node) {
                    of.action ("yamlize ", child.to_string ());
                    var pspec = this.get_class ().find_property (child.name);
                    if (pspec != null) {
                        if (child.first ().tag != null) {
                            of.keyval ("found tag", child.first ().tag.@value);
//~                             of.keyval ("value is `%s`", child.first ().data);
                            switch (child.first ().tag.@value) {
                                case "char" :
                                    this.set (child.name, child.first ().data[0]);
                                    break;
                                case "bool" :
                                    this.set (child.name, bool.parse(child.first ().data.down ()));
                                    break;
                                case "int" :
                                    this.set (child.name, int.parse(child.first ().data));
                                    break;
                            }
                        }
                        else {
                            this.set (child.name, child.first ().data);
                        }
                    }
                }
            }
        }
        catch (GLib.Error e) {
            of.warn (e.message);
            done = false;
        }
        done = true;
        return done;
    }
}
