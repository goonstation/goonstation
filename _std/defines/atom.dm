//where did the contents of _setup.dm go? "gone, reduced to atom"

/// Is this an atom? idk ask mr. molecule man
#define isatom(A) (isloc(A))

/// built-in isobj returns true for /atom/movable
#define isobj(A) (istype(A, /obj))

/// This is relevant to atoms so it goes here!!!! do not @ me
#define opposite_dir_to(dir) (turn(dir, 180))

//temp_flags lol for atoms and im gonna be constantly adding and removing these
//this doesn't entirely make sense, cause some other flags are temporary too! ok im runnign otu OF FUCKING SPACE
/// used for removing us from mantapush list when we get deleted
#define SPACE_PUSHING				(1 << 0)
/// used for removing us from spacepush list when we get beleted
#define MANTA_PUSHING				(1 << 1)
/// atom has a particlesystem right now - used for clean gc to clear refs to itself etc blah
#define HAS_PARTICLESYSTEM			(1 << 2)
/// atom is a particlesystem target - " "
#define HAS_PARTICLESYSTEM_TARGET	(1 << 3)
/// atom has a bad smoke pointing to it right now - used for clean gc to clear refs to itself etc blah
#define HAS_BAD_SMOKE				(1 << 4)
/// im a limb
#define IS_LIMB_ITEM 				(1 << 5)
/// if a turf has kudzu.
#define HAS_KUDZU 					(1 << 6)
/// if a turf has NBGG.
#define HAS_NBGG					(1 << 7)
/// if an atom/movable is in the crusher (so conveyors don't push it around)
#define BEING_CRUSHERED				(1 << 8)


// event_handler_flags
/// Atom implements HasProximity() call in some way.
#define USE_PROXIMITY				(1 << 0)
/// Atom implements EnteredFluid() call in some way.
#define USE_FLUID_ENTER				(1 << 1)
/// Atom can be held as an item and have a grab inside it to choke somebuddy
#define USE_GRAB_CHOKE				(1 << 2)
/// Atom implements var/active = XXX and responds to sticker removal methods (burn-off + acetone). this atom MUST have an 'active' var. im sory.
#define HANDLE_STICKER				(1 << 3)
/// cannot be pushed by MANTAwaters
#define IMMUNE_MANTA_PUSH			(1 << 5)
#define IMMUNE_SINGULARITY			(1 << 6)
#define IMMUNE_SINGULARITY_INACTIVE	(1 << 7)
/// used for trinkets GC
#define IS_TRINKET					(1 << 8)
#define IS_FARTABLE					(1 << 9)
/// overrides the click drag mousedrop pickup QOL kinda stuff
#define NO_MOUSEDROP_QOL			(1 << 10)


//THROW flags (what kind of throw, we can have ddifferent kinds of throws ok)
#define THROW_NORMAL	(1 << 0)
#define THROW_CHAIRFLIP (1 << 1)
#define THROW_GUNIMPACT (1 << 2)
#define THROW_SLIP		(1 << 3)
#define THROW_PEEL_SLIP	(1 << 4)

//For serialization purposes
#define DESERIALIZE_ERROR				(0 << 0)
#define DESERIALIZE_OK					(1 << 0)
#define DESERIALIZE_NEED_POSTPROCESS	(1 << 1)
#define DESERIALIZE_NOT_IMPLEMENTED		(1 << 2)

/// Uncross should call this after setting `.` to make sure Bump gets called if needed
#define UNCROSS_BUMP_CHECK(AM) if(!. && do_bump) AM.Bump(src)
