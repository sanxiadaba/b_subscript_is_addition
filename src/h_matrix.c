#include <stdio.h>
int m[3][3] = {{1,2,3},{4,5,6},{7,8,9}};
int main(void) {
    int *p1 = m[1];
    int d1 = p1[2];
    int d2 = *(*(m + 1) + 2);
    int d3 = 2[1[m]];
    int d4 = m[1][2];
    int sum = d1 + d2 + d3 + d4;
    printf("D1 m[1][2] = %d\n", d1);
    printf("D2 *(*(m+1)+2) = %d\n", d2);
    printf("D3 2[1[m]] = %d\n", d3);
    printf("D4 m[1][2] = %d\n", d4);
    return sum;
}
