/*
Singularity behaviors, for all your singularity needs.

This file contains the base type and:
- Normal Singularity
+ Katamari (normal singulo sub-type)
*/

///

#define EVENT_GROWTH 3 //! the rate at which the event proc radius is scaled relative to the radius of the singularity
#define EVENT_MINIMUM 5 //! the base value added to the event proc radius, serves as the radius of a 1x1

ABSTRACT_TYPE(/datum/singularity_behavior/)
/datum/singularity_behavior/
	/// What singularity object is using me?
	var/obj/machinery/the_singularity/singularity
	/// Use the warpy effect from modern singularity. Props to amylizzle!
	var/use_warp_distortion = TRUE
	/// Set this to a valid icon file to override the singularity icon.
	var/special_icon
	/// This will override the singularity icon_state.
	var/special_icon_state

/datum/singularity_behavior/New(var/obj/machinery/the_singularity/owner, var/datum/singularity_behavior/old_type)
	. = ..()
	src.singularity = owner
	if (use_warp_distortion)
		//get all bendy

		var/image/lense = image(icon='icons/effects/overlays/lensing.dmi', icon_state="lensing_med_hole", pixel_x = -208, pixel_y = -208)
		lense.plane = PLANE_DISTORTION
		lense.blend_mode = BLEND_OVERLAY
		lense.appearance_flags = RESET_ALPHA | RESET_COLOR
		src.singularity.UpdateOverlays(lense, "grav_lensing")

/// Called when an explosive is powerful enough to kill the normal singularity
/datum/singularity_behavior/proc/explosive_kill(var/severity, var/last_touched, var/power)
	return

/// Called when the singularity attempts to consume an atom
/datum/singularity_behavior/proc/consume_atom(var/atom/A, no_visuals = FALSE)
	return

/// Called when the singularity is supposed to animate the atom being consumed
/datum/singularity_behavior/proc/animate_consume_atom(var/atom/A)
	return

/// Called when the singularity wants to move it move it
/datum/singularity_behavior/proc/move()
	return

/// Called when the singularity wants to grow
/datum/singularity_behavior/proc/grow(var/severity)
	return

/// Random events the singularity does occasionaly
/datum/singularity_behavior/proc/event()
	return

// qdeling the behavior itself makes it not gc, and to avoid race conditions,
// i'm not nullifying the behavior on the singularity.

/datum/singularity_behavior/disposing()
	src.singularity = null
	. = ..()

/*
========================
== NORMAL SINGULARITY ==
========================
*/

/datum/singularity_behavior/normal
	var/spaget_count = 0

/datum/singularity_behavior/normal/explosive_kill()
	var/turf/T = get_turf(src)
	qdel(src)
	new /obj/bhole(T,rand(100,300))

/datum/singularity_behavior/normal/consume_atom(var/atom/A, no_visuals = FALSE)
	if (!no_visuals)
		src.animate_consume_atom(A)

	var/gain = 0

	if (isliving(A) && !isintangible(A))//if its a mob
		var/mob/living/L = A
		L.set_loc(src.singularity.get_center())
		gain = 20
		if (ishuman(L))
			var/mob/living/carbon/human/H = A
			//Special halloween-time Unkillable gibspam protection!
			if (H.unkillable)
				H.unkillable = 0
			if (H.mind && H.mind.assigned_role)
				logTheThing(LOG_COMBAT, H, "is spaghettified by \the [src.singularity] at [log_loc(src.singularity)].")
				switch (H.mind.assigned_role)
					if ("Clown")
						// Hilarious.
						gain = 500
						grow()
					if ("Lawyer")
						// Satan.
						gain = 250
					if ("Tourist", "Geneticist")
						// Nerds that are oblivious to dangers
						gain = 200
					if ("Chief Engineer")
						// Hubris
						gain = 150
					if ("Engineer")
						// More hubris
						gain = 100
					if ("Staff Assistant", "Captain")
						// Worthless
						gain = 20
					else
						gain = 50

		L.ghostize()
		qdel(L)

	else if (isobj(A))
		//if (istype(A, /obj/item/graviton_grenade))
			//src.singularity.warp = 100
		if (istype(A.material))
			gain += A.material.getProperty("density") * 3 * A.material_amt
			gain += A.material.getProperty("radioactive") * 4 * A.material_amt
			gain += A.material.getProperty("n_radioactive") * 6 * A.material_amt
			if(isitem(A))
				var/obj/item/I = A
				gain *= I.amount

		if (A.reagents)
			gain += min(A.reagents.total_volume/4, 50)

		if (istype(A, /obj/machinery/nuclearbomb))
			gain += 5000 //ten clowns
			playsound_global(clients, 'sound/machines/singulo_start.ogg', 50)
			SPAWN(1 SECOND)
				src.singularity.maxradius += 5
				for (var/i in 1 to 5)
					src.grow()
					sleep(0.5 SECONDS)
			qdel(A)
		else if (istype(A, /obj/item/plutonium_core)) // as a treat
			gain += 5000
			qdel(A)
		else
			var/obj/O = A
			src.singularity.succ_cache[A.type] += 1
			gain += 10/src.singularity.succ_cache[A.type]
			for(var/atom/other_food in A)
				src.consume_atom(other_food, no_visuals = TRUE)
			O.set_loc(src.singularity.get_center())
			O.ex_act(1)
			if (O)
				qdel(O)

	else if (isturf(A))
		var/turf/T = A
		if (T.turf_flags & IS_TYPE_SIMULATED)
			if (istype(T, /turf/simulated/floor))
				T.ReplaceWithSpace()
				gain += 2
			else
				T.ReplaceWithFloor()

	src.singularity.energy += gain

