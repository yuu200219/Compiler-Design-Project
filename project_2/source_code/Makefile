CLASSPATH=../antlr-3.5.3-complete-no-st3.jar
SRCFILES := $(wildcard *.java)
JC = javac
.SUFFIXES:.java .class

result_1: myparser.g
	java -cp $(CLASSPATH) org.antlr.Tool myparser.g

result_2: $(SRCFILES)
	javac -cp $(CLASSPATH):. *.java

result_test_1: myparserLexer.class myparserParser.class test.c
	java -cp $(CLASSPATH):. testParser test.c

result_test_2: myparserLexer.class myparserParser.class test2.c
	java -cp $(CLASSPATH):. testParser test2.c

result_test_3: myparserLexer.class myparserParser.class test3.c
	java -cp $(CLASSPATH):. testParser test3.c

clean:
	rm -f *.class myparserLexer.java myparserParser.java myparser.tokens

