/datum/targetable/macho/macho_leap
	name = "Macho Leap"
	desc = "Macho madness sky's the limit"
	icon_state = "teleport"
	//Restricting possible leap areas to prevent NERDSS from finding secrets when they get turned into a matzo man
	var/list/possible_areas = list()

	New()
		. = ..()
		possible_areas += get_areas(/area/station)
		possible_areas += get_areas(/area/diner)
		possible_areas += get_areas(/area/radiostation/studio)
		possible_areas += get_areas(/area/sim)

	cast(mob/target)
		. = ..()
		if (isalive(holder.owner) && !holder.owner.transforming)
			var/area/A = input("Select the area to leap to: ", "Select Area", null) as null|anything in possible_areas
			if (!A)
				return

			var/list/turfs = get_area_turfs(A, 1)
			if (!length(turfs))
				return

			holder.owner.transforming = 1
			var/mob/living/H = null
			var/obj/item/grab/G = null
			for (G in holder.owner)
				if (isliving(G.affecting))
					H = G.affecting
			if (H)
				if (H.lying)
					H.lying = 0
					H.remove_stuns()
					H.set_clothing_icon_dirty()
				H.transforming = 1
				H.set_density(0)
				H.set_loc(holder.owner.loc)
			else
				holder.owner.visible_message(SPAN_ALERT("[holder.owner] closes his eyes for a moment."))
				playsound(holder.owner.loc, 'sound/voice/macho/macho_breathing18.ogg', 50, 0, 0, holder.owner.get_age_pitch())
				sleep(4 SECONDS)
			holder.owner.set_density(0)
			if (H)
				holder.owner.set_dir(get_dir(holder.owner, H))
				H.set_dir(get_dir(H, holder.owner))
				animate_flip(H, 3)
				/*
				var/icon/composite = icon(H.icon, H.icon_state, null, 1)
				composite.Turn(180)
				for (var/O in H.overlays)
					var/image/I = O
					var/icon/Ic = icon(I.icon, I.icon_state)
					Ic.Turn(180)
					composite.Blend(Ic, ICON_OVERLAY)
				H.overlays = null
				H.icon = composite
				*/
				holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] grabs [H] and flies through the ceiling!</B>"))
			else
				holder.owner.visible_message(SPAN_ALERT("[holder.owner] flies through the ceiling!"))
			playsound(holder.owner.loc, 'sound/effects/bionic_sound.ogg', 50)
			playsound(holder.owner.loc, 'sound/voice/macho/macho_become_enraged01.ogg', 50, 0, 0, holder.owner.get_age_pitch())
			for (var/i = 0, i < 20, i++)
				holder.owner.pixel_y += 15
				holder.owner.set_dir(turn(holder.owner.dir, 90))
				if (H)
					H.pixel_y += 15
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
			holder.owner.set_loc(pick(turfs))
			if (H)
				holder.owner.visible_message(SPAN_ALERT("[holder.owner] suddenly descends from the ceiling with [H]!"))
				H.set_loc(holder.owner.loc)
			else
				holder.owner.visible_message(SPAN_ALERT("[holder.owner] suddenly descends from the ceiling!"))
			playsound(holder.owner.loc, 'sound/effects/bionic_sound.ogg', 50)
			for (var/i = 0, i < 20, i++)
				holder.owner.pixel_y -= 15
				holder.owner.set_dir(turn(holder.owner.dir, 90))
				if (H)
					H.pixel_y -= 15
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
			if (G)
				qdel(G)
			playsound(holder.owner.loc, "explosion", 50)
			playsound(holder.owner.loc, pick(snd_macho_rage), 50, 0, 0, holder.owner.get_age_pitch())
			for (var/mob/M in viewers(holder.owner, 5))
				if (M != holder.owner)
					M.changeStatus("knockdown", 8 SECONDS)
				SPAWN(0)
					shake_camera(M, 4, 16)
			if (istype(holder.owner.loc, /turf/simulated/floor))
				holder.owner.loc:break_tile()
			if (H)
				holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] ultra atomic piledrives [H]!!</B>"))
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
				H.changeStatus("knockdown", 1 SECOND)
				H.pixel_x = 0
				H.pixel_y = 0
				H.transforming = 0
				H.set_density(1)
			holder.owner.pixel_x = 0
			holder.owner.pixel_y = 0
			holder.owner.transforming = 0
			holder.owner.set_density(1)
			SPAWN(0.5 SECONDS)
				holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_leap
