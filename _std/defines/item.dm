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

//Item function flags

/// apply to an item's flags to use the item's intent_switch_trigger() proc. This will be called when intent is switched while this item is in hand.
#define USE_INTENT_SWITCH_TRIGGER 1
/// allows special attacks to be performed on help and grab intent with this item
#define USE_SPECIALS_ON_ALL_INTENTS 2

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
