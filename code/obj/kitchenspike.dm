TYPEINFO(/obj/kitchenspike)
	mats = 10

/obj/kitchenspike
	name = "a meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = FALSE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR

/obj/kitchenspike/attackby(obj/item/grab/G, mob/user)
	if(!istype(G))
		return
	spike(user, G.affecting)

/obj/kitchenspike/hitby(atom/movable/A, datum/thrown_thing/thr)
	if (!src.spike(null, A))
		return ..()

/obj/kitchenspike/proc/spike(mob/user, mob/victim)
	. = FALSE
	if(!ismonkey(victim))
		boutput(user, "<span class='alert'>[victim] is too big for the spike, try something smaller!</span>")
		return
	if((!isnpcmonkey(victim) || victim.client) && !isdead(victim))
		boutput(user, "<span class='alert'>[victim] looks sentient and is struggling too much!</span>")
		return
	if(!src.occupied)
		src.occupied = TRUE
		src.UpdateIcon()
		src.meat = 5
		if (user)
			src.visible_message("<span class='alert'>[user] forces [victim] onto the spike, killing [him_or_her(victim)] instantly!</span>")
		else
			src.visible_message("<span class='alert'>[victim] is impaled on the spikes, instantly killing [him_or_her(victim)]!")
		victim.unequip_all()
		qdel(victim)
		JOB_XP(user, "Chef", 2)
		return TRUE
	else
		boutput(user, "<span class='alert'>The spike already has a monkey on it, finish collecting their meat first!</span>")
		return

/obj/kitchenspike/attack_hand(mob/user)
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
			src.occupied = FALSE
			src.UpdateIcon()

/obj/kitchenspike/update_icon()
	. = ..()
	if (src.occupied)
		src.icon_state = "spikebloody"
	else
		src.icon_state = "spike"
