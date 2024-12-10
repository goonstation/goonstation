
/datum/lifeprocess/sight
	process()
		if (!owner.client) return ..()
		//proc/handle_regular_sight_updates()

////Mutrace and normal sight
		owner.sight |= SEE_BLACKNESS
		if (!isdead(owner))
			owner.sight &= ~SEE_TURFS
			owner.sight &= ~SEE_MOBS
			owner.sight &= ~SEE_OBJS

			owner.see_in_dark = SEE_DARK_HUMAN
			owner.see_invisible = INVIS_NONE

			if (owner.client)
				if((owner.traitHolder && owner.traitHolder.hasTrait("cateyes")) || (owner.getStatusDuration("food_cateyes")))
					owner.render_special.set_centerlight_icon("cateyes")
				else
					owner.render_special.set_centerlight_icon("default")
			if (human_owner?.mutantrace)
				human_owner.mutantrace.sight_modifier()

			if (human_owner && isvampire(human_owner))
				if (human_owner.check_vampire_power(1) == 1 && !isrestrictedz(human_owner.z))
					human_owner.sight |= SEE_MOBS
					human_owner.see_invisible = INVIS_CLOAK

			if (istype(owner, /mob/living/critter/flock))
				owner.see_invisible = INVIS_FLOCK

////Dead sight
		var/turf/T = owner.eye ? get_turf(owner.eye) : get_turf(owner) //They might be in a closet or something idk
		if ((isdead(owner) || HAS_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION) || HAS_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION_WEAK)) && (T && (!isrestrictedz(T.z) || (owner.client?.adventure_view))))
			owner.sight |= SEE_TURFS
			owner.sight |= SEE_MOBS
			owner.sight |= SEE_OBJS
			owner.see_in_dark = SEE_DARK_FULL
			if (owner.client?.adventure_view)
				owner.see_invisible = INVIS_ADVENTURE
			else if(HAS_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION_WEAK))
				owner.sight &= ~SEE_BLACKNESS
				owner.sight &= ~SEE_MOBS
			else
				owner.see_invisible = INVIS_CLOAK
		else
			if (robot_owner)
				//var/sight_therm = 0 //todo fix this
				var/sight_constr = 0
				for (var/obj/item/roboupgrade/R in robot_owner.upgrades)
					if (R && istype(R, /obj/item/roboupgrade/visualizer) && R.activated && (T && !isrestrictedz(T.z)))
						sight_constr = 1
					//if (R && istype(R, /obj/item/roboupgrade/opticthermal) && R.activated)
					//	sight_therm = 1

				//if (sight_therm)
				//	src.sight |= SEE_MOBS //todo make borg thermals have a purpose again
				//else
				//	src.sight &= ~SEE_MOBS

				if (sight_constr)
					robot_owner.see_invisible = INVIS_CONSTRUCTION
				else
					robot_owner.see_invisible = INVIS_CLOAK

				robot_owner.sight &= ~SEE_OBJS
				robot_owner.see_in_dark = SEE_DARK_FULL
			if(hivebot_owner)
				hivebot_owner.see_invisible = INVIS_CLOAK
			if(ai_mainframe_owner)
				ai_mainframe_owner.see_invisible = INVIS_CLOAK
////Ship sight
		if (istype(owner.loc, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/ship = owner.loc
			if (ship.sensors)
				if (ship.sensors.active)
					owner.sight |= ship.sensors.sight
					owner.sight &= ~ship.sensors.antisight
					owner.see_in_dark = ship.sensors.see_in_dark
					if (owner.client?.adventure_view)
						owner.see_invisible = INVIS_ADVENTURE
					else
						owner.see_invisible = ship.sensors.see_invisible
					if(ship.sensors.centerlight)
						owner.render_special.set_centerlight_icon(ship.sensors.centerlight, ship.sensors.centerlight_color)
					return ..()

		if (owner.traitHolder && owner.traitHolder.hasTrait("infravision"))
			if (owner.see_invisible < INVIS_INFRA)
				owner.see_invisible = INVIS_INFRA

		if (HAS_ATOM_PROPERTY(owner, PROP_MOB_GHOSTVISION) && (T && !isrestrictedz(T.z)))
			if (owner.see_in_dark != 1)
				owner.see_in_dark = 1
			if (owner.see_invisible < INVIS_GHOST)
				owner.see_invisible = INVIS_GHOST

		if (owner.client?.adventure_view)
			owner.see_invisible = INVIS_ADVENTURE

		if (HAS_ATOM_PROPERTY(owner, PROP_MOB_THERMALVISION_MK2))
			owner.sight |= SEE_MOBS
			if (owner.see_in_dark < SEE_DARK_FULL)
				owner.see_in_dark = SEE_DARK_FULL
			if (owner.see_invisible < INVIS_CLOAK)
				owner.see_invisible = INVIS_CLOAK
			if (owner.see_infrared < 1)
				owner.see_infrared = 1
			var/datum/client_image_group/image_group = get_image_group(CLIENT_IMAGE_GROUP_MOB_OVERLAY)
			if (!(owner in image_group.subscribed_mobs_with_subcount))
				image_group.add_mob(owner)

			owner.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))
		else
			var/datum/client_image_group/image_group = get_image_group(CLIENT_IMAGE_GROUP_MOB_OVERLAY)
			if (owner in image_group.subscribed_mobs_with_subcount)
				image_group.remove_mob(owner)

		if (HAS_ATOM_PROPERTY(owner, PROP_MOB_THERMALVISION))	//  && (T && !isrestrictedz(T.z))
			// This kinda fucks up the ability to hide things in infra writing in adv zones
			// so away the restricted z check goes.
			// with mobs invisible it shouldn't matter anyway? probably? idk.
			//src.sight |= SEE_MOBS
			if (owner.see_in_dark < initial(owner.see_in_dark) + 4)
				owner.see_in_dark += 4
			if (owner.see_invisible < INVIS_CLOAK)
				owner.see_invisible = INVIS_CLOAK
			if (owner.see_infrared < 1)
				owner.see_infrared = 1
			owner.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))


		if (HAS_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION))
			owner.render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))
		else if (HAS_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION_WEAK))
			owner.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

		if (HAS_ATOM_PROPERTY(owner, PROP_MOB_MESONVISION))
			if(T && !isrestrictedz(T.z))
				owner.sight |= SEE_TURFS
				owner.sight &= ~SEE_BLACKNESS
			if (owner.see_in_dark < initial(owner.see_in_dark) + 1)
				owner.see_in_dark++
			owner.render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255), wide = (owner.client?.widescreen))
			if (owner.see_invisible < INVIS_INFRA)
				owner.see_invisible = INVIS_INFRA

		if (human_owner)////Glasses handled separately because i dont have a fast way to get glasses on any mob type
			if (istype(human_owner.glasses, /obj/item/clothing/glasses/construction) && (T && !isrestrictedz(T.z)))
				if (human_owner.see_in_dark < initial(human_owner.see_in_dark) + 1)
					human_owner.see_in_dark++
				if (human_owner.see_invisible < INVIS_CONSTRUCTION)
					human_owner.see_invisible = INVIS_CONSTRUCTION
		..()
