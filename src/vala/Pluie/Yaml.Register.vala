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
 * a class registering type which could be populated
 */
public class Pluie.Yaml.Register : GLib.Object
{
    /**
     *
     */
    public static Gee.HashMap<Type, Gee.ArrayList<GLib.Type>> rtype         { get; internal set; }
    /**
     *
     */
    public static Gee.ArrayList<string>                       namespaces    { get; internal set; }

    /**
     *
     */
    static construct {
        Yaml.Register.rtype      = new Gee.HashMap<Type, Gee.ArrayList<GLib.Type>> ();
        Yaml.Register.namespaces = new Gee.ArrayList<string> ();
    }

    /**
     *
     */
    private Gee.ArrayList<GLib.Type> init_type_list ()
    {
        return new Gee.ArrayList<GLib.Type> ();
    }

    /**
     *
     */
    public bool add_namespace (string name, ...)
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
     *
     */
    public string resolve_namespace_type (GLib.Type type)
    {
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
        Yaml.dbg ("resolve_namespace_type %s => %s".printf (type.name (), name));  
        return name;
    }

    /**
     *
     */
    public Gee.ArrayList<GLib.Type>? get_type_list (GLib.Type type)
    {
        return rtype.get (type);
    }

    /**
     *
     */
    public bool add_type (GLib.Type owntype, ...)
    {
        bool done = true;
        if (!this.is_registered (owntype)) {
            rtype.set (owntype, this.init_type_list ());
        }
        var l = va_list();
        while (done) {
            GLib.Type? t = l.arg<GLib.Type> ();
            if (t == null || t == Type.INVALID) {
                break;
            }
            Yaml.dbg ("adding to %s type %s".printf (owntype.name (), t.name ()));
            done = done && rtype.get (owntype).add (t);
        }
        return done;
    }

    /**
     *
     */
    public bool is_registered (GLib.Type type)
    {
        return rtype.has_key (type);
    }

    /**
     *
     */
    public bool is_registered_type (GLib.Type type, GLib.Type checktype)
    {
        return this.is_registered (type) && rtype.get (type).contains (checktype);
    }
}
