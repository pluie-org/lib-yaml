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
using Gee;
using Pluie;
extern void yaml_parse_file(string srcPath, string destPath);

/**
 * a Yaml scanner class dealing with libyaml to generate a list of Yaml.Event
 */
public class Pluie.Yaml.Scanner
{
    string             path;
    /**
     * Regex pattern use to find EVENT
     */
    const string       REG_EVENT     = "^([0-9]+), ([0-9]+)(.*)$";
    /**
     * Regex pattern use to find EVENT VERSION
     */
    const string       REG_VERSION   = "^, ([0-9]+), ([0-9]+)$";
    /**
     * Regex pattern use to find EVENT TAG
     */
    const string       REG_TAG       = "^, \"([^\"]*)\", \"([^\"]*)\"$";
    /**
     * Regex pattern use to find EVENT ERROR
     */
    const string       REG_ERROR     = "^, \"([^\"]*)\"$";
    /**
     * Regex pattern use to find EVENT SCALAR
     */
    const string       REG_SCALAR    = "^, ([0-9]+), \"(.*)\"$";
    /**
     * Regex pattern use to find EVENT ANCHOR
     */
    const string       REG_ANCHOR    = "^, \"([^\"]*)\"$";
    /**
     * Regex pattern use to find EVENT ALIAS
     */
    const string       REG_ALIAS     = "^, \"([^\"]*)\"$";

    /**
     * enum linked to MatchInfo REG_EVENT
     */
    enum               MIEVT         { NONE, LINE, TYPE, DATA }
    /**
     * enum linked to MatchInfo REG_VERSION
     */
    enum               MIEVT_VERSION { NONE, MAJOR, MINOR }
    /**
     * enum linked to MatchInfo REG_SCALAR
     */
    enum               MIEVT_SCALAR  { NONE, STYLE, DATA }
    /**
     * enum linked to MatchInfo REG_TAG
     */
    enum               MIEVT_TAG     { NONE,  HANDLE, SUFFIX }
    /**
     * enum linked to MatchInfo REG_ANCHOR
     */
    enum               MIEVT_ANCHOR  { NONE, ID }
    /**
     * enum linked to MatchInfo REG_ERROR
     */
    enum               MIEVT_ERROR   { NONE, DATA }

    /**
     * indicate if file has been sucessfully scanned
     */
    public bool        done          { get; internal set; }

    /**
     * Reader used to load content yaml file
     */
    Io.Reader          reader;

    /**
     * Yaml Processor used to process events
     */
    Yaml.Processor     processor     { get; internal set; }

    /**
     * @param path the path of file to scan
     */
    public Scanner (string path)
    {
        var date     = new GLib.DateTime.now_local ().format ("%s");
        this.path    = Path.build_filename (Environment.get_tmp_dir (), "pluie-yaml-%s-%s.events".printf (date, Path.get_basename(path)));
        yaml_parse_file(path, this.path);
        this.reader  = new Io.Reader (this.path);
    }

    /**
     *
     */
    ~Scanner()
    {
        var f = GLib.File.new_for_path (this.path);
        try {
            f.delete ();
        }
        catch (GLib.Error e) {
            of.error (e.message);
        }
    }

    /**
     * return resulting Yaml root node
     */
    public Yaml.Node? get_nodes ()
    {
        return this.processor.root;
    }

    /**
     * return error Yaml Event
     */
    public Yaml.Event? get_error_event ()
    {
        return this.processor.error_event;
    }

    /**
     * scan specifiyed file generated throught yaml.c
     * @param path optional file path to scan
     */
    public bool run (string? path = null)
    {
        Dbg.in (Log.METHOD, "path:'%s'".printf (path), Log.LINE, Log.FILE);
        this.before_run (path);
        this.processor = new Yaml.Processor ();
        this.done      = false;
        Yaml.dbg_action ("Scanning events", path);
        while (this.reader.readable) {
            this.scan_event (this.reader.read ());
        }
        this.done = true;
        Yaml.dbg_state (this.done);
        this.done = this.done && this.processor.run ();
        Yaml.dbg_state (this.done);
        Dbg.out (Log.METHOD, "done:%d".printf ((int)done), Log.LINE, Log.FILE);
        return this.done;
    }

    /**
     *
     */
    private void before_run (string? path)
    {
        if (path != null && this.reader.path != path) {
            this.reader.load (path);
        }
        else {
            this.reader.rewind(new Io.StreamLineMark(0, 0));
        }
    }

