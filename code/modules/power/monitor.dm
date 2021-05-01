// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet

/obj/machinery/power/monitor
	name = "Power Monitoring Computer"
	icon = 'icons/obj/machinery/computer.dmi'
	icon_state = "power2"
	density = 1
	anchored = 1
	desc = "Shows the power usage of the station."
	var/datum/light/light
	var/light_r = 1
	var/light_g = 1
	var/light_b = 1
	var/window_tag = "powcomp"
	/// does it have a glow in the dark screen? see computer_screens.dmi
	var/glow_in_dark_screen = TRUE
	var/image/screen_image

/obj/machinery/power/monitor/New()
	..()
	light = new/datum/light/point
	light.set_brightness(0.4)
	light.set_color(light_r, light_g, light_b)
	light.attach(src)
	if(glow_in_dark_screen)
		src.screen_image = image('icons/obj/computer_screens.dmi', src.icon_state, -1)
		screen_image.plane = PLANE_LIGHTING
		screen_image.blend_mode = BLEND_ADD
		screen_image.layer = LIGHTING_LAYER_BASE
		screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.UpdateOverlays(screen_image, "screen_image")

/obj/machinery/power/monitor/attack_ai(mob/user)
	add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return
	interacted(user)

/obj/machinery/power/monitor/attack_hand(mob/user)
	add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return
	interacted(user)

/obj/machinery/power/monitor/proc/interacted(mob/user)

	if ( (!in_interact_range(src, user)) || (status & (BROKEN|NOPOWER)) )
		src.remove_dialog(user)
		user.Browse(null, "window=[window_tag]")
		return

	src.add_dialog(user)
	var/t = "<TT><B>Power Monitoring</B><HR>"

	if(!powernet)
		t += "<span style=\"color:red\">No connection</span>"
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			var/obj/machinery/power/apc/A = term.master
			if(istype(A) && (!A.area || A.area.requires_power))
				L += A

		t += "<PRE>Total power: [engineering_notation(powernet.avail)]W<BR>Total load:  [engineering_notation(powernet.viewload)]W<BR>"

		t += "<FONT SIZE=-1>"

		if(L.len > 0)

			t += "Area                           Eqp./Lgt./Env.  Load   Cell  | Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

			var/list/S = list("<span style='background-color: #f88'> Off</span>","<span style='background-color: #fa6'>AOff</span>","<span style='background-color: #8f8'>  On</span>", "<span style='background-color: #ccf'> AOn</span>")
			var/list/chg = list("N","C","F")

			var/do_newline = 0
			for(var/obj/machinery/power/apc/A in L)

				t += copytext(add_tspace(A.area.name, 30), 1, 30)
				t += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "   N/C"][do_newline ? "<BR>" : " | "]"
				do_newline = !do_newline

		t += "</FONT></PRE>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A></TT>"

	user.Browse(t, "window=[window_tag];size=840x700")
	onclose(user, window_tag)

/obj/machinery/power/monitor/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr.Browse(null, "window=[window_tag]")
		src.remove_dialog(usr)
		return

/obj/machinery/power/monitor/process()
	if(!(status & (NOPOWER|BROKEN)) )
		use_power(250)

	src.updateDialog()

/obj/machinery/power/monitor/console_upper
	icon = 'icons/obj/machinery/computerpanel.dmi'
	icon_state = "power1"

/obj/machinery/power/monitor/console_lower
	icon = 'icons/obj/machinery/computerpanel.dmi'
	icon_state = "power2"

/obj/machinery/power/monitor/power_change()

	if(status & BROKEN)
		icon_state = "broken"
		light.disable()
		if(glow_in_dark_screen)
			src.ClearSpecificOverlays("screen_image")
	else
		if( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
			light.enable()
			if(glow_in_dark_screen)
				screen_image.plane = PLANE_LIGHTING
				screen_image.blend_mode = BLEND_ADD
				screen_image.layer = LIGHTING_LAYER_BASE
				screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
				src.UpdateOverlays(screen_image, "screen_image")
		else
			SPAWN_DBG(rand(0, 15))
				src.icon_state = "power20"
				status |= NOPOWER
				light.disable()
				if(glow_in_dark_screen)
					src.ClearSpecificOverlays("screen_image")

// tweaked version to hook up to the engine->smes powernet and show SMES usage stats and power produced
/obj/machinery/power/monitor/smes
	name = "SMES Monitoring Computer"
	icon = 'icons/obj/machinery/computer.dmi'
	icon_state = "power"
	density = 1
	anchored = 1
	desc = "Shows the SMES usage and power produced by the engine."
	window_tag = "smespowcomp"

/obj/machinery/power/monitor/smes/interacted(mob/user)

	if ( (!in_interact_range(src,user)) || (status & (BROKEN|NOPOWER)) )
		src.remove_dialog(user)
		user.Browse(null, "window=[window_tag]")
		return

	src.add_dialog(user)
	var/t = "<TT><B>Engine and SMES Monitoring</B><HR>"

	if(!powernet)
		t += "<span style=\"color:red\">No connection</span>"
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/smes))
				var/obj/machinery/power/smes/A = term.master
				L += A
			else if(istype(term.master,/obj/machinery/power/pt_laser))
				var/obj/machinery/power/pt_laser/P = term.master
				L += P

		t += "<PRE>Engine Output: [engineering_notation(powernet.avail)]W<BR>SMES/PTL Draw:     [engineering_notation(powernet.viewload)]W<BR>"

		t += "<FONT SIZE=-1>"

		if(L.len > 0)

			t += "Area                   Stored Power | Charging |   Input |  Output | Active | Load<HR>"

			for(var/obj/machinery/power/smes/A in L)
				var/area/place = get_area(A)
				t += copytext(add_tspace(place.name, 30), 1, 30)

				t += "[add_lspace(round(100.0*A.charge/A.capacity, 0.1), 5)]% |      [A.charging ? "Yes" : " No"] | [add_lspace(A.chargelevel,7)] | [add_lspace(A.output,7)] |    [A.online ? "Yes" : " No"] | [A.loaddemand]<BR>"

			for(var/obj/machinery/power/pt_laser/P in L)
				var/area/place = get_area(P)
				t += copytext(add_tspace(place.name, 30), 1, 30)

				t += "[P.output ? add_lspace(round(100.0*P.charge/P.output, 0.1), 5) : 0]% |      [P.charging ? "Yes" : " No"] | [add_lspace(P.chargelevel,7)] | [add_lspace(P.output,7)] |    [P.online ? "Yes" : " No"] | N/A<BR>"

		t += "</FONT></PRE>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A></TT>"

	user.Browse(t, "window=[window_tag];size=660x400")
	onclose(user, window_tag)
