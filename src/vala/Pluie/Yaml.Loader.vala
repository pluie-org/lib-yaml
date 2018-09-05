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
using Gee;
using Pluie;

/**
 * a Yaml Loader class
 */
public class Pluie.Yaml.Loader
{
    /**
     * Flag PACK_NESTED_ENTRIES
     */
    public static bool  PACK_NESTED_ENTRIES { public get; public set; default = false; }
    /**
     * Yaml.Scanner used to retriew yaml events
     */
    Yaml.Scanner        scanner            { public get; internal set; }
    /**
     * indicate if file has been sucessfully loaded
     */
    public bool         done               { get; internal set; }

    /**
     * Reader used to load content yaml file
     */
    Io.Reader           reader;

    /**
     * default constructor of Yaml.Loader
     * @param path the path of file to parse
     * @param display_file display original file
     * @param displayNode display corresponding Yaml Node Graph
     */
    public Loader (string path, bool display_file = false, bool displayNode = false )
    {
        this.reader  = new Io.Reader (path);
        if (this.reader.readable) {
            this.scanner = new Yaml.Scanner (path);
            if (display_file) this.display_file ();

            if ((this.done = this.scanner.run())) {
                if (displayNode) {
                    var n = this.get_nodes ();
                    if (n != null) n.display_childs ();
                    of.state(n != null);
                }
            }
            else {
                var evt = this.scanner.get_error_event ();
                of.error ("line %d (%s)".printf (evt.line, evt.data["error"]));
                this.display_file (evt.line);
            }
        }
    }

    /**
     * return resulting Yaml root node
     */
    public Yaml.Node? get_nodes ()
    {
        Yaml.Node? n = this.scanner.get_nodes ();
        if (PACK_NESTED_ENTRIES) {
            this.pack_entries (n);
        }
        return n;
    }

    /**
     *
     */
    private void pack_entries (Yaml.Node? node = null)
    {
        bool restart = false;
        if (node != null) {
            if (node.ntype.is_sequence ()) {
                foreach (var child in node) {
                    if (child.ntype.is_mapping () && child.name[0] == '_' && child.count () == 1) {
                        var sub = child.first ().clone_node ();
                        node.replace_node (child, sub);
                        restart = true;
                        break;
                    }
                }
                if (restart) pack_entries (node);
            }
            else foreach (var child in node) this.pack_entries (child);
        }
    }

    /**
     * display original file
     * @param errorLine  highlight error line
     */
    public void display_file (int errorLine = 0)
    {
        of.action (errorLine == 0 ? "Reading file" : "Invalid Yaml File", this.reader.path);
        of.echo ();
        this.reader.rewind(new Io.StreamLineMark(0, 0));
        int     line   = 0;
        string? data   = null;
        bool    err    = false;
        bool    before = false;
        while (this.reader.readable) {
            line   = this.reader.line + 1;
            data   = this.reader.read ();
            err    = errorLine > 0 && line == errorLine;
            before = errorLine == 0 || line < errorLine;
            if (this.bypass_ellipse (errorLine, line)) continue;
            ECHO color = data!=null && data.strip()[0] != '#' ? ECHO.COMMAND : ECHO.COMMENT;
            of.echo ("%s%s%s".printf (
                of.c (ECHO.MICROTIME   ).s (" %03d ".printf (line)),
                of.c (ECHO.DATE).s ("| "),
                err ? of.c (ECHO.FAIL).s (data)
                    : of.c (color).s (data)
            ), before);
            if (err) {
                int len = of.term_width - data.length - 13;
                stdout.printf (of.c (ECHO.FAIL).s (@" %$(len)s ".printf (" ")));
                of.echo (Color.off (), true);
            }
            else if (!before) break;
        }
        of.echo (errorLine == 0 ? "EOF" : "");
        of.state (errorLine == 0);
    }

    /**
     * bypass_ellipse
     */
    private bool bypass_ellipse (int errorLine, int line)
    {
        bool bypass = false;
        if (errorLine > 0 && line > 0) {
            if (line < errorLine - 7) bypass = true;
            else if (line == errorLine - 7 && line > 1) {
                of.echo ("%s%s%s".printf (
                    of.c (ECHO.MICROTIME   ).s (" %03d ".printf (line-1)),
                    of.c (ECHO.DATE).s ("| "),
                    of.c (ECHO.COMMAND).s ("... ")
                ));
            }
        }
        return bypass;
    }

}
