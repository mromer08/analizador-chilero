package gt.edu.usac.compiler;

import java_cup.runtime.Symbol;

%%

%{
    /**
	 * Variable para lograr que los comentarios estén equilibrados
	 */
    private int comment_lvl = 0;
    /**
	 * Variable para controlar el caracter null dentro de un string
	 */
    private boolean null_in_string = false;
    /**
	 * Método para comprobar la longitud de la cadena encontrada hasta el momento.
     * @return true si se pasó de la cantidad máxima, de lo contrario false.
	 */
    private boolean is_max_str(){
         return string_buf.length()>= MAX_STR_CONST;
    }
    /**
	 * Método para retornar un Symbol ERROR cuando un string es demasiado largo
     * @return Symbol del tipo ERROR
	 */
    private Symbol max_str_error(){
        yybegin(YYINITIAL);
        return new Symbol(TokenConstants.ERROR, "String constant too long");
    }
    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
%}

%init{

%init}

%eofval{


    switch(zzLexicalState) {
        case YYINITIAL:
        /* nada */
        break;
        case STRING:
            yybegin(YYINITIAL);
		    return new Symbol(TokenConstants.ERROR,"EOF in string constant");
        case MULTILINE_COMMENT:
            yybegin(YYINITIAL);
            return new Symbol(TokenConstants.ERROR, "EOF in comment");
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer
%cup

LineTerminator = \r|\n|\r\n
WhiteSpace = [ \t\f]
Letter = [a-zA-Z_]
Digit = [0-9]
InputCharacter = [^\r\n]

/* comments */
EndOfLineComment = "--" {InputCharacter}* {LineTerminator}?

%state STRING, MULTILINE_COMMENT

%%


/* keywords */

<YYINITIAL> ([cC][lL][aA][sS][sS])|([cC][lL][aA][sS][eE])                                   { return new Symbol(TokenConstants.CLASS); }
<YYINITIAL> ([eE][lL][sS][eE])|([dD][eE][lL][oO][cC][oO][nN][tT][rR][aA][rR][iI][oO])       { return new Symbol(TokenConstants.ELSE); }
<YYINITIAL> [f][aA][lL][sS]([eE]|[oO])                                                      { return new Symbol(TokenConstants.BOOL_CONST,false); }
<YYINITIAL> ([fF][iI])|([iI][sS])                                                           { return new Symbol(TokenConstants.FI); }
<YYINITIAL> ([iI][fF])|([sS][iI])                                                           { return new Symbol(TokenConstants.IF); }
<YYINITIAL> ([iI]|[eE])[nN]                                                                 { return new Symbol(TokenConstants.IN); }
<YYINITIAL> ([iI][nN][hH][eE][rR][iI][tT][sS])|([hH][eE][rR][eE][dD][aA])                   { return new Symbol(TokenConstants.INHERITS); }
<YYINITIAL> ([iI][sS][vV][oO][iI][dD])|([eE][sS][vV][aA][cC][iI][oO])                       { return new Symbol(TokenConstants.ISVOID); }
<YYINITIAL> ([lL][eE][tT])|([lL][aA][vV][aA][rR])                                           { return new Symbol(TokenConstants.LET); }
<YYINITIAL> ([lL][oO][oO][pP])|([cC][iI][cC][lL][oO])                                       { return new Symbol(TokenConstants.LOOP); }
<YYINITIAL> ([pP][oO][oO][lL])|([oO][lL][cC][iI][cC])                                       { return new Symbol(TokenConstants.POOL); }
<YYINITIAL> ([tT][hH][eE][nN])|([eE][nN][tT][oO][nN][cC][eE][sS])                           { return new Symbol(TokenConstants.THEN); }
<YYINITIAL> ([wW][hH][iI][lL][eE])|([mM][iI][eE][nN][tT][rR][aA][sS])                       { return new Symbol(TokenConstants.WHILE); }
<YYINITIAL> ([cC][aA][sS][eE])|([eE][nN][cC][aA][sS][oO])                                   { return new Symbol(TokenConstants.CASE); }
<YYINITIAL> ([eE][sS][aA][cC])|([oO][sS][aA][cC][nN][eE])                                   { return new Symbol(TokenConstants.ESAC); }
<YYINITIAL> ([nN][eE][wW])|([nN][uU][eE][vV][oO])                                           { return new Symbol(TokenConstants.NEW); }
<YYINITIAL> ([oO][fF])|([dD][eE])                                                           { return new Symbol(TokenConstants.OF); }
<YYINITIAL> ([nN][oO][tT])|([nN][eE][lL])                                                   { return new Symbol(TokenConstants.NOT); }
<YYINITIAL> ([t][rR][uU][eE])|([v][eE][rR][dD][aA][dD][eE][rR][oO])                         { return new Symbol(TokenConstants.BOOL_CONST,true); }

<YYINITIAL> {
    {LineTerminator}                 {curr_lineno++;}
    
    /* whitespace */
    {WhiteSpace}                    {/* ignorar */}

    /*comments*/
    {EndOfLineComment}               {curr_lineno++;}
    "*)"                             { return new Symbol(TokenConstants.ERROR, "Unmatched *)"); }
    "(*"                             {comment_lvl++; yybegin(MULTILINE_COMMENT);}

    /* identificadores */
    [a-z]({Letter}|{Digit})*        { return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext())); }
    [A-Z]({Letter}|{Digit})*        { return new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext())); }

    /* literales */
    \"                              { string_buf.setLength(0); yybegin(STRING); }
    {Digit}+                        { return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addString(yytext())); }
    
    /* operadores */
    /* operador de asignacion*/
    "<-"                            { return new Symbol(TokenConstants.ASSIGN); }
    
    /*Simbolo flecha*/
    "=>"                            { return new Symbol(TokenConstants.DARROW); }

    /* operadores aritmeticos */
    "~"                             { return new Symbol(TokenConstants.NEG); }
    "+"                             { return new Symbol(TokenConstants.PLUS); }
    "-"                             { return new Symbol(TokenConstants.MINUS); }
    "*"                             { return new Symbol(TokenConstants.MULT); }
    "/"                             { return new Symbol(TokenConstants.DIV); }

    /* operadores logicos */
    "<="                            { return new Symbol(TokenConstants.LE); }
    "<"                             { return new Symbol(TokenConstants.LT); }
    "="                             { return new Symbol(TokenConstants.EQ); }

    /* simbolos */
    "("                             { return new Symbol(TokenConstants.LPAREN); }
    ")"                             { return new Symbol(TokenConstants.RPAREN); }
    "."                             { return new Symbol(TokenConstants.DOT); }
    ":"                             { return new Symbol(TokenConstants.COLON); }
    "@"                             { return new Symbol(TokenConstants.AT); }
    ","                             { return new Symbol(TokenConstants.COMMA); }
    "{"                             { return new Symbol(TokenConstants.LBRACE); }
    "}"                             { return new Symbol(TokenConstants.RBRACE); }
    ";"                             { return new Symbol(TokenConstants.SEMI); }
}

