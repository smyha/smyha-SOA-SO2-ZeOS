/*
 * sched.h - Estructures i macros pel tractament de processos
 */

#ifndef __SCHED_H__
#define __SCHED_H__

#include <list.h>
#include <types.h>
#include <mm_address.h>

#define NR_TASKS      10
#define KERNEL_STACK_SIZE	1024

#define DEFAULT_QUANTUM 100 /* 100 ticks = 1 quantum */

enum state_t { ST_RUN, ST_READY, ST_BLOCKED };

struct task_struct {
  int PID;			/* Process ID. This MUST be the first field of the struct. */
  page_table_entry * dir_pages_baseAddr;

  struct list_head list; /* To enqueue the process in queues */
  struct list_head kids; /* To enqueue the children in the children list */
  struct task_struct *parent; /* Pointer to the parent process */

  enum state_t state; /* Process state */
  int quantum; /* Remaining quantum */
  int pending_unblocks; /* Number of pending unblocks */

  unsigned long kernel_esp; /* ESP saved during a context switch */
};

union task_union {
  struct task_struct task;
  unsigned long stack[KERNEL_STACK_SIZE];    /* pila de sistema, per procés */
};

extern union task_union task[NR_TASKS]; /* Vector de tasques */


#define KERNEL_ESP(t)       	(DWord) &(t)->stack[KERNEL_STACK_SIZE]

#define INITIAL_ESP       	KERNEL_ESP(&task[1])

/* Inicialitza les dades del proces inicial */
void init_task1(void);

void init_idle(void);

void init_sched(void);

struct task_struct * current();

void task_switch(union task_union*t);

struct task_struct *list_head_to_task_struct(struct list_head *l);

int allocate_DIR(struct task_struct *t);

page_table_entry * get_PT (struct task_struct *t) ;

page_table_entry * get_DIR (struct task_struct *t) ;

/* Headers for the scheduling policy */
void sched_next_rr();
void update_process_state_rr(struct task_struct *t, struct list_head *dest);
int needs_sched_rr();
void update_sched_data_rr();


/* ----------------------------------------------------------------------- */

void switch_stack(long unsigned int *old_esp, unsigned int new_esp);
void inner_task_switch(union task_union *new);

void schedule();

/* ----------------------------------------------------------------------- */

#endif  /* __SCHED_H__ */
