grammar myChecker;

@header {
    // import packages here.
    import java.util.HashMap;
}

@members {
    boolean TRACEON = false;

	public enum TypeInfo {
        Integer,
		Float,
		Double,
		Character,
		Unsigned,
		Boolean,
		Unknown,
		Identifier,
		No_Exist,
		Error
    }

    HashMap<String,TypeInfo> symtab = new HashMap<String,TypeInfo>();

	
    
    

    // attr_type:
    //    1 => integer,
    //    2 => float,
    //    -1 => do not exist,
    //    -2 => error,
       
}

program
	: (INCLUDE LIBRARY)* VOID MAIN '(' ')' '{' (content_1)* '}'
     { if (TRACEON) System.out.println("VOID MAIN () {declarations statements}"); }
	;

content_1
	: (declaration)+ statements
	;

declaration
	: type Identifier  ( '=' signExpr | ) ';'
     {
	   if (TRACEON) System.out.println("declarations: type Identifier : declarations");
	 
  	   if (symtab.containsKey($Identifier.text)) {
		   System.out.println("Error! " + 
				              $Identifier.getLine() + 
							  ": Redeclared identifier.");
	   } else {
		   /* Add ID and its attr_type into the symbol table. */
		   symtab.put($Identifier.text, $type.attr_type);	   
	   }
	 }
	;

type returns [TypeInfo attr_type]
	:INT    { if (TRACEON) System.out.println("type: INT");  $attr_type = TypeInfo.Integer; }
	| FLOAT { if (TRACEON) System.out.println("type: FLOAT");  $attr_type = TypeInfo.Float; }
	| DOUBLE { if (TRACEON) System.out.println("type: DOUBLE");  $attr_type = TypeInfo.Double; }
	| CHAR { if (TRACEON) System.out.println("type: CHAR");  $attr_type = TypeInfo.Character; }
	| UNSIGNED { if (TRACEON) System.out.println("type: UNSIGNED");  $attr_type = TypeInfo.Unsigned; }
	| BOOLEAN { if (TRACEON) System.out.println("type: BOOLEAN");  $attr_type = TypeInfo.Boolean; }
	;

statements
	:statement statements {if (TRACEON) System.out.println("statements: statement statements");}
	| {if (TRACEON) System.out.println("statements: ");} ;

/* 
--------------------
--  operation    --
--------------------
*/

assignment_operator
	: '=' {
		if (TRACEON) System.out.println("assignment_operator: '='");
	}
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
		| '!=' {if (TRACEON) System.out.println("rational_operator: '!='");}
        ;

logical_operator
        : '&&' {if (TRACEON) System.out.println("logical_operator: &&");}
        | '||' {if (TRACEON) System.out.println("logical_operator: ||");}
        | '!' {if (TRACEON) System.out.println("logical_operator: !");}
        | '^' {if (TRACEON) System.out.println("logical_operator: ^");}
        | '&' {if (TRACEON) System.out.println("logical_operator: &");}
        | '|' {if (TRACEON) System.out.println("logical_operator: |");}
        ;

/* 
--------------------
--  expression    --
--------------------
*/

arith_expression returns [TypeInfo attr_type]
	: a = multExpr { $attr_type = $a.attr_type; }
      ( '+' b = multExpr
	    { 	
			if ($a.attr_type != $b.attr_type) {
				System.out.println("Error! " + 
				                $a.start.getLine() +
						        ": Type mismatch for the operator + in an expression.");
		      $attr_type = TypeInfo.Error;
		  	}
        }
	  | '-' c = multExpr
	  	{
			if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator - in an expression.");
		      $attr_type = TypeInfo.Error;
		  	}
		}
	  )*
	;

multExpr returns [TypeInfo attr_type]
	: a = signExpr { $attr_type = $a.attr_type; }
      ( '*' signExpr
      | '/' signExpr
	  )*
	;

signExpr returns [TypeInfo attr_type]
	: primaryExpr { $attr_type = $primaryExpr.attr_type; }
	| '-' primaryExpr { $attr_type = $primaryExpr.attr_type; }
	;

postfixExpr:
        '++' {if (TRACEON) System.out.println("postfixExpr: '++' Identifier");}
        |   '--' {if (TRACEON) System.out.println("postfixExpr: '--' Identifier");}
	;

