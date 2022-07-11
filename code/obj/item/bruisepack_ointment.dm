/obj/item/medical
	name = "medical pack"
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	amount = 5
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0
	stamina_damage = 3
	stamina_cost = 3
	stamina_crit_chance = 3

	examine()
		. = ..()
		. += "[bicon(src)] <span class='notice'>There [src.amount == 1 ? "is" : "are"] [src.amount] [src.name]\s left on the stack!</span>"

	attack_hand(mob/user)
		if (user.r_hand == src || user.l_hand == src)
			src.add_fingerprint(user)
			var/obj/item/medical/split = new src.type(user)
			split.amount = 1
			user.put_in_hand_or_drop(split)

			src.amount--
			if (src.amount < 1)
				qdel(src)
				return
		else
			..()
			return

	attackby(obj/item/medical/W, mob/user)
		if (!istype(W, src.type))
			return

		if (W.amount == 5)
			return

		if (W.amount + src.amount > 5)
			src.amount = (W.amount + src.amount) - 5
			W.amount = 5
		else
			W.amount += src.amount
			qdel(src)
		return

	attack(mob/M, mob/user)
		if (issilicon(M))
			if (prob(5))
				user.show_text("I'm a doctor, not a mechanic.", "red")
			else
				user.show_text("You can't seem to find any flesh on this patient.", "red")
			return
		if (user)
			if (M != user)
				M.visible_message("<span class='alert'>[user] applies [src] to [M].</span>",)
			else
				M.visible_message("<span class='alert'>[M] applies [src] to [himself_or_herself(M)].</span>")

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/affecting = H.organs["chest"]

			if (ishuman(user))
				var/mob/living/carbon/human/user2 = user
				var/t = user2.zone_sel.selecting

				if (H.organs[t])
					affecting = H.organs[t]
			else
				if (!isitem(affecting) || affecting:burn_dam <= 0)
					affecting = H.organs["head"]
					if (!isitem(affecting) || affecting:burn_dam <= 0)
						affecting = H.organs["chest"]

			if (affecting.heal_damage(src.heal_brute, src.heal_burn))
				H.UpdateDamageIcon()

				if (M != user && ishuman(M) && ishuman(user))
					if (M.gender != user.gender)
						M.unlock_medal("Oh, Doctor!", 1)
						user.unlock_medal("Oh, Doctor!", 1)
			else
				health_update_queue |= H
		else
			M.HealDamage("All", src.heal_brute, src.heal_burn)

		repair_bleeding_damage(M, 50, 1)

		src.amount--
		if (src.amount <= 0)
			qdel(src)
		return

/obj/item/medical/bruise_pack
	name = "bruise pack"
	desc = "A pack designed to treat blunt-force trauma."
	icon_state = "brutepack"
	heal_brute = 60

	cyborg
		name = "Tissue Mender"
		heal_brute = 60
		amount = INFINITY

/obj/item/medical/ointment
	name = "ointment"
	icon_state = "ointment"
	heal_burn = 40
	desc = "A topical ointment designed to heal burns."

	cyborg
		name = "Burn Salve Dispenser"
		heal_burn = 40
		amount = INFINITY
