#include <seccells/scthreads.h>

.section .text

.global scthreads_call
.global scthreads_return
.global scthreads_switch
.extern contexts

scthreads_call:
    /*
     * a0: args pointer
     * a1: continuation address
     * a2: target usid
     */
    /*
     * Calculate offset into context array based on current USID, load context base address and add offset
     * Save s1, s2, s3 onto the stack so that we can clobber them and easily restore them later on
     */
    sd s1,  (-1*WORDSIZE)(sp)
    sd s3,  (-3*WORDSIZE)(sp)
    csrr s1, usid
    ld s3, contexts
    slli s1, s1, CONTEXT_SIZE_BITS
    sd s2,  (-2*WORDSIZE)(sp)
    add s2, s3, s1
    /* At this point, we have the address of the context we're looking for in s2 */
    sd ra,  (1*WORDSIZE)(s2)
    sd sp,  (2*WORDSIZE)(s2)
    sd gp,  (3*WORDSIZE)(s2)
    sd s0,  (4*WORDSIZE)(s2)
    /* Don't store s1, s2, s3 because they're already on the stack */
    sd s4,  (8*WORDSIZE)(s2)
    sd s5,  (9*WORDSIZE)(s2)
    sd s6,  (10*WORDSIZE)(s2)
    sd s7,  (11*WORDSIZE)(s2)
    sd s8,  (12*WORDSIZE)(s2)
    sd s9,  (13*WORDSIZE)(s2)
    sd s10, (14*WORDSIZE)(s2)
    sd s11, (15*WORDSIZE)(s2)
    sd a0,  (16*WORDSIZE)(s2)
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

    /* Do the actual compartment switch */
    jals a2, .call_switch
.call_switch:
    entry

    /* Calculate offset into context array based on current USID */
    csrr s1, usid
    slli s1, s1, CONTEXT_SIZE_BITS
    /* Add offset to context array base (still have pointer to context array in s3) */
    add s2, s3, s1
    /* Call function within other thread: set function address and arguments, save URID for returning */
    csrr s1, urid
    sd s1,  (32*WORDSIZE)(s2)
    /* At this point, we have the address of the context we're looking for in s2 */
    ld ra,  (2*WORDSIZE)(s2)
    ld sp,  (2*WORDSIZE)(s2)
    ld gp,  (3*WORDSIZE)(s2)
    ld s0,  (4*WORDSIZE)(s2)
    /*
     * s1, s2, s3 were stored on the stack instead of the context due to clobbering
     * Restore s2 only in the end when we don't need it anymore
     */
    ld s1,  (-1*WORDSIZE)(sp)
    ld s3,  (-3*WORDSIZE)(sp)
    ld s4,  (8*WORDSIZE)(s2)
    ld s5,  (9*WORDSIZE)(s2)
    ld s6,  (10*WORDSIZE)(s2)
    ld s7,  (11*WORDSIZE)(s2)
    ld s8,  (12*WORDSIZE)(s2)
    ld s9,  (13*WORDSIZE)(s2)
    ld s10, (14*WORDSIZE)(s2)
    ld s11, (15*WORDSIZE)(s2)
    /* Don't restore a0, a1 because that is where we jump to + arguments */
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
    ld s2,  (-2*WORDSIZE)(sp)
    jr a1


scthreads_return:
    /* a0: return value (pointer) */
    /*
     * Calculate offset into context array based on current USID, load context base address and add offset
     * Save s1, s2, s3 onto the stack so that we can clobber them and easily restore them later on
     */
    sd s1,  (-1*WORDSIZE)(sp)
    sd s3,  (-3*WORDSIZE)(sp)
    csrr s1, usid
    ld s3, contexts
    slli s1, s1, CONTEXT_SIZE_BITS
    sd s2,  (-2*WORDSIZE)(sp)
    add s2, s3, s1
    /* At this point, we have the address of the context we're looking for in s2 */
    /* Load USID to return to */
    ld a1,  (32*WORDSIZE)(s2)
    /* Actually store the registers into the context */
    sd ra,  (1*WORDSIZE)(s2)
    sd sp,  (2*WORDSIZE)(s2)
    sd gp,  (3*WORDSIZE)(s2)
    sd s0,  (4*WORDSIZE)(s2)
    /* Don't store s1, s2, s3 because they're already on the stack */
    sd s4,  (8*WORDSIZE)(s2)
    sd s5,  (9*WORDSIZE)(s2)
    sd s6,  (10*WORDSIZE)(s2)
    sd s7,  (11*WORDSIZE)(s2)
    sd s8,  (12*WORDSIZE)(s2)
    sd s9,  (13*WORDSIZE)(s2)
    sd s10, (14*WORDSIZE)(s2)
    sd s11, (15*WORDSIZE)(s2)
    sd a0,  (16*WORDSIZE)(s2)
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

    /* Do the actual compartment switch */
    jals a1, .return_switch
