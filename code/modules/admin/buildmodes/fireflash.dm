/datum/buildmode/fireflash
	name = "Fire Flash"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set fire parameters<br>
Left Mouse Button on turf/mob/obj      = FIRE! Literally.<br>
***********************************************************"}
	icon_state = "buildmode_zap"
	var/radius = 3
	var/temperature = 2000
	var/falloff = 200
	var/melting = 0
	var/chemfire_color = null
	var/static/list/chemfire_colors

	New()
		..()
		if (!src.chemfire_colors)
			src.chemfire_colors = list(CHEM_FIRE_RED, CHEM_FIRE_DARKRED, CHEM_FIRE_BLUE, CHEM_FIRE_YELLOW,
				CHEM_FIRE_GREEN, CHEM_FIRE_PURPLE, CHEM_FIRE_BLACK, CHEM_FIRE_WHITE)

	click_mode_right(var/ctrl, var/alt, var/shift)
		radius = input("Fireflash range", "Range", radius) as num
		radius = clamp(radius, 0, 40)
		temperature = input("Fireflash center temperature", "Temperature", temperature) as num
		falloff = input("Fireflash temperature falloff over range", "Temperature falloff", falloff) as num
		melting = (alert("Does the fire melt floors?",,"Yes", "No") == "Yes") ? 1 : 0
		if (tgui_alert(usr, "Is the fire a chemical fire?", "Atmos or chem fire", list("Yes", "No")) == "Yes")
			src.chemfire_color = tgui_input_list(usr, "Choose color", "Color", src.chemfire_colors) || CHEM_FIRE_RED
		else
			src.chemfire_color = null

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!object)
			return
		if (!isturf(object))
			object = get_turf(object)
		if (!object)
			return
		if (melting)
			fireflash_melting(object, radius, temperature, falloff, chemfire = src.chemfire_color)
		else
			fireflash(object, radius, temperature, falloff, chemfire = src.chemfire_color)
