#include <string.h>
#include <utils/util.h>
#include <sel4debug/arch/registers.h>

#include "scthreads.h"
#include "alloc.h"
#include "seccells.h"

seL4_UserContext **contexts = 0;

extern void scthreads_save_context(void *cont_addr);
extern void scthreads_restore_context(void);

void scthreads_init_contexts(seL4_BootInfo *info, void *base_address, unsigned int secdiv_num) {
    /* Currently, only SecDiv 1 (the initial SecDiv) is allowed to initialize the threading contexts */
    unsigned int usid;
    csrr_usid(usid);
    assert(usid == 1);

    seL4_Error error;
    /* Calculate / set necessary range sizes */
    seL4_Word context_list_size = ROUND_UP(secdiv_num * sizeof(seL4_UserContext *), BIT(seL4_MinRangeBits));
    seL4_Word context_size = ROUND_UP(sizeof(seL4_UserContext), BIT(seL4_MinRangeBits));
    seL4_Word stack_size = ROUND_UP(USER_STACK_SIZE, BIT(seL4_MinRangeBits));

    seL4_Word vaddr = (seL4_Word) base_address;

    /* Map context list */
    seL4_CPtr context_list = alloc_object(info, seL4_RISCV_RangeObject, context_list_size);
    error = seL4_RISCV_Range_Map(context_list, seL4_CapInitThreadVSpace, vaddr, seL4_ReadWrite,
                                 seL4_RISCV_ExecuteNever);
    ZF_LOGF_IF(error != seL4_NoError, "Failed to map context list @ %p", (void *)vaddr);
    /* Point global pointer to context list memory area */
    contexts = (seL4_UserContext **)vaddr;
    vaddr += context_list_size;

    /* Map and initialize contexts (including stacks) */
    for (unsigned int secdiv = 1; secdiv < secdiv_num; secdiv++) {
        /* Allocate and map context */
        seL4_CPtr context = alloc_object(info, seL4_RISCV_RangeObject, context_size);
        error = seL4_RISCV_Range_Map(context, seL4_CapInitThreadVSpace, vaddr, seL4_ReadWrite,
                                     seL4_RISCV_ExecuteNever);
        ZF_LOGF_IF(error != seL4_NoError, "Failed to map context @ %p", (void *)vaddr);
        /* Initialize context */
        seL4_UserContext *ctx = (seL4_UserContext *)vaddr;
        memset(ctx, 0, sizeof(seL4_UserContext));
        contexts[secdiv] = ctx;
        vaddr += context_size;

        /* Allocate and map stack */
        seL4_CPtr stack = alloc_object(info, seL4_RISCV_RangeObject, stack_size);
        error = seL4_RISCV_Range_Map(stack, seL4_CapInitThreadVSpace, vaddr, seL4_ReadWrite,
                                     seL4_RISCV_ExecuteNever);
        ZF_LOGF_IF(error != seL4_NoError, "Failed to map stack @ %p", (void *)vaddr);
        /* Assign stack to context (stack top (i.e., last accessible word) since stack grows downwards) */
        ctx->sp = vaddr + stack_size - sizeof(seL4_Word);
        vaddr += stack_size;

        /* Transfer access privileges only to the SecDiv in question (that is not the initial SecDiv) */
        if (secdiv != 1) {
            tfer(ctx->sp, secdiv, RT_R | RT_W);
            tfer(ctx, secdiv, RT_R | RT_W);
        }
    }

    /* Make context list read-only for all SecDivs */
    prot(contexts, RT_R);
    for (unsigned int secdiv = 2; secdiv < secdiv_num; secdiv++) {
        grant(contexts, secdiv, RT_R);
    }
}

seL4_UserContext *scthreads_get_current_context(void) {
    seL4_Word usid;
    csrr_usid(usid);
    return contexts[usid];
}

void scthreads_switch(seL4_Word usid, void *cont_addr) {
    scthreads_save_context(cont_addr);
    jals(usid, thread_entry);
thread_entry:
    entry();
    scthreads_restore_context();
}
