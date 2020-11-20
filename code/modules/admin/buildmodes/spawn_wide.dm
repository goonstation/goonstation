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
	var/turf/A = null

	deselected()
		..()
		A = null

	click_mode_right(var/ctrl, var/alt, var/shift)
		if(ctrl)
			cinematic = (input("Cinematic spawn mode") as null|anything in list("Telepad", "Blink", "None", "Fancy and Inefficient yet Laggy Telepad", "Supplydrop", "Supplydrop (no lootbox)")) || cinematic
			return
		if(alt)
			delete_area = !delete_area
			boutput(usr, delete_area ? "<span class='alert'>Now also deleting areas!</span>" : "<span class='alert'>Now not deleting areas!</span>")
			return

		objpath = get_one_match(input("Type path", "Type path", "/obj/closet"), /atom)
		update_button_text(objpath)
		A = null

	proc/mark_corner(atom/object)
		A = get_turf(object)
	var/matrix/mtx = matrix()
	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!objpath)
			boutput(usr, "<span class='alert'>No object path!</span>")
			return
		if (!A)
			mark_corner(object)
		else
			var/turf/B = get_turf(object)
			if (!B || A.z != B.z)
				boutput(usr, "<span class='alert'>Corners must be on the same Z-level!</span>")
				return
			update_button_text("Spawning...")
			var/cnt = 0
			var/area_of_block = (abs(A.x - B.x) * abs(A.y - B.y))
			for (var/turf/Q in block(A,B))
				//var/atom/sp = new objpath(Q)
				//if (isobj(sp) || ismob(sp) || isturf(sp))
					//sp.set_dir(holder.dir)
					//sp.onVarChanged("dir", 2, holder.dir)
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

							var/atom/A = 0
							if(ispath(objpath, /turf))
								A = Q.ReplaceWith(objpath, 0, 0, 1, force=1)
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
							pool(swirl)
							pool(pad)
					if("Fancy and Inefficient yet Laggy Telepad")
						SPAWN_DBG(cnt/10)
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
							sleep(0.7 SECONDS)
							swirl.loc = Q
							flick("portswirl", swirl)

							var/atom/A = 0
							if(ispath(objpath, /turf))
								A = Q.ReplaceWith(objpath, 0, 0, 1, force=1)
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
							pool(swirl)
							pool(pad)

					if("Blink")
						var/atom/A = 0
						if(ispath(objpath, /turf))
							A = Q.ReplaceWith(objpath, 0, 0, 1, force=1)
						else
							A = new objpath(Q)

						if (isobj(A) || ismob(A))
							A.set_dir(holder.dir)
							A.onVarChanged("dir", SOUTH, A.dir)
							blink(Q)
					if("Supplydrop")
						SPAWN_DBG(rand(0, min(area_of_block*5, 200)))
							if (ispath(objpath, /atom/movable))
								new/obj/effect/supplymarker/safe(Q, 3 SECONDS, objpath)
					if("Supplydrop (no lootbox)")
						SPAWN_DBG(rand(0, min(area_of_block*5, 200)))
							if (ispath(objpath, /atom/movable))
								new/obj/effect/supplymarker/safe(Q, 3 SECONDS, objpath, TRUE)
					else
						var/atom/A = 0
						if(ispath(objpath, /turf))
							A = Q.ReplaceWith(objpath, 0, 0, 1, force=1)
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
			update_button_text(objpath)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (!A)
			mark_corner(object)
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, "<span class='alert'>Corners must be on the same Z-level!</span>")
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
