/datum/targetable/macho/macho_heal
	name = "Macho Healing"
	desc = "Sacrifice your health to heal someone else"
	icon_state = "speedregen"
	cast(atom/target)
		. = ..()
		if (isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (isliving(G.affecting))
					holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_heal
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.remove_stuns()
						H.set_clothing_icon_dirty()
					H.transforming = 1
					holder.owner.transforming = 1
					holder.owner.set_dir(get_dir(holder.owner, H))
					H.set_dir(get_dir(H, holder.owner))
					holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] gently picks up [H]!</B>"))
					playsound(holder.owner.loc, pick(snd_macho_rage), 50, 0, 0, holder.owner.get_age_pitch())
					var/dir_offset = get_dir(holder.owner, H)
					switch(dir_offset)
						if (NORTH)
							H.pixel_y = -24
							H.layer = holder.owner.layer - 1
						if (SOUTH)
							H.pixel_y = 24
							H.layer = holder.owner.layer + 1
						if (EAST)
							H.pixel_x = -24
							H.layer = holder.owner.layer - 1
						if (WEST)
							H.pixel_x = 24
							H.layer = holder.owner.layer - 1
					for (var/i = 0, i < 5, i++)
						H.pixel_y += 2
						sleep(0.3 SECONDS)
					holder.owner.transforming = 0
					holder.owner.bioHolder.AddEffect("fire_resist")
					holder.owner.transforming = 1
					playsound(holder.owner.loc, 'sound/voice/heavenly.ogg', 50)
					holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] closes [his_or_her(holder.owner)] eyes in silent macho prayer!</b>"))
					sleep(4 SECONDS)
					for (var/mob/N in viewers(holder.owner, null))
						N.flash(3 SECONDS)
						if (N.client)
							shake_camera(N, 6, 16)
							N.show_message(SPAN_ALERT("<b>A blinding light envelops [holder.owner]!</b>"), 1)

					playsound(holder.owner.loc, 'sound/weapons/flashbang.ogg', 50, 1)
					qdel(G)
					holder.owner.transforming = 0
					holder.owner.bioHolder.RemoveEffect("fire_resist")
					holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_heal
					random_brute_damage(holder.owner, 25)
					holder.owner.UpdateDamageIcon()
					SPAWN(0)
						if (H)
							H.pixel_x = 0
							H.pixel_y = 0
							H.transforming = 0
							H.full_heal()
