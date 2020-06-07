#include <stdio.h>

int main()
{
    char a[5][5] = {"abc", "def", "ghi", "jkl", "mno"};
    char *aa[5];

    for (int i = 0; i < 5; ++i)
        aa[i] = a[i];

    char **src = aa;
    char catstr[30];
    char *dest = catstr;
    printf("%c\n", aa[1][1]);

    do
    {
        while (**src)
            *dest++ = *(*src)++;
    } while (*++src);

    printf("concat string: %s\n", catstr);
    return 0;
}