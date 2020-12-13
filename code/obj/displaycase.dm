/obj/displaycase
	name = "Display Case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for antique possessions."
	density = 1
	anchored = 1
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
			G.set_loc(src.loc)

			if (occupied)
				new /obj/item/captaingun( src.loc )
				occupied = 0
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()

/obj/displaycase/bullet_act(var/obj/projectile/P)
	var/damage = 0
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)
	if (damage < 1)
		return

	switch(P.proj_data.damage_type)
		if(D_KINETIC)
			src.health -= (damage*2)
		if(D_PIERCING)
			src.health -= (damage/2)
		if(D_ENERGY)
			src.health -= (damage/4)

	src.healthcheck()
	return


/obj/displaycase/blob_act(var/power)
	if (prob(50))
		var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
		G.set_loc(src.loc)
		if (occupied)
			new /obj/item/captaingun( src.loc )
			occupied = 0
		qdel(src)


/obj/displaycase/meteorhit(obj/O as obj)
		var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
		G.set_loc(src.loc)
		new /obj/item/captaingun( src.loc )
		qdel(src)


/obj/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.set_density(0)
			src.destroyed = 1
			var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
			G.set_loc(src.loc)
			playsound(src, "shatter", 70, 1)
			update_icon()
	else
		playsound(src.loc, "sound/impact_sounds/Glass_Hit_1.ogg", 75, 1)
	return

/obj/displaycase/proc/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb[src.occupied]"
	else
		src.icon_state = "glassbox[src.occupied]"
	return


