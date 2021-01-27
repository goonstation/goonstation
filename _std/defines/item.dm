//FLAGS BITMASK

/// can be put in back slot
#define ONBACK							 (1<<0)
/// can pass by a table or rack
#define TABLEPASS						 (1<<1)
/// thing doesn't drift in space
#define NODRIFT							 (1<<2)
/// put this on either a thing you don't want to be hit rapidly, or a thing you don't want people to hit other stuff rapidly with
#define USEDELAY						 (1<<3)
/// 1 second extra delay on use
#define EXTRADELAY					 (1<<4)
/// weapon not affected by shield. MBC also put this flag on cloak/shield device to minimize istype checking, so consider this more SHIELD_ACT (rename? idk)
#define NOSHIELD						 (1<<5)
/// conducts electricity (metal etc.)
#define CONDUCT							 (1<<6)
/// can be put in belt slot
#define ONBELT							 (1<<7)
/// takes a fingerprint
#define FPRINT							 (1<<8)
/// item has priority to check when entering or leaving
#define ON_BORDER						 (1<<9)
/// can pass through a closed door
#define DOORPASS						 (1<<10)
/// automagically talk into this object when a human is holding it (Phone handset!)
#define TALK_INTO_HAND 			 (1<<11)
/// is an open container for chemistry purposes
#define OPENCONTAINER				 (1<<12)
/// is an atom spawned in an adventure area
#define ISADVENTURE 				 (1<<13)
/// No beaker etc. splashing. For Chem machines etc.
#define NOSPLASH 						 (1<<13)
/// No attack when hitting stuff with this item.
#define SUPPRESSATTACK 			 (1<<14)
/// gets an overlay when submerged in fluid
#define FLUID_SUBMERGE 			 (1<<15)
/// gets a perspective overlay from adjacent fluids
#define IS_PERSPECTIVE_FLUID (1<<16)
/// specifically note this object as solid
#define ALWAYS_SOLID_FLUID	 (1<<17)
/// Calls equipment_click from hand_range_attack on items worn with this flag set.
#define HAS_EQUIP_CLICK			 (1<<18)
/// Has the possibility for a TGUI interface
#define TGUI_INTERACTIVE		 (1<<19)
/// Has a click delay for attack_self()
#define ATTACK_SELF_DELAY		 (1<<20)


//Item function flags

/// apply to an item's flags to use the item's intent_switch_trigger() proc. This will be called when intent is switched while this item is in hand.
#define USE_INTENT_SWITCH_TRIGGER 1
/// allows special attacks to be performed on help and grab intent with this item
#define USE_SPECIALS_ON_ALL_INTENTS 2
/// prevents items from creating smoke while burning
#define SMOKELESS 4

//tool flags
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

//tooltip flags for rebuilding

/// rebuild tooltip every single time without exception
#define REBUILD_ALWAYS				1
/// force rebuild if dist does not match cache
#define REBUILD_DIST				2
/// force rebuild if viewer has changed at all
#define REBUILD_USER				4
/// force rebuild if spectrospec status of viewer has changed
#define REBUILD_SPECTRO				8

// blood system and item damage things
#define DAMAGE_BLUNT 1
#define DAMAGE_CUT 2
#define DAMAGE_STAB 4
#define DAMAGE_BURN 8
/// crushing damage is technically blunt damage, but it causes bleeding
#define DAMAGE_CRUSH 16
#define DEFAULT_BLOOD_COLOR "#990000"	// speak for yourself, as a shapeshifting illuminati lizard, my blood is somewhere between lime and leaf green
#define DAMAGE_TYPE_TO_STRING(x) (x == DAMAGE_BLUNT ? "blunt" : x == DAMAGE_CUT ? "cut" : x == DAMAGE_STAB ? "stab" : x == DAMAGE_BURN ? "burn" : x == DAMAGE_CRUSH ? "crush" : "")

