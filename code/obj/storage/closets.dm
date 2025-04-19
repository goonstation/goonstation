
TYPEINFO(/obj/storage/closet)
	mat_appearances_to_ignore = list("steel")

/obj/storage/closet
	name = "closet"
	desc = "It's a closet! This one can be opened AND closed."
	object_flags = NO_GHOSTCRITTER
	soundproofing = 3
	can_flip_bust = 1
	p_class = 3
	open_sound = 'sound/misc/locker_open.ogg'
	close_sound = 'sound/misc/locker_close.ogg'
	volume = 70
	_max_health = LOCKER_HEALTH_WEAK
	_health = LOCKER_HEALTH_WEAK
	material_amt = 0.2
	///Will this locker auto-close when someone is flung into it
	var/auto_close = TRUE

	New()
		. = ..()
		START_TRACKING
		src.AddComponent(/datum/component/bullet_holes, 10, 0)

	disposing()
		. = ..()
		STOP_TRACKING

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		if (!P || !istype(P.proj_data,/datum/projectile/))
			return
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		if (damage < 1)
			return

		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				take_damage(damage, P)
			if(D_PIERCING)
				take_damage(damage, P)
			if(D_ENERGY)
				take_damage(damage / 2, P)
		return

	proc/take_damage(var/amount, var/obj/projectile/P)
		if (!P)
			message_admins("P Gone")
			return
		if (!isnum(amount) || amount <= 0)
			return
		src._health -= amount
		if(_health <= 0)
			_health = 0
			if (isnull(P))
				logTheThing(LOG_COMBAT, src, "is hit and broken open by a projectile at [log_loc(src)]. No projectile data.]")
			else
				var/shooter_data = null
				var/vehicle
				if (P.mob_shooter)
					shooter_data = P.mob_shooter
				else if (ismob(P.shooter))
					var/mob/M = P.shooter
					shooter_data = M
				var/obj/machinery/vehicle/V
				if (istype(P.shooter,/obj/machinery/vehicle/))
					V = P.shooter
					if (!shooter_data)
						shooter_data = V.pilot
					vehicle = 1
				if(shooter_data)
					logTheThing(LOG_COMBAT, shooter_data, "[vehicle ? "driving [V.name] " : ""]shoots and breaks open [src] at [log_loc(src)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
				else
					logTheThing(LOG_COMBAT, src, "is hit and broken open by a projectile at [log_loc(src)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
			break_open()

	proc/break_open()
		src.welded = 0
		src.unlock()
		src.open()
		playsound(src.loc, 'sound/impact_sounds/locker_break.ogg', 70, 1)

	Crossed(atom/movable/AM)
		. = ..()
		if (src.auto_close && src.open && ismob(AM) && AM.throwing)
			var/datum/thrown_thing/thr = global.throwing_controller.throws_of_atom(AM)[1]
			AM.throw_impact(src, thr)
			AM.throwing = FALSE
			AM.changeStatus("knockdown", 1 SECOND)
			AM.set_loc(src.loc)
			src.close()

/obj/storage/closet/emergency
	name = "emergency supplies closet"
	desc = "It's a closet! This one can be opened AND closed. Comes prestocked with emergency equipment. <i>Hopefully</i>."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergency-open"

	make_my_stuff() // cogwerks: adjusted probabilities a bit
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(40))
				new /obj/item/storage/toolbox/emergency(src)
			if (prob(33))
				new /obj/item/clothing/suit/space/emerg(src)
				new /obj/item/clothing/head/emerg(src)
			if (prob(10))
				new /obj/item/storage/firstaid/oxygen(src)
			if (prob(10))
				new /obj/item/tank/air(src)
			if (prob(4))
				new /obj/item/tank/oxygen(src)
			if (prob(2))
				new /obj/item/clothing/mask/gas/emergency(src)
			for (var/i=rand(2,3), i>0, i--)
				new /obj/item/tank/pocket/oxygen(src)
				if (prob(40))
					new /obj/item/tank/mini/oxygen(src)
				if (prob(40))
					new /obj/item/clothing/mask/breath(src)

			return 1

/obj/storage/closet/fire
	name = "firefighting supplies closet"
	desc = "It's a closet! This one can be opened AND closed. Comes prestocked with firefighting equipment. <i>Hopefully</i>."
	icon_state = "fire"
	icon_closed = "fire"
	icon_opened = "fire-open"

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(80))
				new /obj/item/extinguisher(src)
			if (prob(50))
				new /obj/item/clothing/head/helmet/firefighter(src)
			if (prob(30))
				new /obj/item/clothing/suit/hazard/fire(src)
				new /obj/item/clothing/mask/gas/emergency(src)
			if (prob(10))
				new /obj/item/storage/firstaid/fire(src)
			if (prob(5))
				new /obj/item/storage/toolbox/emergency(src)
			return 1

