#define TOP_IS_WRONG_CALIBER 1
#define TOP_NOT_FOUND 2

//////////////////////////////// Parent ////////////////////////////
/obj/item/ammo
	name = "ammo"
	var/sname = "Generic Ammo"
	icon = 'icons/obj/items/ammo.dmi'
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "syringe_kit"
	m_amt = 40000
	g_amt = 0
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 20
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	inventory_counter_enabled = 1
	/// What form does this ammo-thing take? Please pick only one!
	/// AMMO_PILE - generic pile of (sometimes assorted) bullets. Slow to load into anything but boxes and other piles
	/// AMMO_CLIP - speedloaders, quick to load other things, but slow to be loaded with bullets
	/// AMMO_MAGAZINE - that are easily swapped out for other mags, but are slow to be loaded or unloaded with bullets
	/// AMMO_BOX - Same as a magazine, but can be loaded by piles and clips easily, and unloaded quickly
	/// AMMO_ENERGY - Is a battery, doesn't hold any mag_contents (usually), and operates using charge
	var/mag_type = AMMO_PILE
	/// What the mag/pile/clip/etc holds. Read by the gun to shoot whatever's in the list
	/// Or also by other mags/piles/clips/etc to see what to swap around
	/// basically a list of new/datum/projectile/thing
	/// usually empty on energy weapons
	var/list/mag_contents = list()
	/// The types and amounts of bullets loaded into the magazine, for easy reference
	/// Is an associated list, bullet.ammo_ID = list("name" = bullet.ammo_name, "type" = bullet.type, "count" = 1)
	var/list/mag_manifest = list()
	/// For piles, its the type of bullet that'll be transferred to a magazine or clip, if applicable
	/// Lets you customize your mags and clips
	var/datum/projectile/top_bullet
	/// index in the mag manifest for the top bullet, so we can cycle through them
	var/top_bullet_index
	/// The magazine is actually a stand-in for a missing magazine.
	var/is_null_mag = FALSE
	/// What to load into the mag/clip/etc on creation. must be some form of /datum/projectile/thing
	/// Loading will cycle through the list
	var/list/ammo_type = list()
	/// Defines what bullets can enter this magazine. Becomes a list, even if its just one thing
	/// largely ignored on piles, they're just a heap of bullets, after all
	var/list/caliber = CALIBER_ANY
	/// What is this loaded into? Mainly for telling the thing its inside to run update_icon when its ready
	var/obj/item/gun/loaded_in = null
	/// Initial load fills magazines to this or max_amount, whichever's less
	var/amount_left = 0.0
	/// How many shots can fit inside the mag/clip/box. Ignored on piles, cus its a pile
	var/max_amount = 1000
	/// For power cells and theoretical mags that also need to be charged for some reason
	var/charge = 100.0
	var/max_charge = 100.0

	// This is needed to avoid duplicating empty magazines (Convair880).
	var/delete_on_reload = 0
	var/force_new_current_projectile = 0 //for custom grenade shells

	var/icon_dynamic = 0 // For dynamic desc and/or icon updates (Convair880).
	var/icon_short = null // If dynamic = 1, the short icon_state has to be specified as well.
	var/icon_empty = null

	var/sound_load = 'sound/weapons/gunload_click.ogg'
	var/unusualCell = 0
	var/self_charging = 0

	New()
		..()
		if(!islist(src.caliber))
			src.caliber = list(src.caliber)
		SPAWN_DBG(2 SECONDS)
			if(!src.disposed)
				load_up_the_magazine()
				make_bullet_manifest()
				src.update_icon() // So we get dynamic updates right off the bat. Screw static descs.
				if(istype(src.loaded_in, /obj/item/gun))
					src.loaded_in.update_icon()
		return

	/// Fills the magazine with whatever's supposed to be in it on spawn
	proc/load_up_the_magazine() // initial mag filler
		if(!src.ammo_type || src.amount_left < 1 || src.max_amount < 1) return
		if(src.mag_contents.len >= 1) return // Something already filled us!
		var/load_this_many = src.amount_left > src.max_amount ? src.max_amount : src.amount_left
		if(!islist(src.ammo_type))
			src.ammo_type = list(src.ammo_type)
		for(var/load_slot in 1 to load_this_many)
			var/load_bullet = src.ammo_type[(load_slot % src.ammo_type.len) + 1]
			if(!ispath(load_bullet, /datum/projectile))
				continue
			src.mag_contents.Add(new load_bullet)

	attack_self(var/mob/user)
		src.cycle_top_bullet(user = user)

	attack_hand(var/mob/user)
		if ((user.r_hand == src || user.l_hand == src))
			src.unload_magazine(user = user)
		else
			..()

	proc/cycle_top_bullet(var/mob/user)
		if(src.mag_type == AMMO_PILE)
			src.update_bullet_manifest()
			if(src.mag_manifest.len < 1)
				boutput(user, "[src] doesn't have anything in it!")
				return
			if(src.mag_manifest.len >= 2 || (src.mag_manifest.len == 1 && !src.top_bullet))
				qdel(src.top_bullet)
				src.top_bullet_index += 1
				if(src.top_bullet_index > src.mag_manifest.len)
					src.top_bullet_index = 1
				var/make_top = src.mag_manifest[src.top_bullet_index]
				make_top = src.mag_manifest[make_top]["type"]
				src.top_bullet = new make_top(src)
				boutput(user, "You fiddle with \the [src] so that [src.top_bullet.ammo_name] will be loaded next.")
			else
				boutput(user, "You notice that no matter how much you fiddle with \the [src], [src.top_bullet.ammo_name] will be loaded next.")

	/// move *into this* magazine/pile/etc, *that* ammo
	proc/load_ammo(var/obj/item/ammo/from_this_mag, var/mob/user)
		if(!user || !from_this_mag) return
		if(!istype(from_this_mag, /obj/item/ammo/))
			boutput(user, "\The [from_this_mag] is busted, call a coder.")
			return FALSE
		else if(from_this_mag.mag_contents.len < 1)
			boutput(user, "\The [from_this_mag] is empty!")
			return FALSE
		else if(src.mag_contents.len >= src.max_amount)
			boutput(user, "\The [src] can't fit anything else in it!")
			return FALSE

		// Pile -> Pile, move the whole amount
		// Pile -> Clip / Mag, move one at a time
		// Pile -> Box, move the whole amount, but only valid bullets (sort first)
		// Mag -> anything, move one at a time
		// Clip -> anything, move the whole amount
		// Box -> anything but pile, don't move anything

		var/top_bullet_ok // mags and clips get the "top" bullet if being loaded by a pile. Boxes and piles do not.
		var/num_to_move
		switch(from_this_mag.mag_type)
			if(AMMO_PILE)
				switch(src.mag_type)
					if(AMMO_MAGAZINE, AMMO_CLIP)
						num_to_move = 1
						top_bullet_ok = 1
					if(AMMO_PILE, AMMO_BOX)
						num_to_move = from_this_mag.mag_contents.len
			if(AMMO_MAGAZINE)
				num_to_move = 1
			if(AMMO_CLIP)
				num_to_move = from_this_mag.mag_contents.len
			if(AMMO_BOX)
				if(src.mag_type == AMMO_PILE)
					num_to_move = from_this_mag.mag_contents.len
		if(num_to_move < 1)
			boutput(user, "You can't move anything from your [from_this_mag] to \the [src] in this form! Try yanking the bullets from one of them first.")
			return FALSE

		var/ammo_wildcard = ((CALIBER_ANY) in src.caliber)
		// Lets stick one specific bullet into the mag/clip, if we're loading a mag or clip
		if(top_bullet_ok && from_this_mag.mag_type == AMMO_PILE && from_this_mag.top_bullet && istype(from_this_mag.top_bullet, /datum/projectile))
			var/failtype = 0
			if((((from_this_mag.top_bullet.caliber) in src.caliber) || ammo_wildcard))
				failtype = TOP_NOT_FOUND // it'll be unset if VV goes correctly
				for(var/datum/projectile/bullet in from_this_mag.mag_contents)
					if(bullet.type == from_this_mag.top_bullet.type)
						src.mag_contents.Insert(1, bullet)
						from_this_mag.mag_contents -= bullet
						boutput(user, "Loaded \the [src] with \a [bullet.ammo_name]!")
						src.update_icon()
						from_this_mag.update_icon()
						failtype = 0
						return TRUE
			else
				failtype = TOP_IS_WRONG_CALIBER
			if(failtype == TOP_IS_WRONG_CALIBER && istype(from_this_mag.top_bullet, /datum/projectile))
				boutput(user, "[from_this_mag.top_bullet] isn't the right caliber for \the [src]. Trying a different kind of ammo.")
			else if(failtype == TOP_NOT_FOUND)
				boutput(user, "Couldn't find \a [from_this_mag.top_bullet] in your [from_this_mag]. Trying a different kind of ammo.")

		// If the above failed, load as normal
		num_to_move = min((src.max_amount - src.mag_contents.len), num_to_move)
		var/amount_to_move = num_to_move
		var/list/temp_mag = list()
		for(var/datum/projectile/bullet in from_this_mag.mag_contents)
			if(ammo_wildcard || (bullet.caliber in src.caliber))
				temp_mag.Insert(1, bullet)
				from_this_mag.mag_contents -= bullet
				amount_to_move--
			if(amount_to_move < 1)
				break

		if(temp_mag.len)
			var/load_results
			load_results = src.make_ammo_string(list_in = src.make_bullet_manifest(temp_mag), mode = "line")
			src.mag_contents.Insert(1, temp_mag)

			if(amount_to_move > 0)
				num_to_move -= amount_to_move

			src.update_bullet_manifest()
			src.update_icon()
			boutput(user, "You load [load_results] into \the [src].")
			if(from_this_mag.mag_contents.len < 1)
				if(from_this_mag.mag_type == AMMO_PILE)
					boutput(user, "That used up the whole pile!")
					user.u_equip(from_this_mag)
					qdel(from_this_mag)
					return TRUE
				else
					boutput(user, "\The [from_this_mag] is now empty!")
			from_this_mag.update_bullet_manifest()
			from_this_mag.update_icon()
			return TRUE
		else
			boutput(user, "You couldn't find anything in [from_this_mag] to fit in [src]")
			return FALSE

	/// Builds a user-readable list or line of whatever's in the supplied mag_manifest
	proc/make_ammo_string(var/list/list_in, var/mode = "list")
		if(!list_in)
			list_in = src.mag_manifest
			if(!list_in.len)
				src.make_bullet_manifest()

		var/list/returnlist = list()
		for (var/I in list_in)
			if(list_in[I]["count"] >= 1)
				returnlist["[list_in[I]["name"]] ([list_in[I]["count"]])"] = I

		switch(mode)
			if("list")
				returnlist = sortList(returnlist)
				return returnlist
			if("line")
				return english_list(returnlist)

	/// Move bullets from this thing to (hopefully) your hand
	proc/unload_magazine(var/count, var/mob/user, var/atom/put_that_here)
		if(!user) return
		if(src.mag_type == AMMO_ENERGY)
			boutput(user, "You can't just just reach into \the [src] and pull out all the electrons and battery juices!")
			return FALSE
		if(src.mag_contents.len < 1)
			boutput(user, "\The [src] is empty.")
			return FALSE

		// Pile, pick a type of bullet, then a number to move, then move that many bullets to a new pile
		// Mag, get the top bullet, move that to a new pile
		// Clip / Box, move all the bullets to a new pile.
		var/what_to_take // entry in mag_manifest
		var/type_to_take // type entry in mag_manifest
		var/num_to_take
		var/just_transfer // if we don't need to do any fancy bullet management that can be handled by transfer

		if (src.mag_type == AMMO_PILE) // aaa
			src.update_bullet_manifest()
			var/list/ammo_contents = src.make_ammo_string() // Thanks, produce satchel!
			if(src.mag_manifest.len == 1) // Only one kind of bullet
				what_to_take = src.mag_manifest[1]
			else
				// should return an entry in src.mag_manifest. it does not.
				what_to_take = ammo_contents[input("Which kind of thing do you want to pick out of the pile?", "Which?", null) as null|anything in ammo_contents]
			if(!what_to_take)
				boutput(user, "Never mind.")
				return FALSE
			else
				//what_to_take = ammo_contents[what_to_take]
				type_to_take = src.mag_manifest[what_to_take]["type"]
				num_to_take = round(input("How many [src.mag_manifest[what_to_take]["name"]] do you want to take?","Max [src.mag_manifest[what_to_take]["count"]]",1) as num|null)
			if(num_to_take < 1)
				boutput(user, "Never mind.")
				return FALSE
			else
				num_to_take = min(src.mag_manifest[what_to_take]["count"], num_to_take)
				boutput(user, "Taking [num_to_take] [src.mag_manifest[what_to_take]["name"]].")
		else
			just_transfer = 1


		if(src.mag_contents.len >= 1 && IN_RANGE(src, user, 1))
			var/obj/item/ammo/bullets/pile/new_pile = new /obj/item/ammo/bullets/pile
			if(put_that_here && isturf(put_that_here) && IN_RANGE(user, put_that_here, 1))
				new_pile.set_loc(put_that_here)
			else
				user.put_in_hand_or_drop(new_pile)
			if(just_transfer)
				new_pile.load_ammo(src, user)
				return TRUE
			else // Only piles from here forward
				for(var/datum/projectile/bullet in src.mag_contents)
					if(istype(bullet, type_to_take))
						new_pile.mag_contents.Insert(1, bullet)
						src.mag_contents -= bullet
						num_to_take--
					if(num_to_take < 1)
						break

				if(src.mag_contents.len < 1)
					boutput(user, "That used up the whole pile!")
					user.u_equip(src)
					qdel(src)
				else
					src.update_bullet_manifest()
					src.update_icon()
				new_pile.update_bullet_manifest()
				new_pile.update_icon()
				return TRUE
		else
			boutput(user, "You're too far from [src] to keep messing with it.")
			return FALSE

	/// Generate an associated list of all the unique bullets and their amounts
	proc/make_bullet_manifest(var/list/other_list)
		var/list/list_to_read
		if(other_list?.len)
			list_to_read = other_list
		else
			list_to_read = src.mag_contents
		if(list_to_read.len < 1) return
		var/list/list_to_write = list()

		for(var/datum/projectile/bullet in list_to_read)
			if(list_to_write.Find(bullet.ammo_ID))
				list_to_write[bullet.ammo_ID]["count"]++
			else
				var/new_bullet = bullet.ammo_ID
				list_to_write.Add(new_bullet)
				list_to_write[new_bullet] = list("name" = bullet.ammo_name, "type" = bullet.type, "count" = 1)
		if(other_list?.len)
			return list_to_write
		else
			src.mag_manifest = list_to_write

	proc/update_bullet_manifest(var/list/bullets, var/mode)
		if(!bullets || !mode)
			make_bullet_manifest() // just go rebuild it
			return
		if(!islist(src.mag_manifest.len))
			src.mag_manifest = list()

		for(var/datum/projectile/bullet in bullets)
			if(src.mag_manifest.Find(bullet.ammo_ID))
				if(mode == "add")
					src.mag_manifest[bullet.ammo_ID]["count"]++
				else
					src.mag_manifest[bullet.ammo_ID]["count"] = max(src.mag_manifest[bullet.ammo_ID]["count"]--, 0)
			else
				if(mode == "add")
					src.mag_manifest.Add((bullet.ammo_ID = list("name" = bullet.ammo_name, "type" = bullet.type, "count" = 1)))
				else
					boutput(world, "Tried to remove something from [src]'s manifest that wasnt there!!")

	// Thanks, material.dm!
	MouseDrop(over_object, src_location, over_location) //src dragged onto over_object
		if (isobserver(usr))
			boutput(usr, "<span class='alert'>Hey! Keep your cold, dead hands off of that!</span>")
			return

		if(!istype(over_object, /obj/screen/hud))
			if (get_dist(usr,src) > 1)
				boutput(usr, "<span class='alert'>You're too far away from [src] to do that.</span>")
				return
			if (get_dist(usr,over_object) > 1)
				boutput(usr, "<span class='alert'>You're too far away from [over_object] to do that.</span>")
				return

		if(isturf(over_object)) // Drag this ammo-thing to that turf? Unload it to there!
			boutput(usr, "Unloading [src] to [over_object] via clickdragon.")
			var/mob/user = usr
			if(src.unload_magazine(user = user, put_that_here = over_object))
				return

		else if(istype(over_object, /obj/item/ammo)) // Drag this ammo-thing to other ammo? Try to merge em!
			boutput(usr, "Transferring [src] to [over_object] via clickdragon.")
			var/obj/item/ammo/A = over_object
			var/mob/user = usr
			if(A.load_ammo(src, user = user))
				return

		else if(istype(over_object, /obj/screen/hud)) // Drag it to an inventory slot? Throw the mag in there
			var/obj/screen/hud/H = over_object
			var/mob/living/carbon/human/dude = usr
			switch(H.id)
				if("lhand")
					if(dude.l_hand && dude.l_hand != src && src.unload_magazine(user = dude))
						return
				if("rhand")
					if(dude.r_hand && dude.r_hand != src && src.unload_magazine(user = dude))
						return
			// can't unload to any other slot until I can figure out how that works
			// till then, mags from two-handed guns go right on the floor where they belong

		return ..()

	attackby(obj/b as obj, mob/user as mob)
		if(istype(b, /obj/item/ammo))
			var/obj/item/ammo/B = b
			load_ammo(B, user = user)
			return
		else if(istype(b, /obj/item/gun) && src.mag_type != AMMO_PILE && src.mag_type != AMMO_CLIP)
			var/obj/item/gun/G = b
			if(G.allowReverseReload)
				G.load_gun(src, user = user)
				return
		/* else if(b.type == src.type)
			var/obj/item/ammo/bullets/A = b
			if(A.amount_left<1)
				user.show_text("There's no ammo left in [A.name].", "red")
				return
			if(src.amount_left>=src.max_amount)
				user.show_text("[src] is full!", "red")
				return

			while ((A.amount_left > 0) && (src.amount_left < src.max_amount))
				A.amount_left--
				src.amount_left++
			if ((A.amount_left < 1) && (src.amount_left < src.max_amount))
				A.update_icon()
				src.update_icon()
				if (A.delete_on_reload)
					qdel(A) // No duplicating empty magazines, please (Convair880).
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>There wasn't enough ammo left in [A.name] to fully refill [src]. It only has [src.amount_left] rounds remaining.</span>")
				return // Couldn't fully reload the gun.
			if ((A.amount_left >= 0) && (src.amount_left == src.max_amount))
				A.update_icon()
				src.update_icon()
				if (A.amount_left == 0)
					if (A.delete_on_reload)
						qdel(A) // No duplicating empty magazines, please (Convair880).
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>You fully refill [src] with ammo from [A.name]. There are [A.amount_left] rounds left in [A.name].</span>")
				return */ // Full reload or ammo left over.
		else return ..()



	proc/update_icon()
		var/num_count = 0
		if(src.charge < 0)
			src.charge = 0
		if (src.amount_left < 0)
			src.amount_left = 0
		if(src.mag_type == AMMO_ENERGY)
			num_count = src.charge
		else
			num_count = src.mag_contents.len
		inventory_counter.update_number(num_count)

	// src.desc = text("There are [] [] bullet\s left!", src.amount_left, (ammo_type.material && istype(ammo_type, /datum/material/metal/silver)))
		src.desc = "There are [num_count] bullet\s left!"
		src.desc += "Contents: [src.make_ammo_string(mode = "line")]"

		if (num_count > 0)
			if (src.icon_dynamic && src.icon_short)
				src.icon_state = text("[src.icon_short]-[num_count]")
			else if(src.icon_empty)
				src.icon_state = initial(src.icon_state)
		else
			if (src.icon_empty)
				src.icon_state = src.icon_empty
		return

	proc/charge(var/amt = 0)
		if (src.charge >= src.max_charge)
			src.charge = src.max_charge
			return FALSE
		else
			if (amt > 0)
				src.charge = min(src.charge + amt, src.max_charge)
				src.update_icon()
				return src.charge < src.max_charge //if we're fully charged, let other things know immediately
			else
				return FALSE


	proc/use(var/amt = 0)
		src.mag_contents.Cut(1,2)
		if(amount_left >= amt)
			amount_left -= amt
			update_icon()
			return 1
		else
			src.update_icon()
			return FALSE
