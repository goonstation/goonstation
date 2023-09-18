/datum/targetable/wraithAbility/lay_trap
	name = "Place rune trap"
	icon_state = "runetrap"
	desc = "Create a rune trap which stays invisible in the dark and can be sprung by people."
	pointCost = 50
	targeted = FALSE
	cooldown = 30 SECONDS
	var/max_traps = 7
	var/list/trap_types = list("Madness", "Burning", "Teleporting", "Illusions", "EMP", "Blinding", "Sleepyness", "Slipperiness")

	cast()
		. = ..()
		var/mob/living/intangible/wraith/wraith_trickster/W = null
		var/mob/living/critter/wraith/trickster_puppet/P = null
		if(istype(src.holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			W = src.holder.owner
		else
			P = src.holder.owner
		var/trap_choice = null
		var/turf/T = get_turf(holder.owner)
		if (length(src.trap_types) > 1)
			trap_choice = input("What type of trap do you want?", "Target trap type", null) as null|anything in trap_types
		if(isnull(trap_choice))
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

		if(P)
			new trap_choice(T, P.master)
			P.master.traps_laid++
			P.traps_laid++
		else
			new trap_choice(T, W)
			W.traps_laid++
		boutput(holder.owner, "<span class='hint'>You place a trap on the floor. It begins to charge up...</span>")

	castcheck()
		. = ..()
		var/turf/T = get_turf(src.holder.owner)
		if (!issimulatedturf(T))
			boutput(src.holder.owner, "<span class='notice'>You cannot open a trap here.</span>")
			return FALSE
		if (locate(/obj/machinery/wraith/runetrap) in range(T, 3))
			boutput(src.holder.owner, "<span class='notice'>That is too close to another trap.</span>")
			return FALSE
		if (istype(src.holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			var/mob/living/intangible/wraith/wraith_trickster/W = src.holder.owner
			if (!W.haunting)
				boutput(src.holder.owner, "<span class='notice'>You must be manifested to place a trap!</span>")
				return FALSE
			if (W.traps_laid >= src.max_traps)
				boutput(src.holder.owner, "<span class='notice'>You already have too many traps!</span>")
				return FALSE
		if (istype(src.holder.owner, /mob/living/critter/wraith/trickster_puppet))
			var/mob/living/critter/wraith/trickster_puppet/puppet = src.holder.owner
			if (puppet.traps_laid >= src.max_traps)
				boutput(src.holder.owner, "<span class='notice'>You already have too many traps!</span>")
				return FALSE
