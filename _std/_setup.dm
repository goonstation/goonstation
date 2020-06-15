/* Protip: Prepending an underscore to this file puts it at the top of the compile order,
// so that it already has the defines for the later files that use them.
*/

//#define IM_REALLY_IN_A_FUCKING_HURRY_HERE 1 //Uncomment this to just skip everything possible and get into the game asap.
//#define GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW 1 // uncomment this to use atlas as the single map. will horribly break things but speeds up compile/boot times.

#define SKIP_FEA_SETUP 0 //Skip atmos setup
#define SKIP_Z5_SETUP 0 //Skip z5 gen

#ifdef IM_REALLY_IN_A_FUCKING_HURRY_HERE
#define SKIP_FEA_SETUP 1
#define SKIP_Z5_SETUP 1
#define IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME 1 //Skip changelogs
#define I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO 1 //Automatically ready up and start the game ASAP. No input required.
#endif

// Server side profiler stuff for when you want to profile how laggy the game is
// FULL_ROUND
//   Start profiling immediately, save profiler data when world is rebooting (data/profile/xxxxxxxx-full.log)
// PREGAME
//   Start profiling immediately, save profiler data when entering pregame state (data/profile/xxxxxx-pregame.log)
// INGAME_ONLY
//   Clear and start profiling once the PREGAME part ends. (data/profile/xxxxxxxx-ingame.log)
//
// FULL_ROUND and INGAME_ONLY are not compatible with one another, because INGAME_ONLY will
// clear the pre-game data FULL_ROUND collects. Use PREGAME instead if you want that.
//
//#define SERVER_SIDE_PROFILING_FULL_ROUND 1 // Generate and save profiler data for the entire round
//#define SERVER_SIDE_PROFILING_PREGAME 1	// Generate and save profiler data for pregame work (before "Welcome to pregame lobby")
//#define SERVER_SIDE_PROFILING_INGAME_ONLY 1 // Generate and save profiler data for post-pregame work

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// MATH!
#define eulers 2.7182818284
#define pi 3.14159265

#define NETWORK_MACHINE_RESET_DELAY 40 //Time (in 1/10 of a second) before we can be manually reset again (machines).

#define LEVEL_HOST 6
#define LEVEL_CODER 5
#define LEVEL_ADMIN 4
#define LEVEL_PA 3
#define LEVEL_IA 2
#define LEVEL_SA 1
#define LEVEL_MOD 0
#define LEVEL_BABBY -1

#define SAVEFILE_VERSION_MIN	3
#define SAVEFILE_VERSION_MAX	9
#define SAVEFILE_PROFILES_MAX	5

#define CUSTOMJOB_SAVEFILE_PROFILES_MAX	15
#define CUSTOMJOB_SAVEFILE_VERSION_MIN	1
#define CUSTOMJOB_SAVEFILE_VERSION_MAX	3

#define ITEM_RARITY_POOR 1
#define ITEM_RARITY_COMMON 2
#define ITEM_RARITY_UNCOMMON 3
#define ITEM_RARITY_RARE 4
#define ITEM_RARITY_EPIC 5
#define ITEM_RARITY_LEGENDARY 6
#define ITEM_RARITY_MYTHIC 7

#define DIALOGUE_CLOSE 1
#define DIALOGUE_HOLD 2

#define TIME_DILATION_ENABLED 1
#define MIN_TICKLAG 0.4 //min value ticklag can be
#define OVERLOADED_WORLD_TICKLAG 0.8 //max value ticklag can be
#define TICKLAG_DILATION_INC 0.2 //how much to increase by when appropriate
#define TICKLAG_DILATION_DEC 0.2 //how much to decrease by when appropriate //MBCX I DONT KNOW WHY BUT MOST VALUES CAUSE ROUNDING ERRORS, ITS VERY IMPORTANT THAT THIS REMAINS 0.2 FIOR NOW
#define TICKLAG_DILATION_THRESHOLD 5 //these values dont make sense to you? read the math in gameticker
#define TICKLAG_NORMALIZATION_THRESHOLD 0.4 //these values dont make sense to you? read the math in gameticker
#define TICKLAG_DILATE_INTERVAL 20

#define OVERLOAD_PLAYERCOUNT 95 //when pcount is above this number on round start, increase ticklag to OVERLOADED_WORLD_TICKLAG to try to maintain smoothness
#define OSHAN_LIGHT_OVERLOAD 18 //when pcount is above this number on game load, dont generate lighting surrounding the station because it lags the map to heck


#define DEFAULT_CLICK_DELAY MIN_TICKLAG //used to be 1
#define COMBAT_CLICK_DELAY 10
#define CLICK_GRACE_WINDOW 0//2.5

#define COMBAT_BLOCK_DELAY (2)

//Alignment around the turf. Any can be combined with center (top and bottom for horizontal centering, left and right for vertical).
#define TOOLTIP_BOTTOM 0
#define TOOLTIP_TOP 1
#define TOOLTIP_RIGHT 2
#define TOOLTIP_LEFT 4
#define TOOLTIP_CENTER 8

#define TOOLTIP_ALWAYS 1
#define TOOLTIP_NEVER 2
#define TOOLTIP_ALT 3

//Action defines
#define INTERRUPT_ALWAYS -1 //Internal flag that will always interrupt any action.
#define INTERRUPT_MOVE 1 //Interrupted when object moves
#define INTERRUPT_ACT 2 //Interrupted when object does anything
#define INTERRUPT_ATTACKED 4 //Interrupted when object is attacked
#define INTERRUPT_STUNNED 8//Interrupted when owner is stunned or knocked out etc.
#define INTERRUPT_ACTION 16 //Interrupted when another action is started.

#define ACTIONSTATE_STOPPED 1 //Action has not been started yet.
#define ACTIONSTATE_RUNNING 2 //Action is in progress
#define ACTIONSTATE_INTERRUPTED 4 //Action was interrupted
#define ACTIONSTATE_ENDED 8 //Action ended succesfully
#define ACTIONSTATE_DELETE 16 //Action is ready to be deleted.
#define ACTIONSTATE_FINISH 32 //Will finish action after next process.
#define ACTIONSTATE_INFINITE 64 //Will not finish unless interrupted.
//Action defines END

//Material flag defines
#define MATERIAL_CRYSTAL 1 //Crystals, Minerals
#define MATERIAL_METAL 2   //Metals
#define MATERIAL_CLOTH 4   //Cloth or cloth-like
#define MATERIAL_ORGANIC 8 //Coal, meat and whatnot.
#define MATERIAL_ENERGY 16 //Is energy or outputs energy.
#define MATERIAL_RUBBER 32 //Rubber , latex etc

#define MATERIAL_ALPHA_OPACITY 190 //At which alpha do opague objects become see-through?
//---

//Very specific cruiser defines
#define CRUISER_FIREMODE_LEFT 1 //Fire only left weapon
#define CRUISER_FIREMODE_RIGHT 2//Fire only right weapon
#define CRUISER_FIREMODE_BOTH 4 //Fire both weapons
#define CRUISER_FIREMODE_ALT 8  //Alternate between the weapons.

