CLASSPATH=../antlr-3.5.3-complete-no-st3.jar
SRCFILES := $(wildcard *.java)
JC = javac
.SUFFIXES:.java .class

result_1: mylexer.g
	java -jar $(CLASSPATH) mylexer.g

result_2: $(SRCFILES)
	javac -cp $(CLASSPATH):. *.java

result_test_1: testLexer.class test_1.c
	java -cp $(CLASSPATH):. testLexer test_1.c

result_test_2: testLexer.class test_2.c
	java -cp $(CLASSPATH):. testLexer test_2.c

result_test_3: testLexer.class test_3.c
	java -cp $(CLASSPATH):. testLexer test_3.c

clean:
	rm -f *.class mylexer.java mylexer.tokens

