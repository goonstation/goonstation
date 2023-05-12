// where you at, dawg, where you where you at, shuttle_controller.dm
#define SHUTTLE_LOC_CENTCOM 0
#define SHUTTLE_LOC_STATION 1
#define SHUTTLE_LOC_TRANSIT 1.5
#define SHUTTLE_LOC_RETURNED 2

/// If true, the shuttle spends time in transit. If false, it instantly teleports.
#define SHUTTLE_TRANSIT 1

/// Time the shuttle takes to get to SS13
#define SHUTTLEARRIVETIME (6 MINUTES / (1 SECOND))
/// Time the shuttle takes to leave SS13
#define SHUTTLELEAVETIME (2 MINUTES / (1 SECOND))
/// Time the shuttle spends in transit away from SS13
#define SHUTTLETRANSITTIME (2 MINUTES / (1 SECOND))

// you might be asking "why in seconds?" the answer is that shuttle code uses seconds as a base unit and I'm too tired to refactor it

// Shuttle disabled-ness

/// Default; shuttle can be called or auto-calls
#define SHUTTLE_CALL_ENABLED 0
/// Shuttle cannot be called manually, only automatically or by admins
#define SHUTTLE_CALL_MANUAL_CALL_DISABLED 1
/// Shuttle will not be called, period
#define SHUTTLE_CALL_FULLY_DISABLED 2

#define SHUTTLE_AVAILABLE_DISABLED 0
#define SHUTTLE_AVAILABLE_NORMAL 1
#define SHUTTLE_AVAILABLE_DELAY 2
