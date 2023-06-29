//head defines
#define HEAD_HUMAN 0
#define HEAD_MONKEY 1
#define HEAD_LIZARD 2
#define HEAD_LIZARD_FEMALE 2000
#define HEAD_COW 3
#define HEAD_WEREWOLF 4
#define HEAD_SKELETON 5	// skullception *shrug*
#define HEAD_SEAMONKEY 6
#define HEAD_CAT 7
#define HEAD_ROACH 8
#define HEAD_FROG 9
#define HEAD_SHELTER 10
#define HEAD_VAMPTHRALL 11
#define HEAD_RELI 12
#define HEAD_CHICKEN 13
#define HEAD_HUNTER 14
#define HEAD_ITHILLID 15
#define HEAD_VIRTUAL 16
#define HEAD_FLASHY 17
#define HEAD_PUG 18

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
#define TAIL_PUG 9

/// appearanceholder color vars. Tells mutant races to stick this color into the specified special hair / limb overlay color slot
#define CUST_1 1
#define CUST_2 2
#define CUST_3 3
#define SKIN_TONE 4

//appearance bitflags cus im tired of tracking down a million different vars that rarely do what they should
/// We only have male torso/groin sprites, so only use those.
/// Without this flag, your mutant race sprite *must* include a chest_m and groin_m state, or your women will be a bunch of floating limbs
#define NOT_DIMORPHIC								(1<<0)

/// Skin tone defined through the usual route
#define HAS_HUMAN_SKINTONE			(1<<2)
/// Please dont tint my mob it looks weird
#define HAS_NO_SKINTONE					(1<<3)
/// Some parts are skintoned, some are not. Define these with the color flags!
#define HAS_PARTIAL_SKINTONE		(1<<4)

/// used in appearance holder
/// Hair sprites are roughly what you set in the prefs
#define HAS_HUMAN_HAIR					(1<<5)
/// Hair sprites are there, but they're supposed to be different. Like a lizard head thing or cow horns
#define HAS_SPECIAL_HAIR				(1<<6)

/// Apply the skintone to the torso, so chickens can have both gross human skin and gross chicken feathers
#define	TORSO_HAS_SKINTONE			(1<<7)

/// We have normal human eyes of human color where human eyes tend to be
#define HAS_HUMAN_EYES					(1<<8)
/// We have no eyes and yet must see (cus they're baked into the sprite or something)
#define HAS_NO_EYES							(1<<9)

/// Don't show their head, its already baked into their icon override
#define HAS_NO_HEAD							(1<<10)

/// Use humanlike body rendering process, otherwise use a static icon or something
#define BUILT_FROM_PIECES				(1<<11)
/// Has a non-head something in their detail slot they want to show off, like lizard splotches. non-tail oversuits count!
#define HAS_EXTRA_DETAILS				(1<<12)
/// Draw underwear on them. can be overridden with human var underpants_override. dont actually do this though
#define WEARS_UNDERPANTS				(1<<13)
/// Mob's body is drawn using a single, flat image and not several flat images slapped together
#define USES_STATIC_ICON				(1<<14)
/// Mob has some things that're supposed to show up over their outersuit, like a cute little cow muzzle
#define HAS_OVERSUIT_DETAILS		(1<<15)

/// Used primarilly by mutantraces when overwriting the skintone
/// Skintone is determined by the character's first custom color
#define SKINTONE_USES_PREF_COLOR_1		(1<<16)
/// Skintone is determined by the character's second custom color
#define SKINTONE_USES_PREF_COLOR_2		(1<<17)
/// Skintone is determined by the character's third custom color
#define SKINTONE_USES_PREF_COLOR_3		(1<<18)

/// Clamp customization RBG vals between 50 and 190, lizard-style
#define FIX_COLORS										(1<<19)
/// Our head has its own colors that would look weird if tinted
#define	HEAD_HAS_OWN_COLORS						(1<<20)

// The head has a custom nose
#define HAS_LONG_NOSE						(1<<21)

/// Default normal standard human appearance flags
#define HUMAN_APPEARANCE_FLAGS (HAS_HUMAN_SKINTONE | HAS_HUMAN_HAIR | HAS_HUMAN_EYES | BUILT_FROM_PIECES | WEARS_UNDERPANTS )