/datum/singularity_behavior/normal/animate_consume_atom(atom/A)
	if(src.spaget_count < 25)
		src.spaget_count++
		var/spaget_time = 15 SECONDS
		var/obj/dummy/spaget_overlay = new()
		spaget_overlay.appearance = A.appearance
		spaget_overlay.appearance_flags = RESET_COLOR | RESET_ALPHA | PIXEL_SCALE
		spaget_overlay.pixel_x = A.pixel_x + (A.x - src.singularity.x + 0.5)*32
		spaget_overlay.pixel_y = A.pixel_y + (A.y - src.singularity.y + 0.5)*32
		spaget_overlay.vis_flags = 0
		spaget_overlay.plane = PLANE_DEFAULT
		spaget_overlay.mouse_opacity = 0
		spaget_overlay.transform = A.transform
		if(prob(0.1)) // easteregg
			spaget_overlay.icon = 'icons/obj/foodNdrink/food_meals.dmi'
			spaget_overlay.icon_state = "spag-dish"
			spaget_overlay.Scale(2, 2)

		var/angle = get_angle(A, src)
		var/matrix/flatten = matrix((A.x - src.singularity.x)*(cos(angle)), 0, -spaget_overlay.pixel_x, (A.y - src.singularity.y)*(sin(angle)), 0, -spaget_overlay.pixel_y)
		animate(spaget_overlay, spaget_time, FALSE, QUAD_EASING, 0, alpha=0, transform=flatten)
		var/obj/dummy/spaget_turner = new()
		spaget_turner.vis_contents += spaget_overlay
		spaget_turner.mouse_opacity = 0
		spaget_turner.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_TOGETHER
		animate_spin(spaget_turner, src.singularity.right_spinning ? "R" : "L", spaget_time / 8 + randfloat(-2, 2), looping=2, parallel=FALSE)
		src.singularity.vis_contents += spaget_turner
		SPAWN(spaget_time + 1 SECOND)
			src.spaget_count--
			qdel(spaget_overlay)
			qdel(spaget_turner)

/datum/singularity_behavior/normal/move()
	// if we're inside something (e.g posessed mob) dont move
	if (!isturf(src.singularity.loc))
		return

	var/dir = pick(cardinal)

	for (var/dist = max(0, src.singularity.radius-1), dist <= src.singularity.radius+1, dist++)
		var/turf/checkloc = get_ranged_target_turf(src.singularity.get_center(), dir, dist)
		if (locate(/obj/machinery/containment_field) in checkloc)
			return

	step(src.singularity, dir)

