#include<stdio.h>
/*test for if-then statement and printf*/
void main()
{
    int a = 1;
    int b = 2;
    if(a) {
        printf("a = %d\n", a);
        if(2)
            printf("a = %d, b = %d\n", a, b);
    }

}