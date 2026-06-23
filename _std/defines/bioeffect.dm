#define EFFECT_TYPE_MUTANTRACE 1
#define EFFECT_TYPE_DISABILITY 2
#define EFFECT_TYPE_POWER 3
#define EFFECT_TYPE_FOOD 4

#define EFFECT_RESEARCH_NONE 0
#define EFFECT_RESEARCH_IN_PROGRESS 1
#define EFFECT_RESEARCH_DONE 2
#define EFFECT_RESEARCH_ACTIVATED 3

// Bioeffect flags (WIP, the commented-out flags are intended to be added piecemeal in separate PRs -- Nexusuxen)
// Currently the chromosome functionalities work well enough for our needs, but feel free to add additional flags for more nuanced logic
// At some point we'll also probably want things like EFFECT_INNATE (replacing is_innate) in here too
#define BIOEFFECT_CANNOT_SPLICE (1 << 0)
//#define BIOEFFECT_STABILIZED (1 << 1)
//#define BIOEFFECT_EMPOWERED (1 << 2)
//#define BIOEFFECT_ENERGIZED (1 << 3)
//#define BIOEFFECT_SYNCHRONIZED (1 << 4)
//#define BIOEFFECT_REINFORCED (1 << 5)
//#define BIOEFFECT_WEAKENED (1 << 6)
//#define BIOEFFECT_CAMOUFLAGED (1 << 7)
//#define BIOEFFECT_FROM_POOL (1 << 8)
//#define BIOEFFECT_METASTABLE (1 << 9) // stable until moved out of its current bioholder
