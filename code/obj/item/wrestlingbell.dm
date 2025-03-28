/obj/item/wrestlingbell/
	var/obj/machinery/wrestlingbell/parent = null	//temp set while not attached
	w_class = W_CLASS_BULKY

	disposing()
		parent?.hammer = null
		parent = null
		..()

/obj/item/wrestlingbell/hammer
	name = "tiny bell hammer"
	desc = "Notorious violent cousin of teeny tiny hammer."
	icon = 'icons/obj/wrestlingbell.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "bellhammer"
	item_state = "bellhammer"
	flags = TABLEPASS | CONDUCT
	w_class = W_CLASS_TINY
	force = 5
	throwforce = 5
	stamina_damage = 33
	stamina_cost = 18
	stamina_crit_chance = 10

/obj/machinery/wrestlingbell // this is essentially a renamed mounted defib
	name = "Wrestling bell"
	desc = "A bell used to start or stop a round."
	anchored = ANCHORED
	object_flags = NO_GHOSTCRITTER
	density = 1
	var/cooldown = 10 SECONDS
	icon = 'icons/obj/wrestlingbell.dmi'
	icon_state = "wrestlingbell1"
	var/last_ring = 0
	/// tiny hammer when taken out
	var/obj/item/wrestlingbell/hammer/hammer = null

	New()
		..()
		if (!hammer)
			src.hammer = new /obj/item/wrestlingbell/hammer(src)
		RegisterSignal(src.hammer, COMSIG_MOVABLE_MOVED, PROC_REF(hammer_move))

	disposing()
		if (hammer)
			qdel(hammer)
			hammer = null
		..()

	process()
		if(!QDELETED(src.hammer))
			hammer_move()
		else
			src.hammer = null
		..()

	update_icon()
		if (hammer && hammer.loc == src)
			icon_state = "wrestlingbell1"
		else
			icon_state = "wrestlingbell0"

	attack_hand(mob/living/user)
		if (isAI(user) || isintangible(user) || isobserver(user) || !in_interact_range(src, user)) return
		user.lastattacked = src
		..()
		if(!hammer || QDELETED(hammer))
			hammer = null
			return
		if(hammer.loc != src)
			return //if someone else has it, don't put it in user's hand
		user.put_in_hand_or_drop(src.hammer)
		src.hammer.parent = src
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(hammer_move), TRUE)
		UpdateIcon()

	attackby(obj/item/W, mob/living/user)
		user.lastattacked = src
		if (user.a_intent != "harm")
			src.put_back_hammer()
			return
		else if (!ON_COOLDOWN(src, "bell", 20 SECONDS))
			toggle_boxing_mode()

	/// snap back if too far away
	proc/hammer_move()
		if (src.hammer && src.hammer.loc != src)
			if (BOUNDS_DIST(src.hammer, src) > 0)
				src.put_back_hammer()

	proc/put_back_hammer()
		if (src.hammer)
			src.hammer.force_drop(sever=TRUE)
			src.hammer.set_loc(src)
			src.hammer.parent = null

			UpdateIcon()

	proc/toggle_boxing_mode()
		playsound(src.loc, 'sound/misc/Boxingbell.ogg', 50,1)
		for (var/turf/simulated/floor/specialroom/gym/turf in view(10, src))
			for (var/mob/living/carbon/human/human in turf.contents)
				if (human.hasStatus("wrestler"))
					human.delStatus("wrestler")
				else
					human.setStatus("wrestler")