/obj/storage/closet/janitor
	name = "custodial supplies closet"
	desc = "It's a closet! This one can be opened AND closed. Comes with janitor's clothes and biohazard gear."
	spawn_contents = list(/obj/item/storage/box/biohazard_bags,
							/obj/item/storage/box/trash_bags = 2,
							/obj/item/clothing/suit/hazard/bio_suit,
							/obj/item/clothing/head/bio_hood,
							/obj/item/device/light/flashlight,
							/obj/item/clothing/shoes/galoshes,
							/obj/item/reagent_containers/glass/bottle/cleaner,
							/obj/item/storage/box/body_bag,
							/obj/item/caution = 6,
							/obj/item/storage/box/clothing/janitor,
							/obj/item/disk/data/floppy/manudrive/cleaner_grenade)

/obj/storage/closet/law
	name = "\improper Legal closet"
	desc = "It's a closet! This one can be opened AND closed. Comes with lawyer apparel and items."
	spawn_contents = list(/obj/item/clothing/under/misc/lawyer/black,
	/obj/item/clothing/under/misc/lawyer/red,
	/obj/item/clothing/under/misc/lawyer,
	/obj/item/clothing/shoes/brown = 2,
	/obj/item/clothing/shoes/black,
	/obj/item/storage/briefcase = 2)

TYPEINFO(/obj/storage/closet/coffin)
	mat_appearances_to_ignore = list("wood")
/obj/storage/closet/coffin
	name = "coffin"
	desc = "A burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin-open"
	layer = 2.5
	icon_welded = "welded-coffin-4dirs"
	open_sound = 'sound/misc/coffin_open.ogg'
	close_sound = 'sound/misc/coffin_close.ogg'
	volume = 70
	auto_close = FALSE

	wood
		icon_closed = "woodcoffin"
		icon_state = "woodcoffin"
		icon_opened = "woodcoffin-open"
		icon_welded = "welded-coffin-1dir"

/obj/storage/closet/biohazard
	name = "\improper Level 3 Biohazard Suit closet"
	desc = "It's a closet! This one can be opened AND closed. Comes prestocked with level 3 biohazard gear for emergencies."
	icon_state = "bio"
	icon_closed = "bio"
	icon_opened = "bio-open"
	spawn_contents = list(/obj/item/storage/box/biohazard_bags,
	/obj/item/clothing/suit/hazard/bio_suit = 2,
	/obj/item/clothing/under/color/white = 2,
	/obj/item/clothing/shoes/white = 2,
	/obj/item/clothing/head/bio_hood = 2)

/obj/storage/closet/syndicate
	name = "gear closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicate-open"

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/storage/closet/syndicate/personal
	desc = "Gear preperations closet."
	spawn_contents = list(
	/obj/item/clothing/mask/breath,
	/obj/item/clothing/under/misc/syndicate,
#if defined(MAP_OVERRIDE_MANTA)
	/obj/item/tank/jetpack/syndicate,
#else
	/obj/item/tank/jetpack,
#endif
	/obj/item/clothing/under/misc/syndicate,
#ifdef XMAS
	/obj/item/clothing/head/helmet/space/santahat/noslow,
	/obj/item/clothing/suit/space/santa/noslow,
#else
	/obj/item/clothing/head/helmet/space/syndicate,
	/obj/item/clothing/suit/space/syndicate,
#endif
	/obj/item/crowbar,
	/obj/item/cell/supercell/charged,
	/obj/item/device/multitool,
	/obj/item/storage/backpack/syndie)

/obj/storage/closet/syndicate/nuclear
	desc = "Nuclear preperations closet."
	spawn_contents = list(/obj/item/storage/box/handcuff_kit,
	/obj/item/storage/box/flashbang_kit,
	/obj/item/pinpointer/nuke = 5,
	/obj/item/device/pda2/syndicate/nuclear)

/obj/storage/closet/syndicate/malf
	desc = "Gear preperations closet."
	spawn_contents = list(/obj/item/tank/jetpack,
	/obj/item/clothing/mask/breath,
	/obj/item/clothing/head/helmet/space/syndicate,
	/obj/item/clothing/suit/space/syndicate,
	/obj/item/crowbar,
	/obj/item/cell,
	/obj/item/device/multitool)

/obj/storage/closet/thunderdome
	name = "\improper Thunderdome closet"
	desc = "Everything you need!"
	anchored = ANCHORED

