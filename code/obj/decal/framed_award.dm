///////////////////////////////////////
// AZUNGAR'S HEAD OF DEPARTMENT ITEMS// + FIREBARRAGE HELPED TOO BUT HE SMELLS
///////////////////////////////////////

#define FRAME_HAS_GLASS_HAS_AWARD 0
#define FRAME_NO_GLASS_HAS_AWARD 1
#define FRAME_NO_GLASS_NO_AWARD 2

/obj/decal/poster/wallsign/framed_award
	name = "A framed award"
	desc = "Just some generic award"
	var/award_text = null
	var/obj/item/award_type = /obj/item/rddiploma
	var/award_name ="diploma"
	var/usage_state = FRAME_HAS_GLASS_HAS_AWARD
	var/owner_job = "Research Director"
	var/icon_glass = "rddiploma1"
	var/icon_award = "rddiploma"
	var/icon_empty = "frame"
	var/glass_type = /obj/item/sheet/glass
	var/obj/item/award_item
	icon_state = "rddiploma"
	pixel_y = -6

	New()
		..()
		src.award_item = new award_type(src)
		src.award_item.desc = src.desc

	get_desc()
		if(award_text)
			return award_text
		else
			// Do we have a player of the right job?
			for(var/mob/living/carbon/human/player in mobs)
				if(!player.mind)
					continue
				if(player.mind.assigned_role == owner_job)
					award_text = src.get_award_text(player.mind)
					return award_text


	attack_hand(mob/user)
		if (user.stat || isghostdrone(user) || !isliving(user))
			return

		switch (usage_state)
			if (FRAME_HAS_GLASS_HAS_AWARD)
				if (issilicon(user)) return
				src.usage_state = FRAME_NO_GLASS_HAS_AWARD
				src.icon_state = icon_glass
				user.visible_message("[user] takes off the glass frame.", "You take off the glass frame.")
				var/obj/item/sheet/glass/G = new glass_type()
				G.amount = 1
				src.add_fingerprint(user)
				user.put_in_hand_or_drop(G)

			if (FRAME_NO_GLASS_HAS_AWARD)
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				if(istype(src.award_item) && src.award_item.loc == src)
					src.award_item.desc = src.desc
					user.put_in_hand_or_drop(src.award_item)
					user.visible_message("[user] takes the [award_name] from the frame.", "You take the [award_name] out of the frame.")
					src.icon_state = icon_empty
					src.add_fingerprint(user)
					src.usage_state = FRAME_NO_GLASS_NO_AWARD

	attackby(obj/item/W, mob/user)
		if (user.stat)
			return

		if (src.usage_state == FRAME_NO_GLASS_NO_AWARD)
			if (istype(W, src.award_type))
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				user.u_equip(W)
				W.set_loc(src)
				user.visible_message("[user] places the [award_name] back in the frame.", "You place the [award_name] back in the frame.")
				src.usage_state = FRAME_NO_GLASS_HAS_AWARD
				src.icon_state = icon_glass

		if (src.usage_state == FRAME_NO_GLASS_HAS_AWARD)
			if (istype(W, /obj/item/sheet/glass))
				if (W.amount >= 1)
					src.glass_type = W.type
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					user.u_equip(W)
					qdel(W)
					user.visible_message("[user] places glass back in the frame.", "You place the glass back in the frame.")
					src.usage_state = FRAME_HAS_GLASS_HAS_AWARD
					src.icon_state = icon_award


	proc/get_award_text(var/datum/mind/M)
		. = "Awarded to some chump for achieving something."