//MINING Z LEVEL
#define AST_MINSIZE 7        //Min range before rng kicks in
#define AST_REDUCTION 9	     //prob reduction per 1 tile over min size
#define AST_SIZERANGE 4      //+- mod on asteroid size, i.e. 4 = 4 tiles smaller to 4 tiles larger.
#define AST_TILERNG 20       //+- range of flat rng applied to tile placement
#define AST_SEEDS 40         //Base amount of asteroid seeds. Actual amount of asteroids works out to be significantly less.
#define AST_RNGWALKCNT 7     //Amount of asteroid tiles to dig out during random walk.
#define AST_RNGWALKINST 5    //How many random walks should we do per asteroid.

#ifdef UNDERWATER_MAP
#define AST_NUMPREFABS 18     //How many prefabs to place. It'll try it's hardest to place this many at the very least. You're basically guaranteed this amount of prefabs.
#define AST_NUMPREFABSEXTRA 6//Up to how many extra prefabs to place randomly. You might or might not get these extra ones.
#else
#define AST_NUMPREFABS 5     //How many prefabs to place. It'll try it's hardest to place this many at the very least. You're basically guaranteed this amount of prefabs.
#define AST_NUMPREFABSEXTRA 3//Up to how many extra prefabs to place randomly. You might or might not get these extra ones.
#endif

#define AST_MAPSEEDBORDER 10 //Min distance from map edge for seeds.
#define AST_MAPBORDER 3      //Absolute map border around generated content
#define AST_ZLEVEL 5         //Zlevel for generation.
//END

#define MIN_EFFECTIVE_RAD 3 //How many rads after resistances before it actually does anything. Example: This is set to 3, someone takes rad damage that is reduced to 2 by resistances. Nothing happens as its below the min. of 3.
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
#define INFINITY 1e31 //closer then enough

//#define nround(x, n) round(x, 10 ** n)
//#define floor(x) round(x)
//#define ceiling(x) -round(-x)

#define ceil(x) (-round(-(x)))
#define nround(x) (((x % 1) >= 0.5)?round(x):ceil(x))

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MOB_NAME_MAX_LENGTH 50



#define T0C 273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC

#define OCEAN_TEMP 321.15 //48degC -- Not super realistic, but there's underwater hot vents!
#define TRENCH_TEMP 274 //Right above freezing.

#define BURNING_LV1 0   //Lv1 starts at this duration.
#define BURNING_LV2 200 //Lv2 ^^
#define BURNING_LV3 400 //Lv3 ^^

#define OCEAN_COLOR "#4DA0FD"
#define OCEAN_LIGHT  rgb(0.160 * 255, 0.60 * 255, 1.00 * 255, 0.65 * 255)
#define TRENCH_LIGHT rgb(0.025 * 255, 0.05 * 255, 0.15 * 255, 0.70 * 255)

// Defines the Mining Z level, change this when the map changes
// all this does is set the z-level to be ignored by erebite explosion admin log messages
// if you want to see all erebite explosions set this to 0 or -1 or something
#define MINING_Z 5

//FLAGS BITMASK
#define ONBACK 1			// can be put in back slot
#define TABLEPASS 2			// can pass by a table or rack
#define NODRIFT 4			// thing doesn't drift in space
#define USEDELAY 8			// put this on either a thing you don't want to be hit rapidly, or a thing you don't want people to hit other stuff rapidly with
#define EXTRADELAY 16		// 1 second extra delay on use
#define NOSHIELD 32			// weapon not affected by shield. MBC also put this flag on cloak/shield device to minimize istype checking, so consider this more SHIELD_ACT (rename? idk)
#define CONDUCT 64			// conducts electricity (metal etc.)
#define ONBELT 128			// can be put in belt slot
#define FPRINT 256			// takes a fingerprint
#define ON_BORDER 512		// item has priority to check when entering or leaving
#define DOORPASS 1024		// can pass through a closed door
#define TALK_INTO_HAND 2048		//automagically talk into this object when a human is holding it (Phone handset!)
#define OPENCONTAINER	4096	// is an open container for chemistry purposes
#define ISADVENTURE 8192        // is an atom spawned in an adventure area
#define NOSPLASH 16384  		//No beaker etc. splashing. For Chem machines etc.
#define SUPPRESSATTACK 32768 	//No attack when hitting stuff with this item.
#define FLUID_SUBMERGE 65536	//gets an overlay when submerged in fluid
#define IS_PERSPECTIVE_FLUID 131072	//gets a perspective overlay from adjacent fluids
#define ALWAYS_SOLID_FLUID 262144	//specifically note this object as solid
#define HAS_EQUIP_CLICK 524288 //Calls equipment_click from hand_range_attack on items worn with this flag set.

// human equipment slots
#define SLOT_BACK 1
#define SLOT_WEAR_MASM 2
#define SLOT_L_HAND 4
#define SLOT_R_HAND 5
#define SLOT_BELT 6
#define SLOT_WEAR_ID 7
#define SLOT_EARS 8
#define SLOT_GLASSES 9
#define SLOT_GLOVES 10
#define SLOT_HEAD 11
#define SLOT_SHOES 12
#define SLOT_WEAR_SUIT 13
#define SLOT_W_UNIFORM 14
#define SLOT_L_STORE 15
#define SLOT_R_STORE 16
//#define SLOT_W_RADIO 17
#define SLOT_IN_BACKPACK 18
#define SLOT_IN_BELT 19

// bitflags for clothing parts
#define HEAD			1
#define TORSO			2
#define LEGS			4
#define ARMS			8

// other clothing-specific bitflags, applied via the c_flags var
#define SPACEWEAR					1		// combined HEADSPACE and SUITSPACE into this because seriously??
#define MASKINTERNALS				2		// mask allows internals
#define COVERSEYES					4		// combined COVERSEYES, COVERSEYES and COVERSEYES into this
#define COVERSMOUTH					8		// combined COVERSMOUTH and COVERSMOUTH into this.
#define ONESIZEFITSALL				16		// can be worn by fatties (or children? ugh)
#define NOSLIP						32		// for galoshes/magic sandals/etc that prevent slipping on things
#define SLEEVELESS					64		// ain't got no sleeeeeves
#define BLOCKSMOKE					128		//block smoke inhalations (gas mask)
#define IS_JETPACK					256
#define EQUIPPED_WHILE_HELD			512		//doesn't need to be worn to appear in the 'get_equipped_items' list and apply itemproperties (protections resistances etc)! for stuff like shields
#define NOT_EQUIPPED_WHEN_WORN		1024	//return early out of equipped/unequipped, unless in SLOT_L_HAND or SLOT_R_HAND (i.e.: if EQUIPPED_WHILE_HELD)
#define HAS_GRAB_EQUIP				2048 	//if we currently have a grab (or by extention, a block) attached to us
#define BLOCK_TOOLTIP				4096	//whether or not we should show extra tooltip info about blocking with this item
#define BLOCK_CUT					8192	//block an extra point of cut damage when used to block
#define BLOCK_STAB					16384	//block an extra point of stab damage when used to block
#define BLOCK_BURN					32768	//block an extra point of burn damage when used to block
#define BLOCK_BLUNT					65536	//block an extra point of blunt damage when used to block

