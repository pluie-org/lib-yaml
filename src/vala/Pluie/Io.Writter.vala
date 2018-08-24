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

/**
 * basic writer
 */
public class Pluie.Io.Writter
{
    /**
     * current file path
     */
    public string   path      { get; internal set; }
    /**
     *
     */
    public File     file      { get; internal set; }
    /**
     * stream used to read the file
     */
    DataOutputStream stream;

    /**
     * construct a reader
     * by adding {@link Io.StreamLineMark}
     * @param path the path to load
     */
    public Writter (string path)
    {
        this.path   = path;
        this.file   = File.new_for_path (path);
        try {
            this.stream = new DataOutputStream(file.create (FileCreateFlags.NONE));
            if (!file.query_exists ()) {
                of.error ("cannot create file '%s'".printf (path));
            }
        }
        catch (GLib.Error e) {
            of.error (e.message);
        }
    }

    /**
     * read current stream by line
     * @param mark a mark used to operate possible future rewind
     * @return current readed line
     */
    public bool write (uint8[] data)
    {
        bool done = false;
        try {
            long written = 0;
            while (written < data.length) { 
                // sum of the bytes that already have been written to the stream
                written += stream.write (data[written:data.length]);
            }
            done = written == data.length;
        }
        catch (GLib.Error e) {
            of.error (e.message);
        }
        return done;
    }

}
