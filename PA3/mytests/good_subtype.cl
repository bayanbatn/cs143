
-- Tests good cases for subtyping and LUB

class A {};

class B {};

class C inherits A {};

class D inherits C {};

class E inherits C {};

class F inherits B {};

class G inherits B {};

class Test inherits F {
    a : A <- d;
    b : B;
    c : C;
    d : D;
    e : E;
    f : F <- new SELF_TYPE;

    m1() : A { c };
    m2() : A { new D};
    m3() : Object { d };

    m4(x : A) : Int {
        {
            x<-e;
            0;
        }
    };
    m5() : A {
        let x : A<-e in x<-d
    };
    m6() : A {
        case e of
            x : E => x;
            x : D => x;
        esac
    };
    m7() : Object {
        case e of
            x : E => x;
            x : B => x;
        esac
    };
    m8() : Object {
        if true then
            e
        else
            f
        fi
    };
    m9() : Object {
        if true then
            e
        else 
            if true then
                c
            else
                a
            fi 
        fi
    };
    m10() : SELF_TYPE {
        case e of
            x : E => self;
            x : B => new SELF_TYPE;
        esac
    };
    m11() : F {
        case new SELF_TYPE of
            x : Test => self;
            x : B => new SELF_TYPE;
            x : F => new Test;
        esac
    };
    m12() : Object {
        if true then
            new SELF_TYPE
        else
            self 
        fi
    };
    m13() : Object {
        if true then
            new Test
        else 
            if true then
                new SELF_TYPE
            else
                self
            fi 
        fi
    };
    m14() : B {
        if true then
            self 
        else
            new G 
        fi
    };
};

class Main { 
    main() : Object { new Object };    
};
