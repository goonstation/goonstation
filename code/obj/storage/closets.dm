/obj/storage/closet
	name = "closet"
	desc = "It's a closet! This one can be opened AND closed."
	soundproofing = 3
	can_flip_bust = 1
	p_class = 3

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

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
				if (prob(40))
					new /obj/item/tank/emergency_oxygen(src)
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
			if (prob(30))
				new /obj/item/clothing/suit/fire(src)
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
							/obj/item/clothing/suit/bio_suit,
							/obj/item/clothing/head/bio_hood,
							/obj/item/clothing/under/rank/janitor = 2,
							/obj/item/clothing/shoes/black = 2,
							/obj/item/device/light/flashlight,
							/obj/item/clothing/shoes/galoshes,
							/obj/item/reagent_containers/glass/bottle/cleaner,
							/obj/item/caution = 6,
							/obj/item/clothing/gloves/long)

/obj/storage/closet/law
	name = "\improper Legal closet"
	desc = "It's a closet! This one can be opened AND closed. Comes with lawyer apparel and items."
	spawn_contents = list(/obj/item/clothing/under/misc/lawyer/black,
	/obj/item/clothing/under/misc/lawyer/red,
	/obj/item/clothing/under/misc/lawyer,
	/obj/item/clothing/shoes/brown = 2,
	/obj/item/clothing/shoes/black,
	/obj/item/storage/briefcase = 2)

/obj/storage/closet/coffin
	name = "coffin"
	desc = "A burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin-open"
	layer = 2.2

	wood
		icon_closed = "woodcoffin"
		icon_state = "woodcoffin"
		icon_opened = "woodcoffin-open"

/obj/storage/closet/biohazard
	name = "\improper Level 3 Biohazard Suit closet"
	desc = "It's a closet! This one can be opened AND closed. Comes prestocked with level 3 biohazard gear for emergencies."
	icon_state = "bio"
	icon_closed = "bio"
	icon_opened = "bio-open"
	spawn_contents = list(/obj/item/storage/box/biohazard_bags,
	/obj/item/clothing/suit/bio_suit = 2,
	/obj/item/clothing/under/color/white = 2,
	/obj/item/clothing/shoes/white = 2,
	/obj/item/clothing/head/bio_hood = 2)

/obj/storage/closet/syndicate
	name = "gear closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicate-open"

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
	/obj/item/clothing/head/helmet/space/santahat,
	/obj/item/clothing/suit/space/santa,
#else
	/obj/item/clothing/head/helmet/space/syndicate,
	/obj/item/clothing/suit/space/syndicate,
#endif
	/obj/item/crowbar,
	/obj/item/cell/supercell/charged,
	/obj/item/device/multitool)

/obj/storage/closet/syndicate/nuclear
	desc = "Nuclear preperations closet."
	spawn_contents = list(/obj/item/storage/box/handcuff_kit,
	/obj/item/storage/box/flashbang_kit,
	/obj/item/pinpointer/nuke = 5,
	/obj/item/device/pda2/syndicate)

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
	anchored = 1

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
	/obj/item/knife/butcher/predspear = 2,
	/obj/item/gun/energy/laser_gun/pred = 2,
	/obj/item/stimpack = 2,
	/obj/item/storage/belt/wrestling = 2)

/obj/storage/closet/thunderdome/green
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1-open"
	spawn_contents = list(/obj/item/clothing/under/jersey/green,
	/obj/item/clothing/under/jersey/green,
	/obj/item/clothing/shoes/black = 2,
	/obj/item/knife/butcher/predspear = 2,
	/obj/item/gun/energy/laser_gun/pred = 2,
	/obj/item/stimpack = 2,
	/obj/item/storage/belt/wrestling = 2)

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
	/obj/item/clothing/under/shorts/random = 3,
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

			new /obj/item/postit_stack(src)
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

			return 1

//A closet that traps you when you step onto it!

//A locker that traps folks.  I guess it's haunted.
/obj/storage/closet/haunted
	var/throw_strength = 100
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	New()
		..()
		src.open()
		return

	HasEntered(atom/movable/A as mob|obj, atom/OldLoc)
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

		if (M.throw_count || istype(OldLoc, /turf/space) || (M.m_intent != "walk"))
			var/flingdir = turn(get_dir(src.loc, OldLoc), 180)
			src.throw_at(get_edge_target_turf(src, flingdir), throw_strength, 1)
			return



