
/* ================================================== */
/* -------------------- Grenades -------------------- */
/* ================================================== */

/obj/item/chem_grenade
	name = "metal casing"
	icon_state = "grenade-chem1"
	icon = 'icons/obj/items/grenade.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "flashbang"
	w_class = W_CLASS_SMALL
	force = 2
	var/stage = 0
	var/armed = 0
	var/icon_state_armed = "grenade-chem-armed"
	var/list/beakers = new/list()
	var/image/fluid_image1 //its 01:34 and im tired im sorry for this
	var/image/fluid_image2
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | EXTRADELAY | NOSPLASH
	c_flags = ONBELT
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	move_triggered = 1
	duration_put = 0.25 SECONDS //crime
	var/is_dangerous = TRUE
	var/detonating = 0


	New()
		..()
		fluid_image1 = image('icons/obj/items/grenade.dmi', "grenade-chem-fluid1", -1)
		fluid_image2 = image('icons/obj/items/grenade.dmi', "grenade-chem-fluid2", -1)
		src.create_reagents(150000)

	is_open_container()
		return src.detonating

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/grenade_fuse) && !stage)
			boutput(user, "<span class='notice'>You add [W] to the metal casing.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 25, -3)
			qdel(W) //Okay so we're not really adding anything here. cheating.
			icon_state = "grenade-chem2"
			name = "unsecured grenade"
			stage = 1
		else if (isscrewingtool(W) && stage == 1)
			if (beakers.len)
				boutput(user, "<span class='notice'>You lock the assembly.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', 25, -3)
				name = "grenade"
				icon_state = "grenade-chem3"
				stage = 2
			else
				boutput(user, "<span class='alert'>You need to add at least one beaker before locking the assembly.</span>")
		else if (istype(W,/obj/item/reagent_containers/glass) && stage == 1)
			if (beakers.len == 2)
				boutput(user, "<span class='alert'>The grenade can not hold more containers.</span>")
				return
			var/obj/item/reagent_containers/glass/G = W
			if (G.initial_volume > 50) // anything bigger than a regular beaker, but someone could varedit their reagent holder beyond this for admin nonsense
				boutput(user, "<span class='alert'>This beaker is too large!</span>")
				return
			else
				if (G.reagents && G.reagents.total_volume)
					boutput(user, "<span class='notice'>You add \the [G] to the assembly.</span>")
					user.drop_item()
					G.set_loc(src)
					beakers += G
					switch (beakers.len)
						if (1)
							src.fluid_image1.color = G.reagents.get_average_color().to_rgba()
							src.UpdateOverlays(src.fluid_image1, "fluid1")
						if (2)
							src.fluid_image2.color = G.reagents.get_average_color().to_rgba()
							src.UpdateOverlays(src.fluid_image2, "fluid2")
				else
					boutput(user, "<span class='alert'>\The [G] is empty.</span>")
		else if (stage == 2 && (istype(W, /obj/item/assembly/rad_ignite) || istype(W, /obj/item/assembly/prox_ignite) || istype(W, /obj/item/assembly/time_ignite)))
			var/obj/item/assembly/S = W
			if (!S || !S:status)
				return
			boutput(user, "<span class='notice'>You attach the [src.name] to the [S.name]!</span>")
			logTheThing(LOG_BOMBING, user, "made a chemical bomb with a [S.name].")
			message_admins("[key_name(user)] made a chemical bomb with a [S.name].")

			var/obj/item/assembly/chem_bomb/R = new /obj/item/assembly/chem_bomb( user )
			R.attacher = key_name(user)

			switch(UNLINT(S:part1.type))
				if (/obj/item/device/timer)
					R.desc = "A very intricate igniter and timer assembly mounted to a chem grenade."
					R.name = "Timer/Igniter/Chem Grenade Assembly"
				if (/obj/item/device/prox_sensor)
					R.desc = "A very intricate igniter and proximity sensor electrical assembly mounted to a chem grenade."
					R.name = "Proximity/Igniter/Chem Grenade Assembly"
				if (/obj/item/device/radio/signaler)
					R.desc = "A very intricate igniter and signaller electrical assembly mounted to a chem grenade."
					R.name = "Radio/Igniter/Chem Grenade Assembly"

			R.triggering_device = S:part1
			R.c_state(0)
			UNLINT(S:part1.set_loc(R))
			UNLINT(S:part1.master = R)
			R.igniter = S:part2
			R.igniter.status = 1
			UNLINT(S:part2.set_loc(R))
			UNLINT(S:part2.master = R)
			S.layer = initial(S.layer)
			user.u_equip(S)
			user.put_in_hand_or_drop(R)
			src.master = R
			src.layer = initial(src.layer)
			user.u_equip(src)
			src.set_loc(R)
			R.payload = src
			S:part1 = null
			S:part2 = null
			//S = null
			qdel(S)

// warcrimes: Why the fuck is autothrow a feature why would this ever be a feature WHY. Now it wont do it unless it's primed i think.
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(user, target) == 0 || (!isturf(target) && !isturf(target.loc)) || !isturf(user.loc) || !src.armed)
			return
		var/area/a = get_area(target)
		if(a.sanctuary) return
		if (user.equipped() == src)
			if (src.arm(user))
				return ..()
			user.drop_item()
			src.throw_at(get_turf(target), 10, 3)
			return
		else if (isghostdrone(user))
			var/mob/living/silicon/ghostdrone/G = user
			if (istype(G.active_tool, /obj/item/magtractor))
				var/obj/item/magtractor/mag = G.active_tool
				if (mag.holding == src)
					if (src.arm(user))
						return ..()
					mag.dropItem()
					src.throw_at(get_turf(target), 10, 3)
					return

	attack_self(mob/user as mob)
		src.arm(user)

	attack_hand()
		walk(src,0)
		return ..()

	proc/arm(mob/user as mob)
		if (src.armed || src.stage != 2)
			return 1
		var/area/A = get_area(src)
		if(A.sanctuary)
			return
		// Custom grenades only. Metal foam etc grenades cannot be modified (Convair880).
		var/log_reagents = null
		if (src.name == "grenade")
			for (var/obj/item/reagent_containers/glass/G in src.beakers)
				if (G.reagents.total_volume) log_reagents += "[log_reagents(G)] "

		if(!A.dont_log_combat)
			if(is_dangerous && user)
				message_admins("[log_reagents ? "Custom grenade" : "Grenade ([src])"] primed at [log_loc(src)] by [key_name(user)].")
			logTheThing(LOG_COMBAT, user, "primes a [log_reagents ? "custom grenade" : "grenade ([src.type])"] at [log_loc(user)].[log_reagents ? " [log_reagents]" : ""]")

		boutput(user, "<span class='alert'>You prime the grenade! 3 seconds!</span>")
		src.armed = TRUE
		src.icon_state = icon_state_armed
		playsound(src, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		SPAWN(3 SECONDS)
			if (src && !src.disposed)
				if(user?.equipped() == src)
					user.u_equip(src)
				explode()

	proc/explode()
		src.reagents.my_atom = src //hax
		var/has_reagents = 0
		src.detonating = 1
		for (var/obj/item/reagent_containers/glass/G in beakers)
			if (G.reagents.total_volume) has_reagents = 1

		if (!has_reagents)
			playsound(src.loc, 'sound/items/Screwdriver2.ogg', 50, 1)
			src.armed = FALSE
			return

		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

		for (var/obj/item/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(src, G.reagents.total_volume)

		if (src.reagents.total_volume) //The possible reactions didnt use up all reagents.
			var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread
			steam.set_up(10, 0, get_turf(src))
			steam.attach(src)
			steam.start()
			var/min_dispersal = src.reagents.get_dispersal()
			for (var/atom/A in range(min_dispersal, get_turf(src.loc)))
				if ( A == src ) continue
				if (src?.reagents) // Erik: fix for cannot execute null.grenade effects()
					src.reagents.grenade_effects(src, A)
					src.reagents.reaction(A, 1, 10, 0)

		invisibility = INVIS_ALWAYS_ISH //Why am i doing this?
		if (src.master) src.master.invisibility = INVIS_ALWAYS_ISH
		SPAWN(5 SECONDS)		   //To make sure all reagents can work
			if (src.master) qdel(src.master)
			if (src) qdel(src)	   //correctly before deleting the grenade.

	move_trigger(var/mob/M, kindof)
		if (..())
			for (var/obj/O in contents)
				if (O.move_triggered)
					O.move_trigger(M, kindof)

/obj/item/grenade_fuse
	name = "grenade fuse"
	desc = "A fuse mechanism with a safety lever."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "grenade-fuse"
	item_state = "pen"
	force = 0
	w_class = W_CLASS_TINY
	m_amt = 100

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

// Order matters. Water resp. the final smoke ingredient should always be the last reagent added to the beaker.
// If it's not, the foam resp. smoke reaction occurs prematurely without carrying the target reagents with them.

/obj/item/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "After activating, creates a mess of foamed metal. Useful for plugging the hull up."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "metalfoam"
	icon_state_armed = "metalfoam1"
	stage = 2
	is_dangerous = FALSE

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("aluminium", 30)
		B2.reagents.add_reagent("fluorosurfactant", 10)
		B2.reagents.add_reagent("acid", 10)

		beakers += B1
		beakers += B2

/obj/item/chem_grenade/firefighting
	name = "fire fighting grenade"
	desc = "Propells firefighting foam in a wide area around it after activation, putting out fires."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "firefighting"
	icon_state_armed = "firefighting1"
	stage = 2
	is_dangerous = FALSE

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("ff-foam", 30)
		B2.reagents.add_reagent("ff-foam", 30)

		beakers += B1
		beakers += B2

/obj/item/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "cleaner"
	icon_state_armed = "cleaner1"
	stage = 2
	is_dangerous = FALSE

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 30)
		B2.reagents.add_reagent("cleaner", 20)
		B2.reagents.add_reagent("water", 30)

		beakers += B1
		beakers += B2

/obj/item/chem_grenade/fcleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "cleaner"
	icon_state_armed = "cleaner1"
	stage = 2

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 10)
		B1.reagents.add_reagent("superlube", 10)

		B2.reagents.add_reagent("pacid", 10) //The syndicate are sending the strong stuff now -Spy
		B2.reagents.add_reagent("water", 10)

		beakers += B1
		beakers += B2

TYPEINFO(/obj/item/chem_grenade/flashbang)
	mats = 6

TYPEINFO(/obj/item/chem_grenade/flashbang/revolution)
	mats = null

/obj/item/chem_grenade/flashbang
	name = "flashbang"
	desc = "A standard stun grenade."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "flashbang"
	icon_state_armed = "flashbang1"
	stage = 2
	is_syndicate = 1
	is_dangerous = FALSE

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)

		B1.reagents.maximum_volume = 100
		B1.reagents.add_reagent("aluminium", 25)
		B1.reagents.add_reagent("potassium", 25)
		B1.reagents.add_reagent("cola", 25)
		B1.reagents.add_reagent("chlorine", 25)

		B2.reagents.maximum_volume = 100
		B2.reagents.add_reagent("sulfur", 25)
		B2.reagents.add_reagent("oxygen", 25)
		B2.reagents.add_reagent("phosphorus", 25)

		beakers += B1
		beakers += B2

	revolution //convertssss
		explode()
			var/min_dispersal = src.reagents.get_dispersal()
			for (var/mob/M in range(max(min_dispersal,6), get_turf(src.loc)))
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					var/safety = 0
					if (H.eyes_protected_from_light() && H.ears_protected_from_sound())
						safety = 1

					if (safety == 0)
						var/can_convert = 1
						if (!H.client || !H.mind)
							can_convert = 0
						else if (!H.can_be_converted_to_the_revolution())
							can_convert = 0
						else if (H.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY))
							can_convert = 0
						else
							can_convert = 1

						for (var/obj/item/implant/counterrev/found_imp in H.implant)
							found_imp.on_remove(H)
							H.implant.Remove(found_imp)
							qdel(found_imp)

							playsound(H.loc, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 50, 0.1, 0, 0.9)
							H.visible_message("<span class='notice'>The counter-revolutionary implant inside [H] shatters into one million pieces!</span>")

						if (can_convert && !(H.mind?.get_antagonist(ROLE_REVOLUTIONARY)))
							H.mind?.add_antagonist(ROLE_REVOLUTIONARY)

			..()


