//BASKETBALL

/obj/item/basketball
	name = "basketball"
	desc = "If you can't slam with the best, then jam with the rest."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bball"
	item_state = "bball"
	w_class = W_CLASS_NORMAL
	force = 0
	throw_range = 10
	throwforce = 0
	var/obj/item/plutonium_core/payload = null
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5
	custom_suicide = 1
	contraband = 2 // Due to the illegalization of basketball in 2041
	var/base_icon_state = "bball"
	var/spinning_icon_state = "bball_spin"

/obj/item/basketball/attack_hand(mob/user)
	..()
	if(user)
		src.icon_state = base_icon_state

/obj/item/basketball/suicide(var/mob/user as mob)
	user.visible_message(SPAN_ALERT("<b>[user] fouls out, permanently.</b>"))
	user.TakeDamage("head", 175, 0)
	SPAWN(30 SECONDS)
		if (user)
			user.suiciding = 0
	return 1

/obj/item/basketball/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..(hit_atom)
	src.icon_state = base_icon_state
	if(hit_atom)
		playsound(src.loc, 'sound/items/bball_bounce.ogg', 65, 1)
		if(ismob(hit_atom))
			var/mob/M = hit_atom
			if(ishuman(M))
				if((prob(50) && M.bioHolder.HasEffect("clumsy")))
					src.visible_message(SPAN_COMBAT("[M] gets beaned with the [src.name]."))
					M.changeStatus("stunned", 2 SECONDS)
					JOB_XP(M, "Clown", 1)
					return
				else
					if (M.equipped() || get_dir(M, src) == M.dir)
						src.visible_message(SPAN_COMBAT("[M] gets beaned with the [src.name]."))
						logTheThing(LOG_COMBAT, M, "is struck by [src]")
						M.do_disorient(stamina_damage = 20, knockdown = 0, stunned = 0, disorient = 10, remove_stamina_below_zero = 0)
					else
						// catch the ball!
						src.Attackhand(M)
						M.visible_message(SPAN_COMBAT("[M] catches the [src.name]!"), SPAN_COMBAT("You catch the [src.name]!"))
						logTheThing(LOG_COMBAT, M, "catches [src]")
			else
				src.visible_message(SPAN_COMBAT("[M] gets beaned with the [src.name]."))
				logTheThing(LOG_COMBAT, M, "is struck by [src]")
				M.do_disorient(stamina_damage = 20, knockdown = 0, stunned = 0, disorient = 10, remove_stamina_below_zero = 0)

/obj/item/basketball/throw_at(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1,
			allow_anchored = UNANCHORED, bonus_throwforce = 0, end_throw_callback = null)
	src.icon_state = spinning_icon_state
	. = ..()

/obj/item/basketball/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/plutonium_core))
		boutput(user, SPAN_NOTICE("You insert the [W.name] into the [src.name]."))
		user.u_equip(W)
		W.dropped(user)
		W.layer = initial(W.layer)
		W.set_loc(src)
		var/obj/item/plutonium_core/P = W
		src.payload = W
		if(src.loc == user)
			P.plutonize(user.verbs)
		return
	..()
	return

/obj/item/basketball/attack_hand(mob/user)
	..()
	var/mob/living/carbon/human/H = user
	if(istype(H) && payload && istype(payload))
		payload.plutonize(user.verbs)
	return

/obj/item/basketball/unequipped(var/mob/usr)
	if(payload && istype(payload))
		payload.unplutonize(usr.verbs)
	..()

// hoop

/obj/item/bballbasket
	name = "basketball hoop" // it's a hoop you nerd, not a basket
	desc = "Can be mounted on walls."
	opacity = 0
	density = 0
	anchored = UNANCHORED
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bbasket0"
	event_handler_flags = USE_FLUID_ENTER
	var/mounted = 0
	var/active = 0
	var/probability = 40

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W) && mounted)
			src.visible_message(SPAN_NOTICE("<b>[user] removes [src].</b>"))
			src.pixel_y = 0
			src.pixel_x = 0
			src.anchored = UNANCHORED
			src.mounted = 0
		else if (src.mounted && !istype(W, /obj/item/bballbasket))
			if (W.cant_drop) return
			src.visible_message(SPAN_NOTICE("<b>[user]</b> jumps up and tries to dunk [W] into [src]!"))
			user.u_equip(W)
			if (user.bioHolder.HasEffect("clumsy") && prob(50)) // clowns are not good at basketball I guess
				user.visible_message(SPAN_COMBAT("<b>[user] knocks their head into the rim of [src]!</b>"))
				user.changeStatus("knockdown", 5 SECONDS)
				JOB_XP(user, "Clown", 1)

			if (!src.shoot(W, user))
				SPAWN(1 SECOND)
					src.visible_message(SPAN_ALERT("[user] whiffs the dunk."))
		return

	attack_hand(mob/user)
		if (mounted)
			return
		else
			return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (!mounted && GET_DIST(src, target) == 1)
			if (isturf(target) && target.density)
				//if (get_dir(src,target) == NORTH || get_dir(src,target) == EAST || get_dir(src,target) == SOUTH || get_dir(src,target) == WEST)
				if (get_dir(src,target) in cardinal)
					src.visible_message(SPAN_NOTICE("<b>[user] mounts [src] on [target].</b>"))
					user.drop_item()
					src.set_loc(get_turf(user))
					src.mounted = 1
					src.anchored = ANCHORED
					src.set_dir(get_dir(src, target))
					switch (src.dir)
						if (NORTH)
							src.pixel_y = 20
						if (SOUTH)
							src.pixel_y = -20
						if (EAST)
							src.pixel_x = 20
						if (WEST)
							src.pixel_x = -20
		return

	Crossed(atom/movable/A)
		..()
		if (src.active)
			return
		if (istype(A, /obj/item/bballbasket)) // oh for FUCK'S SAKE
			return // NO
		if (isitem(A))
			src.shoot(A)

	proc/shoot(var/obj/O as obj, var/mob/user as mob)
		if (!O)
			return 0
		if (istype(O, /obj/item/bballbasket))
			return
		src.active = 1
		if (user)
			user.u_equip(O)
		O.set_loc(get_turf(src))
		if (prob(src.probability)) // It might land!
			if (prob(30)) // It landed cleanly!
				src.visible_message(SPAN_NOTICE("[O] lands cleanly in [src]!"))
				src.basket(O)
			else // Aaaa the tension!
				src.visible_message(SPAN_ALERT("[O] teeters on the edge of [src]!"))
				var/delay = rand(5, 15)
				animate_horizontal_wiggle(O, delay, 5, 1, -1) // target, number of animation loops, speed, positive x variation, negative x variation
				SPAWN(delay)
					if (O && O.loc == src.loc)
						if (prob(40)) // It goes in!
							src.visible_message(SPAN_NOTICE("[O] slips into [src]!"))
							src.basket(O)
						else
							src.visible_message(SPAN_ALERT("[O] slips off of the edge of [src]!"))
							src.active = 0
					else
						src.active = 0
			src.active = 0
			return 1
		else
			src.active = 0
			return 0

	proc/basket(var/atom/A as obj|mob)
		if (!A || isarea(A) || isturf(A))
			return
		src.active = 1
		playsound(src, "rustle", 75, 1)
		A.invisibility = INVIS_ALWAYS_ISH
		flick("bbasket1", src)
		SPAWN(1.5 SECONDS)
			A.invisibility = INVIS_NONE
			src.active = 0