/obj/storage/closet/mantacontainerred
	name = "shipping container"
	desc = "It's a shipping container, they are frequently used to ship different goods securely across oceans."
	icon = 'icons/obj/32x96.dmi'
	icon_state = "mantacontainerleft"
	icon_closed = "mantacontainerleft"
	icon_opened = "mantacontainerleft-open"
	icon_welded = "mantacontainerleft-welded"
	bound_height = 96
	bound_width = 32
	anchored = 2

	open(var/entangleLogic)
		if (src.open)
			return 0
		if (!src.can_open())
			return 0

		if(entangled && !entangleLogic && !entangled.can_close())
			visible_message("<span class='alert'>It won't budge!</span>")
			return 0

		if(entangled && !entangleLogic)
			entangled.entangled = src
			entangled.close(1)
			contents = entangled.contents


		src.dump_contents()
		src.open = 1
		src.update_icon()
		p_class = initial(p_class)
		playsound(src.loc, 'sound/effects/cargodoor.ogg', 15, 1, -3)
		return 1

	close(var/entangleLogic)
		if (!src.open)
			return 0
		if (!src.can_close())
			return 0

		if(entangled && !entangleLogic && !entangled.can_open())
			visible_message("<span class='alert'>It won't budge!</span>")
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
				for (var/obj/storage/O in lockers_and_crates)
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
			if (isobserver(M) || iswraith(M) || isintangible(M) || istype(M, /mob/living/object))
				continue
			if (src.crunches_contents)
				src.crunch(M)
			M.set_loc(src)

		recalcPClass()

		if(entangled && !entangleLogic)
			entangled.entangled = src
			entangled.contents = src.contents
			entangled.open(1)

		src.update_icon()
		playsound(src.loc, "sound/effects/cargodoor.ogg", 15, 1, -3)
		return 1

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/cargotele))
			return

		else if (istype(W, /obj/item/satchel/))
			var/amt = W.contents.len
			if (amt)
				user.visible_message("<span class='notice'>[user] dumps out [W]'s contents into [src]!</span>")
				var/amtload = 0
				for (var/obj/item/I in W.contents)
					if (open)
						I.set_loc(src.loc)
					else
						I.set_loc(src)
					amtload++
				W:satchel_updateicon()
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
				src.visible_message("<span class='alert'>[user] welds [src] closed with [W].</span>")
			else
				src.weld(0, W, user)
				src.visible_message("<span class='alert'>[user] unwelds [src] with [W].</span>")
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
					user.visible_message("<span class='notice'>The locker has been [src.locked ? null : "un"]locked by [user].</span>")
					src.update_icon()
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
					user.visible_message("<span class='notice'>[src] has been [src.locked ? null : "un"]locked by [user].</span>")
					src.update_icon()
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
			if (get_dist(src, user) <= 1)
				return src.attack_hand(user)
*/
		else
			return ..()


/obj/storage/closet/mantacontainerred/right
	name = "shipping container"
	desc = "It's a shipping container, they are frequently used to ship different goods securely across oceans."
	icon = 'icons/obj/32x96.dmi'
	icon_closed = "mantacontainerright"
	icon_state = "mantacontainerright"
	icon_opened = "mantacontainerright-open"
	icon_welded = "mantacontainerright-welded"
	bound_height = 96
	bound_width = 32
	anchored = 2

/obj/storage/closet/radiation
	name = "radiation supplies closet"
	icon = 'icons/obj/large_storage.dmi'
	icon_closed = "radiation"
	icon_state = "radiation"
	icon_opened = "radiation-open"
	desc = "A handy closet full of everything you need to protect yourself from impending doom of radioactive death."
	spawn_contents = list(/obj/item/clothing/suit/rad = 1,
					/obj/item/clothing/head/rad_hood = 1,
					/obj/item/storage/pill_bottle/antirad = 1,
					/obj/item/clothing/glasses/meson = 1,
					/obj/item/reagent_containers/emergency_injector/anti_rad = 1)

/obj/storage/closet/medicalclothes
	name = "medical clothing locker"
	icon = 'icons/obj/large_storage.dmi'
	icon_closed = "medicalclothes"
	icon_state = "medicalclothes"
	icon_opened = "secure_white-open"
	desc = "A handy medical locker for storing your doctoring apparel."
	spawn_contents = list(/obj/item/clothing/head/nursehat = 1,
					/obj/item/clothing/suit/nursedress = 1,
					/obj/item/clothing/head/headmirror = 1,
					/obj/item/clothing/suit/labcoat/medical = 2)
