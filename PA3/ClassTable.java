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
    private List<AbstractSymbol> uninheritable;                     /* stores list of uninheritable classes */
    // public static final int NUM_PRIMITIVE_CLASSES = 5;

    
    /* Variable scoping and type checking:
     * Wraps around the following data structures that are used
     * for scoping and type checking. Made public for the sake of
     * painlessly passing the necessary data strcutures around
     * as arguments  through one object (ClassTable)*/
    public SymbolTable localVarTypeTable;               /* Handles var scoping and types */
    public Map<AbstractSymbol, HashMap> classToAttrMap;     /* Maps class name to its attr map */
    public Map<AbstractSymbol, HashMap> classToMethodMap;   /* Maps class name to its method map */
    public AbstractSymbol currClassName;                /* Pointer to class we are currently
                                                           processing with type checking */

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

        /* Initialize uninheritable classes */
        uninheritable.add(Int_class.getName());
        uninheritable.add(Str_class.getName());
        uninheritable.add(Bool_class.getName());
    }
	
    public ClassTable(Classes cls) {
	semantErrors = 0;
	errorStream = System.err;
	
	/* Initialize the inheritance graph structure */
        nameToClass = new HashMap<AbstractSymbol, class_c>(); 
        inheritance = new HashMap<AbstractSymbol, Set<AbstractSymbol>>();
        uninheritable = new ArrayList<AbstractSymbol>();

        /* Init data structures for var scoping and type checking */
        localVarTypeTable = new SymbolTable();
        classToAttrMap = new HashMap<AbstractSymbol, HashMap>();
        classToMethodMap = new HashMap<AbstractSymbol, HashMap>();
        currClassName = null;

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

            /* Make sure inheritence is not from Int, String, or Bool */
            if (uninheritable.contains(class_node.getParent())){
                errorStream.println("Error: inheritence from this parent class not allowed");
                semantError(class_node);
                return;
            }

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

        /* Check for cycles within inheritance graph */
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

        /* Make sure a Main class is defined */
        if (!nameToClass.containsKey(TreeConstants.Main)){
            errorStream.println("Error: must define Main class");
            return;
        }

    }

    /* Find LUB for two class types */
    public AbstractSymbol findLeastUpperBound(AbstractSymbol s1, AbstractSymbol s2){

        /* No type is subtype of everything */
        if (s1.equals(TreeConstants.No_type))
            return s2;
        if (s2.equals(TreeConstants.No_type))
            return s1;

        /* find LUB */
        AbstractSymbol curr = s1;
        List<AbstractSymbol> s1SuperTypes = new ArrayList<AbstractSymbol>();

        /* traverse up tree from s1 */
        while (!curr.equals(TreeConstants.No_class)){
            s1SuperTypes.add(curr);
            curr = nameToClass.get(curr).getParent();
        }

        curr = s2;
        while (!curr.equals(TreeConstants.No_class)){
            if (s1SuperTypes.contains(curr))
                /* always returns here */
                return curr;

            curr = nameToClass.get(curr).getParent();
        }

        errorStream.println("Should not reach this far");
        return null;
    }

    /* should have validated type existence before this point */
    public boolean isSubtype(AbstractSymbol type, AbstractSymbol subtype){
        
        /* No_type is subtype of everything */
        // TODO: what about type = No_type
        if (subtype.equals(TreeConstants.No_type))
            return true; 

        AbstractSymbol curr = subtype;

        /* Traverse up the tree */
        while (!curr.equals(TreeConstants.No_class)){
            if (curr.equals(type))
                return true;

            curr = nameToClass.get(curr).getParent();
        }
        return false;
    }

    /* is valid type */
    public boolean isValidType(AbstractSymbol type){
        if (type.equals(TreeConstants.No_type))
            return true;
        return nameToClass.containsKey(type);
    }

    public AbstractSymbol getClassFilename(){
        if (currClassName == null)
            return null;
        return nameToClass.get(currClassName).getFilename();
    }

    public void doTypeCheck(){

        Stack<AbstractSymbol> stack = new Stack<AbstractSymbol>();
        stack.push(TreeConstants.Object_);

        /* First traversal */
        while(!stack.isEmpty()){
            AbstractSymbol curr = stack.pop();
            class_c class_node = nameToClass.get(curr);

            /* Extract attribute and method type info */ 
            currClassName = curr;
            class_node.findAttrAndMethodTypes(this); 

            if (inheritance.containsKey(curr))
                for (AbstractSymbol next : inheritance.get(curr)){
                    stack.push(next);
                }
        }
    }

    /* Error reporting interface */
    public void reportError(TreeNode t, String errMsg){
        errorStream.println(errMsg);
        semantError(nameToClass.get(currClassName).getFilename(), t);
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

    public static final String ERROR_TYPE_NOT_DEF = "Error: parameter type not defined";
    public static final String ERROR_VAR_NAME_IN_USE = "Error: variable name in use";
    public static final String ERROR_TYPE_SELF_TYPE = "Error: parameter type cannot be SELF_TYPE";
    public static final String ERROR_INVALID_RET_TYPE = "Error: invalid method return type";
}

