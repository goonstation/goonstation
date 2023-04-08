/datum/targetable/macho/macho_soulsteal
	name = "Macho Soul Steal"
	desc = "Steals a target's soul to restore health"
	icon_state = "enthrall"
	cast(atom/target)
		if (isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (isliving(G.affecting))
					holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_soulsteal
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					holder.owner.transforming = 1
					holder.owner.set_dir(get_dir(holder.owner, H))
					H.set_dir(get_dir(H, holder.owner))
					holder.owner.visible_message("<span class='alert'><B>[holder.owner] picks up [H] by the throat!</B></span>")
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
				//	var/icon/composite = icon(holder.owner.icon, holder.owner.icon_state, null, 1)
				//	composite.MapColors(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
				//	for (var/O in holder.owner.overlays)
				//		var/image/I = O
				//		var/icon/Ic = icon(I.icon, I.icon_state)
				//		Ic.MapColors(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
				//		composite.Blend(Ic, ICON_OVERLAY)
				//	holder.owner.overlays = null
				//	holder.owner.icon = composite
					playsound(holder.owner.loc, 'sound/voice/chanting.ogg', 75, 0, 0, holder.owner.get_age_pitch())
					holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins radiating with evil energies!</b></span>")
					sleep(4 SECONDS)
					for (var/mob/N in viewers(holder.owner, null))
						N.flash(3 SECONDS)
						if (N.client)
							shake_camera(N, 6, 16)
							N.show_message(text("<span class='alert'><b>A blinding light envelops [holder.owner]!</b></span>"), 1)

					playsound(holder.owner.loc, 'sound/weapons/flashbang.ogg', 50, 1)
					qdel(G)
					holder.owner.transforming = 0
					holder.owner.bioHolder.RemoveEffect("fire_resist")
					holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_soulsteal
					holder.owner.HealDamage("All", 50, 50, 50)
					holder.owner.take_toxin_damage(-INFINITY)
					holder.owner.UpdateDamageIcon()
					if (H)
						H.pixel_x = 0
						H.pixel_y = 0
						H.take_toxin_damage(5000)
						H.transforming = 0
						if (ishuman(H))
							H.set_mutantrace(/datum/mutantrace/skeleton)
							H.set_body_icon_dirty()
