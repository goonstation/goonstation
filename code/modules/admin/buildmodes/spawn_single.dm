/datum/buildmode/spawn_single
	name = "Object Spawn"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set object type<br>
Ctrl-RMB on buildmode button = Set cinematic effect<br>

Left Mouse Button on turf/mob/obj      = Place objects<br>
Right Mouse Button                     = Delete objects<br>
Right Mouse Button + Shift             = Set object type to selected mob/obj type<br>
<br>
Use the button in the upper left corner to<br>
change the direction of created objects.<br>
***********************************************************"}
	icon_state = "buildmode2"
	var/objpath = null
	var/cinematic = "Blink"
	var/tmp/matrix/mtx = matrix()
	var/static/list/spawn_types = list(
		"Telepad", \
		"Blink", \
		"Supplydrop", \
		"Supplydrop (no lootbox)", \
		"Lethal Supplydrop", \
		"Lethal Supplydrop (no lootbox)", \
		"Spawn Heavenly", \
		"Spawn Demonically", \
		"Missile", \
		"Pop in", \
		"Beam", \
		"Poof", \
		"None")
	click_mode_right(var/ctrl, var/alt, var/shift)
		if(ctrl)
			cinematic = (input("Cinematic spawn mode") as null|anything in spawn_types) || cinematic
			return
		if (!objpath)
			objpath = /obj/critter/domestic_bee/heisenbee
		objpath = get_one_match(input("Type path", "Type path", "[objpath]"), /atom)
		update_button_text(objpath)

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!objpath)
			boutput(usr, "<span class='alert'>No object path!</span>")
			return
		var/turf/T = get_turf(object)
		if(!isnull(T) && objpath)
			switch(cinematic)
				if("Telepad")
					var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl
					var/obj/decal/fakeobjects/teleport_pad/pad = new /obj/decal/fakeobjects/teleport_pad
					swirl.mouse_opacity = 0
					pad.mouse_opacity = 0
					pad.loc = T
					pad.alpha = 0
					mtx.Reset()
					mtx.Translate(0, 64)
					pad.transform = mtx
					animate(pad, alpha = 255, transform = mtx.Reset(), time = 5, easing=SINE_EASING)
					SPAWN(0.7 SECONDS)
						swirl.loc = T
						flick("portswirl", swirl)

						var/atom/A = 0
						if(ispath(objpath, /turf))
							A = T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
						else
							A = new objpath(T)


						if (isobj(A) || ismob(A) || isturf(A))
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
						A = T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						A = new objpath(T)

					if (isobj(A) || ismob(A) || isturf(A))
						A.set_dir(holder.dir)
						A.onVarChanged("dir", SOUTH, A.dir)
						blink(T)
				if("Supplydrop")
					if (ispath(objpath, /atom/movable))
						new/obj/effect/supplymarker/safe(T, 3 SECONDS, objpath)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Supplydrop (no lootbox)")
					if (ispath(objpath, /atom/movable))
						new/obj/effect/supplymarker/safe(T, 3 SECONDS, objpath, TRUE)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Lethal Supplydrop")
					if (ispath(objpath, /atom/movable))
						new/obj/effect/supplymarker(T, 3 SECONDS, objpath)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Lethal Supplydrop (no lootbox)")
					if (ispath(objpath, /atom/movable))
						new/obj/effect/supplymarker(T, 3 SECONDS, objpath, TRUE)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Missile")
					if (ispath(objpath, /atom/movable))
						var/image/marker = image('icons/effects/64x64.dmi', T, "impact_marker")
						marker.pixel_x = -16
						marker.pixel_y = -16
						marker.plane = PLANE_OVERLAY_EFFECTS
						marker.layer = NOLIGHT_EFFECTS_LAYER_BASE
						marker.appearance_flags = RESET_ALPHA | RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART | RESET_TRANSFORM
						marker.alpha = 100
						usr.client.images += marker
						SPAWN(0)
							launch_with_missile(new objpath, T, (holder.dir in cardinal) ? holder.dir : null)
							qdel(marker)
							usr.client.images -= marker
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Spawn Heavenly")
					if (ispath(objpath, /atom/movable))
						var/atom/movable/A = new objpath(T)
						heavenly_spawn(A)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Spawn Demonically")
					if (ispath(objpath, /atom/movable))
						var/atom/movable/A = new objpath(T)
						demonic_spawn(A)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Pop in")
					if (ispath(objpath, /atom/movable))
						var/atom/movable/A = new objpath(T)
						A.Scale(0,0)
						animate(A, transform = matrix(), time = 1 SECOND, easing = ELASTIC_EASING)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Beam")
					if(ispath(objpath, /atom/movable))
						var/atom/movable/AM = new objpath(T)
						spawn_beam(AM)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				if("Poof")
					if(ispath(objpath, /atom/movable))
						new objpath(T)
						var/obj/itemspecialeffect/poof/P = new /obj/itemspecialeffect/poof
						P.setup(T)
						playsound(T, 'sound/effects/poff.ogg', 50, 1, pitch = 1)
					else if(ispath(objpath, /turf))
						T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						new objpath(T)
				else
					var/atom/A = 0
					if(ispath(objpath, /turf))
						A = T.ReplaceWith(objpath, keep_old_material=0, handle_air=0, force=1)
					else
						A = new objpath(T)

					if (isobj(A) || ismob(A) || isturf(A))
						A.set_dir(holder.dir)
						A.onVarChanged("dir", SOUTH, A.dir)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			if (ismob(object) || isobj(object))
				objpath = object.type
				update_button_text(objpath)
		else
			if(isobj(object))
				qdel(object)
