//fluid pipes
#define DEFAULT_FLUID_CAPACITY 100
#define LARGE_FLUID_CAPACITY 4000


#define MINIMUM_REAGENT_MOVED 0.1
// multiplied against fluid movement. increase to pull fluid faster
#define REAGENT_MOVEMENT_CONSTANT 2
#define QUANTIZATION_UNITS 0.1


// Fluid clicking
#define CHECK_LIQUID_CLICK(thing) (thing.level <= UNDERFLOOR || HAS_ATOM_PROPERTY(thing, PROP_ATOM_DO_LIQUID_CLICKS))
