//todo : port some more shit over to turf flags
/// simulated floor slippage
#define MOB_SLIP 1
/// simulated floor steppage
#define MOB_STEP 2
/// lol idk this kind of sucks, but i guess i can avoid some type checks in atmos processing
#define IS_TYPE_SIMULATED 4
/// can atmos use this tile as a space sample?
#define CAN_BE_SPACE_SAMPLE 8
/// turf is pushy. for manta
#define MANTA_PUSH 16
/// fluid move gear suffers no penalty on these turfs
#define FLUID_MOVE 32
/// space move gear suffers no penalty on these turfs
#define SPACE_MOVE 64


#define DISJOINT_TURF_CONNECTION_DISPOSAL (1<<0)
#define DISJOINT_TURF_CONNECTION_ATMOS_MACHINERY (1<<1)
#define DISJOINT_TURF_CONNECTION_POWERNETS (1<<2)
#define DISJOINT_TURF_CONNECTION_ATMOS (1<<3) // Someday
#define DISJOINT_TURF_CONNECTION_FLUID (1<<4) // Somehow
#define DISJOINT_TURF_CONNECTION_VIS (1<<5) // Somewhere
#define DISJOINT_TURF_CONNECTION_EX (1<<6) // Sometime
