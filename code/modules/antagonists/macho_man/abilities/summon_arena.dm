/datum/targetable/macho/macho_summon_arena
	name = "Macho Arena"
	desc = "Summon a wrestling ring."
	icon_state = "lightning_cd"
	var/list/macho_arena_turfs

	disposing()
		. = ..()
		if (macho_arena_turfs)
			clean_up_arena_turfs(src.macho_arena_turfs)

	cast(atom/target)
		if (isalive(holder.owner) && !holder.owner.transforming)
			if(!macho_arena_turfs) // no arena exists
				var/ring_radius = 4
				var/turf/Aloc = get_turf(holder.owner)
				for (var/obj/decal/O in range(ring_radius + 1, Aloc))
					if (istype(O, /obj/decal/boxingrope))
						boutput(holder.owner, "<span class='alert'>A ring is already nearby!</span>")
						return
				//var/arena_time = 45 SECONDS
				holder.owner.verbs -= /mob/living/carbon/human/machoman/verb/macho_summon_arena
				playsound(holder.owner.loc, 'sound/voice/chanting.ogg', 75, 0, 0, holder.owner.get_age_pitch())
				holder.owner.visible_message("<span class='alert'><B>[holder.owner] begins summoning a wrestling ring!</B></span>", "<span class='alert'><B>You begin summoning a wrestling ring!</B></span>")
				for (var/mob/living/M in oviewers(ring_radius + 4, get_turf(holder.owner)))
					M.apply_sonic_stun(6, 3, stamina_damage = 0)

				sleep(1.2 SECONDS)
				var/list/arenaropes = list()
				for (var/turf/T in range(ring_radius, Aloc))
					/*   // too many issues with canpass and/or lights breaking, maybe sometime in the future?
					if(isfloor(T))
						animate_buff_out(T)
						SPAWN(1 SECOND)
							var/floor_type = T.type
							var/turf/unsimulated/floor/specialroom/gym/macho_arena/new_turf = T.ReplaceWith("/turf/unsimulated/floor/specialroom/gym/macho_arena/new_turf", 1)
							new_turf.previous_turf_type = floor_type
							new_turf.alpha = 0
							arenaropes += new_turf
					*/
					if(GET_DIST(Aloc,T) == ring_radius) // boundaries
						if(abs(Aloc.x - T.x) == ring_radius && abs(Aloc.y - T.y) == ring_radius) // arena corners
							var/obj/stool/chair/boxingrope_corner/FF = new/obj/stool/chair/boxingrope_corner(T)
							FF.alpha = 0
							if(T.x < Aloc.x) // to the west
								if(T.y > Aloc.y) // north-west corner
									FF.set_dir(NORTHWEST)
								else
									FF.set_dir(SOUTHWEST)
							else // to the east
								if(T.y > Aloc.y) // north-east
									FF.set_dir(NORTHEAST)
								else
									FF.set_dir(SOUTHEAST)
							arenaropes += FF
							var/random_deviation = rand(0, 5)
							SPAWN(random_deviation)
								spawn_animation1(FF)
								sleep(10) // animation, also to simulate them coming in and slamming into the ground
								FF.visible_message("<span class='alert'><B>[FF] slams and anchors itself into the ground!</B></span>")
								playsound(T, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
								for (var/mob/living/M in oviewers(ring_radius * 2, T))
									shake_camera(M, 8, 24)
						else // arena ropes
							var/obj/decal/boxingrope/FF = new/obj/decal/boxingrope(T)
							arenaropes += FF
							if(abs(Aloc.x - T.x) == ring_radius) // side ropes
								if(T.x - Aloc.x < 0)  // west rope
									FF.set_dir(WEST)
								else // east rope
									FF.set_dir(EAST)
							else // top/bottom ropes
								if(T.y - Aloc.y > 0) // north ropes
									FF.set_dir(NORTH)
								else
									FF.set_dir(SOUTH)
							FF.alpha = 0
				sleep(1.4 SECONDS)
				macho_arena_turfs = arenaropes
				/*   // too many issues with canpass and/or lights breaking, maybe sometime in the future?
				for (var/turf/unsimulated/floor/specialroom/gym/macho_arena/F in arenaropes)
					animate_buff_in(F)
				*/
				for (var/obj/decal/boxingrope/F in arenaropes)
					spawn_animation1(F)
				holder.owner.verbs += /mob/living/carbon/human/machoman/verb/macho_summon_arena
			else // desummon arena
				clean_up_arena_turfs(src.macho_arena_turfs)

	proc/clean_up_arena_turfs(var/list/arena_turfs_to_cleanup)
		src.macho_arena_turfs = null
		/*   // too many issues with canpass and/or lights breaking, maybe sometime in the future?
			for (var/turf/unsimulated/floor/specialroom/gym/macho_arena/F in arenaropes)
				SPAWN(0)
					arenaropes -= F
					animate_buff_out(F)
					sleep(10)
					F.change_back()
			*/
		for (var/obj/decal/boxingrope/F in arena_turfs_to_cleanup)
			SPAWN(0)
				leaving_animation(F)
				qdel(F)
		for (var/obj/stool/chair/boxingrope_corner/F in arena_turfs_to_cleanup)
			SPAWN(0)
				leaving_animation(F)
				qdel(F)
