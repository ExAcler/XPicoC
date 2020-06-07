#include <stdio.h>

struct test {
    int ax;
    int *bx;
} tt;

int* aaa1()
{
    int aaa = 3512;
    return &aaa;
}

int x[2][2] = {{1,2},{3,4}};
int axx = 3;
int xxx = axx + 1;
int *xx = x[1];
    
/*printf("%d\n", *xx);*/
int prn;
prn = *(xx - 1);
prn = *xx;

int a;
int *b;
int c;
int ff[] = {135, 235, 3, 4, 5, 6, 7};
char *_ff = (char*)&ff[0];

/*
printf("a = %d\n", *_ff++);
printf("a = %d\n", *_ff++);
printf("a = %d\n", *_ff++);
printf("a = %d\n", *_ff++);
printf("a = %d\n", *_ff++);
printf("a = %d\n", *_ff++);
*/
prn = *_ff++;
prn = *_ff++;
prn = *_ff++;
prn = *_ff++;
prn = *_ff++;
prn = *_ff++;

float a1 = 3.14159265358979324;
unsigned char *b1 = (unsigned char*)&a1;
    
/*printf("%d %d %d %d %d %d %d %d\n", *b1++, *b1++, *b1++, *b1++, *b1++, *b1++, *b1++, *b1++);*/
prn = *b1++;
prn = *b1++;
prn = *b1++;
prn = *b1++;
prn = *b1++;
prn = *b1++;
prn = *b1++;
prn = *b1++;

a = 42;
b = &a;

int *p = aaa1();
/*printf("%d\n", *p);*/
prn = *p;

//unsigned int a1 = 1425634501;

int a2 = 4294967295;
/*printf("%d\n", a2);*/
prn = a2;

//char *dd = "\x61\x44";
char *dd = "hi there";
unsigned short kk;

kk = *(unsigned short*)&dd[0];
/*printf("kk = %d\n", kk);*/
prn = kk;

struct ziggy
{
    int a;
    int b;
    int c;
} bolshevic;

bolshevic.a = 2547;
bolshevic.b = 34;
bolshevic.c = 56;

/*
printf("bolshevic.a = %d\n", bolshevic.a);
printf("bolshevic.b = %d\n", bolshevic.b);
printf("bolshevic.c = %d\n", bolshevic.c);
*/
prn = bolshevic.a;
prn = bolshevic.b;
prn = bolshevic.c;

struct ziggy *tsar = &bolshevic;

/*
printf("tsar->a = %d\n", tsar->a);
printf("tsar->b = %d\n", tsar->b);
printf("tsar->c = %d\n", tsar->c);
*/
prn = tsar->a;
prn = tsar->b;
prn = tsar->c;

char *aaab = (char*)&bolshevic;
/*
printf("tsar->a = %d\n", *aaab++);
printf("tsar->b = %d\n", *aaab++);
printf("tsar->c = %d\n", *aaab++);
*/
prn = *aaab++;
prn = *aaab++;
prn = *aaab++;

/*
b = &(bolshevic.b);
printf("bolshevic.b = %d\n", *b);
*/

int *yyy[] = {&a, b, &c};

prn = *yyy[0];
prn = *yyy[1];
prn = *yyy[2];

struct z
{
    int a;
    int b;
    int c;
    int *yyy[3];
} bol;

bol.a = 3;
bol.b = 33;
bol.c = 333;
bol.yyy[0] = &a;
bol.yyy[1] = b;
bol.yyy[2] = &c;

int **yxx = bol.yyy;
*(*yxx++) = 4;
*(*yxx++) = 44;
*(*yxx++) = 444;

yxx = bol.yyy;
prn = *(*yxx++);
prn = *(*yxx++);
prn = *(*yxx++);
prn = a;
prn = c;

void main() {}
