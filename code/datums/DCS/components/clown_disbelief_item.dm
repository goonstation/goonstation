var/global/list/image/clown_disbelief_images
var/global/list/image/clown_disbelief_clown_mobs /// An associative list of clown disbelief item subscription counts, indexed by the mob they've been applied to.

/datum/component/clown_disbelief_item
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/image/disbelief_image

TYPEINFO(/datum/component/clown_disbelief_item)
	initialization_args = list()

/datum/component/clown_disbelief_item/Initialize()
	..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(on_unequip))

	src.disbelief_image = image('icons/effects/effects.dmi', null, "nothing")
	src.disbelief_image.name = "\u200b" // zero width space
	src.disbelief_image.override = 1
	if(isnull(global.clown_disbelief_images))
		global.clown_disbelief_images = list()
	if(isnull(global.clown_disbelief_clown_mobs))
		global.clown_disbelief_clown_mobs = list()
	global.clown_disbelief_images += src.disbelief_image
	for(var/mob/M as anything in by_cat[TR_CAT_CLOWN_DISBELIEF_MOBS])
		M.client?.images += src.disbelief_image

/datum/component/clown_disbelief_item/proc/on_equip(datum/source, mob/equipper, slot)
	src.disbelief_image.loc = equipper
	clown_disbelief_clown_mobs[equipper] += 1

/datum/component/clown_disbelief_item/proc/on_unequip(datum/source, mob/user)
	src.disbelief_image.loc = null
	clown_disbelief_clown_mobs[user] -=1
	if (clown_disbelief_clown_mobs[user] < 1) //No more clown time
		clown_disbelief_clown_mobs -= user

/datum/component/clown_disbelief_item/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED))
	. = ..()

/datum/component/clown_disbelief_item/disposing()
	global.clown_disbelief_images -= src.disbelief_image
	for(var/mob/M as anything in by_cat[TR_CAT_CLOWN_DISBELIEF_MOBS])
		M.client?.images -= src.disbelief_image
	qdel(src.disbelief_image)
	. = ..()
