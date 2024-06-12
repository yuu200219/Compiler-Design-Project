CLASSPATH=../../antlr-3.5.3-complete-no-st3.jar
SRCFILES := $(wildcard *.java)
JC = javac
.SUFFIXES:.java .class

result_1: myChecker.g
	java -cp $(CLASSPATH) org.antlr.Tool myChecker.g

result_2: $(SRCFILES)
	javac -cp $(CLASSPATH):. *.java

result_test_1: myCheckerLexer.class myCheckerParser.class test.c
	java -cp $(CLASSPATH):. myChecker_test test.c

result_test_2: myCheckerLexer.class myCheckerParser.class test2.c
	java -cp $(CLASSPATH):. myChecker_test test2.c

result_test_3: myCheckerLexer.class myCheckerParser.class test3.c
	java -cp $(CLASSPATH):. myChecker_test test3.c


clean:
	rm -f *.class myCheckerLexer.java myCheckerParser.java myChecker.tokens