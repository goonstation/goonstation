/obj/item/coin
	name = "luna coin"
	desc = "An old coin from the Lunar Reserve Bank, with graphics of lunar phases on the heads side and famous crater cities on the tails side."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "coin"
	item_state = "coin"
	w_class = W_CLASS_TINY
	stamina_damage = 0
	stamina_cost = 0
	flags = FPRINT | TABLEPASS  | ATTACK_SELF_DELAY
	click_delay = 1 SECOND
	var/emagged = FALSE

/obj/item/coin/attack_self(mob/user as mob)
	boutput(user, "<span class='notice'>You flip the coin</span>")
	user.u_equip(src)
	src.set_loc(user.loc)
	animate(src, time=6 DECI SECONDS, pixel_y=14, easing=SINE_EASING | EASE_OUT)
	animate(time=6 DECI SECONDS, pixel_y=0, easing=SINE_EASING | EASE_IN)
	SPAWN(12 DECI SECONDS)
		animate(src, time=3 DECI SECONDS, pixel_y=5, easing=SINE_EASING | EASE_OUT)
		animate(time=3 DECI SECONDS, pixel_y=0, easing=SINE_EASING | EASE_IN)
		SPAWN(6 DECI SECOND)
			if(!istype(src.loc, /mob/))	//Hot dog, you caught it midair!
				playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1)
				flip()

/obj/item/coin/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..(hit_atom)
	flip()


/obj/item/coin/emag_act(var/mob/user, var/obj/item/card/emag/E)
	..()
	if(!emagged)
		boutput(user, "You magnetize the coin, ruining it's chances of ever being used in the Inter-galactic Poker Tournaments ever again.")
		emagged = TRUE
		return TRUE

/obj/item/coin/proc/flip()
	if(!emagged)
		if(prob(1))
			src.visible_message("<span class='notice'>The coin lands on its side. Fuck.</span>")
		else if(prob(50))
			src.visible_message("<span class='notice'>The coin comes up Moons.</span>")
		else
			src.visible_message("<span class='notice'>The coin comes up Craters.</span>")
		return
	if(prob(49))
		src.visible_message("<span class='notice'>The coin comes up Moons.</span>")
	else if(prob(49))
		src.visible_message("<span class='notice'>The coin comes up Craters.</span>")
	else
		src.visible_message("<span class='notice'>The coin lands on its side. Fuck.</span>")


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
	user.visible_message("<span class='alert'><b>[user] swallows [src] and begins to choke!</b></span>")
	user.take_oxygen_deprivation(175)
	qdel(src)
	return 1
