/mob/living/critter/golem
	name = "Golem"
	real_name = "Golem"
	desc = "An elemental being, crafted by local artisans using traditional techniques."
	icon_state = "golem"
	hand_count = 2
	blood_id = "smokepowder"
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	metabolizes = FALSE // Don't die to the horrible shit the wizard added
	death_text = "%src% bursts into a puff of smoke!"
	health_brute = 20
	health_brute_vuln = 0.8
	health_burn = 20
	health_burn_vuln = 0.5
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/aggressive
	is_npc = TRUE
	var/reagent_id = null

	New()
		..()
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/golem, src) // Slow strong golems
		src.add_stam_mod_max("golem", 100)
		src.create_reagents(1000)
		SPAWN(4 SECONDS)
			if(reagents && !reagents.total_volume)
				if (length(all_functional_reagent_ids) > 0)
					src.reagent_id = pick(all_functional_reagent_ids)
				else
					src.reagent_id = "water"

				reagents.add_reagent(src.reagent_id, 10)

				var/oldcolor = src.reagents.get_master_color()
				var/icon/I = new /icon('icons/misc/critter.dmi',"golem")
				I.Blend(oldcolor, ICON_ADD)
				src.icon = I
				src.name = "[capitalize(src.reagents.get_master_reagent_name())]-Golem"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/golem
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left golem arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/golem
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right golem arm"

	valid_target(mob/living/C)
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if (H.traitHolder.hasTrait("training_chaplain")) return FALSE
		return ..()

	proc/CustomizeGolem(var/datum/reagents/CR) //customise it with the reagents in a container
		for(var/current_id in CR.reagent_list)
			var/datum/reagent/R = CR.reagent_list[current_id]
			src.reagents.add_reagent(current_id, min(R.volume * 5, 50))

		var/oldcolor = src.reagents.get_master_color()
		var/icon/I = new /icon('icons/misc/critter.dmi',"golem")
		I.Blend(oldcolor, ICON_ADD)
		src.icon = I
		src.faction = FACTION_WIZARD
		src.name = "[capitalize(src.reagents.get_master_reagent_name())]-Golem"
		src.desc = "An elemental entity composed of [src.reagents.get_master_reagent_name()], conjured by a wizard."
		return

	death(var/gibbed)
		..()
		src.visible_message("<span class='combat'><b>[src]</b> bursts into a puff of smoke!</span>")
		logTheThing(LOG_COMBAT, src, "died, causing [src.reagents.get_master_reagent_name()] smoke at [log_loc(src)].")
		src.reagents.smoke_start(12)
		invisibility = INVIS_ALWAYS_ISH
		SPAWN(5 SECONDS)
			qdel(src)