//clothing dirty flags (not used for anything other than submerged overlay update currently. eventually merge into update_clothing)
#define C_BACK 1
#define C_MASK 2
#define C_LHAND 4
#define C_RHAND 8
#define C_BELT 16
#define C_ID 32
#define C_EARS 64
#define C_GLASSES 128
#define C_GLOVES 256
#define C_HEAD 512
#define C_SHOES 1024
#define C_SUIT 2048
#define C_UNIFORM 4096


//Suit blood flags
#define SUITBLOOD_ARMOR 1
#define SUITBLOOD_COAT 2

// tool bitflags on items
#define TOOL_CLAMPING 1
#define TOOL_CUTTING 2
#define TOOL_PRYING 4
#define TOOL_PULSING 8
#define TOOL_SAWING 16
#define TOOL_SCREWING 32
#define TOOL_SNIPPING 64
#define TOOL_SPOONING 128
#define TOOL_WELDING 256
#define TOOL_WRENCHING 512
#define TOOL_CHOPPING 1024 // for firaxes, does additional damage to doors.

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
//TBD the rest

//temp_flags lol for atoms and im gonna be constantly adding and removing these
//this doesn't entirely make sense, cause some other flags are temporary too! ok im runnign otu OF FUCKING SPACE
#define SPACE_PUSHING 1 //used for removing us from mantapush list when we get deleted
#define MANTA_PUSHING 2	//used for removing us from spacepush list when we get beleted
#define HAS_PARTICLESYSTEM 4 			//atom has a particlesystem right now - used for clean gc to clear refs to itself etc blah
#define HAS_PARTICLESYSTEM_TARGET 8 	//atom is a particlesystem target - " "
#define HAS_BAD_SMOKE 16 				//atom has a bad smoke pointing to it right now - used for clean gc to clear refs to itself etc blah
#define IS_LIMB_ITEM 32 				//im a limb
#define HAS_KUDZU 64					//if a turf has kudzu.

//various mob_flags go here
#define MOB_HEARS_ALL 1 	//For mobs who can hear everything (mainly observer ghossts)
#define SPEECH_REVERSE 2 	//God Ecaps
#define SPEECH_BLOB 4		//yes
#define SEE_THRU_CAMERAS 8	//for ai eye
#define IS_BONER 16			//for skeletals
#define IS_RELIQUARY 32 //for Azungar's reliquary stuff
#define IS_RELIQUARY_SOLDIER 64 //for Azungar's reliquary stuff
#define IS_RELIQUARY_GUARDIAN 128 //for Azungar's reliquary stuff
#define IS_RELIQUARY_TECHNICIAN 256 //for Azungar's reliquary stuff
#define IS_RELIQUARY_CURATOR 512 //for Azungar's reliquary stuff
#define AT_GUNPOINT 1024 	//quick check for guns holding me at gunpoint
#define IGNORE_SHIFT_CLICK_MODIFIER 2048 //shift+click doesn't retrigger a SHIFT keypress - use for mobs that sprint on shift and not on mobs that use shfit for bolting doors etc
#define LIGHTWEIGHT_AI_MOB 4096		//not a part of the normal 'mobs' list so it wont show up in searches for observe admin etc, has its own slowed update rate on Life() etc
#define USR_DIALOG_UPDATES_RANGE 8192	//updateusrdialog will consider this mob as being able to 'attack_ai' and update its ui at range

//object_flags
#define BOTS_DIRBLOCK 1	//bot considers this solid object that can be opened with a Bump() in pathfinding DirBlockedWithAccess
#define NO_ARM_ATTACH 2	//illegal for arm attaching
#define CAN_REPROGRAM_ACCESS 4	//access gun can reprog

//deconstruction_flags
#define DECON_NONE 0
#define DECON_SIMPLE 1 //no reqs, just deconstruct!
#define DECON_SCREWDRIVER 2
#define DECON_WRENCH 4
#define DECON_CROWBAR 8
#define DECON_WELDER 16
#define DECON_WIRECUTTERS 32
#define DECON_MULTITOOL 64
#define DECON_BUILT 128 //flag added to something that is player-built
#define DECON_ACCESS 256 //can only be deconstructed if access required is null


//THROW flags (what kind of throw, we can have ddifferent kinds of throws ok)
#define THROW_NORMAL 1
#define THROW_CHAIRFLIP 2
#define THROW_GUNIMPACT 4
#define THROW_SLIP 8

//various sprint flags go here
#define SPRINT_NORMAL 0
#define SPRINT_BAT 1
#define SPRINT_BAT_CLOAKED 2
#define SPRINT_SNIPER 4
#define SPRINT_FIRE 8

//sound mute
#define SOUND_NONE 0
#define SOUND_SPEECH 1
#define SOUND_BLAH 2
#define SOUND_ALL 4
#define SOUND_VOX 8

//Area Ambience
#define AMBIENCE_LOOPING 1
#define AMBIENCE_FX_1 2
#define AMBIENCE_FX_2 3

//Reserved Area Ambience sound channels
#define SOUNDCHANNEL_LOOPING 123
#define SOUNDCHANNEL_FX_1 124
#define SOUNDCHANNEL_FX_2 125

//various turf flags go here (todo : port some more shit over to turf flags)
#define MOB_SLIP 1 			//simulated floor slippage
#define MOB_STEP 2 			//simulated floor steppage
#define IS_TYPE_SIMULATED 4	//lol idk this kind of sucks, but i guess i can avoid some type checks in atmos processing
#define CAN_BE_SPACE_SAMPLE 8 //can atmos use this tile as a space sample?
#define MANTA_PUSH 16 	//turf is pushy. for manta
#define FLUID_MOVE 32 	//fluid move gear suffers no penalty on these turfs
#define SPACE_MOVE 64 	//space move gear suffers no penalty on these turfs
// channel numbers for power

#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
#define TOTAL 4	//for total power used only

// bitflags for machine stat variable
#define BROKEN 1		// machine non-functional
#define NOPOWER 2		// no available power
#define POWEROFF 4		// machine shut down, but may still draw a trace amount
#define MAINT 8			// under maintainance
#define HIGHLOAD 16		// using a lot of power

// Radio (headset etc) colors.
#define RADIOC_STANDARD "#008000"
#define RADIOC_INTERCOM "#006080"
#define RADIOC_COMMAND "#334E6D"
#define RADIOC_SECURITY "#E00000"
#define RADIOC_ENGINEERING "#A86800"
#define RADIOC_MEDICAL "#461B7E"
#define RADIOC_RESEARCH "#153E7E"
#define RADIOC_CIVILIAN "#A10082"
#define RADIOC_SYNDICATE "#962121"
#define RADIOC_OTHER "#800080"

