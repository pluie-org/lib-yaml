/*^* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software    :    pluie-yaml       <https://git.pluie.org/pluie/lib-yaml>
 *  @version     :    0.60
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
 * a class representing a Yaml Root Node
 */
public class Pluie.Yaml.Root : Yaml.Mapping
{
    /**
     * Tags directives
     */
    public Gee.HashMap<string, string>    tag_directives { get; internal set; }

    /**
     * @param name the name of the root node
     */
    public Root (string? name = "PluieYamlRoot", bool add_directive = false, Yaml.Node? child = null)
    {
        base (null, name);
        this.ntype = Yaml.NODE_TYPE.ROOT;
        this.tag_directives = new Gee.HashMap<string, string> ();
        if (add_directive) {
            this.tag_directives["!%s!".printf (Yaml.YAML_VALA_PREFIX)] = Yaml.YAML_VALA_DIRECTIVE;
        }
        if (child != null) {
            this.add (child);
        }
    }

    /**
     * get tag directives formatted for colorized output
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
