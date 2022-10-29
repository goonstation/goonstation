// Process status defines
#define PROCESS_STATUS_IDLE 1
#define PROCESS_STATUS_QUEUED 2
#define PROCESS_STATUS_RUNNING 3
#define PROCESS_STATUS_MAYBE_HUNG 4
#define PROCESS_STATUS_PROBABLY_HUNG 5
#define PROCESS_STATUS_HUNG 6

// Process time thresholds
#define PROCESS_DEFAULT_HANG_WARNING_TIME	20 SECONDS
#define PROCESS_DEFAULT_HANG_ALERT_TIME		30 SECONDS
#define PROCESS_DEFAULT_HANG_RESTART_TIME	45 SECONDS
#define PROCESS_DEFAULT_SCHEDULE_INTERVAL	5 SECONDS
#define PROCESS_DEFAULT_SCHEDULE_JITTER		0 SECONDS

/// try to use no more than this percentage of a tick
#define PROCESS_DEFAULT_TICK_ALLOWANCE		10
#define PROCESS_MAX_TICK_USAGE 100 // defer processing at this percentage of a tick
#define PROCESS_MAX_DEFER_COUNT 1 // how many times to defer in a row before forcing a tick
