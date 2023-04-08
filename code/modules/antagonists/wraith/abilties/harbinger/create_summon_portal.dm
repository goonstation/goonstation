/datum/targetable/wraithAbility/create_summon_portal
	name = "Summon void portal"
	icon_state = "open_portal"
	desc = "Summon a void portal from which otherworldly creatures pour out. You get increased point generation when near it."
	pointCost = 150
	targeted = 0
	cooldown = 3 MINUTES
	var/list/mob_types = list("Bears",
	"Brullbars",
	"Crunched",
	"Ancient things",
	"Ancient repairbots",
	"Heavy gunner drones",
	"Monstrosity crawlers",
	"Bats",
	"Shades",
	"Lions",
	"Skeletons",
	"Random")

	cast()
		if (..())
			return 1

		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && istype(T,/turf/simulated/floor))
			if(istype(holder.owner, /mob/living/intangible/wraith))
				var/mob/living/intangible/wraith/W = holder.owner
				if (!W.density)
					boutput(holder.owner, "Your connection to the physical plane is too weak. You must be manifested to do this.")
					return 1
				if (W.linked_portal)
					if (alert(holder.owner, "You already have a portal. Do you want to destroy the old one?", "Confirmation", "Yes", "No") == "Yes")
						W.linked_portal.deleteLinkedCritters()
						qdel(W.linked_portal)
						W.linked_portal = null
					else
						return 1
				var/mob_choice = null
				if (length(src.mob_types) > 1)
					mob_choice = tgui_input_list(holder.owner, "What should the portal spawn?", "Target Mob Type", mob_types)
				if (mob_choice == null)
					return 1
				switch(mob_choice)
					if("Crunched")
						mob_choice = /obj/critter/crunched
					if("Ancient things")
						mob_choice = /obj/critter/ancient_thing
					if("Ancient repairbots")
						mob_choice = /obj/critter/ancient_repairbot/security
					if("Monstrosity crawlers")
						mob_choice = /obj/critter/mechmonstrositycrawler
					if("Shades")
						mob_choice = /obj/critter/shade
					if("Bats")
						mob_choice = /obj/critter/bat/buff
					if("Lions")
						mob_choice = /mob/living/critter/lion
					if("Skeletons")
						mob_choice = /mob/living/critter/skeleton/wraith
					if("Bears")
						mob_choice = /mob/living/critter/bear
					if("Brullbars")
						mob_choice = /mob/living/critter/brullbar
					if("Heavy gunner drones")
						mob_choice = /obj/critter/gunbot/heavy
					if("Random")
						mob_choice = null
				boutput(holder.owner, "You gather your energy and open a portal")
				var/obj/machinery/wraith/vortex_wraith/V = new /obj/machinery/wraith/vortex_wraith(mob_choice)
				if(mob_choice != null)
					V.random_mode = FALSE
				V.set_loc(W.loc)
				V.master = W
				V.alpha = 0
				animate(V, alpha=255, time = 1 SECONDS)
				W.linked_portal = V
				return 0
		else
			boutput(holder.owner, "We cannot open a portal here")
			return 1
