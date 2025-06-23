/* Avoid multiple inclusion. */
#if !defined (_LINKED_LIST_H)
#define _LINKED_LIST_H

/**
 * Given a list head and a new link, insert that link at the head.
 * Note that if `head` may actually point to any link in a list, and
 * insertion will occur in front of the link to which `head` points.
 */
#define INSERT(head,link) {			\
    link->next = head;				\
    link->prev = NULL;				\
    if (head != NULL) {				\
      head->prev = link;			\
    }						\
    head = link;				\
  }

/**
 * Given a list head and a link in that list, remove the link.  If the
 * link is the first, then update the head to point to its successor.
 */
#define REMOVE(head,link) {			\
    if (link->next != NULL)			\
      link->next->prev = link->prev;		\
    if (link->prev != NULL)			\
      link->prev->next = link->next;		\
    else					\
      head = link->next;			\
  }

#endif /* _LINKED_LIST_H */
