/* =============================================================================================================================== */
/* INCLUDES */

#include "kernel-stub.h"
#include "types.h"
#include "linked_list.h"
#include "circ_linked_list.h"
#include <stdint.h>
/* =============================================================================================================================== */
//MACROS 

#define ADDR_SIZE (sizeof(address_t))
#define ALIGN_UP(addr) (addr % ADDR_SIZE == 0 ? addr : (addr + ADDR_SIZE) & (ADDR_SIZE - 1))

#define HEADER_TO_BLOCK(p) ((void*)((address_t)p + sizeof(header_s)))
#define BLOCK_TO_HEADER(p) ((header_s*)((address_t)p - sizeof(header_s)))


/* =============================================================================================================================== */
/* CONSTANTS */

#define BYTES_PER_WORD  4
#define BITS_PER_BYTE   8
#define BITS_PER_NYBBLE 4
#define BYTES_PER_PAGE 4096
#define WORDS_PER_PAGE (BYTES_PER_PAGE / BYTES_PER_WORD)

#define PTE_MAPPED_BIT     1//0
#define PTE_RESIDENT_BIT   2//1
#define PTE_SREAD_BIT      4//2
#define PTE_SWRITE_BIT     8//3
#define PTE_SEXEC_BIT      16//4
#define PTE_UREAD_BIT      32//5
#define PTE_UWRITE_BIT     64//6
#define PTE_UEXEC_BIT      128//7
#define PTE_REFERENCED_BIT 256//8
#define PTE_DIRTY_BIT      512//9

#define GET_BIT(pte,bit) (pte & (1 << bit))
#define CLEAR_BIT(pte,bit) (pte & ~(1 << bit))
#define SET_BIT(pte,bit) (pte | (1 << bit))

#define UPT_INDEX(vaddr) (vaddr >> 22)
#define LPT_INDEX(vaddr) ((vaddr >> 12) & 0x3ff)
#define OFFSET(vaddr) (vaddr & 0xfff)

static char hex_digits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
static address_link_s* RAM_head = NULL;
static process_info_s* process_head = NULL;
static process_info_s* curr_process = NULL;

/* The externally provided end of the statics, at which the heap will begin. */
extern address_t statics_limit;
/* externally provided base address of the device table*/
extern dt_entry_s* device_table_base;
/* The current limit of the heap. */
static address_t heap_limit = (address_t)NULL;
static word_t page_size = 0x1000;
static word_t program_size = 0x8000;
/* A pair of sentinels to the free list, making the coding easier. */
 header_s free_head = { .next = NULL, .prev = NULL, .size = 0 };
 header_s free_tail = { .next = NULL, .prev = NULL, .size = 0 };




/* =============================================================================================================================== */



/* =============================================================================================================================== */
/* FUNCTION SIGNATURES */

upt_entry_t* create_upt ();
upt_entry_t* create_process_upt(upt_entry_t* kernel_upt);
void set_pte (upt_entry_t* upt, address_t vpage_addr, word_t pte);

/* =============================================================================================================================== */

/* =============================================================================================================================== */
void int_to_hex (word_t value, char* buffer) {

  /* Traverse the value from most to least significant bits. */
  for (int shift = BYTES_PER_WORD * BITS_PER_BYTE - BITS_PER_NYBBLE; shift >= 0; shift -= BITS_PER_NYBBLE) {

    /* Grab the next nybble and add its corresponding digit to the string, advancing the string's pointer. */
    word_t nybble = (value >> shift) & 0xf;
    *buffer++ = hex_digits[nybble];
    
  }

  /* Finish the string with a null termination. */
  *buffer = '\0';
  
} /* int_to_hex () */
/* =============================================================================================================================== */

/**
 * Initialize the heap.  If it is already initialized, do nothing.
 */
void heap_init () {

  /* Continue only if the heap is uninitialized. */
  if (heap_limit != (address_t)NULL) return;

  /* Start the heap where the statics end. */
  heap_limit = statics_limit;

  /* Initialize the sentinels that bookend the free block list. */
  free_head.next = &free_tail;
  free_tail.prev = &free_head;
  
} /* heap_init () */



