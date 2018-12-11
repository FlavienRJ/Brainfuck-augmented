//CONSTANTE
typedef struct _constNode{
	int value;
} t_constNode;

//OPERATIONS
typedef struct _opNode{
	int type;
	int n;
	struct _node **operands;
} t_opNode;

//VARIABLE
typedef struct _varNode{
	int value;
	char *name;
} t_varNode;

//BLOCK OF STATEMENT
typedef struct _blockNode{
	int n; //number of statements
	struct _node **statements;
} t_blockNode;

//STRING
typedef struct _stringNode{
	char *s;
} t_stringNode;

//FLOAT
typedef struct _floatNode{
	float f;
} t_floatNode;

//INT
typedef struct _intNode{
	int i;
} t_intNode;

typedef enum {tConst, tOp, tVar, tBlock, tString, tFloat, tInt} t_nodeType;

typedef struct _node{
	t_nodeType type;
	union{
		t_constNode con;
		t_opNode op;
		t_varNode *var;
		t_blockNode block;
		t_stringNode str;	};
} t_node;

t_varNode *findVar(char*);