/////////////////////////////// Bullets for kinetic firearms /////////////////////////////////

	// Ammo caliber defines
	// see \_std\defines\item.dm for caliber defines!

/obj/item/ammo/bullets
	name = "Ammo box"
	sname = "Bullets"
	desc = "A box of ammo"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 40000
	g_amt = 0
	ammo_type = /datum/projectile/bullet
	module_research = list("weapons" = 2, "miniaturization" = 5)
	module_research_type = /obj/item/ammo/bullets

/obj/item/ammo/bullets/pile
	name = "Pile of Bullets"
	sname = "Pile"
	desc = "A bunch of ammo."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 40000
	g_amt = 0
	ammo_type = null
	mag_type = AMMO_PILE
	module_research = list("weapons" = 2, "miniaturization" = 5)
	module_research_type = /obj/item/ammo/bullets

/obj/item/ammo/bullets/pile/test
	name = "Pile of Bullets"
	sname = "Pile"
	desc = "A bunch of ammo."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 40000
	g_amt = 0
	amount_left = 25
	max_amount = 50
	ammo_type = /datum/projectile/bullet/revolver_38
	mag_type = AMMO_PILE
	module_research = list("weapons" = 2, "miniaturization" = 5)
	module_research_type = /obj/item/ammo/bullets

