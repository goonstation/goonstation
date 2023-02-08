ABSTRACT_TYPE(/obj/item/clothing/head/flower)
/obj/item/clothing/head/flower
// hi flourish. Plant pot stuff for in future can go here i guess.
	max_stack = 10 //this seems about right. Plus, this is also how much can fit into a bouquet.
	var/bouquet_type = /obj/item/bouquet // if no actual bouquet assigned, we use this one

	proc/make_bouquet(obj/item/paperitem, mob/user)
		// first check if it's the right kind of flower, right amount, allocate bouquet
		// have some fail messages
		// make bouquet
		// we do a little storing, put the paper and flowers into flowers_stored and paper_used
		// then we possibly qdel it idk, probably don't need to if we're storing it
		var/flowernum = 2
		var/obj/item/bouquet/bouquet_dummy = src.bouquet_type
		if (istype_exact(bouquet_dummy, /obj/item/bouquet))
			user.visible_message("This flower can't be turned into a bouquet!")
			return
		if (!istype(bouquet_dummy, /obj/item/bouquet))
			CRASH("Somehow, this flower has no real bouquet type. [src]")
		if (src.amount < bouquet_dummy.min_flowers)
			user.visible_message("You need more than one flower to make a bouquet!")
			return
		if (src.amount <= bouquet_dummy.max_flowers)
			flowernum = src.amount
		else
			flowernum = bouquet_dummy.max_flowers
			// if too many flowers we just take the max flowers out of the stack, usually 10
		var/obj/item/bouquet/new_bouquet = new src.bouquet_type(user.loc)
		new_bouquet.paper_used = paperitem
		new_bouquet.flowers_stored = src.split_stack(flowernum)
		user.visible_message("[user] rolls up [flowernum] [src]s into a bouquet.", "You roll up the [src]s.")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/paper))
			make_bouquet(src, W, user)
/obj/item/clothing/head/flower/rafflesia
	name = "rafflesia"
	desc = "Usually reffered to as corpseflower due to its horrid odor, perfect for masking the smell of your stinky head."
	icon_state = "rafflesiahat"
	item_state = "rafflesiahat"

/obj/item/clothing/head/flower/gardenia
	name = "gardenia"
	desc = "A delicate flower from the Gardenia shrub native to Earth, trimmed for you to wear. These white flowers are known for their strong and sweet floral scent."
	icon_state = "flower_gard"
	item_state = "flower_gard"

/obj/item/clothing/head/flower/bird_of_paradise
	name = "bird of paradise"
	desc = "Bird of Paradise flowers, or Crane Flowers, are named for their resemblance to the ACTUAL birds of the same name. Both look great sitting on your head either way."
	icon_state = "flower_bop"
	item_state = "flower_bop"

/obj/item/clothing/head/flower/hydrangea
	name = "hydrangea"
	desc = "Hydrangeas are popular ornamental flowers due to their colourful, pastel flower arrangements; this one has been trimmed nicely for wear as an accessory."
	icon_state = "flower_hyd"
	item_state = "flower_hyd"
	pink
		name = "pink hydrangea"
		icon_state = "flower_hyd-pink"
		item_state = "flower_hyd-pink"
	blue
		name = "blue hydrangea"
		icon_state = "flower_hyd-blue"
		item_state = "flower_hyd-blue"
	purple
		name = "purple hydrangea"
		icon_state = "flower_hyd-purple"
		item_state = "flower_hyd-purple"

/obj/item/clothing/head/flower/lavender
	name = "lavender"
	desc = "Lavender is usually used as an ingredient or as a source of essential oil; you can tuck a sprig behind your ear for that garden aesthetic too."
	icon_state = "flower_lav"
	item_state = "flower_lav"
	bouquet_type = /obj/item/bouquet/lavender

	New()
		src.create_reagents(100)
		..()

/obj/item/clothing/head/flower/rose
	name = "rose"
	desc = "By any other name, would smell just as sweet. This one likes to be called "
	icon_state = "rose"
	var/thorned = TRUE
	var/backup_name_txt = "names/first.txt"
	bouquet_type = /obj/item/bouquet/rose

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

/obj/item/clothing/head/flower/rose/poisoned
	///Trick roses don't poison on attack, only on pickup
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

/obj/item/clothing/head/flower/rose/holorose
	name = "holo rose"
	desc = "A holographic display of a Rose. This one likes to be called "
	icon_state = "holorose"
	backup_name_txt = "names/ai.txt"

	possible_rose_names()
		var/list/possible_names = list()
		for(var/mob/living/silicon/M in mobs)
			possible_names += M
		return possible_names

// I'm putting the bouquet code here because for some reason bouquet.dm wasnt compiling
ABSTRACT_TYPE(/obj/item/bouquet)
/obj/item/bouquet
	name = "abstract bouquet"
	desc = "If you're seeing this, something's wrong"
	var/paper_used = null
	var/flowers_stored = null
	var/max_flowers = 10 // 10 seems like a reasonable amount for now, lets not have 99 flowers in one bouquet
	var/min_flowers = 2 // can't have a bouquet with only one flower
	var/flower_type_used = null
	attackby(/obj/item/W, mob/user)
		// should give us back the paper and flowers when done with snipping tool
		// actually this should be under dispose shouldnt it
		if (issnippingtool(W))
			boutput(user, "<span class='notice'>You disassemble the [src].</span>")
			playsound(src.loc, 'sound/items/Scissor.ogg', 30, 1)
			// how do i make it spit out things
			qdel(src)

/obj/item/bouquet/lavender
	name = "lavender bouquet"
	desc = "They smell pretty, and the purple can't be beat."
	icon_state = "bouquet_lavender"
	item_state = "bouquet_lavender"
	flower_type_used = /obj/item/clothing/head/flower/lavender

/obj/item/bouquet/rose
	name = "rose bouquet"
	desc = "Red is the color of passion; or, of the medbay."
	icon_state = "bouquet_rose"
	item_state = "bouquet_rose"
	flower_type_used = /obj/item/clothing/head/flower/rose

//obj/item/bouquet/mixed
// this can be done later if needed
