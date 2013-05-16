
class C {
	a : Int;
	b : Bool;
	init(x : Int, y : Bool) : C {
           {
		a <- x;
		b <- y;
		self;
           }
	};
        foo () : Int {
            a
        };
        bar () : SELF_TYPE {
            self
        };
};

class D inherits C {
    c : Int <- 5;
    myfunc () : Int {
        foo() + c
    };
    bar () : SELF_TYPE{
        copy()
    };
};

class E inherits C {};

class F inherits C {};

class G inherits D {};

class H inherits IO {
    a : Int;
    b : String;

    foo () : String {
:       in_string()
    };
};

class I {};

Class Main {
	main():C {
	  (new C).init(1,true)
	};
};
