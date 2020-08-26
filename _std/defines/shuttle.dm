// where you at, dawg, where you where you at, shuttle_controller.dm
#define SHUTTLE_LOC_CENTCOM 0
#define SHUTTLE_LOC_STATION 1
#define SHUTTLE_LOC_TRANSIT 1.5
#define SHUTTLE_LOC_RETURNED 2

// is the shuttle gonna instantly teleport, or spend some time in transit
#define SHUTTLE_TRANSIT 1

// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
// you might be asking "why /10?" the answer is that shuttle code uses seconds as a base unit and I'm too tired to refactor it
#define SHUTTLEARRIVETIME (6 MINUTES / 10)
#define SHUTTLELEAVETIME (2 MINUTES / 10)
#define SHUTTLETRANSITTIME (2 MINUTES / 10)
