/datum/targetable/wraithAbility/lay_trap
	name = "Place Rune Trap"
	icon_state = "runetrap"
	desc = "Create a rune trap which stays invisible in the dark and can be sprung by people. It takes several seconds to arm."
	pointCost = 50
	targeted = FALSE
	cooldown = 30 SECONDS
	var/max_traps = 7
	var/list/trap_types = list(
		"Madness",
		"Burning",
		"Teleporting",
		"Illusions",
		"EMP",
		"Blinding",
		"Sleepyness",
		"Slipperiness"
	)

	onAttach(datum/abilityHolder/holder)
		. = ..()
		if (src.max_traps)
			src.desc += " You can only place up to [src.max_traps] trap[s_es(src.max_traps)] at a time."
			src.object.desc = src.desc

	allowcast()
		if (istype(src.holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			var/mob/living/intangible/wraith/wraith_trickster/W = src.holder.owner
			return W.haunting
		return ..()

	cast()
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE

		if (isrestrictedz(src.holder.owner.z))
			boutput(src.holder.owner, SPAN_ALERT("A strange force prevents you from doing that in this area!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/area/A = get_area(src.holder.owner)
		if (A.sanctuary)
			boutput(src.holder.owner, SPAN_ALERT("A strange force prevents you from doing that in this area!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/mob/living/intangible/wraith/wraith_trickster/W
		if (istype(src.holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			W = src.holder.owner
			if (!W.haunting)
				boutput(src.holder.owner, SPAN_ALERT("You cannot cast this under your current form."))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/mob/living/critter/wraith/trickster_puppet/P = src.holder.owner
		if (!istype(P))
			boutput(src.holder.owner, SPAN_ALERT("You cannot cast this under your current form."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		else
			W = P.master
		var/turf/T = get_turf(src.holder.owner)
		if (!isturf(T) || !istype(T, /turf/simulated/floor))
			boutput(src.holder.owner, SPAN_ALERT("You cannot place a trap here."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		for (var/obj/machinery/wraith/runetrap/R in range(T, 3))
			boutput(src.holder.owner, SPAN_ALERT("That is too close to another trap to the [dir2text(get_dir(R, src.holder.owner))]."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if ((W != null && W.traps_laid >= max_traps) || (P != null && P.traps_laid >= max_traps))
			boutput(src.holder.owner, SPAN_ALERT("You already have too many traps!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/trap_choice = null
		if (length(src.trap_types) > 1)
			trap_choice = tgui_input_list(src.holder.owner, "What type of trap do you want?", src.name, trap_types)
		if(trap_choice == null || QDELETED(src.holder.owner))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		switch(trap_choice)
			if("Madness")
				trap_choice = /obj/machinery/wraith/runetrap/madness
			if("Burning")
				trap_choice = /obj/machinery/wraith/runetrap/fire
			if("Teleporting")
				trap_choice = /obj/machinery/wraith/runetrap/teleport
			if("Illusions")
				trap_choice = /obj/machinery/wraith/runetrap/terror
			if("EMP")
				trap_choice = /obj/machinery/wraith/runetrap/emp
			if("Blinding")
				trap_choice = /obj/machinery/wraith/runetrap/stunning
			if("Sleepyness")
				trap_choice = /obj/machinery/wraith/runetrap/sleepyness
			if("Slipperiness")
				trap_choice = /obj/machinery/wraith/runetrap/slipping
		if (istype(P))
			new trap_choice(T, P.master, src.holder.owner)
			P.master.traps_laid++
			P.traps_laid++
		else if (istype(W))
			new trap_choice(T, W, src.holder.owner)
			W.traps_laid++
		else
			stack_trace("[identify_object(src.holder.owner)] attempted to place a trap as a non-wraith and non-puppet, this should never happen!!!")
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		boutput(src.holder.owner, SPAN_NOTICE("You place a trap on the floor, and it begins to charge up."))
		return CAST_ATTEMPT_SUCCESS
