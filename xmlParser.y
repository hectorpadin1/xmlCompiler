%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int lineas = 2;

int yylex(void);
void yyerror (char const *);
char * getEndTag(char * openTag);
int compareTags(char* openTag, char* closeTag);
void exitOk();
void xmlExit(char * string, int code);

%}

%define parse.error verbose

%union{
	char* string;
}


%token <string> TOPEN
%token <string> TCLOSE
%token <string> TCOMMENT
%token <string> TVERSION
%token <string> TFAIL
%token <string> TDATA

%start S

%%

S  
	: TVERSION outside root {exitOk();}
	| TVERSION outside root outside {exitOk();}
	| TVERSION root outside {exitOk();}
	| TVERSION root {exitOk();}
	| outside root outside {
		char string[100];
		sprintf(string, "Sintaxis XML incorrecta. Error cerca de la línea %d.\nCabecera no encontrada.\n", lineas);
		xmlExit(string, 2);
	}
	| root outside {
		char string[100];
		sprintf(string, "Sintaxis XML incorrecta. Error cerca de la línea %d.\nCabecera no encontrada.\n", lineas);
		xmlExit(string, 2);
	}
	| outside root {
		char string[100];
		sprintf(string, "Sintaxis XML incorrecta. Error cerca de la línea %d.\nCabecera no encontrada.\n", lineas);
		xmlExit(string, 2);
	}
	;

outside
	: TCOMMENT {lineas++;}
	| TCOMMENT outside {lineas++;}
	| err {lineas++;}
	;

err : TDATA {
		lineas++;
		char string[100];
		sprintf(string, "Sintaxis XML incorrecta. Error cerca de la línea %d.\nSentencia no reconocida: '%s'.\n", lineas, $1);
		xmlExit(string, 2);
	}
	;

root 
	: TOPEN lista_lineas TCLOSE {
		lineas+=2;
		char * tmp1 = strdup($1);
		char * tmp2 = strdup($3);
		if (compareTags(tmp1, tmp2)) {
			char string[100];
			sprintf(string, "Error cerca de la línea %d.\nEncontrado: '%s' y se esperaba '%s'.\n", lineas, tmp2, (char *)getEndTag(tmp1));
			xmlExit(string, 2);
		}
	}
	| TOPEN TCLOSE {
		lineas++;
		char * tmp1 = strdup($1);
		char * tmp2 = strdup($2);
		if (compareTags(tmp1, tmp2)) {
			char string[100];
			sprintf(string, "Error cerca de la línea %d.\nEncontrado: '%s' y se esperaba '%s'.\n", lineas, tmp2, (char *)getEndTag(tmp1));
			xmlExit(string, 2);
		}
	}
	| TOPEN TCLOSE TOPEN {
		lineas+=2;
		char string[100];
		sprintf(string, "Error cerca de la línea %d.\nNo existe el tag raíz.\n",  lineas);
		xmlExit(string, 2);
	}
	| TOPEN lista_lineas TCLOSE TOPEN {
		lineas+=3;
		char string[100];
		sprintf(string, "Error cerca de la línea %d.\nNo existe el tag raíz.\n",  lineas);
		xmlExit(string, 2);
	}
	;

lista_lineas
	: linea
	| linea lista_lineas
	| TOPEN lista_lineas TCLOSE {
		lineas+=2;
		char * tmp1 = strdup($1);
		char * tmp2 = strdup($3);
		if (compareTags(tmp1, tmp2)) {
			char string[100];
			sprintf(string, "Error cerca de la línea %d.\nEncontrado: '%s' y se esperaba '%s'.\n", lineas, tmp2, (char *)getEndTag(tmp1));
			xmlExit(string, 2);
		}
	}
	| TOPEN lista_lineas TCLOSE lista_lineas {
		lineas+=2;
		char * tmp1 = strdup($1);
		char * tmp2 = strdup($3);
		if (compareTags(tmp1, tmp2)) {
			char string[100];
			sprintf(string, "Error cerca de la línea %d.\nEncontrado: '%s' y se esperaba '%s'.\n", lineas, tmp2, (char *)getEndTag(tmp1));
			xmlExit(string, 2);
		}
	}
	;

linea
	: TOPEN TCLOSE {lineas++;}
	| TCOMMENT {lineas++;}
	| TDATA {lineas++;}
	;


%%

int main(int argc, char *argv[]) {
	extern FILE *yyin;

	switch (argc) {
		case 1:	yyin=stdin;
			yyparse();
			break;
		case 2: yyin = fopen(argv[1], "r");
			if (yyin == NULL) {
				printf("ERROR: No se ha podido abrir el fichero.\n");
			}
			else {
				yyparse();
				fclose(yyin);
			}
			break;
		default: printf("ERROR: Demasiados argumentos.\nSintaxis: %s [fichero_entrada]\n\n", argv[0]);
	}
	
	return 0;
}

void yyerror (char const *message) { fprintf(stderr, "%s near line %d.\n", message, lineas);}

char * getEndTag(char * openTag) {
	int len = strlen(openTag)+1;
	char * aux = strdup(openTag);
	aux[0]='<';
	aux[1]='/';
	for (int i=2; i<len; i++)
		aux[i]=openTag[i-1];
	char* endTag = aux;
	return endTag;
}

int compareTags(char* openTag, char* closeTag) {
	if (strlen(openTag)!=(strlen(closeTag)-1))
		return 1;
	for (int i=0; closeTag[i]!='>'; i++) {
		if ((closeTag[i]!='/') && (closeTag[i]!='<')) {
			if (closeTag[i]!=openTag[i-1]) {
				return 1;
			}
		}
	}
	return 0;
}

void exitOk() {
	char string[100];
	sprintf(string, "Sintaxis XML correcta.\n");
	xmlExit(string, 0);
}

void xmlExit(char * message, int code) {
	if (code!=0)
		fprintf(stderr, "ERROR: %sprogram return with exit status %d.\n", message, code);
	else 
		fprintf(stdout, "%sprogram return with exit status %d.\n", message, code);
	exit(code);
	return;
}
