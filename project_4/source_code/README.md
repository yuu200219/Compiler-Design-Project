資工三 陳昱瑋 409410118
## Overview
[!image](https://github.com/yuu200219/Compiler-Design-Project/blob/main/project_4/source_code/%E6%88%AA%E5%9C%96%202025-02-03%20%E6%99%9A%E4%B8%8A10.58.42.png)
## Compile and Execution:

To compile and execute myCompiler, follow following step:
1. make result_1 (it will generate myCompilerParser.java, myCompilerLexer and myCompiler.tokens)
2. make result_2 (it will compile all .java files, generate relative .class files)
3. make reulst_test_1 (it will output relative LLVM code of test.c)
4. make result_test_2 (it will output relative LLVM code of test2.c)
5. make result_test_3 (it will output relative LLVM code of test3.c)

## Antlr version:
antlr-3.5.3-complete-no-st3.jar.

## Test File Explaination:
1. test.c: Testing functionality of float, if-statement, and printf.
2. test2.c: Testing functionality of global int, float, and multiple statement of printf.
3. test3.c: Testing functionality of nested-if-else and arithmetic computation.

## Feature Support:
1. Integer data type
2. Arithmetic computation
3. Comparison expression
4. if-then/if-then-else
5. printf()
6. Float data type
7. Nested-if-else
8. Global variable

NOTE: In Makefile, CLASSPATH need to change to your own directory of antlr.jar!
