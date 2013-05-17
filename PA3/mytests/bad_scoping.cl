

class C {
    a : Int;
    b : String;
    c : Int <- d; -- undefined
    --a : String;

    m1() : Int{
        d
    };
    m2(x : Int) : Int {
        x -- undeclared var in formal
    };
    m3() : Int{
        {
            let x : Int in x;
            x; -- refering to variable outside of its scope
        }
    };
    m4(y : Int ) : Int{
        let y : String <- "zero" in m1() + y -- nested scoping, referring to wrong var
    };
    m5(y : Int) : Int{
        case "hi" of
            y : Int => y;
            y : String => y;
            y : Object => y;
        esac
    };
    m6(y : Int) : Int{
        case "hi" of
            y : Int => y;
            y : String => let y : Int, y : String in y; -- multiple redef
            y : Object => y;
        esac
    };
};

class D inherits C {
    b : Int <- a+c; --redef of attribute
    --c : String; -- redef without type change
    d : Int;
    e : String;
    f : C;

    m1() : String{ --redef global method
        e
    };
    m2(a : SELF_TYPE) : SELF_TYPE{ -- formal param can't be self_type
        a
    };

};

