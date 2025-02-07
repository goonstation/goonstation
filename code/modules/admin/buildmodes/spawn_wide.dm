/datum/buildmode/spawn_wide
	name = "Wide Area Spawn"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set object type<br>
Ctrl-RMB on buildmode button = Set cinematic effect<br>
Alt-RMB on buildmode button = Toggle deleting areas<br>

Left Mouse Button on turf/mob/obj      = Mark corners of area with two clicks<br>
Right Mouse Button                     = Delete all objects and turfs in the area marked with two clicks<br>
<br>
Use the button in the upper left corner to<br>
change the direction of created objects.<br>
***********************************************************"}
	icon_state = "buildmode5"
	var/objpath = null
	var/cinematic = "Blink"
	var/delete_area = 0
	var/tmp/turf/A = null
	var/tmp/image/marker = null

	deselected()
		..()
		A = null
		usr.client?.images -= marker

	click_mode_right(var/ctrl, var/alt, var/shift)
		if(ctrl)
			cinematic = (input("Cinematic spawn mode") as null|anything in list("Telepad", "Blink", "None", "Fancy and Inefficient yet Laggy Telepad", "Supplydrop", "Supplydrop (no lootbox)", "Lethal Supplydrop", "Lethal Supplydrop (no lootbox)")) || cinematic
			return
		if(alt)
			delete_area = !delete_area
			boutput(usr, delete_area ? SPAN_ALERT("Now also deleting areas!") : SPAN_ALERT("Now not deleting areas!"))
			return

		if (!objpath)
			objpath = /obj/critter/domestic_bee/heisenbee
		objpath = get_one_match(input("Type path", "Type path", "[objpath]"), /atom)
		update_button_text(objpath)
		A = null
		usr.client?.images -= marker

	proc/mark_corner(atom/object)
		if (!marker)
			marker = image('icons/misc/buildmode.dmi', "marker")
			marker.plane = PLANE_OVERLAY_EFFECTS
			marker.layer = NOLIGHT_EFFECTS_LAYER_BASE
			marker.appearance_flags = RESET_ALPHA | RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART | RESET_TRANSFORM | PIXEL_SCALE
		A = get_turf(object)
		marker.loc = A
		usr.client?.images += marker

	var/matrix/mtx = matrix()
	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!objpath)
			boutput(usr, SPAN_ALERT("No object path!"))
			return
		if (!A)
			mark_corner(object)
		else
			var/turf/B = get_turf(object)
			if (!B || A.z != B.z)
				boutput(usr, SPAN_ALERT("Corners must be on the same Z-level!"))
				return
			update_button_text("Spawning...")
			var/total_area = abs(A.x - B.x) * abs(A.y - B.y)
			logTheThing(LOG_ADMIN, usr, "used buildmode wide area spawn between [log_loc(A)] and [log_loc(B)] with type [src.objpath]. Total area [total_area] objects.")
			var/cnt = 0
			for (var/turf/Q in block(A,B))
				//var/atom/sp = new objpath(Q)
				//if (isobj(sp) || ismob(sp) || isturf(sp))
					//sp.set_dir(holder.dir)
					//sp.onVarChanged("dir", 2, holder.dir)
				switch(cinematic)
					if("Telepad")
						var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl
						var/obj/fakeobject/teleport_pad/pad = new /obj/fakeobject/teleport_pad
						swirl.mouse_opacity = 0
						pad.mouse_opacity = 0
						pad.loc = Q
						pad.alpha = 0
						mtx.Reset()
						mtx.Translate(0, 64)
						pad.transform = mtx
						animate(pad, alpha = 255, transform = mtx.Reset(), time = 5, easing=SINE_EASING)
						SPAWN(0.7 SECONDS)
							swirl.loc = Q
							flick("portswirl", swirl)

							var/atom/A = 0
							if(ispath(objpath, /turf))
								A = Q.ReplaceWith(objpath, 0, 1, 1, force=1)
							else
								A = new objpath(Q)

							if (isobj(A) || ismob(A))
								A.set_dir(holder.dir)
								A.onVarChanged("dir", SOUTH, A.dir)
							sleep(0.5 SECONDS)
							mtx.Reset()
							mtx.Translate(0,64)
							animate(pad, transform=mtx, alpha = 0, time = 5, easing = SINE_EASING)
							sleep(0.5 SECONDS)
							swirl.mouse_opacity = 1
							pad.mouse_opacity = 1
							qdel(swirl)
							qdel(pad)
					if("Fancy and Inefficient yet Laggy Telepad")
						SPAWN(cnt/10)
							var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl
							var/obj/fakeobject/teleport_pad/pad = new /obj/fakeobject/teleport_pad
							swirl.mouse_opacity = 0
							pad.mouse_opacity = 0
							pad.loc = Q
							pad.alpha = 0
							mtx.Reset()
							mtx.Translate(0, 64)
							pad.transform = mtx
							animate(pad, alpha = 255, transform = mtx.Reset(), time = 5, easing=SINE_EASING)
							sleep(0.7 SECONDS)
							swirl.loc = Q
							flick("portswirl", swirl)

							var/atom/A = 0
							if(ispath(objpath, /turf))
								A = Q.ReplaceWith(objpath, 0, 1, 1, force=1)
							else
								A = new objpath(Q)

							if (isobj(A) || ismob(A))
								A.set_dir(holder.dir)
								A.onVarChanged("dir", SOUTH, A.dir)
							sleep(0.5 SECONDS)
							mtx.Reset()
							mtx.Translate(0,64)
							animate(pad, transform=mtx, alpha = 0, time = 5, easing = SINE_EASING)
							sleep(0.5 SECONDS)
							swirl.mouse_opacity = 1
							pad.mouse_opacity = 1
							qdel(swirl)
							qdel(pad)

					if("Blink")
						var/atom/A = 0
						if(ispath(objpath, /turf))
							A = Q.ReplaceWith(objpath, 0, 1, 1, force=1)
						else
							A = new objpath(Q)

						if (isobj(A) || ismob(A))
							A.set_dir(holder.dir)
							A.onVarChanged("dir", SOUTH, A.dir)
							blink(Q)
					if("Supplydrop")
						SPAWN(rand(0, min(200, (length(block(A,B))))))
							if (ispath(objpath, /atom/movable))
								new/obj/effect/supplymarker/safe(Q, 3 SECONDS, objpath)
					if("Supplydrop (no lootbox)")
						SPAWN(rand(0, min(200, (length(block(A,B))))))
							if (ispath(objpath, /atom/movable))
								new/obj/effect/supplymarker/safe(Q, 3 SECONDS, objpath, TRUE)
					if("Lethal Supplydrop")
						SPAWN(rand(0, min(200, (length(block(A,B))))))
							if (ispath(objpath, /atom/movable))
								new/obj/effect/supplymarker(Q, 3 SECONDS, objpath)
					if("Lethal Supplydrop (no lootbox)")
						SPAWN(rand(0, min(200, (length(block(A,B))))))
							if (ispath(objpath, /atom/movable))
								new/obj/effect/supplymarker(Q, 3 SECONDS, objpath, TRUE)
					else
						var/atom/A = 0
						if(ispath(objpath, /turf))
							A = Q.ReplaceWith(objpath, 0, 1, 1, force=1)
						else
							A = new objpath(Q)

						if (isobj(A) || ismob(A))
							A.set_dir(holder.dir)
							A.onVarChanged("dir", SOUTH, A.dir)
				cnt++
				if (cnt > 499)
					cnt = 0
					sleep(0.2 SECONDS)
			A = null
			usr.client?.images -= marker
			update_button_text(objpath)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (!A)
			mark_corner(object)
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, SPAN_ALERT("Corners must be on the same Z-level!"))
				return
			for (var/turf/T in block(A,B))
				if (cinematic == "Blink")
					blink(T)
				for (var/obj/O in T)
					qdel (O)
				if (delete_area)
					new /area(T)
				T.ReplaceWithSpaceForce()
				LAGCHECK(LAG_LOW)
			A = null
			usr.client?.images -= marker
