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
    public SymbolTable localVarToType;                      /* Handles var scoping and types */
    public Map<AbstractSymbol, HashMap> classToAttrMap;     /* Maps class name to its attr map */
    public Map<AbstractSymbol, HashMap> classToMethodMap;   /* Maps class name to its method map */
    public AbstractSymbol currClassName;                    /* Pointer to class we are currently
                                                               processing with type checking */
    public Set<AbstractSymbol> caseTypes;                   /* Set of distinct types of case stmt */

    /* Error messages */
    public static final String ERROR_TYPE_NOT_DEF = "Error: parameter type %s not defined";
    public static final String ERROR_VAR_NAME_IN_USE = "Error: variable name %s in use";
    public static final String ERROR_VAR_NOT_DEFINED = "Error: undefined variable %s";
    public static final String ERROR_METHOD_NOT_DEFINED = "Error: undefined method %s";
    public static final String ERROR_METHOD_SIGN_MISMATCH = "Error: unexpected method signature for %s";
    public static final String ERROR_TYPE_SELF_TYPE = "Error: parameter type cannot be SELF_TYPE";
    public static final String ERROR_INVALID_RET_TYPE = "Error: invalid return type for method %s";
    public static final String ERROR_MAIN_NO_MAIN_METHOD = "Error: Main class must define main method";
    public static final String ERROR_ASSIGN_TYPE_MISMATCH = "Error: cannot assign type %s to type %s";
    public static final String ERROR_RET_TYPE_MISMATCH = "Error: cannot return type %s to expected type %s";
    public static final String ERROR_ARG_TYPE_MISMATCH = "Error: expected type: %s, got type: %s";
    public static final String ERROR_CASE_TYPE_IN_USE = "Error: case branch type %s in use already";
    public static final String ERROR_UNKNOWN_RET_TYPE = "Error: unknown (no_type) return type";
    public static final String ERROR_TYPE_NOT_SUBTYPE = "Error: cannot cast type %s to non-supertype %s";
    public static final String ERROR_ASSIGN_TO_SELF = "Error: cannot assign to self variable";
    public static final String ERROR_WRONG_NUMBER_OF_ARGS = "Erro: Method %s invoked with wrong"+ 
                                                            "number of args";


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
        uninheritable.add(TreeConstants.SELF_TYPE);
    }
	
    public ClassTable(Classes cls) {
	semantErrors = 0;
	errorStream = System.err;
	
	/* Initialize the inheritance graph structure */
        nameToClass = new HashMap<AbstractSymbol, class_c>(); 
        inheritance = new HashMap<AbstractSymbol, Set<AbstractSymbol>>();
        uninheritable = new ArrayList<AbstractSymbol>();

        /* Init data structures for var scoping and type checking */
        localVarToType = new SymbolTable();
        classToAttrMap = new HashMap<AbstractSymbol, HashMap>();
        classToMethodMap = new HashMap<AbstractSymbol, HashMap>();
        currClassName = null;
        caseTypes = new HashSet<AbstractSymbol>();

        /* Initialize basic classes into hiererchy */
        installBasicClasses();

        /* Add the rest of the class types into the graph */
        for (int i = 0; i < cls.getLength(); i++){
            class_c class_node = (class_c) cls.getNth(i);
            if (nameToClass.containsKey(class_node.getName()) || class_node.getName().equals(TreeConstants.SELF_TYPE))
                semantError(class_node).println("Redefinition of existing class "+class_node.getName());
            /* Make sure inheritence is not from Int, String, or Bool */
            else if (uninheritable.contains(class_node.getParent()))
                semantError(class_node).println("Class "+class_node.getName()+
                                                " cannot inherit class "+class_node.getParent());
            else {
                nameToClass.put(class_node.getName(), class_node);
                /* Include class in inheritance graph */
                if (!inheritance.containsKey(class_node.getParent()))
                    inheritance.put(class_node.getParent(), new HashSet<AbstractSymbol>());
                inheritance.get(class_node.getParent()).add(class_node.getName());
            }
        }

        /* Validate inheritance tree structure */
        Set<AbstractSymbol> reachable = new HashSet<AbstractSymbol>(); 
        Stack<AbstractSymbol> stack = new Stack<AbstractSymbol>();
        stack.push(TreeConstants.Object_);
        int class_cnt = 0; // accounts for the Object class

        while(!stack.isEmpty()){
            AbstractSymbol curr = stack.pop();
            reachable.add(curr);
            class_cnt++;

            if (inheritance.containsKey(curr))
                for (AbstractSymbol next : inheritance.get(curr)){
                    stack.push(next);
                }
        }

        /* Check for cycles and disjoint sections within inheritance graph */
        if (class_cnt < nameToClass.size()){
            Set<AbstractSymbol> keys = nameToClass.keySet(); // set of all defined class names
            keys.removeAll(reachable); // keep only the unreachable nodes
            for (AbstractSymbol class_name : keys){
                semantError(nameToClass.get(class_name)).println("Class "+class_name+" is not part of class tree");
            }
        }

        /* Make sure a Main class is defined */
        if (!nameToClass.containsKey(TreeConstants.Main)){
            errorStream.println("Class Main is not defined");
            /* continue if Main is the only error in class hiererchy */
        }

    }

    /* Find LUB for two class types */
    public AbstractSymbol findLeastUpperBound(AbstractSymbol s1, AbstractSymbol s2){

        /* No type is subtype of everything */
        if (s1.equals(TreeConstants.No_type))
            return s2;
        if (s2.equals(TreeConstants.No_type))
            return s1;
        /* LUB of SELF_TYPEs is SELF_TYPE */
        if (s1.equals(TreeConstants.SELF_TYPE) && s2.equals(TreeConstants.SELF_TYPE))
            return TreeConstants.SELF_TYPE;

        /* find LUB */
        AbstractSymbol curr = s1;
        if (s1.equals(TreeConstants.SELF_TYPE))
            curr = currClassName;
        List<AbstractSymbol> s1SuperTypes = new ArrayList<AbstractSymbol>();

        /* traverse up tree from s1 */
        while (!curr.equals(TreeConstants.No_class)){
            s1SuperTypes.add(curr);
            curr = nameToClass.get(curr).getParent();
        }

        curr = s2;
        if (s2.equals(TreeConstants.SELF_TYPE))
            curr = currClassName;
        while (!curr.equals(TreeConstants.No_class)){
            if (s1SuperTypes.contains(curr))
                /* always returns here */
                return curr;

            curr = nameToClass.get(curr).getParent();
        }

        errorStream.println("Should not reach this far");
        semantError();
        return null;
    }

    /* should have validated type existence before this point */
    public boolean isSubtype(AbstractSymbol type, AbstractSymbol subtype){
        
        /* No_type is subtype of everything */
        if (subtype.equals(TreeConstants.No_type))
            return true; 
        /* Handle SELF_TYPEs */
        if (type.equals(TreeConstants.SELF_TYPE) && subtype.equals(TreeConstants.SELF_TYPE))
            return true;
        if (type.equals(TreeConstants.SELF_TYPE) && !subtype.equals(TreeConstants.SELF_TYPE))
            return false;
        
        AbstractSymbol curr = subtype;
        if (subtype.equals(TreeConstants.SELF_TYPE))
            curr = currClassName;

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
        if (type.equals(TreeConstants.SELF_TYPE)) // TODO: think about this more
            return true;
        if (type.equals(TreeConstants.prim_slot))
            return true;
        return nameToClass.containsKey(type);
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

        /* Second traversal */
        stack.push(TreeConstants.Object_);
        while(!stack.isEmpty()){
            AbstractSymbol curr = stack.pop();
            class_c class_node = nameToClass.get(curr);

            /* Extract attribute and method type info */ 
            currClassName = curr;
            class_node.checkAttrAndMethodTypes(this); 

            if (inheritance.containsKey(curr))
                for (AbstractSymbol next : inheritance.get(curr)){
                    stack.push(next);
                }
        }

        dumpDebugInfo();
    }

    private void dumpDebugInfo(){
        if (!Flags.semant_debug) 
            return;

        // classToAttrMap, classToMethodMap
        for (AbstractSymbol class_name : nameToClass.keySet()){
           
            System.out.println("-----Class: "+class_name+" -----------"); 
            
            HashMap<AbstractSymbol, AbstractSymbol> attrToType = 
                    classToAttrMap.get(class_name);
            HashMap<AbstractSymbol, List> methodToSignature =
                    classToMethodMap.get(class_name);

            System.out.println("Printing attributes: ");
            System.out.println("=====================");
            for (AbstractSymbol attr : attrToType.keySet()){
                System.out.println(attr+": "+attrToType.get(attr));
            }
            System.out.println();

            System.out.println("Printing methods: ");
            System.out.println("=====================");
            for (AbstractSymbol method : methodToSignature.keySet()){
                System.out.print(method+": ");
                for (Object o : methodToSignature.get(method)){
                    AbstractSymbol type = (AbstractSymbol) o;
                    System.out.print(type + ", ");
                }
                System.out.print("\n");
            }
            System.out.println();
        }
        
    }

    /* Error reporting interface */
    public void reportError(TreeNode t, String errMsg){
        semantError(nameToClass.get(currClassName).getFilename(), t)
                   .println(errMsg);
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