/obj/item/ammo/bullets/pile/test2
	name = "Assorted Pile of Bullets"
	sname = "Pile"
	desc = "A bunch of ammo."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 40000
	g_amt = 0
	amount_left = 25
	max_amount = 50
	ammo_type = /datum/projectile/bullet/revolver_38
	mag_type = AMMO_PILE
	module_research = list("weapons" = 2, "miniaturization" = 5)
	module_research_type = /obj/item/ammo/bullets

	New(list/var_override, list/new_mag)
		ammo_type = list()
		var/list/proj_types = concrete_typesof(/datum/projectile, cache=TRUE)
		for(var/i in 1 to amount_left)
			ammo_type.Add(pick(proj_types))
		. = ..()



/obj/item/ammo/bullets/empty
	sname = "Missing detatchable magazine"
	name = "Missing detatchable magazine"
	icon_state = "357-2"
	amount_left = 0
	max_amount = 0
	ammo_type = null
	caliber = null
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"
	is_null_mag = TRUE

/obj/item/ammo/bullets/internal
	sname = "Internal Magazine"
	name = "Internal Magazine"
	icon_state = "357-2"
	amount_left = 0
	max_amount = 0
	ammo_type = null
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/internal/zipgun
	sname = "Metal Pipe"
	name = "Metal Pipe"
	icon_state = "357-2"
	amount_left = 0
	max_amount = 100
	ammo_type = null
	caliber = CALIBER_ANY
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/internal/slamgun
	sname = "Metal Pipe"
	name = "Metal Pipe"
	icon_state = "357-2"
	amount_left = 0
	max_amount = 1
	ammo_type = null
	caliber = CALIBER_SHOTGUN
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/internal/flintlock
	sname = "Barrel"
	name = "Barrel"
	icon_state = "357-2"
	amount_left = 0
	max_amount = 2
	ammo_type = /datum/projectile/bullet/flintlock
	caliber = CALIBER_PISTOL_FLINTLOCK
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/internal/derringer
	sname = "Derringer Chamber"
	name = "Derringer Chamber"
	icon_state = "357-2"
	amount_left = 2
	max_amount = 2
	ammo_type = /datum/projectile/bullet/derringer
	caliber = CALIBER_DERRINGER
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/internal/revolver
	sname = "Revolver Cylinder"
	name = "Revolver Cylinder"
	icon_state = "357-2"
	amount_left = 7
	max_amount = 7
	ammo_type = /datum/projectile/bullet/revolver_38
	caliber = CALIBER_REVOLVER
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"

