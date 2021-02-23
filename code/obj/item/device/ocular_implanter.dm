#define EYE_LEFT 1
#define EYE_RIGHT 2
#define EYE_BOTH 4

/obj/item/device/ocular_implanter
	name = "eye implanter"
	icon_state = "ocular_implanter-full"
	desc = "A worrying looking medical device for eye implants. The suction cup eye pieces fill you with dread."
	w_class = 2
	is_syndicate = 1
	var/implant = /obj/item/organ/eye/cyber/sechud
	var/implants_available = EYE_LEFT | EYE_RIGHT
	var/list/parts_to_remove = list()
	var/list/parts_to_add = list()

	attack_self(mob/user as mob)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			src.add_fingerprint(H)
			switch (alert("Which eye would you like to operate on with [src]?","Both Eyes","Left Eye","Right Eye","Cancel"))
				if ("Cancel")
					return
				if ("Both Eyes")
					if ((implants_available & EYE_LEFT) && (implants_available & EYE_RIGHT))
						start_replace_eye(EYE_BOTH, H)
					else
						user.show_text("This implanter doesn't contain both implants.")
				if ("Right Eye")
					if (implants_available & EYE_RIGHT)
						start_replace_eye(EYE_RIGHT, H)
					else
						user.show_text("This implanter doesn't contain the right eye implant.")
				if ("Left Eye")
					if (implants_available & EYE_LEFT)
						start_replace_eye(EYE_LEFT, H)
					else
						user.show_text("This implanter doesn't contain the left eye implant.")


	proc/start_replace_eye(var/target, var/mob/living/carbon/human/H)
		message_admins("replace eye!")
		if(!H.can_equip(src, SLOT_GLASSES))
			boutput(src, "<span class='alert'>You need to remove your eyewear first.</span>")
			return
		//
		if (target == EYE_BOTH)
			parts_to_add += "right_eye"
			parts_to_add += "left_eye"
			implants_available = 0
		else if (target == EYE_RIGHT)
			parts_to_add += "right_eye"
			implants_available = implants_available ^ EYE_RIGHT
		else
			parts_to_add += "left_eye"
			implants_available = implants_available ^ EYE_LEFT
		for(var/part_loc in parts_to_add)
			var/obj/item/bodypart = null
			bodypart = H.get_organ(part_loc)
			if(!bodypart)
				parts_to_remove += part_loc
		SETUP_GENERIC_ACTIONBAR(H, src, 5 SECONDS, /obj/item/device/ocular_implanter/proc/end_replace_eye, src.icon, src.icon_state,"[src] finishes working")

	proc/end_replace_eye()
		//playsound(H.loc, ""pick(work_sounds)"", 50, 1, -1)
		var/mob/living/carbon/human/H = src
		var/turf/T = src.loc
		for(var/part_loc in parts_to_remove)
			message_admins("removing [part_loc]")
			if (T)
				H.drop_organ(part_loc, T)
				H.update_body()
		for(var/part_loc in parts_to_add)
			message_admins("adding [part_loc]")
			H.receive_organ(new implant, part_loc, 0, 1)
			H.update_body()
		boutput(H, "<span class='alert'><b>[pick("IT HURTS!", "OH GOD!", "JESUS FUCK!")]</b></span>")
		H.emote("scream")
		bleed(H, 5, 5)
		if (implants_available & EYE_RIGHT)
			icon_state = "ocular_implanter-R"
		else if (implants_available & EYE_LEFT)
			icon_state = "ocular_implanter-L"
		else
			icon_state = "ocular_implanter-LR"
		parts_to_remove = list()
		parts_to_add = list()
