/datum/targetable/faith_based
	//var/faith_cost = 0

	tryCast(atom/target, params)
		/* var/area/station/chapel/area = get_area(holder.owner)
		if (!istype(area))
			boutput(holder.owner, SPAN_ALERT("You can only cast that spell while on holy ground."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (src.targeted)
			area = get_area(target)
			if (!istype(area))
				boutput(holder.owner, SPAN_ALERT("You can only target holy ground with that ability."))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN */
		/* var/datum/trait/job/chaplain/faithtrait = holder.owner.traitHolder.getTrait("training_chaplain")
		if (!faithtrait || faithtrait.faith < src.faith_cost)
			boutput(holder.owner, SPAN_ALERT("Your flock lacks the faith for you to use this ability."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN */
		. = ..()
		/* if (. == CAST_ATTEMPT_SUCCESS)
			faithtrait.faith -= src.faith_cost */

/datum/targetable/faith_based/alight_candles
	name = "Alight Candles"
	desc = "Alights all the candles in the chapel."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "toxmob"
	cooldown = 10 SECONDS

	cast(atom/target)
		..()
		var/area/station/chapel/area = get_area(holder.owner)
		for (var/obj/item/device/light/candle/candle in area.contents)
			candle.light(holder.owner)

/datum/targetable/faith_based/snuff_candles
	name = "Snuff Candles"
	desc = "Snuffs all the candles in the chapel."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "bholerip"
	cooldown = 10 SECONDS

	cast(atom/target)
		..()
		var/area/station/chapel/area = get_area(holder.owner)
		for (var/obj/item/device/light/candle/candle in area.contents)
			candle.put_out(holder.owner)


/datum/targetable/faith_based/chaplain_announcement
	name = "Chapel Announcement"
	desc = "Make an announcement."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "puke"
	cooldown = 2 MINUTES

	cast(atom/target)
		..()
		var/message = input(holder.owner, null, "Announcement text:")
		if (!message && message == "")
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		command_announcement(message, "[holder.owner]'s booming voice echoes from the chapel", 'sound/voice/chanting.ogg', alert_origin=ALERT_DEPARTMENT)

ABSTRACT_TYPE(/datum/targetable/faith_based/spawn_decoration)
/datum/targetable/faith_based/spawn_decoration
	name = "Spawn Decoration"
	desc = "spawns a decoration."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "toxmob"
	cooldown = 30 SECONDS
	targeted = TRUE
	target_anything = TRUE
	var/spawnable_type

	castcheck(atom/target)
		. = ..()
		if (!.)
			return
		if (disabled)
			boutput(holder.owner, SPAN_ALERT("You cannot use that ability at this time."))
			return FALSE

	cast(atom/target)
		if (!spawnable_type)
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/turf/turf = get_turf(target)
		if (!isfloor(turf))
			boutput(holder.owner, SPAN_ALERT("You can only spawn decorations on floors."))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		for (var/obj/O in turf)
			if (O.density || isitem(O))
				boutput(holder.owner, SPAN_ALERT("You cannot spawn a decoration here, because of [O]."))
				return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/list/check_turfs = get_all_neighbours(turf)
		for (var/turf/check_turf in check_turfs)
			for (var/obj/O in check_turf)// needs to have a lot of space around it, to prevent it from being used as an impromptu barricade
				if (O.density || istype(O, /obj/machinery/door))
					boutput(holder.owner, SPAN_ALERT("You cannot spawn a decoration here; [O] is in the way."))
					return CAST_ATTEMPT_FAIL_CAST_FAILURE
		..()
		var/decoration = new spawnable_type(turf)
		animate_supernatural_spawn(decoration)
		holder.owner.abilityHolder.removeAbility(src.type)
		if (!atheist_manager)
			atheist_manager = new()
		atheist_manager.add_object(decoration, image(icon = 'icons/obj/clothing/overcoats/item_suit_cardboard.dmi', icon_state = "c_box", pixel_x = 20))
		return CAST_ATTEMPT_SUCCESS


/datum/targetable/faith_based/spawn_decoration/tree
	name = "Spawn Decoration"
	desc = "spawns a decoration."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "toxmob"
	cooldown = 30 SECONDS
	spawnable_type = /obj/tree

/datum/targetable/faith_based/spawn_decoration/eternal_fire
	name = "Eternal Fire"
	desc = "Conjure an oddly cool flame which will burn forever, without need for fuel."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "fire_essence1"
	cooldown = 30 SECONDS
	spawnable_type = null

	cast(atom/target)
		..()
		var/turf/turf = get_turf(target)
		var/atom/movable/hotspot/chemfire/fire = new (turf, CHEM_FIRE_YELLOW)
		fire.temperature = T20C
		fire.min_status_duration = 2
		fire.max_status_duration = 4



/// Gets a list of all 8 neighbouring turfs of the given turf. Ignores the edges of the map
proc/get_all_neighbours(turf/T) // TODO figure out which file this should go into
	if(!T) return list()

	var/list/neighbours = list()
	var/x = T.x
	var/y = T.y
	var/z = T.z

	var/turf/north = locate(x, y+1, z)
	if(north) neighbours += north
	var/turf/south = locate(x, y-1, z)
	if(south) neighbours += south
	var/turf/east = locate(x+1, y, z)
	if(east) neighbours += east
	var/turf/west = locate(x-1, y, z)
	if(west) neighbours += west
	var/turf/ne = locate(x+1, y+1, z)
	if(ne) neighbours += ne
	var/turf/nw = locate(x-1, y+1, z)
	if(nw) neighbours += nw
	var/turf/se = locate(x+1, y-1, z)
	if(se) neighbours += se
	var/turf/sw = locate(x-1, y-1, z)
	if(sw) neighbours += sw
	return neighbours
