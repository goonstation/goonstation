
/// Returns true if the given x is an item.
#define isitem(x) istype(x, /obj/item)

#define istool(x,y) (isitem(x) && (x:tool_flags & (y)))
#define isclampingtool(x) (istool(x, TOOL_CLAMPING))
#define iscuttingtool(x) (istool(x, TOOL_CUTTING))
#define ispryingtool(x) (istool(x, TOOL_PRYING))
#define ispulsingtool(x) (istool(x, TOOL_PULSING))
#define issawingtool(x) (istool(x, TOOL_SAWING))
#define isdeconstructingtool(x) (istool(x, TOOL_DECONSTRUCTING))
#define isscrewingtool(x) (istool(x, TOOL_SCREWING) || (istype(x, /obj/item/reagent_containers) && x:reagents:has_reagent("screwdriver")) ) //the joke is too good
#define issnippingtool(x) (istool(x, TOOL_SNIPPING))
#define isspooningtool(x) (istool(x, TOOL_SPOONING))
#define isweldingtool(x) (istool(x, TOOL_WELDING))
#define iswrenchingtool(x) (istool(x, TOOL_WRENCHING))
#define ischoppingtool(x) (istool(x, TOOL_CHOPPING))
#define issolderingtool(x) (istool(x, TOOL_SOLDERING))
#define iswiringtool(x) (istool(x, TOOL_WIRING))
#define isassemblyapplier(x) (istool(x, TOOL_ASSEMBLY_APPLIER))
#define isdiggingtool(x) (istool(x, TOOL_DIGGING))

/// Returns true if the given x is a grab (obj/item/grab)
#define isgrab(x) (istype(x, /obj/item/grab/))

/// Returns true if x is equipped or inside & usable in what's equipped (currently only applicable to magtractors)
#define equipped_or_holding(x,source) (source.equipped() == x || (source.equipped()?.useInnerItem && (x in source.equipped())))

/// Returns TRUE if item is worn by a human other than `user`, FALSE otherwise
#define IS_WORN_BY_SOMEONE_OTHER_THAN(item, user) (istype(item.loc, /mob/living/carbon/human) && user != item.loc)

/// Returns TRUE if the item is something that NPCs should not be able to pick up
#define IS_NPC_ILLEGAL_ITEM(x) ( \
		istype(x, /obj/item/body_bag) && x.w_class >= W_CLASS_BULKY \
	)

#define cangunpoint(x) (istype(x, /obj/item/gun) || istype(x, /obj/item/bang_gun))

/// Randomizes an item's pixel offset within the given range
#define RANDOMIZE_PIXEL_OFFSET(item, range) \
    item.pixel_x = rand(-(range), (range)); \
    item.pixel_y = rand(-(range), (range))
