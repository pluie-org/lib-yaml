/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.3
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
using Pluie;

/**
 * a Yaml Loader class
 */
public class Pluie.Yaml.Loader
{
    /**
     * Scanner 
     */
    Yaml.Scanner    scanner     { public get; internal set; }

    /**
     * indicate if file has been sucessfully loaded
     */
    public bool     done        { get; internal set; }

    /**
     * Reader used to load content yaml file
     */
    Io.Reader       reader;

    /**
     * @param path the path of file to parse
     * @param displayFile display original file
     * @param displayNode display corresponding Yaml Node Graph
     */
    public Loader (string path, bool displayFile = false, bool displayNode = false )
    {
        this.reader  = new Io.Reader (path);
        if (displayFile) {
            this.displayFile ();
        }
        this.scanner = new Yaml.Scanner (path);
        if ((this.done = this.scanner.run()) && displayNode) {
            this.get_nodes ().display_childs ();
            of.state(true);
        }
        if (!this.done) {
            var evt = this.scanner.get_error_event ();
            of.error ("line %d (%s)".printf (evt.line, evt.data["error"]));
            this.displayFile (evt.line);
        }
    }

    /**
     * return resulting Yaml root node
     */
    public Yaml.NodeRoot get_nodes ()
    {
        return this.scanner.get_nodes ();
    }

    /**
     * display original file
     */
    public void displayFile (int errorLine = 0)
    {
        of.action (errorLine == 0 ? "Reading file" : "Invalid Yaml File", this.reader.path);
        of.echo ();
        this.reader.rewind(new Io.StreamLineMark(0, 0));
        int     line = 0;
        string? data = null;;
        while (this.reader.readable) {
            line = this.reader.line + 1;
            data = this.reader.read ();
            if (errorLine > 0 && line > 0) {
                if (line < errorLine - 7) continue;
                else if (line == errorLine - 7) {
                    of.echo ("%s%s%s".printf (
                        of.c (ECHO.MICROTIME   ).s (" %03d ".printf (line-1)),
                        of.c (ECHO.DATE).s ("| "),
                        of.c (ECHO.COMMAND).s ("... ")
                    ));
                }
            }
            of.echo ("%s%s%s".printf (
                of.c (ECHO.MICROTIME   ).s (" %03d ".printf (line)),
                of.c (ECHO.DATE).s ("| "),
                errorLine > 0 && line == errorLine
                    ? of.c (ECHO.FAIL).s (data)
                    : of.c (ECHO.COMMAND).s (data)
            ), errorLine == 0 || line < errorLine);
            if (errorLine > 0 &&  line == errorLine) {
                int len = of.term_width - data.length - 13;
                stdout.printf (of.c (ECHO.FAIL).s (@" %$(len)s ".printf (" ")));
                of.echo (Color.off (), true);
            }
            if (errorLine > 0 && line > errorLine) {
                break;
            }
        }
        of.echo (errorLine == 0 ? "EOF" : "");
        of.state (errorLine == 0);
    }
}
