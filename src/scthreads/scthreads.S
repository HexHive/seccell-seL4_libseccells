#include "scthreads.h"

.section .text

.global scthreads_save_context
.global scthreads_restore_context
.extern contexts

scthreads_save_context:
    /* t0, t1 get clobbered - we need temporary registers, unfortunately */
    /* Calculate offset into context list */
    csrr t0, usid
    slli t0, t0, WORDSIZESHIFT
    /* Load context list address and add offset */
    la t1, contexts
    add t1, t1, t0
    /* At this point, we have the address of the context we're looking for in t1 */
    sd a0,  (0*WORDSIZE)(t1)     /* Store the parameter as pc since we want to continue where the caller left off */
    sd ra,  (1*WORDSIZE)(t1)
    sd sp,  (2*WORDSIZE)(t1)
    sd gp,  (3*WORDSIZE)(t1)
    sd s0,  (4*WORDSIZE)(t1)
    sd s1,  (5*WORDSIZE)(t1)
    sd s2,  (6*WORDSIZE)(t1)
    sd s3,  (7*WORDSIZE)(t1)
    sd s4,  (8*WORDSIZE)(t1)
    sd s5,  (9*WORDSIZE)(t1)
    sd s6,  (10*WORDSIZE)(t1)
    sd s7,  (11*WORDSIZE)(t1)
    sd s8,  (12*WORDSIZE)(t1)
    sd s9,  (13*WORDSIZE)(t1)
    sd s10, (14*WORDSIZE)(t1)
    sd s11, (15*WORDSIZE)(t1)
    sd a0,  (16*WORDSIZE)(t1)
    sd a1,  (17*WORDSIZE)(t1)
    sd a2,  (18*WORDSIZE)(t1)
    sd a3,  (19*WORDSIZE)(t1)
    sd a4,  (20*WORDSIZE)(t1)
    sd a5,  (21*WORDSIZE)(t1)
    sd a6,  (22*WORDSIZE)(t1)
    sd a7,  (23*WORDSIZE)(t1)
    /* Blank t0, t1 in seL4_UserContext struct due to them being clobbered here */
    addi t0, zero, 0
    sd t0,  (24*WORDSIZE)(t1)
    sd t0,  (25*WORDSIZE)(t1)
    sd t2,  (26*WORDSIZE)(t1)
    sd t3,  (27*WORDSIZE)(t1)
    sd t4,  (28*WORDSIZE)(t1)
    sd t5,  (29*WORDSIZE)(t1)
    sd t6,  (30*WORDSIZE)(t1)
    sd tp,  (31*WORDSIZE)(t1)
    ret

scthreads_restore_context:
    /* t0, t1 get clobbered - we need temporary registers, unfortunately */
    /* Calculate offset into context list */
    csrr t0, usid
    slli t0, t0, WORDSIZESHIFT
    /* Load context list address and add offset */
    la t1, contexts
    add t1, t1, t0
    /* At this point, we have the address of the context we're looking for in t1 */
    ld ra,  (0*WORDSIZE)(t1)     /* Load caller-defined value as ra to continue execution there after restoring */
    /* Ignore ra from seL4_UserContext struct due to ra being set explicitely above */
    ld sp,  (2*WORDSIZE)(t1)
    ld gp,  (3*WORDSIZE)(t1)
    ld s0,  (4*WORDSIZE)(t1)
    ld s1,  (5*WORDSIZE)(t1)
    ld s2,  (6*WORDSIZE)(t1)
    ld s3,  (7*WORDSIZE)(t1)
    ld s4,  (8*WORDSIZE)(t1)
    ld s5,  (9*WORDSIZE)(t1)
    ld s6,  (10*WORDSIZE)(t1)
    ld s7,  (11*WORDSIZE)(t1)
    ld s8,  (12*WORDSIZE)(t1)
    ld s9,  (13*WORDSIZE)(t1)
    ld s10, (14*WORDSIZE)(t1)
    ld s11, (15*WORDSIZE)(t1)
    ld a0,  (16*WORDSIZE)(t1)
    ld a1,  (17*WORDSIZE)(t1)
    ld a2,  (18*WORDSIZE)(t1)
    ld a3,  (19*WORDSIZE)(t1)
    ld a4,  (20*WORDSIZE)(t1)
    ld a5,  (21*WORDSIZE)(t1)
    ld a6,  (22*WORDSIZE)(t1)
    ld a7,  (23*WORDSIZE)(t1)
    /* Ignore t0, t1 from seL4_UserContext struct due to them being clobbered here */
    ld t2,  (26*WORDSIZE)(t1)
    ld t3,  (27*WORDSIZE)(t1)
    ld t4,  (28*WORDSIZE)(t1)
    ld t5,  (29*WORDSIZE)(t1)
    ld t6,  (30*WORDSIZE)(t1)
    ld tp,  (31*WORDSIZE)(t1)
    ret
