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
using Pluie;
using Gee;

/**
 * a class representing a mapping node
 */
public class Pluie.Yaml.Root : Yaml.Mapping
{
    /**
     * Tags map definition
     */
    public Gee.HashMap<string, string>    tag_directives { get; internal set; }

    /**
     *
     */
    public Root (string? name = "PluieYamlRoot")
    {
        base (null, name);
        this.ntype = Yaml.NODE_TYPE.ROOT;
        this.tag_directives = new Gee.HashMap<string, string> ();
    }

    /**
     *
     */
    public string get_display_tag_directives ()
    {
        var sb = new StringBuilder();
        foreach (var entry in this.tag_directives.entries) {
            int len = 10 - entry.key.length -2;
            var str = " %TAG "+@" %$(len)s"+" %s %s";
            sb.append (
                "\n        %s %s".printf (
                    of.c(ECHO.TITLE).s (str.printf (" ", entry.key.replace("!", ""), Color.off ())), 
                    of.c (ECHO.DEFAULT).s (entry.value))
            );
        }
        return sb.str;
    }

}
