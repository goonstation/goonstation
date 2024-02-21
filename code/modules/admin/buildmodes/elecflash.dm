/datum/buildmode/elecflash
	name = "Electric Flash"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set electric parameters<br>
Left Mouse Button on turf/mob/obj      = ZAP!<br>
***********************************************************"}
	icon_state = "buildmode_zap"
	var/radius = 3
	var/power = 3
	var/exclude_center = 0

	click_mode_right(var/ctrl, var/alt, var/shift)
		radius = input("Zap range", "Range", radius) as num
		radius = clamp(radius,0,8)
		power = input("Power (clamped 1 to 6)", "Power", power) as num
		power = clamp(power,0,6)
		exclude_center = (alert("Exclude center tile?",,"Yes", "No") == "Yes") ? 1 : 0

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!object)
			return
		if (!isturf(object))
			object = get_turf(object)
		if (!object)
			return
		elecflash(object,radius,power, exclude_center)
