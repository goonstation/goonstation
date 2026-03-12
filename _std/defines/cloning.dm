#define CLONER_DEFECT_SEVERITY_UNUSED null
#define CLONER_DEFECT_SEVERITY_MINOR "minor"
#define CLONER_DEFECT_SEVERITY_MAJOR "major"

// These should sum to 100 (but it'll function if they don't)
#define CLONER_DEFECT_PROB_MINOR 75
#define CLONER_DEFECT_PROB_MAJOR 25

#define MEAT_NEEDED_TO_CLONE	16
#define MAXIMUM_MEAT_LEVEL		100
#define DEFAULT_MEAT_USED_PER_TICK 0.6
#define DEFAULT_SPEED_BONUS 1
#define SPEEDY_MODULE_SPEED_MULT 3
#define SPEEDY_MODULE_MEAT_MULT 4
#define EFFICIENCY_MODULE_MEAT_MULT 0.5

// a lower bound on the amount of meat used per clone, even if ejected instantly
#define MINIMUM_MEAT_USED 4

#define MEAT_LOW_LEVEL	MAXIMUM_MEAT_LEVEL * 0.15

#define MAX_FAILED_CLONE_TICKS 200 // vOv
