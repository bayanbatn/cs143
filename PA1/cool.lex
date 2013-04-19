/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    // Comment depth
    int comment_depth = 0;

    // String validity state
    boolean invalidString = false;

    // Buffer for string const
    StringBuilder sb;

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

    // Must define next_token() function, that reads from the current pointer
%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    sb = new StringBuilder(2*MAX_STR_CONST);

%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    String errorInfo = null; 

    switch(yy_lexical_state) {
    case YYINITIAL:
	/* nothing special to do in the initial state */
	break;
    case STRING_STATE:
        yybegin(YYINITIAL);
        return new Symbol(TokenConstants.ERROR, "EOF in string constant");
    case LINE_COMMENT:
    case BLOCK_COMMENT:
        yybegin(YYINITIAL);
        return new Symbol(TokenConstants.ERROR, "EOF in comment");
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer
%cup

%state STRING_STATE, LINE_COMMENT, BLOCK_COMMENT

DIGIT = [0-9]
VAR_CHAR = [0-9a-zA-Z_]
WHITESPACE = [\ \b\t\f\r\x0b]

%%

<YYINITIAL>[cC][lL][aA][sS][sS]      
{
     return new Symbol(TokenConstants.CLASS);
}

<YYINITIAL>[eE][lL][sS][eE]
{
     return new Symbol(TokenConstants.ELSE);
}

<YYINITIAL>[fF][iI]
{
     return new Symbol(TokenConstants.FI);
}

<YYINITIAL>[iI][fF]
{
     return new Symbol(TokenConstants.IF);
}

<YYINITIAL>[iI][nN]
{
     return new Symbol(TokenConstants.IN);
}

<YYINITIAL>[iI][nN][hH][eE][rR][iI][tT][sS]
{
     return new Symbol(TokenConstants.INHERITS);
}

<YYINITIAL>[lL][eE][tT]
{
     return new Symbol(TokenConstants.LET);
}

<YYINITIAL>[lL][oO][oO][pP]
{
     return new Symbol(TokenConstants.LOOP);
}

<YYINITIAL>[pP][oO][oO][lL]
{
     return new Symbol(TokenConstants.POOL);
}

<YYINITIAL>[tT][hH][eE][nN]
{
     return new Symbol(TokenConstants.THEN);
}

<YYINITIAL>[wW][hH][iI][lL][eE]
{
     return new Symbol(TokenConstants.WHILE);
}

<YYINITIAL>"<-"  
{
     return new Symbol(TokenConstants.ASSIGN);
}

<YYINITIAL>[cC][aA][sS][eE]
{
     return new Symbol(TokenConstants.CASE);
}

<YYINITIAL>[eE][sS][aA][cC]
{
     return new Symbol(TokenConstants.ESAC);
}

<YYINITIAL>[oO][fF]
{
     return new Symbol(TokenConstants.OF);
}

<YYINITIAL>[nN][eE][wW]
{
     return new Symbol(TokenConstants.NEW);
}

<YYINITIAL>t[rR][uU][eE]
{
     return new Symbol(TokenConstants.BOOL_CONST, java.lang.Boolean.TRUE);
}

<YYINITIAL>f[aA][lL][sS][eE]
{
     return new Symbol(TokenConstants.BOOL_CONST, java.lang.Boolean.FALSE);
}

<YYINITIAL>"<="
{
     return new Symbol(TokenConstants.LE);
}

<YYINITIAL>[nN][oO][tT]
{
     return new Symbol(TokenConstants.NOT);
}

<YYINITIAL>[iI][sS][vV][oO][iI][dD]
{
     return new Symbol(TokenConstants.ISVOID);
}

<YYINITIAL>"+"      
{
     return new Symbol(TokenConstants.PLUS);
}

<YYINITIAL>"/"      
{
     return new Symbol(TokenConstants.DIV);
}


<YYINITIAL>"-"      
{
     return new Symbol(TokenConstants.MINUS);
}

<YYINITIAL>"*"      
{
     return new Symbol(TokenConstants.MULT);
}

<YYINITIAL>"="      
{
     return new Symbol(TokenConstants.EQ);
}

<YYINITIAL>"<"      
{
     return new Symbol(TokenConstants.LT);
}

<YYINITIAL>"."      
{
     return new Symbol(TokenConstants.DOT);
}

<YYINITIAL>"~"      
{
     return new Symbol(TokenConstants.NEG);
}

<YYINITIAL>","      
{
     return new Symbol(TokenConstants.COMMA);
}

<YYINITIAL>";"      
{
     return new Symbol(TokenConstants.SEMI);
}

<YYINITIAL>":"      
{
     return new Symbol(TokenConstants.COLON);
}

<YYINITIAL>"=>"			
{ /* Sample lexical rule for "=>" arrow.
     Further lexical rules should be defined
     here, after the last %% separator */
     return new Symbol(TokenConstants.DARROW); 
}

<YYINITIAL>"("      
{
     return new Symbol(TokenConstants.LPAREN);
}

<YYINITIAL>")"      
{
     return new Symbol(TokenConstants.RPAREN);
}

<YYINITIAL>"@"      
{
     return new Symbol(TokenConstants.AT);
}

<YYINITIAL>"{"      
{
     return new Symbol(TokenConstants.LBRACE);
}

<YYINITIAL>"}"      
{
     return new Symbol(TokenConstants.RBRACE);
}

<YYINITIAL>{DIGIT}+
{
     return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addString(yytext()));
}