    /**
     * register event version
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void register_event_version(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_VERSION);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data =  new HashMap<string, string>();
            data.set("major", mi.fetch (MIEVT_VERSION.MAJOR));
            data.set("minor", mi.fetch (MIEVT_VERSION.MINOR));
        }
        this.processor.events.add(new Yaml.Event(EVT.VERSION_DIRECTIVE, line, null, data));
    }

    /**
     * register event tag
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void register_event_tag_directive(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_TAG);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data  = new HashMap<string, string>();
            data.set("handle", mi.fetch (MIEVT_TAG.HANDLE));
            data.set("prefix", mi.fetch (MIEVT_TAG.SUFFIX));
        }
        this.processor.events.add(new Yaml.Event(EVT.TAG_DIRECTIVE, line, null, data));
    }

    /**
     * register event tag
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void register_event_tag(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_TAG);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data  = new HashMap<string, string>();
            data.set("handle", mi.fetch (MIEVT_TAG.HANDLE));
            data.set("suffix", mi.fetch (MIEVT_TAG.SUFFIX));
        }
        this.processor.events.add(new Yaml.Event(EVT.TAG, line, null, data));
    }

    /**
     * register event version
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void register_event_error(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_ERROR);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data =  new HashMap<string, string>();
            data.set("error", mi.fetch (MIEVT_ERROR.DATA));
        }
        this.processor.events.add(new Yaml.Event(EVT.NONE, line, null, data));
    }

    /**
     * register event scalar
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void register_event_scalar(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_SCALAR);
        HashMap<string, string>? data = null;
        int? style = null;
        if (reg.match (evtdata, 0, out mi)) {
            style = int.parse(mi.fetch (MIEVT_SCALAR.STYLE));
            data  = new HashMap<string, string>();
            data.set("data", mi.fetch (MIEVT_SCALAR.DATA));
        }
        this.processor.events.add(new Yaml.Event(EVT.SCALAR, line, style, data));
    }

    /**
     * register event anchor
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void register_event_anchor(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_ANCHOR);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data  = new HashMap<string, string>();
            data.set("id", mi.fetch (MIEVT_ANCHOR.ID));
        }
        this.processor.events.add(new Yaml.Event(EVT.ANCHOR, line, null, data));
    }

    /**
     * register event alias
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void register_event_alias(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_ALIAS);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data  = new HashMap<string, string>();
            data.set("id", mi.fetch (MIEVT_ANCHOR.ID));
        }
        this.processor.events.add(new Yaml.Event(EVT.ALIAS, line, null, data));
    }

    /**
     * scan specifiyed line
     * @param data the current line
     */
    private void scan_event (string? data = null)
    {
        Dbg.in (Log.METHOD, null, Log.LINE, Log.FILE);
        if (data == null) {
            return;
        }
        try {
            MatchInfo mi = null;
            Regex    reg = new Regex (REG_EVENT);
            if (reg.match (data, 0, out mi)) {
                int line    = int.parse(mi.fetch (MIEVT.LINE));
                int type    = int.parse(mi.fetch (MIEVT.TYPE));
                string evtdata = mi.fetch (MIEVT.DATA);
                switch(type) {
                    case EVT.SCALAR :
                        this.register_event_scalar (evtdata, line);
                        break;
                    case EVT.ANCHOR :
                        this.register_event_anchor (evtdata, line);
                        break;
                    case EVT.ALIAS :
                        this.register_event_alias (evtdata, line);
                        break;
                    case EVT.TAG :
                        this.register_event_tag (evtdata, line);
                        break;
                    case EVT.TAG_DIRECTIVE :
                        this.register_event_tag_directive (evtdata, line);
                        break;
                    case EVT.VERSION_DIRECTIVE : 
                        this.register_event_version (evtdata, line);
                        break;
                    case EVT.NONE :
                        this.register_event_error (evtdata, line);
                        break;
                    default :
                        this.processor.events.add(new Yaml.Event ((Yaml.EVT) type, line, null, null));
                        break;
                }
            }
        }
        catch (GLib.RegexError e) {
            Dbg.error (e.message, Log.METHOD, Log.LINE, Log.FILE);
        }
        Dbg.out (Log.METHOD, null, Log.LINE, Log.FILE);
    }
}
