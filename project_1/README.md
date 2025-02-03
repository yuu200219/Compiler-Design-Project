- To compile and execute lexical analyzer, follow following step:
  1. `make result_1`
     - It will generate mylexer.java and mylexer.tokens.
  2. `make result_2`
     - it will compile all .java files, generate relative .class files.
  3. `make reulst_test_1`
      - It will analyze the token of test_1.
  4. `make result_test_2`
      - It will analyze the token of test_2.
  5. `make result_test_3`
      - it will analyze the token of test_3.

- NOTE: In Makefile, CLASSPATH need to change to your own directory of antlr.jar!

# Output Explaination
- According to the file `testLexer.java`
  ```java=
  try {
    CharStream input = new ANTLRFileStream(args[0]);
	  mylexer lexer = new mylexer(input);
    Token token = lexer.nextToken();
    while (token.getType() != -1) {  // -1 is EOF.
	    System.out.println("Token: "+token.getType() + " " + token.getText());
	    token = lexer.nextToken();
	   }
  }
  catch(Throwable t) {
    System.out.println("Exception: "+t);
    t.printStackTrace();
  }
  ```
  - It will scan over the test code, and output each token type(it will be a number) and text
  - If the token is not defined in the file `myLexer.g`, it will throw exception.
