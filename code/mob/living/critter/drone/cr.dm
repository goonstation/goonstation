/mob/living/critter/robotic/drone/cr
	drone_designation = "CR"
	desc = "A Syndicate scrap cutter drone, designed for automated salvage operations."
	icon_state = "drone4"

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/energy/cutter
		HH.name = "C-4 Salvager Sawdrill"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handcr"
		HH.limb_name = "C-4 Salvager Sawdrill"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

	setup_healths()
		add_hh_robot(100, 1)
		add_hh_robot_burn(100, 1)