/obj/item/ammo/bullets/internal/revolver/AP
	ammo_type = /datum/projectile/bullet/revolver_38/AP

/obj/item/ammo/bullets/internal/revolver/stun
	ammo_type = /datum/projectile/bullet/revolver_38/stunners

/obj/item/ammo/bullets/internal/revolver/oldtimey
	ammo_type = /datum/projectile/bullet/revolver_45
	caliber = CALIBER_REVOLVER_OLDTIMEY

/obj/item/ammo/bullets/internal/revolver/magnum
	ammo_type = /datum/projectile/bullet/revolver_357
	caliber = list(CALIBER_REVOLVER, CALIBER_REVOLVER_MAGNUM)

/obj/item/ammo/bullets/internal/revolver/magnum/AP
	ammo_type = /datum/projectile/bullet/revolver_357/AP

/obj/item/ammo/bullets/internal/shotgun
	sname = "Shotgun Tube"
	name = "Shotgun Tube"
	icon_state = "357-2"
	amount_left = 8
	max_amount = 8
	ammo_type = /datum/projectile/bullet/a12
	caliber = CALIBER_SHOTGUN
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"

/obj/item/ammo/bullets/internal/shotgun/weak
	ammo_type = /datum/projectile/bullet/a12/weak

/obj/item/ammo/bullets/internal/shotgun/rubber
	ammo_type = /datum/projectile/bullet/abg

/obj/item/ammo/bullets/internal/shotgun/explosive
	ammo_type = /datum/projectile/bullet/aex

/obj/item/ammo/bullets/internal/shotgun/flare
	sname = "Flare Tube"
	name = "Flare Tube"
	amount_left = 1
	max_amount = 1
	ammo_type = /datum/projectile/bullet/flare

/obj/item/ammo/bullets/internal/launcher
	sname = "Launcher Tube"
	name = "Launcher Tube"
	icon_state = "357-2"
	amount_left = 1
	max_amount = 1
	ammo_type = /datum/projectile/bullet/smoke
	caliber = CALIBER_GRENADE
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"

/obj/item/ammo/bullets/internal/launcher/rpg
	amount_left = 1
	ammo_type = /datum/projectile/bullet/rpg
	caliber = list(CALIBER_RPG, CALIBER_ROCKET)
/obj/item/ammo/bullets/internal/launcher/rpg/unloaded
	amount_left = 0

/obj/item/ammo/bullets/internal/launcher/antisingularity
	amount_left = 0
	ammo_type = /datum/projectile/bullet/antisingularity
	caliber = CALIBER_ROCKET

/obj/item/ammo/bullets/internal/launcher/cat
	ammo_type = /datum/projectile/special/meowitzer
	caliber = CALIBER_CAT

/obj/item/ammo/bullets/internal/launcher/beepsky
	ammo_type = /datum/projectile/special/spawner/beepsky
	caliber = CALIBER_CAT

/obj/item/ammo/bullets/internal/launcher/multi
	sname = "Launcher Cylinder"
	name = "Launcher Cylinder"
	amount_left = 4
	max_amount = 4

