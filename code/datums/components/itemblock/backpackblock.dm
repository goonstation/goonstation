/datum/component/itemblock/backpackblock
	signals = list(COMSIG_MOB_ATTACKED_PRE)
	mobtype = /mob/living
	proctype = .proc/loseitem

/datum/component/itemblock/backpackblock/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_TOOLTIP_BLOCKING_APPEND, .proc/append_to_tooltip)

/datum/component/itemblock/backpackblock/proc/loseitem(var/mob/living/M, var/obj/item/weap)
	var/obj/item/storage/S = parent
	if(!istype(S)) //HOW???
		return
	if(S != M.equipped())
		return  //do nothing if not in open hand
	var/list/cont = list()
	SEND_SIGNAL(parent, COMSIG_STORAGE_GET_CONTENTS, cont)
	if (!cont.len)
		return
	var/obj/item/I = pick(cont)
	var/turf/target = locate(M.x + rand(-4,4), M.y+rand(-4,4), M.z)
	SEND_SIGNAL(parent, COMSIG_STORAGE_TRANSFER_ITEM, I, M.loc)
	I.layer = initial(I.layer)
	src.updateblock() //has to happen before throw starts
	I.throw_at(target, 4, 1)

/datum/component/itemblock/backpackblock/on_block_begin(obj/item/I, var/obj/item/grab/block/B)
	..()
	updateblock()

/datum/component/itemblock/backpackblock/proc/append_to_tooltip(parent, list/tooltip)
	if(showTooltip)
		var/list/cont = list()
		SEND_SIGNAL(parent, COMSIG_STORAGE_GET_CONTENTS, cont)
		tooltip += itemblock_tooltip_entry("special.png", "Blocks more damage when filled (+[ceil(cont.len/3)])")
		tooltip += itemblock_tooltip_entry("minus.png", "Contents ejected when attacked")

/datum/component/itemblock/backpackblock/proc/updateblock()
	var/obj/item/storage/I = parent
	if(!istype(I)||!(I.c_flags && I.c_flags & HAS_GRAB_EQUIP))
		return
	var/list/cont = list()
	SEND_SIGNAL(parent, COMSIG_STORAGE_GET_CONTENTS, cont)
	var/blockplus = DEFAULT_BLOCK_PROTECTION_BONUS + ceil(cont.len/3) //a bit of bonus protection. 1 point bonus per 3 items in the bag
	for (var/obj/item/grab/block/B in I.contents)
		if(I.c_flags & BLOCK_CUT) //only increase the types we're actually blocking
			B.setProperty("I_block_cut", blockplus)
		if(I.c_flags & BLOCK_STAB)
			B.setProperty("I_block_stab", blockplus)
		if(I.c_flags & BLOCK_BURN)
			B.setProperty("I_block_burn", blockplus)
		if(I.c_flags & BLOCK_BLUNT)
			B.setProperty("I_block_blunt", blockplus)
