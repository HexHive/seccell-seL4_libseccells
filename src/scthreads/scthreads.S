#include <seccells/scthreads.h>

.section .text

.global scthreads_save_context
.global scthreads_restore_context
.global scthreads_switch_internal
.extern contexts

scthreads_save_context:
    /* Save s1, s2, s3 onto the stack so that we can clobber them and easily restore them later on */
    addi sp, sp, -3*WORDSIZE
    sd s1, (0*WORDSIZE)(sp)
    sd s2, (1*WORDSIZE)(sp)
    sd s3, (2*WORDSIZE)(sp)
    /* Calculate offset into context list based on current USID */
    csrr s1, usid
    slli s1, s1, WORDSIZESHIFT
    /* Load context list address and add offset */
    ld s2, contexts
    add s2, s2, s1
    ld s2, 0(s2)
    /* At this point, we have the address of the context we're looking for in s2 */
    sd a0,  (16*WORDSIZE)(s2)
    /* In case of returning from thread: need to restore caller USID from context */
    addi s1, a3, -2
    bnez s1, .save_context_if_switch_or_call
.save_context_if_return:
    /* Load USID to return to */
    ld a0,  (32*WORDSIZE)(s2)
.save_context_if_switch_or_call:
    /* Copy saved ra from stack to context */
    ld s3,  (3*WORDSIZE)(sp)
    sd s3,  (1*WORDSIZE)(s2)
.save_context_endif_return:
    /* Store original caller sp, not the locally used one (that includes saved s1, s2, s3) */
    addi s3, sp, 4*WORDSIZE
    sd s3,  (2*WORDSIZE)(s2)
    sd gp,  (3*WORDSIZE)(s2)
    sd s0,  (4*WORDSIZE)(s2)
    /* Copy previous s1, s2, s3 from the stack into the context */
    ld s3,  (0*WORDSIZE)(sp)
    sd s3,  (5*WORDSIZE)(s2)
    ld s3,  (1*WORDSIZE)(sp)
    sd s3,  (6*WORDSIZE)(s2)
    ld s3,  (2*WORDSIZE)(sp)
    sd s3,  (7*WORDSIZE)(s2)
    sd s4,  (8*WORDSIZE)(s2)
    sd s5,  (9*WORDSIZE)(s2)
    sd s6,  (10*WORDSIZE)(s2)
    sd s7,  (11*WORDSIZE)(s2)
    sd s8,  (12*WORDSIZE)(s2)
    sd s9,  (13*WORDSIZE)(s2)
    sd s10, (14*WORDSIZE)(s2)
    sd s11, (15*WORDSIZE)(s2)
    sd a1,  (17*WORDSIZE)(s2)
    sd a2,  (18*WORDSIZE)(s2)
    sd a3,  (19*WORDSIZE)(s2)
    sd a4,  (20*WORDSIZE)(s2)
    sd a5,  (21*WORDSIZE)(s2)
    sd a6,  (22*WORDSIZE)(s2)
    sd a7,  (23*WORDSIZE)(s2)
    sd t0,  (24*WORDSIZE)(s2)
    sd t1,  (25*WORDSIZE)(s2)
    sd t2,  (26*WORDSIZE)(s2)
    sd t3,  (27*WORDSIZE)(s2)
    sd t4,  (28*WORDSIZE)(s2)
    sd t5,  (29*WORDSIZE)(s2)
    sd t6,  (30*WORDSIZE)(s2)
    sd tp,  (31*WORDSIZE)(s2)
    /* Restore s1, s2, s3 from the stack */
    ld s1, (0*WORDSIZE)(sp)
    ld s2, (1*WORDSIZE)(sp)
    ld s3, (2*WORDSIZE)(sp)
    addi sp, sp, 3*WORDSIZE
    ret

scthreads_restore_context:
    /* Clobber s1, s2, s3 - they're restored and overwritten from the saved context anyway */
    /* Calculate offset into context list based on current USID */
    csrr s1, usid
    slli s1, s1, WORDSIZESHIFT
    /* Load context list address and add offset */
    ld s2, contexts
    add s2, s2, s1
    ld s2, 0(s2)
    /* At this point, we have the address of the context we're looking for in s2 */
    ld sp,  (2*WORDSIZE)(s2)
    ld gp,  (3*WORDSIZE)(s2)
    /* Differentiate between scthreads_switch, scthreads_call, scthreads_return */
    addi s3, a3, -1
    beqz s3, .restore_context_else_if_call
    bgtz s3, .restore_context_else_if_return
.restore_context_if_switch:
    /* Thread switch: restore context */
    ld ra,  (1*WORDSIZE)(s2)
    ld a0,  (16*WORDSIZE)(s2)
    j .restore_context_endif_switch
.restore_context_else_if_return:
    /* Thread return: set return value/pointer */
    ld ra,  (1*WORDSIZE)(s2)
    mv a0, a2
    j .restore_context_endif_switch
.restore_context_else_if_call:
    /* Call function within other thread: set function address and arguments, save URID for returning */
    mv ra, a1
    mv a0, a2
    csrr s1, urid
    sd s1,  (32*WORDSIZE)(s2)
.restore_context_endif_switch:
    ld s0,  (4*WORDSIZE)(s2)
    ld s1,  (5*WORDSIZE)(s2)
    /* Restore s2 only in the end when we don't need it anymore */
    ld s3,  (7*WORDSIZE)(s2)
    ld s4,  (8*WORDSIZE)(s2)
    ld s5,  (9*WORDSIZE)(s2)
    ld s6,  (10*WORDSIZE)(s2)
    ld s7,  (11*WORDSIZE)(s2)
    ld s8,  (12*WORDSIZE)(s2)
    ld s9,  (13*WORDSIZE)(s2)
    ld s10, (14*WORDSIZE)(s2)
    ld s11, (15*WORDSIZE)(s2)
    ld a1,  (17*WORDSIZE)(s2)
    ld a2,  (18*WORDSIZE)(s2)
    ld a3,  (19*WORDSIZE)(s2)
    ld a4,  (20*WORDSIZE)(s2)
    ld a5,  (21*WORDSIZE)(s2)
    ld a6,  (22*WORDSIZE)(s2)
    ld a7,  (23*WORDSIZE)(s2)
    ld t0,  (24*WORDSIZE)(s2)
    ld t1,  (25*WORDSIZE)(s2)
    ld t2,  (26*WORDSIZE)(s2)
    ld t3,  (27*WORDSIZE)(s2)
    ld t4,  (28*WORDSIZE)(s2)
    ld t5,  (29*WORDSIZE)(s2)
    ld t6,  (30*WORDSIZE)(s2)
    ld tp,  (31*WORDSIZE)(s2)
    ld s2,  (6*WORDSIZE)(s2)
    ret

scthreads_switch_internal:
    /*
     * a0: target usid
     * a1: continuation address (if call)
     * a2: args pointer (if call) or return value pointer (if return)
     * a3: flag: switch (0) or call (1) or return from call (2)?
     */
    addi sp, sp, -WORDSIZE
    sd ra, 0(sp)
    jal scthreads_save_context
    addi sp, sp, WORDSIZE
    jals a0, .switch_sd
.switch_sd:
    entry
    /* scthreads_restore_context is a no-return function => execution continues as defined in the saved context */
    j scthreads_restore_context