/datum/singularity_behavior/normal/event()
	var/numb = rand(1,3)
	if(prob(25 / max(src.singularity.radius, 1)))
		grow()
	switch (numb)
		if (1) //Eats the turfs around it
			for (var/mob/living/carbon/M in hearers(src.singularity.radius*EVENT_GROWTH+EVENT_MINIMUM, src.singularity.get_center()))
				M.take_radiation_dose(clamp(0.2 SIEVERTS*(src.singularity.radius+1), 0, 2 SIEVERTS))
				M.show_text("You feel odd.", "red")
			return

		if (2) //tox damage all carbon mobs in area
			for (var/mob/living/carbon/M in hearers(src.singularity.radius*EVENT_GROWTH+EVENT_MINIMUM, src.singularity.get_center()))
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.bioHolder?.HasEffect("blind") || H.blinded)
						return
					else if (istype(H.glasses,/obj/item/clothing/glasses/toggleable/meson))
						M.show_text("You look directly into [src.singularity.name], good thing you had your protective eyewear on!", "green")
						return
					// remaining eye(s) meson cybereyes?
					else if((!H.organHolder?.left_eye || istype(H.organHolder?.left_eye, /obj/item/organ/eye/cyber/meson)) && (!H.organHolder?.right_eye || istype(H.organHolder?.right_eye, /obj/item/organ/eye/cyber/meson)))
						M.show_text("You look directly into [src.singularity.name], good thing your eyes are protected!", "green")
						return
				M.changeStatus("stunned", 7 SECONDS)
				M.visible_message("<span class='alert'><B>[M] stares blankly at [src]!</B></span>",\
				"<B>You look directly into [src]!<br><span class='alert'>You feel weak!</span></B>")
			return

		if (3) //Stun mobs who lack optic scanners
			var/turf/sing_center = src.singularity.get_center()
			for (var/turf/T in orange(src.singularity.radius+EVENT_GROWTH+0.5, sing_center))
				if (prob(70))
					continue

				if (T && !(T.turf_flags & CAN_BE_SPACE_SAMPLE) && (IN_EUCLIDEAN_RANGE(sing_center, T, src.singularity.radius+EVENT_GROWTH+0.5)))
					if (T.turf_flags & IS_TYPE_SIMULATED)
						if (istype(T,/turf/simulated/floor) && !istype(T,/turf/simulated/floor/plating))
							var/turf/simulated/floor/F = T
							if (!F.broken)
								if (prob(80))
									F.break_tile_to_plating()
									if(!F.intact)
										var/obj/item/tile/tile = new(F)
										tile.setMaterial(F.material)
								else
									F.break_tile()
						else if (istype(T, /turf/simulated/wall))
							var/turf/simulated/wall/W = T
							if (istype(W, /turf/simulated/wall/r_wall) || istype(W, /turf/simulated/wall/auto/reinforced))
								new /obj/structure/girder/reinforced(W)
							else
								new /obj/structure/girder(W)
							var/obj/item/sheet/S = new /obj/item/sheet(W)
							if (W.material)
								S.setMaterial(W.material)
							else
								var/datum/material/M = getMaterial("steel")
								S.setMaterial(M)
							W.ReplaceWithFloor()
					else
						T.ReplaceWithFloor()
			return
/*
==================================
=== KATAMARI (Normal sub-type) ===
==================================
*/

/datum/singularity_behavior/normal/katamari_mode
	use_warp_distortion = FALSE // can't see objects stuck on singulo if they're distorted

/datum/singularity_behavior/normal/katamari_mode/animate_consume_atom(var/atom/A)
	var/obj/dummy/kat_overlay = new()
	kat_overlay.appearance = A.appearance
	kat_overlay.appearance_flags = RESET_COLOR | RESET_ALPHA | PIXEL_SCALE | RESET_TRANSFORM
	kat_overlay.pixel_x = 0
	kat_overlay.pixel_y = 0
	kat_overlay.vis_flags = 0
	kat_overlay.plane = PLANE_NOSHADOW_ABOVE
	kat_overlay.layer = src.singularity.layer + rand()
	kat_overlay.mouse_opacity = 0
	kat_overlay.alpha = 64
	var/matrix/tr = new
	tr.Turn(randfloat(0, 360))
	tr.Translate(sqrt(src.singularity.num_absorbed) * 3 + 16 - 16, -16)
	tr.Turn(randfloat(0, 360))
	tr.Translate(-src.singularity.pixel_x, -src.singularity.pixel_y)
	kat_overlay.transform = tr
	src.singularity.underlays += kat_overlay

#undef EVENT_GROWTH
#undef EVENT_MINIMUM
