;    E_Magnitude:   32 bit Complex magnitude functions for ARM Cortex-M3    
; --------------------------------------------------------------------------
; (c) 2009 Ivan Mellen                                        September 2009 
; --------------------------------------------------------------------------
; Free Personal, Non-Commercial Use License. 
; The Software is licensed to you for your personal, NON-COMMERCIAL USE.
; If you have questions about this license, need other sizes or would like
; a different license please email : imellen(at)embeddedsignals(dot)com
;
;
; This file contains only one function:
; void magnitude32_32bIn(int *x,int M);  // KEIL version 
;
; Magnitude  functions calculate magnitude of complex frequency: magnitude=sqrt(re^2+im^2)
;
;
; C interface:  
; unsigned int sqrt32(unsigned int y); //auxiliary function, return in 16Q16 format
; void magnitude16_16bIn(short *x,int M); //for 16 bit FFT, 16b input precision, fast
; void magnitude16_32bIn(int   *x,int M); //for 32 bit FFT, 16b input precision, fast
; void magnitude24_32bIn(int   *x,int M); //for 32 bit FFT, 24b input precision, slower
; void magnitude32_32bIn(int   *x,int M); //for 32 bit FFT, 32b input precision, slowest
;
;
; Data description:
;
; unsigned int sqrt32(unsigned int y); //auxilary function, return in 16Q16 format
; y = unsigned 32 bit input value
; return value = 32 bit unsigned in 16Q16 format, e.g  1.5 is 0x00018000
;
;
; For magnitude16_16bIn( short *x,int M) function:
; x in  = {re0,im0, re1,im1, .. re(M-1),im(M-1) }  ; 16 bit elements
; x out = {mag0, mag1, ..       mag(M-1), }              ; 32 bit elements
;  ; xout shoud be treated as array of [M/2] integers, 16Q16 format, every element used
;
;
; For magnitude16_32bIn(int *x,int M) and magnitude24_32bIn(int *x,int M) functions:
; x in  = {re0,im0, re1,im1, .. re(M-1),im(M-1) }  ; 32 bit elements
; x out = {mag0, u, mag1, u, .. mag(M-1), u }              ; 32 bit elements
;  ; where u is unmodified previous value (imaginary part of complex frequency)
;
;
;  For magnitude32_32bIn(int *x,int M) and magnitude16_32bIn(int *x,int M) functions:
;  x in  = {re0,im0, re1,im1, .. re(M-1),im(M-1) }  ; 32 bit elements
;  x out = {mag0, u, mag1, u, .. mag(M-1), u }               ; 32 bit elements
;  ; where u is unmodified previous value (imaginary part of complex frequency)
;
; Example program:
; void Window16to32b_real(int *x,unsigned short *w,int N);
; void FFT128Real_32b(int *y, int *x);
; void magnitude32_32bIn(int   *x,int M);
; extern int Hamming128_16b[];
;
; #define NN 128
; int x[NN];  // input array
; int y[NN +2];  // one extra element 
;
; //fill x[] with 32 bit values from interval <-32768, 32767> 
; // top 16 bits ignored by the windowing function
;
; Window16to32b_real( x, Hamming128_16b, NN); // perform windowing function
; FFT128Real_32b(y,x); //call FFT routine;
; magnitude32_32bIn(&y[2],NN/2-1);  // convert complex output to magnitude
;   //DC and Fs/2 bins are already real (can be negative!)
;   
; Benchmarks:                                                    
;                          Best case (magnitude32_32bIn only)|  Worst case (magnitude32_32bIn only)
;   
; Function    FFT Points      Lat0       Lat1         Lat2   |    Lat0      Lat1     Lat2
;
; magnitude16_16bIn
;              16             193                                        
;              32             393                                        
;              64             793                                        
;              128            1593                                        
;              256            3193                                        
;              512            6393                                        
;              1024           12793       14327       15860  |                    
;              2048           25593                                        
;              4096           51193                                        
;
; magnitude16_32bIn
;              16             193                                        
;              32             393                                        
;              64             793                                        
;              128            1593                                        
;              256            3193                                        
;              512            6393                                        
;              1024           12793       14327       15860  |                    
;              2048           25593                                        
;              4096            51193                                        
;
; magnitude24_32bIn
;              16             268                                        
;              32             556                                        
;              64             1132                                        
;              128            2284                                        
;              256            4588                                        
;              512            9196                                        
;              1024           18412       20457       24035  |                    
;              2048           36844                                        
;
; magnitude32_32bIn (speed is data dependant)
;              16             240                            |   275             
;              32             496                            |   571             
;              64             1008                           |   1163            
;              128            2032                           |   2347            
;              256            4080                           |   4715            
;              512            8176                           |   9451            
;              1024           16368       18413       21991  |   18923      21479    25568
;              2048           32752                          |   37867           
;              4096           65520                          |   75755           
;                                                                       
;   
; sqrt32       7 cycles + call overhead  (32 bit input 32Q0, 32 bit output 16Q16)  
   


                
             THUMB
             AREA    FFTLIB2_CORTEXM3, CODE, READONLY        
             EXPORT  magnitude32_32bIn
             ALIGN 8
        
        
        
        
        
magnitude32_32bIn
            stmdb.w sp!, {r4-r5, lr}
            adr lr, LUTsqrt-256 
