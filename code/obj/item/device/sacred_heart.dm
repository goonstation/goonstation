#define HEART 1

/obj/item/device/sacred_heart_scroll
	name = "Sacred Heart Scroll"
	icon_state = "sacred_heart_scroll-"
	desc = "A dusty old scroll containing some rather enlightening knowlege from a time of cloak and dagger."
	w_class = 2
	is_syndicate = TRUE
	var/implant = /obj/item/organ/heart/sacred
	var/implants_available = HEART
	var/list/parts_to_remove = list()
	var/list/parts_to_add = list()

	attack_self(mob/user)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			src.add_fingerprint(H)
			switch (alert("Would you like to read [src]? This can only be done once.",,"Proceed","Cancel"))
				if ("Cancel")
					return
				if ("Proceed")
					if (implants_available & HEART)
						start_replace_heart(HEART, H)
					else
						user.show_text("This scroll's writings are illegible.")


	proc/start_replace_heart(var/target, var/mob/living/carbon/human/H)
		parts_to_add += "heart"
		for(var/part_loc in parts_to_add)
			var/obj/item/bodypart = null
			bodypart = H.get_organ(part_loc)
			if(bodypart)
				parts_to_remove += part_loc
		boutput(H, "<span class='alert'>This will take some time to read!</span>")
		SPAWN(1 SECOND)
			playsound(H.loc, "sound/items/ocular_implanter_start.ogg", 50, 0, -1)
			SETUP_GENERIC_ACTIONBAR(H, src, 10 SECONDS, /obj/item/device/sacred_heart_scroll/proc/end_replace_heart, list(target, H), src.icon, src.icon_state,"[src] Teaches you much about the faith.", null)

	proc/end_replace_heart(var/target, var/mob/living/carbon/human/H)
		if(!H)
			return
		playsound(H.loc, "sound/items/ocular_implanter_end.ogg", 50, 0, -1)
		var/turf/T = H.loc
		for(var/part_loc in parts_to_remove)
			if (T)
				H.drop_organ(part_loc, T)
				H.update_body()
		for(var/part_loc in parts_to_add)
			H.receive_organ(new implant, part_loc, 0, 1)
			H.update_body()
			implants_available = FALSE
		boutput(H, "<span class='alert'><b>[pick("IT HURTS!", "OH GOD!", "JESUS FUCK!")]</b></span>")
		bleed(H, 5, 5)
		SPAWN(5 DECI SECOND)
			H.emote("scream")
		icon_state = "sacred_heart_scroll-U"
		parts_to_remove = list()
		parts_to_add = list()

#undef HEART
