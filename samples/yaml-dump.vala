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
using Pluie;

int main (string[] args)
{
    Echo.init(false);

    var path     = Yaml.DATA_PATH + "/tag.yml";
    var done     = false;

    of.title ("Pluie Yaml Library", Pluie.Yaml.VERSION, "a-sansara");
    Pluie.Yaml.DEBUG = true;
    var config = new Yaml.Config (path, true);
    var root   = config.root_node () as Yaml.Root;
    if ((done = root != null)) {
        root.display_childs ();

        
        of.action("Yaml.Node", "to_yaml_string");
        string yaml = root.to_yaml_string ();
        try {
            // an output file in the current working directory
            var file = File.new_for_path ( "./tag-generated.yml");
            // delete if file already exists
            if (file.query_exists ()) {
                file.delete ();
            }
            var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
            uint8[] data = yaml.data;
            long written = 0;
            while (written < data.length) { 
                // sum of the bytes of 'text' that already have been written to the stream
                written += dos.write (data[written:data.length]);
            }
            Yaml.Dumper.show_yaml_string (root, true, true, true);
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
            return 1;
        }

    }

    return (int) done;
}
