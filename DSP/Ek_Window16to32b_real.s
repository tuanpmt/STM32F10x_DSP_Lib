;Window16to32b_real:  Hybrid 32/16 bit windowing functions for ARM Cortex-M3    
;--------------------------------------------------------------------------
;(c) 2009 Ivan Mellen                                        September 2009 
;--------------------------------------------------------------------------
;Free Personal, Non-Commercial Use License. 
;The Software is licensed to you for your personal, NON-COMMERCIAL USE.
;If you have questions about this license, need other sizes or would like
;a different license please email : imellen(at)embeddedsignals(dot)com
;
;
; This file contains only one function:
; Window16to32b_real(int *x,unsigned short *w,int N);  // KEIL version 
;
;
;/*
;function prototypes:
;void Window16to32b_real(int *x,unsigned short *w,int N);  // w[] has N/2 elements in 0Q16, x[] has N elements
; 
;
;
;Data description:
;
;x - input signal for windowing function (lower 16 bits treated as signed shorts)
;  - outputfrom windowing function, written to same array - now 32 bit integers, scaled to +-1/2 of full range
;  - input to 32 bit FFT, must be scaled to +-1/2 of full range to avoid overflow
;
;w - first half of symetrical windowing function, N/2 elements,  0Q16  (0.5 =32768   0.99998 =65535)
;N - FFT size
;
;
;
;for Window16to32b_real(int *x,unsigned short *w,int N) function:
;
;x in  = {x0, d, x1, d, x2, ,d x3, d, x4, ...xN-1,d}   ;16 bit signed integers
;x out = { xw0, xw1, xw2 ... xw(N-1) }  ; 32 bit integers, scaled for  FFT....Complex_32b()
; ;where d is don't care
;w = {w0,w1,w2 .. wN/2-1}   in 0Q16
;N = window size
;
; 
;
;Usage example:
;
;void Window16to32b_real(int *x, unsigned short *w,int N);
;#define N 128
;int x[N]; //0 to N-1
;int y[N+2]; // (0 to N/2 )*  two elements (re, im)
;int i;
;short *sx;
;extern int Hamming128_16b[]; // N/2 real coefficients 0Q16
;unsigned short w[N/2]; //RAM based windowing coefficients
;
;for (i=0;i<N/2;i++) w[i] = 0Q16 coefficient value;
;
;//fill input array
;for (i=0;i<N;i++) x[i] = some 32 bit signed value;
;
;// alternative way of getting input data
;sx = (int *)x;
;for (i=0;i<N;i++) sx[2*i]= 16 bit signed value; 
;
;Window16to32b_real( x, Hamming128_16b, NN); // perform windowing function
;FFT128Real_32b(y,x); //call FFT routine;
;
;Benchmarks:
;
;
;
;
;Function    FFT Points    Lat0          Lat1          Lat2          
;Window16b_real
;Window16to32b_real
;            16           123                                                  
;            32           217                                                  
;            64           405                                                  
;            128          781                                                  
;            256          1533                                                  
;            512          3037                                                  
;            1024         6045          6174           6303                              
;            2048         12061                                                  
;            4096         24093                                                  
;
; Window16b_complex     
; Window16to32b_complex 
;            16           199                                                  
;            32           369                                                  
;            64           709                                                  
;            128          1389                                                  
;            256          2749                                                  
;            512          5469                                                  
;            1024         10909                                                  
;            2048         21789                                                  
;            4096         43549                                                  
;
;Window32to32b_real  (data dependant speed)
;            16           137                                                  
;            32           243                                                  
;            64           455                                                  
;            128          879                                                  
;            256          1727                                                  
;            512          3423                                                  
;            1024         6815-7842      6950-7974     7084-8108                              
;            2048         13599                                                  
;            4096         27167                                                  
;
;Window32to32b_complex  (data dependant speed)
;            16           229                                                  
;            32           427                                                  
;            64           823                                                  
;            128          1615                                                  
;            256          3199                                                  
;            512          6367                                                  
;            1024         12703   ... worst case TBD                                                
;            2048         25375                                                  
;            4096         50719                                                  
;
;
;
;// void Window16to32b_real(int *x,unsigned short *w,int N);
;

        
        THUMB
        AREA    FFTLIB2_CORTEXM3, CODE, READONLY        
        EXPORT  Window16to32b_real
        EXPORT  Hamming128_16b
        ALIGN 8
        

Window16to32b_real
            stmdb sp!, {r4-r9, lr}
            mov r12, r1
            add.w r9, r0, r2, lsl #0x02
            mov lr, r2
            sub.w r8, r0, #0x00000010
for_k1
            ldmia r12!, {r4, r6}
            lsrs r5, r4, #0x10
            uxth r4, r4
            lsrs r7, r6, #0x10
            uxth r6, r6
            ldrsh r0, [r8, #+0x10]!
            ldrsh.w r1, [r8, #+0x004]
            ldrsh.w r2, [r8, #+0x008]
            ldrsh.w r3, [r8, #+0x00C]
            muls r0, r4, r0
            asrs r0, r0, #0x01
            str.w r0, [r8, #+0x000]
            muls r1, r5, r1
            asrs r1, r1, #0x01
            str.w r1, [r8, #+0x004]
            muls r2, r6,r2
            asrs r2, r2, #0x01
            str.w r2, [r8, #+0x008]
            muls r3, r7, r3
            asrs r3, r3, #0x01
            str.w r3, [r8, #+0x00C]
            ldrsh r0, [r9, #-0x10]!
            ldrsh.w r1, [r9, #+0x004]
            ldrsh.w r2, [r9, #+0x008]
            ldrsh.w r3, [r9, #+0x00C]
            muls r0, r7, r0
            asrs r0, r0, #0x01
            str.w r0, [r9, #+0x000]
            muls r1, r6	,r1
            asrs r1, r1, #0x01
            str.w r1, [r9, #+0x004]
            muls r2, r5	,r2
            asrs r2, r2, #0x01
            str.w r2, [r9, #+0x008]
            muls r3, r4	,r3
            asrs r3, r3, #0x01
            str.w r3, [r9, #+0x00C]
            subs.w lr, lr, #0x00000008
            bne for_k1
            ldmia sp!, {r4-r9, pc}
  
  
            ALIGN 8
 
; Hamming 128 0Q16 unsigned , first 64 elements 
Hamming128_16b   
    DCW 0x147b, 0x14a0, 0x150e, 0x15c6, 0x16c7, 0x1811, 0x19a1, 0x1b79
    DCW 0x1d95, 0x1ff6, 0x229a, 0x257e, 0x28a1, 0x2c02, 0x2f9e, 0x3372
    DCW 0x377d, 0x3bbb, 0x402b, 0x44c9, 0x4993, 0x4e85, 0x539d, 0x58d7
    DCW 0x5e30, 0x63a4, 0x6931, 0x6ed2, 0x7484, 0x7a45, 0x800f, 0x85df
    DCW 0x8bb2, 0x9185, 0x9752, 0x9d18, 0xa2d2, 0xa87c, 0xae13, 0xb394
    DCW 0xb8fb, 0xbe45, 0xc36e, 0xc873, 0xcd52, 0xd206, 0xd68e, 0xdae5
    DCW 0xdf0a, 0xe2fa, 0xe6b2, 0xea31, 0xed73, 0xf077, 0xf33b, 0xf5bd
    DCW 0xf7fc, 0xf9f7, 0xfbab, 0xfd18, 0xfe3d, 0xff1a, 0xffad, 0xffff

    END