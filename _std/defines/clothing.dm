// human equipment slots
// if the variable names of slots on human are ever changed make sure these match the new names
#define SLOT_BACK "back"
#define SLOT_WEAR_MASK "wear_mask"
#define SLOT_L_HAND "l_hand"
#define SLOT_R_HAND "r_hand"
#define SLOT_BELT "belt"
#define SLOT_WEAR_ID "wear_id"
#define SLOT_EARS "ears"
#define SLOT_GLASSES "glasses"
#define SLOT_GLOVES "gloves"
#define SLOT_HEAD "head"
#define SLOT_SHOES "shoes"
#define SLOT_WEAR_SUIT "wear_suit"
#define SLOT_W_UNIFORM "w_uniform"
#define SLOT_L_STORE "l_store"
#define SLOT_R_STORE "r_store"
//#define SLOT_W_RADIO 17
#define SLOT_IN_BACKPACK 18
#define SLOT_IN_BELT 19

var/list/all_slots = list(SLOT_BACK, SLOT_WEAR_MASK, SLOT_L_HAND, SLOT_R_HAND, SLOT_BELT, SLOT_WEAR_ID, SLOT_EARS, SLOT_GLASSES, SLOT_GLOVES, SLOT_HEAD, SLOT_SHOES, SLOT_WEAR_SUIT, SLOT_L_STORE, SLOT_R_STORE)

// bitflags for clothing parts
#define HEAD			1
#define TORSO			2
#define LEGS			4
#define ARMS			8

// other clothing-specific bitflags, applied via the c_flags var

/// protects you from the dangers of space
#define SPACEWEAR					(1<<0)
/// mask allows internals to be used
#define MASKINTERNALS				(1<<1)
/// covers the person's eyes
#define COVERSEYES					(1<<2)
// covers the person's mouth
#define COVERSMOUTH					(1<<3)
/// for galoshes/magic sandals/etc that prevent slipping on things
#define NOSLIP						(1<<4)
/// ain't got no sleeeeeves
#define SLEEVELESS					(1<<5)
/// block smoke inhalations (gas mask)
#define BLOCKSMOKE					(1<<6)
/// blocks choking, also a very silly flag name
#define BLOCKCHOKE					(1<<7)
/// is this clothing a jetpack
#define IS_JETPACK					(1<<8)
/// doesn't need to be worn to appear in the 'get_equipped_items' list and apply itemproperties (protections resistances etc)! for stuff like shields
#define EQUIPPED_WHILE_HELD			(1<<9)
/// unused flag
//#define C_FLAG_UNUSED		(1<<10)
/// if we currently have a grab (or by extention, a block) attached to us
#define HAS_GRAB_EQUIP				(1<<11)
/// whether or not we should show extra tooltip info about blocking with this item
#define BLOCK_TOOLTIP				(1<<12)
/// block an extra point of cut damage when used to block
#define BLOCK_CUT					(1<<13)
/// block an extra point of stab damage when used to block
#define BLOCK_STAB					(1<<14)
/// block an extra point of burn damage when used to block
#define BLOCK_BURN					(1<<15)
/// block an extra point of blunt damage when used to block
#define BLOCK_BLUNT					(1<<16)
/// can be worn on the back
#define ONBACK						(1<<17)
/// can be work on the belt
#define ONBELT						(1<<18)
/// block miasma inhalations (sterile mask)
#define BLOCKMIASMA					(1<<19)
// covers the person's hair
#define COVERSHAIR					(1<<20)

//Suit blood flags
#define SUITBLOOD_ARMOR 1
#define SUITBLOOD_COAT 2

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

//priority for which things make step sounds
#define STEP_PRIORITY_MAX 2
#define STEP_PRIORITY_MED 1
#define STEP_PRIORITY_LOW 0.5
#define STEP_PRIORITY_NONE 0

//shoe laces!
#define LACES_NORMAL 0
#define LACES_TIED 1
#define LACES_CUT 2
#define LACES_NONE -1

//glove side for iconstate stuff
#define GLOVE_HAS_LEFT 1
#define GLOVE_HAS_RIGHT 2
