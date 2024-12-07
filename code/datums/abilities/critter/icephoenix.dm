ABSTRACT_TYPE(/datum/targetable/critter/ice_phoenix)
/datum/targetable/critter/ice_phoenix

// movement modifiers don't work in space it seems, needs to be fixed before this ability works
/datum/targetable/critter/ice_phoenix/sail
	name = "Sail"
	desc = "Channel to gain a large movement speed buff while in space for 10 seconds"
	cooldown = 10 SECONDS // 120 seconds
	cooldown_after_action = TRUE

	tryCast()
		if (!istype(get_turf(src.holder.owner), /turf/space))
			boutput(src.holder.owner, SPAN_ALERT("You need to be in space to use this ability!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		var/mob/living/L = src.holder.owner
		if (L.throwing)
			return
		EndSpacePush(L)
		// 10 seconds below
		SETUP_GENERIC_ACTIONBAR(src.holder.owner, null, 3 SECONDS, /mob/living/critter/ice_phoenix/proc/on_sail, null, \
			'icons/mob/critter/nonhuman/icephoenix.dmi', "icephoenix", null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)

/datum/targetable/critter/ice_phoenix/return_to_station
	name = "Return to Station Space"
	desc = "Toggles if you will return to station space when traveling off the current Z level.<br><br>Currently toggled off."

	cast()
		..()
		var/mob/living/critter/ice_phoenix/phoenix = src.holder.owner
		phoenix.travel_back_to_station = !phoenix.travel_back_to_station
		if (phoenix.travel_back_to_station)
			boutput(phoenix, SPAN_NOTICE("You will now travel back to station space when traveling off the Z level"))
		else
			boutput(phoenix, SPAN_NOTICE("You will no longer travel back to station space when traveling off the Z level"))
		src.object.desc = "Toggles if you will return to station space when traveling off the current Z level.<br><br>Currently toggled " + \
			"[!phoenix.travel_back_to_station ? "off" : "on"]."

