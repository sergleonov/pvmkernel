# Paged Virtual Memory Kernel, 10 am Edition

**Contents**

* `bios.asm`  
    Contains the BIOS code responsible for booting the system. 
* `kernel.c`  
    Defines core kernel functionality, including process creation and scheduling. 
* `kernel-stub.asm` & `kernel-stub.h`  
    Provide basic kernel setup and function definitions for initializing the kernel and interacting with system calls. 
* `init.asm`  
    Calls the other 3 programs, ROM 4-6, and prints "hello from kernel." Tests all the syscalls effectively. 
* `types.h`  
    Defines common types and constants used across the kernel.
* `do-nothing.asm`  
    A test program that does nothing, as the name suggests.
* `linked_list.h`  
    Implements a doubly linked list with add and remove methods used for managing RAM free blocks and heap free blocks. 
* `circ_linked_list.h`  
    Header file containing macros for insert and remove methods for the circular doubly linked list used for managing the process list.
* `loop.asm`  
    Runs a loop with 10,000 iterations to test the alarm interrupt.

**Build and Run**

Download all the files into your directory. Then...

**Assemble the files:**

(sys2) $ f-assemble bios.asm
(sys2) $ f-assemble loop.asm
(sys2) $ f-assemble init.asm


**Build the kernel:**

(sys2) $ f-build combo.vmx kernel-stub.asm kernel.c


**Run the simulation:**

(sys2) $ f-simulate bios.vmx combo.vmx loop.vmx 


**Adjust RAM space:**

(sys2) $ cd fivish/simulator
(sys2) $ vim f-simulate


Set the field `mainMemoryPages` to `64` to enable concurrent running of test programs

## Implementation Comments

We are currently setting all the metadata bits to one in the user program and in the kernel. This is not the best practice as it allows user to access kernel code.

## Page tables

_Fivish_ uses the same two-level page table structure that we outlined in class:

The *_upper-level table_* contains 1,024 entries (where each entry is a 4-byte address that leads to a lower-level table block).
The top 10 bits (positions 22-31) of a virtual address are used to index into this table.

Each *_lower-level table block_* also contains 1,024 entries, each of which is a 4-byte _page table entry_ (described in detail
below) that leads to a physical page frame (a.k.a., a 4 KB block of RAM).  The virtual address's middle 10 bits (positions 12-21)
index into the lower-level table block to find the correct PTE.

(The low 12 bits (positions 0-11) of a virtual address are the _offset_, which are combined with the physical page frame's address
to specify a specific physical address.)

### Page Table Entry (PTE) format

The upper 20 bits (positions 12-31) of each PTE are the _physical page number_.  These 20 bits, when followed by 12 bits of `0`, is
the _page-aligned base address_ of a physical page frame.  If the 12 _offset_ bits of a virtual address are appended to the 20-bit
physical page number, the result is a complete 32-bit physical address.

The lower 12 bits (positions 0-11) of each PTE are _metadata_.  Ordered from least to most significant, they are:

0. _Mapped_: Is this PTE for a valid virtual page that has been mapped to some physical page (now or at some point in the past).
1. _Resident_: Is this virtual page mapped to a physical page that is _in main memory_. (`1` = yes; `0` = no, e.g.,  it is on the
block device.)
2. _Supervisor readable_: Can the virtual page be _read_ while the CPU is in supervisor mode?
3. _Supervisor writeable_: Can the virtual page be _written_ while the CPU is in supervisor mode?
4. _Supervisor executable_: Can the virtual page's values be _executed_ (this is, fetched as machine code) while the CPU is in
supervisor mode?
5. _User readable_: Can the virtual page be _read_ while the CPU is in user mode?
6. _User writeable_: Can the virtual page be _written_ while the CPU is in user mode?
7. _User executable_: Can the virtual page's values be _executed_ (this is, fetched as machine code) while the CPU is in user mode?
8. _Referenced_: This bit is _set_ when this PTE is used by the MMU for any translation.
9. _Dirty_: This bit is _set_ when this PTE is used by the MMU for any _write_-operation translation.
10. _Unused_
11. _Unused_

The MMU uses these bits upon each translation.  If a PTE indicates that the needed virtual page is *not* _mapped_, _resident_, or
has the necessary _permissions_, it will raise an `INVALID_ADDRESS` interrupt.

Reading and writing these bits is best handled by a set of C macros, something like this:

```
#define PTE_MAPPED_BIT   0
#define PTE_RESIDENT_BIT 1
#define PTE_SREAD_BIT    2
[...]

#define GET_BIT(pte,bit) (pte & (1 << bit))
#define CLEAR_BIT(pte,bit) (pte & ~(1 << bit))
#define SET_BIT(pte,bit) (pte | (1 << bit))
```

