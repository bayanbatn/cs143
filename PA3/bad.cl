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

-- bad: unreachable classes

class I inherits J {};
class J inherits K {};
class K inherits I {};


-- bad: duplicate name
-- class Object {};
-- class D {};

Class Main {
	main():C {
	 {
	  (new C).init(1,1);
	  (new C).init(1,true,3);
	  (new C).iinit(1,true);
	  (new C);
	 }
	};
};
