//where did the contents of _setup.dm go? "gone, reduced to atom"

/// Is this an atom? idk ask mr. molecule man
#define isatom(A) (isloc(A))

/// built-in isobj returns true for /atom/movable
#define isobj(A) (istype(A, /obj))

/// This is relevant to atoms so it goes here!!!! do not @ me
#define opposite_dir_to(dir) (turn(dir, 180))


/**
 * Makes the given procs available for use with the admin interact menu
 * Example: `ADMIN_INTERACT_PROCS(/obj/machinery/nuclearbomb, proc/arm, proc/disarm)`
 * would add the `*arm` and `*disarm` options to the admin interact menu for nuclear bombs.
 * Will display the "name" of the proc if it has one, for example `set name = "foo"` will result in the proc's entry in the interact menu being "Foo".
**/
#define ADMIN_INTERACT_PROCS(TYPE, PROCNAME...)\
	TYPEINFO(TYPE); \
	TYPEINFO_NEW(TYPE){ \
		. = ..(); \
		admin_procs += list(APPLY_PREFIX(TYPE/, PROCNAME)); \
	}
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
/// Atom implements EnteredFluid() call in some way.
#define USE_FLUID_ENTER				(1 << 0)
/// Atom can be held as an item and have a grab inside it to choke somebuddy
#define USE_GRAB_CHOKE				(1 << 1)
/// Atom implements var/active = XXX and responds to sticker removal methods (burn-off + acetone). this atom MUST have an 'active' var. im sory.
#define HANDLE_STICKER				(1 << 2)
/// cannot be pushed by MANTAwaters
#define IMMUNE_MANTA_PUSH			(1 << 3)
#define IMMUNE_SINGULARITY			(1 << 4)
#define IMMUNE_SINGULARITY_INACTIVE	(1 << 5)
/// used for trinkets GC
#define IS_TRINKET					(1 << 6)
#define IS_FARTABLE					(1 << 7)
/// overrides the click drag mousedrop pickup QOL kinda stuff
#define NO_MOUSEDROP_QOL			(1 << 8)
#define MOVE_NOCLIP 				(1 << 9)
/// Atom won't get warped to z5 via floor holes on underwater maps
#define IMMUNE_TRENCH_WARP			(1 << 10)


//THROW flags (what kind of throw, we can have ddifferent kinds of throws ok)
#define THROW_NORMAL	(1 << 0)
#define THROW_CHAIRFLIP (1 << 1)
#define THROW_GUNIMPACT (1 << 2)
#define THROW_SLIP		(1 << 3)
#define THROW_PEEL_SLIP	(1 << 4)
#define THROW_BASEBALL  (1 << 5) // throw that doesn't stun into walls.

//For serialization purposes
#define DESERIALIZE_ERROR				(0 << 0)
#define DESERIALIZE_OK					(1 << 0)
#define DESERIALIZE_NEED_POSTPROCESS	(1 << 1)
#define DESERIALIZE_NOT_IMPLEMENTED		(1 << 2)

/// Uncross should call this after setting `.` to make sure Bump gets called if needed
#define UNCROSS_BUMP_CHECK(AM) if(!. && do_bump) AM.Bump(src)

/// Use this to override the help message instead of doing it directly
#define HELP_MESSAGE_OVERRIDE(HM) \
	help_message = HM; \
	help_verb() { \
		set popup_menu = TRUE; \
		set hidden = FALSE; \
		..(); \
	}

/// Wrapper around RegisterSignal for help messages. Use this when you want a component to add a custom help message to its parent.
/// Makes it so the target is given the Help verb
/// Note that we never remove the help verb and this is mostly because it's easier, unlikely to happen often and also not a big deal
/// as the help verb just says that there's no help message if there's no help message.
/// The reason why we skip mob is that mob.verbs is different from obj.verbs etc. Basically if you are trying to do this to a mob
/// probably you will need to include HELP_MESSAGE_OVERRIDE on the mob to give it the static help verb. Sorry.
#define RegisterHelpMessageHandler(target, help_message_handler) \
	RegisterSignal(parent, COMSIG_ATOM_HELP_MESSAGE, help_message_handler); \
	if(!ismob(target)) target.verbs |= /atom/proc/help_verb_dynamic

/// Wrapper around UnregisterSignal for help messages, identical to UnregisterSignal but here for parity
#define UnregisterHelpMessageHandler(target) \
	UnregisterSignal(parent, COMSIG_ATOM_HELP_MESSAGE)

/// For an unanchored movable atom
#define UNANCHORED 0
/// For an atom that can't be moved by player actions
#define ANCHORED 1
/// For an atom that's always immovable, even by stuff like black holes and gravity artifacts.
#define ANCHORED_ALWAYS 2

/// The atom is below the floor tiles.
#define UNDERFLOOR 1
/// The atom is above the floor tiles.
#define OVERFLOOR 2
