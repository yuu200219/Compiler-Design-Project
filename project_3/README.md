資工三 陳昱瑋 409410118

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
