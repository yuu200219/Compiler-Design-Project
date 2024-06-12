#include<stdio.h>
/*test for while-loop, if-then-else statement and printf*/
void main()
{
    int a = 1;
    int b = 2;
    if(a > 1) {
        while(a) {
            a=2;
        }
        printf("test_1\n");
    }
    else if(a == 1) {
        printf("test_2\n");
    }
    else if(a < 1) 
        printf("test_3\n");
    else printf("test_4\n");

}