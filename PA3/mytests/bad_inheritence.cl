

-- cycle
class C inherits E {};
class D inherits C {};
class E inherits D {};

-- inherit from SELF_TYPE
class F inherits SELF_TYPE {};

-- inherits from undefined class type
class G inherits H {};

-- inherits from uninheritable classes
class I inherits Int {};
class J inherits String {};
class K inherits Bool {};

-- multiple class def
class X {};
class X {};

-- overriding basic def
class Object {};
class Int {};
class IO {};
class String {};
class Bool {};
class SELF_TYPE {};

-- self inheritence?
class Y inherits Y {}; -- apparently this is okay

-- class Main is not defined (commented out)
--class Main {};
