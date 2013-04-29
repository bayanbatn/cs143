
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


(* error test for attributes *)
class F {
    X : Int;
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

(* error test for methods *)
class G {
    X() : Int {5};
    i : Int <- 5;
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


(* error:  closing brace is missing *)
Class E inherits A {
    i : Int <- 5;
    j : Int <- 5;
;



