
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

			if (human_owner?.mutantrace)
				human_owner.mutantrace.sight_modifier()
			else
				owner.see_in_dark = SEE_DARK_HUMAN
				owner.see_invisible = 0

			if (owner.client)
				if((owner.traitHolder && owner.traitHolder.hasTrait("cateyes")) || (owner.getStatusDuration("food_cateyes")))
					owner.render_special.set_centerlight_icon("cateyes")
				else
					owner.render_special.set_centerlight_icon("default")

			if (human_owner && isvampire(human_owner))
				if (human_owner.check_vampire_power(1) == 1 && !isrestrictedz(human_owner.z))
					human_owner.sight |= SEE_MOBS
					human_owner.see_invisible = 2

////Dead sight
		var/turf/T = owner.eye ? get_turf(owner.eye) : get_turf(owner) //They might be in a closet or something idk
		if ((isdead(owner) ||( owner.bioHolder && owner.bioHolder.HasEffect("xray"))) && (T && !isrestrictedz(T.z)))
			owner.sight |= SEE_TURFS
			owner.sight |= SEE_MOBS
			owner.sight |= SEE_OBJS
			owner.see_in_dark = SEE_DARK_FULL
			if (owner.client?.adventure_view)
				owner.see_invisible = 21
			else
				owner.see_invisible = 2
		else
			if (robot_owner)
				//var/sight_therm = 0 //todo fix this
				var/sight_meson = 0
				var/sight_constr = 0
				for (var/obj/item/roboupgrade/R in robot_owner.upgrades)
					if (R && istype(R, /obj/item/roboupgrade/visualizer) && R.activated)
						sight_constr = 1
					if (R && istype(R, /obj/item/roboupgrade/opticmeson) && R.activated)
						sight_meson = 1
					//if (R && istype(R, /obj/item/roboupgrade/opticthermal) && R.activated)
					//	sight_therm = 1

				if (sight_meson)
					robot_owner.sight &= ~SEE_BLACKNESS
					robot_owner.sight |= SEE_TURFS
					robot_owner.render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))
					robot_owner.vision.set_scan(1)
					robot_owner.client.color = "#c2ffc2"
				else
					robot_owner.sight |= SEE_BLACKNESS
					robot_owner.sight &= ~SEE_TURFS
					robot_owner.client.color = null
					robot_owner.vision.set_scan(0)
				//if (sight_therm)
				//	src.sight |= SEE_MOBS //todo make borg thermals have a purpose again
				//else
				//	src.sight &= ~SEE_MOBS

				if (sight_constr)
					robot_owner.see_invisible = 9
				else
					robot_owner.see_invisible = 2

				robot_owner.sight &= ~SEE_OBJS
				robot_owner.see_in_dark = SEE_DARK_FULL
////Ship sight
		if (istype(owner.loc, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/ship = owner.loc
			if (ship.sensors)
				if (ship.sensors.active)
					owner.sight |= ship.sensors.sight
					owner.sight &= ~ship.sensors.antisight
					owner.see_in_dark = ship.sensors.see_in_dark
					if (owner.client?.adventure_view)
						owner.see_invisible = 21
					else
						owner.see_invisible = ship.sensors.see_invisible
					if(ship.sensors.centerlight)
						owner.render_special.set_centerlight_icon(ship.sensors.centerlight, ship.sensors.centerlight_color)
					return ..()

		if (owner.traitHolder && owner.traitHolder.hasTrait("infravision"))
			if (owner.see_invisible < 1)
				owner.see_invisible = 1

		if (HAS_MOB_PROPERTY(owner, PROP_GHOSTVISION) && (T && !isrestrictedz(T.z)))
			if (owner.see_in_dark != 1)
				owner.see_in_dark = 1
			if (owner.see_invisible < 15)
				owner.see_invisible = 15

		if (owner.client?.adventure_view)
			owner.see_invisible = 21

		if (HAS_MOB_PROPERTY(owner, PROP_THERMALVISION_MK2))
			owner.sight |= SEE_MOBS //traitor item can see through walls
			owner.sight &= ~SEE_BLACKNESS
			if (owner.see_in_dark < SEE_DARK_FULL)
				owner.see_in_dark = SEE_DARK_FULL
			if (owner.see_invisible < 2)
				owner.see_invisible = 2
			if (owner.see_infrared < 1)
				owner.see_infrared = 1
			owner.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

		if (HAS_MOB_PROPERTY(owner, PROP_THERMALVISION))	//  && (T && !isrestrictedz(T.z))
			// This kinda fucks up the ability to hide things in infra writing in adv zones
			// so away the restricted z check goes.
			// with mobs invisible it shouldn't matter anyway? probably? idk.
			//src.sight |= SEE_MOBS
			if (owner.see_in_dark < initial(owner.see_in_dark) + 4)
				owner.see_in_dark += 4
			if (owner.see_invisible < 2)
				owner.see_invisible = 2
			if (owner.see_infrared < 1)
				owner.see_infrared = 1
			owner.render_special.set_centerlight_icon("thermal", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

		if (HAS_MOB_PROPERTY(owner, PROP_MESONVISION) && (T && !isrestrictedz(T.z)))
			owner.sight |= SEE_TURFS
			owner.sight &= ~SEE_BLACKNESS
			if (owner.see_in_dark < initial(owner.see_in_dark) + 1)
				owner.see_in_dark++
			owner.render_special.set_centerlight_icon("meson", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255), wide = (owner.client?.widescreen))

		if (HAS_MOB_PROPERTY(owner, PROP_NIGHTVISION))
			owner.render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

		if (human_owner)////Glasses handled separately because i dont have a fast way to get glasses on any mob type
			if (istype(human_owner.glasses, /obj/item/clothing/glasses/construction) && (T && !isrestrictedz(T.z)))
				if (human_owner.see_in_dark < initial(human_owner.see_in_dark) + 1)
					human_owner.see_in_dark++
				if (human_owner.see_invisible < 8)
					human_owner.see_invisible = 8
		..()
