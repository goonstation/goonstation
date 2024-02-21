/datum/component/itemblock/backpackblock
	signals = list(COMSIG_MOB_ATTACKED_PRE)
	mobtype = /mob/living
	proctype = PROC_REF(loseitem)

/datum/component/itemblock/backpackblock/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_TOOLTIP_BLOCKING_APPEND, PROC_REF(append_to_tooltip))

/datum/component/itemblock/backpackblock/proc/loseitem(var/mob/living/M, var/obj/item/weap)
	var/obj/item/storage/S = parent
	if(!istype(S)) //HOW???
		return
	if(S != M.equipped())
		return  //do nothing if not in open hand
	var/obj/item/I = pick(S.storage.get_contents())
	if (!I)
		return
	var/turf/target = locate(M.x + rand(-4,4), M.y+rand(-4,4), M.z)
	S.storage?.transfer_stored_item(I, M.loc)
	I.dropped(M)
	I.layer = initial(I.layer)
	src.updateblock() //has to happen before throw starts
	I.throw_at(target, 4, 1)

/datum/component/itemblock/backpackblock/on_block_begin(obj/item/I, var/obj/item/grab/block/B)
	..()
	updateblock()

/datum/component/itemblock/backpackblock/proc/append_to_tooltip(parent, list/tooltip)
	if(showTooltip)
		var/obj/item/storage/I = parent
		tooltip += itemblock_tooltip_entry("special.png", "Blocks more damage when filled (+[ceil(length(I.storage.get_contents())/3)])")
		tooltip += itemblock_tooltip_entry("minus.png", "Contents ejected when attacked")

/datum/component/itemblock/backpackblock/proc/updateblock()
	var/obj/item/storage/I = parent
	if(!istype(I)||!(I.c_flags && I.c_flags & HAS_GRAB_EQUIP))
		return
	var/blockplus = DEFAULT_BLOCK_PROTECTION_BONUS + ceil(length(I.storage.get_contents())/3) //a bit of bonus protection. 1 point bonus per 3 items in the bag
	for (var/obj/item/grab/block/B in I.contents)
		if(I.c_flags & BLOCK_CUT) //only increase the types we're actually blocking
			B.setProperty("I_block_cut", blockplus)
		if(I.c_flags & BLOCK_STAB)
			B.setProperty("I_block_stab", blockplus)
		if(I.c_flags & BLOCK_BURN)
			B.setProperty("I_block_burn", blockplus)
		if(I.c_flags & BLOCK_BLUNT)
			B.setProperty("I_block_blunt", blockplus)
