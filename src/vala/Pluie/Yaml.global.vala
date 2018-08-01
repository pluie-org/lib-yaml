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

namespace Pluie
{
    namespace Yaml
    {
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
