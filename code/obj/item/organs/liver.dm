/obj/item/organ/liver
	name = "liver"
	organ_name = "liver"
	desc = "Ew, this thing is just the wurst."
	icon_state = "liver"
	failure_disease = /datum/ailment/disease/liver_failure

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

		if (!H.organHolder.liver && H.organHolder.chest && H.organHolder.chest.op_stage == 3.0)

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] chest!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] chest!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your chest!</span>")

			user.u_equip(src)
			H.organHolder.receive_organ(src, "liver", 3.0)
			H.update_body()

		else
			..()
		return

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= FAIL_DAMAGE && prob(src.get_damage() * 0.2))
			donor.contract_disease(failure_disease,null,null,1)
		return 1

	on_broken(var/mult = 1)
		donor.take_toxin_damage(2*mult, 1)				


	disposing()
		if (holder)
			if (holder.liver == src)
				holder.liver = null
		..()

/obj/item/organ/liver/cyber
	name = "cyberliver"
	desc = "A fancy robotic liver to replace one that someone's lost!"
	icon_state = "cyber-liver"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6
