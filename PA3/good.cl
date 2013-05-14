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
};

class D inherits C {};

class E inherits C {};

class F inherits Int {};

class G inherits D {};

class H inherits IO {};

class I {};

Class Main {
	main():C {
	  (new C).init(1,true)
	};
};
