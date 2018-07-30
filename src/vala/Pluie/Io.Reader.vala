using GLib;
using Gee;
using Pluie;

/**
 * a class to read file line by line with convenient methods to rewind to specific lines
 * using {@link Io.StreamLineMark}
 */
public class Pluie.Io.Reader
{
    /**
     * current file path
     */
    public string   path      { get; internal set; default = null; }
    /**
     * indicates the current line number
     */
    public int      line      { get; internal set; default = 0; }
    /**
     * indicates if current stream is readable
     */
    public bool     readable  { get; internal set; default = false; }
    /**
     * stream used to read the file
     */
    DataInputStream stream;

    /**
     * construct a reader
     * by adding {@link Io.StreamLineMark}
     * @param path the path to load
     */
    public Reader (string path)
    {
        this.load (path);
    }

    /**
     * load a yaml file by specifiyed path
     * @param path the path to load
     * @return operation succeed
     */
    public bool load (string path)
    {
        Dbg.in (Log.METHOD, "path:'%s'".printf (path), Log.LINE, Log.FILE);
        if (path == this.path && this.line > 0) {
            if (this.rewind (new Io.StreamLineMark (0, 0))) {
                return this.readable;
            }
        }
        this.readable = false;
        this.path     = path;
        this.line     = 0;
        var file      = File.new_for_path (path);
        if (!file.query_exists ()) {
            of.error ("File '%s' doesn't exist.".printf (file.get_path ()));
        }
        else {
            try {
                this.stream   = new DataInputStream (file.read ());
                this.readable = true;
                this.line++;
            }
            catch (Error e) {
                of.error (e.message);
            }
        }
        Dbg.out (Log.METHOD, "done:%d".printf ((int)this.readable), Log.LINE, Log.FILE);
        return this.readable;
    }

    /**
     * read current stream by line
     * @param mark a mark used to operate possible future rewind
     * @return current readed line
     */
    public string? read (out Io.StreamLineMark? mark = null)
    {
        mark = null;
        string? data = null;
        if (this.readable) {
            try {
                // save pos before consume line
                mark = new Io.StreamLineMark (this.stream.tell (), this.line);
                data = this.stream.read_line (null);
                if ((this.readable = data != null)) {
                    this.line++;
                }
            }
            catch (IOError e) {
                this.readable = false;
                of.error (e.message);
            }
        }
        return data;
    }

    /**
     * rewind current reading to specifiyed mark
     * @return operation succeed
     */
    public bool rewind (Io.StreamLineMark mark)
    {
        this.readable = false;
        try {
            this.line     = mark.line;
            this.readable = this.stream.seek (mark.pos, SeekType.SET);
        }
        catch (Error e) {
            of.error (e.message);
        }
        return this.readable;
    }

}