// Frequency defines for headsets & intercoms (Convair880).
#define R_FREQ_MINIMUM 1441		// Minimum "selectable" freq
#define R_FREQ_MAXIMUM 1489		// Maximum "selectable" freq
#define R_FREQ_DEFAULT 1459
#define R_FREQ_COMMAND 1358
#define R_FREQ_SECURITY 1359
#define R_FREQ_ENGINEERING 1357
#define R_FREQ_RESEARCH 1354
#define R_FREQ_MEDICAL 1356
#define R_FREQ_CIVILIAN 1355
#define R_FREQ_SYNDICATE 1352 // Randomized for nuke rounds.
#define R_FREQ_GANG 1400 // Placeholder, it's actually randomized in gang rounds.
#define R_FREQ_MULTI 1451
#define R_FREQ_INTERCOM_COLOSSEUM 1403
#define R_FREQ_INTERCOM_MEDICAL 1445
#define R_FREQ_INTERCOM_SECURITY 1485
#define R_FREQ_INTERCOM_BRIG 1489
#define R_FREQ_INTERCOM_RESEARCH 1443
#define R_FREQ_LOUDSPEAKERS 1438
#define R_FREQ_INTERCOM_ENGINEERING 1441
#define R_FREQ_INTERCOM_CARGO 1455
#define R_FREQ_INTERCOM_CATERING 1485
#define R_FREQ_INTERCOM_AI 1447
#define R_FREQ_INTERCOM_BRIDGE 1442

// let's start putting adventure zone factions in here
#define R_FREQ_WIZARD 1089 // magic number, used in many magic tricks
#define R_FREQ_INTERCOM_WIZARD 1089
#define R_FREQ_INTERCOM_OWLERY 1291
#define R_FREQ_INTERCOM_SYNDCOMMAND 6174 // kaprekar's constant, a unique and weird number
#define R_FREQ_INTERCOM_TERRA8 1156 // 34 squared, octahedral number, centered pentagonal number, centered hendecagonal number
#define R_FREQ_INTERCOM_HEMERA 777 // heh

// These are for the Syndicate headset randomizer proc.
#define R_FREQ_BLACKLIST_HEADSET list(R_FREQ_DEFAULT, R_FREQ_COMMAND, R_FREQ_SECURITY, R_FREQ_ENGINEERING, R_FREQ_RESEARCH, R_FREQ_MEDICAL, R_FREQ_CIVILIAN, R_FREQ_SYNDICATE, R_FREQ_GANG, R_FREQ_MULTI)
#define R_FREQ_BLACKLIST_INTERCOM list(R_FREQ_INTERCOM_COLOSSEUM, R_FREQ_INTERCOM_MEDICAL, R_FREQ_INTERCOM_SECURITY, R_FREQ_INTERCOM_BRIG, R_FREQ_INTERCOM_RESEARCH, R_FREQ_INTERCOM_ENGINEERING, R_FREQ_INTERCOM_CARGO, R_FREQ_INTERCOM_CATERING, R_FREQ_INTERCOM_AI, R_FREQ_INTERCOM_BRIDGE)


proc/default_frequency_color(freq)
	switch(freq)
		if(R_FREQ_DEFAULT)
			return RADIOC_STANDARD
		if(R_FREQ_COMMAND)
			return RADIOC_COMMAND
		if(R_FREQ_SECURITY)
			return RADIOC_SECURITY
		if(R_FREQ_ENGINEERING)
			return RADIOC_ENGINEERING
		if(R_FREQ_RESEARCH)
			return RADIOC_RESEARCH
		if(R_FREQ_MEDICAL)
			return RADIOC_MEDICAL
		if(R_FREQ_CIVILIAN)
			return RADIOC_CIVILIAN
		if(R_FREQ_SYNDICATE)
			return RADIOC_SYNDICATE
		if(R_FREQ_GANG)
			return RADIOC_SYNDICATE
		if(R_FREQ_INTERCOM_MEDICAL)
			return RADIOC_MEDICAL
		if(R_FREQ_INTERCOM_SECURITY)
			return RADIOC_SECURITY
		if(R_FREQ_INTERCOM_BRIG)
			return "#FF5000"
		if(R_FREQ_INTERCOM_RESEARCH)
			return RADIOC_RESEARCH
		if(R_FREQ_INTERCOM_ENGINEERING)
			return RADIOC_ENGINEERING
		if(R_FREQ_INTERCOM_CARGO)
			return RADIOC_ENGINEERING
		if(R_FREQ_INTERCOM_CATERING)
			return RADIOC_CIVILIAN
		if(R_FREQ_INTERCOM_AI)
			return RADIOC_COMMAND
		if(R_FREQ_INTERCOM_BRIDGE)
			return RADIOC_COMMAND

//   HOLIDAYS
// #define HALLOWEEN 1
// #define XMAS 1
//#define CANADADAY 1

// so that you can move things around easily, in theory
// before you use any of these, please make sure the HUD you are using them in is actually related to the ones they're used on,
// so that we dont move the human HUD around and half the robot HUD winds up being all over the place (again)
#define ui_invtoggle "CENTER-5, SOUTH"
#define ui_belt "CENTER-4, SOUTH"
#define ui_storage1 "CENTER-3, SOUTH"
#define ui_storage2 "CENTER-2, SOUTH"
#define ui_back "CENTER-1, SOUTH"
#define ui_lhand "CENTER, SOUTH"
#define ui_rhand "CENTER+1, SOUTH"
#define ui_twohand "CENTER+0:16, SOUTH"
#define ui_shoes "CENTER-5, SOUTH+1"
#define ui_gloves "CENTER-4, SOUTH+1"
#define ui_id "CENTER-3, SOUTH+1"
#define ui_clothing "CENTER-2, SOUTH+1"
#define ui_suit "CENTER-1, SOUTH+1"
#define ui_glasses "CENTER, SOUTH+1"
#define ui_ears "CENTER+1, SOUTH+1"
#define ui_mask "CENTER+2, SOUTH+1"
#define ui_head "CENTER+3, SOUTH+1"
#define ui_throwing "CENTER+2, SOUTH"
#define ui_intent "CENTER+3, SOUTH"
#define ui_mintent "CENTER+5, SOUTH"
#define ui_resist "CENTER+5, SOUTH"
#define ui_pulling "CENTER+6, SOUTH"
#define ui_rest "CENTER+6, SOUTH"
#define ui_abiltoggle "CENTER-6, SOUTH"
#define ui_stats "CENTER+7, SOUTH"
#define ui_legend "CENTER+7:16, SOUTH"


#define ui_zone_sel "CENTER+4, SOUTH"
#define ui_storage_area "1,8 to 1,1"
#define ui_storage_close "1,1"


#define tg_ui_invtoggle "WEST:6,SOUTH:5"
#define tg_ui_belt "CENTER-3:9,SOUTH:5"
#define tg_ui_storage1 "CENTER+1:20,SOUTH:5"
#define tg_ui_storage2 "CENTER+2:22,SOUTH:5"
#define tg_ui_back "CENTER-2:11,SOUTH:5"
#define tg_ui_lhand "CENTER-1:15, SOUTH:5"
#define tg_ui_rhand "CENTER+0:15, SOUTH:5"
#define tg_ui_twohand "CENTER-1:31, SOUTH:5"
#define tg_ui_shoes "WEST+1:8,SOUTH:5"
#define tg_ui_gloves "WEST+2:10,SOUTH+1:7"
#define tg_ui_id "CENTER-4:7,SOUTH:5"
#define tg_ui_clothing "WEST:6,SOUTH+1:7"
#define tg_ui_suit "WEST+1:8,SOUTH+1:7"
#define tg_ui_glasses "WEST:6,SOUTH+2:9"
#define tg_ui_ears "WEST+2:10,SOUTH+2:9"
#define tg_ui_mask "WEST+1:8,SOUTH+2:9"
#define tg_ui_head "WEST+1:8,SOUTH+3:11"
#define tg_ui_legend "WEST+2:10, SOUTH+3:11"
#define tg_ui_throwing "EAST-1:28,SOUTH+1:7"
#define tg_ui_intent "EAST-3:24,SOUTH:5"
#define tg_ui_mintent "EAST-2:26,SOUTH:5"
#define tg_ui_resist "EAST-3:24, SOUTH+1:7"
#define tg_ui_pulling "EAST-2:26, SOUTH+1:7"
#define tg_ui_rest "EAST-2:26,SOUTH+1:7"
#define tg_ui_abiltoggle "WEST+2:9,SOUTH:5"
#define tg_ui_stats "WEST+2:10,SOUTH:5"
#define tg_ui_sprint "EAST-2:26,SOUTH:5"
#define tg_ui_swaphands "CENTER:-1, SOUTH+1:2"
#define tg_ui_equip "CENTER:-18, SOUTH+1:2"

