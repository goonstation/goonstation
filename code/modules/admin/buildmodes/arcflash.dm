/datum/buildmode/arcflash
	name = "Arc Flash"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set wattage<br>
Left Mouse Button on turf/mob/obj      = SHOCK!<br>
***********************************************************"}
	icon_state = "buildmode_zap"
	var/wattage = 5000

	click_mode_right(var/ctrl, var/alt, var/shift)
		wattage = input("Shock wattage", "Wattage", wattage) as num

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (isturf(object))
			arcFlashTurf(usr, object, wattage)
		else
			arcFlash(usr, object, wattage)
