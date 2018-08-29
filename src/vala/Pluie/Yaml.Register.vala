/*^* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software    :    pluie-yaml       <https://git.pluie.org/pluie/lib-yaml>
 *  @version     :    0.55
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
using Pluie;
using Gee;

/**
 * A Register class responsible to register owner types and related types lists
 * 
 * The register also manage full namespace resolving for the yaml tags generation <<BR>>
 * (from Yaml.Object to Yaml.Node)
 * 
 * The registered types means that they can (must) be populated from Yaml.Node
 * to Yaml.Object or the opposite.<<BR>>
 * See classes Yaml.Builder & Yaml.Object for more details about that.
 */
public class Pluie.Yaml.Register
{
    /**
     *
     */
    static Gee.HashMap<Type, Gee.ArrayList<GLib.Type>> rtype;
    /**
     *
     */
    static Gee.ArrayList<string>                       namespaces;
    /**
     * 
     */
    static Gee.HashMap<Quark, string>                  ns_resolved;

    /**
     *
     */
    static construct {
        Yaml.Register.rtype       = new Gee.HashMap<Type, Gee.ArrayList<GLib.Type>> ();
        Yaml.Register.namespaces  = new Gee.ArrayList<string> ();
        Yaml.Register.ns_resolved = new Gee.HashMap<Quark, string> ();
    }

    /**
     *
     */
    internal Register ()
    {
    }

    /**
     * add multiple type to specified owner type
     * @param owner_type the owner type to registering types
     */
    public static bool add_type (GLib.Type owner_type, ...)
    {
        bool done = true;
        if (!is_registered (owner_type)) {
            rtype.set (owner_type, init_type_list ());
        }
        var l = va_list();
        while (done) {
            GLib.Type? t = l.arg<GLib.Type> ();
            if (t == null || t == Type.INVALID) {
                break;
            }
            Yaml.dbg ("adding to %s type %s".printf (owner_type.name (), t.name ()));
            done = done && rtype.get (owner_type).add (t);
        }
        return done;
    }

    /**
     * check if specified owner_type is registered
     * @param owner_type the owner type to check
     */
    public static bool is_registered (GLib.Type owner_type)
    {
        return rtype.has_key (owner_type);
    }

    /**
     * check if specified type is registered for specified owner_type
     * @param owner_type the owner type to check
     * @param type the type presumably belonging to owner type
     */
    public static bool is_registered_type (GLib.Type owner_type, GLib.Type type)
    {
        return is_registered (owner_type) && rtype.get (owner_type).contains (type);
    }

    /**
     * add one or multiple namespace for tag resolution
     * namespace value ar same as in vala source code (so with dot separator)
     * @param name a namespace to register
     */
    public static bool add_namespace (string name, ...)
    {
        var l    = va_list();
        Yaml.dbg ("adding namespace %s".printf (name));
        var done = Yaml.Register.namespaces.contains (name) || Yaml.Register.namespaces.add (name);
        while (done) {
            string? ns = l.arg();
            if (ns == null) {
                break;  // end of the list
            }
            Yaml.dbg ("adding namespace %s".printf (ns));
            if (!Yaml.Register.namespaces.contains (ns)) {
                done = done && Yaml.Register.namespaces.add (ns);
            }
        }
        return done;
    }

    /**
     * resolve full namespace for specified type
     * @param type the type to retriew his full namespace
     * @return the full namespace
     */
    public static string resolve_namespace_type (GLib.Type type)
    {
        if (!is_resolved_ns (type)) {
            var name = type.name ();
            try {
                Regex reg = new Regex ("([A-Z]{1}[a-z]+)");
                var d  = reg.split (type.name (), 0);
                var rn = "";
                var gb = "";
                for (var i = 1; i < d.length; i+=2) {
                    rn += d[i];
                    if (namespaces.contains (rn)) {
                        rn += ".";
                        gb += d[i];
                    }
                }
                // case ENUM which ends with dot
                if (rn.substring(-1) == ".") {
                    rn = name.splice (0, gb.length, rn);
                }
                name = rn;
            }
            catch (GLib.RegexError e) {
                of.error (e.message);
            }
            var serial = get_serial (type);
            Yaml.dbg ("resolve_namespace_type %u (%s) => %s".printf (serial, type.name (), name));  
            ns_resolved.set (serial, name);
        }
        return get_resolved_ns (type);
    }

    /**
     *
     */
    private static Gee.ArrayList<GLib.Type> init_type_list ()
    {
        return new Gee.ArrayList<GLib.Type> ();
    }

    /**
     * check if full namespace is already resolved for specified type
     * @param type the type to check
     */
    private static bool is_resolved_ns (GLib.Type type)
    {
        return ns_resolved.has_key (get_serial (type));
    }

    /**
     * get Quark related to specified type
     */
    private static Quark get_serial (Type type)
    {
        return Quark.from_string (type.name ());
    }

    /**
     * retriew full namespace value for specified type
     * @param type the type to retriew his full namespace
     * @return the full namespace for specified type
     */
    private static string get_resolved_ns (GLib.Type type)
    {
        return is_resolved_ns (type) ? ns_resolved.get (get_serial (type)) : type.name ();
    }
}
