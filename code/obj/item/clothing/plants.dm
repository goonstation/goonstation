/obj/item/clothing/head/rafflesia
	name = "rafflesia"
	desc = "Usually referred to as corpseflower due to its horrid odor. Perfect for masking the smell of your stinky head."
	icon_state = "rafflesiahat"
	item_state = "rafflesiahat"

/obj/item/clothing/head/flower
	name = "flower"
	desc = "A pretty nice flower... you shouldn't see this, though."
	icon_state = "flower_gard"
	item_state = "flower_gard"
	flags = SUPPRESSATTACK
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	var/datum/forensic_id/sleuth_scent = null // What the flower smells like

	New()
		var/s_color = src.pick_sleuth_scent()
		if(s_color)
			src.sleuth_scent = register_id(s_color)
			apply_scent(src, src.sleuth_scent)
		..()

	equipped(mob/user, slot)
		..()
		apply_scent(user, src.sleuth_scent)

	afterattack(atom/target, mob/user, reach, params)
		..()
		apply_scent(target, src.sleuth_scent)
		var/waves = pick("waves","shakes","flutters","twirls","whirls","dances")
		var/around = pick("around","by","about","all over","beside","throughout")
		user.visible_message("[user] [waves] \the [src] [around] \the [target].")
		playsound(src, 'sound/impact_sounds/Bush_Hit.ogg', 20, TRUE, 0, 2)

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		HYPadd_harvest_reagents(src,origin_plant,passed_genes,quality_status)
		return src

	proc/pick_sleuth_scent()
		return null

	proc/apply_scent(var/atom/target, var/datum/forensic_id/scent)
		if(!scent)
			return
		var/datum/forensic_data/basic/f_data
		if(src == target)
			f_data = new(scent, flags = FORENSIC_FAKE)
			f_data.time_end = INFINITY
		else
			f_data = new(scent, flags = FORENSIC_FAKE | FORENSIC_REMOVAL_CLEAN)
		target.add_evidence(f_data, FORENSIC_GROUP_SLEUTH)

/obj/item/clothing/head/flower/gardenia
	name = "gardenia"
	desc = "A delicate flower from the Gardenia shrub native to Earth, trimmed for you to wear. These white flowers are known for their strong and sweet floral scent."
	icon_state = "flower_gard"
	item_state = "flower_gard"

	pick_sleuth_scent()
		return pick_string("colors.txt", "colors") // White flowers == any color?

/obj/item/clothing/head/flower/bird_of_paradise
	name = "bird of paradise"
	desc = "Bird of Paradise flowers, or Crane Flowers, are named for their resemblance to the ACTUAL birds of the same name. Both look great sitting on your head either way."
	icon_state = "flower_bop"
	item_state = "flower_bop"

	pick_sleuth_scent()
		return pick("fuzzy orange", "sky blue")

/obj/item/clothing/head/flower/hydrangea
	name = "hydrangea"
	desc = " Hydrangeas act as natural pH indicators, sporting blue flowers when the soil is acidic and pink ones when the soil is alkaline. They are popular ornamental flowers due to their colorful pastel blooms; this one has been trimmed nicely for wear as an accessory."
	icon_state = "flower_hyd"
	item_state = "flower_hyd"
	var/datum/forensic_id/sleuth_scent_B = null // This flower's subtypes can have two scents at once

	New()
		..()
		apply_scent(src, src.sleuth_scent_B)

	equipped(mob/user, slot)
		..()
		apply_scent(user, src.sleuth_scent_B)

	afterattack(atom/target, mob/user, reach, params)
		..()
		apply_scent(target, src.sleuth_scent_B)

	pick_sleuth_scent()
		return "dusty grey"

/obj/item/clothing/head/flower/hydrangea/pink
	name = "pink hydrangea"
	icon_state = "flower_hyd-pink"
	item_state = "flower_hyd-pink"

	New()
		src.sleuth_scent_B = register_id("candy pink")
		..()

/obj/item/clothing/head/flower/hydrangea/blue
	name = "blue hydrangea"
	icon_state = "flower_hyd-blue"
	item_state = "flower_hyd-blue"

	New()
		src.sleuth_scent_B = register_id("sapphire blue")
		..()

/obj/item/clothing/head/flower/hydrangea/purple
	name = "purple hydrangea"
	icon_state = "flower_hyd-purple"
	item_state = "flower_hyd-purple"

	New()
		src.sleuth_scent_B = register_id("amethyst purple")
		..()

/obj/item/clothing/head/flower/lavender
	name = "lavender"
	desc = "Lavender is usually used as an ingredient or as a source of essential oil; you can tuck a sprig behind your ear for that garden aesthetic too."
	icon_state = "flower_lav"
	item_state = "flower_lav"

	New()
		src.create_reagents(100)
		..()

	pick_sleuth_scent()
		return "lavender purple"

