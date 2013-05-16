
ASSN = 2J
CLASS= cs143
CLASSDIR= /home/naranb/cs143
#CLASSDIR= /afs/ir/class/cs143

SRC= cool.cup good.cl bad.cl README
CSRC= \
	AbstractSymbol.java \
	AbstractTable.java \
	BoolConst.java \
	CgenClassTable.java \
	CgenNode.java \
	CgenSupport.java \
	ClassTable.java \
	CoolTokenLexer.java \
	Flags.java \
	IdSymbol.java \
	IdTable.java \
	IntSymbol.java \
	IntTable.java \
	ListNode.java \
	Parser.java \
	StringSymbol.java \
	StringTable.java \
	SymbolTable.java \
	TreeConstants.java \
	TreeNode.java \
	Utilities.java \
	cool-tree.java
TSRC= myparser mycoolc cool-tree.aps
CGEN= CoolParser.java TokenConstants.java
LIBS= lexer semant cgen
CFIL= ${CSRC} ${CGEN}
HFIL= cool-tree.h cool-tree.handcode.h 
LSRC= Makefile
CLS= ${CFIL:.java=.class}
OUTPUT= good.output bad.output

JAVAC := javac
CUP := ${CLASSDIR}/bin/java_cup
#CUP := /usr/class/cs143/bin/java_cup

CUPCLASSPATH := ${CLASSDIR}/lib/java-cup-11a.jar

CLASSPATH := ${CUPCLASSPATH}:.

parser: Makefile ${CLS}
	@rm -f parser
	echo '#!/bin/sh' >> parser
	echo 'java -classpath ${CLASSPATH}:`dirname $$0` Parser $$*' >> parser
	chmod 755 parser

${OUTPUT}:	parser good.cl bad.cl
	@rm -f ${OUTPUT}
	./myparser good.cl >good.output 2>&1 
	-./myparser bad.cl >bad.output 2>&1 

CoolParser.java TokenConstants.java: cool.cup
	${CUP} -parser CoolParser -symbols TokenConstants -expect 10000 -dump -nopositions < $< >cool.output 2>&1 || { egrep '^Error at ' cool.output; false; }


dotest:	parser good.cl bad.cl
	@echo "\nRunning parser on good.cl\n"
	-./myparser good.cl 
	@echo "\nRunning parser on bad.cl\n"
	-./myparser bad.cl

submit: parser
	$(CLASSDIR)/bin/pa_submit PA2J .

clean:
	rm -f parser *.class CoolParser.java TokenConstants.java

# build rules

%.class : %.java TokenConstants.java cool-tree.class
	${JAVAC} -classpath ${CLASSPATH} $<

%.class : src/%.java TokenConstants.java cool-tree.class
	${JAVAC} -d . -sourcepath .:src -classpath ${CLASSPATH} $<

# dummy dependency
cool-tree.class : src/cool-tree.java
	${JAVAC} -d . -sourcepath .:src -classpath ${CLASSPATH} $<
	touch $@

# extra dependencies:
