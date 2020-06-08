#include <stdio.h>
#include <string.h>

struct str
{
    int a;
    char str1[20];
    int b;
    char str2[20];
    int c;
} s;

s.a = 1;
s.b = 2;
s.c = 3;

memset(s.str1, 'q', sizeof(s.str1));
printf("%s\n", s.str1);
strcpy(s.str1, "hello");
printf("%s\n", s.str1);

memset(s.str2, 'w', sizeof(s.str1));
strncpy(s.str2, s.str1, 7);
printf("%s\n", s.str2);
printf("%d %d %d\n", s.a, s.b, s.c);

strncpy(s.str2, "hgosh", 2);
printf("%s\n", s.str2);

printf("%d\n", strcmp(s.str1, "apple") > 0);
printf("%d\n", strcmp(s.str1, "goere") > 0);
printf("%d\n", strcmp(s.str1, "zebra") < 0);
printf("%d\n", strncmp(s.str2, s.str1, 1));

printf("%d\n", strlen(s.str1));

printf("%d\n", s.str2[6]);

strcat(s.str2, s.str1);
printf("%s\n", s.str2);

int i;
char strtext[] = "129th";
char cset[] = "1234567890";

i = strspn (strtext,cset);
printf ("The initial number has %d digits.\n",i);

char str[] = "fcba73";
char keys[] = "1234567890";
i = strcspn (str,keys);
printf ("The first number in str is at position %d.\n",i+1);
char *strp = str;
char *p = strpbrk(str, keys);
printf("%s %s\n", p, strp);
char *p2 = strstr(str, "ba");
printf("%s\n", p2);

char str1[] ="This is a simple string";
char* pch;
pch = strstr (str1,"simple");
strncpy (pch,"sample",6);
printf("%s\n", str1);

void main() {}
