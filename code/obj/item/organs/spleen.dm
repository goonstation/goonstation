/obj/item/organ/spleen
	name = "spleen"
	organ_name = "spleen"
	icon_state = "spleen"
	body_side = L_ORGAN


	on_life(var/mult = 1)
		if (!..())
			return 0
		if (donor.blood_volume < 500 && donor.blood_volume > 0) // if we're full or empty, don't bother v
			if (prob(66))
				donor.blood_volume += 1 * mult // maybe get a little blood back ^
			else if (src.robotic)  // garuanteed extra blood with robotic spleen
				donor.blood_volume += 2 * mult
		else if (donor.blood_volume > 500)
			if (prob(20))
				donor.blood_volume -= 1 * mult
		return 1

	on_broken(var/mult = 1)
		donor.blood_volume -= 2 * mult

	disposing()
		if (holder)
			if (holder.spleen == src)
				holder.spleen = null
		..()



	attack(var/mob/living/carbon/M as mob, var/mob/user as mob)
		if (!ismob(M))
			return

		src.add_fingerprint(user)

		if (user.zone_sel.selecting != "chest")
			return ..()
		if (!surgeryCheck(M, user))
			return ..()

		var/mob/living/carbon/human/H = M
		if (!H.organHolder)
			return ..()

		if (!H.organHolder.spleen && H.organHolder.chest && H.organHolder.chest.op_stage == 6.0)

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] chest!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] chest!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your chest!</span>")

			user.u_equip(src)
			H.organHolder.receive_organ(src, "spleen", 3.0)
			H.update_body()

		else
			..()
		return

/obj/item/organ/spleen/cyber
	name = "cyberspleen"
	desc = "A fancy robotic spleen to replace one that someone's lost!"
	icon_state = "cyber-spleen"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6