/obj/item/bballbasket/testing
	probability = 100

//PLUTONIUM CORE

/obj/item/plutonium_core
	name = "plutonium core"
	desc = "A payload from a nuclear warhead. Comprised of weapons-grade plutonium."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "plutonium"
	item_state = "egg3"
	w_class = W_CLASS_NORMAL
	force = 0
	throwforce = 10

	proc/plutonize(var/usrverbs)
		usrverbs += /mob/proc/chaos_dunk

	proc/unplutonize(var/usrverbs)
		usrverbs -= /mob/proc/chaos_dunk

/obj/item/plutonium_core/attack_hand(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves)
			boutput(H, SPAN_COMBAT("Your hand burns from grabbing the [src.name]."))
			var/zone = H.hand ? "l_arm" : "r_arm"
			H.TakeDamage(zone, 0, 15, 0, DAMAGE_BURN)

//BLOOD BOWL BALL

/obj/item/bloodbowlball
	name = "spiked ball"
	desc = "An american football studded with sharp spikes and serrated blades. Looks dangerous."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bloodbowlball"
	item_state = "bloodbowlball"
	w_class = W_CLASS_NORMAL
	force = 10
	throw_range = 10
	throwforce = 2
	throw_spin = 0

/obj/item/bloodbowlball/attack_hand(mob/user)
	..()
	if(user)
		src.icon_state = "bloodbowlball"

/obj/item/bloodbowlball/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..(hit_atom)
	src.icon_state = "bloodbowlball"
	if(hit_atom)
		playsound(src.loc, 'sound/items/bball_bounce.ogg', 65, 1)
		if(ismob(hit_atom))
			var/mob/M = hit_atom
			if(ishuman(M))
				var/mob/living/carbon/T = M
				if(prob(20) || T.equipped() || get_dir(T, src) == T.dir)
					for(var/mob/V in AIviewers(src, null))
						if(V.client)
							V.show_message(SPAN_COMBAT("[T] gets stabbed by one of the [src.name]'s spikes."), 1)
							playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_2.ogg', 65, 1)
					T.changeStatus("stunned", 5 SECONDS)
					T.TakeDamageAccountArmor("chest", 30, 0)
					take_bleeding_damage(T, null, 15, DAMAGE_STAB)
					return
				else if (prob(50))
					src.visible_message(SPAN_COMBAT("[T] catches the [src.name] but gets cut."))
					T.TakeDamage(T.hand == LEFT_HAND ? "l_arm" : "r_arm", 15, 0)
					take_bleeding_damage(T, null, 10, DAMAGE_CUT)
					src.Attackhand(T)
					return
				// catch the ball!
				else
					src.Attackhand(T)
					T.visible_message(SPAN_COMBAT("[M] catches the [src.name]!"))
					return
	return

/obj/item/bloodbowlball/throw_at(atom/target, range, speed, list/params, turf/thrown_from, throw_type = 1, allow_anchored = UNANCHORED, bonus_throwforce = 0)
	src.icon_state = "bloodbowlball_air"
	. = ..()

/obj/item/bloodbowlball/attack(target, mob/user)
	playsound(target, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, TRUE)
	if(iscarbon(target))
		var/mob/living/carbon/targMob = target
		if(!isdead(targMob))
			targMob.visible_message(SPAN_COMBAT("<B>[user] attacks [target] with the [src]!</B>"))
			take_bleeding_damage(target, user, 5, DAMAGE_STAB)
	if(prob(30))
		if(prob(30))
			boutput(user, SPAN_COMBAT("You accidentally cut your hand badly!"))
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 10, 0)
			take_bleeding_damage(user, user, 5, DAMAGE_CUT)
		else
			boutput(user, SPAN_COMBAT("You accidentally cut your hand!"))
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 5, 0)
			take_bleeding_damage(user, null, 1, DAMAGE_CUT, 0)

