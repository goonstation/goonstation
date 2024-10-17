//todo : port some more shit over to turf flags
/// simulated floor slippage
#define MOB_SLIP (1<<0)
/// simulated floor steppage
#define MOB_STEP (1<<1)
/// turf is pushy. for manta
#define MANTA_PUSH (1<<2)
/// fluid move gear suffers no penalty on these turfs
#define FLUID_MOVE (1<<3)
/// space move gear suffers no penalty on these turfs
#define SPACE_MOVE (1<<4)

/// Allows connections for disposal pipes
#define DISJOINT_TURF_CONNECTION_DISPOSAL (1<<0)
/// Allows connections for atmos machinery (nodes)
#define DISJOINT_TURF_CONNECTION_ATMOS_MACHINERY (1<<1)
/// Allows for connections for powernets
#define DISJOINT_TURF_CONNECTION_POWERNETS (1<<2)
#define DISJOINT_TURF_CONNECTION_ATMOS (1<<3) // Someday
#define DISJOINT_TURF_CONNECTION_FLUID (1<<4) // Somehow
#define DISJOINT_TURF_CONNECTION_VIS (1<<5) // Somewhere
#define DISJOINT_TURF_CONNECTION_EX (1<<6) // Sometime

#define DISJOINT_TURF_ALL (DISJOINT_TURF_CONNECTION_DISPOSAL | DISJOINT_TURF_CONNECTION_ATMOS_MACHINERY | DISJOINT_TURF_CONNECTION_POWERNETS | DISJOINT_TURF_CONNECTION_ATMOS | DISJOINT_TURF_CONNECTION_FLUID | DISJOINT_TURF_CONNECTION_VIS | DISJOINT_TURF_CONNECTION_EX )
