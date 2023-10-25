//! Macros related to the process scheduler

/// In hot loops prefer this over process.setLastTask(task, object)
#define SET_LAST_TASK(task, object) do {\
		last_task = task;\
		last_object = object;\
	} while(0)
