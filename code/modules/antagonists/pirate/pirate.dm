/datum/antagonist/pirate
	id = ROLE_PIRATE
	display_name = "\improper Pirate"

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			boutput(src.owner.current, "<span class='alert'>Due to your lack of opposable thumbs, the pirates were unable to provide you with your equipment. That's biology for you.</span>")
			return FALSE
		var/mob/living/carbon/human/H = src.owner.current
		var/obj/trinket
		if (H.trinket)
			trinket = H.trinket.deref()
			trinket.set_loc(null)
		H.unequip_all(TRUE)

		if (id == ROLE_PIRATE_CAPTAIN)
			H.equip_if_possible(new /obj/item/clothing/under/shirt_pants_b(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/suit/armor/pirate_captain_coat(H), H.slot_wear_suit)
			H.equip_if_possible(new /obj/item/clothing/head/pirate_captain(H), H.slot_head)
			H.equip_if_possible(new /obj/item/clothing/shoes/swat/heavy(H), H.slot_shoes)
			H.equip_if_possible(new /obj/item/device/radio/headset/pirate/captain(H), H.slot_ears)

		else if (id == ROLE_PIRATE_FIRST_MATE)
			H.equip_if_possible(new /obj/item/clothing/under/gimmick/guybrush(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/suit/armor/pirate_first_mate_coat(H), H.slot_wear_suit)
			H.equip_if_possible(new /obj/item/clothing/head/pirate_first_mate(H), H.slot_head)
			H.equip_if_possible(new /obj/item/device/radio/headset/pirate/first_mate(H), H.slot_ears)

		else if (id == ROLE_PIRATE)
			// Random clothing:
			var/obj/item/clothing/jumpsuit = pick(/obj/item/clothing/under/gimmick/waldo,
							/obj/item/clothing/under/misc/serpico,
							/obj/item/clothing/under/gimmick/guybrush,
							/obj/item/clothing/under/misc/dirty_vest)
			var/obj/item/clothing/hat = pick(/obj/item/clothing/head/red,
							/obj/item/clothing/head/bandana/red,
							/obj/item/clothing/head/pirate_brn,
							/obj/item/clothing/head/pirate_blk)

			H.equip_if_possible(new jumpsuit, H.slot_w_uniform)
			H.equip_if_possible(new hat, H.slot_head)
			H.equip_if_possible(new /obj/item/device/radio/headset/pirate(H), H.slot_ears)

		H.equip_if_possible(new /obj/item/storage/backpack(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/shoes/swat(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/reagent_containers/food/drinks/flask/pirate(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/pinpointer/gold_bee(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/clothing/glasses/eyepatch/pirate(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/requisition_token/pirate(H), H.slot_r_store)
		H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(H), H.slot_l_store)
		H.equip_if_possible(new /obj/item/swords_sheaths/pirate(H), H.slot_belt)

		H.equip_sensory_items()

		H.traitHolder.addTrait("training_drinker")


	first_mate
		id = ROLE_PIRATE_FIRST_MATE
		display_name = "\improper Pirate First Mate"

	captain
		id = ROLE_PIRATE_CAPTAIN
		display_name = "\improper Pirate Captain"


/obj/gold_bee
	name = "\improper Gold Bee Statue"
	desc = "The artist has painstainkly sculpted every individual strand of bee wool to achieve this breath-taking result. You could almost swear this bee is about to spontaneously take flight."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gold_bee"
	flags = FPRINT | FLUID_SUBMERGE | TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER
	density = 1
	anchored = UNANCHORED
	var/list/gibs = list()

	New()
		..()
		src.setMaterial(getMaterial("gold"), appearance = 0, setname = 0)
		for(var/i in 1 to 7)
			gibs.Add(new /obj/item/stamped_bullion)
			gibs.Add(new /obj/item/raw_material/gold)

	attack_hand(mob/user)
		src.add_fingerprint(user)

		if (user.a_intent != INTENT_HARM)
			src.visible_message("<span class='notice'><b>[user]</b> pets [src]!</span>")

	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src

		src.visible_message("<span class='combat'><b>[user]</b> hits [src] with [W]!</span>")
		src.take_damage(W.force / 3)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
		attack_particle(user, src)

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)

		src.visible_message("<span class='combat'><b>[src]</b> is hit by [P]!</span>")
		if (damage <= 0)
			return
		if(P.proj_data.damage_type == D_KINETIC || (P.proj_data.damage_type == D_ENERGY && damage))
			src.take_damage(damage / 3)
		else if (P.proj_data.damage_type == D_PIERCING)
			src.take_damage(damage)

	proc/take_damage(var/amount)
		if (!isnum(amount) || amount < 1)
			return
		src._health = max(0,src._health - amount)

		if (src._health < 1)
			src.visible_message("<span class='alert'><b>[src]</b> breaks and shatters into many peices!</span>")
			playsound(src.loc, 'sound/impact_sounds/plate_break.ogg', 50, 0.1, 0, 0.5)
			if (length(gibs))
				for (var/atom/movable/I in gibs)
					I.set_loc(get_turf(src))
					ThrowRandom(I, 3, 1)
			qdel(src)
