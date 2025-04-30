/* Avoid multiple inclusion. */
#if !defined (_CIRC_LINKED_LIST_H)
#define _CIRC_LINKED_LIST_H

/**
 * Given a list head and a new link, insert that link at the head.
 * Note that if `head` may actually point to any link in a list, and
 * insertion will occur in front of the link to which `head` points.
 */
#define CIRC_INSERT(head,link) {			\
    link->next = head->next;				\
    link->prev = head;				\
    if (head->next != head){        \
      head->next->prev = link;        \
    }                                   \
    head->next = link;             \
    if (head->prev == head) {				\
      head->prev = link;			\
    }						\
  }

/**
 * Given a list head and a link in that list, remove the link.  If the
 * link is the first, then update the head to point to its successor.
 */
#define CIRC_REMOVE(head,link) {			\
    if (head == link) {                     \
      if (link->next == link) {            \
        head = NULL;                      \
      } else{                            \
        head = link->next;                \
        head->prev = link->prev;        \
        link->prev->next = head;        \
      }                                    \
    }else{                              \
      link->prev->next = link->next;     \
      link->next->prev = link->prev;     \
    }    \
  }

#endif /* _CIRC_LINKED_LIST_H */
