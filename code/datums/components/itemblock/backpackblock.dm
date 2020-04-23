/datum/component/itemblock/backpackblock
	signals = list(COMSIG_ON_ATTACK_FLUSH) 
	mobtype = /mob/living
	proctype = .proc/loseitem

/datum/component/itemblock/backpackblock/proc/loseitem(var/mob/living/mdef, var/mob/living/magr, var/datum/attackResults/msgs) 
	var/obj/item/I = parent
	if(I != mdef.equipped())
		return 
	var/obj/item/T = pick(I.contents)
	if (!T)
		return
	var/turf/target = locate(mdef.x + rand(-2,2), mdef.y+rand(-2,2), mdef.z)
	T.set_loc(get_turf(I.loc))
	T.throw_at(target, 4, 1)

/datum/component/itemblock/backpackblock/getTooltipDesc()
	.= ..()
	if(showTooltip) 
		. += itemblock_tooltip_entry("special.png", "Blocks damage based on contents")
		. += itemblock_tooltip_entry("special.png", "Contents thrown around when attacked")

