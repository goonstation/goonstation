/obj/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox0"
	desc = "A display case for antique possessions."
	density = 1
	anchored = ANCHORED
	material_amt = 0.3
	var/health = 30
	var/obj/item/displayed = null // The item held within.
	var/destroyed = 0

	New()
		..()
		if (ispath(src.displayed))
			src.displayed = new src.displayed

		if (displayed)
			displayed.set_loc(src)
			displayed.pixel_x = 0
			displayed.pixel_y = 0
			displayed.transform *= 0.8
			overlays += displayed

/obj/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)

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
		src.health = 0
		src.healthcheck()
		qdel(src)


/obj/displaycase/meteorhit(obj/O as obj)
	src.health = 0
	src.healthcheck()
	qdel(src)


/obj/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.set_density(0)
			src.destroyed = 1
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)
			if (displayed)
				displayed.set_loc(src.loc)
				displayed.transform *= 1.25
				displayed = null
				overlays.Cut()
			desc = "A display case for antique possessions. It has been destroyed."
			playsound(src, "shatter", 70, 1)
			UpdateIcon()
	else
		playsound(src.loc, 'sound/impact_sounds/Glass_Hit_1.ogg', 75, 1)
	return

/obj/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb0"
	else
		src.icon_state = "glassbox0"
	return


/obj/displaycase/attackby(obj/item/W, mob/user)
	if (isscrewingtool(W)) // To bolt to the floor
		if (src.anchored == 0)
			src.anchored = ANCHORED
			playsound(user, 'sound/items/Screwdriver2.ogg', 65, TRUE)
			user.show_message(SPAN_NOTICE("You bolt the display case to the floor."))
		else
			src.anchored = UNANCHORED
			playsound(user, 'sound/items/Screwdriver2.ogg', 65, TRUE)
			user.show_message(SPAN_NOTICE("You unbolt the display case from the floor."))
		return
	else if (iswrenchingtool(W) && destroyed) // To disassemble when broken
		boutput(user, SPAN_NOTICE("You begin to disassemble the broken display case."))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		var/turf/T = user.loc
		sleep(2 SECONDS)
		if ((user.loc == T && user.equipped() == W))
			boutput(user, SPAN_NOTICE("You disassemble the broken display case."))
			qdel(src)
		return
	else if (istype(W, /obj/item/sheet/glass) && destroyed) // To repair when broken
		boutput(user, SPAN_NOTICE("You begin to repair the broken display case."))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		var/turf/T = user.loc
		sleep(1.5 SECONDS)
		if ((user.loc == T && user.equipped() == W))
			user.show_message(SPAN_NOTICE("You fix the broken display case."))
			var/obj/item/sheet/glass/G = W
			G.change_stack_amount(-1)
			src.set_density(1)
			src.destroyed = 0
			src.health = 30
			UpdateIcon()
			desc = "A display case for antique possessions."
		return
	else if (displayed == null && !(destroyed)) // To put items inside when not broken
		if (W.cant_drop)
			boutput(user, SPAN_ALERT("You can't put items that are attached to you in the display case!"))
			return
		if (istype(W, /obj/item/grab))
			boutput(user, SPAN_ALERT("You can't put that in the display case!"))
			return
		user.drop_item()
		displayed = W
		displayed.set_loc(src)
		displayed.pixel_x = 0
		displayed.pixel_y = 0
		displayed.transform *= 0.8
		desc = "A display case for antique possessions. There is \an [displayed.name] inside of it."
		overlays += displayed
		boutput(user, SPAN_NOTICE("You place the [W.name] in the display case."))
	else // When punched
		user.lastattacked = src
		attack_particle(user, src)
		src.health -= W.force
		src.healthcheck()
	..()
	return

/obj/displaycase/attack_hand(mob/user)
	if (user.a_intent == INTENT_HARM)
		user.visible_message(SPAN_ALERT("[user] kicks the display case."))
		user.lastattacked = src
		attack_particle(user, src)
		src.health -= 2
		src.healthcheck()
	..()
	return