This should allow simpler expressions for setting PTE's.  For example, to set a PTE as being _user readable_: `SET_BIT(some_pte, PTE_UREAD_BIT)`

### Activating a page table

To have the CPU use paged virtual translation, the kernel must do the following:

1. Set the `pt` CSR to contain the *physical* address of an upper page-table.
2. Set bits 2 (_use virtual addressing_) and 3 (use _paged_ virtual addressing) in the `md` CSR.

## First goal: Transitioning the kernel into paged VM space

We seek to create a first page table, intended for the kernel itself, with _identity mappings_ for the occupied portion of the
physical address space.  That is, from the base of the first device (the _device table_, which is always at `0x1000`) to the limit
of the last device, we want to create PTE's that map the page at virtual address `A` to the physical page frame, also at address
`A`.  In other words, if our translations work correctly through this page table, the MMU will translate each virtual address to the
identify physical address.

Creating this initial table starts, perhaps, with a function like the following that creates a new upper table (with the observation
that this function does not properly check return values of calls to test for failure, which is really should):

```
  /* Define a type for each entry of an upper page-table. */
  typedef address_t upt_entry_t;

  /* Make a new upper page-table, zeroing it out.  It is an array of upper page-table entries. */
  upt_entry_t* create_upt () {

    address_t page_frame = page_alloc();
    zero_page(page_frame);
    return (upt_entry_t*)page_frame;

  }
    
```

Then, we could create a PTE for some virtual page, and have a function for inserting/setting that PTE in the page table:

```
  #define UPT_INDEX(vaddr) (vaddr >> 22)
  #define LPT_INDEX(vaddr) ((vaddr >> 12) & 0x3ff)
  #define OFFSET(vaddr) (vaddr & 0xfff)

  typedef address_t pte_t;

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
```

To get all of this working, we will need supporting functions such as `page_alloc()`, `zero_page()`, and more.  In particular, we
will need a high-level function that determines the range of physical devices, and then loops through that range, creating and
inserting PTE's to establish identity mappings to each.

## To-do:

Each member of this group should add their username (e.g., `sfkaplan`) at the end of one of these tasks.  Spread out.  Feel free to
take on a task as a pair with someone else in the group.  *To avoid having everyone trying to edit the same file, each new function
should be written into its own `.c` file*, and I will merge them once first versions of them are done.

- [ ] Write the high-level `map_all_devices()` to create the page table of identity mappings. - **Madi + Deshan**
- [ ] Write `page_alloc()` (as a modified `RAM_alloc()` from Project-2?) - **Crawford + Sergei**
- [ ] Write `zero_page()` - **larciniega27**
- [ ] Write proper versions of the above functions that handle errors correctly.- **Sherlyn + Mayisa + Lindsay**
- [ ] Write stub code to transition into virtual addressing for the kernel by using the page table created by `map_all_devices()`. - **kbarrett27**
- [ ] Choose a kernel from Project-2 as a starting point to which to add these functions. - **Teamwork!**

## Tasks

| Task | Team |
|------|-------------|
| Write the high-level `map_all_devices()` to create the page table of identity mappings | Madi + Deshan |
| Write `page_alloc()` (as a modified `RAM_alloc()` from Project-2?) | Crawford + Sergei |
| Write `zero_page()` | Luis Arciniega |
| Write proper versions of the above functions that handle errors correctly | Sherlyn, Mayisa and Lindsay |
| Write stub code to transition into virtual addressing for the kernel | Kaleb Barrett |
| Choose a kernel from Project-2 as a starting point | Teamwork! |

## Team

| Name | Email |
|------|-------|
| Crawford Dawson | ddawson27@amherst.edu |
| Deshan de Mel | ddemel27@amherst.edu |
| Kaleb Barrett | kbarrett27@amherst.edu |
| Lindsay Ward | lward25@amherst.edu |
| Madi Gudin | mgudin27@amherst.edu |
| Mayisa Tasnim | mtasnim27@amherst.edu |
| Sergei Leonov | sleonov27@amherst.edu |
| Sherlyn Saavedra | ssaavedra27@amherst.edu |
| Luis Arciniega | larciniega27@amherst.edu |

ahan27@amherst.edu, ddawson27@amherst.edu, ddemel27@amherst.edu, kbarrett27@amherst.edu, larciniega27@amherst.edu, lward25@amherst.edu, mbailey26@amherst.edu, mgudin27@amherst.edu, mtasnim27@amherst.edu, sfkaplan@amherst.edu, sleonov27@amherst.edu, ssaavedra27@amherst.edu
