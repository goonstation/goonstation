//I have drudged this from the depths of mport's shitcode hell.
//If it works, it works. You can make it less shit if you are really that bothered.

/mob/living/carbon/human/welder
	real_name = "The Welder"
	name = "The Welder"
	var/welder_damage = 1
	var/welder_lastupgrade

	handle_regular_sight_updates()
		src.sight |= SEE_TURFS
		src.sight |= SEE_MOBS
		src.sight |= SEE_OBJS
		src.see_in_dark = 8
		src.see_invisible = 2
		return

	New()
		welder_lastupgrade = world.time
		..()


/mob/living/carbon/human/welder/Life(datum/controller/process/mobs/parent)
	..()

	if(world.time - welder_lastupgrade > 1200)
		if(src && src.mind && src.mind.welder_knife)
			welder_lastupgrade = world.time
			var/obj/item/knife/welder/K = locate(src.mind.welder_knife)
			K.damage_level++
			src << "\bold You feel the power emnating from your knife increase!"


/mob/proc/make_welder()
	if (iswelder(src))
		src.give_welder_power(1)
		src.give_welder_power(2)
		src.give_welder_power(4)
		src.give_welder_power(5)
		src.give_welder_power(7)
	else
		src.give_welder_power(3)
	src.name = "The Welder"
	src.real_name = "The Welder"
	src.bioHolder.AddEffect("breathless", 0, 0, 1)
	return


/mob/proc/remove_welder_power(var/power_id = 0)
	switch(power_id)
		if(0)
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_ghost
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_form
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_resist
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_doorbust
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_portal
		if(2)
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_ghost
		if(3)
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_form
		if(4)
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_resist
		if(5)
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_doorbust
		if(7)
			src.verbs -= /mob/living/carbon/human/welder/proc/welder_portal

/mob/proc/give_welder_power(var/power_id = 0)
	switch(power_id)
		if(2)
			src.verbs += /mob/living/carbon/human/welder/proc/welder_ghost
		if(3)
			src.verbs += /mob/living/carbon/human/welder/proc/welder_form
		if(4)
			src.verbs += /mob/living/carbon/human/welder/proc/welder_resist
		if(5)
			src.verbs += /mob/living/carbon/human/welder/proc/welder_doorbust
		if(7)
			src.verbs += /mob/living/carbon/human/welder/proc/welder_portal

/mob/living/carbon/human/welder/proc/welder_ghost()
	set category = "Welder Verbs"
	set name = "Welder Ghost"
	set desc= "Ghosts you"

	if(src.mind.welder_knife)
		var/obj/item/knife/welder/K = locate(src.mind.welder_knife)
		if(K)
			qdel(K)
	var/mob/dead/observer/O = new/mob/dead/observer(src)
	src.mind.transfer_to(O)
	O.make_welder()
	SPAWN_DBG(1 SECOND)
		if(!src.client)
			qdel(src)

/mob/living/carbon/human/welder/proc/welder_form()
	set category = "Welder Verbs"
	set name = "Welder Appear"
	set desc= "You take your humanish form"


	var/mob/living/carbon/human/welder/mob = new /mob/living/carbon/human/welder(src.loc)
	SPAWN_DBG(0.5 SECONDS)
		var/obj/item/device/radio/R = new /obj/item/device/radio/headset(mob)
		mob.equip_if_possible(R, mob.slot_ears)
		mob.equip_if_possible(new /obj/item/clothing/gloves/black(mob), mob.slot_gloves)
		var/obj/item/clothing/head/helmet/welding/W = new/obj/item/clothing/head/helmet/welding(mob)
		W.cant_self_remove = 1
		W.cant_other_remove = 1
		W.color_r = 1 // less dark
		W.color_g = 1
		W.color_b = 1
		W.nodarken = 1
		W.see_face = 1
		W.setProperty("coldprot", 95)
		W.setProperty("heatprot", 95)
		mob.equip_if_possible(W, mob.slot_head)
		mob.equip_if_possible(new /obj/item/clothing/shoes/black(mob), mob.slot_shoes)
		mob.equip_if_possible(new /obj/item/clothing/suit/armor/vest(mob), mob.slot_wear_suit)
		mob.equip_if_possible(new /obj/item/clothing/under/color(mob), mob.slot_w_uniform)
		if(!src.mind.welder_knife)
			src.mind.welder_knife = "[pick(rand(1, 999))]"
		var/obj/item/knife/welder/K = new/obj/item/knife/welder(mob)
		K.tag = src.mind.welder_knife
		mob.equip_if_possible(K, mob.slot_r_hand)

		src.mind.transfer_to(mob)
		mob.make_welder()
		mob.welder_damage = src.welder_damage

		SPAWN_DBG(1 SECOND)
			if(!src.client)
				del(src)

/mob/living/carbon/human/welder/proc/welder_resist()
	set category = "Welder Verbs"
	set name = "Recover Stun"
	set desc= "You get back up and keep going when stunned"

	if(!isdead(src))
		src.delStatus("stunned")
		src.delStatus("weakened")
		src.delStatus("paralysis")
		src.blinded = 0
		src.lying = 0
		setalive(src)

/mob/living/carbon/human/welder/proc/welder_doorbust()
	set category = "Welder Verbs"
	set name = "Opens nearby doors"
	set desc= "Opens some doors"

	for(var/obj/machinery/door/G in oview(3))
		SPAWN_DBG(1 DECI SECOND)
			G.open()

/mob/living/carbon/human/welder/proc/welder_portal()
	set category = "Welder Verbs"
	set name = "Spawn Portal"
	set desc= "Creates a portal that creates zombies"

	new/obj/hellportal(src.loc)

// Welder knife

/obj/item/knife/welder
	name = "Welder's Knife"
	desc = "Something is wrong about this knife."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife_b"
	item_state = "knife_b"
	force = 20.0
	throwforce = 20.0
	throw_speed = 4
	throw_range = 6
	cant_other_remove = 1
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD
	var/damage_level = 1


/obj/item/knife/welder/attack(target as mob, mob/user as mob)
	var/welder_check = (istype(user:head, /obj/item/clothing/head/helmet/welding)  && istype(user:wear_suit, /obj/item/clothing/suit/armor/vest))
	if(!welder_check)
		random_brute_damage(user, 30*src.damage_level)
		boutput(user,"<span style=\"color:red\">You feel immense pain!</span>")
		user.changeStatus("weakened", 80)
		return

	if (src.damage_level > 4)
		src.damage_level = 4
	src.force = (20*src.damage_level)
	if(hasvar(target,"stunned"))
		target:stunned += 5
	if(hasvar(target,"weakened"))
		target:weakened += 5
	..()


///////////////////////////////////////////// HELLPORTAL

/obj/hellportal
	name = "hell portal"
	desc = "This looks bad."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "whole-massive"
	var/number_left = 5

/obj/hellportal/New()
	SPAWN_DBG(1 SECOND)
		new /obj/effects/void_break(src.loc)
	SPAWN_DBG(1.5 SECONDS)
		critter_spam()

/obj/hellportal/proc/critter_spam()
	for(var/I, I <= number_left, I++)
		var/obj/zomb = new /obj/critter/zombie(src.loc)
		src.visible_message("<span style=\"color:red\"><b> \The [zomb] emerges from \the [src]!</b></span>")
		sleep(25)
	qdel(src)