formag3
            ldmia.n r0!, {r4-r5}
            smull r4, r3, r4, r4
            smull r2, r5, r5, r5
            adds r4, r4, r2
            adcs r3, r5
            beq only16
            clz r5, r3
            and r5, r5, #0x000000FE
            lsls r3, r5
            rsb.w r2, r5, #0x00000020
            lsrs r4, r2
            orr.w r4, r4, r3
            lsrs r3, r4, #0x18
            ldr.w r2, [lr, r3, lsl #0x2]
            ubfx r3, r4, #0x08, #0x10
            lsls r4, r2, #0x0C
            lsrs r2, r2, #0x14
            muls r2, r3, r2
            adds.w r4, r4, r2, lsr #0x04
            lsrs r5, r5, #0x01
            lsrs r4, r5
            str r4, [r0, #-0x08]
            subs r1, #0x01
            bne formag3
            ldmia.w sp!, {r4-r5, pc}
only16
            clz r5, r4
            and r5, r5, #0x000000FE
            lsls r4, r5
            lsrs r3, r4, #0x18
            ldr.w r2, [lr, r3, lsl #0x2]
            ubfx r3, r4, #0x08, #0x10
            lsls r4, r2, #0x0C
            lsrs r2, r2, #0x14
            muls r2, r3	,r2
            adds.w r4, r4, r2, lsr #0x04
            lsrs r5, r5, #0x01
            lsrs r4, r5
            lsrs r4, r4, #0x10
out3
            str r4, [r0, #-0x08]
            subs r1, #0x01
            bne formag3
            ldmia.w sp!, {r4-r5, pc}

           ALIGN 4
           
LUTsqrt 
BidErr   DCD 0xff080002,0xfd180ff2,0xfb281fc3,0xf9482f75,0xf7883f09,0xf5a84e81,0xf3f85ddb,0xf2386d1a
         DCD 0xf0887c3d,0xeef88b45,0xed589a33,0xebb8a908,0xea38b7c3,0xe8b8c665,0xe728d4f0,0xe5b8e362
         DCD 0xe448f1bd,0xe2e90001,0xe1890e2f,0xe0391c46,0xdec92a49,0xdd893835,0xdc39460d,0xdaf953d0
         DCD 0xd9c9617f,0xd8796f1b,0xd7597ca2,0xd6198a17,0xd4f99778,0xd3d9a4c7,0xd2b9b204,0xd199bf2f
         DCD 0xd089cc48,0xcf69d950,0xce69e646,0xcd59f32c,0xcc5a0001,0xcb4a0cc6,0xca5a197a,0xc94a261f
         DCD 0xc85a32b4,0xc76a3f39,0xc68a4baf,0xc59a5816,0xc4aa646f,0xc3ba70b9,0xc2da7cf4,0xc20a8921
         DCD 0xc11a9541,0xc04aa152,0xbf6aad56,0xbe9ab94c,0xbdcac535,0xbcfad111,0xbc2adce0,0xbb6ae8a2
         DCD 0xbaaaf457,0xb9cb0001,0xb91b0b9d,0xb85b172e,0xb78b22b3,0xb6eb2e2b,0xb62b3998,0xb56b44fa
         DCD 0xb4ab5050,0xb40b5b9a,0xb34b66da,0xb2ab720e,0xb1fb7d38,0xb15b8856,0xb09b936b,0xaffb9e74
         DCD 0xaf5ba973,0xaeabb468,0xae1bbf52,0xad6bca33,0xaccbd509,0xac3bdfd5,0xab9bea98,0xab0bf551
         DCD 0xaa5c0001,0xa9dc0aa6,0xa93c1543,0xa8ac1fd6,0xa81c2a60,0xa78c34e1,0xa6fc3f59,0xa67c49c8
         DCD 0xa5ec542e,0xa55c5e8c,0xa4cc68e1,0xa44c732d,0xa3bc7d71,0xa33c87ac,0xa2bc91df,0xa22c9c0a
         DCD 0xa1aca62d,0xa12cb047,0xa0bcba59,0xa03cc464,0x9facce67,0x9f4cd861,0x9ebce255,0x9e4cec40
         DCD 0x9dccf624,0x9d5d0000,0x9ced09d5,0x9c6d13a3,0x9bfd1d69,0x9b8d2728,0x9b0d30e0,0x9aad3a90
         DCD 0x9a2d443a,0x99cd4ddc,0x994d5778,0x98ed610c,0x987d6a9a,0x980d7421,0x97ad7da1,0x973d871b
         DCD 0x96cd908e,0x966d99fa,0x960da360,0x959dacc0,0x952db619,0x94ddbf6b,0x946dc8b8,0x940dd1fe
         DCD 0x939ddb3e,0x933de478,0x92ededab,0x927df6d9,0x922e0000,0x91be0922,0x915e123e,0x910e1b53
         DCD 0x90ae2463,0x905e2d6d,0x8fee3672,0x8fae3f70,0x8f3e486a,0x8eee515d,0x8e8e5a4b,0x8e3e6333
         DCD 0x8dde6c16,0x8d8e74f3,0x8d3e7dcb,0x8cde869e,0x8c8e8f6b,0x8c2e9833,0x8beea0f5,0x8b8ea9b3
         DCD 0x8b3eb26b,0x8aeebb1e,0x8a8ec3cc,0x8a4ecc74,0x89fed518,0x89aeddb7,0x894ee651,0x890eeee5
         DCD 0x88bef775,0x886f0000,0x882f0886,0x87cf1108,0x878f1984,0x873f21fc,0x86ef2a6f,0x86af32dd
         DCD 0x865f3b47,0x860f43ac,0x85cf4c0c,0x857f5468,0x853f5cbf,0x84ef6512,0x84af6d60,0x846f75aa
         DCD 0x840f7df0,0x83df8630,0x838f8e6d,0x834f96a5,0x830f9ed9,0x82bfa709,0x827faf34,0x823fb75b
         DCD 0x81ffbf7e,0x81afc79d,0x817fcfb7,0x812fd7ce,0x80efdfe0,0x80afe7ee,0x806feff8,0x802ff7fe

         END