/obj/item/chem_grenade/cryo
	name = "cryo grenade"
	desc = "An experimental non-lethal grenade using cryogenic technologies."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "cryo"
	icon_state_armed = "cryo1"
	stage = 2

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)

		B1.reagents.add_reagent("cryostylane", 35)

		beakers += B1

/obj/item/chem_grenade/incendiary
	name = "incendiary grenade"
	desc = "A rather volatile grenade that creates a small fire."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "incendiary"
	icon_state_armed = "incendiary1"
	stage = 2

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		B1.reagents.add_reagent("infernite", 20)
		beakers += B1

/obj/item/chem_grenade/very_incendiary
	name = "high range incendiary grenade"
	desc = "A rather volatile grenade that creates a large fire."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "incendiary-highrange"
	icon_state_armed = "incendiary-highrange1"
	stage = 2

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		B1.reagents.add_reagent("firedust", 20)
		beakers += B1

/obj/item/chem_grenade/very_incendiary/vr
	icon = 'icons/effects/VR.dmi'
	icon_state = "chemg3"
	icon_state_armed = "chemg4"

/obj/item/chem_grenade/shock
	name = "shock grenade"
	desc = "An arc flashing grenade that shocks everyone close by."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "shock"
	icon_state_armed = "shock1"
	stage = 2

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)

		B1.reagents.add_reagent("voltagen", 50)

		beakers += B1

