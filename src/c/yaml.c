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

#include <stdio.h>
#include <yaml.h>

/* return a new string with every instance of ch replaced by repl */
char *replace_char(const char *s, char ch, const char *repl) {
    int count = 0;
    const char *t;
    for(t=s; *t; t++)count += (*t == ch);
    size_t rlen = strlen(repl);
    char *res = malloc(strlen(s) + (rlen-1)*count + 1);
    char *ptr = res;
    for(t=s; *t; t++) {
        if(*t == ch) {
            memcpy(ptr, repl, rlen);
            ptr += rlen;
        } else {
            *ptr++ = *t;
        }
    }
    *ptr = 0;
    return res;
}

char *escape_string(const char *s) {
    char *t;
    t = replace_char(s, '\"', "\\\"");
    t = replace_char(t, '\n', "\\n");
    return t;
}

void yaml_parse_file(const char *srcPath, const char *destPath)
{
    FILE *rh = fopen(srcPath, "r");
    FILE *wh = fopen(destPath, "w");
    yaml_parser_t parser;
    yaml_token_t  token;

    if(!yaml_parser_initialize(&parser))
        fputs("Failed to initialize parser!\n", stderr);
    if(rh == NULL || wh == NULL)
        fputs("Failed to open file!\n", stderr);

    yaml_parser_set_input_file(&parser, rh);
    int stop = 0;
    do {
        yaml_parser_scan(&parser, &token);
        long int line = parser.mark.line + 1; 
        switch(token.type)
        {
            case YAML_SCALAR_TOKEN            :
                fprintf(wh, "%lu, %d, %d, \"%s\"\n", line, token.type, token.data.scalar.style, escape_string((char *)token.data.scalar.value));
                break;

            case YAML_ALIAS_TOKEN             :
                fprintf(wh, "%lu, %d, \"%s\"\n", line, token.type, token.data.alias.value);
                break;

            case YAML_ANCHOR_TOKEN            :
                fprintf(wh, "%lu, %d, \"%s\"\n", line, token.type, token.data.anchor.value);
                break;

            case YAML_DOCUMENT_START_TOKEN    :
                fprintf(wh, "%lu, %d, %d\n", line, token.type, parser.encoding);
                break;

            case YAML_TAG_TOKEN               :
                fprintf(wh, "%lu, %d, \"%s\", \"%s\"\n", line, token.type, token.data.tag.handle, token.data.tag.suffix);
                break;

            case YAML_VERSION_DIRECTIVE_TOKEN :
                fprintf(wh, "%lu, %d, %d, %d\n", line, token.type, token.data.version_directive.major, token.data.version_directive.minor);
                break;

            case YAML_NO_TOKEN                :
                fprintf(wh, "%lu, %d, \"%s\"\n", line, token.type, escape_string((char *)parser.problem));
                stop = 1;
                break;
            
            /* Others */
            default:
                fprintf(wh, "%lu, %d\n", line, token.type);
        }
        if(token.type != YAML_STREAM_END_TOKEN)
            yaml_token_delete(&token);
        if (stop == 1) break;

    }
    while(token.type != YAML_STREAM_END_TOKEN);

    yaml_token_delete(&token);
    yaml_parser_delete(&parser);
    fclose(rh);
    fclose(wh);
}

