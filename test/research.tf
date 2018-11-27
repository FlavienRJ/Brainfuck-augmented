# A comment
# * to specify it's reserved word

#VARIABLES
{*int:A <- 2} #Asignement 2 to int A
{2 -> *int:A} #Why don't use the 2 way ?
{*float:B <- 2.0}
{*string:C <- "variable C"}
{*bool:D <- _true_}
{*int[2]:L <- [1,2,3]} #list of size 2 of int

#ARRAYS
{L[1] -> *out} #get first element
{L[0]} #get all elements
{*size L} #get size of L

#INPUT/OUTPUT
{A <- *in} #read value from input
{A -> *out} #write value to out

#CONTROL STRUCTURES
# {*if {condition} {true} {false}}
{*if {A > 0} {B -> *out} {*continue}} 

# {*while {condition} {statement}}
{*while {A > 0} {{B + 1 -> B}{A <- A - 1}}}
# {*for {time} {statement}}
{*for {5} {C -> *out}}

#FUNCTION
# {*fun:function_name [list_arg] {statements}}
{*fun:add1 *int[1]:args {{args[1] + 1}}}
{{*int[1]:Args <- [A]}{add1 Args}}