/obj/decal/fakeobjects/nuclear_reactor_destroyed
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


	New()
		. = ..()
		src.AddComponent(/datum/component/radioactive, 100, FALSE, FALSE, 5)
		src.UpdateParticles(new/particles/nuke_overheat_smoke(get_turf(src)),"overheat_smoke")
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