/* =============================================================================================================================== */
void* heap_alloc (int size) {

  /* Ensure that the heap is initialized. */
  heap_init();

  /* Blocks must always be allocated in word/address-sized chunks. */
  size = ALIGN_UP(size);
  
  /* Search the free list for a block of sufficient size. */
  header_s* current = free_head.next;
  while (current != &free_tail) {

    /* Is this block large enough? */
    if (current->size >= size) {

      /* Yes. Remove it from the list and use it. */
      current->prev->next = current->next;
      current->next->prev = current->prev;
      current->next       = NULL;
      current->prev       = NULL;
      break; 

    } else {

      /* No. Move to the next block. */
      current = current->next;

    }
    
  }

  /* If we did not find a free block to use, make a new one. */
  if (current == &free_tail) {

    int block_size = sizeof(header_s) + size;
    current        = (header_s*)heap_limit;
    current->size  = size;
    int sp = 0;
    word_t sp_addr = (word_t)&sp;
    if (heap_limit + block_size >= sp_addr) {
      syscall_handler_halt();
    } else {
      heap_limit    += block_size;
    }
    
  }

  return HEADER_TO_BLOCK(current);
  
} /* allocate() */
/* =============================================================================================================================== */



/* =============================================================================================================================== */
void heap_free (void* ptr) {

  /* Do nothing if there is no block. */
  if (ptr == NULL) return;

  /* Find the header. */
  header_s* header = BLOCK_TO_HEADER(ptr);
  
  /* Insert the block at the front of the free list. */
  header->next         = free_head.next;
  header->prev         = &free_head;
  free_head.next->prev = header;
  free_head.next       = header;
  
} /* deallocate () */
/* =============================================================================================================================== */

void ram_init(){

  RAM_head = heap_alloc(sizeof(*RAM_head));
  RAM_head->val = kernel_limit;
  RAM_head->next = NULL;
  RAM_head->prev = NULL;
  for (address_t i = kernel_limit + page_size; i < RAM_limit; i+=page_size){
    address_link_s* node = (address_link_s*)heap_alloc(sizeof(*node));
    node->val = i; 
    node->next = NULL;
    node->prev = NULL;
    INSERT(RAM_head, node);
  }
}

address_t page_alloc(){

  if (RAM_head != NULL) {

    address_t toRet = RAM_head->val;
    address_link_s* toFree = RAM_head;
    REMOVE(RAM_head, RAM_head);
    heap_free(toFree);
    return toRet;
  }
  return NULL;
}

void ram_free(address_t address){

  address_link_s* node = (address_link_s*)heap_alloc(sizeof(*node));
  node->val = address;
  INSERT(RAM_head, node);
  
}

address_t process_head_init(){
  process_head = heap_alloc(sizeof(*process_head));
  process_head->prev = process_head;
  process_head->next = process_head;
  process_head->sp = NULL;
  process_head->pc = NULL;
  process_head->pid = NULL;
  process_head->curr_page_idx = NULL;

  process_head->pt_ptr = (address_t) create_process_upt((upt_entry_t*) kernel_upt_ptr);
  return (address_t) process_head;
}

void jump_to_next_ROM(process_info_s* curr){
  userspace_jump(curr->pc);
}

