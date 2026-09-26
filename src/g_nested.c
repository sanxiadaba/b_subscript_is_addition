#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int *p = arr;
int idx(void) { return 2; }
int main(void) {
    int c1 = p[idx()];
    int c2 = idx()[p];
    int c3 = (2 + 1)[arr];
    int c4 = 1[p + 1];
    int c5 = idx()[p + 0];
    int c6 = 2[p + 1];
    int c7 = (1 + 1)[arr + 2];
    int c8 = arr[2 + 1];
    int c9 = p[idx() + 0];
    int c10 = p[1 + 1];
    int c11 = arr[1 + 2];
    printf("C1 p[idx()] = %d\n", c1);
    printf("C2 idx()[p] = %d\n", c2);
    printf("C3 (2+1)[arr] = %d\n", c3);
    printf("C4 1[p+1] = %d\n", c4);
    printf("C5 idx()[p+0] = %d\n", c5);
    printf("C6 2[p+1] = %d\n", c6);
    printf("C7 (1+1)[arr+2] = %d\n", c7);
    printf("C8 arr[2+1] = %d\n", c8);
    printf("C9 p[idx()+0] = %d\n", c9);
    printf("C10 p[1+1] = %d\n", c10);
    printf("C11 arr[1+2] = %d\n", c11);
    return c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10 + c11;
}
