/datum/targetable/wraithAbility/lay_trap
	name = "Place rune trap"
	icon_state = "runetrap"
	desc = "Create a rune trap which stays invisible in the dark and can be sprung by people."
	pointCost = 50
	targeted = 0
	cooldown = 30 SECONDS
	var/max_traps = 7
	var/list/trap_types = list("Madness",
	"Burning",
	"Teleporting",
	"Illusions",
	"EMP",
	"Blinding",
	"Sleepyness")

	cast()
		if (..())
			return 1

		if (!istype(holder.owner, /mob/living/intangible/wraith/wraith_trickster) && !istype(holder.owner, /mob/living/critter/wraith/trickster_puppet))
			boutput(holder.owner, "<span class='notice'>You cannot cast this under your current form.</span>")
			return 1

		var/mob/living/intangible/wraith/wraith_trickster/W = null
		var/mob/living/critter/wraith/trickster_puppet/P = null
		if(istype(holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			W = holder.owner
			if (!W.haunting)
				boutput(holder.owner, "<span class='notice'>You must be manifested to place a trap!</span>")
				return 1
		else
			P = holder.owner
		var/trap_choice = null
		var/turf/T = get_turf(holder.owner)
		if (!isturf(T) || !istype(T,/turf/simulated/floor))
			boutput(holder.owner, "<span class='notice'>You cannot open a trap here.</span>")
			return 1
		for (var/obj/machinery/wraith/runetrap/R in range(T, 3))
			boutput(holder.owner, "<span class='notice'>That is too close to another trap.</span>")
			return 1
		if ((W != null && W.traps_laid >= max_traps) || (P != null && P.traps_laid >= max_traps))
			boutput(holder.owner, "<span class='notice'>You already have too many traps!</span>")
			return 1
		if (length(src.trap_types) > 1)
			trap_choice = input("What type of trap do you want?", "Target trap type", null) as null|anything in trap_types
		if(trap_choice == null)
			return 1
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

		if(P != null)
			new trap_choice(T, P.master)
			P.master.traps_laid++
			P.traps_laid++
		else
			new trap_choice(T, W)
			W.traps_laid++
		boutput(holder.owner, "You place a trap on the floor, it begins to charge up.")
		return 0
