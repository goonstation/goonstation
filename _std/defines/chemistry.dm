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

// Meal Times used to identify when a food product might TYPICALLY be consumed
#define MEAL_TIME_BREAKFAST (1<<0)
#define MEAL_TIME_LUNCH	(1<<1)
#define MEAL_TIME_DINNER (1<<2)
#define MEAL_TIME_SNACK	(1<<3)
#define MEAL_TIME_FORBIDDEN_TREAT (1<<4)

//macro for lag-compensated probability - assumes lag-compensation multiplier is always called mult
#define probmult(x) (prob(percentmult((x), mult)))

#define THRESHOLD_UNDER 0
#define THRESHOLD_OVER 1
#define THRESHOLD_INIT THRESHOLD_UNDER

