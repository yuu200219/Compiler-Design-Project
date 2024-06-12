lexer grammar mylexer;

options {
  language = Java;
}

/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
//
RETURN : 'return';
BREAK : 'break';
CASE : 'case';
CONTINUE : 'continue';
DEFAULT : 'default';
ENUM : 'enum';
EXTERN : 'extern';
GOTO : 'goto';
STRUCT : 'struct';
SWITCH : 'switch';
TYPEDEF : 'typedef';
UNION : 'union';
STATIC : 'static';
VOLATILE : 'volatile';


//data type
INT_TYPE  : 'int';
CHAR_TYPE : 'char';
FLOAT_TYPE: 'float';
DOUBLE_TYPE: 'double';
AUTO_TYPE : 'auto';
VOID_TYPE : 'void';
CONST_TYPE : 'const';
SIGNED_TYPE : 'signed';
UNSIGNED_TYPE : 'unsigned';


/* control structure */
IF : 'if';
ELSE : 'else';
LOOP : 'for';
WHILE : 'while';
DO : 'do';


/*----------------------*/
/*  Compound Operators  */
/*----------------------*/

EQ_OP : '==';
LE_OP : '<=';
GE_OP : '>=';
NE_OP : '!=';
PP_OP : '++';
MM_OP : '--';

RSHIFT_OP : '<<';
LSHIFT_OP : '>>';

EQUAL_OP : '=';
PLUS_OP : '+';
MIN_OP : '-';
MUL_OP : '*';
DIV_OP : '/';
MOD_OP : '%';

BIT_AND_OP : '&';
BIT_OR_OP : '|';
BIT_XOR_OP : '^';
BIT_COMP_OP : '~';

LOGIC_AND_OP : '&&';
LOGIC_OR_OP : '||';
NOT_OP : '!';

// identifier

DEC_NUM : ('0' | ('1'..'9')(DIGIT)*);

ID : (LETTER)(LETTER | DIGIT)*;
fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3;
fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2: '.'(DIGIT)+;
fragment FLOAT_NUM3: (DIGIT)+;
 

/* Comments */
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/';

// Special characters
LITERAL : '"' (options{greedy=false;}: .)* '"';
LIBRARY : '<' (options{greedy=false;}: .)* '>';
BRACE_L : '{';
BRACE_R : '}';
BRACKET_L : '(';
BRACKET_R : ')';
SQUARE_BRACKET_L : '[';
SQUARE_BRACKET_R : ']';


NEW_LINE: '\n';

SEMICOLON : ';';
SINGLE_QUATATION : '\'';
PERIOD : '.';
COMMA : ',';
HASH : '#';
INCLUDE : '#include';




WS  : (' '|'\r'|'\t')+
    ;
