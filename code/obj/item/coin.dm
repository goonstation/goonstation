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

/obj/item/coin/attack_self(mob/user as mob)
	boutput(user, "<span class='notice'>You flip the coin</span>")
	SPAWN_DBG(1 SECOND)
		if(prob(49))
			boutput(user, "<span class='notice'>It comes up heads</span>")
		else if(prob(49))
			boutput(user, "<span class='notice'>It comes up tails</span>")
		else
			boutput(user, "<span class='alert'>It lands on its side, fuck</span>")

/obj/item/coin/throw_impact(atom/hit_atom)
	..(hit_atom)
	var/p = rand(100)
	if(p < 50)
		src.visible_message("<span class='notice'>The coin comes up heads</span>")

	else if(p < 99)
		src.visible_message("<span class='notice'>The coin comes up tails</span>")
	else
		src.visible_message("<span class='notice'>The coin lands on its side</span>")

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
