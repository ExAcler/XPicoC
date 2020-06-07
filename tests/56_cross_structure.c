#include <stdio.h>

struct s1;

struct s2
{
    struct s1 *s;
    int *c;
    int a;
    int *b;
    int d;
};

struct s1
{
    struct s2 x;
    struct s2 *s;
};

void main()
{
    struct s1 ss;
    ss.x.a = (5 << 2) & 0b100;
    ss.x.d = ss.x.a + 1;
    ss.s = &ss.x;
    ss.x.c = &ss.x.a;
    ss.x.b = &ss.x.d;

    struct s1 sss = ss;

    printf("%d\n", *(sss.s->c));
    int *yy = *((int**)ss.x.c + 1);
    printf("%d\n", *yy);
}
