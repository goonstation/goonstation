// human equipment slots
#define SLOT_BACK 1
#define SLOT_WEAR_MASK 2
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

/// protects you from the dangers of space
#define SPACEWEAR					1
/// mask allows internals to be used
#define MASKINTERNALS				2
/// covers the person's eyes
#define COVERSEYES					4
// covers the person's mouth
#define COVERSMOUTH					8
// can be worn by any body size
#define ONESIZEFITSALL				16
/// for galoshes/magic sandals/etc that prevent slipping on things
#define NOSLIP						32
/// ain't got no sleeeeeves
#define SLEEVELESS					64
/// block smoke inhalations (gas mask)
#define BLOCKSMOKE					128
/// blocks choking, also a very silly flag name
#define BLOCKCHOKE					256
/// is this clothing a jetpack
#define IS_JETPACK					512
/// doesn't need to be worn to appear in the 'get_equipped_items' list and apply itemproperties (protections resistances etc)! for stuff like shields
#define EQUIPPED_WHILE_HELD			1024
/// return early out of equipped/unequipped, unless in SLOT_L_HAND or SLOT_R_HAND (i.e.: if EQUIPPED_WHILE_HELD)
#define NOT_EQUIPPED_WHEN_WORN		2048
/// if we currently have a grab (or by extention, a block) attached to us
#define HAS_GRAB_EQUIP				4096
/// whether or not we should show extra tooltip info about blocking with this item
#define BLOCK_TOOLTIP				8192
/// block an extra point of cut damage when used to block
#define BLOCK_CUT					16384
/// block an extra point of stab damage when used to block
#define BLOCK_STAB					32768
/// block an extra point of burn damage when used to block
#define BLOCK_BURN					65536
/// block an extra point of blunt damage when used to block
#define BLOCK_BLUNT					131072


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
