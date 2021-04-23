/obj/kitchenspike
	name = "a meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = 0

/obj/kitchenspike/attackby(obj/item/grab/G as obj, mob/user as mob)
	if(!istype(G, /obj/item/grab))
		return
	if(!ismonkey(G.affecting))
		boutput(user, "<span class='alert'>They are too big for the spike, try something smaller!</span>")
		return

	if(src.occupied == 0)
		src.icon_state = "spikebloody"
		src.occupied = 1
		src.meat = 5
		var/mob/dead/observer/newmob
		src.visible_message("<span class='alert'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>")
		if (G.affecting.client)
			newmob = new/mob/dead/observer(G.affecting)
			G.affecting:client:mob = newmob
		G.affecting.unequip_all()
		qdel(G.affecting)
		qdel(G)
		JOB_XP(user, "Chef", 2)

	else
		boutput(user, "<span class='alert'>The spike already has a monkey on it, finish collecting his meat first!</span>")

/obj/kitchenspike/attack_hand(mob/user as mob)
	if(..())
		return
	if(src.occupied)
		if(src.meat > 1)
			src.meat--
			new /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat( src.loc )
			boutput(user, "You remove some meat from the monkey.")
		else if(src.meat == 1)
			src.meat--
			new /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat(src.loc)
			boutput(user, "You remove the last piece of meat from the monkey!")
			src.icon_state = "spike"
			src.occupied = 0
