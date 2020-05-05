/obj/item/organ/intestines
	name = "intestines"
	organ_name = "intestines"
	desc = "Did you know that if you laid your guts out in a straight line, they'd be about 9 meters long? Also, you'd probably be dying, so it's not something you should do. Probably."
	icon_state = "intestines"

	// on_transplant()
	// 	..()
	// 	if (src.donor)
	// 		for (var/datum/ailment_data/disease in src.donor.ailments)
	// 			if (disease.cure == "Intestine Transplant")
	// 				src.donor.cure_disease(disease)
	// 		return


	disposing()
		if (holder)
			if (holder.intestines == src)
				holder.intestines = null
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

		if (!H.organHolder.intestines && H.organHolder.chest && H.organHolder.chest.op_stage == 4.0)

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] chest!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] chest!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your chest!</span>")

			user.u_equip(src)
			H.organHolder.receive_organ(src, "intestines", 3.0)
			H.update_body()

		else
			..()
		return

/obj/item/organ/intestines/cyber
	name = "cyberintestines"
	desc = "A fancy robotic intestines to replace one that someone's lost!"
	icon_state = "cyber-intestines"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6

