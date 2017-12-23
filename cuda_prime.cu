#include <stdio.h>
#include <math.h>
#include <ctime>

using namespace std;

__global__
void lista_pierwszych( unsigned long long int *d_sqrtzliczby,
                       unsigned long long int *d_liczba,
                       bool *d_jest){
  long int i = (blockIdx.x*blockDim.x + threadIdx.x);
  if(i<*d_sqrtzliczby+100 && i>2 && i%2!=0){
    if(*d_liczba % i==0){
      *d_jest =1 ;
    }
  }
}

int liczbapierwsza() {
  clock_t begin = clock();
	bool z=1;
	long  y=2;
	int i = 2;
	unsigned long long int x=10000001400000049;
		while (y < sqrt(x)+10) {
			int flag = 0;
			for (i; i <= i / 2; i++){
				printf("1");
				if (y%i == 0){
					flag = 1;
					break;
				}
			}
			if (flag == 0){
				if (x%y == 0) {
					z = 0;
					break;
				}
			}
			y++;
		}
		if (z == 0) {
			printf(" nie jestliczba pierwsza ");
		}
		else
			printf(" jest ");

      clock_t end = clock();
      double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
      printf("%f ", elapsed_secs);
	return 1;
}

int main(void){
  liczbapierwsza();
  unsigned long long *liczba, *d_liczba, *sqrtzliczby, *d_sqrtzliczby;
  bool *jest, *d_jest;

  jest= (bool*)malloc(sizeof(bool));
  liczba = (unsigned long long*)malloc(sizeof(unsigned long long));
  sqrtzliczby =(unsigned long long*)malloc(sizeof(unsigned long long));
  cudaMalloc(&d_liczba, sizeof(unsigned long long));
  cudaMalloc(&d_sqrtzliczby, sizeof(unsigned long long));
  cudaMalloc(&d_jest,sizeof(unsigned long long));

  *liczba = 10000001400000049;
  *sqrtzliczby = sqrtl(*liczba);
  printf("%llu ", *sqrtzliczby);
  cudaMemcpy(d_liczba,liczba,sizeof(unsigned long long), cudaMemcpyHostToDevice);
  cudaMemcpy(d_sqrtzliczby,sqrtzliczby, sizeof(unsigned long long),cudaMemcpyHostToDevice );
  cudaMemcpy(d_jest, jest, sizeof(bool), cudaMemcpyHostToDevice);
  clock_t begin = clock();
  if(*liczba%2 ==0){
    printf("%llu ", *liczba);
    printf("nie jest liczba pierwsza");
  }
  else{
    lista_pierwszych<<<((int)sqrt(*liczba)+255)/256, 256>>>( d_sqrtzliczby,d_liczba,d_jest);
    cudaMemcpy(jest, d_jest,sizeof(bool),cudaMemcpyDeviceToHost);
    if(*jest == 0){
      printf("%llu ", *liczba);
      printf("jest liczba pierwsza");
    }
    else{
      printf("%llu ", *liczba);
      printf("nie jest liczba pierwsza");
    }
  }
  clock_t end = clock();
  double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
  printf(" %f ", elapsed_secs);

  cudaFree(d_liczba);
  cudaFree(d_sqrtzliczby);
  cudaFree(d_jest);
  free(jest);
  free(liczba);
  free(sqrtzliczby);
}