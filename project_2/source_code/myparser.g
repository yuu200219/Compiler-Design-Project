grammar myparser;

options {
   language = Java;
}

@header {
    // import packages here.
}

@members {
    boolean TRACEON = true;
}

include: (INCLUDE LIBRARY)* program
        {if (TRACEON) System.out.println("INCLUDE LIBRARY");}
        ;
program: VOID MAIN '(' ')' '{' declarations statements '}'
        {if (TRACEON) System.out.println("VOID MAIN () {declarations statements}");}
        ;
//(INCLUDE LIBRARY)*
declarations:type Identifier ( '=' signExpr | )';' declarations
             { if (TRACEON) System.out.println("declarations: type Identifier : declarations"); }
           | { if (TRACEON) System.out.println("declarations: ");} ;

           
type:
        INT { if (TRACEON) System.out.println("type: INT"); }
        | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); }
        | DOUBLE {if (TRACEON) System.out.println("type: DOUBLE"); }
        | CHAR  {if (TRACEON) System.out.println("type: CHAR"); }
        | UNSIGNED {if (TRACEON) System.out.println("type: UNSIGNED"); }
        ;

statements:statement statements {if (TRACEON) System.out.println("statements: statement statements");}
        | {if (TRACEON) System.out.println("statements: ");} ;

arith_expression: 
        multExpr
        ( '+' multExpr {if (TRACEON) System.out.println("arith_expression: multExpr ('+' multExpr)*;");} 
	| '-' multExpr {if (TRACEON) System.out.println("arith_expression: multExpr ('-' multExpr)*;");}
	)*
        ;

multExpr:
        signExpr
        (( '*' signExpr
        | '/' signExpr
        | '%' signExpr
        )*)
        ;

signExpr:
        primaryExpr
        | '-' primaryExpr
	;

assignment_operator
	: '=' {if (TRACEON) System.out.println("assignment_operator: '='");}
	| '*=' {if (TRACEON) System.out.println("assignment_operator: '*='");}
	| '/=' {if (TRACEON) System.out.println("assignment_operator: '/='");}
	| '%=' {if (TRACEON) System.out.println("assignment_operator: 'percent'");}
	| '+=' {if (TRACEON) System.out.println("assignment_operator: '+='");}
	| '-=' {if (TRACEON) System.out.println("assignment_operator: '-='");}
	| '<<=' {if (TRACEON) System.out.println("assignment_operator: '<<='");}
	| '>>=' {if (TRACEON) System.out.println("assignment_operator: '>>='");}
	| '&=' {if (TRACEON) System.out.println("assignment_operator: '&='");}
	| '^=' {if (TRACEON) System.out.println("assignment_operator: '^='");}
	| '|=' {if (TRACEON) System.out.println("assignment_operator: '|='");}
	;

rational_operator
        : '<' {if (TRACEON) System.out.println("rational_operator: '<'");}
        | '>' {if (TRACEON) System.out.println("rational_operator: '>'");}
        | '<=' {if (TRACEON) System.out.println("rational_operator: '<='");}
        | '>=' {if (TRACEON) System.out.println("rational_operator: '>='");}
        | '==' {if (TRACEON) System.out.println("rational_operator: '=='");}
        ;

logical_operator
        : '&&' {if (TRACEON) System.out.println("logical_operator: &&");}
        | '||' {if (TRACEON) System.out.println("logical_operator: ||");}
        | '!' {if (TRACEON) System.out.println("logical_operator: !");}
        | '^' {if (TRACEON) System.out.println("logical_operator: ^");}
        | '&' {if (TRACEON) System.out.println("logical_operator: &");}
        | '|' {if (TRACEON) System.out.println("logical_operator: |");}
        ;

postfixExpr:
        '.' Identifier {if (TRACEON) System.out.println("postfixExpr: '.' Identifier");}
        |   '->' Identifier {if (TRACEON) System.out.println("postfixExpr: '->' Identifier");}
        |   '++' {if (TRACEON) System.out.println("postfixExpr: '++' Identifier");}
        |   '--' {if (TRACEON) System.out.println("postfixExpr: '--' Identifier");}
	;	  

primaryExpr: 
        Integer_constant {if (TRACEON) System.out.println("primaryExpr: Integer_constant");}
        | Floating_point_constant {if (TRACEON) System.out.println("primaryExpr: Floating_point_constant");}
        | Identifier {if (TRACEON) System.out.println("primaryExpr: Identifier");}
	| '(' arith_expression ')' {if (TRACEON) System.out.println("primaryExpr: arith_expression");}
        ;

