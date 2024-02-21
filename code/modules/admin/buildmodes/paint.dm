/datum/buildmode/paint
	name = "Paint"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Paint object<br>
Right Mouse Button on mob/obj/turf = Depaint object<br>
Right Mouse Button on buildmode    = Select color<br>
***********************************************************"}
	icon_state = "buildmode7"
	var/paintcolor = "#ffffff"

	click_mode_right(var/ctrl, var/alt, var/shift)
		paintcolor = input("Painting color", "Color", paintcolor) as color
		update_button_text("Color: <span style='color: [paintcolor];'>[paintcolor]</span>")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		object.color = paintcolor
		blink(get_turf(object))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		object.color = null
		blink(get_turf(object))
