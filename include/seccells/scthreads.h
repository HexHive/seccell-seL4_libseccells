#ifndef SCTHREADS_H
#define SCTHREADS_H

/*
 * ####################
 * Common
 * ####################
 */

#include <sel4/config.h>
#include <seccells/gen_config.h>
/* First of all, make sure we're compiling for 64 bit SecCells systems only */
#if (__riscv_xlen != 64) || (!defined(CONFIG_RISCV_SECCELL))
#error "Unsupported system: Please compile for 64 bit RISC-V with SecCells support!"
#endif

/* Default stack size is 64kB => see CMakeLists.txt */
#define USER_STACK_SIZE CONFIG_SCTHREADS_STACK_SIZE

#ifdef __ASSEMBLER__
/*
 * ####################
 * Assembler-only
 * ####################
 */
#define WORDSIZE      8  /* A word is 8 bytes (64 bits) */
#define WORDSIZESHIFT 3  /* Shift by 3 to multiply by 8 */
#else
/*
 * ####################
 * C-only
 * ####################
 */
#include <sel4/sel4.h>
#include <seccells/seccells.h>

typedef enum {
    SCSWITCH = 0,
    SCCALL = 1,
    SCRETURN = 2
} switch_type_t;

extern seL4_UserContext **contexts;

void scthreads_init_contexts(seL4_BootInfo *info, void *base_address, unsigned int secdiv_num);
void scthreads_set_thread_entry(seL4_Word target_usid, void *entry_point);
/* Expose the assembly function as well for low-level access -- scthreads_{call,switch,return} should be preferred */
void scthreads_switch_internal(seL4_Word usid, void *(*start_routine)(void *), void *restrict args, switch_type_t flag);
void scthreads_switch(seL4_Word target_usid);
void *scthreads_call(seL4_Word target_usid, void *(*start_routine)(void *), void *restrict args);
void scthreads_return(void *ret);

static inline seL4_UserContext *scthreads_get_current_context(void) {
    seL4_Word usid;
    csrr_usid(usid);
    return contexts[usid];
}
#endif

#endif /* SDTHTREADS_H */
