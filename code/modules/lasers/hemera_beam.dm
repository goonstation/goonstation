/obj/linked_laser/h7_beam
	name = "energy beam"
	desc = "A rather threatening beam of photons!"
	icon = 'icons/obj/lasers/hemera_beam.dmi'
	icon_state = "h7beam1"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	///How dangerous is this beam, anyhow? 1-5. 1-3 cause minor teleport hops and radiation damage, 4 tends to deposit people in a place separate from their stuff (or organs), and 5 tears their molecules apart
	power = 1
	var/obj/machinery/networked/h7_emitter/master = null
	max_length = 48

/obj/linked_laser/h7_beam/proc/update_master_power()
	var/brightness = min(src.get_power(), 3) / 5
	src.add_simple_light("laser_beam", list(0.28 * 255, 0.07 * 255, 0.58 * 255, brightness * 255))

/obj/linked_laser/h7_beam/get_icon_state()
	return "h7beam[min(round(src.get_power(), 1), 5)]"

/obj/linked_laser/h7_beam/copy_laser(turf/T, dir)
	var/obj/linked_laser/h7_beam/new_laser = ..()
	new_laser.power = src.power
	new_laser.master = src.master
	return new_laser

/obj/linked_laser/h7_beam/try_propagate()
	. = ..()
	src.update_master_power()

/obj/linked_laser/h7_beam/proc/get_power()
	if (src.master)
		src.power = src.master.crystalCount
	return src.power

/obj/linked_laser/h7_beam/disposing()
	if (src.master)
		if (src.master.beam == src)
			src.master.beam = null
		src.master = null
	..()

/obj/linked_laser/h7_beam/proc/telehop(atom/movable/hopAtom as mob|obj, hopOffset=1, varyZ=0)
	var/targetZLevel = hopAtom.z
	if (varyZ)
		targetZLevel = pick(1,3,4,5)

	hopOffset *= 3

	var/turf/lowerLeft = locate( max(hopAtom.x - hopOffset, 1), max(1, hopAtom.y - hopOffset), targetZLevel)
	var/turf/upperRight = locate( min( world.maxx, hopAtom.x + hopOffset), min(world.maxy, hopAtom.y + hopOffset), targetZLevel)

	if (!lowerLeft || !upperRight)
		return

	var/list/hopTurfs = block(lowerLeft, upperRight)
	if (!hopTurfs.len)
		return

	playsound(hopAtom.loc, "warp", 50, 1)
	do_teleport(hopAtom, pick(hopTurfs), 0, 0)
	return

/obj/linked_laser/h7_beam/Crossed(atom/movable/AM)
	. = ..()
	if (QDELETED(src))
		return
	src.hit(AM)

/obj/linked_laser/h7_beam/proc/hit(atom/movable/AM)
	var/power = src.get_power()

	if (isobj(AM) && !istypes(AM, list(/obj/effects, /obj/overlay, /obj/laser_sink, /obj/linked_laser)))
		telehop(AM, power)
		return

	if (!isliving(AM))
		return

	var/mob/living/hitMob = AM
	switch (src.power)
		if (1 to 3)
			hitMob.take_radiation_dose(3 SIEVERTS)
			hitMob.changeStatus("knockdown", 2 SECONDS)
			telehop(hitMob, src.power)
			return

		if (4)
			//big telehop + might leave parts behind.
			hitMob.take_radiation_dose(3 SIEVERTS)

			random_brute_damage(hitMob, 25)
			hitMob.changeStatus("knockdown", 2 SECONDS)
			if (ishuman(hitMob) && prob(15))
				var/mob/living/carbon/human/hitHuman = hitMob
				if (hitHuman.organHolder && hitHuman.organHolder.brain)
					var/obj/item/organ/brain/B = hitHuman.organHolder.drop_organ("Brain", hitHuman.loc)
					telehop(B, 2, 0)
					boutput(hitHuman, SPAN_ALERT("<b>You seem to have left something...behind.</b>"))

			telehop(hitMob, src.power, 1)
			return

		else
			//Are they a human wearing the obsidian crown?
			if (ishuman(hitMob) && istype(hitMob:head, /obj/item/clothing/head/void_crown))
				var/obj/source = locate(/obj/dfissure_from)
				if (!source)
					telehop(AM, 5, 1)
					return

				AM.set_loc(get_turf(source))
				return

			//death!!
			hitMob.vaporize()
			return

/obj/linked_laser/h7_beam/become_endpoint()
	..()
	var/turf/next_turf = get_next_turf()
	for (var/obj/object in next_turf)
		if (src.is_blocking(object))
			src.hit(object)