//item rarity stuff
#define ITEM_RARITY_POOR 1
#define ITEM_RARITY_COMMON 2
#define ITEM_RARITY_UNCOMMON 3
#define ITEM_RARITY_RARE 4
#define ITEM_RARITY_EPIC 5
#define ITEM_RARITY_LEGENDARY 6
#define ITEM_RARITY_MYTHIC 7

// item comp defs
#define FORCE_EDIBILITY 1
//item attack bitflags
/// The pre-attack signal doesnt want the attack to continue, so don't
#define ATTACK_PRE_DONT_ATTACK 1

// Guns'n'ammo defines
// Ammo item types
/// A naked pile of ammunition, like a box of shells, or belt of bullets
#define AMMO_PILE (1<<0)
/// A clip-like device that holds bullets, for quick loading into an internal magazine
#define AMMO_CLIP (1<<1)
/// A mechanism that feeds bullets into a gun, designed to be swapped out to reload
#define AMMO_MAGAZINE (1<<2)
/// A box designed to hold a belt of bullets, typically for machine guns
/// Basically just a mag that's really easy to load and unload bullets into/from
#define AMMO_BELTMAG (1<<3)
/// A battery, uses a number to determine remaining ammo
#define AMMO_ENERGY (1<<4)
// Ammo numbering defines
/// The max number of unique ammotypes that can fit into a magazine/pile/etc
#define MAX_UNIQUE_AMMO_TYPES 10
/// The max total number of bullets that can fit into any magazine/pile/etc though normal means
#define MAX_MAGAZINE_CAPACITY 2000
// Ammo caliber defines
#define CALIBER_RIFLE_ASSAULT 0.223
#define CALIBER_RIFLE_HEAVY 0.308
#define CALIBER_RIFLE_CASELESS 0.185
#define CALIBER_PISTOL 0.355
#define CALIBER_PISTOL_SMALL 0.22
#define CALIBER_PISTOL_MAGNUM 0.50
#define CALIBER_PISTOL_GYROJET 0.512
#define CALIBER_MINIGUN 0.10
#define CALIBER_CAT 9.5
#define CALIBER_FROG 8.0
#define CALIBER_CRAB 12
#define CALIBER_TRASHBAG 9.5
#define CALIBER_SECBOT 11.5
#define CALIBER_REVOLVER_MAGNUM 0.357
#define CALIBER_REVOLVER_OLDTIMEY 0.45
#define CALIBER_REVOLVER 0.38
#define CALIBER_DERRINGER 0.41
#define CALIBER_WHOLE_DERRINGER 3.00
#define CALIBER_SHOTGUN 0.72
#define CALIBER_CANNON 0.787
#define CALIBER_CANNON_MASSIVE 15.7
#define CALIBER_GRENADE 1.57
#define CALIBER_ROCKET 1.12
#define CALIBER_RPG 1.58
#define CALIBER_ROD 1.00
#define CALIBER_PISTOL_FLINTLOCK 0.56
#define CALIBER_BATTERY 1.30
#define CALIBER_IMPLANT 1.11
#define CALIBER_ANY -1
#define REALLY_BIG_PROJECTILE -1
// Gun Defs
/// Return when currently shooting
#define GUN_IS_SHOOTING 2
/// Gun consumes charge from loaded magazine
#define GUN_NEEDS_ENERGY (1<<0)
/// Gun needs projectile entries in its loaded magazine's mag_contents
#define GUN_NEEDS_BULLETS (1<<1)
// Gun Sound assoc Defs
/// Load single
#define LOAD_SINGLE "load_single"
/// Load multiple
#define LOAD_MULTIPLE "load_multiple"
/// Load magazine
#define LOAD_MAGAZINE "load_magazine"
/// Unload single
#define UNLOAD_SINGLE "unload_single"
/// Unload multiple
#define UNLOAD_MULTIPLE "unload_multiple"
/// Unload magazine
#define UNLOAD_MAGAZINE "unload_magazine"
/// Shoot gun
#define SHOOT_SOUND "shoot_sound"
/// Shoot gun, but silenced
#define SHOOT_SILENCED_SOUND "shoot_silent"
/// Shoot gun, but its empty
#define SHOOT_EMPTY "shoot_empty"