#define tg_ui_zone_sel "EAST-1:28,SOUTH:5"
#define tg_ui_extra_buttons "EAST-4:22,SOUTH:5:1"

#define ui_oxygen "EAST-3, NORTH"
#define ui_toxin "EAST-5, NORTH"
#define ui_internal "EAST, NORTH-1"
#define ui_fire "EAST-4, NORTH"
#define ui_rad "EAST-6, NORTH"
#define ui_temp "EAST-2, NORTH"
#define ui_health "EAST, NORTH"
#define ui_stamina "EAST-1, NORTH"
#define ui_pull "SOUTH,14"

#define ui_acti "SOUTH,11"
#define ui_movi "SOUTH,13"

#define ui_module "SOUTH-1,6"
#define ui_botradio "SOUTH-1,7"
#define ui_bothealth "EAST+1, NORTH"
#define ui_boto2 "EAST+1, NORTH-2"
#define ui_botfire "EAST+1, NORTH-3"
#define ui_bottemp "EAST+1, NORTH-4"
#define ui_cell "EAST+1, NORTH-6"
#define ui_botpull "SOUTH-1,14"
#define ui_botstore "SOUTH-1,4"
#define ui_panel "SOUTH-1,5"

#define ui_iarrowleft "SOUTH-1,11"
#define ui_iarrowright "SOUTH-1,13"
#define ui_zone_select "SOUTH,12"

#define ui_inv1 "SOUTH-1,1"
#define ui_inv2 "SOUTH-1,2"
#define ui_inv3 "SOUTH-1,3"

/*
//TESTING A LAYOUT
#define ui_mask "SOUTH-1:-14,1:7"
#define ui_headset "SOUTH-2:-14,1:7"
#define ui_head "SOUTH-1:-14,1:51"
#define ui_glasses "SOUTH-1:-14,2:51"
#define ui_ears "SOUTH-1:-14,3:51"
#define ui_oclothing "SOUTH-1:-49,1:51"
#define ui_iclothing "SOUTH-2:-49,1:51"
#define ui_shoes "SOUTH-3:-49,1:51"
#define ui_back "SOUTH-1:-49,2:51"
#define ui_lhand "SOUTH-2:-49,2:51"
#define ui_rhand "SOUTH-2:-49,0:51"
#define ui_gloves "SOUTH-3:-49,0:51"
#define ui_belt "SOUTH-2:-49,1:127"
#define ui_id "SOUTH-2:-49,2:127"
#define ui_storage1 "SOUTH-3:-49,1:127"
#define ui_storage2 "SOUTH-3:-49,2:127"

#define ui_dropbutton "SOUTH-3,12"
#define ui_swapbutton "SOUTH-1,13"
#define ui_resist "SOUTH-3,14"
#define ui_throw "SOUTH-3,15"
#define ui_oxygen "EAST+1, NORTH-4"
#define ui_toxin "EAST+1, NORTH-6"
#define ui_internal "EAST+1, NORTH-2"
#define ui_fire "EAST+1, NORTH-8"
#define ui_temp "EAST+1, NORTH-10"
#define ui_health "EAST+1, NORTH-11"
#define ui_pull "WEST+6,SOUTH-2"1
#define ui_hand "SOUTH-1,6"
#define ui_sleep "EAST+1, NORTH-13"
#define ui_rest "EAST+1, NORTH-14"
//TESTING A LAYOUT
*/

// gameticker
#define GAME_STATE_WORLD_INIT	1
#define GAME_STATE_PREGAME		2
#define GAME_STATE_SETTING_UP	3
#define GAME_STATE_PLAYING		4
#define GAME_STATE_FINISHED		5

//States for airlock_control
#define ACCESS_STATE_INTERNAL	-1
#define ACCESS_STATE_LOCKED		0
#define ACCESS_STATE_EXTERNAL	1

#define AIRLOCK_STATE_INOPEN		-2
#define AIRLOCK_STATE_PRESSURIZE	-1
#define AIRLOCK_STATE_CLOSED		0
#define AIRLOCK_STATE_DEPRESSURIZE	1
#define AIRLOCK_STATE_OUTOPEN		2

#define AIRLOCK_CONTROL_RANGE 5

#define DATALOGGER

#define CREW_OBJECTIVES

#define MISCREANTS

//mob intent type defines
#define INTENT_HARM "harm"
#define INTENT_DISARM "disarm"
#define INTENT_HELP "help"
#define INTENT_GRAB "grab"

//#define RESTART_WHEN_ALL_DEAD 1

//#define PLAYSOUND_LIMITER

//Projectile damage type defines
#define D_KINETIC 1
#define D_PIERCING 2
#define D_SLASHING 4
#define D_ENERGY 8
#define D_BURNING 16
#define D_RADIOACTIVE 32
#define D_TOXIC 48
#define D_SPECIAL 128

//Missing limb flags
#define LIMB_LEFT_ARM 1
#define LIMB_RIGHT_ARM 2
#define LIMB_LEFT_LEG 4
#define LIMB_RIGHT_LEG 8

// see in dark levels
#define SEE_DARK_FULL 8
#define SEE_DARK_HUMAN 3

//speeds !!!
#define BASE_SPEED 1.65
#define BASE_SPEED_SUSTAINED 1.5
#define RUN_SCALING 0.12
#define RUN_SCALING_LYING 0.2
#define RUN_SCALING_STAGGER 0.5
#define WALK_DELAY_ADD 0.8

