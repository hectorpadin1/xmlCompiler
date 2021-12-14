%{

#include <stdlib.h>
#include "xmlParser.tab.h"

char * trim(char * buff);
char * getTag(char * buff);

%}


nl              (\r\n|\r|\n)
ws              [ \t\r\n]+
open            "<"
close           ">"
namestartmin    [a-záéíóú\200-\377_]
namecharmin     [a-záéíóú\200-\377_0-9]
namestartmay    [A-ZÁÉÍÓÚ\200-\377_]
namecharmay     [A-ZÁÉÍÓÚ\200-\377_0-9]
digit           [0-9]+(\.[0-9]+)?
name            ({namestartmin}{namecharmin}*)|({namestartmay}{namecharmay}*)
xmlversion      "<?xml"{ws}?"version=\""{digit}"\""{ws}"encoding=\"".+?"\"?>"
data            {ws}?({namecharmin}|{namecharmay}|[-\/\!\?¿¡\(\)''@#\"\$\%\*\-\.,:€=])+{ws}?
comment         "<!--"{data}+"-->"

%%

{ws}                                        {}
{comment}                                   {/*printf("co %s\n", yytext);*/ yylval.string=trim(strdup(yytext)); return TCOMMENT;}
{xmlversion}                                {/*printf("x %s\n", yytext);*/ yylval.string=trim(strdup(yytext)); return TVERSION;}
{open}{ws}?{name}{ws}?{close}({data}+)?     {/*printf("o %s\n", yytext);*/ yylval.string=getTag(trim(strdup(yytext))); return TOPEN;}
{open}"/"{name}{ws}?{close}                 {/*printf("c %s\n", yytext);*/ yylval.string=trim(strdup(yytext)); return TCLOSE;}
{data}+                                     {/*printf("d %s\n", yytext);*/ yylval.string=trim(strdup(yytext)); return TDATA;}
[^<>]+                                      {/*printf("f %s\n", yytext);*/ yylval.string=trim(strdup(yytext)); return TFAIL;}

%%

char * trim(char * buff) {
    int x = 0;
    while(1) {
        if((*buff == ' ') || (*buff == '\t') || (*buff == '\r') || (*buff == '\n')) { 
                x++;
                ++buff;
        } else
            break;
    }
    int y = strlen(buff)-1;
    while(1) {
        if(buff[y] == ' ' || (buff[y] == '\t') || (buff[y] == '\r') || (buff[y] == '\n')) { 
                y--;
        } else
            break;
    }
    y = strlen(buff)-y;
    buff[strlen(buff)-y+1]='\0';
    return buff;
}

char * getTag(char * buff) {
    char * out = strdup(buff);
    int x = 0;
    for (int i=0; i<strlen(out); i++) {
        if (x)
            out[i] = '\0';
        if (out[i]=='>')
            x = 1;
    }
    return out;
}