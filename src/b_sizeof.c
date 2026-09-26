#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int *p = arr;
int f(int q[]) { return sizeof(q); }
int main(void) {
    int n1 = sizeof(arr);
    int n2 = sizeof(p);
    int n3 = f(arr);
    int n4 = n1 / n2;
    int q = sizeof(arr) / sizeof(arr[0]);
    int sum = n1 + n2 + n3 + n4;
    printf("B1 sizeof(arr) = %d\n", n1);
    printf("B2 sizeof(p) = %d\n", n2);
    printf("B3 f(arr) = %d\n", n3);
    printf("B4 n1/n2 (sizeof(arr)/sizeof(p)) = %d\n", n4);
    printf("B5 sizeof(arr)/sizeof(arr[0]) = %d\n", q);
    return sum + q;
}
