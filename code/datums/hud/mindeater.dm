/datum/hud/critter/mindeater
	New()
		..()
		src.create_screen("toggle_psi_bolt", "Toggle Psi Bolt", 'icons/mob/critter/nonhuman/intruder.dmi', "psi_bolt-on", "SOUTH,EAST", HUD_LAYER_1, \
			customType = /atom/movable/screen/hud/toggle_psi_bolt)

	relay_click(id, mob/user, list/params)
		var/mob/living/critter/mindeater/mindeater = src.master
		if (id == "toggle_psi_bolt")
			mindeater.toggle_psi_bolt()
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
