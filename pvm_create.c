#include "kernel-stub.h"
#include "types.h"

#define BYTES_PER_PAGE 4096
#define WORDS_PER_PAGE (BYTES_PER_PAGE / BYTES_PER_WORD)

#define PTE_MAPPED_BIT     0
#define PTE_RESIDENT_BIT   1
#define PTE_SREAD_BIT      2
#define PTE_SWRITE_BIT     3
#define PTE_SEXEC_BIT      4
#define PTE_UREAD_BIT      5
#define PTE_UWRITE_BIT     6
#define PTE_UEXEC_BIT      7
#define PTE_REFERENCED_BIT 8
#define PTE_DIRTY_BIT      9

#define GET_BIT(pte,bit) (pte & (1 << bit))
#define CLEAR_BIT(pte,bit) (pte & ~(1 << bit))
#define SET_BIT(pte,bit) (pte | (1 << bit))

#define UPT_INDEX(vaddr) (vaddr >> 22)
#define LPT_INDEX(vaddr) ((vaddr >> 12) & 0x3ff)
#define OFFSET(vaddr) (vaddr & 0xfff)

/* Define a type for each entry of an upper page-table. */
typedef address_t upt_entry_t;

/* Define a type for each entry in the lower page-table. */
typedef address_t pte_t;

void zero_page (address_t page) {

  for (word_t* current = (word_t*)page; current < page + WORDS_PER_PAGE; current++) {
    *current = 0;
  }
  
}

/* Make a new upper page-table, zeroing it out.  It is an array of upper page-table entries. */
upt_entry_t* create_upt () {

  address_t page_frame = page_alloc();
  zero_page(page_frame);
  return (upt_entry_t*)page_frame;

}

void set_pte (upt_entry_t* upt, address_t vpage_addr, word_t pte) {
  
  /* Index into the UPT. */
  word_t upt_index = UPT_INDEX(vpage_addr);

  /* Does that entry lead to a LPT block? */
  if (upt[upt_index] == 0) {

    /* No, so create it. */
    address_t page_frame = page_alloc();
    zero_page(page_frame);
    upt[upt_index] = page_frame;
    
  }

  /* Index into the LPT. */
  pte_t* lpt       = (pte_t*)upt[upt_index];
  word_t lpt_index = LPT_INDEX(vpage_addr);
  lpt[lpt_index]   = pte;

}

/* Find the last entry in the device table and return a pointer to it. */
dt_entry_s* find_last_device () {

  /* Iterate through the device table until the last entry is found. */
  dt_entry_s* current = device_table_base;
  dt_entry_s* prev    = NULL;
  while (current->type != none_device_code) {
    prev = current;
    current++;
  }

  /* Return the last valid device table entry. */
  return prev;
  
}

/* Make the first page table, mapping the kernel's space. */
upt_entry_t* create_kernel_upt () {

  /* Create an empty page table to start. */
  upt_entry_t* upt = create_upt();

  /* Loop through all of the pages used in the physical address space, first base to last limit. */
  address_t base              = 0x1000;
  address_t limit             = find_last_device()->limit;
  word_t    pte_metadata_bits = PTE_MAPPED_BIT | PTE_RESIDENT_BIT | PTE_SREAD_BIT | PTE_SWRITE_BIT | PTE_SEXEC_BIT;
  for (address_t current = base; current < limit; current += BYTES_PER_PAGE) {

    /* Map this virtual page to the physical page at the same address, setting metadata bits to make it usable. */
    pte_t pte = current | pte_metadata_bits;
    set_pte(upt, current, pte);
   
  }

}
