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
#define HEAD_CHICKEN 13

//tail defines
#define TAIL_NONE 0
#define TAIL_MONKEY 1
#define TAIL_LIZARD 2
#define TAIL_COW 3
#define TAIL_WEREWOLF 4
#define TAIL_SKELETON 5
#define TAIL_SEAMONKEY 6
#define TAIL_CAT 7
#define TAIL_ROACH 8

//appearance bitflags cus im tired of tracking down a million different vars that rarely do what they should
/// so far just makes fat mutants render as male
#define IS_MUTANT								(1<<0)

/// Skin tone defined through the usual route
#define HAS_HUMAN_SKINTONE			(1<<1)
/// Skin tone defined some other way
#define HAS_SPECIAL_SKINTONE		(1<<2)
/// Please dont tint my mob it looks weird
#define HAS_NO_SKINTONE					(1<<3)
/// Some parts are skintoned, some are not. Define these with the color flags!
#define HAS_PARTIAL_SKINTONE		(1<<4)

/// used in appearance holder
/// Hair sprites are roughly what you set in the prefs
#define HAS_HUMAN_HAIR					(1<<5)
/// Hair sprites are there, but they're supposed to be different. Like a lizard head thing or cow horns
#define HAS_SPECIAL_HAIR				(1<<6)
/// Hair sprites are there, but they're supposed to be different. Like a lizard head thing or cow horns
#define HAS_BODYDETAIL_HAIR			(1<<7)
/// Please don't render hair on my wolves it looks too cute
#define HAS_NO_HAIR							(1<<8)


/// We have normal human eyes of human color where human eyes tend to be
#define HAS_HUMAN_EYES					(1<<9)
/// We have no eyes and yet must see (cus they're baked into the sprite or something)
#define HAS_NO_EYES							(1<<11)


/// Don't show their head, its already baked into their icon override
#define HAS_NO_HEAD							(1<<12)


/// Use humanlike body rendering process, otherwise use a static icon or something
#define BUILT_FROM_PIECES				(1<<13)
/// Has a non-head something in their detail slot they want to show off, like lizard splotches. non-tail oversuits count!
#define HAS_EXTRA_DETAILS				(1<<14)
/// Draw underwear on them. can be overridden with human var underpants_override. dont actually do this though
#define WEARS_UNDERPANTS				(1<<15)
/// Mob's body is drawn using a single, flat image and not several flat images slapped together
#define USES_STATIC_ICON				(1<<16)



///non-hairstyle body accessory bitflags

///corresponds to the color settings in user prefs
/// If HAS_EXTRA_DETAILS is set, render what's in the appearanceholder's mob_detail_1
#define BODYDETAIL_1	(1<<1)
/// If HAS_EXTRA_DETAILS is set, render what's in the appearanceholder's mob_detail_2
#define BODYDETAIL_2	(1<<2)
/// If HAS_EXTRA_DETAILS is set, render what's in the appearanceholder's mob_detail_3
#define BODYDETAIL_3	(1<<3)

/// Hair color is used to determine the color of certain non-hair things. Like horns or scales
#define HAS_HAIR_COLORED_DETAILS	(1<<5)


/// Has a non-tail detail that goes over the suit, like a cute little enormous cow muzzle
#define BODYDETAIL_OVERSUIT_1		(1<<6)
/// The oversuit is colorful, otherwise don't color it. Defaults to first customization color
#define BODYDETAIL_OVERSUIT_IS_COLORFUL		(1<<7)


/// Skintone is determined by the character's first custom color
#define SKINTONE_USES_PREF_COLOR_1		(1<<8)
/// Skintone is determined by the character's second custom color
#define SKINTONE_USES_PREF_COLOR_2		(1<<9)
/// Skintone is determined by the character's third custom color
#define SKINTONE_USES_PREF_COLOR_3		(1<<10)


/// Clamp customization RBG vals between 50 and 190, lizard-style
#define FIX_COLORS										(1<<11)
/// Our head has its own colors that would look weird if tinted
#define	HEAD_HAS_OWN_COLORS						(1<<12)

/// Apply the skintone to the torso, so chickens can have both gross human skin and gross chicken feathers
#define	TORSO_HAS_SKINTONE						(1<<13)
