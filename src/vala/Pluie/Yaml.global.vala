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

namespace Pluie
{
    namespace Yaml
    {
        const string YAML_VERSION          = "1.2";
        const string YAML_VALA_PREFIX      = "v";
        const string YAML_VALA_DIRECTIVE   = "tag:pluie.org,2018:vala/";

        public static bool DEBUG           = false;

        public static bool DBG_SHOW_INDENT = true;
        public static bool DBG_SHOW_PARENT = false;
        public static bool DBG_SHOW_UUID   = true;
        public static bool DBG_SHOW_LEVEL  = false;
        public static bool DBG_SHOW_REF    = false;
        public static bool DBG_SHOW_COUNT  = true;
        public static bool DBG_SHOW_TAG    = true;
        public static bool DBG_SHOW_TYPE   = true;

        /**
         *
         */
        public static void dbg_action (string msg, string? val = null)
        {
            if (Pluie.Yaml.DEBUG) of.action (msg, val);
        }

        /**
         *
         */
        public static void dbg_keyval (string key, string val)
        {
            if (Pluie.Yaml.DEBUG) of.keyval (key, val);
        }

        /**
         *
         */
        public static void dbg_state (bool done)
        {
            if (Pluie.Yaml.DEBUG) of.state (done);
        }

        /**
         *
         */
        public static void dbg (string? msg = null)
        {
            if (Pluie.Yaml.DEBUG && msg != null) of.echo (msg);
        }

        /**
         * ParseError 
         */
        public errordomain AddNodeError
        {
            MAPPING_CONTAINS_CHILD,
            MAPPING_IS_SINGLE_PAIR,
            MAPPING_NOT_SINGLE_PAIR
        }

        private const ZlibCompressorFormat ZFORMAT = ZlibCompressorFormat.GZIP;

        /**
         *
         */
        private void convert (File source, File dest, Converter converter) throws Error {
            var src_stream = source.read ();
            var dst_stream = dest.replace (null, false, 0);
            var conv_stream = new ConverterOutputStream (dst_stream, converter);
            // 'splice' pumps all data from an InputStream to an OutputStream
            conv_stream.splice (src_stream, 0);
        }

        /**
         *
         */
        public static uint8[] serialize (GLib.Object? obj, string? dest = null)
        {
            Array<uint8> a = new Array<uint8> ();
            if (obj != null) {
                var node = obj.get_type ().is_a (typeof (Yaml.Node)) ? obj as Yaml.Node : Yaml.Builder.to_node (obj);
                if (node != null) {
                    var content = node.to_yaml_string ();
                    var date    = new GLib.DateTime.now_local ().format ("%s");
                    var path    = Path.build_filename (Environment.get_tmp_dir (), "pluie-yaml-%s-%s.source".printf (date, node.uuid));
                    var dpath   = dest == null ? path + ".gz" : dest;
                    var writter = new Io.Writter (path);
                    if (writter.write (content.data)) {
                        try {
                            var gzfile = File.new_for_path (dpath);
                            convert (writter.file, gzfile, new ZlibCompressor (ZFORMAT));
                            var reader = new Io.InputChunkStream(dpath, 80);
                            while (!reader.eof ()) {
                                var b = reader.read ();
                                a.append_vals (b, reader.get_buffer_size ());
                            }
                            writter.delete_file ();
                            if (dest == null) {
                                writter.delete_file (gzfile);
                            }
                        }
                        catch (GLib.Error e) {
                            of.error (e.message);
                        }
                    }
                }
            }
            return a.data;
        }

        /**
         *
         */
        public static Yaml.Root deserialize (uint8[] zdata)
        {
            Yaml.Root? obj = null;
            if (zdata.length > 0) {
                var date    = new GLib.DateTime.now_local ().format ("%s");
                var path    = Path.build_filename (Environment.get_tmp_dir (), "pluie-yaml-%s.gz".printf (date));
                var dpath   = Path.build_filename (Environment.get_tmp_dir (), "pluie-yaml-%s.source".printf (date));
                var writter = new Io.Writter (path);
                if (writter.write (zdata)) {
                    var file = File.new_for_path (dpath);
                    try {
                        convert (writter.file, file, new ZlibDecompressor (ZFORMAT));
                        var config = new Yaml.Config (dpath);
                        obj = config.root_node ();
                        writter.delete_file ();
                    }
                    catch(GLib.Error e) {
                        of.error (e.message);
                    }
                }
            }
            return obj;
        }

        /**
         * haxadecimal sequence
         */
        const string hexa_sequence = "0123456789abcdef";

        /**
         * convert %02x string to uint8
         * @param hex2byte string representation of hexadecimal value on 1 byte
         */
        uint8 hex_to_dec (string hexbyte)
        {
            return (uint8) (
                Yaml.hexa_sequence.index_of(hexbyte.data[0].to_string ())*16 +
                Yaml.hexa_sequence.index_of(hexbyte.data[1].to_string ())
            );
        }