.return_switch:
    entry

    /* Calculate offset into context list based on current USID */
    csrr s1, usid
    slli s1, s1, CONTEXT_SIZE_BITS
    /* Add offset to context array base (still have pointer to context array in s3) */
    add s2, s3, s1
    /* At this point, we have the address of the context we're looking for in s2 */
    ld ra,  (1*WORDSIZE)(s2)
    ld sp,  (2*WORDSIZE)(s2)
    ld gp,  (3*WORDSIZE)(s2)
    ld s0,  (4*WORDSIZE)(s2)
    /*
     * s1, s2, s3 were stored on the stack instead of the context due to clobbering
     * Restore s2 only in the end when we don't need it anymore
     */
    ld s1,  (-1*WORDSIZE)(sp)
    ld s3,  (-3*WORDSIZE)(sp)
    ld s4,  (8*WORDSIZE)(s2)
    ld s5,  (9*WORDSIZE)(s2)
    ld s6,  (10*WORDSIZE)(s2)
    ld s7,  (11*WORDSIZE)(s2)
    ld s8,  (12*WORDSIZE)(s2)
    ld s9,  (13*WORDSIZE)(s2)
    ld s10, (14*WORDSIZE)(s2)
    ld s11, (15*WORDSIZE)(s2)
    /* a0 is passed as return value (pointer) */
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
    ld s2,  (-2*WORDSIZE)(sp)
    ret


scthreads_switch:
    /* a0: target usid */
    /*
     * Calculate offset into context array based on current USID, load context base address and add offset
     * Save s1, s2, s3 onto the stack so that we can clobber them and easily restore them later on
     */
    sd s1,  (-1*WORDSIZE)(sp)
    sd s3,  (-3*WORDSIZE)(sp)
    csrr s1, usid
    ld s3, contexts
    slli s1, s1, CONTEXT_SIZE_BITS
    sd s2,  (-2*WORDSIZE)(sp)
    add s2, s3, s1
    /* At this point, we have the address of the context we're looking for in s2 */
    sd ra,  (1*WORDSIZE)(s2)
    sd sp,  (2*WORDSIZE)(s2)
    sd gp,  (3*WORDSIZE)(s2)
    sd s0,  (4*WORDSIZE)(s2)
    /* Don't store s1, s2, s3 because they're already on the stack */
    sd s4,  (8*WORDSIZE)(s2)
    sd s5,  (9*WORDSIZE)(s2)
    sd s6,  (10*WORDSIZE)(s2)
    sd s7,  (11*WORDSIZE)(s2)
    sd s8,  (12*WORDSIZE)(s2)
    sd s9,  (13*WORDSIZE)(s2)
    sd s10, (14*WORDSIZE)(s2)
    sd s11, (15*WORDSIZE)(s2)
    sd a0,  (16*WORDSIZE)(s2)
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

    /* Do the actual compartment switch */
    jals a0, .switch_switch
.switch_switch:
    entry

    /* Calculate offset into context list based on current USID */
    csrr s1, usid
    slli s1, s1, CONTEXT_SIZE_BITS
    /* Add offset to context array base (still have pointer to context array in s3) */
    add s2, s3, s1
    /* At this point, we have the address of the context we're looking for in s2 */
    ld ra,  (1*WORDSIZE)(s2)
    ld sp,  (2*WORDSIZE)(s2)
    ld gp,  (3*WORDSIZE)(s2)
    ld s0,  (4*WORDSIZE)(s2)
    /*
     * s1, s2, s3 were stored on the stack instead of the context due to clobbering
     * Restore s2 only in the end when we don't need it anymore
     */
    ld s1,  (-1*WORDSIZE)(sp)
    ld s3,  (-3*WORDSIZE)(sp)
    ld s4,  (8*WORDSIZE)(s2)
    ld s5,  (9*WORDSIZE)(s2)
    ld s6,  (10*WORDSIZE)(s2)
    ld s7,  (11*WORDSIZE)(s2)
    ld s8,  (12*WORDSIZE)(s2)
    ld s9,  (13*WORDSIZE)(s2)
    ld s10, (14*WORDSIZE)(s2)
    ld s11, (15*WORDSIZE)(s2)
    ld a0,  (16*WORDSIZE)(s2)
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
    ld s2,  (-2*WORDSIZE)(sp)
    ret
