//CONSTANT
#define TAPE_SIZE       1024
#define STACK_SIZE      128
#define PROGRAM_SIZE    4096

#define OP_END          0
#define OP_MRIGHT       1
#define OP_MLEFT        2
#define OP_ADD          3
#define OP_MINUS        4    
#define OP_OUTPUT       5
#define OP_INPUT        6
#define OP_LOOP         7
#define OP_END_LOOP     8
#define OP_NEW_PROC     9
#define OP_END_PROC     10
#define OP_CALL_PROC    11

#define SUCCESS         0
#define FAILURE         1

//FLAGS
extern int visualisation;
extern int interpreter; 
extern int debug;
extern int file;

//STRUCT
typedef struct _instruction {
    unsigned short operator;
    unsigned short argument;
    char name;
} t_instruction;

typedef struct _fn_instruction {
    char name;
    unsigned short IC_begin;
    unsigned short size;
    t_instruction PROC_INSTR[128];
} t_fn_instruction;

//FUNCTIONS
void spush(int a);
int spop();
int sempty();
int sfull();

void init();
void mright();
void mleft();
void cadd();
void cminus();
void coutput();
void cinput();
void mloop();
void mloopend();
void newproc(char procname);
void endproc();
void callproc(char procname);
int findProcname(char procname);
void endprog();

int execute();
int executeInstr(t_instruction instr, int ic);
int executeproc(char procname);
void cleanprog();
void cleantape();