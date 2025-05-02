#if !defined (_TYPES_H)
#define _TYPES_H

#include <stdint.h>

#define NULL 0

typedef uint32_t address_t;
typedef uint32_t word_t;

typedef struct dt_entry {
  word_t    type;
  address_t base;
  address_t limit;
} dt_entry_s;

typedef struct DMA_portal {
  address_t src;
  address_t dst;
  word_t    length;
} DMA_portal_s;

typedef struct address_link {
  struct address_link* next;
  struct address_link* prev;
  address_t        val;
} address_link_s;

//process info struct
typedef struct process_info {
  struct process_info* next;
  struct process_info* prev;
  word_t        pid;
  address_t*    page_list_base;
  address_t    pt_ptr;
  word_t        pc;
  word_t        sp;
  word_t        curr_page_idx;
} process_info_s;

typedef struct header {

  word_t         size;
  struct header* next;
  struct header* prev;
  
} header_s;

/* Define a type for each entry of an upper page-table. */
typedef address_t upt_entry_t;

/* Define a type for each entry in the lower page-table. */
typedef address_t pte_t;


#endif /* _TYPES_H */
