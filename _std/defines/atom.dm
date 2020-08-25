//where did the contents of _setup.dm go? "gone, reduced to atom"

//temp_flags lol for atoms and im gonna be constantly adding and removing these
//this doesn't entirely make sense, cause some other flags are temporary too! ok im runnign otu OF FUCKING SPACE
#define SPACE_PUSHING 1 //used for removing us from mantapush list when we get deleted
#define MANTA_PUSHING 2	//used for removing us from spacepush list when we get beleted
#define HAS_PARTICLESYSTEM 4 			//atom has a particlesystem right now - used for clean gc to clear refs to itself etc blah
#define HAS_PARTICLESYSTEM_TARGET 8 	//atom is a particlesystem target - " "
#define HAS_BAD_SMOKE 16 				//atom has a bad smoke pointing to it right now - used for clean gc to clear refs to itself etc blah
#define IS_LIMB_ITEM 32 				//im a limb
#define HAS_KUDZU 64					//if a turf has kudzu.

//event_handler_flags
#define USE_PROXIMITY 1 	//Atom implements HasProximity() call in some way.
#define USE_FLUID_ENTER 2 	//Atom implements EnteredFluid() call in some way.
#define USE_GRAB_CHOKE 4	//Atom can be held as an item and have a grab inside it to choke somebuddy
#define HANDLE_STICKER 8	//Atom implements var/active = XXX and responds to sticker removal methods (burn-off + acetone). this atom MUST have an 'active' var. im sory.
#define USE_HASENTERED 16	//Atom implements HasEntered() call in some way.
#define USE_CHECKEXIT 32	//Atom implements CheckExit() call in some way.
#define USE_CANPASS 64		//Atom implements CanPass() call in some way. (doesnt affect turfs, put this on mobs or objs)
#define IMMUNE_MANTA_PUSH 128			//cannot be pushed by MANTAwaters
#define IMMUNE_SINGULARITY 256
#define IMMUNE_SINGULARITY_INACTIVE 512
#define IS_TRINKET 1024 		//used for trinkets GC
#define IS_FARTABLE 2048
#define NO_MOUSEDROP_QOL 4096 //overrides the click drag mousedrop pickup QOL kinda stuff
//TBD the rest

//THROW flags (what kind of throw, we can have ddifferent kinds of throws ok)
#define THROW_NORMAL 1
#define THROW_CHAIRFLIP 2
#define THROW_GUNIMPACT 4
#define THROW_SLIP 8
