/datum/targetable/ai/module/chems
	targeted = TRUE
	target_anything = 1
	var/obj/item/thrown_reagents/reagent_capsule

	cast(atom/target)
		if (..())
			return 1

		if(!ispath(reagent_capsule))
			boutput(holder.owner, SPAN_ALERT("Something appears to be wrong with the chem module... Call 1-800-CODER."))
			return 1

		var/turf/T = get_turf(target)
		for(var/obj/machinery/camera/cam in T.cameras)
			if(!isturf(cam.loc) || !istype_exact(cam,/obj/machinery/camera))
				continue

			if(!can_shoot_to(cam, T, max_length=15))
				continue

			if(!ON_COOLDOWN(cam,"[src.type]", 15 SECONDS))
				var/obj/decal/D = new/obj/decal(cam.loc)

				D.set_dir(get_dir(cam,target))
				D.name = "metal foam spray"
				D.icon = 'icons/obj/chemical.dmi'
				D.icon_state = "chempuff"
				D.layer = EFFECTS_LAYER_BASE

				playsound(cam, 'sound/machines/mixer.ogg', 50, TRUE)

				logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] fires [src.name], creating metal foam at [log_loc(T)].")

				var/obj/foam = new reagent_capsule(get_turf(cam))
				foam.throw_at(target, 10, 1)

				SPAWN(1 SECOND)
					step_towards(D, get_step(D, D.dir))
					cam.visible_message(SPAN_ALERT("[cam] spews out a metalic foam!"))
					sleep(1 SECOND)
					D.dispose()
				return

		boutput(holder.owner, SPAN_ALERT("Unable to calculate valid shot from available camera."))
		return 1

/datum/targetable/ai/module/chems/metal_foam
	name = "Spray Metal Foam"
	desc = "Launches a small stream of metal foam from the camera."
	icon_state = "camera_foam"
	targeted = TRUE
	target_anything = 1
	reagent_capsule = /obj/item/thrown_reagents/metal_foam

/obj/item/thrown_reagents
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ballwhite"
	var/list/reagent_list

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		var/datum/effects/system/foam_spread/s = new()
		s.set_up(5, get_turf(hit_atom), reagent_list, 1) // Aborts if reagent list is null (even for metal foam), but I'm not gonna touch foam_spread.dm (Convair880).
		s.start()
		qdel(src)

/obj/item/thrown_reagents/metal_foam
	color = "#999"
	reagent_list = list("iron" = 3, "fluorosurfactant" = 1, "acid" = 1)
