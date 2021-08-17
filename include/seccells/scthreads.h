#ifndef SCTHREADS_H
#define SCTHREADS_H
#include <sel4/sel4.h>

/* 16 kB stack size => can be adapted if necessary */
#define USER_STACK_SIZE 16384

extern seL4_UserContext **contexts;

void scthreads_init_contexts(seL4_BootInfo *info, void *base_address, unsigned int secdiv_num);

#endif /* SDTHTREADS_H */
