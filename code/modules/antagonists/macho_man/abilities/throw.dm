/datum/targetable/macho/macho_superthrow
	name = "Macho Throw"
	desc = "Throw someone super hard"
	icon_state = "Throw"
	cast(atom/target)
		if (isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (isliving(G.affecting))
					holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_superthrow
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					holder.owner.transforming = 1
					holder.owner.set_density(0)
					H.set_density(0)
					H.set_loc(holder.owner.loc)
					step(H, holder.owner.dir)
					H.set_dir(get_dir(H, holder.owner))
					holder.owner.visible_message("<span class='alert'><B>[holder.owner] starts spinning around [H]!</B></span>")
					playsound(holder.owner.loc, 'sound/effects/bionic_sound.ogg', 50)
					for (var/i = 0, i < 80, i++)
						var/delay = 5
						switch(i)
							if (50 to INFINITY)
								delay = 0.25
							if (40 to 50)
								delay = 0.5
							if (30 to 40)
								delay = 1
							if (10 to 30)
								delay = 2
							if (0 to 10)
								delay = 3
						holder.owner.set_dir(turn(holder.owner.dir, 90))
						H.set_loc(get_step(holder.owner, holder.owner.dir))
						H.set_dir(get_dir(H, holder.owner))
						sleep(delay)
					holder.owner.pixel_x = 0
					holder.owner.pixel_y = 0
					holder.owner.transforming = 0
					H.pixel_x = 0
					H.pixel_y = 0
					holder.owner.set_density(1)
					qdel(G)
					playsound(holder.owner.loc, 'sound/weapons/rocket.ogg', 50)
					holder.owner.visible_message("<span class='alert'><B>[holder.owner] flings [H] with all of his might!</B></span>")
					var/target_dir = get_dir(holder.owner, H)
					SPAWN(0)
						if (H)
							walk(H, target_dir, 1)
							sleep(1.5 SECONDS)
							playsound(holder.owner.loc, "explosion", 50)
							var/obj/overlay/O = new/obj/overlay(get_turf(H))
							O.anchored = ANCHORED
							O.name = "Explosion"
							O.layer = NOLIGHT_EFFECTS_LAYER_BASE
							O.pixel_x = -92
							O.pixel_y = -96
							O.icon = 'icons/effects/214x246.dmi'
							O.icon_state = "explosion"
							O.fingerprintslast = holder.owner.key
							SPAWN(3.5 SECONDS) qdel(O)
							explosion(O, H.loc, 1, 2, 3, 4, 1)
							H.gib()
					holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_superthrow
