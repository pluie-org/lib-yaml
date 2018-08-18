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
    public static Gee.HashMap<Type, Gee.ArrayList<GLib.Type>> reg { get; internal set; }

    /**
     *
     */
    static construct {
        Yaml.Register.reg = new Gee.HashMap<Type, Gee.ArrayList<GLib.Type>> ();
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
    public Gee.ArrayList<GLib.Type>? get_type_list (GLib.Type type)
    {
        return reg.get (type);
    }

    /**
     *
     */
    public bool add_type (GLib.Type type, GLib.Type addedType)
    {
        if (!this.is_registered (type)) {
            reg.set (type, this.init_type_list ());
        }
        return reg.get (type).add (addedType);
    }

    /**
     *
     */
    public bool is_registered (GLib.Type type)
    {
        return reg.has_key (type);
    }

    /**
     *
     */
    public bool is_registered_type (GLib.Type type, GLib.Type checktype)
    {
        return this.is_registered (type) && reg.get (type).contains (checktype);
    }
}
