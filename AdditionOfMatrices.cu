
 #include <stdio.h>
 #include <stdlib.h>
 #include <math.h>
 
 /*---------------------------------------------------------------------
  * Kernel:   AdditionOfMatrices
  * Purpose:  Implement matrix addition
  * In args:  A, B, m, n
  * Out arg:  C
  */
 __global__ void AdditionOfMatrices(float A[], float B[], float C[], int m, int n) {
    /* blockDim.x = threads_per_block                            */
    /* First block gets first threads_per_block components.      */
    /* Second block gets next threads_per_block components, etc. */
    int my_ij = blockDim.x * blockIdx.x + threadIdx.x;
 
    /* The test shouldn't be necessary */
    if (blockIdx.x < m && threadIdx.x < n) 
       C[my_ij] = A[my_ij] + B[my_ij];
 }  /* AdditionOfMatrices */
 
 
 /*---------------------------------------------------------------------
  * Function:  Read_matrix
  * Purpose:   Read an m x n matrix from stdin
  * In args:   m, n
  * Out arg:   A
  */
  void Read_matrix(float A[], int m, int n) {
   int i, j;

   for (i = 0; i < m; i++)
      for (j = 0; j < n; j++)
         scanf("%f", &A[i*n+j]);
}  /* Read_matrix */


/*---------------------------------------------------------------------
 * Function:  Print_matrix
 * Purpose:   Print an m x n matrix to stdout
 * In args:   title, A, m, n
 */
void Print_matrix(char title[], float A[], int m, int n) {
   int i, j;

   printf("%s\n", title);
   for (i = 0; i < m; i++) {
      for (j = 0; j < n; j++)
         printf("%.1f ", A[i*n+j]);
      printf("\n");
   }  
}  /* Print_matrix */
 
 
 /* Host code */
 int main(int argc, char* argv[]) {
    int m, n;
    float *h_A, *h_B, *h_C;
    float *d_A, *d_B, *d_C;
    size_t size;
 
    /* Get size of matrices */
    if (argc != 3) {
       fprintf(stderr, "usage: %s <row count> <col count>\n", argv[0]);
       exit(0);
    }
    m = strtol(argv[1], NULL, 10);
    n = strtol(argv[2], NULL, 10);
    printf("m = %d, n = %d\n", m, n);
    size = m*n*sizeof(float);
 
    h_A = (float*) malloc(size);
    h_B = (float*) malloc(size);
    h_C = (float*) malloc(size);
    
    printf("Enter the matrices A and B\n");
    Read_matrix(h_A, m, n);
    printf("matrix a is complete, now enter secend matrix: ");
    Read_matrix(h_B, m, n);
 
    Print_matrix("A =", h_A, m, n);
    Print_matrix("B =", h_B, m, n);
 
    /* Allocate matrices in device memory */
    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_C, size);
 
    /* Copy matrices from host memory to device memory */
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
 
    /* Invoke kernel using m thread blocks, each of    */
    /* which contains n threads */
    /* Execution configuration */
    dim3 block_size( 16, 16 );
    dim3 num_blocks( ( n - 1 + block_size.x ) / block_size.x, 
                     ( m - 1 + block_size.y ) / block_size.y );
  
    AdditionOfMatrices<<<block_size, num_blocks>>>(d_A, d_B, d_C, m, n);
 
    /* Wait for the kernel to complete */
    cudaThreadSynchronize();
 
    /* Copy result from device memory to host memory */
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
 
    Print_matrix("The sum is: ", h_C, m, n);
 
    /* Free device memory */
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
 
    /* Free host memory */
    free(h_A);
    free(h_B);
    free(h_C);
 
    return 0;
 }  /* main */