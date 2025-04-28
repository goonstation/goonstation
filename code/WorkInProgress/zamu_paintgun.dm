// painball gun
// it's a gun that shoots paint
/obj/item/gun/paintball
	name = "paintball gun"
	desc = "It's a gun that shoots balls. Balls of paint. Paint balls."
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "gungun"
	item_state = "gungun"
	recoil_enabled = FALSE

	w_class = W_CLASS_NORMAL
	var/obj/item/paint_can/paint_ammo = null
	inventory_counter_enabled = TRUE
	two_handed = TRUE
	can_dual_wield = FALSE

	New()
		set_current_projectile(new /datum/projectile/paintball)
		projectiles = list(current_projectile)
		src.inventory_counter?.update_number(0)
		..()

	examine()
		. = ..()
		if (!src.paint_ammo)
			. += "There is no paint can loaded."
		else
			. += "\A  [src.paint_ammo] (<span style='display: inline-block; height: 1em; width: 1em; border: 1px solid black; background-color: [src.paint_ammo.paint_color];'>&nbsp;</span>) is loaded. It has [src.paint_ammo.uses] use\s left."

	canshoot(mob/user)
		// yes if we have a paint can and paint in it, no otherwise
		return (src.paint_ammo && paint_ammo.uses > 0)

	process_ammo(var/mob/user)
		// basically the same as the above check
		if (src.paint_ammo && src.paint_ammo.uses > 0)
			src.paint_ammo.uses--
			src.inventory_counter?.update_number(src.paint_ammo.uses)
			if (src.paint_ammo.uses <= 0)
				// so that missing the shot doesn't mysteriously not fix the thing
				src.paint_ammo.overlays = null
			return TRUE

		playsound(user, 'sound/weapons/Gunclick.ogg', 60, TRUE)
		return FALSE

	alter_projectile(var/obj/projectile/P)
		. = ..()
		var/datum/projectile/paintball/PB = P.proj_data
		if (istype(PB))
			PB.host_can = src.paint_ammo
			var/list/color_list = hex_to_rgb_list(src.paint_ammo.paint_color)
			// i dont know why this isnt working and i dont care any more.
			// the gun manufactures its own shells for the paint some how ok.
			// and somehow those shells are white instead of paint-colored.
			PB.color_red = color_list[1] / 255
			PB.color_green = color_list[2] / 255
			PB.color_blue = color_list[3] / 255
			P.color = src.paint_ammo.paint_color
			// somehow of all things this works. sure. whatever. perfect.
			// if you figure out how to do it better: please
			src.paint_ammo.paint_thing(P, TRUE, TRUE)

	// remove paint can
	attack_self(mob/user as mob)
		if (src.paint_ammo)
			user.put_in_hand_or_drop(src.paint_ammo)
			boutput(user, SPAN_NOTICE("You remove \the [src.paint_ammo] from \the [src]."))
			playsound(user.loc, 'sound/weapons/gunload_click.ogg', 30, TRUE)
			src.paint_ammo = null
			src.inventory_counter?.update_text("")
		else
			boutput(user, SPAN_ALERT("\The [src] has no paint can loaded!"))


	// swap paint cans
	attackby(obj/item/b, mob/user)

		if(istype(b, /obj/item/paint_can))
			var/obj/item/paint_can/old_can = src.paint_ammo

			// Drop the replacement and put it into the gun,
			// then give them the old can back (if there is one)
			user.u_equip(b)
			b.set_loc(src)
			src.paint_ammo = b
			if (old_can)
				user.put_in_hand_or_drop(old_can)
				boutput(user, SPAN_NOTICE("You swap \the [b] into \the [src]."))
			else
				boutput(user, SPAN_NOTICE("You insert \the [b] into \the [src]."))

			playsound(user.loc, 'sound/weapons/gunload_click.ogg', 60, TRUE)
			src.inventory_counter?.update_number(src.paint_ammo.uses)

			return

		. = ..()



/datum/projectile/paintball
	name = "paintball"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ball_white"
	stun = 0
	cost = 1
	dissipation_rate = 0
	dissipation_delay = 0
	sname = "paintball"
	shot_sound = 'sound/effects/splort.ogg'
	default_firemode = /datum/firemode/single

	damage_type = 0
	hit_ground_chance = 33
	window_pass = 0
	brightness = 1.0
	color_red = 1
	color_green = 1
	color_blue = 1

	disruption = 0
	hits_ghosts = 1 // rule of funny
	max_range = 20

	var/obj/item/paint_can/host_can = null

	on_hit(atom/hit)
		// PAINT THINGS??????
		if (src.host_can)
			src.host_can.paint_thing(hit, TRUE)
