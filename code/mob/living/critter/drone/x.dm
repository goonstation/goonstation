/mob/living/critter/robotic/drone/x
	drone_designation = "X"
	desc = "An experimental and extremely dangerous Syndicate railgun drone."
	icon_state = "drone3"

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/railgun
		HH.name = "S-51 Sustained Hardlight Barrager"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handrail"
		HH.limb_name = "S-51 Sustained Hardlight Barrager"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

	setup_loot_table()
		..()
		loot_table[/obj/item/spacecash/buttcoin] = 500

	setup_healths()
		add_hh_robot(500, 1)
		add_hh_robot_burn(500, 1)
