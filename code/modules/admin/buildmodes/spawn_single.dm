/datum/buildmode/spawn_single
	name = "Object Spawn"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set object type<br>
Ctrl-RMB on buildmode button = Set cinematic effect<br>

Left Mouse Button on turf/mob/obj      = Place objects<br>
Right Mouse Button                     = Delete objects<br>
<br>
Use the button in the upper left corner to<br>
change the direction of created objects.<br>
***********************************************************"}
	icon_state = "buildmode2"
	var/objpath = null
	var/cinematic = "Blink"
	var/matrix/mtx = matrix()
	click_mode_right(var/ctrl, var/alt, var/shift)
		if(ctrl)
			cinematic = (input("Cinematic spawn mode") as null|anything in list("Telepad", "Blink", "Supplydrop", "Supplydrop (no lootbox)", "None")) || cinematic
			return
		objpath = get_one_match(input("Type path", "Type path", "/obj/closet"), /atom)
		update_button_text(objpath)

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!objpath)
			boutput(usr, "<span class='alert'>No object path!</span>")
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

						var/atom/A = 0
						if(ispath(objpath, /turf))
							A = T.ReplaceWith(objpath, handle_air = 0)
						else
							A = new objpath(T)


						if (isobj(A) || ismob(A) || isturf(A))
							A.dir = holder.dir
							A.onVarChanged("dir", SOUTH, A.dir)
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
					var/atom/A = 0
					if(ispath(objpath, /turf))
						A = T.ReplaceWith(objpath, handle_air = 0)
					else
						A = new objpath(T)

					if (isobj(A) || ismob(A) || isturf(A))
						A.dir = holder.dir
						A.onVarChanged("dir", SOUTH, A.dir)
						blink(T)
				if("Supplydrop")
					if (ispath(objpath, /atom/movable))
						new/obj/effect/supplymarker/safe(T, 3 SECONDS, objpath)
				if("Supplydrop (no lootbox)")
					if (ispath(objpath, /atom/movable))
						new/obj/effect/supplymarker/safe(T, 3 SECONDS, objpath, TRUE)
				else
					var/atom/A = 0
					if(ispath(objpath, /turf))
						A = T.ReplaceWith(objpath, handle_air = 0)
					else
						A = new objpath(T)

					if (isobj(A) || ismob(A) || isturf(A))
						A.dir = holder.dir
						A.onVarChanged("dir", SOUTH, A.dir)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if(isobj(object))
			qdel(object)