statement:
        Identifier ((assignment_operator arith_expression) | postfixExpr) ';' {if (TRACEON) System.out.println("statement: Identifier");}
        | if_else_statements {if (TRACEON) System.out.println("statement: if_statement");}
        | for_loop_statements {if (TRACEON) System.out.println("statement: for_loop_statements");}
        | while_loop_statements {if (TRACEON) System.out.println("statement: while_loop_statements");}
        | print_statement ';' {if (TRACEON) System.out.println("statement: print_statement");}
        ;

if_else_statements:
        IF '(' arith_expression ((rational_operator | logical_operator) primaryExpr | )')' 
        statement_t
        (ELSE statement_t)?
        ;

for_loop_statements: 
        FOR '('((declarations | statement) | ';')
        (primaryExpr (rational_operator | logical_operator) primaryExpr)?';' 
        Identifier (postfixExpr | assignment_operator primaryExpr) ')'
        statement_t
        ;

while_loop_statements:
        WHILE '('
        arith_expression ((rational_operator | logical_operator) primaryExpr | )
        ')'
        statement_t
        ;

statement_t: 
        statement {if (TRACEON) System.out.println("statement_t: statement");}
        | '{' statements '}' {if (TRACEON) System.out.println("statement_t: {statements}");}
        ;

print_statement:
        PRINTF '(' LITERAL  (',' primaryExpr)*')'
        {if (TRACEON) System.out.println("print_statement: PRINTF '(' LITERAL  (',' primaryExpr)*')'");}
        ;

// format_string: 
//         LITERAL {if (TRACEON) System.out.println("format_string: LITERAL");}
//         ;
// | (format_specifier)* {if (TRACEON) System.out.println("format_string: format_specifier");}
// format_specifier:
//         '%' (((flag)? (width)? (precision)? (length)? conversion_specifier) | '%')
//         {if (TRACEON) System.out.println("format_specifier");}
//         ;

// flag: 
//         '-' {if (TRACEON) System.out.println("flag: '-'");}
//         | '+' {if (TRACEON) System.out.println("flag: '+'");}
//         ;

// width: 
//         Integer_constant
//         {if (TRACEON) System.out.println("width: Integer_constant");}
//         ;
        
// precision: 
//         '.' Integer_constant
//         {if (TRACEON) System.out.println("precision: '.'");}
//         ;

// length: 
//         'l' {if (TRACEON) System.out.println("length: 'l'");}
//         | 'll' {if (TRACEON) System.out.println("length: 'll'");}
//         ;

// conversion_specifier: 
//         'd' {if (TRACEON) System.out.println("conversion_specifier: 'd'");}
//         | 'i' {if (TRACEON) System.out.println("conversion_specifier: 'i'");}
//         | 'e' {if (TRACEON) System.out.println("conversion_specifier: 'e'");}
//         | 'E' {if (TRACEON) System.out.println("conversion_specifier: 'E'");}
//         | 'o' {if (TRACEON) System.out.println("conversion_specifier: 'o'");}
//         | 'u' {if (TRACEON) System.out.println("conversion_specifier: 'u'");}
//         | 'x' {if (TRACEON) System.out.println("conversion_specifier: 'x'");}
//         | 'X' {if (TRACEON) System.out.println("conversion_specifier: 'X'");}
//         | 'c' {if (TRACEON) System.out.println("conversion_specifier: 'c'");}
//         | 'p' {if (TRACEON) System.out.println("conversion_specifier: 'p'");}
//         | 's' {if (TRACEON) System.out.println("conversion_specifier: 's'");}
//         ;       
 

/* description of the tokens */
//keywords
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
// data type
FLOAT:'float';
INT:'int';
DOUBLE:'double';
CHAR: 'char';
UNSIGNED: 'unsigned';
VOID: 'void';

// function
MAIN: 'main';
PRINTF: 'printf';



IF: 'if';
ELSE: 'else';
WHILE: 'while';
FOR: 'for';



Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

BRACE_L : '{';
BRACE_R : '}';
BRACKET_L : '(';
BRACKET_R : ')';
SQUARE_BRACKET_L : '[';
SQUARE_BRACKET_R : ']';
SEMICOLON : ';';
PERIOD : '.';
COMMA : ',';
HASH : '#';

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
COMMENT_1:'/*' .* '*/' {$channel=HIDDEN;};
COMMENT_2:'//' .* '\n' {$channel=HIDDEN;};
LITERAL :  '"' (options{greedy=false;}: .)* '"';
LIBRARY : '<'Identifier'.h>';
INCLUDE : '#include';