/obj/item/coin
	name = "coin"
	desc = "A small gold coin with an alien head on one side and a monkey buttocks on the other."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "coin"
	item_state = "coin"
	w_class = 1.0
	stamina_damage = 0
	stamina_cost = 0
	module_research = list("vice" = 3, "efficiency" = 1)
	module_research_type = /obj/item/coin
	var/emagged = FALSE

/obj/item/coin/attack_self(mob/user as mob)
	boutput(user, "<span class='notice'>You flip the coin</span>")
	SPAWN_DBG(1 SECOND)
		src.set_loc(user.loc)
		user.u_equip(src)
		playsound(src.loc, "sound/items/coindrop.ogg", 100, 1)
		flip()

/obj/item/coin/throw_impact(atom/hit_atom)
	..(hit_atom)
	flip()
		
		
/obj/item/coin/emag_act(var/mob/user, var/obj/item/card/emag/E)
	..()
	if(!emagged)
		boutput(user, "You magnetize the coin, ruining it's chances of ever being used in the Inter-galactic Poker Tournaments ever again.")
		emagged = TRUE
		
/obj/item/coin/proc/flip()
	if(!emagged)
		if(prob(1))
			src.visible_message("<span class='notice'>The coin lands on its side. Fuck.</span>")
		else if(prob(50))
			src.visible_message("<span class='notice'>The coin comes up heads.</span>")
		else
			src.visible_message("<span class='notice'>The coin comes up tails.</span>")
		return
	if(prob(49))
		src.visible_message("<span class='notice'>The coin comes up heads.</span>")
	else if(prob(49))
		src.visible_message("<span class='notice'>The coin comes up tails.</span>")
	else
		src.visible_message("<span class='notice'>The coin lands on its side. Fuck.</span>")


/obj/item/coin_bot
	name = "Probability Disc"
	desc = "A small golden disk of some sort. Possibly used in highly complex quantum experiments."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "coin"
	item_state = "coin"
	w_class = 1.0

	attack_self(var/mob/user as mob)
		playsound(src.loc, "sound/items/coindrop.ogg", 100, 1)
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
