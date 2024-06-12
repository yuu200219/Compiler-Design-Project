CLASSPATH=../../antlr-3.5.3-complete-no-st3.jar
SRCFILES := $(wildcard *.java)
JC = javac
.SUFFIXES:.java .class

result_1: myCompiler.g
	java -cp $(CLASSPATH) org.antlr.Tool myCompiler.g

result_2: $(SRCFILES)
	javac -cp $(CLASSPATH):. *.java

result_test_1: myCompilerLexer.class myCompilerParser.class test.c
	java -cp $(CLASSPATH):. myCompiler_test test.c

result_test_2: myCompilerLexer.class myCompilerParser.class test2.c
	java -cp $(CLASSPATH):. myCompiler_test test2.c

result_test_3: myCompilerLexer.class myCompilerParser.class test3.c
	java -cp $(CLASSPATH):. myCompiler_test test3.c


clean:
	rm -f *.class myCompilerLexer.java myCompilerParser.java myCompiler.tokens
