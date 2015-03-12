/* main.c:  test program for 32 bit real FFT and supporting functions for Cortex-M3
--------------------------------------------------------------------------
(c) 2009 Ivan Mellen                                        September 2009
--------------------------------------------------------------------------
imellen(at)embeddedsignals(dot)com
*/

#include <stdio.h>
//declare functions

/*
void Window16to32b_real(int *x,unsigned short *w,int N);
void FFT128Real_32b(int *y, int *x);
void magnitude32_32bIn(int   *x,int M);

extern unsigned short Hamming128_16b[];
*/
#include "fft.h"

#define NN 128
int x[NN];  // input array
int y[NN +2];  // one extra element


unsigned short w[NN/2]; //first half of symetrical window 0Q16 unsigned

//int main(void)
int sample_main(void)
{
	//int i,N,aBig,aBig2,aSmall;
	int i,aBig,aBig2,aSmall;
	
	
	//optional block for STM32, configure flash access
	int *Flash_ACR,latency;
	Flash_ACR=(int*)0x40022000;
	latency=0;
	*Flash_ACR=0x10+latency ; //enable  prefetch, set latency
	
	
	//test code
	aBig=32760; // big amplitude test signal1
	aBig2=23165; // big amplitude * sin(pi/4)
	aSmall=10;   // small amplitude test signal2,  to avoid x overflow aSmall<32767-aBig2
	
	while(1)  //infinity loop, multiple benchmarks without restart possible
	{
	
		//create windowing function 0Q16  (0.5 =32768   0.99998 =65535)
		for (i=0;i<NN/2;i++)   w[i]=0xffff;   //0.99998
		
		//clear output array
		for (i=0;i<NN;i++)   y[i]=0;
		
		// create input signal (16 bit in 32 bit array, upper 16 bits are ignored)
		for (i=0;i<NN;i+=8)
		{
			 x[i+0]= 0        +0;       // signal 1: f=fs/4  A=aSmall
			 x[i+1]= -aSmall  +aBig2;   // signal 2: f=fs/8  A=aBig
			 x[i+2]= 0        +aBig;
			 x[i+3]= aSmall   +aBig2;
			 x[i+4]= 0        +0;
			 x[i+5]= -aSmall  -aBig2;
			 x[i+6]= 0        -aBig;
			 x[i+7]= aSmall   -aBig2;
		}
		
		
		
		Window16to32b_real( x, Hamming128_16b, NN); // apply Hamming window to input signal
		//Window16to32b_real( x, w, NN); //or just expand to 32 bits with 1/2 scale
		
		//for (i=0;i<NN;i++)   x[i]=0;  //test fft 32 bit performance, fastest with small input
		
		
		//call FFT routine;
		FFT128Real_32b(y,x);
		
		// convert complex output to magnitude
		magnitude32_32bIn(&y[2],NN/2-1);  //DC and Fs/2 bins are already real (can be negative!)
		
		// expected output: y[32] magnitude of signal1 *2^15      y[64] magnitude of signal2 *2^15
		i=1; // benchmark stop
		
		
		//Format output for easier reading
		for (i=0;i<=NN;i+=2) y[i+1]=0; //zero imag part of original complex frequency
		for (i=0;i<=NN;i+=2) y[i]=((y[i]+16384)>>15); //2Q30 converted to 17Q15 and rounded
		
		i=1; // // check results after formating y
		
		//expected output when w[]=0xffff used for windowing
		// y[32]=32760   y[64]=10     ...rest = 0
		
	
	}
}

