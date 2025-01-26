
/// Returns true if the given x is an item.
#define isitem(x) istype(x, /obj/item)

#define istool(x,y) (isitem(x) && (x:tool_flags & (y)))
#define iscuttingtool(x) (istool(x, TOOL_CUTTING))
#define ispulsingtool(x) (istool(x, TOOL_PULSING))
#define ispryingtool(x) (istool(x, TOOL_PRYING))
#define isscrewingtool(x) (istool(x, TOOL_SCREWING) || (istype(x, /obj/item/reagent_containers) && x:reagents:has_reagent("screwdriver")) ) //the joke is too good
#define issnippingtool(x) (istool(x, TOOL_SNIPPING))
#define iswrenchingtool(x) (istool(x, TOOL_WRENCHING))
#define ischoppingtool(x) (istool(x, TOOL_CHOPPING))
#define isweldingtool(x) (istool(x, TOOL_WELDING))
#define issawingtool(x) (istool(x, TOOL_SAWING))
#define isspooningtool(x) (istool(x, TOOL_SPOONING))
#define isassemblyapplier(x) (istool(x, TOOL_ASSEMBLY_APPLIER))

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