/obj/item/ammo/bullets/internal/launcher/multi/explosive
	ammo_type = /datum/projectile/bullet/grenade_round/explosive

/obj/item/ammo/bullets/internal/launcher/multi/derringers
	amount_left = 6
	max_amount = 6
	ammo_type = /datum/projectile/special/spawner/gun
	caliber = CALIBER_WHOLE_DERRINGER

/obj/item/ammo/bullets/derringer
	sname = ".41 RF"
	name = ".41 ammo box"
	icon_state = "357-2"
	amount_left = 2.0
	max_amount = 2.0
	ammo_type = /datum/projectile/bullet/derringer
	caliber = CALIBER_DERRINGER
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"

// /obj/item/ammo/bullets/custom
// 	sname = ".22 LR Custom"
// 	name = "custom .22 ammo box"
// 	icon_state = "custom-8"
// 	amount_left = 8.0
// 	max_amount = 8.0
// 	ammo_type = /datum/projectile/bullet/custom
// 	caliber = CALIBER_PISTOL_SMALL
// 	icon_dynamic = 1
// 	icon_short = "custom"
// 	icon_empty = "custom-0"
// 	mag_type = AMMO_PILE

// 	onMaterialChanged()
// 		src.mag_contents[1].material = copyMaterial(src.material)

// 		if(src.material)
// 			src.mag_contents[1].power = round(material.getProperty("density") / 2.75)
// 			src.mag_contents[1].dissipation_delay = round(material.getProperty("density") / 4)
// 			src.mag_contents[1].ks_ratio = max(0,round(material.getProperty("hard") / 75))

// 			if((src.material.material_flags & MATERIAL_CRYSTAL))
// 				src.mag_contents[1].damage_type = D_PIERCING
// 			if((src.material.material_flags & MATERIAL_METAL))
// 				src.mag_contents[1].damage_type = D_KINETIC
// 			if((src.material.material_flags & MATERIAL_ORGANIC))
// 				src.mag_contents[1].damage_type = D_TOXIC
// 			if((src.material.material_flags & MATERIAL_ENERGY))
// 				src.mag_contents[1].damage_type = D_ENERGY
// 			if((src.material.material_flags & MATERIAL_METAL) && (src.material.material_flags & MATERIAL_CRYSTAL))
// 				src.mag_contents[1].damage_type = D_SLASHING
// 			if((src.material.material_flags & MATERIAL_ENERGY) && (src.material.material_flags & MATERIAL_ORGANIC))
// 				src.mag_contents[1].damage_type = D_BURNING
// 			if((src.material.material_flags & MATERIAL_ENERGY) && (src.material.material_flags & MATERIAL_METAL))
// 				src.mag_contents[1].damage_type = D_RADIOACTIVE

// 		return ..()

/obj/item/ammo/bullets/bullet_22
	sname = ".22 LR"
	name = ".22 magazine"
	icon_state = "pistol_magazine"
	amount_left = 10.0
	max_amount = 10.0
	ammo_type = /datum/projectile/bullet/bullet_22
	caliber = CALIBER_PISTOL_SMALL
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/bullet_22/faith
	amount_left = 4.0
	max_amount = 4.0

/obj/item/ammo/bullets/bullet_22/HP
	sname = ".22 Hollow Point"
	name = ".22 HP magazine"
	icon_state = "pistol_magazine_hp"
	ammo_type = /datum/projectile/bullet/bullet_22/HP

/obj/item/ammo/bullets/a357
	sname = ".357 Mag"
	name = ".357 speedloader"
	icon_state = "38-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = /datum/projectile/bullet/revolver_357
	caliber = CALIBER_REVOLVER_MAGNUM
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"
	mag_type = AMMO_CLIP

/obj/item/ammo/bullets/a357/AP
	sname = ".357 Mag AP"
	name = ".357 AP speedloader"
	icon_state = "38A-7"
	ammo_type = /datum/projectile/bullet/revolver_357/AP
	icon_dynamic = 1
	icon_short = "38A"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a38
	sname = ".38 Spc"
	name = ".38 speedloader"
	icon_state = "38-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = /datum/projectile/bullet/revolver_38
	caliber = CALIBER_REVOLVER
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"
	mag_type = AMMO_CLIP

/obj/item/ammo/bullets/a38/AP
	sname = ".38 Spc AP"
	name = ".38 AP speedloader"
	icon_state = "38A-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = /datum/projectile/bullet/revolver_38/AP
	icon_dynamic = 1
	icon_short = "38A"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a38/stun
	sname = ".38 Spc Stun"
	name = ".38 Stun speedloader"
	icon_state = "38S-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = /datum/projectile/bullet/revolver_38/stunners
	icon_dynamic = 1
	icon_short = "38S"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/c_45
	sname = "Cold .45"
	name = "Colt .45 speedloader"
	icon_state = "38-7"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = /datum/projectile/bullet/revolver_45
	caliber = CALIBER_REVOLVER_OLDTIMEY
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"


/obj/item/ammo/bullets/airzooka
	name = "Airzooka Tactical Replacement Trashbag"
	sname = "air"
	desc = "A tactical trashbag for use in a Donk Co Airzooka."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	icon_state = "trashbag"
	m_amt = 40000
	g_amt = 0
	amount_left = 10
	max_amount = 10
	ammo_type = /datum/projectile/bullet/airzooka
	caliber = CALIBER_TRASHBAG
	mag_type = AMMO_MAGAZINE // ?

/obj/item/ammo/bullets/airzooka/bad
	name = "Airzooka Tactical Replacement Trashbag: Xtreme Edition"
	sname = "air"
	desc = "A tactical trashbag for use in a Donk Co Airzooka, now with plasma lining."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	icon_state = "biobag"
	m_amt = 40000
	g_amt = 0
	amount_left = 10
	max_amount = 10
	ammo_type = /datum/projectile/bullet/airzooka/bad
	caliber = 4.6

/obj/item/ammo/bullets/nine_mm_NATO
	sname = "9mm NATO"
	name = "9mm magazine"
	icon_state = "pistol_clip"	//9mm_clip that exists already. Also, put this in hacked manufacturers cause these bullets are not good.
	amount_left = 18.0
	max_amount = 18.0
	ammo_type = /datum/projectile/bullet/nine_mm_NATO
	caliber = CALIBER_PISTOL
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/nine_mm_NATO/boomerang //empty clip for the clock_188/boomerang
	amount_left = 0

/obj/item/ammo/bullets/a12
	sname = "12ga Buckshot"
	name = "12ga buckshot ammo box"
	ammo_type = /datum/projectile/bullet/a12
	icon_state = "12"
	amount_left = 8.0
	max_amount = 8.0
	caliber = CALIBER_SHOTGUN
	icon_dynamic = 0
	icon_empty = "12-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	weak //for nuke ops engineer
		ammo_type = /datum/projectile/bullet/a12/weak


