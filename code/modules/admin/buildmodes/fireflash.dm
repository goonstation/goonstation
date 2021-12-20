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

	click_mode_right(var/ctrl, var/alt, var/shift)
		radius = input("Fireflash range", "Range", radius) as num
		radius = clamp(radius, 0, 40)
		temperature = input("Fireflash center temperature", "Temperature", temperature) as num
		falloff = input("Fireflash temperature falloff over range", "Temperature falloff", falloff) as num
		melting = (alert("Does the fire melt floors?",,"Yes", "No") == "Yes") ? 1 : 0

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!object)
			return
		if (!isturf(object))
			object = get_turf(object)
		if (!object)
			return
		if (melting)
			fireflash_sm(object, radius, temperature, falloff)
		else
			fireflash_s(object, radius, temperature, falloff)
