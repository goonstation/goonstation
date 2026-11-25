/datum/element/lifeprocess/sight/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (!target.client)
		return

	var/turf/T = target.eye ? get_turf(target.eye) : get_turf(target)
	var/unrestricted_z = (T && (!isrestrictedz(T.z) || (target.client.adventure_view)))

	// Mutantrace and normal sight.
	target.sight |= SEE_BLACKNESS
	if (!isdead(target))
		target.sight &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)
		target.see_in_dark = SEE_DARK_HUMAN
		target.see_invisible = INVIS_NONE

		if (target.traitHolder?.hasTrait("cateyes") || (target.getStatusDuration("food_cateyes")))
			target.render_special.set_centerlight_icon("cateyes")
		else
			target.render_special.set_centerlight_icon("default")

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			H.mutantrace?.sight_modifier()

			if (isvampire(H) && unrestricted_z && (H.check_vampire_power(1) == 1))
				H.sight |= SEE_MOBS
				H.see_invisible = INVIS_CLOAK

		if (istype(target, /mob/living/critter/flock))
			target.see_invisible = INVIS_FLOCK

	// Dead sight.
	if (unrestricted_z && (isdead(target) || HAS_ATOM_PROPERTY(target, PROP_MOB_XRAYVISION) || HAS_ATOM_PROPERTY(target, PROP_MOB_XRAYVISION_WEAK)))
		target.sight |= (SEE_TURFS | SEE_MOBS | SEE_OBJS)
		target.see_in_dark = SEE_DARK_FULL

		if (target.client.adventure_view)
			target.see_invisible = INVIS_ADVENTURE

		else if(HAS_ATOM_PROPERTY(target, PROP_MOB_XRAYVISION_WEAK))
			target.sight &= ~(SEE_BLACKNESS | SEE_MOBS)

		else
			target.see_invisible = INVIS_MESON

	// Robot sight.
	else if (istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/M = target

		var/invis_level = INVIS_CLOAK
		if (unrestricted_z)
			for (var/obj/item/roboupgrade/visualizer/upgrade in M.upgrades)
				if (upgrade.activated)
					invis_level = INVIS_CONSTRUCTION
					break

		M.see_invisible = invis_level
		M.sight &= ~SEE_OBJS
		M.see_in_dark = SEE_DARK_FULL

	// AI sight.
	else if (istype(target, /mob/living/silicon/ai) || istype(target, /mob/living/silicon/hivebot))
		target.see_invisible = INVIS_CLOAK

	// Ship sight.
	if (istype(target.loc, /obj/machinery/vehicle))
		var/obj/machinery/vehicle/ship = target.loc
		var/obj/item/shipcomponent/sensor/sensors = ship.get_part(POD_PART_SENSORS)

		if (sensors?.active)
			target.sight |= sensors.sight
			target.sight &= ~sensors.antisight
			target.see_in_dark = sensors.see_in_dark

			if (target.client.adventure_view)
				target.see_invisible = INVIS_ADVENTURE
			else
				target.see_invisible = sensors.see_invisible

			if (sensors.centerlight)
				target.render_special.set_centerlight_icon(sensors.centerlight, sensors.centerlight_color)

			return

	// Infrared vision.
	if (target.traitHolder?.hasTrait("infravision") && (target.see_invisible < INVIS_INFRA))
		target.see_invisible = INVIS_INFRA

	// Ghostvision.
	if (HAS_ATOM_PROPERTY(target, PROP_MOB_GHOSTVISION) && unrestricted_z)
		if (target.see_in_dark != 1)
			target.see_in_dark = 1
		if (target.see_invisible < INVIS_GHOST)
			target.see_invisible = INVIS_GHOST

	// Adventure view.
	if (target.client.adventure_view)
		target.see_invisible = INVIS_ADVENTURE

	// Thermal vision II.
	if (HAS_ATOM_PROPERTY(target, PROP_MOB_THERMALVISION_MK2))
		target.sight |= SEE_MOBS
		if (target.see_in_dark < SEE_DARK_FULL)
			target.see_in_dark = SEE_DARK_FULL
		if (target.see_invisible < INVIS_CLOAK)
			target.see_invisible = INVIS_CLOAK
		if (target.see_infrared < 1)
			target.see_infrared = 1

		var/datum/client_image_group/image_group = global.get_image_group(CLIENT_IMAGE_GROUP_MOB_OVERLAY)
		if (!image_group.subscribed_mobs_with_subcount[target])
			image_group.add_mob(target)

		target.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

	else
		var/datum/client_image_group/image_group = get_image_group(CLIENT_IMAGE_GROUP_MOB_OVERLAY)
		if (image_group.subscribed_mobs_with_subcount[target])
			image_group.remove_mob(target)

	// Thermal vision I.
	if (HAS_ATOM_PROPERTY(target, PROP_MOB_THERMALVISION))
		if (target.see_in_dark < target::see_in_dark + 4)
			target.see_in_dark += 4
		if (target.see_invisible < INVIS_CLOAK)
			target.see_invisible = INVIS_CLOAK
		if (target.see_infrared < 1)
			target.see_infrared = 1

		target.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

	// Nightvision.
	if (HAS_ATOM_PROPERTY(target, PROP_MOB_NIGHTVISION))
		target.render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))
	else if (HAS_ATOM_PROPERTY(target, PROP_MOB_NIGHTVISION_WEAK))
		target.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

	// Mesons.
	if (HAS_ATOM_PROPERTY(target, PROP_MOB_MESONVISION))
		if (unrestricted_z)
			target.sight |= SEE_TURFS
			target.sight &= ~SEE_BLACKNESS
		if (target.see_in_dark < target::see_in_dark + 1)
			target.see_in_dark += 1
		if (target.see_invisible < INVIS_MESON)
			target.see_invisible = INVIS_MESON

		target.render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255), wide = (target.client.widescreen))

	// Construction.
	if (istype(astype(target, /mob/living/carbon/human)?.glasses, /obj/item/clothing/glasses/construction) && unrestricted_z)
		if (target.see_in_dark < target::see_in_dark + 1)
			target.see_in_dark += 1
		if (target.see_invisible < INVIS_CONSTRUCTION)
			target.see_invisible = INVIS_CONSTRUCTION
