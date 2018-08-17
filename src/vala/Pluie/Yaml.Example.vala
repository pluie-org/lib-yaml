/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.4
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

/**
 * a test class to implements yamlize

 */
public class Pluie.Yaml.Example : Yaml.Object
{
    public string          myname        { get; set; }
    public string          type_string   { get; set; }
    public int             type_int      { get; set; }
    public uint            type_uint     { get; set; }
    public float           type_float    { get; set; }
    public double          type_double   { get; set; }
    public char            type_char     { get; set; }
    public uchar           type_uchar    { get; set; }
    public unichar         type_unichar  { get; set; }
    public short           type_short    { get; set; }
    public ushort          type_ushort   { get; set; }
    public long            type_long     { get; set; }
    public ulong           type_ulong    { get; set; }
    public size_t          type_size_t   { get; set; }
    public ssize_t         type_ssize_t  { get; set; }
    public int8            type_int8     { get; set; }
    public uint8           type_uint8    { get; set; }
    public int16           type_int16    { get; set; }
    public uint16          type_uint16   { get; set; }
    public int32           type_int32    { get; set; }
    public uint32          type_uint32   { get; set; }
    public int64           type_int64    { get; set; }
    public uint64          type_uint64   { get; set; }
    public bool            type_bool     { get; set; }
    public Yaml.SubExample type_object   { get; set; }
    public Yaml.NODE_TYPE  type_enum     { get; set; }

    /**
     *
     */
    protected override void yaml_init ()
    {
        // base.yaml_init ();
        Dbg.msg ("Yaml.Object %s (%s) instantiated".printf (this.myname, this.type_from_self ()), Log.LINE, Log.FILE);
    }

}
