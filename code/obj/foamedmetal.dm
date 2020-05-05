// wall formed by metal foams
// dense and opaque, but easy to break

/obj/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 0 	// changed in New()
	anchored = 1
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	flags = FPRINT | CONDUCT | USEDELAY
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	var/metal = 1		// 1=aluminium, 2=iron

	New()
		..()

		if(istype(loc, /turf/space))
			loc:ReplaceWithMetalFoam(metal)

		update_nearby_tiles(1)
		SPAWN_DBG(1 DECI SECOND)
			RL_SetOpacity(1)

	disposing()
		RL_SetOpacity(0)
		density = 0
		update_nearby_tiles(1)
		..()

	proc/updateicon()
		if(metal == 1)
			icon_state = "metalfoam"
		else
			icon_state = "ironfoam"


	ex_act(severity)
		dispose()

	blob_act(var/power)
		dispose()

	bullet_act()
		if(metal==1 || prob(50))
			dispose()

	attack_hand(var/mob/user)
		if (user.is_hulk() || (prob(75 - metal*25)))
			user.visible_message("<span style=\"color:red\">[user] smashes through the foamed metal.</span>")
			dispose()
		else
			boutput(user, "<span style=\"color:blue\">You hit the metal foam but bounce off it.</span>")
		return


	attackby(var/obj/item/I, var/mob/user)

		if (istype(I, /obj/item/grab))
			var/obj/item/grab/G = I
			G.affecting.set_loc(src.loc)
			src.visible_message("<span style=\"color:red\">[G.assailant] smashes [G.affecting] through the foamed metal wall.</span>")
			I.dispose()
			dispose()
			return

		if(prob(I.force*20 - metal*25))
			user.visible_message( "<span style=\"color:red\">[user] smashes through the foamed metal.</span>", "<span style=\"color:blue\">You smash through the foamed metal with \the [I].</span>")
			dispose()
		else
			boutput(user, "<span style=\"color:blue\">You hit the metal foam to no effect.</span>")

	// only air group geometry can pass
	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
		return air_group

	proc/update_nearby_tiles(need_rebuild)
		var/turf/simulated/source = loc
		if (istype(source))
			return source.update_nearby_tiles(need_rebuild)

		return 1


