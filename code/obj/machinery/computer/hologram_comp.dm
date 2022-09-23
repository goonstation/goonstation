/obj/machinery/computer/hologram_comp
	name = "Hologram Computer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holo_console0"
	var/obj/machinery/hologram_proj/projector = null
	var/temp = null
	var/lumens = 0
	var/h_r = 245
	var/h_g = 245
	var/h_b = 245

/obj/machinery/computer/hologram_comp/New()
	..()
	SPAWN( 10 )
		src.projector = locate(/obj/machinery/hologram_proj, get_step(src.loc, NORTH))
		return
	return

/obj/machinery/computer/hologram_comp/proc/render()
	var/icon/I = new /icon('icons/mob/human.dmi', "body_m")

	if (src.lumens >= 0)
		I.Blend(rgb(src.lumens, src.lumens, src.lumens), ICON_ADD)
	else
		I.Blend(rgb(- src.lumens,  -src.lumens,  -src.lumens), ICON_SUBTRACT)

	I.Blend(new /icon('icons/mob/human_underwear.dmi', "briefs_b"), ICON_OVERLAY)

	var/icon/U = new /icon('icons/mob/human_hair.dmi', "short")
	U.Blend(rgb(src.h_r, src.h_g, src.h_b), ICON_ADD)
//
	I.Blend(U, ICON_OVERLAY)

	src.projector.projection.icon = I

/obj/machinery/computer/hologram_comp/proc/show_console(var/mob/user as mob)
	var/dat
	src.add_dialog(user)
	if (src.temp)
		dat = text("[]<BR><BR><A href='?src=\ref[];temp=1'>Clear</A>", src.temp, src)
	else
		dat = text("<B>Hologram Status:</B><HR><br>Power: <A href='?src=\ref[];power=1'>[]</A><HR><br><B>Hologram Control:</B><BR><br>Color Luminosity: []/220 <A href='?src=\ref[];reset=1'>\[Reset\]</A><BR><br>Lighten: <A href='?src=\ref[];light=1'>1</A> <A href='?src=\ref[];light=10'>10</A><BR><br>Darken: <A href='?src=\ref[];light=-1'>1</A> <A href='?src=\ref[];light=-10'>10</A><BR><br><BR><br>Hair Color: ([],[],[]) <A href='?src=\ref[];h_reset=1'>\[Reset\]</A><BR><br>Red (0-255): <A href='?src=\ref[];h_r=-300'>\[0\]</A> <A href='?src=\ref[];h_r=-10'>-10</A> <A href='?src=\ref[];h_r=-1'>-1</A> [] <A href='?src=\ref[];h_r=1'>1</A> <A href='?src=\ref[];h_r=10'>10</A> <A href='?src=\ref[];h_r=300'>\[255\]</A><BR><br>Green (0-255): <A href='?src=\ref[];h_g=-300'>\[0\]</A> <A href='?src=\ref[];h_g=-10'>-10</A> <A href='?src=\ref[];h_g=-1'>-1</A> [] <A href='?src=\ref[];h_g=1'>1</A> <A href='?src=\ref[];h_g=10'>10</A> <A href='?src=\ref[];h_g=300'>\[255\]</A><BR><br>Blue (0-255): <A href='?src=\ref[];h_b=-300'>\[0\]</A> <A href='?src=\ref[];h_b=-10'>-10</A> <A href='?src=\ref[];h_b=-1'>-1</A> [] <A href='?src=\ref[];h_b=1'>1</A> <A href='?src=\ref[];h_b=10'>10</A> <A href='?src=\ref[];h_b=300'>\[255\]</A><BR>", src, (src.projector.projection ? "On" : "Off"),  -src.lumens + 35, src, src, src, src, src, src.h_r, src.h_g, src.h_b, src, src, src, src, src.h_r, src, src, src, src, src, src, src.h_g, src, src, src, src, src, src, src.h_b, src, src, src)
	user.Browse(dat, "window=hologram_console")
	onclose(user, "hologram_console")
	return

/obj/machinery/computer/hologram_comp/Topic(href, href_list)
	if(..())
		return
	if (in_interact_range(src, usr))
		flick("holo_console1", src)
		if (href_list["power"])
			if (src.projector.projection)
				src.projector.icon_state = "hologram0"
				qdel(src.projector.projection)
			else
				src.projector.projection = new /obj/projection(src.projector.loc)
				src.projector.projection.icon = 'icons/mob/human.dmi'
				src.projector.projection.icon_state = "body_m"
				src.projector.icon_state = "hologram1"
				src.render()
		else
			if (href_list["h_r"])
				if (src.projector.projection)
					src.h_r += text2num_safe(href_list["h_r"])
					src.h_r = clamp(src.h_r, 0, 255)
					render()
			else
				if (href_list["h_g"])
					if (src.projector.projection)
						src.h_g += text2num_safe(href_list["h_g"])
						src.h_g = clamp(src.h_g, 0, 255)
						render()
				else
					if (href_list["h_b"])
						if (src.projector.projection)
							src.h_b += text2num_safe(href_list["h_b"])
							src.h_b = clamp(src.h_b, 0, 255)
							render()
					else
						if (href_list["light"])
							if (src.projector.projection)
								src.lumens += text2num_safe(href_list["light"])
								src.lumens = clamp(src.lumens, -185.0, 35)
								render()
						else
							if (href_list["reset"])
								if (src.projector.projection)
									src.lumens = 0
									render()
							else
								if (href_list["temp"])
									src.temp = null
		for(var/mob/M in viewers(1, src))
			if (M.using_dialog_of(src))
				src.show_console(M)
	return
