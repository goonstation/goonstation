/datum/targetable/macho/macho_stare
	name = "Macho Stare"
	desc = "Stares deeply at a victim, causing them to explode"
	icon_state = "glare"
	cast(atom/target)
		if (isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (isliving(G.affecting))
					holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_stare
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.jitteriness = 0
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
					playsound(holder.owner.loc, 'sound/effects/mindkill.ogg', 50)
					holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins intensely staring [H] in the eyes!</b></span>")
					boutput(H, "<span class='alert'>You feel a horrible pain in your head!</span>")
					sleep(0.5 SECONDS)
					H.make_jittery(1000)
					H.visible_message("<span class='alert'><b>[H] starts violently convulsing!</b></span>")
					sleep(4 SECONDS)
					playsound(holder.owner.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
					qdel(G)
					var/location = get_turf(H)
					holder.owner.transforming = 0
					holder.owner.bioHolder.RemoveEffect("fire_resist")
					holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_stare
					if (H.client)
						var/mob/dead/observer/newmob
						newmob = new/mob/dead/observer(H)
						H:client:mob = newmob
						H.mind.transfer_to(newmob)
						newmob.corpse = null
					H.visible_message("<span class='alert'><b>[H] instantly vaporizes into a cloud of blood!</b></span>")
					for (var/mob/N in viewers(holder.owner, null))
						if (N.client)
							shake_camera(N, 6, 16)
					qdel(H)
					SPAWN(0)
						//alldirs
						var/icon/overlay = icon('icons/effects/96x96.dmi',"smoke")
						overlay.Blend(rgb(200,0,0,200),ICON_MULTIPLY)
						var/image/I = image(overlay)
						I.pixel_x = -32
						I.pixel_y = -32
						/*
						var/the_dir = NORTH
						for (var/i=0, i<8, i++)
						*/
						var/datum/reagents/bloodholder = new /datum/reagents(25)
						bloodholder.add_reagent("blood", 25)
						smoke_reaction(bloodholder, 4, location)
						particleMaster.SpawnSystem(new /datum/particleSystem/chemSmoke(location, bloodholder, 20))
						//the_dir = turn(the_dir,45)