//stamina config
#define STAMINA_MAX 200        			//Default max stamina value
#define STAMINA_REGEN 10   	   		 	//Default stamina regeneration rate.
#define STAMINA_ITEM_DMG 20     		//Default stamina damage objects do.
#define STAMINA_ITEM_COST 18    		//Default attack cost on user for attacking with items.
#define STAMINA_HTH_DMG 30      		//Default hand-to-hand (punch, kick) stamina damage.
#define STAMINA_HTH_COST 20     		//Default hand-to-hand (punch, kick) stamina cost
#define STAMINA_MIN_ATTACK 91   		//The minimum amount of stamina required to attack.
#define STAMINA_NEG_CAP -75     		//How far into the negative we can take stamina. (People will be stunned while stamina regens up to > 0 - so this can lead to long stuns if set too high)
#define STAMINA_NEG_CAP_STUN_TIME 60   	//When we reach the neg cap, how long to paralyze?
#define STAMINA_STUN_TIME 5     		//How long we will be stunned for, for being <= 0 stamina
#define STAMINA_STUN_CRIT_TIME 8  		//How long we will be stunned for, for being <= NEGCAP stamina
#define STAMINA_GRAB_COST 25    		//How much grabbing someone costs.
#define STAMINA_DISARM_COST 5   		//How much disarming someone costs.
#define STAMINA_FLIP_COST 25    		//How much flipping / suplexing costs.
#define STAMINA_CRIT_CHANCE 25  		//Base chance of landing a critical hit to stamina.
#define STAMINA_CRIT_DIVISOR 2  		//Divide stamina by how much on a crit
#define STAMINA_BLOCK_CHANCE 40 		//Chance to block an attack in disarm mode. Settings this to 0 effectively disables the blocking system.
#define STAMINA_GRAB_BLOCK_CHANCE 85    //Chance to block grabs.
#define STAMINA_DEFAULT_BLOCK_COST 5    //Cost of blocking an attack.
#define STAMINA_LOW_COST_KICK 1 	    //Does kicking people on the ground cost less stamina ? (Right now it doesnt cost less but rather refunds some because kicking people on the ground is very relaxing OKAY)
#define STAMINA_NO_ATTACK_CAP 1 		//Attacks only cost stamina up to the min atttack cap. after that they are free
#define STAMINA_NEG_CRIT_KNOCKOUT 0     //Getting crit below or at 0 stamina will always knock out
#define STAMINA_WINDED_SPEAK_MIN 0      //Can't speak below this point.
#define STAMINA_SPRINT 64				//can only sprint above this number
#define STAMINA_COST_SPRINT 7			//cost of moving in sprint
#define SUSTAINED_RUN_GRACE 0.5 SECONDS	//grace period where sustained run can be sustained
#define SUSTAINED_RUN_REQ 8				//how many tiles to start sustained run

//This is a bad solution. Optimally this should scale.
#define STAMINA_MIN_WEIGHT_CLASS 2 	    //Minimum weightclass (w_class) of an item that allows for knock-outs and critical hits.

//This is the last resort option for the RNG lovers.
#define STAMINA_STUN_ON_CRIT 0          //Getting crit stuns the affected person for a short moment?
#define STAMINA_STUN_ON_CRIT_SEV 2      //How long people get stunned on crits

#define STAMINA_CRIT_DROP 0	    	    //If 1, stamina crits will instantly set a targets stamina to the number set below instead of doing a multiplier.
#define STAMINA_CRIT_DROP_NUM 1			//Amount of stamina to drop to on a crit.
////////////////////////////////////////////////////

#define STAMINA_SCALING_KNOCKOUT_BASE 20   //Base chance at 0 stamina to be knocked out by an attack - scales up the lower stamina goes.
#define STAMINA_SCALING_KNOCKOUT_SCALER 60 //Up to which *additional* value the chance will scale with lower stamina nearly the negative cap

#define STAMINA_EXHAUSTED_STR "<p style=\"color:red;font-weight:bold;\">You are too exhausted to attack.</p>" //The message tired people get when they try to attack.

#define STAMINA_DEFAULT_FART_COST 0  //How much farting costs. I am not even kidding.

#define USE_STAMINA_DISORIENT //use the new stamina based stun disorient system thingy

#define DIAG_MOVE_DELAY_MULT 1.4

//reagent_container bit flags
#define RC_SCALE 	1		// has a graduated scale, so total reagent volume can be read directly (e.g. beaker)
#define RC_VISIBLE	2		// reagent is visible inside, so color can be described
#define RC_FULLNESS 4		// can estimate fullness of container
#define RC_SPECTRO	8		// spectroscopic glasses can analyse contents

// blood system and item damage things
#define DAMAGE_BLUNT 1
#define DAMAGE_CUT 2
#define DAMAGE_STAB 4
#define DAMAGE_BURN 8					// a) this is an excellent idea and b) why do we still use damtype strings then
#define DAMAGE_CRUSH 16					// crushing damage is technically blunt damage, but it causes bleeding
#define DEFAULT_BLOOD_COLOR "#990000"	// speak for yourself, as a shapeshifting illuminati lizard, my blood is somewhere between lime and leaf green
#define DAMAGE_TYPE_TO_STRING(x) (x == DAMAGE_BLUNT ? "blunt" : x == DAMAGE_CUT ? "cut" : x == DAMAGE_STAB ? "stab" : x == DAMAGE_BURN ? "burn" : x == DAMAGE_CRUSH ? "crush" : "")

//some different generalized block weapon shapes that i can re use instead of copy paste
#define BLOCK_SETUP		src.c_flags |= BLOCK_TOOLTIP; RegisterSignal(src, COMSIG_ITEM_BLOCK_BEGIN, .proc/block_prop_setup, TRUE) //makes the magic work
#define BLOCK_ALL		BLOCK_SETUP; src.c_flags |= (BLOCK_BLUNT | BLOCK_CUT | BLOCK_STAB | BLOCK_BURN)
#define BLOCK_LARGE		BLOCK_SETUP; src.c_flags |= (BLOCK_BLUNT | BLOCK_CUT | BLOCK_STAB)
#define BLOCK_SWORD		BLOCK_LARGE
#define BLOCK_ROD 		BLOCK_SETUP; src.c_flags |= (BLOCK_BLUNT | BLOCK_CUT)
#define BLOCK_TANK		BLOCK_SETUP; src.c_flags |= (BLOCK_BLUNT | BLOCK_CUT | BLOCK_BURN)
#define BLOCK_SOFT		BLOCK_SETUP; src.c_flags |= (BLOCK_STAB | BLOCK_BURN)
#define BLOCK_KNIFE		BLOCK_SETUP; src.c_flags |= (BLOCK_CUT | BLOCK_STAB)
#define BLOCK_BOOK		BLOCK_SETUP; src.c_flags |= (BLOCK_CUT | BLOCK_STAB)
#define BLOCK_ROPE		BLOCK_BOOK

#define DEFAULT_BLOCK_PROTECTION_BONUS 2 //blocking to match damage type correctly gives you a -2 bonus on protection (unless this item grants Even More protection, that overrides this)

// Process Scheduler defines
// Process status defines
#define PROCESS_STATUS_IDLE 1
#define PROCESS_STATUS_QUEUED 2
#define PROCESS_STATUS_RUNNING 3
#define PROCESS_STATUS_MAYBE_HUNG 4
#define PROCESS_STATUS_PROBABLY_HUNG 5
#define PROCESS_STATUS_HUNG 6

// Process time thresholds
#define PROCESS_DEFAULT_HANG_WARNING_TIME 	300 SECONDS
#define PROCESS_DEFAULT_HANG_ALERT_TIME 	600 SECONDS
#define PROCESS_DEFAULT_HANG_RESTART_TIME 	900 SECONDS
#define PROCESS_DEFAULT_SCHEDULE_INTERVAL 	50  // 50 ticks
#define PROCESS_DEFAULT_TICK_ALLOWANCE		20	// 20% of one tick
#define MAX_TICK_USAGE 95 // 95% of a tick

