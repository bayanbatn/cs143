import java.io.PrintStream;
import java.util.*;

/** This class may be used to contain the semantic information such as
 * the inheritance graph.  You may use it or not as you like: it is only
 * here to provide a container for the supplied methods.  */
class ClassTable {
    private int semantErrors;
    private PrintStream errorStream;
    private Map<AbstractSymbol, Set<AbstractSymbol>> inheritance;   /* inheritance directed graph structure */
    private Map<AbstractSymbol, class_c> nameToClass;               /* mapping from class name to class obj */
    // public static final int NUM_PRIMITIVE_CLASSES = 5;

    /** Creates data structures representing basic Cool classes (Object,
     * IO, Int, Bool, String).  Please note: as is this method does not
     * do anything useful; you will need to edit it to make if do what
     * you want.
     * */
    private void installBasicClasses() {
	AbstractSymbol filename 
	    = AbstractTable.stringtable.addString("<basic class>");
	
	// The following demonstrates how to create dummy parse trees to
	// refer to basic Cool classes.  There's no need for method
	// bodies -- these are already built into the runtime system.

	// IMPORTANT: The results of the following expressions are
	// stored in local variables.  You will want to do something
	// with those variables at the end of this method to make this
	// code meaningful.

	// The Object class has no parent class. Its methods are
	//        cool_abort() : Object    aborts the program
	//        type_name() : Str        returns a string representation 
	//                                 of class name
	//        copy() : SELF_TYPE       returns a copy of the object

        class_c Object_class = 
            new class_c(0, 
                    TreeConstants.Object_, 
                    TreeConstants.No_class,
                    new Features(0)
                    .appendElement(new method(0, 
                            TreeConstants.cool_abort, 
                            new Formals(0), 
                            TreeConstants.Object_, 
                            new no_expr(0)))
                    .appendElement(new method(0,
                            TreeConstants.type_name,
                            new Formals(0),
                            TreeConstants.Str,
                            new no_expr(0)))
                    .appendElement(new method(0,
                            TreeConstants.copy,
                            new Formals(0),
                            TreeConstants.SELF_TYPE,
                            new no_expr(0))),
                    filename);

	// The IO class inherits from Object. Its methods are
	//        out_string(Str) : SELF_TYPE  writes a string to the output
	//        out_int(Int) : SELF_TYPE      "    an int    "  "     "
	//        in_string() : Str            reads a string from the input
	//        in_int() : Int                "   an int     "  "     "

        class_c IO_class = 
            new class_c(0,
                    TreeConstants.IO,
                    TreeConstants.Object_,
                    new Features(0)
                    .appendElement(new method(0,
                            TreeConstants.out_string,
                            new Formals(0)
                            .appendElement(new formalc(0,
                                    TreeConstants.arg,
                                    TreeConstants.Str)),
                            TreeConstants.SELF_TYPE,
                            new no_expr(0)))
                    .appendElement(new method(0,
                            TreeConstants.out_int,
                            new Formals(0)
                            .appendElement(new formalc(0,
                                    TreeConstants.arg,
                                    TreeConstants.Int)),
                            TreeConstants.SELF_TYPE,
                            new no_expr(0)))
                    .appendElement(new method(0,
                            TreeConstants.in_string,
                            new Formals(0),
                            TreeConstants.Str,
                            new no_expr(0)))
                    .appendElement(new method(0,
                                TreeConstants.in_int,
                                new Formals(0),
                                TreeConstants.Int,
                                new no_expr(0))),
            filename);

	// The Int class has no methods and only a single attribute, the
	// "val" for the integer.

        class_c Int_class = 
            new class_c(0,
                    TreeConstants.Int,
                    TreeConstants.Object_,
                    new Features(0)
                    .appendElement(new attr(0,
                            TreeConstants.val,
                            TreeConstants.prim_slot,
                            new no_expr(0))),
                    filename);

        // Bool also has only the "val" slot.
        class_c Bool_class = 
            new class_c(0,
                    TreeConstants.Bool,
                    TreeConstants.Object_,
                    new Features(0)
                    .appendElement(new attr(0,
                            TreeConstants.val,
                            TreeConstants.prim_slot,
                            new no_expr(0))),
                    filename);

	// The class Str has a number of slots and operations:
	//       val                              the length of the string
	//       str_field                        the string itself
	//       length() : Int                   returns length of the string
	//       concat(arg: Str) : Str           performs string concatenation
	//       substr(arg: Int, arg2: Int): Str substring selection

        class_c Str_class =
            new class_c(0,
                    TreeConstants.Str,
                    TreeConstants.Object_,
                    new Features(0)
                    .appendElement(new attr(0,
                            TreeConstants.val,
                            TreeConstants.Int,
                            new no_expr(0)))
                    .appendElement(new attr(0,
                            TreeConstants.str_field,
                            TreeConstants.prim_slot,
                            new no_expr(0)))
                    .appendElement(new method(0,
                            TreeConstants.length,
                            new Formals(0),
                            TreeConstants.Int,
                            new no_expr(0)))
                    .appendElement(new method(0,
                            TreeConstants.concat,
                            new Formals(0)
                            .appendElement(new formalc(0,
                                    TreeConstants.arg, 
                                    TreeConstants.Str)),
                            TreeConstants.Str,
                            new no_expr(0)))
                    .appendElement(new method(0,
                                TreeConstants.substr,
                                new Formals(0)
                                .appendElement(new formalc(0,
                                        TreeConstants.arg,
                                        TreeConstants.Int))
                                .appendElement(new formalc(0,
                                        TreeConstants.arg2,
                                        TreeConstants.Int)),
                                TreeConstants.Str,
                                new no_expr(0))),
            filename);

        /* Add primitive classes to the inheritance graph structure */
        Set<AbstractSymbol> primitives = new HashSet<AbstractSymbol>();
        primitives.add(IO_class.getName());
        primitives.add(Int_class.getName());
        primitives.add(Str_class.getName());
        primitives.add(Bool_class.getName());

        inheritance.put(Object_class.getName(), primitives);

        /* Add primitives to name to class translation structure */
        nameToClass.put(IO_class.getName(), IO_class);
        nameToClass.put(Int_class.getName(), Int_class);
        nameToClass.put(Str_class.getName(), Str_class);
        nameToClass.put(Bool_class.getName(), Bool_class);
        nameToClass.put(Object_class.getName(), Object_class);
    }
	

