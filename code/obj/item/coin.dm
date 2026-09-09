/obj/item/coin
	name = "luna coin"
	desc = "An old coin from the Lunar Reserve Bank, with graphics of lunar phases on the heads side and famous crater cities on the tails side."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "coin"
	item_state = "coin"
	w_class = W_CLASS_TINY
	stamina_damage = 0
	stamina_cost = 0
	flags = TABLEPASS  | ATTACK_SELF_DELAY
	click_delay = 1 SECOND
	pass_unstable = TRUE
	var/emagged = FALSE

	// is the coin in the air
	var/in_air = FALSE
	/// the prob() of the coin failing when trying to do a trickshot
	var/prob_clonk = 0
	/// the amount of free coin trickshots
	var/damage_accumulated = 0

/obj/item/coin/New()
	. = ..()
	// this assumes the projectile can only hit the coin if in_air is true
	RegisterSignal(src, COMSIG_ATOM_HITBY_PROJ, PROC_REF(coin_trickshot))

/obj/item/coin/disposing()
	. = ..()
	UnregisterSignal(src, COMSIG_ATOM_HITBY_PROJ)

/obj/item/coin/attack_self(mob/user as mob)
	boutput(user, SPAN_NOTICE("You flip the coin..."))
	user.u_equip(src)
	src.set_loc(user.loc)
	//Spin it in midair
	animate(src, transform = turn(matrix(), 120), time = 6 DECI SECONDS, flags = ANIMATION_PARALLEL)
	animate(transform = turn(matrix(), 240), time = 6 DECI SECONDS)
	animate(transform = null, time = 6 DECI SECONDS)
	//First throw
	animate(src, time = 6 DECI SECONDS, pixel_y = 14, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(time = 6 DECI SECONDS, pixel_y = 0, easing = SINE_EASING | EASE_IN)
	//One bounce on the ground
	animate(src, time = 12 DECI SECONDS,  flags = ANIMATION_PARALLEL)
	animate(time= 3 DECI SECONDS, pixel_y = 4, easing = SINE_EASING | EASE_OUT)
	animate(time = 3 DECI SECONDS, pixel_y = 0, , easing = SINE_EASING | EASE_IN)

	// you have until the ground bounce to hit the coin with a projectile
	src.in_air = TRUE
	sleep(12 DECI SECOND)
	if (src.in_air)
		src.in_air = FALSE

	sleep(6 DECI SECOND)
	if(!istype(src.loc, /mob/))	//Hot dog, you caught it midair!
		playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1)
		flip()
	if (src.in_air)
		src.in_air = FALSE
/obj/item/coin/throw_begin(atom/target)
	. = ..(target)
	if (!src.in_air)
		src.in_air = TRUE

/obj/item/coin/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	. = ..(hit_atom)
	if (thr.throw_type & THROW_GUNIMPACT)
		// a hit noise for emphasis
		if (isliving(hit_atom))
			if (!issilicon(hit_atom))
				playsound(src, 'sound/impact_sounds/Flesh_Break_1.ogg', 100, 1)
			else
				// default bullet noise
				playsound(src, 'sound/impact_sounds/Flesh_Stab_2.ogg', 100, 1)
	if (src.in_air)
		src.in_air = FALSE
	flip()

/obj/item/coin/Cross(atom/movable/mover)
	// we only want to interrupt projectiles if we're being flipped
	if(src.in_air && istype(mover, /obj/projectile))
		return FALSE
	if(!src.density)
		return TRUE

/obj/item/coin/proc/can_trickshot(mob/user)
	if (src.damage_accumulated > 5)
		src.visible_message(SPAN_ALERT("The [src] breaks from the impact of the projectile!"))
		dothepixelthing(src)
		return FALSE

	// failure prob code yoinked from clock 180s and made harsher
	prob_clonk = min(prob_clonk + 20, 100)
	SPAWN(1 SECONDS)
		prob_clonk = max(prob_clonk - 20, 0)
	// prevent nerds from being nerds by ruining their day with RNG
	if (prob(src.prob_clonk))
		return FALSE

	return TRUE

/obj/item/coin/proc/coin_trickshot(rendering_on, obj/projectile/shot, impact_x, impact_y)
	if (!src.can_trickshot(usr))
		return

	var/power = shot.proj_data?.damage
	var/throw_speed = floor(shot.proj_data?.projectile_speed/10)

	// reduce power if the shot isnt kinetic
	if (!istype(shot,/datum/projectile/bullet))
		power /= 3
		throw_speed /= 2
	else
		power /= 2

	src.damage_accumulated += 1

	var/atom/M = null
	for (var/mob/living/possible in viewers(10,src))
		if (usr && usr == possible)
			continue
		if (M)
			if (GET_DIST(M,src) >= GET_DIST(possible,src))
				M = possible
		else
			M = possible

	if (M)
		src.throw_at(M,10,throw_speed,throw_type=THROW_GUNIMPACT,bonus_throwforce=clamp(power,0,20))
	else
		// throw in the direction
		M = get_edge_target_turf(src, shot.dir)
		src.throw_at(M,10,throw_speed,throw_type=THROW_GUNIMPACT,bonus_throwforce=clamp(power,0,20))

/obj/item/coin/emag_act(var/mob/user, var/obj/item/card/emag/E)
	..()
	if(!emagged)
		boutput(user, "You magnetize the coin, restoring an old order to the universe.")
		emagged = TRUE
		return TRUE

/obj/item/coin/proc/flip()
	if(!emagged)
		if(prob(1))
			src.visible_message(SPAN_NOTICE("The coin lands on its side. Fuck."))
		else if(prob(50))
			src.visible_message(SPAN_NOTICE("The coin comes up Moons (heads)."))
		else
			src.visible_message(SPAN_NOTICE("The coin comes up Craters (tails)."))
		return
	if(prob(49))
		src.visible_message(SPAN_NOTICE("The coin comes up Moons (heads)."))
	else if(prob(49))
		src.visible_message(SPAN_NOTICE("The coin comes up Craters (tails)."))
	else
		src.visible_message(SPAN_NOTICE("The coin lands on its side. Fuck."))


/obj/item/coin_bot
	name = "probability disc"
	desc = "A small golden disk of some sort. Possibly used in highly complex quantum experiments."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "coin"
	item_state = "coin"
	w_class = W_CLASS_TINY

	attack_self(var/mob/user as mob)
		if (ON_COOLDOWN(src, "attack_self", 1 SECOND))
			return
		playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1)
		if (prob(50))
			user.visible_message("[src] shows Heads.")
		else
			user.visible_message("[src] shows Tails.")

/obj/item/coin/custom_suicide = 1
/obj/item/coin/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message(SPAN_ALERT("<b>[user] swallows [src] and begins to choke!</b>"))
	user.take_oxygen_deprivation(175)
	qdel(src)
	return 1
