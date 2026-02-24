/datum/targetable/macho/macho_heartpunch
	name = "Macho Heartpunch"
	desc = "Punches a guy's heart. Right out of their body."
	icon_state = "stasis"
	targeted = 1
	cast(atom/target)
		var/mob/M = target
		if (!(BOUNDS_DIST(M, holder.owner) == 0))
			return

		. = ..()
		var/did_it = 0
		holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_heartpunch
		var/direction = get_dir(holder.owner,M)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.organHolder && H.organHolder.heart)
				//PUNCH THE HEART! YEAH!
				holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] punches out [H]'s heart!</B>"))
				playsound(holder.owner, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)

				var/obj/item/organ/heart/heart_to_punt = H.organHolder.drop_organ("heart")

				for (var/I = 1, I <= 5 && heart_to_punt && step(heart_to_punt,direction, 1), I++)
//						new D(heart_to_punt.loc)
					bleed(H, 25, 5)
					playsound(heart_to_punt,'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)

				H.emote("scream")
				did_it = 1
			else
				holder.owner.show_text("Man, this poor sucker ain't got a heart to punch, whatta chump.", "blue")
				SPAWN(2 SECONDS)
					if (isalive(holder.owner))
						holder.owner.emote("sigh")

		else if (isrobot(M)) //Extra mean to borgs.

			var/mob/living/silicon/robot/R = M
			if (R.part_chest)
				holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] punches off [R]'s chest!</B>"))
				playsound(holder.owner, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
				R.emote("scream")
				var/obj/item/parts/robot_parts/chest/chestpunt = new R.part_chest.type(R.loc)
				chestpunt.name = "[R.name]’s [chestpunt.name]"
				R.compborg_lose_limb(R.part_chest)

				for (var/I = 1, I <= 5 && chestpunt && step(chestpunt ,direction, 1), I++)
					make_cleanable(/obj/decal/cleanable/oil,chestpunt.loc)
					playsound(chestpunt,'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)

				did_it = 1

			else //Uh?
				holder.owner.show_text("Man, this poor sucker ain't even got a chest to punch, whatta chump.", "blue")
				SPAWN(2 SECONDS)
					if (isalive(holder.owner))
						holder.owner.emote("sigh")

		else
			holder.owner.show_text("You're not entirely sure where the heart is on this thing. Better leave it alone.", "blue")
			SPAWN(2 SECONDS)
				if (isalive(holder.owner))
					holder.owner.emote("sigh")

		if (did_it)
			SPAWN(rand(2,4) * 10)
				playsound(holder.owner.loc, pick(snd_macho_rage), 50, 0, 0, holder.owner.get_age_pitch())
				holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner]</b> gloats and boasts!"))

		holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_heartpunch
