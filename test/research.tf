# A comment
# _ to specify it's reserved word

#VARIABLES
{_int_:A <- 2} #Asignement 2 to int A
{2 -> _int_:A} #Why don't use the 2 way ?
{_float_:B <- 2.0}
{_string_:C <- "variable C"}
{_bool_:D <- _true_}
{_int[2]_:L <- [1,2,3]} #list of size 2 of int

#ARRAYS
{L[1] -> _out_} #get first element
{L[0]} #get all elements
{_size_ L} #get size of L

#INPUT/OUTPUT
{A <- _in_} #read value from input
{A -> _out_} #write value to out

#CONTROL STRUCTURES
# {_if_ {condition} {true} {false}}
{_if_ {A > 0} {B -> _out_} {_continue_}} 

# {_while_ {condition} {statement}}
{_while_ {A > 0} {{B + 1 -> B}{A <- A - 1}}}
# {_for_ {time} {statement}}
{_for_ {5} {C -> _out_}}

#FUNCTION
# {_fun_:function_name [list_arg] {statements}}
{_fun_:add1 _int[1]_:args {{args[1] + 1}}}
{{_int[1]_:Args <- [A]}{add1 Args}}