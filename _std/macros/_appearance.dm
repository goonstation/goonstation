//head defines
#define HEAD_HUMAN 0
#define HEAD_MONKEY 1
#define HEAD_LIZARD 2
#define HEAD_COW 3
#define HEAD_WEREWOLF 4
#define HEAD_SKELETON 5	// skullception *shrug*
#define HEAD_SEAMONKEY 6
#define HEAD_CAT 7
#define HEAD_ROACH 8
#define HEAD_FROG 9
#define HEAD_SHELTER 10

//appearance bitflags cus im tired of tracking down a million different vars that rarely do what they should
#define IS_MUTANT								1	// Log shit if this is set but the mutantrace isnt. why does this even happen.

#define HAS_HUMAN_SKINTONE			2	// Skin tone determined through the usual route
#define HAS_SPECIAL_SKINTONE		4	// Skin tone defined some other way
#define HAS_NO_SKINTONE					8	// Please dont tint my mob it looks weird

// used in appearance holder
#define HAS_HUMAN_HAIR					16 // Hair sprites are roughly what you set in the prefs
#define HAS_SPECIAL_HAIR				32 // Hair sprites are there, but they're supposed to be different. Like a lizard head thing or cow horns
#define HAS_DETAIL_HAIR					64 // Hair sprites are there, but they're supposed to be different. Like a lizard head thing or cow horns
#define HAS_NO_HAIR							2048 // Please don't render hair on my wolves it looks too cute

#define HAS_HUMAN_EYES					4096 // We have normal human eyes of human color where human eyes tend to be
#define HAS_SPECIAL_EYES				8192 //	We have different eyes of different color probably somewhere else
#define HAS_NO_EYES							16384 // We have no eyes and yet must see (cus they're baked into the sprite or something)

#define HAS_HUMAN_HEAD					32768	// Head is roughly human-shaped with no additional features
#define HAS_SPECIAL_HEAD				131072	// Head is shaped differently, but otherwise just a head
#define HAS_NO_HEAD							262144	// Don't show their head, its already baked into their icon override

#define BUILT_FROM_PIECES				524288	// Use humanlike body rendering process, otherwise use a static icon or something
#define HAS_EXTRA_DETAILS				1048576	// Has a non-head something in their detail slot they want to show off, like lizard splotches
#define HAS_A_TAIL							2097152	// Has a tail, so give em an oversuit
#define WEARS_UNDERPANTS				4194304	// Draw underwear on them. also works on mutants, for the most part

//non-hairstyle body accessory bitflags
//corresponds to the color settings in user prefs
#define DETAIL_1	1	//
#define DETAIL_2	2	//
#define DETAIL_3	4	//

#define HAS_HAIR_COLORED_HAIR			8		// Hair (if any) is/are the color/s you/we (hopefully) set/assigned
#define HAS_SPECIAL_COLORED_HAIR	16	// Hair color is determined some other way
#define HAS_HAIR_COLORED_DETAILS	32	// Hair color is used to determine the color of certain non-hair things. Like horns or scales
#define HAS_UNUSED_HAIR_COLOR			64	// Hair color isnt used for anything :/ unused

#define OVERSUIT_USES_PREF_COLOR_1		128		//
#define OVERSUIT_USES_PREF_COLOR_2		256		//
#define OVERSUIT_USES_PREF_COLOR_3		512		//

#define SKINTONE_USES_PREF_COLOR_1		1024	//
#define SKINTONE_USES_PREF_COLOR_2		2048	//
#define SKINTONE_USES_PREF_COLOR_3		4096	//

#define FIX_COLORS										8192	// Clamp customization RBG vals between 50 and 190, lizard-style
#define	HEAD_HAS_OWN_COLORS						16384	// our head has its own colors that would look weird if tinted