/obj/item/ammo/bullets/buckshot_burst // real spread shotgun ammo
	sname = "Buckshot"
	name = "buckshot ammo box"
	ammo_type = /datum/projectile/special/spreader/buckshot_burst/
	icon_state = "12"
	amount_left = 8.0
	max_amount = 8.0
	caliber = CALIBER_SHOTGUN
	icon_dynamic = 0
	icon_empty = "12-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/nails // oh god oh fuck
	sname = "Nails"
	name = "nailshot ammo box"
	ammo_type = /datum/projectile/special/spreader/buckshot_burst/nails
	icon_state = "custom-8"
	icon_short = "custom"
	amount_left = 8.0
	max_amount = 8.0
	caliber = CALIBER_SHOTGUN
	icon_dynamic = 1
	icon_empty = "custom-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/aex
	sname = "12ga AEX"
	name = "12ga AEX ammo box"
	ammo_type = /datum/projectile/bullet/aex
	icon_state = "AEX"
	amount_left = 8.0
	max_amount = 8.0
	caliber = CALIBER_SHOTGUN
	icon_dynamic = 0
	icon_empty = "AEX-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/abg
	sname = "12ga Rubber Slug"
	name = "12ga rubber slugs"
	ammo_type = /datum/projectile/bullet/abg
	icon_state = "bg"
	amount_left = 8.0
	max_amount = 8.0
	caliber = CALIBER_SHOTGUN
	icon_dynamic = 0
	icon_empty = "bg-0"
	sound_load = 'sound/weapons/gunload_click.ogg'

/obj/item/ammo/bullets/ak47
	sname = ".308 Auto" // This makes little sense, but they're all chambered in the same caliber, okay (Convair880)?
	name = "AK magazine"
	ammo_type = /datum/projectile/bullet/ak47
	icon_state = "ak47"
	amount_left = 30.0
	max_amount = 30.0
	caliber = CALIBER_RIFLE_HEAVY
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/assault_rifle
	sname = "5.56x45mm NATO"
	name = "STENAG magazine" //heh
	ammo_type = /datum/projectile/bullet/assault_rifle
	icon_state = "stenag_mag"
	amount_left = 30.0
	max_amount = 30.0
	caliber = CALIBER_RIFLE_ASSAULT
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	mag_type = AMMO_MAGAZINE

	armor_piercing
		sname = "5.56x45mm NATO AP"
		name = "AP STENAG magazine"
		ammo_type = /datum/projectile/bullet/assault_rifle/armor_piercing
		icon_state = "stenag_mag-AP"

/obj/item/ammo/bullets/minigun
	sname = "7.62×51mm NATO"
	name = "Minigun cartridge"
	ammo_type = /datum/projectile/bullet/minigun
	icon_state = "40mmR"
	icon_empty = "40mmR-0"
	amount_left = 500.0
	max_amount = 500.0
	caliber = CALIBER_MINIGUN
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	mag_type = AMMO_BOX

/obj/item/ammo/bullets/rifle_3006
	sname = ".308 AP"
	name = ".308 rifle magazine"
	ammo_type = /datum/projectile/bullet/rifle_3006
	icon_state = "rifle_clip"
	amount_left = 4
	max_amount = 4
	caliber = CALIBER_RIFLE_HEAVY
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/rifle_762_NATO
	sname = "7.62×51mm NATO"
	name = "7.62 NATO magazine"
	ammo_type = /datum/projectile/bullet/rifle_762_NATO
	icon_state = "rifle_box_mag" //todo
	amount_left = 4
	max_amount = 4
	caliber = CALIBER_RIFLE_HEAVY
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/tranq_darts
	sname = ".308 Tranquilizer"
	name = ".308 tranquilizer darts"
	ammo_type = /datum/projectile/bullet/tranq_dart
	icon_state = "tranq_clip"
	amount_left = 4
	max_amount = 4
	caliber = CALIBER_RIFLE_HEAVY
	mag_type = AMMO_MAGAZINE

	syndicate
		sname = ".308 Tranquilizer Deluxe"
		ammo_type = /datum/projectile/bullet/tranq_dart/syndicate

		pistol
			sname = ".355 Tranqilizer"
			name = ".355 tranquilizer pistol darts"
			amount_left = 15
			max_amount = 15
			caliber = CALIBER_PISTOL
			ammo_type = /datum/projectile/bullet/tranq_dart/syndicate/pistol

	anti_mutant
		sname = ".308 Mutadone"
		name = ".308 mutadone darts"
		ammo_type = /datum/projectile/bullet/tranq_dart/anti_mutant

/obj/item/ammo/bullets/vbullet
	sname = "VR bullets"
	name = "VR magazine"
	ammo_type = /datum/projectile/bullet/vbullet
	icon_state = "ak47"
	caliber = CALIBER_RIFLE_HEAVY
	amount_left = 200
	mag_type = AMMO_MAGAZINE

/obj/item/ammo/bullets/flare
	sname = "12ga Flare"
	name = "12ga flares"
	amount_left = 8
	max_amount = 8
	icon_state = "12"
	ammo_type = /datum/projectile/bullet/flare
	caliber = CALIBER_SHOTGUN
	icon_dynamic = 0
	icon_empty = "12-0"

	single
		amount_left = 1
		max_amount = 1


/obj/item/ammo/bullets/cannon
	sname = "20mm APHE"
	name = "20mm APHE shells"
	amount_left = 5
	max_amount = 5
	icon_state = "40mmR"
	ammo_type = /datum/projectile/bullet/cannon
	caliber = CALIBER_CANNON
	w_class = 2
	icon_dynamic = 1
	icon_empty = "40mmR-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	single
		amount_left = 1
		max_amount = 1

/obj/item/ammo/bullets/autocannon
	sname = "40mm HE"
	name = "40mm HE shells"
	amount_left = 2
	max_amount = 2
	icon_state = "40mmR"
	ammo_type = /datum/projectile/bullet/autocannon
	caliber = CALIBER_GRENADE
	w_class = 3
	icon_dynamic = 0
	icon_empty = "40mmR-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	single
		amount_left = 1
		max_amount = 1

	seeker
		sname = "40mm HE Seeker"
		name = "40mm HE pod-seeking shells"
		ammo_type = /datum/projectile/bullet/autocannon/seeker/pod_seeking

	knocker
		sname = "40mm HE Knocker"
		name = "40mm HE airlock-breaching shells"
		ammo_type = /datum/projectile/bullet/autocannon/knocker

