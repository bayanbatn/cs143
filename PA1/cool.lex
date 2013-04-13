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

    switch(yy_lexical_state) {
    case YYINITIAL:
	/* nothing special to do in the initial state */
	break;
	/* If necessary, add code for other states here, e.g:
	   case COMMENT:
	   ...
	   break;
	*/
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer
%cup

%{
//State declarations
%}
%state STRING_STATE, LINE_COMMENT, BLOCK_COMMENT

%%

<YYINITIAL>"(?i:class\\s)"      
{
     return new Symbol(TokenConstants.CLASS);
}

<YYINITIAL>"(?i:else\\s)"      
{
     return new Symbol(TokenConstants.ELSE);
}

<YYINITIAL>"(?i:fi\\s)"      
{
     return new Symbol(TokenConstants.FI);
}

<YYINITIAL>"(?i:if\\s)"      
{
     return new Symbol(TokenConstants.IF);
}

<YYINITIAL>"(?i:in\\s)"      
{
     return new Symbol(TokenConstants.IN);
}

<YYINITIAL>"(?i:inherits\\s)"      
{
     return new Symbol(TokenConstants.INHERITS);
}

<YYINITIAL>"(?i:let\\s)"      
{
     return new Symbol(TokenConstants.LET);
}

<YYINITIAL>"(?i:loop\\s)"      
{
     return new Symbol(TokenConstants.LOOP);
}

<YYINITIAL>"(?i:pool\\s)"      
{
     return new Symbol(TokenConstants.POOL);
}

<YYINITIAL>"(?i:then\\s)"      
{
     return new Symbol(TokenConstants.THEN);
}

<YYINITIAL>"(?i:while\\s)"      
{
     return new Symbol(TokenConstants.WHILE);
}

<YYINITIAL>"\<\-"  
{
     //TODO: verify this is correct
     return new Symbol(TokenConstants.ASSIGN);
}

<YYINITIAL>"(?i:case\\s)"      
{
     return new Symbol(TokenConstants.CASE);
}

<YYINITIAL>"(?i:esac\\s)"      
{
     return new Symbol(TokenConstants.ESAC);
}

<YYINITIAL>"(?i:of\\s)"      
{
     return new Symbol(TokenConstants.OF);
}

<YYINITIAL>"(?i:new\\s)"      
{
     return new Symbol(TokenConstants.NEW);
}

<YYINITIAL>"t(?i:rue)"      
{
     return new Symbol(TokenConstants.BOOL_CONST, java.lang.Boolean.TRUE);
}

<YYINITIAL>"f(?i:alse)"      
{
     return new Symbol(TokenConstants.BOOL_CONST, java.lang.Boolean.FALSE);
}

<YYINITIAL>"(?i:le)"      
{
    /**
     * Operators and special characters
     */
     return new Symbol(TokenConstants.LE);
}

<YYINITIAL>"(?i:not)" 
{
     return new Symbol(TokenConstants.NOT);
}

<YYINITIAL>"(?i:isvoid)"     
{
     return new Symbol(TokenConstants.ISVOID);
}

<YYINITIAL>"\+"      
{
     return new Symbol(TokenConstants.PLUS);
}

<YYINITIAL>"\/"      
{
     return new Symbol(TokenConstants.DIV);
}


<YYINITIAL>"\-"      
{
     return new Symbol(TokenConstants.MINUS);
}

<YYINITIAL>"\*"      
{
     return new Symbol(TokenConstants.MULT);
}

<YYINITIAL>"\="      
{
     return new Symbol(TokenConstants.EQ);
}

<YYINITIAL>"\<"      
{
     return new Symbol(TokenConstants.LT);
}

<YYINITIAL>"\."      
{
     return new Symbol(TokenConstants.DOT);
}

<YYINITIAL>"\~"      
{
     return new Symbol(TokenConstants.NEG);
}

<YYINITIAL>"\,"      
{
     return new Symbol(TokenConstants.COMMA);
}

<YYINITIAL>"\;"      
{
     return new Symbol(TokenConstants.SEMI);
}

<YYINITIAL>"\:"      
{
     return new Symbol(TokenConstants.COLON);
}

<YYINITIAL>"=>"			
{ /* Sample lexical rule for "=>" arrow.
     Further lexical rules should be defined
     here, after the last %% separator */
     return new Symbol(TokenConstants.DARROW); 
}

<YYINITIAL>"\("      
{
     return new Symbol(TokenConstants.LPAREN);
}

<YYINITIAL>"\)"      
{
     return new Symbol(TokenConstants.RPAREN);
}

<YYINITIAL>"\@"      
{
     return new Symbol(TokenConstants.AT);
}

<YYINITIAL>"\{"      
{
     return new Symbol(TokenConstants.LBRACE);
}

<YYINITIAL>"\}"      
{
     return new Symbol(TokenConstants.RBRACE);
}

<YYINITIAL>"[\\d]+"
{
     return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addString(yytext()));
}

<YYINITIAL>"\""
{
     // Begin String
     /* Handling string */
     yybegin(STRING_STATE);
     return next_token();
}

<STRING_STATE>"[\\w]*"
{
    //create string, add to table, make sure formatting is good, escaped chars, etc TODO
    return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(yytext()));
}

<STRING_STATE>"\"" 
{
    // End String
    yybegin(YYINITIAL);
    return next_token(); //TODO remove and see what happens
}

<YYINITIAL>"[a-z][\\w]*"
{
    // Handle ObjectID
    return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext()));
}

<YYINITIAL>"[A-Z][\\w]*"
{
    // Handle TypeID
    return new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext()));
}

.                               { /* This rule should be the very last
                                     in your lexical specification and
                                     will match match everything not
                                     matched by other lexical rules. */
                                  System.err.println("LEXER BUG - UNMATCHED: " + yytext()); }