<MULTILINE_COMMENT> {
    {LineTerminator}                {curr_lineno++;}
    "(*"                            {comment_lvl++;}
    "*)"                            {comment_lvl--; if(comment_lvl == 0) yybegin(YYINITIAL);}
    .                               {/* ignorar */}
}

<STRING> {
  \"                             { yybegin(YYINITIAL);
                                    if(is_max_str())
                                        return max_str_error();
                                    if(null_in_string)
                                        return new Symbol(TokenConstants.ERROR, "String contains null character");
                                   return new Symbol(TokenConstants.STR_CONST,
                                   AbstractTable.stringtable.addString(string_buf.toString())); }
    {LineTerminator}            { curr_lineno++; yybegin(YYINITIAL); return new Symbol(TokenConstants.ERROR, "Unterminated string constant"); }
    \0                        { null_in_string = true; }
    [^\n\r\"\\]+                   { string_buf.append( yytext() ); }
    \\t                            { string_buf.append('\t'); }
    \\n                            { string_buf.append('\n'); }
    \\b                            { string_buf.append('\b'); }
    \\f                           { string_buf.append('\f'); }
    \\.                             { string_buf.append(yytext().substring(1,yytext().length())); }
    \\\n                          {curr_lineno++; string_buf.append(yytext().substring(1,yytext().length())); }
}
.                               { return new Symbol(TokenConstants.ERROR, yytext()); }
