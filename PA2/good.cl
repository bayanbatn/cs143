(* comments! 
 * TODO: test case statement
 * TODO: test let statements
 *)

class A inherits IO {

s1 : String;
s2 : String <- "asdfds";
idx : Int <- 5;
-- i : Int <- 0;

initClassA(str1 : String, str2 : String) : SELF_TYPE {
    { 
        s1 <- str1;
        s2 <- str2;
        idx <- 0;
        self;
    }
};

-- dummy method, always returns 1
getOne() : Int {
    let i : Int in
    { 
        i  <- 0;
        if true then
            i <- 1
        else
            i <- 5
        fi;
        i;
    }
};

printInputString(b : Bool) : SELF_TYPE {
    if not b then 
    {
        out_string("nothing to print");
        self;
    }
    else
    {
        out_string("first string is: ").out_string(s1).out_string("\n");
        out_string("second string is: ").out_string(s2).out_string("\n");
        self;
    }
    fi
};

(*
t1 : Int;
t2 : Int;
t3 : Int;
*)

arithmaticTest(x : Int, y : Int, z : Int, b : Bool) : SELF_TYPE {
    let t1 : Int <- 0, t2 : Int, t3 : Int <- ~1 in
    {
        t1 <- (x+y)*z;
        t2 <- (~5*(z + x*z) + ~(y/z + 143)*x);
        out_string("first int: ").out_int(t1).out_string("\n");
        out_string("second int: ").out_int(t2).out_string("\n");

        if not (x=y) then
            out_string("x is not equal to y\n")
        else
            out_string("")
        fi;
    
        if x<y then
            out_string("x is less than y\n")
        else
            out_string("")
        fi;

        if x<=y then
            out_string("x is less than or equal to y\n")
        else
            out_string("")
        fi;

        if isvoid t3 then
            out_string("t3 is void\n")
        else
            out_string("")
        fi;
    }
};

letAmbiguityTest() : SELF_TYPE {
    { 
    idx <- let i1 : Int <- 0 in
             let i2 : Int <- 5, i3 : Int <- 10, i4 : Int <- ~10 in
               --should throw error if using wrong precedence
               i2 + i1 * 5 + i3 + i4; 
    out_int(idx);
    }
};

myType : String;

caseTest() : SELF_TYPE {
    {
    myType <- case self of
        a : A => a.selfTypeDeclare();
        b : B => b.selfTypeDeclare();
        o : Object => "unknown type detected";
    esac;
    out_string(myType).out_string("\n");
    }
};

selfTypeDeclare() : String {
    "I am type A"
};

}; -- class end braces

Class B inherits A {

-- override dummy method, always returns 2 now
getOne() : Int {
    2
};

-- override type declare method
selfTypeDeclare() : String {
    "I am type B now"
};

printSubstrings() : SELF_TYPE {
    { 
        while idx < s1.length() loop
        {
            idx <- idx + self@A.getOne(); -- increment by 1
            out_string("substr is: ").out_string(s1.substr(0, idx)).out_string("\n");
        }
        pool;
        out_string("and done! \n");
        self;
    }
};

};

Class Main {

    b : B;

    main() : Object {
        {
        b <- new B;
        b.initClassA("test_string_1", "test_string_2");
        b.arithmaticTest(1000, 100, 10, true);
        b.printSubstrings();
        }
    };

};


