/*On Simics compile with "gcc thread.c -pthread"  
on CygWin, -pthread option is not required */

#include <pthread.h>
#include <stdio.h>
#include <sys/timeb.h>

//cache blocks are 32B, make sure array and sum elements fall on different blocks
#define NUMBER_OF_ROWS 256 //2^8

#define NUMBER_OF_COLS 1000000
#define NUMBER_OF_ADDITIONAL_THREADS 3


//shared arrays named "array" and "sum",  variable "count", and lock location named "lock_var"
int array[NUMBER_OF_ROWS][NUMBER_OF_COLS];
double sum[NUMBER_OF_ROWS];
long gRefTime; //For timing

//Timing functions
long GetMilliSecondTime(struct timeb timeBuf);
long GetCurrentTime(void);
void SetTime(void);
long GetTime(void);


void *FindRowSum(void *arg)
{
	int *pid = (int *) arg;
	int index, j;
	

	
	for(index = 0; index < NUMBER_OF_ROWS; index++) {
		for (j=0; j< NUMBER_OF_COLS; j++)
			array[index][j] = index; //assume array data are read here

		sum[index] = 0; //start computations (assume a complex one)
		for (j=0; j<NUMBER_OF_COLS; j++)
		{
			sum[index] = sum[index] + array[index][j];
		}
		printf("pid = %d Sum[%d] = %f\n", *pid, index, sum[index]);
	
	}

	return NULL;
}
int main (void)
{
	
	int i, pid;
	
	
	
	printf("1T: PID 0 started: time = %f\n", (double) time(NULL));
	SetTime();

	pid = 0;

	FindRowSum(&pid); //main is the 4th thread

	printf("1T: PID 0 ended: time = %f\n", (double) time(NULL));
	printf("1T: PID %d took: time = %ld ms to complete\n", pid, GetTime());
	return 0;
}
long GetMilliSecondTime(struct timeb timeBuf){
	long mliScndTime;
	mliScndTime = timeBuf.time;
	mliScndTime *= 1000;
	mliScndTime += timeBuf.millitm;
	return mliScndTime;
}

long GetCurrentTime(void){
	long crntTime=0;
	struct timeb timeBuf;
	ftime(&timeBuf);
	crntTime = GetMilliSecondTime(timeBuf);
	return crntTime;
}

void SetTime(void){
	gRefTime = GetCurrentTime();
}

long GetTime(void){
	long crntTime = GetCurrentTime();
	return (crntTime - gRefTime);
}
