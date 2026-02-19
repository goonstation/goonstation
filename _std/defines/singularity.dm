
#define SINGULARITY_TIME 11

#define DEFAULT_AREA 25
#define EVENT_GROWTH 3//the rate at which the event proc radius is scaled relative to the radius of the singularity
#define EVENT_MINIMUM 5//the base value added to the event proc radius, serves as the radius of a 1x1

#define SINGULARITY_MAX_DIMENSION 11//defines the maximum dimension possible by a player created singularity.

#ifdef UPSCALED_MAP
#undef SINGULARITY_MAX_DIMENSION
#define SINGULARITY_MAX_DIMENSION 22
#endif
