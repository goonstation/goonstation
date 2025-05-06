/datum/hud/critter/mindeater
	New()
		..()
		src.create_screen("toggle_psi_bolt", "Toggle Psi Bolt", 'icons/mob/critter/nonhuman/intruder.dmi', "psi_bolt-on", "SOUTH,EAST", HUD_LAYER_1, \
			customType = /atom/movable/screen/hud/toggle_psi_bolt)

		src.create_screen("toggle_mind_speak", "Toggle Mind Speak", 'icons/mob/critter/nonhuman/intruder.dmi', "shared_speaking-on", "SOUTH,EAST-1", HUD_LAYER_1, \
			customType = /atom/movable/screen/hud/toggle_mind_speak)

	relay_click(id, mob/user, list/params)
		var/mob/living/critter/mindeater/mindeater = src.master
		if (id == "toggle_psi_bolt")
			mindeater.toggle_psi_bolt()
		else if (id == "toggle_mind_speak")
			mindeater.toggle_shared_speaking()
		else
			..()

/atom/movable/screen/hud/toggle_psi_bolt
	desc = "Toggles whether you can fire your psi bolt when disguised.<br><br>Currently toggled on."
	var/toggled_on = TRUE

	clicked(list/params)
		src.toggled_on = !src.toggled_on
		src.desc = "Toggles whether you can fire your psi bolt when disguised.<br><br>Currently toggled [src.toggled_on ? "on" : "off"]."
		src.icon_state = "psi_bolt-[src.toggled_on ? "on" : "off"]"
		..()

/atom/movable/screen/hud/toggle_mind_speak
	desc = "Toggles whether what you say is shared among Invaders or aloud.<br><br>Currently set to Invaders."
	var/toggled_on = TRUE

	clicked(list/params)
		src.toggled_on = !src.toggled_on
		src.desc = "Toggles whether what you say is shared among Invaders or aloud.<br><br>Currently set to [src.toggled_on ? "Invaders" : "aloud"]."
		src.icon_state = "shared_speaking-[src.toggled_on ? "on" : "off"]"
		..()
