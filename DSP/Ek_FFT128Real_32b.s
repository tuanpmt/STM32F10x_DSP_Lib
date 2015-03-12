;   E_FFT128Real_32b:  32 bit FFT of 128 real elements for ARM Cortex-M3    
;--------------------------------------------------------------------------
;(c) 2009 Ivan Mellen                                        September 2009 
; --------------------------------------------------------------------------
; Free Personal, Non-Commercial Use License. 
; The Software is licensed to you for your personal, NON-COMMERCIAL USE.
; If you have questions about this license, need other sizes or would like
; a different license please email : imellen(at)embeddedsignals(dot)com
;
;  This file contains only one function:
;  void FFT128Real_32b(int *y, int *x);  // KEIL version 
;   
; 32 bit real FFT benchmarks on STM32 Cortex-M3,
; coefficients in flash, including call overhead:  
; Speed is input data dependant.
;
;          Best case          |    Worse case          
; Size    Lat0   Lat1   Lat2  | Lat0     Lat1    Lat2
; 16      604					
; 32      1331					
; 64      3262					
; 128     7075						
; 256     16334						
; 512     35055						
; 1024    78634  85205  94627 | 97386    103942   112592
; 2048    167099					
; 4096    368062
;
;  
;
;N is 128 
;int x[N]   = { x0, x1, x2 ... x(N-1) }  ; 32 bit int scaled for  FFT, 128 real elements
;int y[N+2] = {DC,0,reF1,imF1,reF2,imF2,.. reF(N/2),0 }, 32 bit int, 66 complex elements


;  Input data restrictions: 
;    x must be scaled to 1/2 of the full range to avoid overflow (+- 2^30) 

                       
             THUMB
             AREA    FFTLIB2_CORTEXM3, CODE, READONLY        
             EXPORT  FFT128Real_32b
             ALIGN 8
        
         
FFT128Real_32b
            stmdb sp!, {r4-r11, lr}
            mov.w r2,#0x80
                   
            movs lr,#0
            mov r12,lr
            lsls r3,r2,#0x15 
