/*On Simics compile with "gcc thread.c -pthread"  
on CygWin, -pthread option is not required */

#include <pthread.h>
#include <stdio.h>
#include <sys/timeb.h>



#define NUMBER_OF_ROWS 256 //2^8

#define NUMBER_OF_COLS 1000000
#define NUMBER_OF_ADDITIONAL_THREADS 9



//shared arrays named "array" and "sum",  variable "count", and lock location named "lock_var"
int array[NUMBER_OF_ROWS][NUMBER_OF_COLS];
int rowsProcessed[NUMBER_OF_ADDITIONAL_THREADS+1];
float sum[NUMBER_OF_ROWS];

long threadTime[NUMBER_OF_ADDITIONAL_THREADS+1];//Used to store the time it took for thread to complete in ms
long avgRowTime[NUMBER_OF_ADDITIONAL_THREADS+1];
double timeComplete[NUMBER_OF_ADDITIONAL_THREADS+1];//Used to store the final time of a thread.
int count = 0;  //define a shared count, initialized to zero
pthread_mutex_t lock_var;  //define a shared lock variable (a system level variable)
long gRefTime, gRefTime2; //For timing

//Timing functions
long GetMilliSecondTime(struct timeb timeBuf);
long GetCurrentTime(void);
void SetTime(void);
long GetTime(void);
void SetTimeRow(void);
long GetTimeRow(void);
int FetchAndIncrement()
{
	int t;
	pthread_mutex_lock(&lock_var);	//lock
		t = count;
		count = count + 1;
	pthread_mutex_unlock(&lock_var); //unlock
	return(t);
}
void *FindRowSum(void *arg)
{
	int *pid = (int *) arg;
	int index, j, counter;
	long avgTime, Time;
	counter =0;
	SetTimeRow();
	index = FetchAndIncrement();
	
	while(index < NUMBER_OF_ROWS) {
		for (j=0; j< NUMBER_OF_COLS; j++)
		array[index][j] = index; //assume array data are read here

		sum[index] = 0; //start computations (assume a complex one)
		for (j=0; j<NUMBER_OF_COLS; j++)
		{
			sum[index] = sum[index] + array[index][j];
		}
		Time = GetTimeRow();
		printf("pid = %d Sum[%d] = %f Took Time = %ld ms to complete row\n", *pid, index, sum[index], Time);
		avgTime = avgTime + Time;
		counter++;
		index = FetchAndIncrement();
	}
	threadTime[*pid] = GetTime();
	rowsProcessed[*pid] = counter;
	avgRowTime[*pid] = avgTime / counter;
	timeComplete[*pid] = (double) time(NULL);
	return NULL;
}
int main (void)
{
	pthread_t threadID[NUMBER_OF_ADDITIONAL_THREADS];
	void *exit_status;
	int i, pid[NUMBER_OF_ADDITIONAL_THREADS+1];
	
	
	for(i=0; i<NUMBER_OF_ADDITIONAL_THREADS; i++) { //create 1 aditional threads to run
		pid[i] = i;
		printf("10T: PID %d started: time = %f\n", pid[i], (double) time(NULL));
		SetTime();
		pthread_create(&threadID[i], NULL, FindRowSum, &pid[i]);  //&i would also work but print pid info above will be incorrect
	}
	
	pid[9] = 9;
	printf("10T: PID %d started: time = %f\n", pid[9], (double) time(NULL));
	SetTime();
	FindRowSum(&pid[9]); //main is the 2th thread
	for(i=0; i<NUMBER_OF_ADDITIONAL_THREADS; i++)
		pthread_join(threadID[i], &exit_status);
	for( i = 0; i < (1+NUMBER_OF_ADDITIONAL_THREADS); i++)
	{
		printf("10T: PID %d ended: time = %f\n",pid[i], timeComplete[i]);
		printf("10T: PID %d took: time = %ld ms to complete\n", pid[i], threadTime[i]);
		printf("10T: PID %d Processed: %d rows and spent an Average Time of : %ld per row\n",pid[i], rowsProcessed[i], avgRowTime[i]);
    }
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
void SetTimeRow(void){
	gRefTime2 = GetCurrentTime();
}

long GetTimeRow(void){
	long crntTime = GetCurrentTime();
	return (crntTime - gRefTime2);
}
