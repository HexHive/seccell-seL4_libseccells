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

/*
 * Default context size is 64kB, stack size is context_size - sizeof(seL4_UserContext) => see CMakeLists.txt
 * This needs to be bigger than seL4_MinRangeBits to actually allow mapping a range for that.
 */
#define CONTEXT_SIZE_BITS CONFIG_SCTHREADS_CONTEXT_SIZE_BITS

#ifdef __ASSEMBLER__
/*
 * ####################
 * Assembler-only
 * ####################
 */
#define WORDSIZE 8      /* A word is 8 bytes (64 bits) */
#else
/*
 * ####################
 * C-only
 * ####################
 */
#include <sel4/sel4.h>
#include <utils/util.h>
#include <seccells/seccells.h>

extern seL4_UserContext *contexts;

void scthreads_init_contexts(seL4_BootInfo *info, void *base_address, unsigned int secdiv_num);
void scthreads_set_thread_entry(seL4_Word target_usid, void *entry_point);
void scthreads_switch(seL4_Word target_usid);
void *scthreads_call(seL4_Word target_usid, void *(*start_routine)(void *), void *restrict args);
void scthreads_return(void *ret);

static inline seL4_UserContext *scthreads_get_current_context(void) {
    seL4_Word usid;
    csrr_usid(usid);
    char *ctx_ptr = (char *)contexts + (usid * BIT(CONTEXT_SIZE_BITS));
    return (seL4_UserContext *)ctx_ptr;
}
#endif

#endif /* SDTHTREADS_H */
