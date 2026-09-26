#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int main(void) {
    int *ok = &arr[2];
    int *bad = arr[2];
    printf("I1 sizeof(arr[2]) = %d\n", (int)sizeof arr[2]);
    printf("I2 *(&arr[2]) = %d\n", *ok);
    printf("I3 bad=%p\n", (void *)bad);
    return 0;
}
