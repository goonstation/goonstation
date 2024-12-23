/obj/fakeobject/nuclear_reactor_destroyed
	name = "Molten Reactor Core"
	desc = "A molten nuclear reactor core. It's still burning and smoking. Some engineers are gonna get fired for this."
	icon = 'icons/misc/nuclearreactor.dmi'
	icon_state = "reactor_destroyed"
	bound_width = 160
	bound_height = 160
	pixel_x = -64
	pixel_y = -64
	bound_x = -64
	bound_y = -64
	anchored = ANCHORED
	density = TRUE
	mat_changename = FALSE
	dir = EAST
	pixel_point = TRUE
	/// ref to the turf the reactor light is stored on, because you can't center simple lights
	VAR_PRIVATE/turf/_light_turf

	New()
		. = ..()
		src.AddComponent(/datum/component/radioactive, 100, FALSE, FALSE, 5)
		src.UpdateParticles(new/particles/nuke_overheat_smoke(get_turf(src)),"overheat_smoke")
		src._light_turf = get_turf(src)
		src._light_turf.add_medium_light("reactor_destroyed_light", list(255,0,0,255))
		SPAWN(10 SECONDS)
			src.bonus_rads_4_u()

	proc/bonus_rads_4_u()
		var/datum/gas_mixture/current_gas = new/datum/gas_mixture()
		current_gas.radgas += 50
		current_gas.temperature = 1000
		var/turf/current_loc = get_turf(src)
		current_loc.assume_air(current_gas)
		for(var/i = 1 to 5)
			shoot_projectile_XY(src, new /datum/projectile/neutron(100), rand(-10,10), rand(-10,10))

		SPAWN(10 SECONDS)
			src.bonus_rads_4_u()

	ex_act(severity)
		return

	disposing()
		. = ..()
		src._light_turf?.remove_medium_light("reactor_destroyed_light")

/obj/fakeobject/turbine_destroyed
	name = "Destroyed Gas Turbine"
	desc = "A large turbine used for generating power using hot gas. It seems to be utterly destroyed."
	icon = 'icons/obj/large/96x160.dmi'
	icon_state = "ruined"
	anchored = ANCHORED
	density = TRUE
	bound_width = 96
	bound_height = 160
	pixel_x = -32
	pixel_y = -32
	bound_x = -32
	bound_y = -32
	dir = EAST

	ex_act(severity)
		return