/* let us never forget this - haine
/obj/closet/thunderdome/New()
	..()
	sleep(0.2 SECONDS)*/

/obj/storage/closet/thunderdome/red
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicate-open"
	spawn_contents = list(/obj/item/clothing/under/jersey/red,
	/obj/item/clothing/under/jersey/red,
	/obj/item/clothing/shoes/black = 2,
	/obj/item/knife/butcher/hunterspear = 2,
	/obj/item/gun/energy/plasma_gun = 2,
	/obj/item/stimpack = 2,
	/obj/item/storage/belt/wrestling = 2,
	/obj/item/storage/box/kendo_box = 1,
	/obj/item/storage/box/kendo_box/hakama = 1)

/obj/storage/closet/thunderdome/green
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1-open"
	spawn_contents = list(/obj/item/clothing/under/jersey/green,
	/obj/item/clothing/under/jersey/green,
	/obj/item/clothing/shoes/black = 2,
	/obj/item/knife/butcher/hunterspear = 2,
	/obj/item/gun/energy/plasma_gun = 2,
	/obj/item/stimpack = 2,
	/obj/item/storage/belt/wrestling = 2,
	/obj/item/storage/box/kendo_box = 1,
	/obj/item/storage/box/kendo_box/hakama = 1)

/obj/storage/closet/electrical_supply
	name = "electrical supplies closet"
	desc = "Everything you would ever need to repair electrical systems. Well, almost."
	spawn_contents = list(/obj/item/storage/toolbox/electrical = 3,
	/obj/item/device/multitool = 3)

/obj/storage/closet/welding_supply
	name = "welding supplies closet"
	desc = "A handy closet full of everything an aspiring apprentice welder could ever need."
	spawn_contents = list(/obj/item/clothing/head/helmet/welding = 3,
	/obj/item/weldingtool = 3)

/obj/storage/closet/wrestling
	name = "wrestling supplies closet"
	desc = "A handy closet full of everything an aspiring fake showboater wrestler needs to launch his career."
	spawn_contents = list(/obj/item/storage/belt/wrestling/fake = 3,
	/obj/item/clothing/under/shorts/random_color = 3,
	/obj/item/clothing/mask/wrestling/black = 1,
	/obj/item/clothing/mask/wrestling/blue = 1,
	/obj/item/clothing/mask/wrestling/green = 1)

/obj/storage/closet/office
	name = "office supply closet"
	desc = "Various supplies for the modern office."
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			var/obj/item/paper_bin/B1 = new /obj/item/paper_bin(src)
			B1.pixel_y = 6
			B1.pixel_x = -5

			var/obj/item/paper_bin/B2 = new /obj/item/paper_bin(src)
			B2.pixel_y = 6
			B2.pixel_x = 5

			new /obj/item/item_box/postit(src)
			new /obj/item/hand_labeler(src)

			var/obj/item/pen/B3 = new /obj/item/pen(src)
			B3.pixel_y = 0
			B3.pixel_x = -4

			var/obj/item/storage/box/marker/B4
			if (prob(66))
				B4 = new /obj/item/storage/box/marker/basic(src)
			else
				B4 = new /obj/item/storage/box/marker(src)
			B4.pixel_y = 0
			B4.pixel_x = 0

			var/obj/item/storage/box/crayon/B5
			if (prob(66))
				B5 = new /obj/item/storage/box/crayon/basic(src)
			else
				B5 = new /obj/item/storage/box/crayon(src)
			B5.pixel_y = 0
			B5.pixel_x = 4

			var/obj/item/staple_gun/red/B6 = new /obj/item/staple_gun/red(src)
			B6.pixel_y = -5
			B6.pixel_x = -4

			var/obj/item/scissors/B7 = new /obj/item/scissors(src)
			B7.pixel_y = -5
			B7.pixel_x = 4

			var/obj/item/stamp/B8 = new /obj/item/stamp(src)
			B8.pixel_y = 6
			B8.pixel_x = 0

			var/obj/item/folder/B9 = new /obj/item/folder(src)
			B9.pixel_y = 0
			B9.pixel_x = 6

			var/obj/item/folder/B10 = new /obj/item/canvas(src)
			B10.pixel_y = 0	// everything else does it i guess
			B10.pixel_x = 0

			return 1

//A closet that traps you when you step onto it!