        /**
         * enum MatchInfo keys of Yaml.Mode.find method related to mode FIND_MODE.SQUARE_BRACKETS of Yaml.Node
         */
        public enum EVT {
            NONE,
            STREAM_START,
            STREAM_END,
            VERSION_DIRECTIVE,
            TAG_DIRECTIVE,
            DOCUMENT_START,
            DOCUMENT_END,
            BLOCK_SEQUENCE_START,
            BLOCK_MAPPING_START,
            BLOCK_END,
            FLOW_SEQUENCE_START,
            FLOW_SEQUENCE_END,
            FLOW_MAPPING_START,
            FLOW_MAPPING_END,
            BLOCK_ENTRY,
            FLOW_ENTRY,
            KEY,
            VALUE,
            ALIAS,
            ANCHOR,
            TAG,
            SCALAR;

            /**
              * @return infos related to EVT
              */
            public string infos ()
            {
                return this.to_string().substring("PLUIE_YAML_".length);
            }

            /**
              * @return event is key
              */
            public bool is_key ()
            {
                return this == EVT.KEY;
            }

            /**
              * @return event is anchor
              */
            public bool is_anchor ()
            {
                return this == EVT.ANCHOR;
            }

            /**
              * @return event is alias
              */
            public bool is_alias ()
            {
                return this == EVT.ALIAS;
            }

            /**
              * @return event is tag
              */
            public bool is_tag ()
            {
                return this == EVT.TAG;
            }

            /**
              * @return event is tag
              */
            public bool is_tag_directive ()
            {
                return this == EVT.TAG_DIRECTIVE;
            }

            /**
              * @return event is key
              */
            public bool is_value ()
            {
                return this == EVT.VALUE;
            }

            /**
              * @return event is scalar
              */
            public bool is_scalar ()
            {
                return this == EVT.SCALAR;
            }

            /**
              * @return event is mapping start event
              */
            public bool is_mapping_start ()
            {
                return this == EVT.BLOCK_MAPPING_START || this == EVT.FLOW_MAPPING_START;
            }

            /**
              * @return event is sequence start event
              */
            public bool is_sequence_start ()
            {
                return this == EVT.BLOCK_SEQUENCE_START || this == EVT.FLOW_SEQUENCE_START;
            }

            /**
              * @return event is sequence end event
              */
            public bool is_sequence_end ()
            {
                return this == EVT.BLOCK_END || this == EVT.FLOW_SEQUENCE_END;
            }

            /**
              * @return event is sequence entry event
              */
            public bool is_entry ()
            {
                return this == EVT.BLOCK_ENTRY || this == EVT.FLOW_ENTRY;
            }

            /**
              * @return event is mapping end event
              */
            public bool is_mapping_end ()
            {
                return this == EVT.BLOCK_END;
            }

            /**
              * @return event is error event
              */
            public bool is_error ()
            {
                return this == EVT.NONE;
            }

        }

        /**
         * enum possible find mode of Yaml.Node.mode
         */
        public enum FIND_MODE
        {
            DOT,
            SQUARE_BRACKETS;

            /**
             *
             */
            public bool is_dot ()
            {
                return this == DOT;
            }
        }

        public static FIND_MODE MODE = FIND_MODE.DOT;

        /**
         * enum MatchInfo keys of Yaml.Mode.find method related to mode FIND_MODE.SQUARE_BRACKETS of Yaml.Node
         */
        internal enum FIND_COLLECTION { PATH, OPEN, KEY, CLOSE; }

        /**
         * enum MatchInfo keys of Yaml.Node.find method related to mode FIND_MODE.DOT of Yaml.Node
         */
        internal enum FIND_DOT        { PATH, KEY, SEQUENCE; }

        /**
         * enum possible type of Yaml.Node
         */
        public enum NODE_TYPE
        {
            UNDEFINED,
            ROOT,
            SCALAR,
            SINGLE_PAIR,
            MAPPING,
            SEQUENCE;

            /**
             * @return if current NODE_TYPE match a collection node (root|mapping|sequence)
             */
            public bool is_collection ()
            {
                return this == MAPPING || this == SEQUENCE || this == ROOT;
            }

            /**
             * @return if current NODE_TYPE match a scalar node
             */
            public bool is_scalar ()
            {
                return this == SCALAR;
            }

            /**
             * @return if current NODE_TYPE match a single/pair mapping node
             */
            public bool is_single_pair ()
            {
                return this == SINGLE_PAIR;
            }

            /**
             * @return if current NODE_TYPE match a mapping node
             */
            public bool is_mapping ()
            {
                return this == MAPPING;
            }

            /**
             * @return if current NODE_TYPE match a sequence node
             */
            public bool is_sequence ()
            {
                return this == SEQUENCE;
            }

            /**
             * @return if current NODE_TYPE match a root node
             */
            public bool is_root ()
            {
                return this == ROOT;
            }

            /**
             *@return infos related to NODE_TYPE
             */
            public string infos ()
            {
                return this.to_string().substring("PLUIE_YAML_NODE_TYPE_".length);
            }
        }

        /**
         *@return universal infos related to NODE_TYPE
         */
        public string uuid ()
        {
            var sb = new StringBuilder();
            for (var i = 0; i < 4; i++) sb.append (Random.next_int ().to_string ("%08x"));
            var h = sb.str;
            var d = Yaml.hex_to_dec (h.substring (16, 2));
            d    &= 0x3f;
            d    |= 0x80;
            return "%s-%s-4%s-%02x%s-%s".printf (
                h.substring (0, 8),
                h.substring (8, 4),
                h.substring (13, 3),
                d,
                h.substring (18, 2),
                h.substring (20)
            );
        }
    }
}
