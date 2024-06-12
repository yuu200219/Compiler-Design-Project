
/*
check for-loop
check while-loop
check if-else
*/
void main() {

    float a = 1.0;
    int c = 0;
    int aa;
    int b = 0.1;
    
    if(a>b) printf("a<b");
    
    if(a == 1)
        a-=2;
    if(a == 2)
        a /= 2;
    else if(a == 0.1)
        a+=3;

    for (int i = 0; i>b ;i+=0.1) {
        for (int j = 1; j< 10;j++) {
            i++;
        }
    }
    while(a<1) {
        a+=1;
        if(a == 1)
            a-=2;
        else if(a == 0.1)
            a+=3;
    }

}