<YYINITIAL>\"
{
     // Begin String
     yybegin(STRING_STATE);
     // Refresh string builder
     sb.setLength(0); 
     invalidString = false;
}

<STRING_STATE>[^\n\"\\\0]+
{
     sb.append(yytext());
}

<STRING_STATE>(\\.)
{
     String token = yytext();
     if (token.length() != 2)
        System.err.println("Token length must be 2!");

     // Grab escaped char
     char ch = token.charAt(1);

     switch(ch){
     /* Handle escaped characters */
         case 'b': sb.append('\b');
             break;
         case 't': sb.append('\t');
             break;
         case 'f': sb.append('\f');
             break;
         case 'n': sb.append('\n');
             break;
         default:   sb.append(ch);
     }
}

<STRING_STATE>(\\\n)
{
    // Escaped new line found
    sb.append('\n');
    curr_lineno += 1;
}

<STRING_STATE>\0
{
    // Invalid character detected
    invalidString = true;
    return new Symbol(TokenConstants.ERROR, "String contains null character.");
}

<STRING_STATE>\"
{
    // Regular end to the string, 
    // barring invalid char + max length violations
    
    // Whatever happens, we are done parsing the string here
    yybegin(YYINITIAL);

    // Already returned error at the appropriate line
    if (invalidString)
        return next_token();
    // String is too long
    if (sb.length() >= MAX_STR_CONST)
        return new Symbol(TokenConstants.ERROR, "String constant too long");

    return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(sb.toString()));
}

<STRING_STATE>\n
{
    // String terminates in a new line, resulting in error
    // Whatever happens, we are done parsing the string here
    yybegin(YYINITIAL);

    curr_lineno += 1;
    return new Symbol(TokenConstants.ERROR, "Unterminated string constant");
}

<STRING_STATE>(\\<<EOF>>)
{   // handles edge case
}


<YYINITIAL>[a-z]{VAR_CHAR}*
{
    // Handle ObjectID
    return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext()));
}

<YYINITIAL>[A-Z]{VAR_CHAR}*
{
    // Handle TypeID
    return new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext()));
}

<YYINITIAL>{WHITESPACE}+
{
    // Do nothing when parsing whitespace
}

<YYINITIAL>\n
{
    curr_lineno += 1;
}

<YYINITIAL>\-\-
{
    // Begin line comment
    yybegin(LINE_COMMENT);
}

<LINE_COMMENT>.
{
    // Ignore content of comment
}

<LINE_COMMENT>\n
{
    // Handle comment: ignore everything inside comment
    yybegin(YYINITIAL);
    curr_lineno += 1;
}

<YYINITIAL>\(\*
{
    // Begin block comment
    yybegin(BLOCK_COMMENT);
    comment_depth += 1;
}

<YYINITIAL>\*\)
{
    // Throw error if see comment closure without comment beginning
    return new Symbol(TokenConstants.ERROR, "Unmatched *)");
}

<BLOCK_COMMENT>[^\)\*\n]
{ // processing uninteresting stuff
}

<BLOCK_COMMENT>\n|\n\)|\*\n
{
    // handle new line separately to update line number
    curr_lineno += 1;
}

<BLOCK_COMMENT>[^\*\n]\)|\*[^\)\n]
{ // processing uninteresting stuff
}

<BLOCK_COMMENT>"(*"
{
    comment_depth += 1;
}

<BLOCK_COMMENT>"*)"
{
    // Done with block comment
    comment_depth -= 1;
    if (comment_depth == 0)
        yybegin(YYINITIAL);
}

.                               
{ /* This rule should be the very last
     in your lexical specification and
     will match match everything not
     matched by other lexical rules. */
    System.err.println("LEXER BUG - UNMATCHED: " + yytext()); 
    return new Symbol(TokenConstants.ERROR, yytext());
}
