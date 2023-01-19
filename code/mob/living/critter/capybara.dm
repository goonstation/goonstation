/mob/living/critter/small_animal/capybara
	name = "capybara"
	desc = "Everybody's friendly coconut on legs."
	icon_state = "capybara"
	icon_state_dead = "capybara-dead" //normally this wouldn't be necessary, except icon_state can be modified to capybara-sitting
	is_npc = TRUE
	ai_type = /datum/aiHolder/capybara
	can_lie = FALSE
	butcherable = 2 //2 makes butchering this creature an abominable act. Which it is. You monsters.
