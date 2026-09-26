#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int *p = arr;
int main(void) {
    int a1 = arr[2];
    int a2 = 2[arr];
    int a3 = p[2];
    int a4 = 2[p];
    int a5 = *(p + 2);
    int a6 = (2 + p)[0];
    int a7 = (p + 2)[0];
    int a8 = "hello"[1];
    int a9 = 1["hello"];
    printf("A1 arr[2] = %d\n", a1);
    printf("A2 2[arr] = %d\n", a2);
    printf("A3 p[2] = %d\n", a3);
    printf("A4 2[p] = %d\n", a4);
    printf("A5 *(p+2) = %d\n", a5);
    printf("A6 (2+p)[0] = %d\n", a6);
    printf("A7 (p+2)[0] = %d\n", a7);
    printf("A8 hello[1] = %c\n", a8);
    printf("A9 1[hello] = %c\n", a9);
    return a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9;
}
