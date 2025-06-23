#include <assert.h>
#include <stdio.h>
#include "kernel.c" // should really be header file
// maybe rename RAM_head and ram_init to PAGE_head and page_init in kernel.c 

void test_page_alloc() {

    ram_init(); 

    // allocate 1 page
    address_t addr1 = page_alloc();
    if (addr1 != NULL) { // check if allocation succeeds
        printf("page allocated to address: %p\n", (void*)addr1);
        return;
    }

    // allocate all available pages
    while (page_alloc() != NULL);
    if (get_RAM_head() == NULL) {
        printf("page allocated to address: %p\n", (void*)addr1);
    } // checks all pages are allocated


    // attempt to allocate when no pages are available (error)
    address_t addr2 = page_alloc();
    assert(addr2 == NULL); // should fail
    if (addr2 == NULL) { 
        printf("couldn't allocate pages, as expected");
        return;
    }

    // free 1 page and reallocate
    zero_page(addr1); // assuming zero_page has no bugs
    address_t addr3 = page_alloc();
    if (addr3 == addr1) { 
        printf("couldn't allocate pages, as expected");
        return;
    }
    printf("freed page reallocated at address: %p\n", (void*)addr3);
}

int main() {
    test_page_alloc();
    printf("all tests passed.\n");
    return 0;
}