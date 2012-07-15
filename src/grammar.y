%{
  #include <stdio.h>
  #include "src/nodes.h"

  #define YYDEBUG 1
  #define P(x)  print_node(x, false, 0)
  #define PR(x) print_node(x, true, 0)
  #define O(s)  puts(s)

  void yyerror(char *);
  int yylex(void);
  int yydebug;
  FILE *yyin;
  struct JLNode *root;
%}

%error-verbose

/* LITERALS */

%token<floatval> FLOAT
%token<intval> INTEGER
%token<val> IDENT STRING TRUE FALSE


/* OPERATORS */

/* Boolean */
%token<val> AND OR
/* Unary */
%token<val> PLUSPLUS MINUSMINUS
/* Relational */
%token<val> EQEQ GTE LTE NE
/* Bitwise */
%token<val> LSHIFT RSHIFT
/* Assignment */
%token<val> PLUSEQ MINUSEQ MULTEQ DIVEQ MODEQ


/* KEYWORDS */

/* Iteration */
%token<val> WHILE DO FOR
/* Branch */
%token<val> IF ELSE
/* Control */
%token<val> BREAK CONTINUE RETURN
/* Misc */
%token<val> VAR THIS NULLT


/* ASSOCIATIVITY */

%left '+' '-' '*' '%' AND OR

%union {
  char * val;
  int intval;
  double floatval;
  struct JLNode * node;
}

%type<val> AssignmentOperator 
%type<node> Program Statement Block VariableStatement EmptyStatement ExpressionStatement 
IfStatement IterationStatement ContinueStatement BreakStatement ReturnStatement
Literal NumericLiteral BooleanLiteral StringLiteral NullLiteral ArrayLiteral Identifier
Expression PrimaryExpression LeftHandSideExpression UnaryExpression 
PostfixExpression ShiftExpression RelationalExpression AdditiveExpression EqualityExpression
BitwiseANDExpression BitwiseORExpression BitwiseXORExpression LogicalORExpression
LogicalANDExpression MultiplicativeExpression ConditionalExpression StatementList
AssignmentExpression ElementList

%%

Program:
    Statement                                         { root = $1; }
    ;

Statement:
    Block                                             { $$ = $1; }
    | VariableStatement                               { $$ = $1; }
    | EmptyStatement                                  { $$ = $1; }
    | ExpressionStatement                             { $$ = $1; }
    | IfStatement                                     { $$ = $1; }
    | IterationStatement                              { $$ = $1; }
    | ContinueStatement                               { $$ = $1; }
    | BreakStatement                                  { $$ = $1; }
    | ReturnStatement                                 { $$ = $1; }
    ;

Block:
    '{' StatementList '}'                             { $$ = NEW_BLOCK($2); }
    ;

StatementList:
    Statement                                         { $$ = NEW_STMTLST($1, NULL); } 
    | StatementList Statement                         { $$ = NEW_STMTLST($2, $1); }
    ;

VariableStatement:
    VAR Identifier ';'                                { $$ = NEW_VARSTMT($2); }
    ;

EmptyStatement:
    ';'                                               { $$ = NEW_EMPTSTMT(); }
    ;

ExpressionStatement:
    Expression ';'                                    { $$ = NEW_EXPSTMT($1); }
    ;

IfStatement:
    IF '(' Expression ')' Statement ELSE Statement    { $$ = NEW_IF($3, $5, $7); }
    | IF '(' Expression ')' Statement                 { $$ = NEW_IF($3, $5, NULL); }
    ;

IterationStatement:
    DO Statement WHILE '(' Expression ')'                               { $$ = NEW_DOWHILE($2, $5); }
    | WHILE '(' Expression ')' Statement                                { $$ = NEW_WHILE($3, $5); }
    | FOR '(' Expression ';' Expression ';' Expression ')' Statement    { $$ = NEW_FOR($3, $5, $7); }
    ;

ContinueStatement:
    CONTINUE ';'                       { $$ = NEW_CONT(); }
    ;

BreakStatement:
    BREAK ';'                          { $$ = NEW_BREAK(); }
    ;

ReturnStatement:
    RETURN ';'                         { $$ = NEW_RETURN(NULL); }
    | RETURN Expression ';'            { $$ = NEW_RETURN($2); }
    ;

Literal:
    NullLiteral                        { $$ = $1; }
    | BooleanLiteral                   { $$ = $1; }
    | NumericLiteral                   { $$ = $1; }
    | StringLiteral                    { $$ = $1; }
    ;

ArrayLiteral:
    '[' Elision ']'                    { $$ = NEW_ARR(); }
    | '[' ElementList ']'              { $$ = NEW_ARR(); }
    | '[' ElementList ',' Elision ']'  { $$ = NEW_ARR(); }
    ;

ElementList:
    | Elision AssignmentExpression                  { $$ = NEW_ARR(); }
    | ElementList ',' Elision AssignmentExpression  { $$ = NEW_ARR(); }
    ;

Elision:
    ','
    | Elision ','
    ;

BooleanLiteral:
    TRUE                  { $$ = NEW_BOOL(1); }
    | FALSE               { $$ = NEW_BOOL(0); }
    ;

StringLiteral:
    STRING                { $$ = NEW_STR($1); }
    ;

NullLiteral:
    NULLT                 { $$ = NEW_NULL(); }
    ;

NumericLiteral:
    INTEGER               { $$ = NEW_NUM((double)$1); }
    | FLOAT               { $$ = NEW_NUM($1); }
    ;

Identifier:
    IDENT                 { $$ = NEW_IDENT($1); }
    ;