/obj/decal/poster/wallsign/framed_award/hos_medal
	name = "framed medal"
	desc = "A dusty old war medal."
	award_type = /obj/item/clothing/suit/security_badge/hosmedal // stored in suits.dm
	award_name = "medal"
	owner_job = "Head of Security"
	icon_glass = "medal1"
	icon_award = "medal"
	icon_empty = "frame"
	icon_state = "medal"

	New()
		..()
		if (istype(src.award_item, src.award_type))
			var/obj/item/clothing/suit/security_badge/hosmedal/medal = src.award_item
			medal.award_text = src.get_award_text()

	attackby(obj/item/W, mob/user)
		if (user.stat)
			return

		if (istype(W, /obj/item/diary))
			var/obj/item/paper/book/from_file/space_law/first/newbook = new /obj/item/paper/book/from_file/space_law/first
			user.u_equip(W)
			user.put_in_hand_or_drop(newbook)
			boutput(user, SPAN_ALERT("Beepsky's private journal transforms into Space Law 1st Print."))
			qdel(W)

		..()

	get_award_text(var/datum/mind/M)
		var/hosname = "Anonymous"
		if(M?.current?.client?.preferences?.name_last)
			hosname = M.current.client.preferences.name_last
		var/hosage = 50
		if(M?.current?.bioHolder?.age)
			hosage = M.current.bioHolder.age
		. = "Awarded to [pick("Pvt.","Sgt","Cpl.","Maj.","Cpt.","Col.","Gen.")] "
		. += "[hosname] for [pick("Outstanding","Astounding","Incredible")] "
		. += "[pick("Bravery","Courage","Sneakiness","Competence","Participation","Robustness")] in the "
		. += "[pick("Great","Scary","Bloody","")] [pick("War","Battle","Massacre","Riot","Kerfuffle","Undeclared Conflict")] of "
		. += "'[(CURRENT_SPACE_YEAR - rand((hosage - 18),hosage)) % 100]."

/obj/decal/poster/wallsign/framed_award/firstbill
	name = "framed space currency"
	desc = "A single bill of space currency."
	award_type = /obj/item/firstbill
	award_name = "first bill"
	owner_job = "Head of Personnel"
	icon_glass = "hopcredit1"
	icon_award = "hopcredit"
	icon_empty = "frame"
	icon_state = "hopcredit"

	get_award_text(var/datum/mind/M)
		var/hopname = "Anonymous"
		if(M?.current?.client?.preferences?.name_last)
			hopname = M.current.client.preferences.name_last
		. = "The first [pick("Space","NT", "Golden","Silver")] "
		. += "[pick("Dollar","Doubloon","Buck","Peso","Credit")] earned by [hopname] "
		. += "for selling a [pick("Amazing","Mediocre","Suspicious","Quality","Decent","Odd")] "
		. += "[pick("Time share","Hamburger", "Clown shoe","Corporate secrets")]"

/obj/decal/poster/wallsign/framed_award/rddiploma
	name = "research directors diploma"
	desc = "A fancy space diploma."
	award_type = /obj/item/rddiploma

	get_desc(dist)
		if(award_text)
			return award_text
		if (dist <= 1 & prob(50))
			. += ".. Upon closer inspection this degree seems to be fake! Who could have guessed!"
		else
			// Do we have a rd?
			..()

	get_award_text(var/datum/mind/M)
		var/rdname = "Anonymous"
		if(M?.current?.client?.preferences?.name_last)
			rdname = M.current.client.preferences.name_last
		. += "It says \ [rdname] has been awarded the degree of [pick("Associate", "Bachelor")] of [pick("arts","science")] "
		. += "Master of [pick("arts","science")], "
		. += "in [pick("Superstition","Quantum","Avian","Simian","Relative","Absolute","Computational","Philosophical","Practical","Inadvisably-applied","Impractical","Hyper", "Mega", "Giga", "Probabilistic")] [pick("Physics","Astronomy","Plasmatology", "Astrology","Cosmetology", "Dentistry","Botany","Science","Ologylogy","Wumbology")].\""

/obj/decal/poster/wallsign/framed_award/mdlicense
	name = "medical directors medical license"
	desc = "There's just no way this is real."
	award_type = /obj/item/mdlicense
	award_name = "medical license"
	owner_job = "Medical Director"
	icon_glass = "mdlicense1"
	icon_award = "mdlicense"
	icon_empty = "frame"
	icon_state = "mdlicense"

	get_award_text(var/datum/mind/M)
		var/mdname = "Anonymous"
		if(M?.current?.client?.preferences?.name_last)
			mdname = M.current.client.preferences.name_last
		. += "It says \ [mdname] has been granted a license as a Physician and Surgeon entitled to practice the profession of medicine in space."

#undef FRAME_HAS_GLASS_HAS_AWARD
#undef FRAME_NO_GLASS_HAS_AWARD
#undef FRAME_NO_GLASS_NO_AWARD

///////////////////////////////////////
// ACTUAL AWARDS
///////////////////////////////////////

/obj/item/rddiploma
	name = "RD's diploma"
	icon = 'icons/obj/items/items.dmi'
	desc = ".. Upon closer inspection this degree seems to be fake! Who could have guessed!"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "rddiploma"
	item_state = "rddiploma"

/obj/item/mdlicense
	name = "MD's medical license"
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "mdlicense"
	item_state = "mdlicense"

/obj/item/firstbill
	name = "HoP's first bill"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "hopbill"
