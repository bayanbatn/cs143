
(*
 *  execute "coolc bad.cl" to see the error messages that the coolc parser
 *  generates
 *
 *  execute "parsetest < bad.cl" to see the error messages that your parser
 *  generates
 *)

(* no error *)
class A {
};

(* error:  b is not a type identifier *)
Class b inherits A {
};

(* error:  a is not a type identifier *)
Class C inherits a {
};

(* error:  keyword inherits is misspelled *)
Class D inherts A {
    i : Int <- 5;
    j : Int <- 5;
};

(* error: class key word is missing *)
E inherits A {
    i : Int <- 5;
    j : Int <- 5;
};

(* error test for features *)

(* error test for methods *)
class G {
    i : Int <- 5;
    X() : Int {5}; --X error handling not working
    j : Int <- 5;
    y() : x {5};
    k : Int <- 5;
    l : Int <- 5;
    y(x : Int, Z : Int) : Int {5};
    r : Int <- 5;
    t : Int <- 5;
    z(x : Int, Z) : Int {5};
    s : Int <- 5;
    q : Int <- 5;
    w(x : Int, y : Int) : x {5};
    m : Int <- 5;
    u(x : Int, y : Int) {5};
    n : Int <- 5;
    u(x : Int, y : Int) : Int 5};
    m : Int <- 5;
    u(x : Int, y : Int) : Int {5;
    n : Int <- 5;
    u(x : Int, y : Int) : Int ;
};


(* error test for attributes *)
class F {
    X : Int; --X not working for some reason
    i : Int <- 5;
    j : Int <- 5;
    y : x;
    k : Int <- 5;
    l : Int <- 5;
    z : Int 5+5;
    r : Int <- 5;
    t : Int <- 5;
    z : <- 5+5;
};


(* error test for let binding *)
class G {
     
    letBindingErrorTest(i8 : Int) : Int {
        {
        let I2 : Int <-2, i1 : Int <- 1, i3 : Int <- 3, I4 : Int <- 4 in
            i1+I2+i3+I4 ;
        let i1 : Int <- 1, , i2 : Int <- 2 in
            i1+i2;
        let i1 : x <- 1, i2 : Int <- 2 in
            i1+i2;
        let I1 : Int, i2 : Int <- 2 in
            I1+i2 ;
        let Int <- 2, i1 : Int <- 2 in
            i1 ;
        let in
            i8 ;
        }
    };
};


(* error test for block code *)
class H {
    
    blockErrorTest(i8 : Int) : Int {
        {
            {
                5+5;
                X <- 5;
                y <- 2;
            };

            {
            };

            {
                X < y;
            };

            {
                true;
                Int + String;
                1+1;
                {};
                let Int <- 2, i1 : Int <- 2 in
                    i1 ;
                "hi";
                5;
                i8;
            };

        }
    };
};

(* error:  closing brace is missing *)
Class E inherits A {
    i : Int <- 5;
    j : Int <- 5;
};