void run_ROM(word_t next_ROM){

  char str_buffer[9];
  print("Searching for ROM #");
  int_to_hex(next_ROM, str_buffer);
  print(str_buffer);
  print("\n");
  dt_entry_s* dt_ROM_ptr = find_device(ROM_device_code, next_ROM);
  if (dt_ROM_ptr == NULL) {
    print("Process not found\n");
    return;
  }
  
  // assuming program size of 32KB, make list of pages for program
  address_t* program_page_list = heap_alloc(sizeof(address_t));

  for (int i = 0; i < (int)(program_size/page_size); i++){
    program_page_list[i] = page_alloc();
    if (program_page_list[i] == 0) {
      print("No more RAM space.\n");
      syscall_handler_halt();
    }
  }

  print("Running program...\n");
  /* Copy the program into the free RAM space after the kernel. */

  // Start the process info struct
  process_info_s* process = heap_alloc(sizeof(*process));
  ebreak_wrap();
  process_head->pt_ptr = (address_t) create_process_upt((upt_entry_t*) kernel_upt_ptr);
  ebreak_wrap();
  
  address_t curr_ROM_place = dt_ROM_ptr->base;
  for (int i = 0; i < (int)(program_size/page_size); i++){
    DMA_portal_ptr->src    = curr_ROM_place + i * page_size;
    DMA_portal_ptr->dst    = program_page_list[i];
    DMA_portal_ptr->length = page_size; // Trigger
  }

  
  // adding process info to the process list
  process->pid = next_ROM;
  process->page_list_base = program_page_list;
  process->sp = program_size;
  process->pc =NULL;
  process->curr_page_idx = 0;
 
  curr_process = process;
  CIRC_INSERT(process_head, process);

  /* Jump to the copied code at the kernel limit / program base. */
  jump_to_next_ROM(curr_process);
}

/* =============================================================================================================================== */
void run_programs () {

  static word_t next_program_ROM = 3;
  
  run_ROM(next_program_ROM++);
  
} /* run_programs () */
/* =============================================================================================================================== */

void end_process(){
  
  print("Ending current process...");
  // free the RAM blocks
  for (int i = 0; i < (int)(program_size/page_size); i++){
    ram_free(curr_process->page_list_base[i]);
  }

  // preserve the local pointer of the prcoess being removed
  process_info_s* tmp = curr_process; 
  // update current process to the next one
  curr_process = curr_process->next;
  // remove the process from list, handling the case where we remove the last process
  //well, if we remove the last process we should halt
  if (curr_process->next == curr_process->prev) {
          process_head = NULL;
          print("(last one)");
          print("done.\n");
          syscall_handler_halt();
  }else{
     CIRC_REMOVE(process_head, tmp);
     heap_free(tmp);
  }
  
  

  print("done.\n");

  //handling edge case manually
  if(curr_process->pc==0){
    curr_process = process_head->next;
  }
 
 
  jump_to_next_ROM(curr_process);
}

void update_curr_process(address_t sp, address_t pc){

        curr_process->curr_page_idx = (int)(pc / page_size);
        curr_process->sp = sp + curr_process->page_list_base[curr_process->curr_page_idx];
        curr_process->pc = pc + curr_process->page_list_base[curr_process->curr_page_idx];
}

void alarm_next_program(){
  print("Alarm interrupt invoked...\nJumping to next program...\n");

  curr_process = curr_process->next;
  if (curr_process->pc == 0){
    curr_process = process_head->next;
  }

  jump_to_next_ROM(curr_process);
}

address_t restore_sp(){
  if (curr_process->pc == 0){
    curr_process = process_head->next;
  }
      return  curr_process->sp;
}

address_t get_base(){
  if (curr_process->pc == 0){
    curr_process = process_head->next;
  }
      return  curr_process->page_list_base[curr_process->curr_page_idx];
}

address_t get_limit(){
  if (curr_process->pc == 0){
    curr_process = process_head->next;
  }
  return  curr_process->page_list_base[curr_process->curr_page_idx] + page_size;
}


void zero_page (address_t page) {

  for (word_t* current = (word_t*)page; current < (word_t*)(page + WORDS_PER_PAGE); current++) {
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

  return upt;

}

upt_entry_t* create_process_upt(upt_entry_t* kernel_upt) {
  upt_entry_t* upt = create_upt();
  for (int i = 0; i < (BYTES_PER_PAGE / BYTES_PER_WORD) / 2; i += BYTES_PER_WORD) {
    upt[i] = kernel_upt[i];
  }

  return upt;
}


char end_of_statics[] = "end of statics";

