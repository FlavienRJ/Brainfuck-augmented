#define TAPE_SIZE 1024
#define STACK_SIZE 128
#define DATA_SIZE 65535

#define OP_END      0
#define OP_MRIGHT   1
#define OP_MLEFT    2
#define OP_ADD      3
#define OP_MINUS    4    
#define OP_OUTPUT   5
#define OP_INPUT    6
#define OP_LOOP     7
#define OP_END_LOOP 8

#define SUCCESS     0
#define FAILURE     1

//FLAGS
extern int visualisation;
extern int interpreter; 
extern int debug;
extern int file;