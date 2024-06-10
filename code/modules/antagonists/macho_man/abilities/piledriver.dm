/datum/targetable/macho/macho_piledriver
	name = "Atomic Piledriver"
	desc = "Piledrive a target"
	icon_state = "Drop"
	cast(atom/target)
		. = ..()
		if (isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (isliving(G.affecting))
					holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_piledriver
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.remove_stuns()
						H.set_clothing_icon_dirty()
					H.transforming = 1
					holder.owner.transforming = 1
					holder.owner.set_density(0)
					H.set_density(0)
					H.set_loc(holder.owner.loc)
					holder.owner.set_dir(get_dir(holder.owner, H))
					H.set_dir(get_dir(H, holder.owner))
					animate_flip(H, 3)
					holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] grabs [H] and spins in the air!</B>"))
					playsound(holder.owner.loc, 'sound/effects/bionic_sound.ogg', 50)
					for (var/i = 0, i < 15, i++)
						holder.owner.pixel_y += 6
						H.pixel_y += 6
						holder.owner.set_dir(turn(holder.owner.dir, 90))
						H.set_dir(turn(H.dir, 90))
						switch(holder.owner.dir)
							if (NORTH)
								H.pixel_x = holder.owner.pixel_x
								H.layer = holder.owner.layer - 1
							if (SOUTH)
								H.pixel_x = holder.owner.pixel_x
								H.layer = holder.owner.layer + 1
							if (EAST)
								H.pixel_x = holder.owner.pixel_x - 8
								H.layer = holder.owner.layer - 1
							if (WEST)
								H.pixel_x = holder.owner.pixel_x + 8
								H.layer = holder.owner.layer - 1
						sleep(0.1 SECONDS)
					holder.owner.pixel_x = 0
					holder.owner.pixel_y = 0
					holder.owner.transforming = 0
					H.pixel_x = 0
					H.pixel_y = 0
					H.transforming = 0
					holder.owner.set_density(1)
					H.set_density(1)
					qdel(G)
					playsound(holder.owner.loc, "explosion", 50)
					holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] atomic piledrives [H]!</B>"))
					var/obj/overlay/O = new/obj/overlay(get_turf(holder.owner))
					O.anchored = ANCHORED
					O.name = "Explosion"
					O.layer = NOLIGHT_EFFECTS_LAYER_BASE
					O.pixel_x = -92
					O.pixel_y = -96
					O.icon = 'icons/effects/214x246.dmi'
					O.icon_state = "explosion"
					SPAWN(3.5 SECONDS) qdel(O)
					random_brute_damage(H, 50)
					H.changeStatus("knockdown", 10 SECONDS)
					holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_piledriver
