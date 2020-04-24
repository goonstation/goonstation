/datum/component/itemblock/backpackblock
	signals = list(COMSIG_MOB_ATTACKED_PRE) 
	mobtype = /mob/living
	proctype = .proc/loseitem

/datum/component/itemblock/backpackblock/proc/loseitem(var/mob/living/M, var/obj/item/weap)
	var/obj/item/storage/S = parent
	if(!istype(S)) //HOW???
		return
	if(S != M.equipped())
		return 
	var/obj/item/I = pick(S.get_contents())
	if (!I)
		return
	var/turf/target = locate(M.x + rand(-4,4), M.y+rand(-4,4), M.z)
	I.set_loc(M.loc)
	I.dropped(M)
	S.hud.remove_item(I)
	I.layer = initial(I.layer)
	src.updateblock()
	I.throw_at(target, 4, 1)


/datum/component/itemblock/backpackblock/on_block_begin(obj/item/I, var/obj/item/grab/block/B)
	..()
	updateblock()

/datum/component/itemblock/backpackblock/getTooltipDesc()
	.= ..()
	if(showTooltip) 
		. += itemblock_tooltip_entry("special.png", "Blocks damage based on contents")
		. += itemblock_tooltip_entry("minus.png", "Contents thrown around when attacked")

/datum/component/itemblock/backpackblock/proc/updateblock()
	var/obj/item/storage/I = parent
	if(!istype(I)||!(I.c_flags && I.c_flags & HAS_GRAB_EQUIP))
		return
	var/list/L=I.get_contents()//make dreamchecker happy
	var/blockplus = 1 + round(L.len/3)
	for (var/obj/item/grab/block/B in I.contents)
		if(I.c_flags & BLOCK_CUT)
			B.setProperty("block_cut",blockplus)
		if(I.c_flags & BLOCK_STAB)
			B.setProperty("block_stab",blockplus)
		if(I.c_flags & BLOCK_BURN)
			B.setProperty("block_burn",blockplus)
		if(I.c_flags & BLOCK_BLUNT)
			B.setProperty("block_blunt",blockplus)
