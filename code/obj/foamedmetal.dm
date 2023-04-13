// wall formed by metal foams
// dense and opaque, but easy to break

/obj/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 0 	// changed in New()
	anchored = ANCHORED
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	flags = FPRINT | CONDUCT | USEDELAY
	event_handler_flags = USE_FLUID_ENTER
	var/metal = 1		// 1=aluminium, 2=iron
	gas_impermeable = TRUE

	New()
		..()

		if(istype(loc, /turf/space))
			loc:ReplaceWithMetalFoam(metal)

		update_nearby_tiles(1)
		SPAWN(1 DECI SECOND)
			RL_SetOpacity(1)

	disposing()
		RL_SetOpacity(0)
		density = 0
		update_nearby_tiles(1)
		..()

	update_icon()
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
			user.visible_message("<span class='alert'>[user] smashes through the foamed metal.</span>")
			dispose()
		else
			boutput(user, "<span class='notice'>You hit the metal foam but bounce off it.</span>")
		return


	attackby(var/obj/item/I, var/mob/user)

		if (istype(I, /obj/item/grab))
			var/obj/item/grab/G = I
			G.affecting.set_loc(src.loc)
			src.visible_message("<span class='alert'>[G.assailant] smashes [G.affecting] through the foamed metal wall.</span>")
			I.dispose()
			dispose()
			return

		if(prob(I.force*20 - metal*25))
			user.visible_message( "<span class='alert'>[user] smashes through the foamed metal.</span>", "<span class='notice'>You smash through the foamed metal with \the [I].</span>")
			dispose()
		else
			boutput(user, "<span class='notice'>You hit the metal foam to no effect.</span>")

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		. = ..()
		if (prob((AM.throwforce + thr.bonus_throwforce) * 10 - src.metal * 25))
			AM.visible_message("<span class='alert'>[AM] smashes through the foamed metal.</span>")
			dispose()

	proc/update_nearby_tiles(need_rebuild)
		var/turf/source = src.loc
		if (istype(source))
			return source.update_nearby_tiles(need_rebuild)

		return 1