//A locker that traps folks.  I guess it's haunted.
/obj/storage/closet/haunted
	var/throw_strength = 100
	event_handler_flags = USE_FLUID_ENTER

	New()
		..()
		src.open()
		return

	Crossed(atom/movable/A as mob|obj)
		if (!src.open || src.welded || !isliving(A))
			return ..()

		A.throwing = 0
		A.set_loc(src) //Get them for sure!
		if (!src.close())
			A.set_loc(get_turf(src))//or not, welp
			return

		src.welded = 1
		A.set_loc(src) //Stay in there, jerk!!

		var/mob/living/M = A
		if (!istype(M) || M.loc != src)
			return

		if (M.throwing || istype(A.last_turf, /turf/space) || (M.m_intent != "walk"))
			var/flingdir = turn(get_dir(src.loc, A.last_turf), 180)
			src.throw_at(get_edge_target_turf(src, flingdir), throw_strength, 1)
			return



/obj/storage/closet/mantacontainerred
	name = "shipping container"
	desc = "It's a shipping container, they are frequently used to ship different goods securely across oceans."
	icon = 'icons/obj/large/32x96.dmi'
	icon_state = "mantacontainerleft"
	icon_closed = "mantacontainerleft"
	icon_opened = "mantacontainerleft-open"
	icon_welded = "mantacontainerleft-welded"
	bound_height = 96
	bound_width = 32
	anchored = ANCHORED_ALWAYS

	open(var/entangleLogic, mob/user)
		if (src.open)
			return 0
		if (!src.can_open())
			return 0

		if(entangled && !entangleLogic && !entangled.can_close())
			visible_message(SPAN_ALERT("It won't budge!"))
			return 0

		if(entangled && !entangleLogic)
			entangled.entangled = src
			entangled.close(1)
			contents = entangled.contents


		src.dump_contents()
		src.open = 1
		src.UpdateIcon()
		p_class = initial(p_class)
		playsound(src.loc, 'sound/effects/cargodoor.ogg', 15, 1, -3)
		return 1

	close(var/entangleLogic)
		if (!src.open)
			return 0
		if (!src.can_close())
			return 0

		if(entangled && !entangleLogic && !entangled.can_open())
			visible_message(SPAN_ALERT("It won't budge!"))
			return 0

		src.open = 0

		for (var/obj/O in get_turf(src))
			if (src.is_acceptable_content(O))
				O.set_loc(src)

		for (var/mob/M in get_turf(src))
			if (M.anchored || M.buckled)
				continue
			if (src.is_short && !M.lying)
				step_away(M, src, 1)
				continue
#ifdef HALLOWEEN
			if (halloween_mode && prob(5)) //remove the prob() if you want, it's just a little broken if dudes are constantly teleporting
				var/list/obj/storage/myPals = list()
				for_by_tcl(O, /obj/storage)
					LAGCHECK(LAG_LOW)
					if (O.z != src.z || O.open || !O.can_open())
						continue
					myPals.Add(O)

				var/obj/storage/warp_dest = pick(myPals)
				M.set_loc(warp_dest)
				M.show_text("You are suddenly thrown elsewhere!", "red")
				M.playsound_local(M.loc, "warp", 50, 1)
				continue
