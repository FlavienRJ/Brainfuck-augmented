flex simplang.l &&\
bison -d simplang.y &&\
gcc *.c -o simplang &&\
./simplang test2.lang