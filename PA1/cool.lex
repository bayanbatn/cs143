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

    // empty for now
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
        /* nothing to do here, as EOF is handled inside the rules section */
        break;
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
}

<STRING_STATE>([^\n\"\\]*|(\\(.|\n)))*[\"\n<<EOF>>]
{
    /* Handling string match */
    // Whatever happens, we are done parsing the string here
    yybegin(YYINITIAL);

    // read in the regex match
    String token = yytext();
    StringBuilder sb = new StringBuilder(token.length());

    if (token.charAt(token.length()-1) == '\n'){
        // if string terminates in a new line 
        curr_lineno += 1;
        return new Symbol(TokenConstants.ERROR, "Unterminated string constant");
    } else if (token.charAt(token.length()-1) != '"'){ 
        // if string doens't terminate on " or newline, then EOF reached
        return new Symbol(TokenConstants.ERROR, "EOF in string constant");
    }

    /* State of parsing */
    boolean escaped = false;
    boolean invalidChar = false;

    for (int i = 0; i < token.length()-1; i++){

        char ch = token.charAt(i);
        switch(ch){
            case '\\': if (escaped){
                          sb.append(ch);
                          escaped = false;
                      } else
                          escaped = true;
                      break;
            /* Handle escaped characters */
            case 'b': if (escaped){
                          sb.append('\b');
                          escaped = false;
                      } else
                          sb.append(ch);
                      break;
            case 't': if (escaped){
                          sb.append('\t');
                          escaped = false;
                      } else
                          sb.append(ch);
                      break;
            case 'f': if (escaped){
                          sb.append('\f');
                          escaped = false;
                      } else
                          sb.append(ch);
                      break;
            case 'n': if (escaped){
                          sb.append('\n');
                          escaped = false;
                      } else
                          sb.append(ch);
                      break;
            /* Handle invalid characters */
            case '\0': invalidChar = true; 
                       escaped = false;
                       break;
            case '\n': if (escaped){
                           sb.append('\n');
                           escaped = false;
                           curr_lineno += 1;
                       }
                       break;
            default:   sb.append(ch);
                       escaped = false;
                       break;
        }
    }

    // invalid character (null) is detected
    if (invalidChar)
        return new Symbol(TokenConstants.ERROR, "String contains null character.");

    // string is too long
    if (sb.length() >= MAX_STR_CONST)
        return new Symbol(TokenConstants.ERROR, "String constant too long");

    return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(sb.toString()));
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
