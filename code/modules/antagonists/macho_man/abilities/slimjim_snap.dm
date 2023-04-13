/datum/targetable/macho/macho_slimjim_snap
	name = "Macho Slim-Jim Snap"
	desc = "Snaps a target into a slim jim."
	icon_state = "lesser"
	cast(atom/target)
		if (isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (isliving(G.affecting))
					holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_slimjim_snap
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
					holder.owner.visible_message("<span class='alert'><B>[holder.owner] menacingly grabs [H] by the chest!</B></span>")
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

					playsound(holder.owner.loc, 'sound/voice/macho/macho_slimjim.ogg', 75) // SNAP INTO A SLIM JIM!
					sleep(0.5 SECONDS)
					if (ishuman(H))
						var/mob/living/carbon/human/HU = H
						holder.owner.visible_message("<span class='alert'><B>[holder.owner] begins snapping [H]'s body!</B></span>")
						var/number_of_snaps = 5
						var/i
						for(i = 0; i < number_of_snaps; i++)
							playsound(HU.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
							HU.emote("scream")
							take_bleeding_damage(HU, holder.owner, 5, DAMAGE_STAB)
							HU.Scale(1 + (rand(-30, 20) * 0.01), 1 + (rand(-20, 30) * 0.01))
							HU.Turn(rand(-60, 90))
							HU.bioHolder.age += 10
							sleep(1 SECOND)

						playsound(holder.owner.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 100, 1)
						var/obj/victimjim = new /obj/item/reagent_containers/food/snacks/slimjim(HU.loc)
						HU.visible_message("<span class='alert'><B>The only thing that remains after [H] is a Slim Jim!</B></span>", "<span class='alert'><B>Your body is snapped into a Slim Jim!</B></span>")
						victimjim.setMaterial(getMaterial("flesh"))
						victimjim.name = "Slim [HU.real_name]"
						HU.ghostize()
						qdel(HU)
					else
						H.visible_message("<span class='alert'><B>[holder.owner] snaps [H] into a Slim Jim with his bare hands!</B></span>", "<span class='alert'><B>Your body is snapped into a Slim Jim!</B></span>")
						playsound(H.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 100, 1)
						var/obj/victimjim = new /obj/item/reagent_containers/food/snacks/slimjim(H.loc)
						victimjim.setMaterial(getMaterial("flesh"))
						victimjim.name = "Slim [H.real_name]"
						H.ghostize()
						qdel(H)
					holder.owner.transforming = 0
					holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_slimjim_snap
					SPAWN(20)
						playsound(holder.owner.loc, pick(snd_macho_rage), 50, 0, 0, holder.owner.get_age_pitch())
						holder.owner.visible_message("<span class='alert'><b>[holder.owner]</b> gloats and boasts!</span>")
