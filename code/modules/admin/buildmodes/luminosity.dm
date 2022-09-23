/datum/buildmode/luminosity
	name = "Luminosity and Color"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Adjust lighting color to set with left mouse button.<br>
Ctrl + RMB on buildmode button         = Adjust luminosity to set with left mouse button. Each 1 luminosity is 1 tile of radius. Lights larger than 10 can become laggy.<br>
Left Mouse Button                      = Set luminosity and color on selected object<br>
Ctrl + LMB                             = Clear luminosity on selected object<br>
Right Mouse Button                     = Copy luminosity and color from selected object<br>
Ctrl + RMB                             = Reset object luminosity and color to default<br>
***********************************************************"}
	icon_state = "buildmode7"
	var/color_r = 1
	var/color_g = 1
	var/color_b = 1
	var/luminosity = 5

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (ctrl)
			luminosity = input("New luminosity", "New luminosity", luminosity) as num
		else
			var/colorstr = input("New color", "New color", rgb(color_r * 255, color_g * 255, color_b * 255)) as color
			color_r = hex2num(copytext(colorstr, 2, 4)) / 255
			color_g = hex2num(copytext(colorstr, 4, 6)) / 255
			color_b = hex2num(copytext(colorstr, 6, 8)) / 255

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (ctrl)
			if (object.luminosity)
				object.sd_SetLuminosity(0)

			if (istype(object, /obj/machinery/light))
				object:brightness = 0
			blink(get_turf(object))

			boutput(usr, "<span class='notice'>Set [object]'s luminosity to 0.</span>")
		else
			object.sd_SetColor(color_r, color_g, color_b, 1)

			if (istype(object, /obj/machinery/light))
				object:brightness = luminosity

			if (luminosity)
				object.sd_SetLuminosity(luminosity)
			else
				object.sd_SetLuminosity(0)
			blink(get_turf(object))

			boutput(usr, "<span class='notice'>Set [object] to ([object.sd_ColorRed], [object.sd_ColorGreen], [object.sd_ColorBlue]):[luminosity].</span>")

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (ctrl)
			object.sd_SetColor(initial(object.sd_ColorRed), initial(object.sd_ColorGreen), initial(object.sd_ColorBlue), 1)
			object.sd_SetLuminosity(initial(object.luminosity))

			if (istype(object, /obj/machinery/light))
				object:brightness = initial(object:brightness)

			boutput(usr, "<span class='notice'>Reset [object] to ([object.sd_ColorRed], [object.sd_ColorGreen], [object.sd_ColorBlue]):[object.luminosity].</span>")

		else
			color_r = object.sd_ColorRed
			color_g = object.sd_ColorGreen
			color_b = object.sd_ColorBlue
			luminosity = object.luminosity

			boutput(usr, "<span class='notice'>Copied ([color_r], [color_g], [color_b]):[luminosity] from [object].</span>")
