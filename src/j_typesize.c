#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int main(void) {
    printf("J1 sizeof(arr[2]) = %d\n", (int)sizeof arr[2]);
    printf("J2 sizeof(int*)   = %d\n", (int)sizeof(int *));
    printf("J3 sizeof(arr)    = %d\n", (int)sizeof arr);
    return 0;
}
