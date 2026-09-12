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
	throw_speed = 0.3
	var/emagged = FALSE
	/// Does this coin count as in the air for the purposes of ricochet?
	var/in_air = FALSE

//debug macro :3
#ifdef LIVE_SERVER
#define SET_AIR(value) src.in_air = value;
#else
#define SET_AIR(value)\
	src.in_air = value;\
	src.color = src.in_air ? "red" : null
#endif

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

	//This looks complicated but works out to the coin counting as in the air after 2 ticks on the first throw and 1 tick on the second
	SPAWN(2 DECI SECONDS)
		SET_AIR(TRUE)
		sleep(8 DECI SECONDS)
		SET_AIR(FALSE)
		sleep(3 DECI SECONDS)
		SET_AIR(TRUE)
		sleep(4 DECI SECONDS)
		SET_AIR(FALSE)

	sleep(18 DECI SECOND)

	if(!istype(src.loc, /mob/))	//Hot dog, you caught it midair!
		playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1)
		flip()

/obj/item/coin/throw_begin(atom/target, turf/thrown_from, mob/thrown_by)
	. = ..()
	SET_AIR(TRUE)

/obj/item/coin/throw_end(list/params, turf/thrown_from)
	. = ..()
	SPAWN(3 DECI SECONDS)
		SET_AIR(FALSE)

/obj/item/coin/Cross(atom/movable/mover)
	// we only want to interrupt projectiles if we're being flipped
	if(src.in_air && istype(mover, /obj/projectile))
		return FALSE
	return ..()

/obj/item/coin/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..(hit_atom)
	flip()

/obj/item/coin/bullet_act(obj/projectile/P)
	var/obj/itemspecialeffect/glare/effect = new
	effect.color = "#FFFFFF"
	effect.setup(src.loc)
	src.visible_message(SPAN_BOLD(SPAN_ALERT("[P] ricochets [pick("crazily", "skillfully", "straight")] off [src]!")))

	var/atom/shooter = P.shooter
	shoot_reflected_trickshot(P, src, 4)
	var/turf/coin_target = get_steps(src, get_dir_accurate(shooter, src), src.throw_range)
	animate(src)
	src.throwing = FALSE
	src.throw_at(coin_target, src.throw_range, 2)

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

#undef SET_AIR
