#include <string.h>
#include <sel4/sel4.h>
#include <utils/util.h>
#include <alloc/alloc.h>
#include <seccells/scthreads.h>

/* Globals */
seL4_UserContext *contexts = NULL;

/*
 * Layout for the context store:
 *
 * +------------------------------------+ <----- contexts
 * |   (unused and not mapped beause    |
 * |    context 0 is the supervisor)    |
 * +------------------------------------+ <----- contexts + (1 * BIT(CONTEXT_SIZE_BITS))
 * |  seL4_UserContext (for registers)  | ---+
 * +------------------------------------+    |
 * |  stack region for context 1        | <--+
 * |                                    |
 * +------------------------------------+ <----- contexts + (2 * BIT(CONTEXT_SIZE_BITS))
 * |                 .                  |
 * |                 .                  |
 * |                 .                  |
  * +------------------------------------+ <----- contexts + (n * BIT(CONTEXT_SIZE_BITS))
 * |  seL4_UserContext (for registers)  | ---+
 * +------------------------------------+    |
 * |  stack region for context n        | <--+
 * |                                    |
 * +------------------------------------+
 */

void scthreads_init_contexts(seL4_BootInfo *info, void *base_address, unsigned int secdiv_num) {
    /* Currently, only SecDiv 1 (the initial SecDiv) is allowed to initialize the threading contexts */
    unsigned int usid;
    csrr_usid(usid);
    assert(usid == 1);

    /* Set base address */
    contexts = (seL4_UserContext *)base_address;
    /* Map and initialize contexts (including stacks) */
    for (unsigned int secdiv = 1; secdiv < secdiv_num; secdiv++) {
        /* Calculate address for the context */
        seL4_Word vaddr = (seL4_Word)base_address + (secdiv * BIT(CONTEXT_SIZE_BITS));

        /* Allocate and map context and stack */
        seL4_CPtr context = alloc_object(info, seL4_RISCV_RangeObject, BIT(CONTEXT_SIZE_BITS));
        seL4_Error error = seL4_RISCV_Range_Map(context, seL4_CapInitThreadVSpace, vaddr, seL4_ReadWrite,
                                                seL4_RISCV_ExecuteNever);
        ZF_LOGF_IF(error != seL4_NoError, "Failed to map context @ %p", (void *)vaddr);

        /* Initialize context */
        seL4_UserContext *ctx = (seL4_UserContext *)vaddr;
        memset(ctx, 0, sizeof(seL4_UserContext));

        /* Assign stack to context (top address since stack grows downwards => could potentially grow into context!) */
        ctx->sp = vaddr + BIT(CONTEXT_SIZE_BITS);

        /* Transfer access privileges only to the SecDiv in question (that is not the initial SecDiv) */
        if (secdiv != 1) {
            tfer(vaddr, secdiv, RT_R | RT_W);
        }
    }
}

void scthreads_set_thread_entry(seL4_Word target_usid, void *entry_point) {
    seL4_Word current_usid;
    csrr_usid(current_usid);

    grant(&scthreads_set_thread_entry, target_usid, RT_R | RT_W | RT_X);
    jals(target_usid, target_sd_entry);

target_sd_entry:
    entry();
    seL4_UserContext *thread_ctx = scthreads_get_current_context();
    thread_ctx->ra = (seL4_Word)entry_point;
    jals(current_usid, initial_sd_entry);

initial_sd_entry:
    entry();
}
