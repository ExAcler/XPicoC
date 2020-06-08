#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int a = atoi("2561");
int b = atoi("25ab");
printf("%d %d\n", a, b);

float c = atof("1234.5678");
printf("%f\n", c);

char *pt;
float d = strtod("1234.56abc", &pt);
printf("%f %s\n", d, pt);

char str[30];
char *mem = (char*)malloc(50);
strcpy(mem, "hello");
memcpy(str, mem, 6);
printf("%s %s\n", mem, str);
realloc(mem, 30);

void main() {}