/datum/targetable/wraithAbility/create_summon_portal
	name = "Summon void portal"
	icon_state = "open_portal"
	desc = "Summon a void portal from which otherworldly creatures pour out. You get increased point generation when near it."
	pointCost = 150
	targeted = FALSE
	cooldown = 3 MINUTES
	var/static/list/mob_types = list("Bears", "Brullbars", "Crunched", "Ancient things", "Ancient repairbots", "Heavy gunner drones",
										"Monstrosity crawlers", "Bats", "Shades", "Lions", "Skeletons", "Random")

	cast()
		. = ..()
		if (issimulatedturf(get_turf(holder.owner)))
			var/mob/living/intangible/wraith/W = src.holder.owner
			if (W.linked_portal)
				if (tgui_alert(holder.owner, "You already have a portal. Do you want to destroy the old one?", "Confirmation", list("Yes", "No")) == "Yes")
					W.linked_portal.deleteLinkedCritters()
					qdel(W.linked_portal)
					W.linked_portal = null
				else
					return TRUE
			var/mob_choice = null
			if (length(src.mob_types) > 1)
				mob_choice = tgui_input_list(holder.owner, "What should the portal spawn?", "Target Mob Type", mob_types)
			if (mob_choice == null)
				return TRUE
			switch(mob_choice)
				if("Crunched")
					mob_choice = /mob/living/critter/crunched
				if("Ancient things")
					mob_choice = /obj/critter/ancient_thing
				if("Ancient repairbots")
					mob_choice = /mob/living/critter/robotic/repairbot/security
				if("Monstrosity crawlers")
					mob_choice = /mob/living/critter/mechmonstrositycrawler
				if("Shades")
					mob_choice = /mob/living/critter/shade
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
					mob_choice = /mob/living/critter/robotic/gunbot
				if("Random")
					mob_choice = null
			boutput(holder.owner, "<span class='success'>You gather your energy and open a portal.</span>")
			var/obj/machinery/wraith/vortex_wraith/vortex = new /obj/machinery/wraith/vortex_wraith(mob_choice)
			if(mob_choice != null)
				vortex.random_mode = FALSE
			vortex.set_loc(get_turf(W))
			vortex.master = W
			vortex.alpha = 0
			animate(vortex, alpha=255, time = 1 SECONDS)
			W.linked_portal = vortex
		else
			boutput(holder.owner, "<span class='alert'>We cannot open a portal here.</span>")
			return TRUE

	castcheck(atom/target)
		. = ..()
		var/mob/living/intangible/wraith/W = src.holder.owner
		if (!W.density)
			boutput(W, "<span class='alert'>Your connection to the physical plane is too weak. You must be manifested to do this.</span>")
			return FALSE
