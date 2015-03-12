#ifndef	__FFT_H__
#define	__FFT_H__

void Window16to32b_real(int *x,unsigned short *w,int N);
void FFT128Real_32b(int *y, int *x);
void magnitude32_32bIn(int   *x,int M);

extern unsigned short Hamming128_16b[];

#endif	// __FFT_H__

