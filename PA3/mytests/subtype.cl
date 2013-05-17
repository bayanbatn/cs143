


class A {};

class B {};

class C inherits A {};

class D inherits C {};

class E inherits C {};

class F inherits B {};

class Test {
    a : A <- d;
    b : B;
    c : C;
    d : D;
    e : E;
    f : F;

    m1() : A { c };
    m2() : A { new D};
    m3() : Object { d };

    m4(x : A) : Int {
        {
            x<-e;
            0;
        }
    }
    m5() : A {
        let x : A<-e in x<-d
    }
    m6() : A {
        case e of
            x : E => x;
            x : D => x;
        esac
    }
    m7() : Object {
        case e of
            x : E => x;
            x : B => x;
        esac
    }
    m8() : Object {
        if true then
            e
        else
            f
        fi
    }
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
    }
};

class Main { };
