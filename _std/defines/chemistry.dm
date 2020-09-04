//states of matter!
#define SOLID 1
#define LIQUID 2
#define GAS 3

//chem transfer methods
#define TOUCH 1
#define INGEST 2
#define INJECT 3

//some holder stuff i dont understand
#define MAX_TEMP_REACTION_VARIANCE 8
#define CHEM_EPSILON 0.0001

//makes sure we cant have too many critters
#define CRITTER_REACTION_LIMIT 50
#define CRITTER_REACTION_CHECK(x) if (x++ > CRITTER_REACTION_LIMIT) return

//uncomment to enable sorting of reactions by priority (which is currently slow and bad)
//#define CHEM_REACTION_PRIORITIES

//reagent_container bit flags
#define RC_SCALE 	1		// has a graduated scale, so total reagent volume can be read directly (e.g. beaker)
#define RC_VISIBLE	2		// reagent is visible inside, so color can be described
#define RC_FULLNESS 4		// can estimate fullness of container
#define RC_SPECTRO	8		// spectroscopic glasses can analyse contents
