/**
 * a class representing a stream mark recording a line and it's position in the stream
 * to permit future rewind @see Io.Reader
 */
public class Pluie.Io.StreamLineMark
{
    /**
     * current line
     */
    public int     line { get; internal set; default = 0; }
    /**
     * current position (stream.tell value)
     */
    public int64   pos  { get; internal set; default = 0; }

    /**
     * construct a StreamLineMark with given pos & line
     */
    public StreamLineMark (int64 pos, int line)
    {
        this.pos  = pos;
        this.line = line;
    }

}