#endif
			if (isobserver(M) || iswraith(M) || isintangible(M) || islivingobject(M))
				continue
			if (src.crunches_contents)
				src.crunch(M)
			M.set_loc(src)

		recalcPClass()

		if(entangled && !entangleLogic)
			entangled.entangled = src
			entangled.contents = src.contents
			entangled.open(1)

		src.UpdateIcon()
		playsound(src.loc, 'sound/effects/cargodoor.ogg', 15, 1, -3)
		SEND_SIGNAL(src, COMSIG_OBJ_STORAGE_CLOSED)
		return 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cargotele))
			return

		else if (istype(W, /obj/item/satchel/))
			if(secure && locked)
				user.show_text("Access Denied", "red")
				return
			if (count_turf_items() >= max_capacity || length(contents) >= max_capacity)
				user.show_text("[src] cannot fit any more items!", "red")
				return
			var/amt = length(W.contents)
			if (amt)
				user.visible_message(SPAN_NOTICE("[user] dumps out [W]'s contents into [src]!"))
				var/amtload = 0
				for (var/obj/item/I in W.contents)
					if(length(contents) >= max_capacity)
						break
					if (open)
						I.set_loc(src.loc)
					else
						I.set_loc(src)
					amtload++
				W:UpdateIcon()
				W.tooltip_rebuild = 1
				if (amtload)
					user.show_text("[amtload] [W:itemstring] dumped into [W]!", "blue")
				else
					user.show_text("No [W:itemstring] dumped!", "red")
				return

		if (src.open)
			if (!src.is_short && isweldingtool(W))
				return

			else if (iswrenchingtool(W))
				return

		else if (!src.open && isweldingtool(W))
			if(!W:try_weld(user, 1, burn_eyes = 1))
				return
			if (!src.welded)
				src.weld(1, W, user)
				src.visible_message(SPAN_ALERT("[user] welds [src] closed with [W]."))
			else
				src.weld(0, W, user)
				src.visible_message(SPAN_ALERT("[user] unwelds [src] with [W]."))
			return

		if (src.secure)
			if (src.emagged)
				user.show_text("It appears to be broken.", "red")
				return
			else if (src.personal && istype(W, /obj/item/card/id))
				var/obj/item/card/id/I = W
				if (src.allowed(user) || !src.registered || (istype(W, /obj/item/card/id) && src.registered == I.registered))
					//they can open all lockers, or nobody owns this, or they own this locker
					src.locked = !( src.locked )
					user.visible_message(SPAN_NOTICE("The locker has been [src.locked ? null : "un"]locked by [user]."))
					src.UpdateIcon()
					if (!src.registered)
						src.registered = I.registered
						src.name = "[I.registered]'s [src.name]"
						src.desc = "Owned by [I.registered]."
					for (var/mob/M in src.contents)
						src.log_me(user, M, src.locked ? "locks" : "unlocks")
					return
			else if (!src.personal && src.allowed(user))
				if (!src.open)
					src.locked = !src.locked
					user.visible_message(SPAN_NOTICE("[src] has been [src.locked ? null : "un"]locked by [user]."))
					src.UpdateIcon()
					for (var/mob/M in src.contents)
						src.log_me(user, M, src.locked ? "locks" : "unlocks")
					return
				else
					src.close()
					return

			if (secure != 2)
				user.show_text("Access Denied", "red")
			user.unlock_medal("Rookie Thief", 1)
			return
/*
		else if (issilicon(user))
			if (BOUNDS_DIST(src, user) == 0)
				return src.Attackhand(user)
*/
		else
			return ..()


/obj/storage/closet/mantacontainerred/right
	name = "shipping container"
	desc = "It's a shipping container, they are frequently used to ship different goods securely across oceans."
	icon = 'icons/obj/large/32x96.dmi'
	icon_closed = "mantacontainerright"
	icon_state = "mantacontainerright"
	icon_opened = "mantacontainerright-open"
	icon_welded = "mantacontainerright-welded"
	bound_height = 96
	bound_width = 32
	anchored = ANCHORED_ALWAYS

/obj/storage/closet/radiation
	name = "radiation supplies closet"
	icon = 'icons/obj/large_storage.dmi'
	icon_closed = "radiation"
	icon_state = "radiation"
	icon_opened = "radiation-open"
	desc = "A handy closet full of everything you need to protect yourself from impending doom of radioactive death."
	spawn_contents = list(/obj/item/clothing/suit/hazard/rad = 1,
					/obj/item/clothing/head/rad_hood = 1,
					/obj/item/storage/pill_bottle/antirad = 1,
					/obj/item/clothing/glasses/toggleable/meson = 1,
					/obj/item/reagent_containers/emergency_injector/anti_rad = 1)

/obj/storage/closet/medicalclothes
	name = "medical clothing locker"
	icon = 'icons/obj/large_storage.dmi'
	icon_closed = "red-medical"
	icon_state = "red-medical"
	icon_opened = "open-white"
	desc = "A handy medical locker for storing your doctoring apparel."
	spawn_contents = list(/obj/item/clothing/head/nursehat = 2,
					/obj/item/clothing/head/traditionalnursehat = 2,
					/obj/item/clothing/suit/nursedress = 3,
					/obj/item/clothing/suit/wintercoat/medical = 3,
					/obj/item/clothing/head/headmirror = 3,
					/obj/item/clothing/suit/labcoat = 2)

/obj/storage/closet/command/ruined //replacements for azones and mining level flavor
	name = "Dented command locker"
	desc = "This thing looks ransacked."
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "dented_c"
	icon_closed = "dented_c"
	icon_opened = "dented_c-open"
	spawn_contents = list()

/obj/storage/closet/command/ruined/hos //rejoice HoS players
	name = "Dented Head of Security's locker"
	desc = "A banged up Head of Security locker. Looks like somebody took the law into their own hands."
	spawn_contents = list(/obj/item/clothing/shoes/brown,
	/obj/item/paper/iou)

/obj/storage/closet/mauxite
	desc = "This thing looks pretty robust!"
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "closed$$mauxite"
	default_material = "mauxite"
	uses_default_material_appearance = TRUE
	mat_changename = TRUE
