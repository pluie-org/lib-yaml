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

using GLib;
using Gee;
using Pluie;

/**
 * Yaml Event class
 */
public class Pluie.Yaml.Event
{
    /**
     * event type
     */
    public Yaml.EVT  evtype  { get; internal set; default = 0; }
    /**
     * indicates the current line number
     */
    public int line          { get; internal set; default = 0; }
    /**
     * indicates the current event style
     */
    public int? style        { get; internal set; default = null; }
    /**
     * event data
     */
    public Gee.HashMap<string, string>? data  { get; internal set; default = null; }

    /**
     * construct a Event
     * @param path the path to load
     */
    public Event (Yaml.EVT evtype, int line=0, int? style=null, Gee.HashMap<string, string>? data=null)
    {
        this.evtype = evtype;
        this.line   = line;
        this.style  = style;
        this.data   = data;
    }
}
