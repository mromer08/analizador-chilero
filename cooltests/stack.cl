class List {
   isNil() : Bool { true };
   head()  : String { { abort(); ""; } };

   tail()  : List { { abort(); self; } };
   cons(i : String) : List {
      (new Cons).init(i, self)
   };

};



class Cons inherits List {
   car : String;
   cdr : List;
   isNil() : Bool { false };
   head()  : String { car };
   tail()  : List { cdr };
   init(i : String, rest : List) : List {
      {
	 car <- i;
	 cdr <- rest;
	 self;
      }
   };

};


class StackComm inherits IO {
    init(s : String, l : List) : List {
        if s = "e" then new ExecuteComm.ex(l) else
        if s = "d" then { new DisplayComm.print_list(l); l; }
        else l.cons(s)
        fi fi
    };
};


class DisplayComm inherits StackComm {
    print_list(l : List) : Object {
      if l.isNil() then out_string("")
      else {
			out_string(l.head());
			out_string("\n");
			print_list(l.tail());
		}
      fi
   };
};

class ExecuteComm inherits StackComm {
    ex(l : List) : List {
        if l.isNil() then l else
        if l.head() = "+" then new SumComm.sum(l.tail()) else
        if l.head() = "s" then new SwitchComm.sw(l.tail()) else
        l
        fi fi fi
    };
};

class SumComm inherits StackComm {
    first : Int;
    second : Int;

    sum(l : List) : List { {
        first <- new A2I.a2i_aux(l.head());
        second <- new A2I.a2i_aux(l.tail().head());
        new Cons.init(new A2I.i2a_aux(first + second), l.tail().tail());
    }
    };
};

class SwitchComm inherits StackComm {
    first: String;
    second: String;

    sw(l: List) : List { {
        first <- l.head();
        second <- l.tail().head();
        new Cons.init(second, new Cons.init(first, l.tail().tail()));
    }
    };
};

class Main inherits IO {

   l : List;
   comm : String;

   main() : Object { {
    l <- new List;
    out_string(">");
    comm <- in_string();
    while ( not comm = "x" ) loop {
        l <- (new StackComm).init(comm, l);
        out_string(">");
        comm <- in_string();
        }
    pool;
   }
   };
};
