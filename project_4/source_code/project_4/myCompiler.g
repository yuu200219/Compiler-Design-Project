grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
    import java.util.Stack;
}

@members {
    boolean TRACEON = false;
    boolean GLOBAL = true;
    // Type information.
    public enum Type{
       VOID, ERR, BOOL, INT, FLOAT, CHAR, CONST_INT, CONST_FLOAT;
    }

    // This structure is used to record the information of a variable or a constant.
    class tVar {
	   int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
	   int   iValue;   // value of constant integer. Ex: 123.
	   double fValue;   // value of constant floating point. Ex: 2.314.
      String gValue;   // global variable
	};

    class Info {
       Type theType;  // type information.
       tVar theVar;
	   
	   Info() {
         theType = Type.ERR;
		   theVar = new tVar();
	   }
    };

	
    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, [Type, [varIndex or iValue, or fValue]]>
	//    - type: the variable type   (please check "enum Type")
	//    - varIndex: the variable's index, ex: t1, t2, ...
	//    - iValue: value of integer constant.
	//    - fValue: value of floating-point constant.
    // ============================================

    HashMap<String, Info> symtab = new HashMap<String, Info>();

    // labelCount is used to represent temporary label.
    // The first index is 0.
    int labelCount = 0;
	
    // varCount is used to represent temporary variables.
    // The first index is 0.
    int varCount = 0;
    
    // startPos is used to represent the @.str starting position
    int startPos = 1;
    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();


    /*
     * Output prologue.
     */
    void prologue()
    {
         //TextCode.add("; === prologue ====");
         //TextCode.add("declare dso_local i32 @printf(i8*, ...)");
	      TextCode.add("\ndefine dso_local i32 @main()");
	      TextCode.add("{");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue()
    {
       /* handle epilogue */
       //TextCode.add("\n; === epilogue ===");
	    TextCode.add("ret i32 0");
       TextCode.add("}");
    }
    
    
    /* Generate a new label */
    String newLabel()
    {
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 
    
    /* Record false labe by stack*/
    Stack<String> Lfalse_record = new Stack<String>();

    boolean print_declare = false;
    public List<String> getTextCode()
    {
       return TextCode;
    }
}



program
	: (INCLUDE LIBRARY)* (declarations) (VOID|INT) MAIN { GLOBAL = false; }'('')'
   { 
      if (TRACEON) System.out.println("VOID MAIN () {declarations statements}"); 
      /* Output function prologue */
           prologue();
   }
   '{' declarations statements '}'
   {
      /* output function epilogue */	  
            epilogue();
   }
	;

declarations: type Identifier
            {
               if (TRACEON)
                  System.out.println("declarations: type Identifier : declarations");

               if (symtab.containsKey($Identifier.text)) {
                  // variable re-declared.
                  System.out.println("Type Error: " + 
                                       $Identifier.getLine() + 
                                       ": Redeclared identifier.");
                  System.exit(0);
               }
               Info the_entry = new Info();
               if(!GLOBAL) {
                  /* Add ID and its info into the symbol table. */
                  the_entry.theType = $type.attr_type;
                  the_entry.theVar.varIndex = varCount;
                  varCount ++;
                  symtab.put($Identifier.text, the_entry);

                  if ($type.attr_type == Type.INT) { 
                     TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
                  }
                  else if($type.attr_type == Type.FLOAT) {
                     TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca float, align 4");
                  }
               } 
               else if(GLOBAL) {
                  the_entry.theType = $type.attr_type;
                  the_entry.theVar.gValue = $Identifier.text;
                  symtab.put($Identifier.text, the_entry);
                  if ($type.attr_type == Type.INT) { 
                     TextCode.add("@" + the_entry.theVar.gValue + " = common dso_local global i32 0, align 4");
                  }
                  else if($type.attr_type == Type.FLOAT) {
                     TextCode.add("@" + the_entry.theVar.gValue + " = common dso_local global float 0.000000e+00, align 4");
                  }
               } 
            }
            ( '=' a=signExpr 
            {
               if($a.theInfo.theType != Type.ERR) {
                  if(!GLOBAL) {
                     if($a.theInfo.theType == Type.CONST_INT) {
                        TextCode.add("store i32 " + $a.theInfo.theVar.iValue + ", i32* \%t" + the_entry.theVar.varIndex + ", align 4");
                     }
                     else if($a.theInfo.theType == Type.INT) {
                        TextCode.add("store i32 \%t" + $a.theInfo.theVar.varIndex + ", i32* \%t" + the_entry.theVar.varIndex + ", align 4");
                     }

                     if($a.theInfo.theType == Type.CONST_FLOAT) {
                        double var = $a.theInfo.theVar.fValue;
                        long bits = Double.doubleToLongBits(var);
                        TextCode.add("store float 0x" + Long.toHexString(bits) + ", float* \%t" + the_entry.theVar.varIndex + ", align 4");
                     }
                  }
                  else if(GLOBAL) {
                     if($a.theInfo.theType == Type.CONST_INT) {
                        TextCode.set(TextCode.size()-1, "@" + the_entry.theVar.gValue + " = dso_local global i32 "+ $a.theInfo.theVar.iValue + ", align 4");
                     }
                     
                     if($a.theInfo.theType == Type.CONST_FLOAT) {
                        double var = $a.theInfo.theVar.fValue;
                        long bits = Double.doubleToLongBits(var);
                        TextCode.set(TextCode.size()-1, "@" + the_entry.theVar.gValue + " = dso_local global float 0x"+ Long.toHexString(bits) + ", align 4");
                     }
                  }  
               }
            }
            | ) ';' declarations
            | 
            {
               if (TRACEON)
                  System.out.println("declarations: ");
            }
            ;


type
returns [Type attr_type]
    : INT { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
    | CHAR { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
    | FLOAT { if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
	;


statements:statement statements
          |
          ;


statement: assign_stmt ';'
         | if_stmt
         | func_no_return_stmt ';'
         | for_stmt
         | print_stmt ';'
         ;

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



for_stmt: FOR '(' assign_stmt ';'
                  a=cond_expression ';'
                  assign_stmt
              ')'
                  block_stmt
        ;
		 
		 
if_stmt
            : if_then_stmt if_else_stmt
            {
               String label_0 = Lfalse_record.pop();
               TextCode.add("\n" + label_0 + ":"); //current label
               
               //TextCode.add("pop: " + label_0);
               //TextCode.add("Lfalse_record: " + Lfalse_record);
            }
            ;

	   
if_then_stmt
            : IF '(' a=cond_expression ')'
            {
               String Ltrue = newLabel();
               String Lfalse = newLabel();
               Lfalse_record.push(Lfalse);

               // TextCode.add("push: " + Lfalse);
               // TextCode.add("Lfalse_record: " + Lfalse_record);
               
               TextCode.add("br i1 \%t" + $a.theInfo.theVar.varIndex + ", label \%" + Ltrue + ", label \%" + Lfalse);
               TextCode.add("\n" + Ltrue + ":");
            }
            b=block_stmt
            ;


if_else_stmt
            : (ELSE 
            {  
               String label_5 = newLabel(); //newlabel to jump end
               TextCode.add("br label \%" + label_5);
               
               String label_3 = Lfalse_record.pop();
               //TextCode.add("pop: " + label_3);  
               TextCode.add("\n" + label_3 + ":"); //current label
               
               Lfalse_record.push(label_5);        

               //TextCode.add("push: " + label_5);   
               //TextCode.add("Lfalse_record: " + Lfalse_record); 
               
            }
            block_stmt 
            { 
               // jump to false label
                
               String label_2 = Lfalse_record.pop();
               
               TextCode.add("br label \%" + label_2);
               Lfalse_record.push(label_2);
               // TextCode.add("br label \%L" + labelCount); 
            }
            )| 
            {
      
               String label_8 = Lfalse_record.pop();
               
               //TextCode.add("pop: " + label_8);
               
               Lfalse_record.push(label_8);
              
               //TextCode.add("push: " + label_8);
               //TextCode.add("Lfalse_record: " + Lfalse_record);

               TextCode.add("br label \%" + label_8);
            }
            ;

				  
block_stmt: 
      ('{' statements '}')
      | statement
	   ;



assign_stmt: Identifier ((assignment_operator arith_expression) 
             {
               Info theRHS = $arith_expression.theInfo;
               Info theLHS = symtab.get($Identifier.text); 
            
               if ((theLHS.theType == Type.INT) &&
                  (theRHS.theType == Type.INT)) {		   
                 
                  TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");
               } else if ((theLHS.theType == Type.INT) &&
                  (theRHS.theType == Type.CONST_INT)) {
                 
                  TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");				
               }
               
               if((theLHS.theType == Type.FLOAT) &&
                  (theRHS.theType == Type.FLOAT)) {
                     TextCode.add("store float \%t" + theRHS.theVar.varIndex + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");
               }
               else if((theLHS.theType == Type.FLOAT) &&
                  (theRHS.theType == Type.CONST_FLOAT)) {
                     double var = theRHS.theVar.fValue;
                     long bits = Double.doubleToLongBits(var);
                     
                     TextCode.add("store float 0x" + Long.toHexString(bits) + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");
               } 
               
			   } 
            | PostfixOP
            {
               Info theLHS = symtab.get($Identifier.text); 
               if(theLHS.theType == Type.INT) {
                  TextCode.add("\%t" + varCount + " = load i32, i32* \%t" + theLHS.theVar.varIndex + ", align 4");
                  int vIndex = varCount;
                  varCount ++;
                  TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + vIndex + ", 1");
                  vIndex = varCount;
                  varCount ++;
                  TextCode.add("store i32 \%t" + vIndex + ", i32 \%t" + theLHS.theVar.varIndex + ", align 4");
               }
               else if(theLHS.theType == Type.FLOAT) {
                  TextCode.add("\%t" + varCount + " = load float, float* \%t" + theLHS.theVar.varIndex + ", align 4");
                  int vIndex = varCount;
                  varCount ++;
                  TextCode.add("\%t" + varCount + " = fadd float \%t" + vIndex + ", 1.000000e+00");
                  vIndex = varCount;
                  varCount ++;
                  TextCode.add("store float \%t" + vIndex + ", float \%t" + theLHS.theVar.varIndex + ", align 4");
               }
               
            })
            ;

print_stmt: PRINTF '(' 
               LITERAL (',' a=arith_expression 
               {
                  if($a.theInfo.theType == Type.INT && !print_declare) {
                     TextCode.add(0, "declare dso_local i32 @printf(i8*, ...)");
                     print_declare = true;
                  }
                  else if($a.theInfo.theType == Type.FLOAT) {
                     TextCode.add("\%t" + varCount + " = fpext \%t" + $a.theInfo.theVar.varIndex + " to double");
                     $a.theInfo.theVar.varIndex = varCount;
                     varCount ++;
                  }
               })*
            ')'
            {
               int size = 0;
               boolean contain_percent = false;
               String str = $LITERAL.text;
               str = str.replace("\"", "");
               if(str.contains("\\n")) {
                  size --;
               }
               if(str.contains("\%d") || str.contains("\%lf")) {
                  contain_percent = true;
               }
               size += str.length() + 1;
               str = str.replace("\\n", "\\0A");
               str = str + "\\00";
               if(startPos > 1) {
                  int tmp = startPos - 1;
                  TextCode.add(startPos, "@.str." + tmp +" = private unnamed_addr constant [" + size + " x i8] c" + "\"" + str + "\"");
               }
               else {
                  TextCode.add(startPos, "@.str = private unnamed_addr constant [" + size + " x i8] c" + "\"" + str + "\"");
               }
                  
               startPos ++;
               if(contain_percent) {//have parameters
                  if($a.theInfo.theType == Type.INT) {
                     TextCode.add("\%t" + varCount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + size + " x i8], [" + size + " x i8]* @.str, i64 0, i64 0), i32 \%t"+ $a.theInfo.theVar.varIndex + ")");
                  }
                  else if($a.theInfo.theType == Type.FLOAT) {
                     TextCode.add("\%t" + varCount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + size + " x i8], [" + size + " x i8]* @.str, i64 0, i64 0), double \%t"+ $a.theInfo.theVar.varIndex + ")");
                  }
               }
               else {
                  TextCode.add("\%t" + varCount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + size + " x i8], [" + size + " x i8]* @.str, i64 0, i64 0))");
               }
               varCount ++;
            }
            ;



func_no_return_stmt: Identifier '(' argument ')'
                   ;


argument: arg (',' arg)*
        ;

arg: arith_expression
   | STRING_LITERAL
   ;
		   
cond_expression
returns [Info theInfo]
@init {theInfo = new Info();}
               : a=arith_expression (RelationOP b=arith_expression)*
               {
                  String cmp = "";
                  if($a.theInfo.theType == Type.FLOAT || $b.theInfo.theType == Type.FLOAT) {
                     switch($RelationOP.text) {
                        case ">":
                           cmp = "ogt";
                           break;
                        case ">=":
                           cmp = "oge";
                           break;
                        case "<":
                           cmp = "olt";
                           break;
                        case "<=":
                           cmp = "ole";
                           break;
                        case "==":
                           cmp = "oeq";
                           break;
                        case "!=":
                           cmp = "one";
                           break;
                     }
                     if(($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
                        TextCode.add("\%t" + varCount + " = fcmp " + cmp + " float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
                        $theInfo.theType = Type.BOOL;
                        $theInfo.theVar.varIndex = varCount;
                        varCount ++;
                     }
                     else if(($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
                        TextCode.add("\%t" + varCount + " = fcmp " + cmp + "float \%t" + $a.theInfo.theVar.varIndex + ", float" + $b.theInfo.theVar.fValue);
                     }
                     else if(($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
                        TextCode.add("\%t" + varCount + " = fcmp " + cmp + "float " + $a.theInfo.theVar.fValue + ", float \%t" + $b.theInfo.theVar.varIndex);
                     }
                  }
                  else if($a.theInfo.theType == Type.INT || $b.theInfo.theType == Type.INT) {
                     switch($RelationOP.text) {
                        case ">":
                           cmp = "sgt";
                           break;
                        case ">=":
                           cmp = "sge";
                           break;
                        case "<":
                           cmp = "slt";
                           break;
                        case "<=":
                           cmp = "sle";
                           break;
                        case "==":
                           cmp = "eq";
                           break;
                        case "!=":
                           cmp = "ne";
                           break;
                     }
                     if(($a.theInfo.theType == Type.INT) && ($b.theInfo.theType == Type.INT)) {
                        TextCode.add("\%t" + varCount + " = icmp " + cmp + " i32 \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
                        $theInfo.theType = Type.BOOL;
                        $theInfo.theVar.varIndex = varCount;
                        varCount ++;
                     }
                     else if(($a.theInfo.theType == Type.INT) && ($b.theInfo.theType == Type.CONST_INT)) {
                        TextCode.add("\%t" + varCount + " = icmp " + cmp + "i32 \%t" + $a.theInfo.theVar.varIndex + ", i32 " + $b.theInfo.theVar.iValue);
                     }
                     else if(($a.theInfo.theType == Type.CONST_INT) && ($b.theInfo.theType == Type.INT)) {
                        TextCode.add("\%t" + varCount + " = icmp " + cmp + "i32 " + $a.theInfo.theVar.iValue + ", i32 \%t" + $b.theInfo.theVar.varIndex);
                     }
                  }
                  
                  
                  
               }
               ;
			   
arith_expression
returns [Info theInfo]
@init {theInfo = new Info();}
                : a=multExpr { $theInfo=$a.theInfo; }
                 ( '+' b=multExpr
                    {
                        // We need to do type checking first.
                        // ...
                  
                        // code generation.					   
                        if (($a.theInfo.theType == Type.INT) &&
                        ($b.theInfo.theType == Type.INT)) 
                        {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        } 
                        else if (($a.theInfo.theType == Type.INT) &&
                        ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        }
                        else if (($a.theInfo.theType == Type.CONST_INT) &&
                        ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $b.theInfo.theVar.varIndex + ", " + $a.theInfo.theVar.iValue);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        }
                        else if(($a.theInfo.theType == Type.CONST_INT) &&
                        ($b.theInfo.theType == Type.CONST_INT)) 
                        {
                           // if all are constant, no need to used register.
                           $theInfo.theVar.iValue = $a.theInfo.theVar.iValue + $b.theInfo.theVar.iValue;
                        }


                    }
                 | '-' b=multExpr
                     {
                        if(($a.theInfo.theType == Type.INT) &&
                        ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.varIndex);
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        }
                        else if (($a.theInfo.theType == Type.INT) &&
                        ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        }
                        else if (($a.theInfo.theType == Type.CONST_INT) &&
                        ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $b.theInfo.theVar.varIndex + ", " + $a.theInfo.theVar.iValue);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        }
                        else if(($a.theInfo.theType == Type.CONST_INT) &&
                        ($b.theInfo.theType == Type.CONST_INT)) 
                        {
                           // if all are constant, no need to used register.
                           $theInfo.theVar.iValue = $a.theInfo.theVar.iValue - $b.theInfo.theVar.iValue;
                        }
                     } 
                 )*
                 ;

multExpr
returns [Info theInfo]
@init {theInfo = new Info();}
          : a=signExpr { $theInfo=$a.theInfo; }
          ( '*' b=signExpr 
          { 
            if(($a.theInfo.theType == Type.INT) &&
               ($b.theInfo.theType == Type.CONST_INT)) {
                  TextCode.add("\%t" + varCount + " = mul nsw i32 " + $b.theInfo.theVar.iValue + ", \%t" + $a.theInfo.theVar.varIndex);
                  // update mulExpr's theInfo
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
            } 
            else if(($a.theInfo.theType == Type.CONST_INT) &&
               ($b.theInfo.theType == Type.INT)) {
                  TextCode.add("\%t" + varCount + " = mul nsw i32 " + $a.theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex);
                  // update mulExpr's theInfo
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
            }
            else if(($a.theInfo.theType == Type.INT) &&
               ($b.theInfo.theType == Type.INT)) {
                  TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $b.theInfo.theVar.varIndex + ", \%t" + $a.theInfo.theVar.varIndex);
                  
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
            } 
            
            else if(($a.theInfo.theType == Type.CONST_INT) &&
               ($b.theInfo.theType == Type.CONST_INT)) {
                  $theInfo.theVar.iValue = $a.theInfo.theVar.iValue * $b.theInfo.theVar.iValue;
                  $theInfo.theType = Type.CONST_INT;
            } 
          }
          | '/' signExpr 
	  )*
	  ;

signExpr
returns [Info theInfo]
@init {theInfo = new Info();}
        : a=primaryExpr { $theInfo=$a.theInfo; } 
        | '-' b=primaryExpr { $theInfo=$b.theInfo; } 
	;
		  
primaryExpr
returns [Info theInfo]
@init {theInfo = new Info();}
           : Integer_constant
            {
               $theInfo.theType = Type.CONST_INT;
               $theInfo.theVar.iValue = Integer.parseInt($Integer_constant.text);
               if(TRACEON) {
                  System.out.println("primaryExpr: Integer_constant");
               }
            }
            | Floating_point_constant
            {
               $theInfo.theType = Type.CONST_FLOAT;
               $theInfo.theVar.fValue = Float.parseFloat($Floating_point_constant.text);
               if(TRACEON) {
                  System.out.println("primaryExpr: Floating_point_constant");
               }
            }
            | Identifier
               {
                  // get type information from symtab.
                  Type the_type = symtab.get($Identifier.text).theType;
                  $theInfo.theType = the_type;

                  // get variable index from symtab.
                  int vIndex = symtab.get($Identifier.text).theVar.varIndex;
                  String gName = symtab.get($Identifier.text).theVar.gValue;
                  
                  switch (the_type) {
                     case INT: 
                        if(gName != null)
                           TextCode.add("\%t" + varCount + " = load i32, i32* @" + gName + ", align 4"); 
                        else
                           TextCode.add("\%t" + varCount + " = load i32, i32* \%t" + vIndex + ", align 4");
                        $theInfo.theVar.varIndex = varCount;
                        varCount ++;
                        break;
                     case FLOAT:
                        TextCode.add("\%t" + varCount + " = load float, float* \%t" + vIndex + ", align 4");
                        $theInfo.theVar.varIndex = varCount;
                        varCount ++;
                        break;
                     case CHAR:
                        break;
			
                  }
            }
	   | '&' Identifier
	   | '(' a=arith_expression ')'
         {
            $theInfo = $a.theInfo;
         }
         ;

		   
/* description of the tokens */
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
VOID: 'void';

MAIN: 'main';

IF: 'if';
ELSE: 'else';
FOR: 'for';
WHILE: 'while';
PRINTF: 'printf';

RelationOP: '>' |'>=' | '<' | '<=' | '==' | '!=';
PostfixOP: '++' | '--';

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

STRING_LITERAL
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

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
COMMENT:'/*' .* '*/' {$channel=HIDDEN;};
COMMENT_2:'//' .* '\n' {$channel=HIDDEN;};
LIBRARY : '<'Identifier'.h>';
INCLUDE : '#include';
LITERAL :  '"' (options{greedy=false;}: .)* '"';
//LITERAL :  '"' ~( '"' )* '"';
fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    ;
