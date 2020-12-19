/datum/buildmode/spawn_gift
	name = "Gift Spawn"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set gift object type<br>
Ctrl-RMB on buildmode button = Set cinematic effect and giftwrap style<br>

Left Mouse Button on turf/mob/obj      = Place gifts<br>
Right Mouse Button                     = Mark corners of area to spawn gifts with two clicks<br>
Right Mouse Button + CTRL              = Clear area corners<br>
Right Mouse Button + Shift             = Set object type to selected mob/obj type<br>
<br>
Use the button in the upper left corner to<br>
change the direction of created objects.<br>
***********************************************************"}
	icon_state = "buildmode12"
	var/objpath = null
	var/cinematic = "Blink"
	var/giftwrap_style = "Regular"
	var/turf/first_corner = null
	var/matrix/mtx = matrix()
	click_mode_right(var/ctrl, var/alt, var/shift)
		if(ctrl)
			cinematic = (input("Cinematic spawn mode") as null|anything in list("Telepad", "Blink", "None")) || cinematic
			giftwrap_style = (input("Gift wrapping style mode") as null|anything in list("Regular", "Spacemas")) || giftwrap_style
			return
		objpath = get_one_match(input("Type path", "Type path", "/obj/closet"), /atom)
		first_corner = null
		if(ispath(objpath, /turf))
			boutput(usr, "<span class='alert'>No gifting turfs!</span>")
			return
		update_button_text(objpath)

	proc/mark_corner(atom/object)
		first_corner = get_turf(object)

	proc/spawn_gift(var/turf/T)
		var/atom/A
		var/obj/item/gift/G = new /obj/item/gift(T)
		A = new objpath(G)
		var/random_style
		if(isitem(A))
			var/obj/item/gifted_item = A
			G.size = gifted_item.w_class
			G.w_class = G.size + 1
			//style selection copied from wrapping paper's New()
			if(giftwrap_style == "Regular")
				random_style = rand(1,8)
			else
				random_style = pick("r", "rs", "g", "gs")
			G.icon_state = "gift[clamp(G.size, 1, 3)]-[random_style]"
		else if(ismob(A) || istype(A, /obj/critter))
			G.size = 3
			G.w_class = G.size + 1
			//style selection copied from wrapping paper's New()
			if(giftwrap_style == "Regular")
				random_style = rand(1,8)
			else
				random_style = pick("r", "rs", "g", "gs")
			G.icon_state = "strange-[random_style]"
		else
			G.size = 3
			G.w_class = 4
			//style selection copied from wrapping paper's New()
			if(giftwrap_style == "Regular")
				random_style = rand(1,8)
			else
				random_style = pick("r", "rs", "g", "gs")
			G.icon_state = "gift3-[random_style]"
		G.gift = A
		if (isobj(A) || ismob(A))
			A.set_dir(holder.dir)
			A.onVarChanged("dir", SOUTH, A.dir)

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!objpath || ispath(objpath, /turf))
			boutput(usr, "<span class='alert'>Incorrect object path!</span>")
			return
		var/turf/T = get_turf(object)
		if(!isnull(T) && objpath)
			switch(cinematic)
				if("Telepad")
					var/obj/decal/teleport_swirl/swirl = unpool(/obj/decal/teleport_swirl)
					var/obj/decal/fakeobjects/teleport_pad/pad = unpool(/obj/decal/fakeobjects/teleport_pad)
					swirl.mouse_opacity = 0
					pad.mouse_opacity = 0
					pad.loc = T
					pad.alpha = 0
					mtx.Reset()
					mtx.Translate(0, 64)
					pad.transform = mtx
					animate(pad, alpha = 255, transform = mtx.Reset(), time = 5, easing=SINE_EASING)
					SPAWN_DBG(0.7 SECONDS)
						swirl.loc = T
						flick("portswirl", swirl)

						spawn_gift(T)

						sleep(0.5 SECONDS)
						mtx.Reset()
						mtx.Translate(0,64)
						animate(pad, transform=mtx, alpha = 0, time = 5, easing = SINE_EASING)
						sleep(0.5 SECONDS)
						swirl.mouse_opacity = 1
						pad.mouse_opacity = 1
						pool(swirl)
						pool(pad)
				if("Blink")
					spawn_gift(T)
					blink(T)
				else
					spawn_gift(T)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			if (ismob(object) || isobj(object))
				objpath = object.type
				update_button_text(objpath)
			return
		if(ctrl)
			first_corner = null
			boutput(usr, "<span class='alert'>Cleared corners!</span>")
			return
		if (!objpath || ispath(objpath, /turf))
			boutput(usr, "<span class='alert'>Incorrect object path!</span>")
			return
		else if (!first_corner)  //mark first corner
			mark_corner(object)
		else  //first corner exists, time to wide area spawn
			var/turf/second_corner = get_turf(object)
			if (!second_corner || first_corner.z != second_corner.z)
				boutput(usr, "<span class='alert'>Corners must be on the same Z-level!</span>")
				return
			update_button_text("Spawning...")
			var/cnt = 0
			for (var/turf/Q in block(first_corner,second_corner))
				switch(cinematic)
					if("Telepad")
						var/obj/decal/teleport_swirl/swirl = unpool(/obj/decal/teleport_swirl)
						var/obj/decal/fakeobjects/teleport_pad/pad = unpool(/obj/decal/fakeobjects/teleport_pad)
						swirl.mouse_opacity = 0
						pad.mouse_opacity = 0
						pad.loc = Q
						pad.alpha = 0
						mtx.Reset()
						mtx.Translate(0, 64)
						pad.transform = mtx
						animate(pad, alpha = 255, transform = mtx.Reset(), time = 5, easing=SINE_EASING)
						SPAWN_DBG(0.7 SECONDS)
							swirl.loc = Q
							flick("portswirl", swirl)

							spawn_gift(Q)

							sleep(0.5 SECONDS)
							mtx.Reset()
							mtx.Translate(0,64)
							animate(pad, transform=mtx, alpha = 0, time = 5, easing = SINE_EASING)
							sleep(0.5 SECONDS)
							swirl.mouse_opacity = 1
							pad.mouse_opacity = 1
							pool(swirl)
							pool(pad)
					if("Blink")
						spawn_gift(Q)
						blink(Q)
					else
						spawn_gift(Q)
				cnt++
				if (cnt > 499)
					cnt = 0
					sleep(0.2 SECONDS)
			first_corner = null
			update_button_text(objpath)

