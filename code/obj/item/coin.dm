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
	var/emagged = FALSE

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
	sleep(18 DECI SECOND)
	if(!istype(src.loc, /mob/))	//Hot dog, you caught it midair!
		playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1)
		flip()

/obj/item/coin/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..(hit_atom)
	flip()


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

/obj/item/coin/antcoin //Coin found in the ant farm and traitor objective. Code clearly taken from the fine luna coin above but modified/simpler.
	name = "one Ashanikan penny"
	desc = "A coin with an ant on it. Why would ants need currantcy?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "currantcy"
	item_state = "currantcy"
	w_class = W_CLASS_TINY
	stamina_damage = 0
	stamina_cost = 0
	flags = TABLEPASS  | ATTACK_SELF_DELAY
	click_delay = 1 SECOND

/obj/item/coin/attack_self(mob/user as mob)
	boutput(user, SPAN_NOTICE("you flip the coin, ante up..."))
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
	sleep(18 DECI SECOND)
	if(!istype(src.loc, /mob/))	//Hot dog, you caught it midair!
		playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1)
		flip()

/obj/item/coin/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..(hit_atom)
	flip()
