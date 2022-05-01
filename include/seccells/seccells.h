#ifndef SECCELLS_H
#define SECCELLS_H

/* Permissions */
#define RT_R 0b00000010     /* 0x2 */
#define RT_W 0b00000100     /* 0x4 */
#define RT_X 0b00001000     /* 0x8 */

/* Macros for assembly instructions */
/* Note: even though some of the instructions could be wrapped into static inline functions, macros were deliberately
   chosen to have unified calling conventions (similar to actual assembly instruction syntax). This is not very good
   software engineering practice and should be reworked in the future. */
#define entry()            \
   do {                    \
      asm volatile (       \
         "entry"           \
      );                   \
   } while (0)

#define jalrs(ret_reg, dest_reg, sd_reg)            \
   do {                                             \
      asm volatile (                                \
         "jalrs %[ret], %[dest], %[sd]"             \
         : [ret] "=r" (ret_reg)                     \
         : [dest] "r" (dest_reg), [sd] "r" (sd_reg) \
      );                                            \
   } while (0)

/* Attention: jals first argument is input and output at the same time but using it as output here causes linker issues
   since the store operation emitted by the compiler messes up offsets to the given label. We just use it as input for
   now. */
#define jals(sd_reg, dest_label)             \
   do {                                      \
      asm volatile goto (                    \
         "jals %[sd], %l[" #dest_label "]"   \
         :                                   \
         : [sd] "r" (sd_reg)                 \
         :                                   \
         : dest_label                        \
      );                                     \
   } while (0)

#define grant(addr_reg, sd_reg, perms_imm)                                    \
   do {                                                                       \
      asm volatile (                                                          \
         "grant %[addr], %[sd], %[perms]"                                     \
         :                                                                    \
         : [addr] "r" (addr_reg), [sd] "r" (sd_reg), [perms] "i" (perms_imm)  \
      );                                                                      \
   } while (0)

#define tfer(addr_reg, sd_reg, perms_imm)                                     \
   do {                                                                       \
      asm volatile (                                                          \
         "tfer %[addr], %[sd], %[perms]"                                      \
         :                                                                    \
         : [addr] "r" (addr_reg), [sd] "r" (sd_reg), [perms] "i" (perms_imm)  \
      );                                                                      \
   } while (0)

#define recv(addr_reg, sd_reg, perms_imm)                                     \
   do {                                                                       \
      asm volatile (                                                          \
         "recv %[addr], %[sd], %[perms]"                                      \
         :                                                                    \
         : [addr] "r" (addr_reg), [sd] "r" (sd_reg), [perms] "i" (perms_imm)  \
      );                                                                      \
   } while (0)

#define prot(addr_reg, perms_imm)                                    \
   do {                                                              \
      /* Attention: variable might shadow name from outer scope */   \
      uint64_t tmp_perms = (perms_imm);                              \
      asm volatile (                                                 \
         "prot %[addr], %[perms]"                                    \
         :                                                           \
         : [addr] "r" (addr_reg), [perms] "r" (tmp_perms)            \
      );                                                             \
   } while (0)

#define inval(addr_reg)          \
   do {                          \
      asm volatile (             \
         "inval %[addr]"         \
         :                       \
         : [addr] "r" (addr_reg) \
      );                         \
   } while (0)

#define reval(addr_reg, perms_imm)                                   \
   do {                                                              \
      /* Attention: variable might shadow name from outer scope */   \
      uint64_t tmp_perms = (perms_imm);                              \
      asm volatile (                                                 \
         "reval %[addr], %[perms]"                                   \
         :                                                           \
         : [addr] "r" (addr_reg), [perms] "r" (tmp_perms)            \
      );                                                             \
   } while (0)

#define excl(excl_flag, addr_reg, perms_imm)                         \
   do {                                                              \
      /* Attention: variable might shadow name from outer scope */   \
      uint64_t tmp_perms = (perms_imm);                              \
      asm volatile (                                                 \
         "excl %[exc], %[addr], %[perms]"                            \
         : [exc] "=r" (excl_flag)                                    \
         : [addr] "r" (addr_reg), [perms] "r" (tmp_perms)            \
      );                                                             \
   } while (0)

#define csrr_usid(usid_reg)         \
   do {                             \
      asm volatile (                \
         "csrr %[usid], usid"       \
         : [usid] "=r" (usid_reg)   \
         :                          \
      );                            \
   } while (0)

#define csrr_urid(urid_reg)         \
   do {                             \
      asm volatile (                \
         "csrr %[urid], urid"       \
         : [urid] "=r" (urid_reg)   \
         :                          \
      );                            \
   } while (0)

#endif /* SECCELLS_H */