/obj/item/clothing/head/flower/rose
	name = "rose"
	desc = "By any other name, would smell just as sweet. This one likes to be called "
	icon_state = "flower_rose"
	var/thorned = TRUE
	var/backup_name_txt = "names/first.txt"

	proc/possible_rose_names()
		var/list/possible_names = list()
		for(var/mob/M in mobs)
			if(!M.mind)
				continue
			if(ishuman(M))
				if(iswizard(M))
					continue
				if(isnukeop(M))
					continue
				possible_names += M
		return possible_names

	New()
		..()
		var/list/possible_names = possible_rose_names()
		var/rose_name
		if(!length(possible_names))
			rose_name = pick_string_autokey(backup_name_txt)
		else
			var/mob/chosen_mob = pick(possible_names)
			rose_name = chosen_mob.real_name
		desc = desc + rose_name + "."

	attack_hand(mob/user)
		var/mob/living/carbon/human/H = user
		if(istype(H) && src.thorned)
			if (src.thorns_protected(H))
				..()
				return
			if(ON_COOLDOWN(src, "prick_hands", 1 SECOND))
				return
			src.prick(user)
		else
			..()

	proc/thorns_protected(mob/living/carbon/human/H)
		if (H.hand)//gets active arm - left arm is 1, right arm is 0
			if (istype(H.limbs.l_arm,/obj/item/parts/robot_parts) || istype(H.limbs.l_arm,/obj/item/parts/human_parts/arm/left/synth))
				return TRUE
		else
			if (istype(H.limbs.r_arm,/obj/item/parts/robot_parts) || istype(H.limbs.r_arm,/obj/item/parts/human_parts/arm/right/synth))
				return TRUE
		if(H.gloves)
			return TRUE

	proc/prick(mob/M)
		boutput(M, "<span class='alert'>You prick yourself on [src]'s thorns trying to pick it up!</span>")
		random_brute_damage(M, 3)
		take_bleeding_damage(M, null, 3, DAMAGE_STAB)

	attackby(obj/item/W, mob/user)
		if (issnippingtool(W) && src.thorned)
			boutput(user, "<span class='notice'>You snip off [src]'s thorns.</span>")
			src.thorned = FALSE
			src.desc += " Its thorns have been snipped off."
			return
		..()

	attack(mob/living/carbon/human/M, mob/user, def_zone)
		if (istype(M) && !(M.head?.c_flags & BLOCKCHOKE) && def_zone == "head")
			M.tri_message(user, "<span class='alert'>[user] holds [src] to [M]'s nose, letting [him_or_her(M)] take in the fragrance.</span>",
				"<span class='alert'>[user] holds [src] to your nose, letting you take in the fragrance.</span>",
				"<span class='alert'>You hold [src] to [M]'s nose, letting [him_or_her(M)] take in the fragrance.</span>"
			)
			return TRUE
		..()

	pickup(mob/user)
		. = ..()
		if(ishuman(user) && src.thorned && !src.thorns_protected(user))
			src.prick(user)
			SPAWN(0.1 SECONDS)
				user.drop_item(src, FALSE)

	pick_sleuth_scent()
		return "blood red"

/obj/item/clothing/head/flower/rose/poisoned
	///Trick roses don't poison on attack, only on pickup
	flags = 0
	hide_attack = ATTACK_VISIBLE
	var/trick = FALSE
	attack(mob/M, mob/user, def_zone)
		if (!..() || is_incapacitated(M) || src.trick)
			return
		src.poison(M)

	prick(mob/user)
		..()
		src.poison(user)

	proc/poison(mob/M)
		if (!M.reagents?.has_reagent("capulettium"))
			if (M.mind?.assigned_role == "Mime")
				//since this is used for faking your own death, have a little more reagent
				M.reagents?.add_reagent("capulettium_plus", 20)
				//mess with medics a little
				M.bioHolder.AddEffect("dead_scan", timeleft = 40 SECONDS, do_stability = FALSE, magical = TRUE)
			else
				M.reagents?.add_reagent("capulettium", 13)
		//DO NOT add the SECONDS define to this, bioHolders are cursed and don't believe in ticks
		M.bioHolder?.AddEffect("mute", timeleft = 40, do_stability = FALSE, magical = TRUE)

	pick_sleuth_scent()
		return "jade green"

/obj/item/clothing/head/flower/rose/holorose
	name = "holo rose"
	desc = "A holographic display of a Rose. This one likes to be called "
	icon_state = "flower_hrose"
	backup_name_txt = "names/ai.txt"

	possible_rose_names()
		var/list/possible_names = list()
		for(var/mob/living/silicon/M in mobs)
			possible_names += M
		return possible_names

	pick_sleuth_scent()
		return null

// Pumpkin hats

/obj/item/clothing/head/pumpkinlatte
	name = "carved spiced pumpkin"
	desc = "Cute!"
	icon_state = "pumpkinlatte"
	c_flags = COVERSEYES | COVERSMOUTH
	see_face = FALSE
	item_state = "pumpkinlatte"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/light/flashlight))
			user.visible_message("[user] adds [W] to [src].", "You add [W] to [src].")
			W.name = copytext(src.name, 8) + " lantern"	// "carved "
			W.desc = "Cute!"
			W.icon = 'icons/misc/halloween.dmi'
			W.icon_state = "flight[W:on]"
			W.item_state = "pumpkin"
			qdel(src)
		else
			. = ..()


/obj/item/clothing/head/pumpkin
	name = "carved pumpkin"
	desc = "Spookier!"
	icon_state = "pumpkin"
	c_flags = COVERSEYES | COVERSMOUTH
	see_face = FALSE
	item_state = "carved"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/light/flashlight))
			user.visible_message("[user] adds [W] to [src].", "You add [W] to [src].")
			W.name = copytext(src.name, 8) + " lantern"	// "carved "
			W.desc = "Spookiest!"
			W.icon = 'icons/misc/halloween.dmi'
			W.icon_state = "flight[W:on]"
			W.item_state = "lantern"
			W.transform = src.transform
			qdel(src)
		else
			..()
