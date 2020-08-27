//check defines/access.dm for access levels! this is just airlock specific stuff, and access is used for some consoles too
//States for airlock_control
#define ACCESS_STATE_INTERNAL	-1
#define ACCESS_STATE_LOCKED		0
#define ACCESS_STATE_EXTERNAL	1

#define AIRLOCK_STATE_INOPEN		-2
#define AIRLOCK_STATE_PRESSURIZE	-1
#define AIRLOCK_STATE_CLOSED		0
#define AIRLOCK_STATE_DEPRESSURIZE	1
#define AIRLOCK_STATE_OUTOPEN		2

#define AIRLOCK_CONTROL_RANGE 5