/obj/item/ammo/bullets/grenade_round
	sname = "40mm HEDP"
	name = "40mm HEDP shells"
	amount_left = 8
	max_amount = 8
	icon_state = "40mmR"
	ammo_type = /datum/projectile/bullet/grenade_round/
	caliber = CALIBER_GRENADE
	w_class = 3
	icon_dynamic = 0
	icon_empty = "40mmR-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	explosive
		desc = "High Explosive Dual Purpose grenade rounds compatible with grenade launchers. Effective against infantry and armour."
		ammo_type = /datum/projectile/bullet/grenade_round/explosive

	high_explosive
		desc = "High Explosive grenade rounds compatible with grenade launchers. Devastatingly effective against infantry targets."
		sname = "40mm HE"
		name = "40mm HE shells"
		icon_state = "AEX"
		icon_empty = "AEX-0"
		ammo_type = /datum/projectile/bullet/grenade_round/high_explosive

/obj/item/ammo/bullets/smoke
	sname = "40mm Smoke"
	name = "40mm smoke shells"
	amount_left = 5
	max_amount = 5
	icon_state = "40mmB"
	ammo_type = /datum/projectile/bullet/smoke
	caliber = CALIBER_GRENADE
	w_class = 3
	icon_dynamic = 0
	icon_empty = "40mmB-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	single
		amount_left = 1
		max_amount = 1

/obj/item/ammo/bullets/pbr
	sname = "40mm Plastic Baton Rounds"
	name = "40mm plastic baton rounds"
	ammo_type = /datum/projectile/bullet/pbr
	amount_left = 2
	max_amount = 2
	icon_state = "40mmB"
	caliber = CALIBER_GRENADE
	w_class = 3
	icon_dynamic = 0
	icon_empty = "40mmB-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

//basically an internal object for converting hand-grenades into shells, but can be spawned independently.
/obj/item/ammo/bullets/grenade_shell
	sname = "40mm Custom Shell"
	name = "40mm hand grenade conversion chamber"
	desc = "A 40mm shell used for converting hand grenades into impact detonation explosive shells"
	amount_left = 1
	max_amount = 1
	icon_state = "paintballr-4"
	ammo_type = /datum/projectile/bullet/grenade_shell
	caliber = CALIBER_GRENADE
	w_class = 3
	icon_dynamic = 0
	icon_empty = "paintballb-4"
	delete_on_reload = 0 //deleting it before the shell can be fired breaks things
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	force_new_current_projectile = 1

	attackby(obj/item/W as obj, mob/living/user as mob)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if(!W || !user)
			return
		if (istype(W, /obj/item/chem_grenade) || istype(W, /obj/item/old_grenade))
			if (AMMO.has_grenade == 0)
				AMMO.load_nade(W)
				user.u_equip(W)
				W.layer = initial(W.layer)
				W.set_loc(src)
				src.update_icon()
				boutput(user, "You load [W] into the [src].")
				return
			else
				boutput(user, "<span class='alert'>For <i>some reason</i>, you are unable to place [W] into an already filled chamber.</span>")
				return
		else
			return ..()

	attack_hand(mob/user as mob)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if(!user)
			return
		if (src.loc == user && AMMO.has_grenade != 0)
			user.put_in_hand_or_drop(AMMO.get_nade())
			AMMO.unload_nade()
			boutput(user, "You pry the grenade out of [src].")
			src.add_fingerprint(user)
			src.update_icon()
			return
		return ..()

	update_icon()
		inventory_counter.update_number(src.amount_left)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if (AMMO.has_grenade != 0)
			src.icon_state = "40mmR"
		else
			src.icon_state = "40mmR-0"



// Ported from old, non-gun RPG-7 object class (Convair880).
/obj/item/ammo/bullets/rpg
	sname = "MPRT rocket"
	name = "MPRT rocket"
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	ammo_type = new /datum/projectile/bullet/rpg
	caliber = CALIBER_ROCKET
	w_class = 3
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/rod
	sname = "metal rod"
	name = "metal rod"
	force = 4
	amount_left = 2
	max_amount = 2
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rod_1"
	ammo_type = /datum/projectile/bullet/rod
	caliber = CALIBER_ROD
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/bullet_9mm
	sname = "9×19mm Parabellum"
	name = "9mm magazine"
	icon_state = "pistol_magazine"
	amount_left = 15.0
	max_amount = 15.0
	ammo_type = /datum/projectile/bullet/bullet_9mm
	caliber = CALIBER_PISTOL
	mag_type = AMMO_MAGAZINE

	smg
		name = "9mm SMG magazine"
		amount_left = 30.0
		max_amount = 30.0
		ammo_type = /datum/projectile/bullet/bullet_9mm/smg

/obj/item/ammo/bullets/lmg
	sname = "7.62×51mm NATO"
	name = "LMG belt"
	ammo_type = /datum/projectile/bullet/lmg
	icon_state = "lmg_ammo"
	icon_empty = "lmg_ammo-0"
	amount_left = 100.0
	max_amount = 100.0
	caliber = CALIBER_RIFLE_HEAVY
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	mag_type = AMMO_BOX

	weak
		sname = "7.62×51mm NATO W"
		name = "discount LMG belt"
		ammo_type = /datum/projectile/bullet/lmg/weak
		amount_left = 25.0
		max_amount = 25.0


//////////////////////////////////// Power cells for eguns //////////////////////////

/obj/item/ammo/power_cell
	name = "Power Cell"
	desc = "A power cell that holds a max of 100PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 10000
	g_amt = 20000
	module_research = list("weapons" = 1, "energy" = 5, "miniaturization" = 5)
	module_research_type = /obj/item/ammo/power_cell
	caliber = CALIBER_BATTERY
	mag_type = AMMO_ENERGY


	onMaterialChanged()
		..()
		if(istype(src.material))
			if(src.material.hasProperty("electrical"))
				max_charge = round(material.getProperty("electrical") ** 1.33)
			else
				max_charge =  40

		charge = max_charge
		return

	New()
		..()
		update_icon()
		desc = "A power cell that holds a max of [src.max_charge]PU. Can be inserted into any energy gun, even tasers!"

	disposing()
		processing_items -= src
		..()

	emp_act()
		src.use(INFINITY)
		return

	update_icon()
		inventory_counter.update_percent(src.charge, src.max_charge)
		if (src.artifact || src.unusualCell) return
		overlays = null
		var/ratio = src.charge / src.max_charge
		ratio = round(ratio, 0.20) * 100
		switch(ratio)
			if(20)
				overlays += "cell_1/5"
			if(40)
				overlays += "cell_2/5"
			if(60)
				overlays += "cell_3/5"
			if(80)
				overlays += "cell_4/5"
			if(100)
				overlays += "cell_5/5"
		return

	examine()
		if (src.artifact)
			return list("You have no idea what this thing is!")
		. = ..()
		if (src.unusualCell)
			return
		. += "There are [src.charge]/[src.max_charge] PU left!"

	use(var/amt = 0)
		if (src.charge <= 0)
			src.charge = 0
			return FALSE
		else
			if (amt > 0)
				src.charge = max(0, src.charge - amt)
				src.update_icon()
				return 1
			else
				return FALSE

	attackby(obj/attacking_item as obj, mob/attacker as mob)
		if(istype(attacking_item, /obj/item/gun/energy))
			var/obj/item/ammo/power_cell/pcell = src
			attacking_item.attackby(pcell, attacker)
		else return ..()

