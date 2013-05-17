

-- Tests bad cases for subtyping and LUB

class A {};

class B {};

class C inherits A {};

class D inherits C {};

class E inherits C {};

class F inherits B {};

class Test inherits F {
    a : A <- b;
    b : B;
    c : C;
    d : D;
    e : E;
    f : F;

    m1() : A { b };
    m2() : D { new E};
    m3() : B { new E };

    m4(x : C) : Int {
        {
            x<-a;
            0;
        }
    };
    m5() : A {
        let x : F<-e in x<-b
    };
    m6() : A {
        case e of
            x : A => x;
            x : B => x;
        esac
    };
    m7() : C {
        case e of
            x : E => x;
            x : F => x;
        esac
    };
    m8() : SELF_TYPE {
        if true then
            self
        else
            new Test
        fi
    };
};

class Main { 
    main() : Object { new Object };    
};
