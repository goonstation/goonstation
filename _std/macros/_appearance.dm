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
#define HEAD_VAMPZOMBIE 11
#define HEAD_RELI 12

//tail defines
#define TAIL_NONE 0
#define TAIL_MONKEY 1
#define TAIL_LIZARD 2
#define TAIL_COW 3
#define TAIL_WEREWOLF 4
#define TAIL_SKELETON 5	// skullception *shrug*
#define TAIL_SEAMONKEY 6
#define TAIL_CAT 7
#define TAIL_ROACH 8

//appearance bitflags cus im tired of tracking down a million different vars that rarely do what they should
#define IS_MUTANT								1	// so far just makes fat mutants render as male

#define HAS_HUMAN_SKINTONE			2	// Skin tone determined through the usual route
#define HAS_SPECIAL_SKINTONE		4	// Skin tone defined some other way
#define HAS_NO_SKINTONE					8	// Please dont tint my mob it looks weird

// used in appearance holder
#define HAS_HUMAN_HAIR					16 // Hair sprites are roughly what you set in the prefs
#define HAS_SPECIAL_HAIR				32 // Hair sprites are there, but they're supposed to be different. Like a lizard head thing or cow horns
#define HAS_DETAIL_HAIR					64 // Hair sprites are there, but they're supposed to be different. Like a lizard head thing or cow horns
#define HAS_NO_HAIR							128 // Please don't render hair on my wolves it looks too cute

#define HAS_HUMAN_EYES					256 // We have normal human eyes of human color where human eyes tend to be
#define HAS_SPECIAL_EYES				512 //	We have different eyes of different color probably somewhere else
#define HAS_NO_EYES							1024 // We have no eyes and yet must see (cus they're baked into the sprite or something)

#define HAS_HUMAN_HEAD					2048	// Head is roughly human-shaped with no additional features
#define HAS_SPECIAL_HEAD				4096	// Head is shaped differently, but otherwise just a head
#define HAS_NO_HEAD							8192	// Don't show their head, its already baked into their icon override

#define BUILT_FROM_PIECES				16384	// Use humanlike body rendering process, otherwise use a static icon or something
#define HAS_EXTRA_DETAILS				32768	// Has a non-head something in their detail slot they want to show off, like lizard splotches. non-tail oversuits count!
#define HAS_A_TAIL							65536	// Has a tail. used for checking if tail loss should cause clumsines
#define WEARS_UNDERPANTS				131072	// Draw underwear on them. can be overridden with human var underpants_override. dont actually do this though
#define USES_STATIC_ICON				262144	// Mob's body is drawn using a single, flat image and not several flat images slapped together

//non-hairstyle body accessory bitflags
//corresponds to the color settings in user prefs
#define DETAIL_1	1	//
#define DETAIL_2	2	//
#define DETAIL_3	4	//

#define HAS_HAIR_COLORED_HAIR			8		// Hair (if any) is/are the color/s you/we (hopefully) set/assigned
#define HAS_SPECIAL_COLORED_HAIR	16	// Hair color is determined some other way
#define HAS_HAIR_COLORED_DETAILS	32	// Hair color is used to determine the color of certain non-hair things. Like horns or scales
#define HAS_UNUSED_HAIR_COLOR			64	// Hair color isnt used for anything :/ unused

#define DETAIL_OVERSUIT_1		128		// Has a detail that goes over the suit, like a cute little enormous cow muzzle
#define DETAIL_OVERSUIT_2		256		// currently unused
#define DETAIL_OVERSUIT_IS_COLORFUL		512		// The oversuit is colorful, otherwise don't color it. Defaults to first customization color

#define SKINTONE_USES_PREF_COLOR_1		1024	//
#define SKINTONE_USES_PREF_COLOR_2		2048	// unused... for now
#define SKINTONE_USES_PREF_COLOR_3		4096	// unused... for now

#define FIX_COLORS										8192	// Clamp customization RBG vals between 50 and 190, lizard-style
#define	HEAD_HAS_OWN_COLORS						16384	// our head has its own colors that would look weird if tinted