/** Delete queue defines */
#define MIN_DELETE_CHUNK_SIZE 1
#define MAX_DELETE_CHUNK_SIZE 100

// attack message flags
#define SUPPRESS_BASE_MESSAGE 1
#define SUPPRESS_SOUND 2
#define SUPPRESS_VISIBLE_MESSAGES 4
#define SUPPRESS_SHOWN_MESSAGES 8
#define SUPPRESS_LOGS 16
// used by limbs which make a special kind of melee attack happen
#define SUPPRESS_MELEE_LIMB 15

#define GRAB_PASSIVE 0
#define GRAB_AGGRESSIVE 1
#define GRAB_NECK 2
#define GRAB_KILL 3
#define GRAB_PIN 4

#define DISORIENT_MISSTEP_CHANCE 40

#define STEP_PRIORITY_MAX 2
#define STEP_PRIORITY_MED 1
#define STEP_PRIORITY_LOW 0.5
#define STEP_PRIORITY_NONE 0

//I feel like these should be a thing, ok
#define true 1
#define false 0

//For statusEffects
#define INFINITE_STATUS null

//How much stuff is allowed in the pools before the lifeguard throws them into the deletequeue instead. A shameful lifeguard.
#define DEFAULT_POOL_SIZE 150
//#define DETAILED_POOL_STATS

#define LOOC_RANGE 8

#define DELETE_STOP 0
#define DELETE_RUNNING 1
#define DELETE_CHECK 2

#define LAG_LOW 13
#define LAG_MED 20
#define LAG_HIGH 40
#define LAG_REALTIME 66

//input keystates
#define MODIFIER_NONE   0x0000
#define MODIFIER_SHIFT  0x0001
#define MODIFIER_ALT    0x0002
#define MODIFIER_CTRL   0x0004

#define HEARING_NORMAL 0
#define HEARING_BLOCKED 1
#define HEARING_ANTIDEAF -1

// shoes!
#define LACES_NORMAL 0
#define LACES_TIED 1
#define LACES_CUT 2
#define LACES_NONE -1

//moved from computerfiles.dm
//File permission flags
#define COMP_ROWNER 1
#define COMP_WOWNER 2
#define COMP_DOWNER 4
#define COMP_RGROUP 8
#define COMP_WGROUP 16
#define COMP_DGROUP 32
#define COMP_ROTHER 64
#define COMP_WOTHER 128
#define COMP_DOTHER 256

#define COMP_HIDDEN 0
#define COMP_ALLACC 511

//moved from chem
#define SOLID 1
#define LIQUID 2
#define GAS 3

//fluid pipe defines
#define FLUIDPIPE_NORMAL 1
#define FLUIDPIPE_SOURCE 2
#define FLUIDPIPE_SINK 3
#define DEFAULT_FLUID_CAPACITY 100

//moved from chemistry-holder.dm
#define TOUCH 1
#define INGEST 2
#define INJECT 3
#define MAX_TEMP_REACTION_VARIANCE 8

//moved from communications.dm
#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

//moved from power/lighting.dm
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

//moved from shipalert.dm
#define SHIP_ALERT_GOOD 0
#define SHIP_ALERT_BAD 1

// where you at, dawg, where you where you at, shuttle_controller.dm
#define SHUTTLE_LOC_CENTCOM 0
#define SHUTTLE_LOC_STATION 1
#define SHUTTLE_LOC_TRANSIT 1.5
#define SHUTTLE_LOC_RETURNED 2

//moved from guardbot.dm because i wanna use this list of buddy hats on some critters
#define BUDDY_HATS list("detective","hoscap","hardhat","hosberet","ntberet","chef","souschef","captain","centcom","centcom-red","tophat","ptophat","mjhat","plunger","cakehat0","cakehat1","butt","santa","yellow","blue","red","green","black","white","psyche","wizard","wizardred","wizardpurple","witch","obcrown","macrown","safari","dolan","viking","mailcap","bikercap","paper","apprentice","chavcap","policehelm","captain-fancy","rank-fancy","mime_beret","mime_bowler")

#define EYEBLIND_L 1 // for calculating human eye funkery
#define EYEBLIND_R 2

#define ENSURE_IMAGE(x, y, z) if(!x) x = image(icon = y, icon_state = z); else x.icon_state = z

// preference datum limits
#define NAME_CHAR_MAX 16
#define NAME_CHAR_MIN 2
#define FLAVOR_CHAR_LIMIT 256

#define FULLNAME_MAX 50

//JOB EXPERIENCE STUFF BELOW
#define XP_ROUND_CAP 6000 //Hard CAP on XP earned per round, used to prevent exploiting.
#define XP_GLOBAL_MOD 1 //Global multiplier for xp earned. normalXP * XP_GLOBAL_MOD. For events or adjustments.
#define XP_CONSTANT 0.2 //Constant for scaling the XP curve.
#define XP_FOR_LEVEL(LV) (((LV/XP_CONSTANT)**2)) //Returns XP required for the given level.
#define LEVEL_FOR_XP(XP) (XP_CONSTANT * sqrt(XP))//Returns the level for the given amount of XP. Recommend rounding it down.

//Defines the range of time that is throttled, see below. Currently very roughly one minute "game time".
#define XP_THROTTLE_TICKS 600

//This much XP is allowed per XP_THROTTLE_TICKS. Should prevent people from exploiting certain things. This cap is ignored if a person if awarded XP in excess of this cap in one burst.
//Roughly 2 times the expected XP per minute, currently.
#define XP_THROTTLE_AMT 10

//Short macro that will give USR in the current context XP amount if they have the appropriate job.
//USR_JOB_XP("Clown", 5) //Would give usr 5xp if they are a clown.
#define USR_JOB_XP(JOB, XP) if(usr.job == JOB && usr.key) award_xp(usr.key, JOB, XP)

//Short macro that will give TRG, XP amount if they have the appropriate job.
//JOB_XP(someMobHere, "Clown", 5) //Would give someMobHere 5xp if they are a clown.
#define JOB_XP(TRG, JOB, XP) if(ismob(TRG) && TRG:job == JOB && TRG:key) award_xp(TRG:key, JOB, XP)

//0.2, 25, 100, 225, 400, 625 ... 7=1225,10=2500,20=10000,30=22500,50=62500,100=250000
//Say a round lasts 60 minutes. Level 5 should take 2 hours. ??
//TOTAL TIME SPENT FOR LEVELS WITH CONSTANT 0.2, LV5@2hours, 5.2XP per min:
//625XP/120m,5.2XP-min.lv5=2 hours, lv7=3.9 hours, lv10=8 hours, lv20=32.05 hours, lv30=72,1 hours, lv50=200 hours, lv100=801 hours/33 days
//JOB EXPERIENCE STUFF END

//This is here because it's used literally everywhere in the codebase below this.
#ifdef SPACEMAN_DMM
#define LAGCHECK(x)
#else
#define LAGCHECK(x) if (lagcheck_enabled && world.tick_usage > x) sleep(world.tick_lag)
#endif