firstStage
            adds.w lr, r1, lr, lsl #0x03
            ldr.w r5, [lr, #+0x004]
            ldr.w r4, [lr, #+0x000]
            adds.w lr, lr, r2
            ldr.w r9, [lr, #+0x004]
            ldr.w r8, [lr, #+0x000]
            adds.w lr, lr, r2
            ldr.w r7, [lr, #+0x004]
            ldr.w r6, [lr, #+0x000]
            adds.w lr, lr, r2
            ldr.w r11, [lr, #+0x004]
            ldr.w r10, [lr, #+0x000]
            adds.w lr, lr, r2
            add r8, r10
            add r9, r11
            sub.w r10, r8, r10, lsl #0x01
            sub.w r11, r9, r11, lsl #0x01
            mov.w r4, r4, asr #0x02
            mov.w r5, r5, asr #0x02
            add.w r4, r4, r6, asr #0x02
            add.w r5, r5, r7, asr #0x02
            sub.w r6, r4, r6, asr #0x01
            sub.w r7, r5, r7, asr #0x01
            add.w r4, r4, r8, asr #0x02
            add.w r5, r5, r9, asr #0x02
            sub.w r8, r4, r8, asr #0x01
            sub.w r9, r5, r9, asr #0x01
            add.w r6, r6, r11, asr #0x02
            sub.w r7, r7, r10, asr #0x02
            sub.w r11, r6, r11, asr #0x01
            add.w r10, r7, r10, asr #0x01
            str r5, [r0, #0x04]
            str r4, [r0], #+0x08
            str r7, [r0, #0x04]
            str r6, [r0], #+0x08
            str.w r9, [r0, #+0x004]
            str r8, [r0], #+0x08
            str.w r10, [r0, #+0x004]
            str r11, [r0], #+0x08
            adds.w r12, r12, r3
            rbit lr, r12
            bne firstStage
firstStageFinished
            sub.w r1, r0, r2, lsl #0x02
            mov.w r3, #0x00000020
            lsrs r2, r2, #0x05
            it eq
            ldmiaeq sp!, {r4-r11, pc}
            adr r0,coef_table           
nextStage
            push {r1-r2}
            add.w r12, r3, r3, lsl #0x01
            add r1, r12
            sub.w r2, r2, #0x00010000
nextBlock
            add.w r2, r2, r3, lsl #0x0D
nextButterfly
            ldr r5, [r1, #0x04]
            ldr r4, [r1, #0x00]
            subs r1, r1, r3
            ldr.w r11, [r0, #+0x004]
            ldr r10, [r0], #+0x08
            smull lr, r12, r5, r10
            smull r5, lr, r5, r11
            smull r5, r11, r4, r11
            subs.w r11, r12, r11
            smull r5, r10, r4, r10
            adds.w r10, r10, lr
            ldr r5, [r1, #0x04]
            ldr r4, [r1, #0x00]
            subs r1, r1, r3
            ldr.w r9, [r0, #+0x004]
            ldr r8, [r0], #+0x08
            smull lr, r12, r5, r8
            smull r5, lr, r5, r9
            smull r5, r9, r4, r9
            subs.w r9, r12, r9
            smull r5, r8, r4, r8
            adds.w r8, r8, lr
            ldr r5, [r1, #0x04]
            ldr r4, [r1, #0x00]
            subs r1, r1, r3
            ldr r7, [r0, #0x04]
            ldr r6, [r0], #+0x08
            smull lr, r12, r5, r6
            smull r5, lr, r5, r7
            smull r5, r7, r4, r7
            subs.w r7, r12, r7
            smull r5, r6, r4, r6
            adds.w r6, r6, lr
            ldr r5, [r1, #0x04]
            ldr r4, [r1, #0x00]
            adds r1, #0x00
            add r8, r10
            add r9, r11
            sub.w r10, r8, r10, lsl #0x01
            sub.w r11, r9, r11, lsl #0x01
            mov.w r4, r4, asr #0x02
            mov.w r5, r5, asr #0x02
            add.w r4, r4, r6, asr #0x01
            add.w r5, r5, r7, asr #0x01
            sub.w r6, r4, r6
            sub.w r7, r5, r7
            add.w r4, r4, r8, asr #0x01
            add.w r5, r5, r9, asr #0x01
            sub.w r8, r4, r8
            sub.w r9, r5, r9
            add.w r6, r6, r11, asr #0x01
            sub.w r7, r7, r10, asr #0x01
            sub.w r11, r6, r11
            add.w r10, r7, r10
            str r5, [r1, #0x04]
            str r4, [r1, #0x00]
            adds r1, r1, r3
            str r7, [r1, #0x04]
            str r6, [r1, #0x00]
            adds r1, r1, r3
            str.w r9, [r1, #+0x004]
            str.w r8, [r1, #+0x000]
            adds r1, r1, r3
            str.w r10, [r1, #+0x004]
            str r11, [r1], #+0x08
            subs.w r2, r2, #0x00010000
            bge nextButterfly
            add.w r12, r3, r3, lsl #0x01
            add r1, r12
            sub.w r2, r2, #0x00000001
            movs.w lr, r2, lsl #0x10
            it ne
            subne.w r0, r0, r12
            bne nextBlock
            pop {r1-r2}
            mov.w r3, r3, lsl #0x02
            lsrs r2, r2, #0x02
            bne.w nextStage
            mov32 r11,wNRhalf
            mov r8, r1
            movw r9, #0x01F8
            add r9, r8
            ldr.w r5, [r8, #+0x004]
            ldr r7, [r8], #+0x08
            adds.w r1, r7, r5
            str r1, [r8, #-0x08]
            movs r1, #0x00
            str r1, [r8, #-0x04]
            subs r7, r7, r5
            str.w r7, [r9, #+0x008]
            movw r0, #0x001F
for_k
            ldr.w r3, [r11, #+0x004]
            ldr r4, [r11], #+0x08
            ldr.w r5, [r8, #+0x004]
            ldr r7, [r8], #+0x08
            ldr.w r6, [r9, #+0x004]
            ldr r2, [r9], #-0x08
            mov r12,#0x7fffffff 
            sub.w r12, r12, r4, asr #0x01
            smull lr, r1, r7, r4
            mov.w r1, r1, asr #0x02
            smull lr, r10, r5, r3
            sub.w r1, r1, r10, asr #0x02
            smull lr, r10, r2, r12
            add.w r1, r1, r10, asr #0x01
            smull lr, r10, r6, r3
            sub.w r1, r1, r10, asr #0x02
            mov.w r1, r1, lsl #0x02
            str r1, [r8, #-0x08]
            smull lr, r1, r5, r4
            mov.w r1, r1, asr #0x02
            smull lr, r10, r7, r3
            add.w r1, r1, r10, asr #0x02
            smull lr, r10, r2, r3
            sub.w r1, r1, r10, asr #0x02
            smull lr, r10, r6, r12
            sub.w r1, r1, r10, asr #0x01
            mov.w r1, r1, lsl #0x02
            str r1, [r8, #-0x04]
            smull lr, r1, r2, r4
            mov.w r1, r1, asr #0x02
            smull lr, r10, r6, r3
            add.w r1, r1, r10, asr #0x02
            smull lr, r10, r7, r12
            add.w r1, r1, r10, asr #0x01
            smull lr, r10, r5, r3
            add.w r1, r1, r10, asr #0x02
            mov.w r1, r1, lsl #0x02
            str.w r1, [r9, #+0x008]
            smull lr, r1, r6, r4
            mov.w r1, r1, asr #0x02
            smull lr, r10, r2, r3
            sub.w r1, r1, r10, asr #0x02
            smull lr, r10, r7, r3
            add.w r1, r1, r10, asr #0x02
            smull lr, r10, r5, r12
            sub.w r1, r1, r10, asr #0x01
            mov.w r1, r1, lsl #0x02
            str.w r1, [r9, #+0x00C]
            subs r0, #0x01
            bne for_k
            ldr.w r5, [r8, #+0x004]
            rsb.w r5, r5, #0x00000000
            str.w r5, [r8, #+0x004]
            ldmia sp!, {r4-r11, pc}
            
            ALIGN 2

            
coef_table 
  DCD 0x7fffffff, 0x00000000, 0x7fffffff, 0x00000000, 0x7fffffff, 0x00000000
  DCD 0x30fbc54d, 0x7641af3d, 0x7641af3d, 0x30fbc54d, 0x5a82799a, 0x5a82799a
  DCD 0xa57d8666, 0x5a82799a, 0x5a82799a, 0x5a82799a, 0x00000000, 0x7fffffff
  DCD 0x89be50c3, 0xcf043ab3, 0x30fbc54d, 0x7641af3d, 0xa57d8666, 0x5a82799a
  DCD 0x7fffffff, 0x00000000, 0x7fffffff, 0x00000000, 0x7fffffff, 0x00000000
  DCD 0x7a7d055b, 0x25280c5e, 0x7f62368f, 0x0c8bd35e, 0x7d8a5f40, 0x18f8b83c
  DCD 0x6a6d98a4, 0x471cece7, 0x7d8a5f40, 0x18f8b83c, 0x7641af3d, 0x30fbc54d
  DCD 0x5133cc94, 0x62f201ac, 0x7a7d055b, 0x25280c5e, 0x6a6d98a4, 0x471cece7
  DCD 0x30fbc54d, 0x7641af3d, 0x7641af3d, 0x30fbc54d, 0x5a82799a, 0x5a82799a
  DCD 0x0c8bd35e, 0x7f62368f, 0x70e2cbc6, 0x3c56ba70, 0x471cece7, 0x6a6d98a4
  DCD 0xe70747c4, 0x7d8a5f40, 0x6a6d98a4, 0x471cece7, 0x30fbc54d, 0x7641af3d
  DCD 0xc3a94590, 0x70e2cbc6, 0x62f201ac, 0x5133cc94, 0x18f8b83c, 0x7d8a5f40
  DCD 0xa57d8666, 0x5a82799a, 0x5a82799a, 0x5a82799a, 0x00000000, 0x7fffffff
  DCD 0x8f1d343a, 0x3c56ba70, 0x5133cc94, 0x62f201ac, 0xe70747c4, 0x7d8a5f40
  DCD 0x8275a0c0, 0x18f8b83c, 0x471cece7, 0x6a6d98a4, 0xcf043ab3, 0x7641af3d
  DCD 0x809dc971, 0xf3742ca2, 0x3c56ba70, 0x70e2cbc6, 0xb8e31319, 0x6a6d98a4
  DCD 0x89be50c3, 0xcf043ab3, 0x30fbc54d, 0x7641af3d, 0xa57d8666, 0x5a82799a
  DCD 0x9d0dfe54, 0xaecc336c, 0x25280c5e, 0x7a7d055b, 0x9592675c, 0x471cece7
  DCD 0xb8e31319, 0x9592675c, 0x18f8b83c, 0x7d8a5f40, 0x89be50c3, 0x30fbc54d
  DCD 0xdad7f3a2, 0x8582faa5, 0x0c8bd35e, 0x7f62368f, 0x8275a0c0, 0x18f8b83c

      
  DCD 0x7fffffff, 0x80000000 
wNRhalf
  DCD                         0x79b82684, 0x80277872, 0x73742ca2, 0x809dc971, 0x6d37ef91, 0x8162aa04
  DCD 0x670747c4, 0x8275a0c0, 0x60e60685, 0x83d60412, 0x5ad7f3a2, 0x8582faa5, 0x54e0cb15, 0x877b7bec
  DCD 0x4f043ab3, 0x89be50c3, 0x4945dfec, 0x8c4a142f, 0x43a94590, 0x8f1d343a, 0x3e31e19b, 0x9235f2ec
  DCD 0x38e31319, 0x9592675c, 0x33c0200c, 0x99307ee0, 0x2ecc336c, 0x9d0dfe54, 0x2a0a5b2e, 0xa1288376
  DCD 0x257d8666, 0xa57d8666, 0x21288376, 0xaa0a5b2e, 0x1d0dfe54, 0xaecc336c, 0x19307ee0, 0xb3c0200c
  DCD 0x1592675c, 0xb8e31319, 0x1235f2ec, 0xbe31e19b, 0x0f1d343a, 0xc3a94590, 0x0c4a142f, 0xc945dfec
  DCD 0x09be50c3, 0xcf043ab3, 0x077b7bec, 0xd4e0cb15, 0x0582faa5, 0xdad7f3a2, 0x03d60412, 0xe0e60685
  DCD 0x0275a0c0, 0xe70747c4, 0x0162aa04, 0xed37ef91, 0x009dc971, 0xf3742ca2, 0x00277872, 0xf9b82684

  END    