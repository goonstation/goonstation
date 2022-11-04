//some different generalized block weapon shapes that i can re use instead of copy paste
//#define BLOCK_SETUP		src.c_flags |= BLOCK_TOOLTIP; RegisterSignal(src, COMSIG_ITEM_BLOCK_BEGIN, .proc/block_prop_setup, TRUE) //makes the magic work
//#define BLOCK_ALL		BLOCK_SETUP; src.c_flags |= (BLOCK_BLUNT | BLOCK_CUT | BLOCK_STAB | BLOCK_BURN)
//#define BLOCK_LARGE		BLOCK_SETUP; src.c_flags |= (BLOCK_BLUNT | BLOCK_CUT | BLOCK_STAB)
//#define BLOCK_SWORD		BLOCK_LARGE
//#define BLOCK_ROD 		BLOCK_SETUP; src.c_flags |= (BLOCK_BLUNT | BLOCK_CUT)
//#define BLOCK_TANK		BLOCK_SETUP; src.c_flags |= (BLOCK_BLUNT | BLOCK_CUT | BLOCK_BURN)
//#define BLOCK_SOFT		BLOCK_SETUP; src.c_flags |= (BLOCK_STAB | BLOCK_BURN)
//#define BLOCK_KNIFE		BLOCK_SETUP; src.c_flags |= (BLOCK_CUT | BLOCK_STAB)
//#define BLOCK_BOOK		BLOCK_SETUP; src.c_flags |= (BLOCK_CUT | BLOCK_STAB)
//#define BLOCK_ROPE		BLOCK_BOOK

#define DEFAULT_BLOCK_PROTECTION_BONUS 4 //blocking to match damage type correctly gives you a +3 bonus on protection (unless this item grants Even More protection, that overrides this)
#define UNARMED_BLOCK_PROTECTION_BONUS 2 //Unarmed blocks don't need to match damage type, but generally block less damage


#define BLOCK_SETUP(blocktypes)	RegisterSignal(src, COMSIG_ITEM_BLOCK_BEGIN, .proc/block_prop_setup, TRUE); src.c_flags |= BLOCK_TOOLTIP; ADD_BLOCKS(blocktypes)
#define BLOCK_ALL		(BLOCK_BLUNT | BLOCK_CUT | BLOCK_STAB | BLOCK_BURN)
#define BLOCK_LARGE		(BLOCK_BLUNT | BLOCK_CUT | BLOCK_STAB)
#define BLOCK_SWORD		BLOCK_LARGE
#define BLOCK_ROD 		(BLOCK_BLUNT | BLOCK_CUT)
#define BLOCK_TANK		(BLOCK_BLUNT | BLOCK_CUT | BLOCK_BURN)
#define BLOCK_SOFT		(BLOCK_STAB | BLOCK_BURN)
#define BLOCK_KNIFE		(BLOCK_CUT | BLOCK_STAB)
#define BLOCK_BOOK		(BLOCK_CUT | BLOCK_STAB)
#define BLOCK_ROPE		BLOCK_BOOK
#define BLOCK_NONE		0

#define ADD_BLOCKS(blocktypes) src.c_flags |= (blocktypes)
#define REMOVE_BLOCKS(blocktypes) src.c_flags &= ~(blocktypes)
#define SET_BLOCKS(blocktypes) REMOVE_BLOCKS(BLOCK_ALL); ADD_BLOCKS(blocktypes)
