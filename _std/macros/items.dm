
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

/// Returns true if the given x is a grab (obj/item/grab)
#define isgrab(x) (istype(x, /obj/item/grab/))

/// Returns true if x is equipped or inside & usable in what's equipped (currently only applicable to magtractors)
#define equipped_or_holding(x,source) (source.equipped() == x || (source.equipped()?.useInnerItem && (x in source.equipped())))