/obj/displaycase/attackby(obj/item/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/displaycase/attack_hand(mob/user as mob)
	if (src.destroyed && src.occupied)
		new /obj/item/captaingun( src.loc )
		boutput(user, "<b>You deactivate the hover field built into the case.</b>")
		src.occupied = 0
		src.add_fingerprint(user)
		update_icon()
		return
	else
		user.visible_message("<span class='alert'>[user] kicks the display case.</span>")
		src.health -= 2
		healthcheck()
		return

// Added a little mini-quest here. Gun can be repaired, and the player will be rewarded for using
// high-quality materials, which will make the weapon more powerful (Convair880).
/obj/item/captaingun
	name = "antique laser gun"
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "caplaser"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "gun"
	force = 1.0
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT
	var/stability = 10

	var/repair_stage = 0
	var/quality_counter = 0 // Simply the sum of all material.quality values of every component.
	var/q_threshold1 = 100 // Decent quality.
	var/q_threshold2 = 200 // Superb quality.

	var/datum/projectile/our_projectile = null
	var/datum/projectile/our_projectile2 = null // Reserved for top-notch replacement parts.
	var/list/our_projectiles = null
	var/obj/item/ammo/power_cell/our_cell = null

	New()
		src.stability = rand(6,20)
		..()
		return

	examine(mob/user)
		. = ..()
		if (user.mind && user.mind.assigned_role == "Captain")
			. += "It's your laser gun! It's really just for show and made of plastic but man it looks cool. Everybody thinks you're awesome, and you know it."
		else
			. += "On closer inspection, it looks like it's just a display model...? What a cheapskate. Fuck our captain."

		if (src.repair_stage > 0)
			switch (src.repair_stage)
				if (1)
					. += "<span class='notice'>The maintenance panel is open, revealing a largely empty circuit board.</span>"
				if (2)
					. += "<span class='notice'>The wiring has been replaced, but there's still an empty spot in the circuit board.</span>"
				if (3)
					. += "<span class='notice'>A new coil has been inserted, but not secured yet.</span>"
				if (4)
					. += "<span class='notice'>The coil has been soldered into place, but there's nothing to focus the laser beam.</span>"
				if (5)
					. += "<span class='notice'>A lens has been installed, but the control circuits aren't set up yet.</span>"
				if (6)
					. += "<span class='notice'>The gun appears to be missing a power cell.</span>"
				if (7)
					. += "<span class='notice'>Power cell installed. The maintenance panel is open.</span>"

	attack()
		..()
		src.stability--
		src.healthcheck(usr)
		return

	proc/healthcheck(mob/user as mob)
		if (!src) return
		if (src.stability <= 0)
			if (user && ismob(user))
				boutput(user, "<span class='alert'>The laser gun snaps in half!</span>")
				user.u_equip(src)
			qdel(src)
		return

	/*
	0 Screwdriver
	1 Cable coil
	2 Small coil
	3 Soldering iron
	4 Lens
	5 Multitool
	6 Power cell
	7 Screwdriver
	*/
	attackby(obj/item/O as obj, mob/user as mob)
		if (isscrewingtool(O))
			if (src.repair_stage == 0)
				user.show_text("You open the maintenance panel.", "blue")
				src.repair_stage = 1

			else if (src.repair_stage == 7)
				user.visible_message("<span class='notice'>[user] finishes repairing the [src.name].</span>", "<span class='notice'>You close the maintenance panel and power up the gun.</span>")

				src.generate_properties(user) // Type of projectile(s) based on material quality.
				var/obj/item/gun/energy/laser_gun/antique/L = new /obj/item/gun/energy/laser_gun/antique(get_turf(user))
				L.current_projectile = new src.our_projectile
				if (!isnull(src.our_projectile2))
					src.our_projectiles = list(new src.our_projectile, new src.our_projectile2)
					L.projectiles = src.our_projectiles
				src.our_cell.set_loc(L)
				L.cell = src.our_cell

				// The man with the golden gun.
				if (src.quality_counter >= src.q_threshold2)
					L.setMaterial(getMaterial("gold"), appearance = 0, setname = 0)
					if (L.material)
						L.material.owner = L
						L.material.triggerOnAdd(L)
						L.name = "show-piece antique laser gun"
						user.unlock_medal("Tinkerer", 1)

				user.u_equip(src)
				user.put_in_hand_or_drop(L)
				qdel(src)
				return

		else if (istype(O, /obj/item/cable_coil))
			if (src.repair_stage == 1)
				var/obj/item/cable_coil/C = O
				if (C.amount >= 10)
					user.show_text("You begin to rewire the gun's circuit board...", "blue")
					if (do_after(user, 3.5 SECONDS))
						user.show_text("You rewire the circuit board.", "blue")
						src.repair_stage = 2
						if (C.material)
							src.quality_counter += C.material.quality
					else
						user.show_text("You were interrupted!", "red")
						return
				else
					user.show_text("You need more wire than that.", "red")
					return

		else if (istype(O, /obj/item/coil/small))
			if (src.repair_stage == 2)
				user.show_text("You begin to install the coil...", "blue")
				if (do_after(user, 3.5 SECONDS))
					user.show_text("You install the coil.", "blue")
					src.repair_stage = 3
					if (O.material)
						src.quality_counter += O.material.quality
					user.u_equip(O)
					qdel(O)
				else
					user.show_text("You were interrupted!", "red")
					return

		else if (istype(O, /obj/item/electronics/soldering))
			if (src.repair_stage == 3)
				user.show_text("You begin to solder the coil into place...", "blue")
				if (do_after(user, 3.5 SECONDS))
					user.show_text("You solder the coil into place.", "blue")
					src.repair_stage = 4
				else
					user.show_text("You were interrupted!", "red")
					return

		else if (istype(O, /obj/item/lens))
			if (src.repair_stage == 4)
				user.show_text("You begin to install the lens...", "blue")
				if (do_after(user, 3.5 SECONDS))
					user.show_text("You install the lens.", "blue")
					src.repair_stage = 5
					if (O.material)
						src.quality_counter += O.material.quality
					user.u_equip(O)
					qdel(O)
				else
					user.show_text("You were interrupted!", "red")
					return

		else if (ispulsingtool(O))
			if (src.repair_stage == 5)
				user.show_text("You initialize the control board.", "blue")
				src.repair_stage = 6

		else if (istype(O, /obj/item/ammo/power_cell))
			if (src.repair_stage == 6)
				var/obj/item/ammo/power_cell/P = O
				user.show_text("You begin to install the power cell...", "blue")
				if (do_after(user, 3.5 SECONDS))
					user.show_text("You install the power cell.", "blue")
					src.repair_stage = 7
					user.u_equip(P)
					P.set_loc(src)
					src.our_cell = P
					if (P.material)
						src.quality_counter += P.material.quality
				else
					user.show_text("You were interrupted!", "red")
					return

		else
			..()

		return

	// Basically determines how powerful the gun will be, based on the quality of the materials used.
	// Code for the energy gun itself can be found in energy.dm.
	//
	// Why isn't there a crappy version (less than 0 quality) here? I don't want to punish the player
	// for investing a bit of time of effort. After all, scanning and mass-producing energy guns is
	// much less of a hassle.
	proc/generate_properties(var/mob/user)
		if (!src) return

		// Nothing special, just a plain old laser.
		if (src.quality_counter < src.q_threshold1)
			src.our_projectile = /datum/projectile/laser
			if (user && ismob(user))
				user.show_text("The [src.name] looks a little worn, but appears to work alright.", "blue")

		// Player put some effort into it, so let's give him something a little more powerful.
		else if (src.quality_counter >= src.q_threshold1 && src.quality_counter < src.q_threshold2)
			if (user && ismob(user))
				user.show_text("The [src.name] seems to work better than expected thanks to above-average replacment parts.", "blue")
			src.our_projectile = /datum/projectile/laser/old

		// Now we're talking about top-notch stuff.
		else if (src.quality_counter >= src.q_threshold2)
			if (user && ismob(user))
				user.show_text("The [src.name]'s high-quality replacement parts fit together perfectly, increasing the gun's output.", "blue")
			src.our_projectile = /datum/projectile/laser/old
			src.our_projectile2 = /datum/projectile/laser/old_burst

		//DEBUG_MESSAGE("[src.name]'s quality_counter: [quality_counter]")
		return
