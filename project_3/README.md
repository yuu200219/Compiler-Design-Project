# How to compile
To compile and execute type checker, follow following step:

1. `make result_1`
    - It will generate myCheckerParser.java, myCheckerLexer and myChecker.tokens
2. `make result_2`
    - It will compile all .java files, generate relative .class files
3. `make reulst_test_1`
    - It will parsing test.c
4. `make result_test_2` 
    - It will parsing test2.c
5. `make result_test_3`
    - It will parsing test3.c

- Using antlr-3.5.3-complete-no-st3.jar.
- NOTE: In Makefile, CLASSPATH need to change to your own directory of antlr.jar!

# Ouput Explaination
- According to the test file(.c), it will output the corresponding error.
- For example:
  ```c=
  void main() {
    int num;
    int s;
    int index;
    float s;

    k = 0;
    int k;

    num = index + 3.21;
  }
  ```
  it will give following error messages:
  ```bash=
  Error! 10: Redeclared identifier.
  Error! 12: Undeclared identifier.
  Error! 15: Type mismatch for the operator + in an expression.
  Error! 15: Type mismatch for the two sides of an assignment.
  ```  
