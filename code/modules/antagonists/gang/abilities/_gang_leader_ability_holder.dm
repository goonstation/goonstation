/datum/abilityHolder/gang
	usesPoints = FALSE
	tabName = "gang"
	var/stealthed = FALSE
	var/const/MAX_POINTS = 100


/datum/targetable/gang
	icon = 'icons/mob/gang_abilities.dmi'
	icon_state = "gang-template"
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/gang
	can_cast_while_cuffed = TRUE

/datum/targetable/gang/set_gang_base
	name = "Set Gang Base"
	desc = "Permanently sets the area you're currently in as your gang's base and spawns your gang's locker."
	icon_state = "set-gang-base"
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED

	cast()
		. = ..()
		var/mob/M = holder.owner
		var/area/area = get_area(M)

		if(!istype(area, /area/station))
			boutput(M, SPAN_ALERT("You can only set your gang's base on the station."))
			return

		if(area.gang_base)
			boutput(M, SPAN_ALERT("Another gang's base is in this area!"))
			return

		var/datum/antagonist/gang_leader/antag_role = M.mind.get_antagonist(ROLE_GANG_LEADER)
		if (!antag_role)
			return

		antag_role.gang.select_gang_uniform()
		antag_role.gang.base = area
		area.gang_base = TRUE

		for(var/datum/mind/member in antag_role.gang.members)
			boutput(member.current, SPAN_ALERT("Your gang's base has been set up in [area]!"))

		for(var/obj/decal/cleanable/gangtag/G in area)
			if(G.owners == antag_role.gang)
				continue
			antag_role.gang.make_tag(get_turf(G))
			break

		var/obj/ganglocker/locker = new /obj/ganglocker(get_turf(M))
		locker.name = "[antag_role.gang.gang_name] Locker"
		locker.desc = "A locker with a small screen attached to the door, and the words 'Property of [antag_role.gang.gang_name] - DO NOT TOUCH!' scratched into both sides."
		locker.gang = antag_role.gang
		antag_role.gang.locker = locker
		locker.UpdateIcon()

		M.remove_ability_holder(/datum/abilityHolder/gang)
