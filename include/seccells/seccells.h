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
#define entry(label)       \
   do {                    \
      asm (                \
         #label ":   \n\t" \
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

#define jals(sd_reg, dest_label)    \
   do {                             \
      asm volatile (                \
         "jals %[sd], " #dest_label \
         : [sd] "+r" (sd_reg)       \
         :                          \
      );                            \
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

#define count(cnt_reg, addr_reg, perms_imm)                          \
   do {                                                              \
      /* Attention: variable might shadow name from outer scope */   \
      uint64_t tmp_perms = (perms_imm);                              \
      asm (                                                          \
         "count %[cnt], %[addr], %[perms]"                           \
         : [cnt] "=r" (cnt_reg)                                      \
         : [addr] "r" (addr_reg), [perms] "r" (tmp_perms)            \
      );                                                             \
   } while (0)

#define csrr_usid(usid_reg)         \
   do {                             \
      asm (                         \
         "csrr %[usid], usid"       \
         : [usid] "=r" (usid_reg)   \
         :                          \
      );                            \
   } while (0)

#endif /* SECCELLS_H */
