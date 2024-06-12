#include<stdio.h>

int main() {
    int a = 2;
    int b = 4;
    /*test 1 : check operation and partial function(main, printf)*/
    printf("+:%d\n", a + b );
    printf("-:%d\n", a - b );
    printf("*:%d\n", a * b );
    printf("/:%d\n", b / a);
    printf("%:%d\n", b % a);
    printf("|:%d\n", a | b);
    printf("&:%d\n", a & b);
    printf("^:%d\n", a ^ b);
   

    return 0;
}