// Added a little mini-quest here. Gun can be repaired, and the player will be rewarded for using
// high-quality materials, which will make the weapon more powerful (Convair880).
/obj/item/captaingun
	name = "antique laser gun"
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "caplaser"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "capgun"
	force = 1
	flags =  FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	var/stability = 10

	var/repair_stage = 0
	var/quality_counter = 0 // Simply the sum of all material.getQuality() values of every component.
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
					. += SPAN_NOTICE("The maintenance panel is open, revealing a largely empty circuit board.")
				if (2)
					. += SPAN_NOTICE("The wiring has been replaced, but there's still an empty spot in the circuit board.")
				if (3)
					. += SPAN_NOTICE("A new coil has been inserted, but not secured yet.")
				if (4)
					. += SPAN_NOTICE("The coil has been soldered into place, but there's nothing to focus the laser beam.")
				if (5)
					. += SPAN_NOTICE("A lens has been installed, but the control circuits aren't set up yet.")
				if (6)
					. += SPAN_NOTICE("The gun appears to be missing a power cell.")
				if (7)
					. += SPAN_NOTICE("Power cell installed. The maintenance panel is open.")

	attack()
		..()
		src.stability--
		src.healthcheck(usr)
		return

	proc/healthcheck(mob/user as mob)
		if (!src) return
		if (src.stability <= 0)
			if (user && ismob(user))
				boutput(user, SPAN_ALERT("The laser gun snaps in half!"))
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
	attackby(obj/item/O, mob/user)
		if (isscrewingtool(O))
			if (src.repair_stage == 0)
				user.show_text("You open the maintenance panel.", "blue")
				src.repair_stage = 1

			else if (src.repair_stage == 7)
				user.visible_message(SPAN_NOTICE("[user] finishes repairing the [src.name]."), SPAN_NOTICE("You close the maintenance panel and power up the gun."))

				src.generate_properties(user) // Type of projectile(s) based on material quality.
				var/obj/item/gun/energy/laser_gun/antique/L = new /obj/item/gun/energy/laser_gun/antique(get_turf(user))
				L.set_current_projectile(new src.our_projectile)
				if (!isnull(src.our_projectile2))
					src.our_projectiles = list(new src.our_projectile, new src.our_projectile2)
					L.projectiles = src.our_projectiles
				L.AddComponent(/datum/component/cell_holder, our_cell)
				// The man with the golden gun.
				if (src.quality_counter >= src.q_threshold2)
					L.setMaterial(getMaterial("gold"), appearance = 0, setname = 0)
					if (L.material)
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
					actions.start(new /datum/action/bar/icon/captaingun_assembly(src, C), user)
					return
				else
					user.show_text("You need more wire than that.", "red")
					return

		else if (istype(O, /obj/item/coil/small))
			if (src.repair_stage == 2)
				actions.start(new /datum/action/bar/icon/captaingun_assembly(src, O), user)
				return

		else if (istype(O, /obj/item/electronics/soldering))
			if (src.repair_stage == 3)
				actions.start(new /datum/action/bar/icon/captaingun_assembly(src, O), user)
				return

		else if (istype(O, /obj/item/lens))
			if (src.repair_stage == 4)
				actions.start(new /datum/action/bar/icon/captaingun_assembly(src, O), user)
				return

		else if (ispulsingtool(O))
			if (src.repair_stage == 5)
				user.show_text("You initialize the control board.", "blue")
				src.repair_stage = 6
				return

		else if (istype(O, /obj/item/ammo/power_cell))
			if (src.repair_stage == 6)
				actions.start(new /datum/action/bar/icon/captaingun_assembly(src, O), user)
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
			src.our_projectile = /datum/projectile/laser/glitter
			if (user && ismob(user))
				user.show_text("The [src.name] looks a little worn, but appears to work alright, all things considered.", "blue")

		// Player put some effort into it, so let's give him something a little more powerful.
		else if (src.quality_counter >= src.q_threshold1 && src.quality_counter < src.q_threshold2)
			if (user && ismob(user))
				user.show_text("The [src.name] seems to work better than expected thanks to above-average replacment parts.", "blue")
			src.our_projectile = /datum/projectile/laser

		// Now we're talking about top-notch stuff.
		else if (src.quality_counter >= src.q_threshold2)
			if (user && ismob(user))
				user.show_text("The [src.name]'s high-quality replacement parts fit together perfectly, increasing the gun's output.", "blue")
			src.our_projectile = /datum/projectile/laser
			src.our_projectile2 = /datum/projectile/laser/glitter/burst

		//DEBUG_MESSAGE("[src.name]'s quality_counter: [quality_counter]")
		return

/datum/action/bar/icon/captaingun_assembly
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	duration = 3.5 SECONDS

	var/obj/item/captaingun/gun
	var/obj/item/stage_item

	New(var/obj/item/captaingun/O, var/obj/item/I)
		..()
		if(O)
			src.gun = O
		if(I)
			src.stage_item = I
			src.icon = I.icon
			src.icon_state = I.icon_state

	onUpdate()
		..()
		if(QDELETED(src.gun) || QDELETED(src.stage_item) || BOUNDS_DIST(owner, gun) > 0 || BOUNDS_DIST(owner, src.stage_item) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if(istype(source) && stage_item != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		switch(gun.repair_stage)
			if(1)
				boutput(owner, "<span class='notice'>You begin to rewire the gun's circuit board...</span>")
			if(2)
				boutput(owner, "<span class='notice'>You begin to install the coil...</span>")
			if(3)
				boutput(owner, "<span class='notice'>You begin to solder the coil into place...</span>")
			if(4)
				boutput(owner, "<span class='notice'>You begin to install the lens...</span>")
			if(6)
				boutput(owner, "<span class='notice'>You begin to install the power cell...</span>")

	onEnd()
		..()
		var/mob/user = owner
		switch(gun.repair_stage)
			if(1)
				var/obj/item/cable_coil/coil = src.stage_item
				boutput(owner, "<span class='notice'>You rewire the circuit board.</span>")
				gun.repair_stage = 2
				if(coil.material)
					gun.quality_counter += coil.material.getQuality()
				coil.use(10)
				return
			if(2)
				boutput(owner, "<span class='notice'>You install the coil.</span>")
				gun.repair_stage = 3
				if(stage_item.material)
					gun.quality_counter += stage_item.material.getQuality()
				user.u_equip(src.stage_item)
				qdel(src.stage_item)
				return
			if(3)
				boutput(owner, "<span class='notice'>You solder the coil into place.</span>")
				gun.repair_stage = 4
				return
			if(4)
				boutput(owner, "<span class='notice'>You install the lens.</span>")
				gun.repair_stage = 5
				if(stage_item.material)
					gun.quality_counter += stage_item.material.getQuality()
				user.u_equip(src.stage_item)
				qdel(src.stage_item)
				return
			if(6)
				var/obj/item/ammo/power_cell/cell = src.stage_item
				boutput(owner, "<span class='notice'>You install the power cell.</span>")
				gun.repair_stage = 7
				user.u_equip(cell)
				cell.set_loc(gun)
				gun.our_cell = cell
				if(cell.material)
					gun.quality_counter += cell.material.getQuality()
				return