/obj/item/ammo/power_cell/med_power
	name = "Power Cell - 200"
	desc = "A power cell that holds a max of 200PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 15000
	g_amt = 30000
	charge = 200.0
	max_charge = 200.0

/obj/item/ammo/power_cell/med_plus_power
	name = "Power Cell - 250"
	desc = "A power cell that holds a max of 250PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 17500
	g_amt = 35000
	charge = 250.0
	max_charge = 250.0

/obj/item/ammo/power_cell/high_power
	name = "Power Cell - 300"
	desc = "A power cell that holds a max of 300PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 40000
	charge = 300.0
	max_charge = 300.0

/obj/item/ammo/power_cell/self_charging
	name = "Power Cell - Atomic"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 40PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 40.0
	max_charge = 40.0
	var/cycle = 0 //Recharge every other tick.
	var/recharge_rate = 5.0

	onMaterialChanged()
		..()
		if(istype(src.material))
			recharge_rate = 0
			if(src.material.hasProperty("radioactive"))
				recharge_rate += ((src.material.getProperty("radioactive") / 10) / 2.5) //55(cerenkite) should give around 2.2, slightly less than a slow charge cell.
			if(src.material.hasProperty("n_radioactive"))
				recharge_rate += ((src.material.getProperty("n_radioactive") / 10) / 2)
		return

	New()
		processing_items |= src
		..()
		return

	charge(var/amt = 0)
		if (src.charge < src.max_charge)
			processing_items |= src
		return ..()

	use(var/amt = 0)
		processing_items |= src
		return ..()

	process()
		src.cycle = !src.cycle // Charge every four seconds.
		if (src.cycle)
			return

		if(src.material)
			if(src.material.hasProperty("stability"))
				if(src.material.getProperty("stability") <= 50)
					if(prob(max(11 - src.material.getProperty("stability"), 0)))
						var/turf/T = get_turf(src)
						explosion_new(src, T, 1)
						src.visible_message("<span class='alert'>\the [src] detonates.</span>")

		src.charge = min(charge + recharge_rate, max_charge)
		src.update_icon()
		if (src.charge >= src.max_charge)
			processing_items.Remove(src)
		return

/obj/item/ammo/power_cell/self_charging/custom
	name = "Power Cell"
	desc = "A custom-made power cell."

/obj/item/ammo/power_cell/self_charging/med_power
	name = "Power Cell - Blaster Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 200PU."
	charge = 200.0
	max_charge = 200.0

/obj/item/ammo/power_cell/self_charging/slowcharge
	name = "Power Cell - Atomic Slowcharge"
	desc = "A self-contained radioisotope power cell that very slowly recharges an internal capacitor. Holds 40PU."
	recharge_rate = 2.5 // cogwerks: raised from 1.0 because radbows were terrible!!!!!

/obj/item/ammo/power_cell/self_charging/slowcharge/hundred
	name = "Power Cell - Atomic Slowcharge Deluxe"
	desc = "A self-contained radioisotope power cell that very slowly recharges an internal capacitor. Holds 100PU."
	charge = 100.0
	max_charge = 100.0

/obj/item/ammo/power_cell/self_charging/disruptor
	name = "Power Cell - Disruptor Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 100.0
	max_charge = 100.0
	cycle = 0
	recharge_rate = 5.0

/obj/item/ammo/power_cell/self_charging/ntso_baton
	name = "Power Cell - NTSO Stun Baton"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 150.0
	max_charge = 150.0
	cycle = 0
	recharge_rate = 7.5

/obj/item/ammo/power_cell/self_charging/big
	name = "Power Cell - Fusion"
	desc = "A self-contained cold fusion power cell that quickly recharges an internal capacitor. Holds 400PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 400.0
	max_charge = 400.0
	cycle = 0
	recharge_rate = 40.0

/obj/item/ammo/power_cell/self_charging/lawbringer
	name = "Power Cell - Lawbringer Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 300PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 300.0
	max_charge = 300.0
	cycle = 0
	recharge_rate = 10.0

/obj/item/ammo/power_cell/self_charging/howitzer
	name = "Miniaturized SMES"
	desc = "This thing is huge! How did you even lift it put it into the gun?"
	charge = 2500.0
	max_charge = 2500.0

/obj/item/ammo/bullets/flintlock //Flintlock cant be reloaded so this is only for the initial bullet.
	sname = ".58 Flintlock"
	name = ".58 Flintlock"
	ammo_type = /datum/projectile/bullet/flintlock
	icon_state = null
	mag_type = AMMO_PILE
	amount_left = 1
	max_amount = 1
	caliber = CALIBER_PISTOL_FLINTLOCK

/obj/item/ammo/bullets/antisingularity
	sname = "Singularity buster rocket"
	name = "Singularity buster rocket"
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "regularrocket"
	ammo_type = /datum/projectile/bullet/antisingularity
	caliber = CALIBER_ROCKET
	mag_type = AMMO_PILE
	w_class = 3
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/mininuke
	sname = "Miniature nuclear warhead"
	name = "Miniature nuclear warhead"
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "mininuke"
	ammo_type = /datum/projectile/bullet/mininuke
	caliber = CALIBER_ROCKET
	mag_type = AMMO_PILE
	w_class = 3
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/gun
	name = "Briefcase of guns"
	desc = "A briefcase full of guns. It's locked tight..."
	sname = "Guns"
	amount_left = 6
	max_amount = 6
	icon_state = "gungun"
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 20
	mag_type = AMMO_MAGAZINE
	ammo_type = /datum/projectile/special/spawner/gun
	caliber = CALIBER_WHOLE_DERRINGER //idk what caliber to actually make it but apparently its diameter of the tube so i figure it should be 3 inches????
	delete_on_reload = 1

/obj/item/ammo/bullets/meowitzer
	sname = "meowitzer"
	name = "meowitzer"
	desc = "A box containg a single meowitzer. It's shaking violently and feels warm to the touch. You probably don't want to be anywhere near this when it goes off. Wait is that a cat?"
	icon_state = "lmg_ammo"
	icon_empty = "lmg_ammo-0"
	amount_left = 1
	max_amount = 1
	mag_type = AMMO_CLIP
	ammo_type = /datum/projectile/special/meowitzer
	caliber = CALIBER_CAT
	w_class = 3


/obj/item/ammo/bullets/meowitzer/inert
	sname = "inert meowitzer"
	name = "inert meowitzer"
	desc = "A box containg a single inert meowitzer. It appears to be softly purring. Wait is that a cat?"
	ammo_type = /datum/projectile/special/meowitzer/inert


#undef TOP_IS_WRONG_CALIBER
#undef TOP_NOT_FOUND
