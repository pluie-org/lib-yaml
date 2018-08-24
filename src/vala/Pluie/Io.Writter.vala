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
 * basic writter class
 */
public class Pluie.Io.Writter
{
    /**
     * current file path
     */
    public string   path      { get; internal set; }
    /**
     * current file
     */
    public File     file      { get; internal set; }
    /**
     * stream used to read the file
     */
    DataOutputStream stream;

    /**
     * construct a writter
     * @param path the path to write
     * @param delete_if_exists flag indicating if existing file must be removed first
     */
    public Writter (string path, bool delete_if_exists = false)
    {
        this.path = path;
        this.file = File.new_for_path (path);
        try {
            if (delete_if_exists) {
                this.delete_file(this.file);
            }
            this.file   = File.new_for_path (path);
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
     * write specified data to current file
     * @param data the data to write
     * @param written the written data size
     */
    public bool write (uint8[] data, out long? written = null)
    {
        bool done = false;
        long w = 0;
        try {
            while (w < data.length) { 
                // sum of the bytes that already have been written to the stream
                w += stream.write (data[w:data.length]);
            }
            done = w == data.length;
        }
        catch (GLib.Error e) {
            of.error (e.message);
        }
        written = w;
        return done;
    }

    /**
     * delete current or specified file
     * @param file the file to delete (current file if null)
     */
    public bool delete_file(File? file = null)
    {
        bool done = false;
        try {
            ((file == null) ? this.file : file).delete ();
            done = true;
        }
        catch (GLib.Error e) {
            of.error (e.message);
        }
        return done;
    }
}
