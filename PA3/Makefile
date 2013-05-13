
ASSN = 3J
CLASS= cs143
CLASSDIR= /afs/ir/class/cs143

SRC= ClassTable.java TreeConstants.java cool-tree.java good.cl bad.cl README
CSRC = \
	ASTConstants.java \
	ASTLexer.java \
	ASTParser.java \
	AbstractSymbol.java \
	AbstractTable.java \
	BoolConst.java \
	Flags.java \
	IdSymbol.java \
	IdTable.java \
	IntSymbol.java \
	IntTable.java \
	ListNode.java \
	Semant.java \
	StringSymbol.java \
	StringTable.java \
	CgenSupport.java \
	SymbolTable.java \
	SymtabExample.java \
	TokenConstants.java \
	TreeNode.java \
	Utilities.java
TSRC= mysemant mycoolc cool-tree.aps
CGEN= 
LIBS= lexer parser cgen
CFIL= ${CSRC} ${CGEN} ClassTable.java TreeConstants.java cool-tree.java 
HFIL= 
LSRC= Makefile
CLS= ${CFIL:.java=.class}
OUTPUT= good.output bad.output

JAVAC := javac

# rt.jar yet again
CUPCLASSPATH := ${CLASSDIR}/lib/java-cup-11a.jar
CLASSPATH := ${CLASSDIR}/lib:.:/usr/java/lib/rt.jar:${CUPCLASSPATH}

semant: Makefile ${CLS}
	@rm -f semant
	echo '#!/bin/sh' >> semant
	echo 'java -classpath ${CLASSPATH} Semant $$*' >> semant
	chmod 755 semant

${OUTPUT}:	semant good.cl bad.cl
	@rm -f ${OUTPUT}
	./mysemant good.cl >good.output 2>&1 
	-./mysemant bad.cl >bad.output 2>&1 

symtab-example: Makefile ${CLS}
	@rm -f symtab-example
	echo '#!/bin/sh' >> symtab-example
	echo 'java -classpath ${CLASSPATH} SymtabExample $$*' >> symtab-example
	chmod 755 symtab-example

dotest:	semant good.cl bad.cl
	@echo "\nRunning semant on good.cl\n"
	-./mysemant good.cl 
	@echo "\nRunning semant on bad.cl\n"
	-./mysemant bad.cl

clean :
	-rm -f ${OUTPUT} *.s *.class core ${CLS} ${CGEN} semant symtab-example

submit: semant
	$(CLASSDIR)/bin/pa_submit PA3J .

# build rules

%.class : %.java TokenConstants.class cool-tree.class
	${JAVAC} -d . -sourcepath .:src -classpath ${CLASSPATH} $<

%.class : src/%.java TokenConstants.class cool-tree.class
	${JAVAC} -d . -sourcepath .:src -classpath ${CLASSPATH} $<

# dummy dependency
cool-tree.class : ./cool-tree.java
	${JAVAC} -d . -sourcepath .:src -classpath ${CLASSPATH} $<
	touch $@

TokenConstants.class : src/TokenConstants.java
	${JAVAC} -d . -sourcepath .:src -classpath ${CLASSPATH} $<

# extra dependencies:
