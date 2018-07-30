using GLib;
using Gee;
using Pluie;
extern void yaml_parse_file(string srcPath, string destPath);

/**
 * a tiny Yaml Parser whose purpose is not to comply with all yaml specifications but to parse yaml configuration files
 * todo improve description of what is expected
 */
public class Pluie.Yaml.Processor
{
    const string REG_EVENT   = "^([0-9]+), ([0-9]+)(.*)$";
    const string REG_VERSION = "^, ([0-9]+), ([0-9]+)$";
    const string REG_TAG     = "^, \"([^\"]*)\", \"([^\"]*)\"$";
    const string REG_ERROR   = "^, \"([^\"]*)\"$";
    const string REG_SCALAR  = "^, ([0-9]+), \"([^\"]*)\"$";
    const string REG_ANCHOR  = "^, \"([^\"]*)\"$";
    const string REG_ALIAS   = "^, \"([^\"]*)\"$";

    /**
     * enum linked to used RegExp in parse_line
     */
    enum MIEVT
    {
        NONE,
        LINE,
        TYPE,
        DATA
    }

    /**
     * enum linked to used RegExp in parse_line
     */
    enum MIEVT_VERSION
    {
        NONE,
        MAJOR,
        MINOR
    }

    /**
     * enum linked to used RegExp in parse_line
     */
    enum MIEVT_SCALAR
    {
        NONE,
        STYLE,
        DATA
    }

    /**
     * enum linked to used RegExp in parse_line
     */
    enum MIEVT_TAG
    {
        NONE,
        HANDLE,
        SUFFIX
    }

    /**
     * enum linked to used RegExp in parse_line
     */
    enum MIEVT_ANCHOR
    {
        NONE,
        ID,
    }

    /**
     * enum linked to used RegExp in parse_line
     */
    enum MIEVT_ERROR
    {
        NONE,
        DATA,
    }

    /**
     * indicate if file has been sucessfully parsed
     */
    public bool done;

    /**
     * indicate if parsing msut stop
     */
    bool stop;

    /**
     * the mark use to rewind line throught Io.Reader
     */
    Io.StreamLineMark? mark;

    /**
     * Reader used to load content yaml file
     */
    Io.Reader reader;

    /**
     * Events list
     */
    Gee.LinkedList<Yaml.Event>   events           { get; internal set; }

    /**
     *Anchor map
     */
    Gee.HashMap<string, int>     anchors          { get; internal set; }

    /**
     * @param path the path of file to parse
     */
    public Processor (string path)
    {
        var destPath = Path.build_filename (Environment.get_tmp_dir (), Path.get_basename(path));
        yaml_parse_file(path, destPath);
        this.reader  = new Io.Reader (destPath);
        this.scan ();
    }

    /**
     * parse a file related to specifiyed path
     * @param path the path to parse
     */
    public bool scan (string? path = null)
    {
        Dbg.in (Log.METHOD, "path:'%s'".printf (path), Log.LINE, Log.FILE);
        if (path != null) {
            this.reader.load (path);
        }
        else {
            this.reader.rewind(new Io.StreamLineMark(0, 0));
        }
        this.events  = new Gee.LinkedList<Yaml.Event>();
        this.anchors = new Gee.HashMap<string, int>();
        this.stop    = this.done = false;
        of.action ("Scanning events", path);
        while (this.reader.readable) {
            this.scan_line (this.reader.read ());
        }
        this.process_events ();

        this.done = true;
        Dbg.out (Log.METHOD, "done:%d".printf ((int)done), Log.LINE, Log.FILE);
        return this.done;
    }

    /**
     *
     */
    private void process_events ()
    {
        of.action ("Reading events");
        foreach (Yaml.Event event in this.events) {
            int len = 24 - event.evtype.infos ().length;
            stdout.printf("    [ %s"+@" %$(len)s "+", %d, %s", event.evtype.infos (), " ", event.line, event.style != null ? event.style.to_string () : "0");
            if (event.data != null && event.data.size > 0) {
                stdout.printf (", {");
                var it = event.data.map_iterator ();
                string sep;
                for (var has_next = it.next (); has_next; has_next = it.next ()) {
                    sep = it.has_next () ? ", " : "";
                    stdout.printf ("%s: %s%s", it.get_key (), it.get_value (), sep);
                }
                stdout.printf (" }");
            }
            stdout.printf("]\n");
        }
    }

    /**
     * set event version
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void set_event_version(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_VERSION);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data =  new HashMap<string, string>();
            data.set("major", mi.fetch (MIEVT_VERSION.MAJOR));
            data.set("minor", mi.fetch (MIEVT_VERSION.MINOR));
        }
        this.events.offer(new Yaml.Event(EVT.VERSION_DIRECTIVE, line, null, data));
    }


    /**
     * set event tag
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void set_event_tag(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_TAG);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data  = new HashMap<string, string>();
            data.set("handle", mi.fetch (MIEVT_TAG.HANDLE));
            data.set("suffix", mi.fetch (MIEVT_TAG.SUFFIX));
        }
        this.events.offer(new Yaml.Event(EVT.TAG, line, null, data));
    }

    /**
     * set event version
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void set_event_error(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_ERROR);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data =  new HashMap<string, string>();
            data.set("error", mi.fetch (MIEVT_ERROR.DATA));
        }
        this.events.offer(new Yaml.Event(EVT.NONE, line, null, data));
    }

    /**
     * set event scalar
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void set_event_scalar(string evtdata, int line) throws GLib.RegexError
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
        this.events.offer(new Yaml.Event(EVT.SCALAR, line, style, data));
    }

    /**
     * set event anchor
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void set_event_anchor(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_ANCHOR);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data  = new HashMap<string, string>();
            data.set("id", mi.fetch (MIEVT_ANCHOR.ID));
        }
        this.anchors.set(data.get("id"), this.events.size);
        this.events.offer(new Yaml.Event(EVT.ANCHOR, line, null, data));
    }

    /**
     * set event alias
     * @param evtdata the current data event
     * @param line the current line
     * @throws GLib.RegexError
     */
    private void set_event_alias(string evtdata, int line) throws GLib.RegexError
    {
        MatchInfo mi = null;
        Regex    reg = new Regex (REG_ALIAS);
        HashMap<string, string>? data = null;
        if (reg.match (evtdata, 0, out mi)) {
            data  = new HashMap<string, string>();
            data.set("id", mi.fetch (MIEVT_ANCHOR.ID));
        }
        this.events.offer(new Yaml.Event(EVT.ALIAS, line, null, data));
    }

    /**
     * parse specifiyed line
     * @param data the current line
     */
    private void scan_line (string? data = null)
    {
        Dbg.in (Log.METHOD, null, Log.LINE, Log.FILE);
        if (data == null) {
            this.stop = true;
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
                        this.set_event_scalar(evtdata, line);
                        break;
                    case EVT.ANCHOR :
                        this.set_event_anchor(evtdata, line);
                        break;
                    case EVT.ALIAS :
                        this.set_event_alias(evtdata, line);
                        break;
                    case EVT.TAG :
                        this.set_event_tag(evtdata, line);
                        break;
                    case EVT.VERSION_DIRECTIVE : 
                        this.set_event_version(evtdata, line);
                        break;
                    case EVT.NONE :
                        this.set_event_error(evtdata, line);
                        break;
                    default :
                        this.events.offer(new Yaml.Event((Yaml.EVT)type, line, null, null));
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
