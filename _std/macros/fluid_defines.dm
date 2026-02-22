#define IS_VALID_FLUID_TURF(T) (!( !T  || T.flags & FLUID_DENSE || (T.loc && T.loc.flags & FLUID_DENSE))) //handles area as well!!
//same as above but including channel + pool check
#define IS_VALID_FLUIDREACT_TURF(T) (IS_VALID_FLUID_TURF(T) && !((locate(/obj/channel) in T) || (locate(/obj/pool) in T) || locate(/obj/forcefield) in T))
#define SPREAD_CHECK(FG) (FG.members && FG.members.len && ((FG.members.len * FG.required_to_spread) <= FG.contained_amt))
#define VALID_FLUID_CONNECTION(F, t) ( t?.active_liquid && (!t.active_liquid.group || F.group == t.active_liquid.group) && !t.active_liquid.disposed)

#define viscosity_SLOW_COMPONENT(avg_viscosity, max_viscosity, max_speed_mod) (((avg_viscosity-1)/(max_viscosity-1)) * max_speed_mod * 0.5)
#define DEPTH_SLOW_COMPONENT(amt, max_reagent_volume, max_speed_mod) (((amt)/(max_reagent_volume)) * max_speed_mod * 0.3)

//Used in obj/fluid procs only:
#define IS_SOLID_TO_FLUID(A) (A.flags & FLUID_DENSE || A.flags & IS_PERSPECTIVE_FLUID)
#define IS_PERSPECTIVE_WALL(T) (T.flags & IS_PERSPECTIVE_FLUID)
#define IS_PERSPECTIVE_BLOCK(A) (A.flags & IS_PERSPECTIVE_FLUID)

/// Check if object or mobs gets a submerge overlay
#define IS_VALID_SUBMERGE_OBJ(O) (O.flags & FLUID_SUBMERGE)