/obj/item/chem_grenade/pepper
	name = "crowd dispersal grenade"
	desc = "An non-lethal grenade for use against protests, riots, vagrancy and loitering. Not to be used as a food additive."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "pepper"
	icon_state_armed = "pepper1"
	stage = 2

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)
		B1.reagents.maximum_volume=75 //dumb hack, but it works
		B1.reagents.add_reagent("capsaicin", 50)
		B1.reagents.add_reagent("sugar",25)

		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("potassium", 25)
		beakers += B1
		beakers += B2

/obj/item/chem_grenade/saxitoxin
	name = "STX grenade"
	desc = "A smoke grenade containing an extremely lethal nerve agent. Use of this mixture constitutes a war crime, so... try not to leave any witnesses."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "saxitoxin"
	icon_state_armed = "saxitoxin1"
	stage = 2

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)
		B1.reagents.maximum_volume=100 //dumb hack, but it works
		B1.reagents.add_reagent("saxitoxin", 75)
		B1.reagents.add_reagent("sugar",25)

		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("potassium", 25)

		beakers += B1
		beakers += B2

/obj/item/chem_grenade/luminol
	name = "luminol smoke grenade"
	desc = "A smoke grenade containing a compound that reveals traces of blood."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "luminol"
	icon_state_armed = "luminol1"
	stage = 2
	is_dangerous = FALSE

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("luminol", 15)
		B1.reagents.add_reagent("sugar",15)

		B2.reagents.add_reagent("phosphorus", 15)
		B2.reagents.add_reagent("potassium", 15)

		beakers += B1
		beakers += B2

/obj/item/chem_grenade/fog
	name = "fog grenade"
	desc = "A specialized smoke grenade that releases a fog that blocks vision, but is not irritating to inhale."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "fog"
	icon_state_armed = "fog1"
	stage = 2
	is_dangerous = FALSE

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("fog", 25)
		B1.reagents.add_reagent("sugar",25)

		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("potassium", 25)

		beakers += B1
		beakers += B2

/obj/item/chem_grenade/napalm
	name = "napalm smoke grenade"
	desc = "A grenade that will fill an area with napalm smoke."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "incendiary"
	icon_state_armed = "incendiary1"
	stage = 2

	New()
		..()
		var/obj/item/reagent_containers/glass/B1 = new(src)
		var/obj/item/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("syndicate_napalm", 25)
		B1.reagents.add_reagent("sugar",25)

		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("potassium", 25)

		beakers += B1
		beakers += B2