primaryExpr returns [TypeInfo attr_type] 
	: Integer_constant        { $attr_type = TypeInfo.Integer; }
	| Floating_point_constant { $attr_type = TypeInfo.Float; }
	| Identifier			  
	{ 
		if (symtab.containsKey($Identifier.text)) {
	    	$attr_type = symtab.get($Identifier.text);
	   	} else {
           	/* Add codes to report and handle this error */
			System.out.println("Error! " +
								$Identifier.getLine() + 
								": Undeclared identifier.");
	       	$attr_type = TypeInfo.Error;
	   }
	}
	| '(' arith_expression ')' { $attr_type = $arith_expression.attr_type; }
    ;

//


statement returns [TypeInfo attr_type]
	: Identifier ((assignment_operator arith_expression) | postfixExpr) ';'
	{
		if (symtab.containsKey($Identifier.text)) {
	    	$attr_type = symtab.get($Identifier.text);
		   	if($arith_expression.attr_type != null) {
				if($attr_type != $arith_expression.attr_type) {
					System.out.println("Error! " +
										$arith_expression.start.getLine() +
										": Type mismatch for the two sides of an assignment.");
					$attr_type = TypeInfo.Error;
				}
		   	}
	   	} else {
           	/* Add codes to report and handle this error */
			System.out.println("Error! " +
								$Identifier.getLine() + 
								": Undeclared identifier.");
	       	$attr_type = TypeInfo.Error;
	   	}

		
		
	}
	| if_else_statements {if (TRACEON) System.out.println("statement: if_statement");}
    | for_loop_statements {if (TRACEON) System.out.println("statement: for_loop_statements");}
    | while_loop_statements {if (TRACEON) System.out.println("statement: while_loop_statements");}
    | print_statement ';' {if (TRACEON) System.out.println("statement: print_statement");}
	;


if_else_statements:
        IF '(' (judgement) ')'
		{
			if($judgement.attr_type != TypeInfo.Boolean) {
				System.out.println("Error! " +
									$judgement.start.getLine() + 
									": Error occur in the if-else condition part.");
			}
		}
        statement_t
        (ELSE statement_t)?
        ;

for_loop_statements : 
        FOR '('( (declaration | statement) | ';')
        ((judgement)?) ';' 
        ( Identifier ((assignment_operator arith_expression) | postfixExpr) ) ')'
		{
			if($judgement.attr_type != TypeInfo.Boolean) {
				System.out.println("Error! " +
									$judgement.start.getLine() + 
									": Error occur in the for-loop condition part.");
			}
			
			if (symtab.containsKey($Identifier.text)) {
		   		if($arith_expression.attr_type != null) {
					if(symtab.get($Identifier.text) != $arith_expression.attr_type) {
						System.out.println("Error! " +
											$arith_expression.start.getLine() +
											": Type mismatch for the two sides of an assignment.");
					}
		   		}
	   		} else {
           		/* Add codes to report and handle this error */
				System.out.println("Error! " +
									$Identifier.getLine() + 
									": Undeclared identifier.");
	   		}

		}
		statement_t
        ;

while_loop_statements:
        WHILE '('judgement')'
		{
			if($judgement.attr_type != TypeInfo.Boolean) {
				System.out.println("Error! " +
									$judgement.start.getLine() + 
									": Error occur in the while-loop condition part.");
			}
		}
        statement_t
        ;

statement_t: 
        statement {if (TRACEON) System.out.println("statement_t: statement");}
        | '{' statements '}' {if (TRACEON) System.out.println("statement_t: {statements}");}
        ;

print_statement:
        PRINTF '(' (LITERAL)  (',' primaryExpr)* ')'
        {if (TRACEON) System.out.println("print_statement: PRINTF '(' LITERAL  (',' primaryExpr)*')'");}
        ;	 


judgement returns [TypeInfo attr_type]: 
	(a = arith_expression (((rational_operator | logical_operator) b = arith_expression)* | postfixExpr) )
	{
		if($b.attr_type != null && $a.attr_type != null) {
			if($a.attr_type != $b.attr_type) {
				$attr_type = TypeInfo.Error;
			}
			else $attr_type = TypeInfo.Boolean;
		}
		else $attr_type = TypeInfo.Boolean;
		
	}
	;  
/* ====== description of the tokens ====== */
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

FLOAT:'float';
INT:'int';
DOUBLE:'double';
CHAR:'char';
UNSIGNED:'unsigned';
BOOLEAN:'bool';

MAIN: 'main';
VOID: 'void';
PRINTF: 'printf';

IF: 'if';
ELSE: 'else';
WHILE: 'while';
FOR: 'for';

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

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
LITERAL :  '"' (options{greedy=false;}: .)* '"';
COMMENT:'/*' .* '*/' {$channel=HIDDEN;};
COMMENT_2:'//' .* '\n' {$channel=HIDDEN;};
LIBRARY : '<'Identifier'.h>';
INCLUDE : '#include';