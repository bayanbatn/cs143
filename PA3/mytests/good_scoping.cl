
-- test scoping 
class C {
    a : Int;
    b : String;
    c : Int <- a; -- scoping within attr expression

    m1() : Int{
        c -- scoping within method
    };
    m2(x : Int) : Int{
        x + c + m1() -- both local and global (method and attr)
    };
    m3(y : Int) : Int{
        let z : Int <- 0 in z + m2(a) -- nested scoping 
    };
    m4(z1 : String) : Int{ 
        --multiple layer nesting + redef of var + redef within let statement
        let z1 : Int <- 1, z2 : Int <- 2 in 
            let z3 : String <- "three", z3 : Int <- 3 in
                z1 + z2 + z3 
    };
    m5(a : String) : String{
        a.concat(b)  -- redef of global var
    };
    -- nest let + case
    m6(y : Int) : Object{
        let z : Int <- 0 in 
            case 5+10 of
                b : Int => a+b+y+z; -- finds something in all scopes
                o : Object => o.copy();
                s : String => b; -- make sure scoping in b stays in branch
            esac
    };
};

class D inherits C {};

-- test scoping in inherited class
class E inherits D {
    d : Int <- let e:Int <- 5 in e+a; -- test scoping in nested case
    e : String <- m5(b);
    f : D <- let x:Int in new D;

    m1() : Int{
        c + d --both inherited and not
    };
    m7() : Int{
        f.m1() + a + c + d
    };
    m8(d : String) : Int{
        m1() + m7()
    };
    m9(a : String, d : String) : String{
        f.m5(e).concat(d).concat(b).concat(e)  -- redef of global var
    };
    -- nest let + case
    m10(a : String) : Object{
        let e : Int <- 0 in 
            case 5+10 of
                s : String => b; -- make sure scoping in b stays in branch
                a : Int => a+e+d+m1(); -- finds something in all scopes
                o : Object => f <- self; -- testing self scope
            esac
    };
    m11(y : Int) : Object{
        case "hi" of
            y : Int => y;
            y : String => let y : Int in y; -- multiple redef
            y : Object => y;
        esac
    };
};


class Main {
    main() : Object { new Object };
};

