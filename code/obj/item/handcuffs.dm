/obj/item/handcuffs
	name = "handcuffs"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 5
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	m_amt = 500
	var/strength = 2
	var/delete_on_last_use = 0 // Delete src when it's used up (e.g. tape roll)?
	var/apply_multiplier = 1
	var/remove_self_multiplier = 1
	var/remove_other_multiplier = 1
	desc = "Adjustable metal rings joined by cable, made to be applied to a person in such a way that they are unable to use their hands. Difficult to remove from oneself."
	custom_suicide = 1

/obj/item/handcuffs/setMaterial(var/datum/material/mat1, var/appearance = TRUE, var/setname = TRUE, var/mutable = FALSE, var/use_descriptors = FALSE)
	..()
	if (mat1.getID() == "silver")
		name = "silver handcuffs"
		icon_state = "handcuff-silver"
		desc = "These handcuffs are perfect for containing evil creatures, but they're fragile otherwise as a result."
		strength = 1

/obj/item/handcuffs/examine()
	. = ..()
	if (src.delete_on_last_use)
		. += "There are [src.amount] lengths of [istype(src, /obj/item/handcuffs/tape_roll) ? "tape" : "ziptie"] left!"

/obj/item/handcuffs/suicide(var/mob/living/carbon/human/user as mob) //brutal
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	if (istype(src,/obj/item/handcuffs/tape_roll) || istype(src,/obj/item/handcuffs/tape)) // shout out once again to the hasvar bullshit that was here
		return 0
	user.canmove = 0
	user.visible_message(SPAN_ALERT("<b>[user] jams one end of [src] into one of [his_or_her(user)] eye sockets, closing the loop through the other!"))
	playsound(user, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, TRUE)
	user.emote("scream")
	SPAWN(1 SECOND)
		user.visible_message(SPAN_ALERT("<b>[user] yanks the other end of [src] as hard as [he_or_she(user)] can, ripping [his_or_her(user)] skull clean out of [his_or_her(user)] head! [pick("Jesus christ!","Holy shit!","What the fuck!?","Oh my god!")]</b>"))
		var/obj/skull = user.organHolder.drop_organ("skull")
		if (skull)
			skull.set_loc(user.loc)
		make_cleanable( /obj/decal/cleanable/blood,user.loc)
		playsound(user, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, TRUE)
		health_update_queue |= user

/* do not do this thing here:
		for (var/mob/O in AIviewers(user, null)) // loop through all mobs that can see user kill themself
			if (O != user && ishuman(O) && prob(33)) // make sure O isn't user, then make sure they're human?
				//why didn't we just loop through /mob/living/carbon/human in the first place instead of all mobs?
				O.show_message(SPAN_ALERT("You feel ill from watching that.")) // O is grossed out
				for (var/mob/V in viewers(O, null)) // loop through all the mobs that can see O locally
					V.show_message(SPAN_ALERT("[O.name] pukes all over \himself. Thanks, [user.name]."), 1) // tell them that O puked
					playsound(O.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1) // play a sound where O is
					make_cleanable( /obj/decal/cleanable/vomit,O.loc) // make a vomit decal where O
					// these last two parts are within the for loop so that means that for EVERY MOB THAT SEES THIS, A SOUND AND DECAL ARE MADE
*/
		for (var/mob/living/carbon/human/O in AIviewers(user, null))
			if (O != user && prob(33))
				var/vomit_message = SPAN_ALERT("[O] pukes all over [himself_or_herself(O)].")
				O.vomit(0, null, vomit_message)

		SPAWN(0.5 SECONDS)
			if (user && skull)
				var/obj/brain = user.organHolder.drop_organ("brain")
				if (brain)
					brain.set_loc(skull.loc)
					brain.visible_message(SPAN_ALERT("<b>[brain] falls out of the bottom of [skull].</b>"))

		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
				user.canmove = 1
	return 1

