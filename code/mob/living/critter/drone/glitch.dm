/mob/living/critter/robotic/drone/glitch
	name = "D²o-|"
	drone_designation = "Glitch"
	desc = "A highly dÄ:;g$r+us $yn§i#a{e $'+~`?? ???? ? ???? ??"
	icon_state = "glitchdrone"
	alert_sounds = list('sound/machines/glitch1.ogg', 'sound/machines/glitch2.ogg')

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/glitch
		HH.name = "C&z !!!!!!ERROR!!!!!!!--~$!'S"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handglitch"
		HH.limb_name = "C&z !!!!!!ERROR!!!!!!!--~$!'S"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

	setup_healths()
		add_hh_robot(4000, 1)
		add_hh_robot_burn(4000, 1)
