//fluid pipes
#define DEFAULT_FLUID_CAPACITY 100
#define LARGE_FLUID_CAPACITY 1000

// Fluid clicking
#define CHECK_LIQUID_CLICK(thing) (thing.level <= UNDERFLOOR || HAS_ATOM_PROPERTY(thing, PROP_ATOM_DO_LIQUID_CLICKS))
