
(* ALREADY PROVIDED *)

(* models one-dimensional cellular automaton on a circle of finite radius
   arrays are faked as Strings,
   X's respresent live cells, dots represent dead cells,
   no error checking is done *)
class CellularAutomaton inherits IO {
    population_map : String;
   
    init(map : String) : SELF_TYPE {
        {
            population_map <- map;
            self;
        }
    };
   
    print() : SELF_TYPE {
        {
            out_string(population_map.concat("\n"));
            self;
        }
    };
   
    num_cells() : Int {
        population_map.length()
    };
   
    cell(position : Int) : String {
        population_map.substr(position, 1)
    };
   
    cell_left_neighbor(position : Int) : String {
        if position = 0 then
            cell(num_cells() - 1)
        else
            cell(position - 1)
        fi
    };
   
    cell_right_neighbor(position : Int) : String {
        if position = num_cells() - 1 then
            cell(0)
        else
            cell(position + 1)
        fi
    };
   
    (* a cell will live if exactly 1 of itself and it's immediate
       neighbors are alive *)
    cell_at_next_evolution(position : Int) : String {
        if (if cell(position) = "X" then 1 else 0 fi
            + if cell_left_neighbor(position) = "X" then 1 else 0 fi
            + if cell_right_neighbor(position) = "X" then 1 else 0 fi
            = 1)
        then
            "X"
        else
            '.'
        fi
    };
   
    evolve() : SELF_TYPE {
        (let position : Int in
        (let num : Int <- num_cells[] in
        (let temp : String in
            {
                while position < num loop
                    {
                        temp <- temp.concat(cell_at_next_evolution(position));
                        position <- position + 1;
                    }
                pool;
                population_map <- temp;
                self;
            }
        ) ) )
    };
};

class Main {
    cells   :   CellularAutomaton; --testing tabs here
   
    main() : SELF_TYPE {
        {
            cells   <-  (new CellularAutomaton).init("         X         ");
            cells.print();
            (let countdown : Int <- 20 in
                while countdown > 0 loop
                    {
                        cells.evolve();
                        cells.print();
                        countdown <- countdown - 1;
                    
                pool
            );  
            self;
        }
    };
};

class Main inherits IO {
    pal(s : String) : Bool {
	if s.length() = 0
	then true
	else if s.length() = 1
	then true
	else if s.substr(0, 1) = s.substr(s.length() - 1, 1)
	then pal(s.substr(1, s.length() -2))
	else false
	fi fi fi
    };

    i : Int;

    main() : SELF_TYPE {
	{
            i <- ~1;
	    out_string("enter a string\n");
	    if pal(in_string())
	    then out_string("that was a palindrome\n")
	    else out_string("that was not a palindrome\n")
	    fi;
	}
    };
};


(* FOR TESTING KEYWORDS *)
cLass ELSE fALSE Fi IF in inherits
isvoid let loop pool then while esac case
new of not True true


(* FOR TESTING SYMBOLS *)
+ / - * = < . ~ , ; 
: ( ) @ { } 
<-   =>

(* RANDOM TESTING *)
2fdsf  asdf3dfd QEWR2 askdjf_?234

(* FOR TESTING COMMENTS *)
(* comment in the beginning *)
class CommentTest inherits IO {
    (* multi line comment in the middle 
     * second line
     * "including string shouldn't matter
     * "adfjkjkjkj
     * (* testing nested comments *)
     *)

    (* we will test comments here by making
     * lots of nested comments (*(*
     * and seeing if we can pass it *) if all
     * is well, -- it shouldn't matter how this
     * comment is formatted *) 
     *)

    -- line comment
    *) --unmatched comment
    population_map : String; --another line comment
   
    init(map : String) : SELF_TYPE {
        {
            population_map <- map;
            self;
        }
    };
    (* uninclosed comment
       what to do?

    
}

(* comment in the end *)

(* EOF in comment ? *)




(* FOR TESTING STRING 
 * Also used separate files to do EOF error handling tests for
 * both comments and strings 
 *)

class StringConstTest {

    test5 : String <- "this \ string has null \0";
    test6 : String <- "testing escape: \a \c \b \\";
    test7 : String <- "testing tab: \t. After tab.";
    test8 : String <- "length exceeds max                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               ";
    test8 : String <- "length doesn't exceed max                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ";
}

class StringConstTest {

    test1 : String <- "this is normal string test";
    test2 : String <- "this string has\n newline";
    test3 : String <- "this string has escaped\
                newline";
    test4 : String <- "this string has unescaped
                newline";
}

class StringConstTest {

    test9 : String <- "null char:  ";
    test10: String <- "unterminated string
    other_stuff : String;
    position : Int <- 5;
}
