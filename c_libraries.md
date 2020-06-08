### ctype.h

```C
int isalnum(int);
int isalpha(int);
int isblank(int);
int iscntrl(int);
int isdigit(int);
int isgraph(int);
int islower(int);
int isprint(int);
int ispunct(int);
int isspace(int);
int isupper(int);
int isxdigit(int);
int tolower(int);
int toupper(int);
int isascii(int);
int toascii(int);
```

### errno.h

Not implemented

### math.h

```C
float acos(float);
float asin(float);
float atan(float);
float atan2(float, float);
float ceil(float);
float cos(float);
float cosh(float);
float exp(float);
float fabs(float);
float floor(float);
float fmod(float, float);
float frexp(float, int *);
float ldexp(float, int);
float log(float);
float log10(float);
float modf(float, float *);
float pow(float,float);
float round(float);
float sin(float);
float sinh(float);
float sqrt(float);
float tan(float);
float tanh(float);
```

### stdbool.h

The type bool, and values true and false are globally defined.

### stdio.h

```C
int printf(char *, ...);
```

### stdlib.h

```C
float atof(char *);
float strtod(char *,char **);
int atoi(char *);
int atol(char *);
int strtol(char *,char **,int);
int strtoul(char *,char **,int);
void *malloc(int);
void *calloc(int,int);
void *realloc(void *,int);
void free(void *);
int rand();
void abort();
void exit(int);
int abs(int);
int labs(int);
```

Notes:

1. Parameter *base* of strtol() and strtoul() is currently ignored and these functions only support conversion of base-10 numbers by now.
2. There is no way to actually free a memory block created by malloc() or calloc(); free() is equal to realloc(*ptr*, 0). Use these dynamic memory allocation functions with caution.
3. srand() is not supported because it may interfere with the random number generator used by the variable memory system; The random number generator is automatically seeded by the current system counter on startup.

### string.h

```C
void *memcpy(void *,void *,int);
void *memmove(void *,void *,int);
void *memchr(char *,int,int);
int memcmp(void *,void *,int);
void *memset(void *,int,int);
char *strcat(char *,char *);
char *strncat(char *,char *,int);
char *strchr(char *,int);
char *strrchr(char *,int);
int strcmp(char *,char *);
int strncmp(char *,char *,int);
char *strcpy(char *,char *);
char *strncpy(char *,char *,int);
int strlen(char *);
int strspn(char *,char *);
int strcspn(char *,char *);
char *strpbrk(char *,char *);
char *strstr(char *,char *);
char *strtok(char *,char *);
```

### time.h

Not implemented

### unistd.h

Not implemented