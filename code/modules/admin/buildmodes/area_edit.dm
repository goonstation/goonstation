/datum/buildmode/area_edit
	name = "Area Edit"
	desc = {"***********************************************************<br>
Right Mouse Button on turf             = Select area<br>
Right Mouse Button on buildmode button = Cancel selection<br>
Ctrl + RMB on buildmode button         = Edit selected area variables, or create new area instance if none selected<br>
Left Mouse Button on tufs              = Select corners<br>
***********************************************************"}
	icon_state = "buildmode_grid"
	var/area/A
	var/turf/one
	var/tmp/image/marker = null


	deselected()
		. = ..()
		usr.client?.images -= marker
		one = null

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (ctrl)
			if (A)
				usr.client.debug_variables(A)
			else
				A = tgui_input_list(holder.owner, "Select an area type.", "Area type", concrete_typesof(/area))
				if (!A) return
				A = new A()
				update_button_text(A.name)
		else
			one = null
			boutput(usr, SPAN_NOTICE("Corner cleared!"))

	click_right(atom/object, ctrl, alt, shift)
		. = ..()
		if(get_area(object))
			A = get_area(object)
			update_button_text(A.name)

	proc/mark_corner(atom/object)
		if (!marker)
			marker = image('icons/misc/buildmode.dmi', "marker")
			marker.plane = PLANE_OVERLAY_EFFECTS
			marker.layer = NOLIGHT_EFFECTS_LAYER_BASE
			marker.appearance_flags = RESET_ALPHA | RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART | RESET_TRANSFORM | PIXEL_SCALE
		one = get_turf(object)
		marker.loc = one
		usr.client?.images += marker
		boutput(usr, SPAN_NOTICE("Corner set!"))

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!A)
			boutput(usr, SPAN_ALERT("No area selected!"))
		if (!one)
			mark_corner(object)
			blink(one)
		else
			var/turf/two = get_turf(object)
			blink(two)
			if (!two || one.z != two.z)
				boutput(usr, SPAN_ALERT("Corners must be on the same Z-level!"))
				return
			var/area/area_old = null
			boutput(usr, SPAN_NOTICE("Setting area!"))
			for(var/turf/T in block(one, two))
				area_old = get_area(T)
				if(area_old == A)
					continue

				for (var/obj/machinery/M in T)
					if(M in area_old.machines)
						if(istype(M,/obj/machinery/power/apc))
							var/obj/machinery/power/apc/yoink_apc = M
							yoink_apc.area = A
							yoink_apc.name = "[A.name] APC"
							if (!A.area_apc)
								A.area_apc = yoink_apc

						area_old.machines -= M
						A.machines += M
						if (istype(M,/obj/machinery/light)) // steal all the lights
							area_old.remove_light(M)
							A.add_light(M)

				area_old.contents -= T
				A.contents += T

				if(A.area_apc)
					A.area_apc.request_update()

			one = null
			usr.client?.images -= marker

