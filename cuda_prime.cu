#include <stdio.h>
#include <math.h>
#include <ctime>

using namespace std;

__global__
void lista_pierwszych( unsigned long long int *d_sqrtzliczby,
                       unsigned long long int *d_liczba,
                       bool *d_jest,
                       int *current_thread_count,
                       long int q){
  atomicAdd(current_thread_count, 1);
    long int i = (blockIdx.x*blockDim.x + threadIdx.x);
    if((i+61440000*q)<*d_sqrtzliczby+100 && (i+61440000*q)>2 && (i+61440000*q)%2!=0){
      if(*d_liczba % (i+61440000*q)==0){
        *d_jest =1 ;
      }
    }
}


int liczbapierwsza() {
  clock_t begin = clock();
	bool z=1;
	long  y=2;
	int i = 2;
	unsigned long long int x=12808970049658849609;
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
			printf("%llu nie jest liczba pierwsza\n ",x);
		}
		else
			printf("%llu jest liczba pierwsza\n ",x);

      clock_t end = clock();
      double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
      printf("czas CPU: %f \n", elapsed_secs);
	return 1;
}

int main(void){
  liczbapierwsza();
  unsigned long long *liczba, *d_liczba, *sqrtzliczby, *d_sqrtzliczby;
  bool *jest, *d_jest;
  int tally, *dev_tally;
  cudaMalloc((void **)&dev_tally, sizeof(int));
  tally = 0;
  cudaMemcpy(dev_tally, &tally, sizeof(int), cudaMemcpyHostToDevice);
  jest= (bool*)malloc(sizeof(bool));
  liczba = (unsigned long long*)malloc(sizeof(unsigned long long));
  sqrtzliczby =(unsigned long long*)malloc(sizeof(unsigned long long));
  cudaMalloc(&d_liczba, sizeof(unsigned long long));
  cudaMalloc(&d_sqrtzliczby, sizeof(unsigned long long));
  cudaMalloc(&d_jest,sizeof(unsigned long long));

  *liczba = 12808970049658849609;
  *sqrtzliczby = sqrtl(*liczba);
  long int op= (int)ceil(*sqrtzliczby/61440000);
  printf("\n %ld \n", op);
  printf("pierwiastek z liczby: %llu\n ", *sqrtzliczby);
  cudaMemcpy(d_liczba,liczba,sizeof(unsigned long long), cudaMemcpyHostToDevice);
  cudaMemcpy(d_sqrtzliczby,sqrtzliczby, sizeof(unsigned long long),cudaMemcpyHostToDevice );
  cudaMemcpy(d_jest, jest, sizeof(bool), cudaMemcpyHostToDevice);

  clock_t begin = clock();
  if(*liczba%2 ==0){
    printf("%llu nie jest liczba pierwsza\n", *liczba);
  }
  else{
    for(int q=0;q <= op; q++){
      lista_pierwszych<<<60000,1024>>>( d_sqrtzliczby,d_liczba,d_jest, dev_tally ,q);
    }
      cudaMemcpy(jest, d_jest,sizeof(bool),cudaMemcpyDeviceToHost);
      cudaMemcpy(&tally, dev_tally, sizeof(int), cudaMemcpyDeviceToHost);
    printf("total number of threads that executed was: %d\n", tally);
    if(*jest == 0){
      printf("%llu jest liczba pierwsza\n", *liczba);
    }
    else{
      printf("%llu nie jest liczba pierwsza\n", *liczba);
    }
  }
  clock_t end = clock();
  double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
  printf("czas GPU: %f\n ", elapsed_secs);

  cudaFree(d_liczba);
  cudaFree(d_sqrtzliczby);
  cudaFree(d_jest);
  free(jest);
  free(liczba);
  free(sqrtzliczby);
}
