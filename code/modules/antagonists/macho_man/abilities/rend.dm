/datum/targetable/macho/macho_rend
	name = "Macho Rend"
	desc = "Tears a target limb from limb"
	icon_state = "nostun"
	cast(atom/target)
		if (isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (isliving(G.affecting))
					holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_rend
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
					if (ishuman(H))
						var/mob/living/carbon/human/HU = H
						holder.owner.visible_message("<span class='alert'><B>[holder.owner] begins tearing [H] limb from limb!</B></span>")
						var/original_age = HU.bioHolder.age
						if (HU.limbs.l_arm)
							HU.limbs.l_arm.sever()
							playsound(holder.owner.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
							HU.emote("scream")
							HU.bioHolder.age += 10
							sleep(1 SECOND)
						if (HU.limbs.r_arm)
							HU.limbs.r_arm.sever()
							playsound(holder.owner.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
							HU.emote("scream")
							HU.bioHolder.age += 10
							sleep(1 SECOND)
						if (HU.limbs.l_leg)
							HU.limbs.l_leg.sever()
							playsound(holder.owner.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
							HU.emote("scream")
							HU.bioHolder.age += 10
							sleep(1 SECOND)
						if (HU.limbs.r_leg)
							HU.limbs.r_leg.sever()
							playsound(holder.owner.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
							HU.emote("scream")
							sleep(1 SECOND)
						HU.bioHolder.age = original_age
						HU.changeStatus("stunned", 10 SECONDS)
						HU.changeStatus("weakened", 10 SECONDS)
						var/turf/T = get_edge_target_turf(holder.owner, holder.owner.dir)
						SPAWN(0)
							playsound(holder.owner.loc, "swing_hit", 40, 1)
							holder.owner.visible_message("<span class='alert'><B>[holder.owner] casually punts [H] away!</B></span>")
							HU.throw_at(T, 10, 2)
						HU.pixel_x = 0
						HU.pixel_y = 0
						HU.transforming = 0
					else
						holder.owner.visible_message("<span class='alert'><B>[holder.owner] shreds [H] to ribbons with his bare hands!</B></span>")
						H.transforming = 0
						H.gib()
					holder.owner.transforming = 0
					holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_rend
					SPAWN(2 SECONDS)
						playsound(holder.owner.loc, pick(snd_macho_rage), 50, 0, 0, holder.owner.get_age_pitch())
						holder.owner.visible_message("<span class='alert'><b>[holder.owner]</b> gloats and boasts!</span>")
