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

	allowcast()
		if (istype(holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			var/mob/living/intangible/wraith/wraith_trickster/W = holder.owner
			return W.haunting
		return ..()

	castcheck(atom/target)
		if (isrestrictedz(holder.owner.z))
			boutput(holder.owner, SPAN_ALERT("A strange force prevents you from doing that in this area!"))
			return
		var/area/A = get_area(holder.owner)
		if (A.sanctuary)
			boutput(holder.owner, SPAN_ALERT("A strange force prevents you from doing that in this area!"))
			return
		var/mob/living/intangible/wraith/wraith_trickster/W
		if (istype(holder.owner, /mob/living/intangible/wraith/wraith_trickster/))
			W = holder.owner
			if (!W.haunting)
				boutput(holder.owner, SPAN_ALERT("You cannot cast this under your current form."))
				return
		var/mob/living/critter/wraith/trickster_puppet/P = holder.owner
		if (!istype(P))
			boutput(holder.owner, SPAN_ALERT("You cannot cast this under your current form."))
			return
		else
			W = P.master
		var/turf/T = get_turf(holder.owner)
		if (!isturf(T) || !istype(T, /turf/simulated/floor))
			boutput(holder.owner, SPAN_ALERT("You cannot place a trap here."))
			return
		for (var/obj/machinery/wraith/runetrap/R in range(T, 3))
			boutput(holder.owner, SPAN_ALERT("That is too close to another trap to the [dir2text(get_dir(R, holder.owner))]."))
			return
		if ((W != null && W.traps_laid >= max_traps) || (P != null && P.traps_laid >= max_traps))
			boutput(holder.owner, SPAN_ALERT("You already have too many traps!"))
			return
		return ..()

	cast()
		if (..())
			return TRUE
		var/trap_choice = null
		var/turf/T = get_turf(holder.owner)
		if (length(src.trap_types) > 1)
			trap_choice = input("What type of trap do you want?", "Target trap type", null) as null|anything in trap_types
		if(trap_choice == null)
			return TRUE
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

		var/mob/living/intangible/wraith/wraith_trickster/W = holder.owner
		var/mob/living/critter/wraith/trickster_puppet/P = holder.owner
		if (istype(P))
			new trap_choice(T, P.master, holder.owner)
			P.master.traps_laid++
			P.traps_laid++
		else if (istype(W))
			new trap_choice(T, W, holder.owner)
			W.traps_laid++
		else
			boutput(holder.owner, "attempted to place a trap as a non-wraith and non-puppet, this should never happen!!! report this!!! OR ELSE!!!! >:(")
			return
		boutput(holder.owner, SPAN_NOTICE("You place a trap on the floor, and it begins to charge up."))
		return