    public ClassTable(Classes cls) {
	semantErrors = 0;
	errorStream = System.err;
	
	/* Initialize the inheritance graph structure */
        // TODO: include self type here, if so, modify error below
        nameToClass = new HashMap<AbstractSymbol, class_c>(); 
        inheritance = new HashMap<AbstractSymbol, Set<AbstractSymbol>>();

        if (Flags.semant_debug) System.out.println("Installing basic classes");
        installBasicClasses();

        /* Add the rest of the class types into the graph */
        for (int i = 0; i < cls.getLength(); i++){
            class_c class_node = (class_c) cls.getNth(i);
            if (nameToClass.containsKey(class_node.getName())){
                errorStream.println("Error: duplicate class name");
                semantError(class_node);
                return;
            }
            nameToClass.put(class_node.getName(), class_node);

            /* Include class in inheritance graph */
            if (!inheritance.containsKey(class_node.getParent()))
                inheritance.put(class_node.getParent(), new HashSet<AbstractSymbol>());

            inheritance.get(class_node.getParent()).add(class_node.getName());
        }

        /* Validate inheritance tree structure */
        Set<AbstractSymbol> reachable = new HashSet<AbstractSymbol>(); 
        Stack<AbstractSymbol> stack = new Stack<AbstractSymbol>();
        stack.push(TreeConstants.Object_);
        int class_cnt = 0; // accounts for the Object class


        if (Flags.semant_debug) 
            System.out.println("Printing out inheritence graph. Number of classes: "+nameToClass.size());

        while(!stack.isEmpty()){
            AbstractSymbol curr = stack.pop();
            reachable.add(curr);
            class_cnt++;

            if (Flags.semant_debug) System.out.print(curr+" => ");
            
            if (inheritance.containsKey(curr))
                for (AbstractSymbol next : inheritance.get(curr)){
                    stack.push(next);
                    if (Flags.semant_debug) System.out.print(next+", ");
                }
            if (Flags.semant_debug) System.out.print("\n");
        }

        if (class_cnt < nameToClass.size()){
            errorStream.println("Error: some classes are not part of inheritance tree");
            Set<AbstractSymbol> keys = nameToClass.keySet(); // set of all defined class names
            keys.removeAll(reachable); // keep only the unreachable nodes
            for (AbstractSymbol class_name : keys){
                errorStream.print(class_name + " at ");
                semantError(nameToClass.get(class_name));
                errorStream.print("\n");
            }
            return;
        }
    }

    /** Prints line number and file name of the given class.
     *
     * Also increments semantic error count.
     *
     * @param c the class
     * @return a print stream to which the rest of the error message is
     * to be printed.
     *
     * */
    public PrintStream semantError(class_c c) {
	return semantError(c.getFilename(), c);
    }

    /** Prints the file name and the line number of the given tree node.
     *
     * Also increments semantic error count.
     *
     * @param filename the file name
     * @param t the tree node
     * @return a print stream to which the rest of the error message is
     * to be printed.
     *
     * */
    public PrintStream semantError(AbstractSymbol filename, TreeNode t) {
	errorStream.print(filename + ":" + t.getLineNumber() + ": ");
	return semantError();
    }

    /** Increments semantic error count and returns the print stream for
     * error messages.
     *
     * @return a print stream to which the error message is
     * to be printed.
     *
     * */
    public PrintStream semantError() {
	semantErrors++;
	return errorStream;
    }

    /** Returns true if there are any static semantic errors. */
    public boolean errors() {
	return semantErrors != 0;
    }
}
			  
    
