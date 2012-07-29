// jslite.h

#ifndef JSLITE_H
#define JSLITE_H

#include "../ext/uthash.h"
#include <stdlib.h>
#include <stdio.h>

typedef int bool;
#define true 1
#define false 0

#define STREQ(a,b)  (strcmp((a),(b)) == 0)

typedef enum JLTYPE {
  T_NUMBER,
  T_STRING,
  T_BOOLEAN,
  T_OBJECT,
  T_NULL,
  T_UNDEF
} JLTYPE;

typedef struct JLARGS {
  void *args;
} JLARGS;

typedef void (*JLNATVFUNC)(JLARGS*); 

typedef struct JLPROP {
  char *name;
  bool writable;
  bool enumerable;
  bool configurable;
  void *ptr;
  UT_hash_handle hh;
} JLPROP;

struct JLNumber {
  double val;
  bool is_nan;
  bool is_inf;
};

struct JLString {
  long len;
  char *ptr;
};

struct JLBoolean {
  bool val;
};

struct JLArray {
  long len;
  void *ptr;
};

struct JLObject {
  void *proto;
  JLPROP *map;
};

struct JLFunction {
  bool is_native;
  void *func_body;
  JLNATVFUNC *native;
};

typedef struct JLVALUE {
  union {
    struct JLNumber number;
    struct JLString string;
    struct JLArray array;
    struct JLBoolean boolean;
    struct JLObject object;
  };
  JLTYPE type;
} JLVALUE;

struct JLVariable {
  const char *name;
  JLVALUE *ptr;
  UT_hash_handle hh;
};

JLPROP * jl_lookup(JLVALUE *, char *);
void jl_gc(void);

JLVALUE * jl_alloc_val();
JLVALUE * jl_new_val(JLTYPE);
JLVALUE * jl_new_number(double, bool, bool);
JLVALUE * jl_new_string(char *);
JLVALUE * jl_new_boolean(bool);
JLVALUE * jl_new_object();

JLVALUE * jl_cast(JLVALUE *, JLTYPE);
char * jl_typeof(JLVALUE *);
char * jl_str_concat(char *, char *);
void jl_debug_value(JLVALUE *);

void jl_assign(JLVALUE *, char *, JLVALUE *);
void jl_assign_natv_func(JLVALUE *, char *, JLNATVFUNC *);

#define JLCAST(x, t) jl_cast((x), (t))
#define JLBOOL(x) jl_new_boolean((x))
#define JLSTR(x)  jl_new_string((x))
#define JLNULL()  jl_new_val(T_NULL)
#define JLUNDEF() jl_new_val(T_UNDEF)
#define JLNUM(x)  jl_new_number((x),0,0)
#define JLNAN()   jl_new_number(0,1,0)
#define JLINF()   jl_new_number(0,0,1)
#define JLOBJ()   jl_new_object()

#endif
