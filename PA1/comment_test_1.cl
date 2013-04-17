(* comment in the beginning *)
class CommentTest inherits IO {
    (* multi line comment in the middle 
     * second line
     * "including string shouldn't matter
     * "adfjkjkjkj
     * (* testing nested comments *)
     *)

    (* we will test comments here by making
     * lots of nested comments (*(*
     * and seeing if we can pass it *) if all
     * is well, -- it shouldn't matter how this
     * comment is formatted *) 
     *)

    -- line comment
    *) --unmatched comment
    population_map : String; --another line comment
   
    init(map : String) : SELF_TYPE {
        {
            population_map <- map;
            self;
        }
    };
    (* uninclosed comment
       what to do?

    
}

(* comment in the end *)

(* EOF in comment ?
