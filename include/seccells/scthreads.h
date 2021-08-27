#ifndef SCTHREADS_H
#define SCTHREADS_H

/*
 * ####################
 * Common
 * ####################
 */

#include <sel4/config.h>
/* First of all, make sure we're compiling for 64 bit SecCells systems only */
#if (__riscv_xlen != 64) || (!defined(CONFIG_RISCV_SECCELL))
#error "Unsupported system: Please compile for 64 bit RISC-V with SecCells support!"
#endif

/* 16 kB stack size => can be adapted if necessary */
#define USER_STACK_SIZE 16384

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
#include "seccells.h"

extern seL4_UserContext **contexts;

void scthreads_init_contexts(seL4_BootInfo *info, void *base_address, unsigned int secdiv_num);
void scthreads_set_thread_entry(seL4_Word target_usid, void *entry_point);
void scthreads_switch(seL4_Word usid);

static inline seL4_UserContext *scthreads_get_current_context(void) {
    seL4_Word usid;
    csrr_usid(usid);
    return contexts[usid];
}
#endif

#endif /* SDTHTREADS_H */