//Define clientside tick lag seperately from world.tick_lag
//'cause smoothness looks good.
// Glides are supposed to automatically adjust to client framerate. HOWEVER THEY DO NOT :: http://www.byond.com/forum/?post=2241289
// We do the glide size compensation manually in the relevant places.
#define CLIENTSIDE_TICK_LAG_SMOOTH 0.25
//fuck me, I have no idea why there's only 2 framerates that handle smooth glides for us. It's probably because byond is bugged.
//anyway just putting this define here for the client framerate toggle button between SMOOTH AND CHUNKY OH YEAH
#define CLIENTSIDE_TICK_LAG_CHUNKY 0.4

//its the future now
#define CLIENTSIDE_TICK_LAG_CREAMY 0.15


//MBC : I should have added defines like these earlier - most widescreen bits aren't using them as of now!
#define WIDE_TILE_WIDTH 21
#define SQUARE_TILE_WIDTH 15

//The value of mapvotes. A passive vote is one done through player preferences, an active vote is one where the player actively chooses a map
#define MAPVOTE_PASSIVE_WEIGHT 1.0
#define MAPVOTE_ACTIVE_WEIGHT 1.0
//Amount of 1 Second ticks to spend in the pregame lobby before roundstart. Has been 150 seconds for a couple years.
#define PREGAME_LOBBY_TICKS 150	// raised from 120 to 180 to accomodate the v500 ads, then raised back down to 150 after Z5 was introduced.

//for light queue - when should we queue? and when should we pause processing our dowork loop?
#define LIGHTING_MAX_TICKUSAGE 90

//Twitch plays shitty bill!
//#define TWITCH_BOT_ALLOWED
#define TWITCH_BOT_ADDR "142.93.72.14"
#define TWITCH_BOT_CKEY "twitchbill"

#define IS_TWITCH_CONTROLLED(M) (M.client && M.client.ckey == TWITCH_BOT_CKEY)
#define TWITCH_BOT_AUTOCLOSE_BLOCK(X) (X == "mainwindow" || X == "screenSizeHelper")
#define TWITCH_BOT_INTERACT_BLOCK(X) (istype(X,/obj/item/hand_labeler) || istype(X,/obj/item/paper) || istype(X,/obj/storage/crate/loot) || istype(X,/obj/machinery/vending) || istype(X,/obj/submachine/ATM) || istype(X,/obj/item/pen/crayon))

// Enables RP mode (normally set by build process, but you can enable it locally here! wow!)
// #define RP_MODE


//Ass Jam! enables a bunch of wacky and not-good features. BUILD LOCALLY!!!
#ifdef RP_MODE
#define ASS_JAM 0
#elif BUILD_TIME_DAY == 13
#define ASS_JAM 1
#else
#define ASS_JAM 0
#endif

// time for johns madden
#define FOOTBALL_MODE 0


#if ASS_JAM
#ifndef TRAVIS_ASSJAM
#warn Building with ASS_JAM features enabled. Toggle this by changing BUILD_TIME_DAY in __build.dm
#endif
#endif

#ifdef Z_LOG_ENABLE
var/ZLOG_START_TIME
#define Z_LOG(LEVEL, WHAT, X) world.log << "\[[add_zero(world.timeofday - ZLOG_START_TIME, 6)]\] [WHAT] ([LEVEL]) " + X
#define Z_LOG_DEBUG(WHAT, X) Z_LOG("DEBUG", WHAT, X)
#define Z_LOG_INFO(WHAT, X) Z_LOG("INFO", WHAT, X)
#define Z_LOG_WARN(WHAT, X) Z_LOG("WARN", WHAT, X)
#define Z_LOG_ERROR(WHAT, X) Z_LOG("ERROR", WHAT, X)
#else
#define Z_LOG(LEVEL, WHAT, X) //
#define Z_LOG_DEBUG(WHAT, X) //
#define Z_LOG_INFO(WHAT, X) //
#define Z_LOG_WARN(WHAT, X) //
#define Z_LOG_ERROR(WHAT, X) //
#endif

#define CRITTER_REACTION_LIMIT 50
#define CRITTER_REACTION_CHECK(x) if (x++ > CRITTER_REACTION_LIMIT) return

//Activates the viscontents warps
#define NON_EUCLIDEAN 1

#define CURRENT_SPACE_YEAR 2053

#define DELQUEUE_SIZE 35
#define DELQUEUE_WAIT 30

// Used for /datum/respawn_controller - DOES NOT COVER ALL RESPAWNS YET
#define DEFAULT_RESPAWN_TIME 18000
#define RESPAWNS_ENABLED 0

#if DM_BUILD > 1490
#define lentext length
#endif

#define VOLUME_CHANNEL_MASTER 0
#define VOLUME_CHANNEL_GAME 1
#define VOLUME_CHANNEL_AMBIENT 2
#define VOLUME_CHANNEL_RADIO 3
#define VOLUME_CHANNEL_ADMIN 4

//ex:  var/time = 10 SECONDS
#define SECONDS *10
#define MINUTES *600
#define HOURS *36000

#define SECOND SECONDS
#define MINUTE MINUTES
#define HOUR HOURS

#define WATTS *1
#define METERS *1
#define KILOGRAMS *1
#define AMPERES *1
#define KELVIN *1
#define MOLES *1
#define CANDELAS *1

#define WATT WATTS
#define METER METERS
#define KILOGRAM KILOGRAMS
#define AMPERE AMPERES
#define AMP AMPERES
#define AMPS AMPERES
#define MOLE MOLES
#define CANDELA CANDELAS

#define YOTTA *(10**24)
#define ZETTA *(10**21)
#define EXA   *(10**18)
#define PETA  *(10**15)
#define TERA  *(10**12)
#define GIGA  *(10**9)
#define MEGA  *(10**6)
#define KILO  *(10**3)
#define HECTO *(10**2)
#define DEKA  *(10**1)

#define DECI  *(10**-1)
#define CENTI *(10**-2)
#define MILLI *(10**-3)
#define MICRO *(10**-6)
#define NANO  *(10**-9)
#define PICO  *(10**-12)
#define FEMTO *(10**-15)
#define ATTO  *(10**-18)
#define ZEPTO *(10**-21)
#define YOCTO *(10**-24)

//Auditing
//Whether or not a potentially suspicious action gets denied by the code.
#define AUDIT_ACCESS_DENIED (0 << 1)
//Logged whenever you try to View Variables a thing
#define AUDIT_VIEW_VARIABLES (1 << 1)

//PATHOLOGY REMOVAL
//#define CREATE_PATHOGENS 1

//uncomment to enable sorting of reactions by priority (which is currently slow and bad)
//#define CHEM_REACTION_PRIORITIES

// This is here in lieu of a better place to put stuff that gets used all over the place but is specific to a context (in this case, machinery)
#define DATA_TERMINAL_IS_VALID_MASTER(terminal, master) (master && (get_turf(master) == terminal.loc))

#if (defined(SERVER_SIDE_PROFILING_PREGAME) || defined(SERVER_SIDE_PROFILING_FULL_ROUND) || defined(SERVER_SIDE_PROFILING_INGAME_ONLY))
#ifndef SERVER_SIDE_PROFILING
	#define SERVER_SIDE_PROFILING 1
#endif
#endif