PrimaryExpression:
    THIS                  { $$ = NEW_THIS(); }
    | Identifier          { $$ = $1; }
    | Literal             { $$ = $1; }
    | ArrayLiteral        { $$ = $1; }
    | '(' Expression ')'  { $$ = $2; }
    ;

ConditionalExpression:
    LogicalORExpression                                  { $$ = $1; }
    ;

LogicalORExpression:
    LogicalANDExpression                                 { $$ = $1; }
    | LogicalORExpression OR LogicalANDExpression        { $$ = NEW_EXP($1, $3, $2); }
    ;

LogicalANDExpression:
    BitwiseORExpression                                  { $$ = $1; }
    | LogicalANDExpression AND BitwiseORExpression       { $$ = NEW_EXP($1, $3, $2); }
    ;

BitwiseORExpression:
    BitwiseXORExpression                                 { $$ = $1; }
    | BitwiseORExpression '|' BitwiseXORExpression       { $$ = NEW_EXP($1, $3, "|"); }
    ;

BitwiseXORExpression:
    BitwiseANDExpression                                 { $$ = $1; }
    | BitwiseXORExpression '^' BitwiseANDExpression      { $$ = NEW_EXP($1, $3, "^"); }
    ;

BitwiseANDExpression:
    EqualityExpression                                   { $$ = $1; }
    | BitwiseANDExpression '&' EqualityExpression        { $$ = NEW_EXP($1, $3, "&"); }
    ;

EqualityExpression:
    RelationalExpression                                 { $$ = $1; }
    | EqualityExpression EQEQ RelationalExpression       { $$ = NEW_EXP($1, $3, $2); }
    | EqualityExpression NE RelationalExpression         { $$ = NEW_EXP($1, $3, $2); }
    ;

RelationalExpression: 
    ShiftExpression                                      { $$ = $1; }
    | RelationalExpression '<' ShiftExpression           { $$ = NEW_EXP($1, $3, "<"); }
    | RelationalExpression '>' ShiftExpression           { $$ = NEW_EXP($1, $3, ">"); }
    | RelationalExpression LTE ShiftExpression           { $$ = NEW_EXP($1, $3, $2); }
    | RelationalExpression GTE ShiftExpression           { $$ = NEW_EXP($1, $3, $2); }

ShiftExpression:
    AdditiveExpression                                   { $$ = $1; }
    | ShiftExpression LSHIFT AdditiveExpression          { $$ = NEW_EXP($1, $3, $2); }
    | ShiftExpression RSHIFT AdditiveExpression          { $$ = NEW_EXP($1, $3, $2); }
    ;

AdditiveExpression:
    MultiplicativeExpression                             { $$ = $1; }
    | AdditiveExpression '+' MultiplicativeExpression    { $$ = NEW_EXP($1, $3, "+"); }
    | AdditiveExpression '-' MultiplicativeExpression    { $$ = NEW_EXP($1, $3, "-"); }
    ;

MultiplicativeExpression:
    UnaryExpression                                      { $$ = $1; }
    | MultiplicativeExpression '*' UnaryExpression       { $$ = NEW_EXP($1, $3, "*"); }
    | MultiplicativeExpression '/' UnaryExpression       { $$ = NEW_EXP($1, $3, "/"); }
    | MultiplicativeExpression '%' UnaryExpression       { $$ = NEW_EXP($1, $3, "%"); }
    ;

UnaryExpression:
    PostfixExpression                                    { $$ = $1; }
    | PLUSPLUS UnaryExpression                           { $$ = NEW_UNEXP($2, $1); }
    | MINUSMINUS UnaryExpression                         { $$ = NEW_UNEXP($2, $1); }
    | '+' UnaryExpression                                { $$ = NEW_UNEXP($2, "+"); }
    | '-' UnaryExpression                                { $$ = NEW_UNEXP($2, "-"); }
    | '!' UnaryExpression                                { $$ = NEW_UNEXP($2, "!"); }
    ;

PostfixExpression:
    LeftHandSideExpression                               { $$ = $1; }
    | LeftHandSideExpression PLUSPLUS                    { $$ = NEW_UNEXP($1, $2); }
    | LeftHandSideExpression MINUSMINUS                  { $$ = NEW_UNEXP($1, $2); }
    ;

Expression:
    AssignmentExpression                                 { $$ = $1; }
    | Expression ',' AssignmentExpression                { $$ = NEW_ASGN($1, $3, 0); }
    ;

AssignmentExpression:
    ConditionalExpression                                                 { $$ = $1; }
    | LeftHandSideExpression '=' AssignmentExpression                     { $$ = NEW_ASGN($1, $3, "="); }
    | LeftHandSideExpression AssignmentOperator AssignmentExpression      { $$ = NEW_ASGN($1, $3, $2); }
    ;

AssignmentOperator:
    PLUSEQ               { $$ = $1; }
    | MINUSEQ            { $$ = $1; }
    | MULTEQ             { $$ = $1; }
    | DIVEQ              { $$ = $1; }
    | MODEQ              { $$ = $1; }
    ;

LeftHandSideExpression:
    PrimaryExpression /* Ridiculously incomplete */      { $$ = $1; }
    ;

%%

void 
yyerror(char *s) 
{
  fprintf(stderr, "%s haha\n", s);
}

int 
main(int argc, char *argv[]) 
{
  yydebug = 1;

  yyin = argc > 0 ? fopen(argv[1], "r") : stdin;
  if (!yyin) return 1;

  puts("Parsing...");
  yyparse();
  puts("Done parsing.\n");

  puts("Parse tree:");
  puts("-----------------------------------------------");
  PR(root);

  return 0;
}
