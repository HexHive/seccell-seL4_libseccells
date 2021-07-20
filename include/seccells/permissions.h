#ifndef PERMISSIONS_H
#define PERMISSIONS_H

/* Currently, this header file only stores macros allowing to easily work
   with read, write, execute permissions for the SecCells access control but it
   may be extended later on. */
#define RT_R 0b00000010     /* 0x2 */
#define RT_W 0b00000100     /* 0x4 */
#define RT_X 0b00001000     /* 0x8 */

#endif /* PERMISSIONS_H */
