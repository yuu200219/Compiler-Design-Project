#include<stdio.h>

int main() {
    /*test 2 : check logical operation*/
    int a = 4;
    int b = 2;
    if(a == b) {
        printf("a equal b\n");
    }
    if(a < b || a > b) {
        printf("a smaller than b or a bigger than b\n");
    }
    if(!(a != 4)) {
        printf("test for NOT operation");
    }

}