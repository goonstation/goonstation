#define EYE_LEFT 1
#define EYE_RIGHT 2
#define EYE_BOTH 4

/obj/item/device/ocular_implanter
	name = "Ocular Implanter (SecHUD)"
	icon_state = "ocular_implanter-full"
	desc = "A worrying looking medical device for automated eye implants, this model is for SecHUDs. The suction cup fills you with dread."
	w_class = W_CLASS_SMALL
	is_syndicate = 1
	var/implant = /obj/item/organ/eye/cyber/sechud
	var/implants_available = EYE_LEFT | EYE_RIGHT
	var/list/parts_to_remove = list()
	var/list/parts_to_add = list()

	attack_self(mob/user as mob)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			src.add_fingerprint(H)
			var/choice = tgui_alert(user, "Which eye would you like to operate on with [src]?", "Pick eye", list("Left Eye", "Right Eye", "Cancel"))
			if (!choice || choice == "Cancel")
				return
			switch (choice)
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
		if(H.glasses)
			boutput(H, "<span class='alert'>You need to remove your eyewear first.</span>")
			return
		if (H.head && H.head.c_flags & COVERSEYES)
			boutput(H, "<span class='alert'>Your headwear covers your eyes, you need to remove it first.</span>")
			return
		//
		if (target == EYE_BOTH)
			parts_to_add += "right_eye"
			parts_to_add += "left_eye"
		else if (target == EYE_RIGHT)
			parts_to_add += "right_eye"
		else
			parts_to_add += "left_eye"
		for(var/part_loc in parts_to_add)
			var/obj/item/bodypart = null
			bodypart = H.get_organ(part_loc)
			if(bodypart)
				parts_to_remove += part_loc
		boutput(H, "<span class='alert'>Caution! Remain stationary!</span>")
		SPAWN(1 SECOND)
			playsound(H.loc, 'sound/items/ocular_implanter_start.ogg', 50, 0, -1)
			SETUP_GENERIC_ACTIONBAR(H, src, 10 SECONDS, /obj/item/device/ocular_implanter/proc/end_replace_eye, list(target, H), src.icon, src.icon_state,"[src] finishes replacing your eye.", null)

	proc/end_replace_eye(var/target, var/mob/living/carbon/human/H)
		if(!H)
			return
		playsound(H.loc, 'sound/items/ocular_implanter_end.ogg', 50, 0, -1)
		var/turf/T = H.loc
		for(var/part_loc in parts_to_remove)
			if (T)
				H.drop_organ(part_loc, T)
				H.update_body()
		for(var/part_loc in parts_to_add)
			H.receive_organ(new implant, part_loc, 0, 1)
			H.update_body()
		if (target == EYE_BOTH)
			implants_available = 0
		else if (target == EYE_RIGHT)
			implants_available = implants_available ^ EYE_RIGHT
		else
			implants_available = implants_available ^ EYE_LEFT
		boutput(H, "<span class='alert'><b>[pick("IT HURTS!", "OH GOD!", "JESUS FUCK!")]</b></span>")
		bleed(H, 5, 5)
		SPAWN(5 DECI SECOND)
			H.emote("scream")
		if (implants_available & EYE_RIGHT)
			icon_state = "ocular_implanter-R"
		else if (implants_available & EYE_LEFT)
			icon_state = "ocular_implanter-L"
		else
			icon_state = "ocular_implanter-LR"
		parts_to_remove = list()
		parts_to_add = list()

#undef EYE_LEFT
#undef EYE_RIGHT
#undef EYE_BOTH