/obj/item/handcuffs/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	src.try_cuff(target, user)

/obj/item/handcuffs/proc/try_cuff(mob/M, mob/user, instant = FALSE)
	if(HAS_ATOM_PROPERTY(user, PROP_MOB_PRE_POSSESSION) && M == user)
		boutput(user, SPAN_ALERT("A mysterious force grips your limbs, flinging [src] away!"))
		user.drop_item_throw(src)

	if (user?.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
		boutput(user, SPAN_ALERT("Uh ... how do those things work?!"))
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (!H.limbs || !H.limbs.l_arm || !H.limbs.r_arm)
				return
			M = user
			JOB_XP(user, "Clown", 1)
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (isabomination(H))
			boutput(user, SPAN_ALERT("You can't! There's nowhere to put them!"))
			return

		var/handslost = !istype(H.limbs.l_arm,/obj) + !istype(H.limbs.r_arm,/obj)
		switch(handslost)
			if (1)
				boutput(user, SPAN_ALERT("[H.name] only has one arm, you still try to handcuff [him_or_her(H)]!"))
			if (2)
				boutput(user, SPAN_ALERT("[H.name] has no arms, you can't handcuff [him_or_her(H)]!"))
				return

		if (H.hasStatus("handcuffed"))
			boutput(user, SPAN_ALERT("[H] is already handcuffed"))
			return

		playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
		if (instant)
			src.cuff(M)
		else
			actions.start(new/datum/action/bar/icon/handcuffSet(H, src), user)

/obj/item/handcuffs/proc/cuff(mob/living/carbon/human/target)
	src.set_loc(target)
	target.handcuffs = src
	target.drop_from_slot(target.r_hand)
	target.drop_from_slot(target.l_hand)
	target.drop_juggle()
	target.setStatus("handcuffed", duration = INFINITE_STATUS)
	target.update_clothing()

/obj/item/handcuffs/New()
	..()
	BLOCK_SETUP(BLOCK_ROPE)

/obj/item/handcuffs/disposing()
	if (ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		H.set_clothing_icon_dirty()
	..()

/obj/item/handcuffs/proc/werewolf_cant_rip()
	.= src.material?.getID() == "silver"

/obj/item/handcuffs/proc/drop_handcuffs(mob/user)
	user.handcuffs = null
	user.delStatus("handcuffed")
	user.drop_item(src)
	user.update_clothing()
	if (src.strength == 1) // weak cuffs break
		if (src.material && src.material.getID() == "silver")
			src.visible_message(SPAN_ALERT("[src] disintegrate."))
		else if ((istype(src, /obj/item/handcuffs/guardbot)))
			src.visible_message(SPAN_ALERT("[src] biodegrade instantly. [prob (10) ? "DO NOT QUESTION THIS" : null]"))
		else
			src.visible_message(SPAN_ALERT("[src] break apart."))
		qdel(src)

/obj/item/handcuffs/proc/destroy_handcuffs(mob/user)
	user.handcuffs = null
	user.delStatus("handcuffed")
	user.update_clothing()
	qdel(src)

/obj/item/handcuffs/tape_roll
	name = "ducktape"
	desc = "A convenient and illegal source of makeshift handcuffs."
	icon_state = "ducktape"
	c_flags = ONBELT
	m_amt = 200
	amount = 10
	delete_on_last_use = TRUE

/obj/item/handcuffs/tape_roll/crappy
	name = "masking tape"
	delete_on_last_use = FALSE
	apply_multiplier = 2
	remove_self_multiplier = 0.125

/obj/item/handcuffs/tape
	desc = "These seem to be made of tape"
	strength = 1

/obj/item/handcuffs/guardbot
	name = "ziptie cuffs"
	desc = "A wrist-binding tie made from a durable synthetic material.  Weaker than traditional handcuffs, but much more comfortable."
	icon_state = "buddycuff"
	m_amt = 0
	strength = 1
