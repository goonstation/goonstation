//table defines
#define TABLE_DISASSEMBLE 0
#define TABLE_WEAKEN 1
#define TABLE_STRENGTHEN 2
#define TABLE_ADJUST 3
#define TABLE_LOCKPICK 4

//railing defines
#define RAILING_DISASSEMBLE 0
#define RAILING_UNFASTEN 1
#define RAILING_FASTEN 2

//deconstruction_flags
#define DECON_NONE 0
#define DECON_SIMPLE 1 //no reqs, just deconstruct!
#define DECON_SCREWDRIVER 2
#define DECON_WRENCH 4
#define DECON_CROWBAR 8
#define DECON_WELDER 16
#define DECON_WIRECUTTERS 32
#define DECON_MULTITOOL 64
#define DECON_BUILT 128 //flag added to something that is player-built
#define DECON_ACCESS 256 //can only be deconstructed if access required is null
