//#define MAX_MINIONS_PER_SPAWN 3

var/list/snd_macho_rage = list('sound/voice/macho/macho_alert13.ogg', 'sound/voice/macho/macho_alert16.ogg', 'sound/voice/macho/macho_alert24.ogg',\
'sound/voice/macho/macho_become_alert54.ogg', 'sound/voice/macho/macho_become_alert56.ogg', 'sound/voice/macho/macho_rage_55.ogg', 'sound/voice/macho/macho_shout07.ogg',\
'sound/voice/macho/macho_rage_58.ogg', 'sound/voice/macho/macho_rage_61.ogg', 'sound/voice/macho/macho_rage_64.ogg', 'sound/voice/macho/macho_rage_68.ogg',\
'sound/voice/macho/macho_rage_71.ogg', 'sound/voice/macho/macho_rage_72.ogg', 'sound/voice/macho/macho_rage_73.ogg', 'sound/voice/macho/macho_rage_78.ogg',\
'sound/voice/macho/macho_rage_79.ogg', 'sound/voice/macho/macho_rage_80.ogg', 'sound/voice/macho/macho_rage_81.ogg', 'sound/voice/macho/macho_rage_54.ogg',\
'sound/voice/macho/macho_rage_55.ogg')

var/list/snd_macho_idle = list('sound/voice/macho/macho_alert16.ogg', 'sound/voice/macho/macho_alert22.ogg',\
'sound/voice/macho/macho_breathing01.ogg', 'sound/voice/macho/macho_breathing13.ogg', 'sound/voice/macho/macho_breathing18.ogg',\
'sound/voice/macho/macho_idle_breath_01.ogg', 'sound/voice/macho/macho_mumbling04.ogg', 'sound/voice/macho/macho_moan03.ogg',\
'sound/voice/macho/macho_mumbling05.ogg', 'sound/voice/macho/macho_mumbling07.ogg', 'sound/voice/macho/macho_shout08.ogg')

/mob/living/carbon/human/machoman
	var/list/macho_arena_turfs
	New()
		..()
		SPAWN_DBG(0)
			if(src.bioHolder && src.bioHolder.mobAppearance)
				src.bioHolder.mobAppearance.customization_first = "Dreadlocks"
				src.bioHolder.mobAppearance.customization_second = "Full Beard"

				SPAWN_DBG(1 SECOND)
					src.bioHolder.mobAppearance.UpdateMob()

			//src.mind = new
			src.gender = "male"
			src.real_name = pick("M", "m") + pick("a", "ah", "ae") + pick("ch", "tch", "tz") + pick("o", "oh", "oe") + " " + pick("M","m") + pick("a","ae","e") + pick("n","nn")

			if (!src.reagents)
				var/datum/reagents/R = new/datum/reagents(1000)
				src.reagents = R
				R.my_atom = src

			src.reagents.add_reagent("stimulants", 200)

			src.equip_new_if_possible(/obj/item/clothing/shoes/macho, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/macho, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/armor/vest/macho, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/glasses/macho, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/macho, slot_head)
			src.equip_new_if_possible(/obj/item/storage/belt/macho_belt, slot_belt)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (!src.stat && prob(6))
			src.visible_message("<b>[src]</b> mutters to himself.")
			playsound(src.loc, pick(snd_macho_idle), 50, 0, 0, src.get_age_pitch())

//	movement_delay()
//		return ..() - 10

	show_inv(mob/user)
		if (src.stance == "defensive")
			macho_parry(user)
			return
		..()
		return

	attack_hand(mob/user)
		if (src.stance == "defensive")
			src.visible_message("<span class='alert'><B>[user] attempts to attack [src]!</B></span>")
			playsound(src.loc, "sound/impact_sounds/Generic_Swing_1.ogg", 50, 1)
			sleep(0.2 SECONDS)
			macho_parry(user)
			return
		..()
		return

	attackby(obj/item/W, mob/user)
		if (src.stance == "defensive")
			src.visible_message("<span class='alert'><B>[user] swings at [src] with the [W.name]!</B></span>")
			playsound(src.loc, "sound/impact_sounds/Generic_Swing_1.ogg", 50, 1)
			sleep(0.2 SECONDS)
			macho_parry(user, W)
			return
		..()
		return

	Bump(atom/movable/AM, yes)
		if (src.stance == "offensive")
			if ((!( yes ) || src.now_pushing))
				return
			now_pushing = 1
			if (ismob(AM))
				var/mob/M = AM
				boutput(src, "<span class='alert'><B>You power-clothesline [M]!</B></span>")
				for (var/mob/C in oviewers(src))
					shake_camera(C, 8, 3)
					C.show_message("<span class='alert'><B>[src] clotheslines [M] into oblivion!</B></span>", 1)
				M.changeStatus("stunned", 80)
				M.changeStatus("weakened", 5 SECONDS)
				var/turf/target = get_edge_target_turf(src, src.dir)
				M.throw_at(target, 10, 2)
				playsound(src.loc, "swing_hit", 40, 1)
			else if (isobj(AM))
				var/obj/O = AM
				if (O.density)
					playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
					if (istype(O, /obj/machinery/door))
						var/obj/machinery/door/D = O
						if (D.open())
							boutput(src, "<span class='alert'><B>You forcefully kick open [D]!</B></span>")
							for (var/mob/C in oviewers(D))
								shake_camera(C, 8, 3)
								C.show_message("<span class='alert'><B>[src] forcefully kicks open [D]!</B></span>", 1)
						else
							boutput(src, "<span class='alert'><B>You forcefully kick [D]!</B></span>")
							for (var/mob/C in oviewers(src))
								shake_camera(C, 8, 3)
								C.show_message("<span class='alert'><B>[src] forcefully kicks [D]!</B></span>", 1)
							if (prob(33))
								qdel(D)
					else if(O.anchored != 2)
						boutput(src, "<span class='alert'><B>You crash into [O]!</B></span>")
						for (var/mob/C in oviewers(src))
							shake_camera(C, 8, 3)
							C.show_message("<span class='alert'><B>[src] crashes into [O]!</B></span>", 1)
						if ((istype(O, /obj/window) && !istype(O, /obj/window/auto/reinforced/indestructible)) || istype(O, /obj/grille) || istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
							qdel(O)
						else
							var/turf/target = get_edge_target_turf(src, src.dir)
							O.throw_at(target, 10, 2)
			now_pushing = 0
		else
			..()
			return

	proc/macho_parry(mob/M, obj/item/W)
		if (M)
			src.dir = get_dir(src, M)
			if (W)
				W.cant_self_remove = 0
				W.set_loc(src)
				M.u_equip(W)
				W.layer = HUD_LAYER
				src.put_in_hand_or_drop(W)
				src.visible_message("<span class='alert'><B>[src] grabs the [W.name] out of [M]'s hands, shoving [M] to the ground!</B></span>")
			else
				src.visible_message("<span class='alert'><B>[src] parries [M]'s attack, knocking them to the ground!</B></span>")
			M.changeStatus("weakened", 10 SECONDS)
			playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 65, 1)
			SPAWN_DBG(2 SECONDS)
				playsound(src.loc, pick(snd_macho_rage), 60, 0, 0, src.get_age_pitch())
		return

	verb/macho_offense()
		set name = "Stance - Offensive"
		set desc = "Take an offensive stance and tackle people in your way"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			src.stance = "offensive"

	verb/macho_defense()
		set name = "Stance - Defensive"
		set desc = "Take a defensive stance and counter any attackers"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			src.stance = "defensive"

	verb/macho_normal()
		set name = "Stance - Normal"
		set desc = "We all know this stance is for boxing the hell out of dudes."
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			src.stance = "normal"

	verb/macho_grasp(var/mob/living/M as mob in oview(1))
		set name = "Macho Grasp"
		set desc = "Instantly grab someone in a headlock"
		set category = "Macho Moves"
		if (istype(M) && !src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (G.affecting == M)
					return
			playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
			src.visible_message("<span class='alert'><B>[src] aggressively grabs [M]!</B></span>")
			var/obj/item/grab/G = new /obj/item/grab( src )
			G.assailant = src
			src.put_in_hand(G, src.hand)
			G.affecting = M
			M.grabbed_by += G
			M.changeStatus("stunned", 10 SECONDS)
			G.state = 2
			G.update_icon()
			src.dir = get_dir(src, M)
			playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 65, 1)

	verb/macho_headcrunch()
		set name = "Grapple - Headcruncher"
		set desc = "Pulverize the head of a dude you grabbed"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (ishuman(G.affecting))
					var/mob/living/carbon/human/H = G.affecting
					var/obj/item/affecting = H.organs["head"]
					playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
					src.visible_message("<span class='alert'><B>[src] crushes [H]'s skull like a grape!</B></span>")
					affecting.take_damage(50, 0)
					H.take_brain_damage(60)
					H.changeStatus("stunned", 80)
					H.changeStatus("weakened", 5 SECONDS)
					H.UpdateDamageIcon()
					qdel(G)
				else
					playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 75, 1)
					src.visible_message("<span class='alert'><B>[src] crushes [G.affecting]'s body into bits!</B></span>")
					G.affecting.gib()
					qdel(G)
				SPAWN_DBG(2 SECONDS)
					playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
					src.visible_message("<span class='alert'><b>[src]</b> lets out an angry warcry!</span>")
				break

	verb/macho_chestcrunch()
		set name = "Grapple - Ribcracker"
		set desc = "Pulverize the ribcage of a dude you grabbed"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (ishuman(G.affecting))
					var/mob/living/carbon/human/H = G.affecting
					var/obj/item/affecting = H.organs["chest"]
					playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
					src.visible_message("<span class='alert'><B>[src] crushes [H]'s ribcage open like a bag of chips!</B></span>")
					affecting.take_damage(500, 0)
					H.changeStatus("stunned", 80)
					H.changeStatus("weakened", 5 SECONDS)
					H.UpdateDamageIcon()
					qdel(G)
				else
					playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 75, 1)
					src.visible_message("<span class='alert'><B>[src] crushes [G.affecting]'s body into bits!</B></span>")
					G.affecting.gib()
					qdel(G)
				SPAWN_DBG(2 SECONDS)
					playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
					src.visible_message("<span class='alert'><b>[src]</b> lets out an angry warcry!</span>")
				break

	verb/macho_leap()
		set name = "Macho Leap"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			//Restricting possible leap areas to prevent NERDSS from finding secrets when they get turned into a matzo man
			var/list/possible_areas = get_areas(/area/station)
			possible_areas += get_areas(/area/diner)
			possible_areas += get_areas(/area/radiostation/studio)
			possible_areas += get_areas(/area/sim)
			var/area/A = input("Select the area to leap to: ", "Select Area", null) as null|anything in possible_areas
			if (!A)
				return

			src.transforming = 1
			src.verbs -= /mob/living/carbon/human/machoman/verb/macho_leap
			var/mob/living/H = null
			var/obj/item/grab/G = null
			for (G in src)
				if (isliving(G.affecting))
					H = G.affecting
			if (H)
				if (H.lying)
					H.lying = 0
					H.delStatus("paralysis")
					H.delStatus("weakened")
					H.set_clothing_icon_dirty()
				H.transforming = 1
				H.set_density(0)
				H.set_loc(src.loc)
			else
				src.visible_message("<span class='alert'>[src] closes his eyes for a moment.</span>")
				playsound(src.loc, "sound/voice/macho/macho_breathing18.ogg", 50, 0, 0, src.get_age_pitch())
				sleep(4 SECONDS)
			src.set_density(0)
			if (H)
				src.dir = get_dir(src, H)
				H.dir = get_dir(H, src)
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
				src.visible_message("<span class='alert'><B>[src] grabs [H] and flies through the ceiling!</B></span>")
			else
				src.visible_message("<span class='alert'>[src] flies through the ceiling!</span>")
			playsound(src.loc, "sound/effects/bionic_sound.ogg", 50)
			playsound(src.loc, "sound/voice/macho/macho_become_enraged01.ogg", 50, 0, 0, src.get_age_pitch())
			for (var/i = 0, i < 20, i++)
				src.pixel_y += 15
				src.dir = turn(src.dir, 90)
				if (H)
					H.pixel_y += 15
					H.dir = turn(H.dir, 90)
					switch(src.dir)
						if (NORTH)
							H.pixel_x = src.pixel_x
							H.layer = src.layer - 1
						if (SOUTH)
							H.pixel_x = src.pixel_x
							H.layer = src.layer + 1
						if (EAST)
							H.pixel_x = src.pixel_x - 8
							H.layer = src.layer - 1
						if (WEST)
							H.pixel_x = src.pixel_x + 8
							H.layer = src.layer - 1
				sleep(0.1 SECONDS)
			src.set_loc(pick(get_area_turfs(A, 1)))
			if (H)
				src.visible_message("<span class='alert'>[src] suddenly descends from the ceiling with [H]!</span>")
				H.set_loc(src.loc)
			else
				src.visible_message("<span class='alert'>[src] suddenly descends from the ceiling!</span>")
			playsound(src.loc, "sound/effects/bionic_sound.ogg", 50)
			for (var/i = 0, i < 20, i++)
				src.pixel_y -= 15
				src.dir = turn(src.dir, 90)
				if (H)
					H.pixel_y -= 15
					H.dir = turn(H.dir, 90)
					switch(src.dir)
						if (NORTH)
							H.pixel_x = src.pixel_x
							H.layer = src.layer - 1
						if (SOUTH)
							H.pixel_x = src.pixel_x
							H.layer = src.layer + 1
						if (EAST)
							H.pixel_x = src.pixel_x - 8
							H.layer = src.layer - 1
						if (WEST)
							H.pixel_x = src.pixel_x + 8
							H.layer = src.layer - 1
				sleep(0.1 SECONDS)
			if (G)
				qdel(G)
			playsound(src.loc, "explosion", 50)
			playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
			for (var/mob/M in viewers(src, 5))
				if (M != src)
					M.changeStatus("weakened", 80)
				SPAWN_DBG(0)
					shake_camera(M, 4, 2)
			if (istype(src.loc, /turf/simulated/floor))
				src.loc:break_tile()
			if (H)
				src.visible_message("<span class='alert'><B>[src] ultra atomic piledrives [H]!!</B></span>")
				var/obj/overlay/O = new/obj/overlay(get_turf(src))
				O.anchored = 1
				O.name = "Explosion"
				O.layer = NOLIGHT_EFFECTS_LAYER_BASE
				O.pixel_x = -92
				O.pixel_y = -96
				O.icon = 'icons/effects/214x246.dmi'
				O.icon_state = "explosion"
				SPAWN_DBG(3.5 SECONDS) qdel(O)
				random_brute_damage(H, 50)
				H.changeStatus("weakened", 1 SECOND)
				H.pixel_x = 0
				H.pixel_y = 0
				H.transforming = 0
				H.set_density(1)
			src.pixel_x = 0
			src.pixel_y = 0
			src.transforming = 0
			src.set_density(1)
			SPAWN_DBG(0.5 SECONDS)
				src.verbs += /mob/living/carbon/human/machoman/verb/macho_leap

	verb/macho_rend()
		set name = "Macho Rend"
		set desc = "Tears a target limb from limb"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (isliving(G.affecting))
					src.verbs -= /mob/living/carbon/human/machoman/verb/macho_rend
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					src.transforming = 1
					src.dir = get_dir(src, H)
					H.dir = get_dir(H, src)
					src.visible_message("<span class='alert'><B>[src] menacingly grabs [H] by the chest!</B></span>")
					playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
					var/dir_offset = get_dir(src, H)
					switch(dir_offset)
						if (NORTH)
							H.pixel_y = -24
							H.layer = src.layer - 1
						if (SOUTH)
							H.pixel_y = 24
							H.layer = src.layer + 1
						if (EAST)
							H.pixel_x = -24
							H.layer = src.layer - 1
						if (WEST)
							H.pixel_x = 24
							H.layer = src.layer - 1
					for (var/i = 0, i < 5, i++)
						H.pixel_y += 2
						sleep(0.3 SECONDS)
					if (ishuman(H))
						var/mob/living/carbon/human/HU = H
						src.visible_message("<span class='alert'><B>[src] begins tearing [H] limb from limb!</B></span>")
						var/original_age = HU.bioHolder.age
						if (HU.limbs.l_arm)
							HU.limbs.l_arm.sever()
							playsound(src.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 75)
							HU.emote("scream")
							HU.bioHolder.age += 10
							sleep(1 SECOND)
						if (HU.limbs.r_arm)
							HU.limbs.r_arm.sever()
							playsound(src.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 75)
							HU.emote("scream")
							HU.bioHolder.age += 10
							sleep(1 SECOND)
						if (HU.limbs.l_leg)
							HU.limbs.l_leg.sever()
							playsound(src.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 75)
							HU.emote("scream")
							HU.bioHolder.age += 10
							sleep(1 SECOND)
						if (HU.limbs.r_leg)
							HU.limbs.r_leg.sever()
							playsound(src.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 75)
							HU.emote("scream")
							sleep(1 SECOND)
						HU.bioHolder.age = original_age
						HU.changeStatus("stunned", 10 SECONDS)
						HU.changeStatus("weakened", 10 SECONDS)
						var/turf/target = get_edge_target_turf(src, src.dir)
						SPAWN_DBG(0)
							playsound(src.loc, "swing_hit", 40, 1)
							src.visible_message("<span class='alert'><B>[src] casually punts [H] away!</B></span>")
							HU.throw_at(target, 10, 2)
						HU.pixel_x = 0
						HU.pixel_y = 0
						HU.transforming = 0
					else
						src.visible_message("<span class='alert'><B>[src] shreds [H] to ribbons with his bare hands!</B></span>")
						H.transforming = 0
						H.gib()
					src.transforming = 0
					src.verbs += /mob/living/carbon/human/machoman/verb/macho_rend
					SPAWN_DBG(2 SECONDS)
						playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
						src.visible_message("<span class='alert'><b>[src]</b> gloats and boasts!</span>")

	verb/macho_summon_arena()
		set name = "Macho Arena"
		set desc = "Summon a wrestling ring."
		set category = "Macho Moves"

		if (!src.stat && !src.transforming)
			if(!macho_arena_turfs) // no arena exists
				//var/arena_time = 45 SECONDS
				src.verbs -= /mob/living/carbon/human/machoman/verb/macho_summon_arena
				var/ring_radius = 4
				playsound(src.loc, "sound/voice/chanting.ogg", 75, 0, 0, src.get_age_pitch())
				src.visible_message("<span class='alert'><B>[src] begins summoning a wrestling ring!</B></span>", "<span class='alert'><B>You begin summoning a wrestling ring!</B></span>")
				for (var/mob/living/M in oviewers(ring_radius + 4, get_turf(src)))
					M.apply_sonic_stun(6, 3, stamina_damage = 0)

				sleep(1.2 SECONDS)
				var/turf/Aloc = get_turf(src)
				var/list/arenaropes = list()
				for (var/turf/T in range(ring_radius, Aloc))
					/*   // too many issues with canpass and/or lights breaking, maybe sometime in the future?
					if(isfloor(T))
						animate_buff_out(T)
						SPAWN_DBG(10)
							var/floor_type = T.type
							var/turf/unsimulated/floor/specialroom/gym/macho_arena/new_turf = T.ReplaceWith("/turf/unsimulated/floor/specialroom/gym/macho_arena/new_turf", 1)
							new_turf.previous_turf_type = floor_type
							new_turf.alpha = 0
							arenaropes += new_turf
					*/
					if(get_dist(Aloc,T) == ring_radius) // boundaries
						if(abs(Aloc.x - T.x) == ring_radius && abs(Aloc.y - T.y) == ring_radius) // arena corners
							var/obj/stool/chair/boxingrope_corner/FF = new/obj/stool/chair/boxingrope_corner(T)
							FF.alpha = 0
							if(T.x < Aloc.x) // to the west
								if(T.y > Aloc.y) // north-west corner
									FF.dir = NORTHWEST
								else
									FF.dir = SOUTHWEST
							else // to the east
								if(T.y > Aloc.y) // north-east
									FF.dir = NORTHEAST
								else
									FF.dir = SOUTHEAST
							arenaropes += FF
							var/random_deviation = rand(0, 5)
							SPAWN_DBG(random_deviation)
								spawn_animation1(FF)
								SPAWN_DBG(10) // animation, also to simulate them coming in and slamming into the ground
									FF.visible_message("<span class='alert'><B>[FF] slams and anchors itself into the ground!</B></span>")
									playsound(T, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 40, 1)
									for (var/mob/living/M in oviewers(ring_radius * 2, T))
										shake_camera(M, 8, 3)
						else // arena ropes
							var/obj/decal/boxingrope/FF = new/obj/decal/boxingrope(T)
							arenaropes += FF
							if(abs(Aloc.x - T.x) == ring_radius) // side ropes
								if(T.x - Aloc.x < 0)  // west rope
									FF.dir = WEST
								else // east rope
									FF.dir = EAST
							else // top/bottom ropes
								if(T.y - Aloc.y > 0) // north ropes
									FF.dir = NORTH
								else
									FF.dir = SOUTH
							FF.alpha = 0
				sleep(1.4 SECONDS)
				macho_arena_turfs = arenaropes
				/*   // too many issues with canpass and/or lights breaking, maybe sometime in the future?
				for (var/turf/unsimulated/floor/specialroom/gym/macho_arena/F in arenaropes)
					animate_buff_in(F)
				*/
				for (var/obj/decal/boxingrope/F in arenaropes)
					spawn_animation1(F)
				src.verbs += /mob/living/carbon/human/machoman/verb/macho_summon_arena
			else
				var/list/arenaropes = macho_arena_turfs
				macho_arena_turfs = null
				/*   // too many issues with canpass and/or lights breaking, maybe sometime in the future?
				for (var/turf/unsimulated/floor/specialroom/gym/macho_arena/F in arenaropes)
					SPAWN_DBG(0)
						arenaropes -= F
						animate_buff_out(F)
						SPAWN_DBG(10)
							F.change_back()
				*/
				for (var/obj/decal/boxingrope/F in arenaropes)
					SPAWN_DBG(0)
						arenaropes -= F
						leaving_animation(F)
						qdel(F)
				for (var/obj/stool/chair/boxingrope_corner/F in arenaropes)
					SPAWN_DBG(0)
						arenaropes -= F
						leaving_animation(F)
						qdel(F)

	verb/macho_slimjim_snap()
		set name = "Macho Slim-Jim Snap"
		set desc = "Snaps a target into a slim jim."
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (isliving(G.affecting))
					src.verbs -= /mob/living/carbon/human/machoman/verb/macho_slimjim_snap
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					src.transforming = 1
					src.dir = get_dir(src, H)
					H.dir = get_dir(H, src)
					src.visible_message("<span class='alert'><B>[src] menacingly grabs [H] by the chest!</B></span>")
					playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
					var/dir_offset = get_dir(src, H)
					switch(dir_offset)
						if (NORTH)
							H.pixel_y = -24
							H.layer = src.layer - 1
						if (SOUTH)
							H.pixel_y = 24
							H.layer = src.layer + 1
						if (EAST)
							H.pixel_x = -24
							H.layer = src.layer - 1
						if (WEST)
							H.pixel_x = 24
							H.layer = src.layer - 1
					for (var/i = 0, i < 5, i++)
						H.pixel_y += 2
						sleep(0.3 SECONDS)

					playsound(src.loc, "sound/voice/macho/macho_slimjim.ogg", 75) // SNAP INTO A SLIM JIM!
					sleep(0.5 SECONDS)
					if (ishuman(H))
						var/mob/living/carbon/human/HU = H
						src.visible_message("<span class='alert'><B>[src] begins snapping [H]'s body!</B></span>")
						var/number_of_snaps = 5
						var/i
						for(i = 0; i < number_of_snaps; i++)
							playsound(HU.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
							HU.emote("scream")
							take_bleeding_damage(HU, src, 5, DAMAGE_STAB)
							HU.Scale(1 + (rand(-30, 20) * 0.01), 1 + (rand(-20, 30) * 0.01))
							HU.Turn(rand(-60, 90))
							HU.bioHolder.age += 10
							sleep(1 SECOND)

						playsound(src.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 100, 1)
						var/obj/victimjim = new /obj/item/reagent_containers/food/snacks/slimjim(HU.loc)
						HU.visible_message("<span class='alert'><B>The only thing that remains after [H] is a Slim Jim!</B></span>", "<span class='alert'><B>Your body is snapped into a Slim Jim!</B></span>")
						victimjim.setMaterial(getMaterial("flesh"))
						victimjim.name = "Slim [HU.real_name]"
						HU.ghostize()
						qdel(HU)
					else
						H.visible_message("<span class='alert'><B>[src] snaps [H] into a Slim Jim with his bare hands!</B></span>", "<span class='alert'><B>Your body is snapped into a Slim Jim!</B></span>")
						playsound(H.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 100, 1)
						var/obj/victimjim = new /obj/item/reagent_containers/food/snacks/slimjim(H.loc)
						victimjim.setMaterial(getMaterial("flesh"))
						victimjim.name = "Slim [H.real_name]"
						H.ghostize()
						qdel(H)
					src.transforming = 0
					src.verbs += /mob/living/carbon/human/machoman/verb/macho_slimjim_snap
					SPAWN_DBG(20)
						playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
						src.visible_message("<span class='alert'><b>[src]</b> gloats and boasts!</span>")

	verb/macho_touch()
		set name = "Macho Touch"
		set desc = "Transmutes a living target into gold"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (isliving(G.affecting))
					src.verbs -= /mob/living/carbon/human/machoman/verb/macho_touch
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					src.transforming = 1
					src.dir = get_dir(src, H)
					H.dir = get_dir(H, src)
					src.visible_message("<span class='alert'><B>[src] picks up [H] by the throat!</B></span>")
					playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
					var/dir_offset = get_dir(src, H)
					switch(dir_offset)
						if (NORTH)
							H.pixel_y = -24
							H.layer = src.layer - 1
						if (SOUTH)
							H.pixel_y = 24
							H.layer = src.layer + 1
						if (EAST)
							H.pixel_x = -24
							H.layer = src.layer - 1
						if (WEST)
							H.pixel_x = 24
							H.layer = src.layer - 1
					for (var/i = 0, i < 5, i++)
						H.pixel_y += 2
						sleep(0.3 SECONDS)
					src.transforming = 0
					src.bioHolder.AddEffect("fire_resist")
					src.transforming = 1
					playsound(src.loc, "sound/voice/chanting.ogg", 75, 0, 0, src.get_age_pitch())
					src.visible_message("<span class='alert'>[src] begins radiating with dark energy!</span>")
					sleep(4 SECONDS)
					for (var/mob/N in viewers(src, null))
						N.flash(3 SECONDS)
						if (N.client)
							shake_camera(N, 6, 4)
							N.show_message(text("<span class='alert'><b>A blinding light envelops [src]!</b></span>"), 1)

					playsound(src.loc, "sound/weapons/flashbang.ogg", 50, 1)
					qdel(G)
					src.transforming = 0
					src.bioHolder.RemoveEffect("fire_resist")
					src.verbs += /mob/living/carbon/human/machoman/verb/macho_touch
					SPAWN_DBG(0)
						if (H)
							H.desc = "A really dumb looking statue. Very shiny, though."
							H.become_gold_statue()
							H.transforming = 0

/*	verb/macho_minions()
		set name = "Macho Minions"
		set desc = "Summons a horde of micro men"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			src.verbs -= /mob/living/carbon/human/machoman/verb/macho_minions
			src.bioHolder.AddEffect("fire_resist")
			src.transforming = 1
			src.visible_message("<span class='alert'><B>[src] begins glowing with ominous power!</B></span>")
			playsound(src.loc, "sound/voice/chanting.ogg", 75, 0, 0, src.get_age_pitch())
			sleep(4 SECONDS)
			for (var/mob/N in viewers(src, null))
				N.flash(3 SECONDS)
				if (N.client)
					shake_camera(N, 6, 4)
					N.show_message(text("<span class='alert'><b>A blinding light envelops [src]!</b></span>"), 1)
			playsound(src.loc, "sound/weapons/flashbang.ogg", 50, 1)
			src.visible_message("<span class='alert'><B>A group of micro men suddenly materializes!</B></span>")
			var/made_minions = 0
			for (var/turf/T in orange(1))
				var/obj/critter/microman/micro = new(T)
				made_minions ++
				micro.friends += src
				micro.dir = src.dir
				if (made_minions >= MAX_MINIONS_PER_SPAWN)
					break
			src.transforming = 0
			src.bioHolder.RemoveEffect("fire_resist")
			playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
			SPAWN_DBG(2 MINUTES) // holy shit the micro man spam from ONE macho man is awful
				src.verbs += /mob/living/carbon/human/machoman/verb/macho_minions
*/
	verb/macho_piledriver()
		set name = "Atomic Piledriver"
		set desc = "Piledrive a target"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (isliving(G.affecting))
					src.verbs -= /mob/living/carbon/human/machoman/verb/macho_piledriver
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					src.transforming = 1
					src.set_density(0)
					H.set_density(0)
					H.set_loc(src.loc)
					src.dir = get_dir(src, H)
					H.dir = get_dir(H, src)
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
					src.visible_message("<span class='alert'><B>[src] grabs [H] and spins in the air!</B></span>")
					playsound(src.loc, "sound/effects/bionic_sound.ogg", 50)
					for (var/i = 0, i < 15, i++)
						src.pixel_y += 6
						H.pixel_y += 6
						src.dir = turn(src.dir, 90)
						H.dir = turn(H.dir, 90)
						switch(src.dir)
							if (NORTH)
								H.pixel_x = src.pixel_x
								H.layer = src.layer - 1
							if (SOUTH)
								H.pixel_x = src.pixel_x
								H.layer = src.layer + 1
							if (EAST)
								H.pixel_x = src.pixel_x - 8
								H.layer = src.layer - 1
							if (WEST)
								H.pixel_x = src.pixel_x + 8
								H.layer = src.layer - 1
						sleep(0.1 SECONDS)
					src.pixel_x = 0
					src.pixel_y = 0
					src.transforming = 0
					H.pixel_x = 0
					H.pixel_y = 0
					H.transforming = 0
					src.set_density(1)
					H.set_density(1)
					qdel(G)
					playsound(src.loc, "explosion", 50)
					src.visible_message("<span class='alert'><B>[src] atomic piledrives [H]!</B></span>")
					var/obj/overlay/O = new/obj/overlay(get_turf(src))
					O.anchored = 1
					O.name = "Explosion"
					O.layer = NOLIGHT_EFFECTS_LAYER_BASE
					O.pixel_x = -92
					O.pixel_y = -96
					O.icon = 'icons/effects/214x246.dmi'
					O.icon_state = "explosion"
					SPAWN_DBG(3.5 SECONDS) qdel(O)
					random_brute_damage(H, 50)
					H.changeStatus("weakened", 10 SECONDS)
					src.verbs += /mob/living/carbon/human/machoman/verb/macho_piledriver

	verb/macho_superthrow()
		set name = "Macho Throw"
		set desc = "Throw someone super hard"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (isliving(G.affecting))
					src.verbs -= /mob/living/carbon/human/machoman/verb/macho_superthrow
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					src.transforming = 1
					src.set_density(0)
					H.set_density(0)
					H.set_loc(src.loc)
					step(H, src.dir)
					H.dir = get_dir(H, src)
					src.visible_message("<span class='alert'><B>[src] starts spinning around [H]!</B></span>")
					playsound(src.loc, "sound/effects/bionic_sound.ogg", 50)
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
						src.dir = turn(src.dir, 90)
						H.set_loc(get_step(src, src.dir))
						H.dir = get_dir(H, src)
						sleep(delay)
					src.pixel_x = 0
					src.pixel_y = 0
					src.transforming = 0
					H.pixel_x = 0
					H.pixel_y = 0
					src.set_density(1)
					qdel(G)
					playsound(src.loc, "sound/weapons/rocket.ogg", 50)
					src.visible_message("<span class='alert'><B>[src] flings [H] with all of his might!</B></span>")
					var/target_dir = get_dir(src, H)
					SPAWN_DBG(0)
						if (H)
							walk(H, target_dir, 1)
							sleep(1.5 SECONDS)
							playsound(src.loc, "explosion", 50)
							var/obj/overlay/O = new/obj/overlay(get_turf(H))
							O.anchored = 1
							O.name = "Explosion"
							O.layer = NOLIGHT_EFFECTS_LAYER_BASE
							O.pixel_x = -92
							O.pixel_y = -96
							O.icon = 'icons/effects/214x246.dmi'
							O.icon_state = "explosion"
							O.fingerprintslast = src.key
							SPAWN_DBG(3.5 SECONDS) qdel(O)
							explosion(O, H.loc, 1, 2, 3, 4, 1)
							H.gib()
					src.verbs += /mob/living/carbon/human/machoman/verb/macho_superthrow

	verb/macho_soulsteal()
		set name = "Macho Soul Steal"
		set desc = "Steals a target's soul to restore health"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (isliving(G.affecting))
					src.verbs -= /mob/living/carbon/human/machoman/verb/macho_soulsteal
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					src.transforming = 1
					src.dir = get_dir(src, H)
					H.dir = get_dir(H, src)
					src.visible_message("<span class='alert'><B>[src] picks up [H] by the throat!</B></span>")
					playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
					var/dir_offset = get_dir(src, H)
					switch(dir_offset)
						if (NORTH)
							H.pixel_y = -24
							H.layer = src.layer - 1
						if (SOUTH)
							H.pixel_y = 24
							H.layer = src.layer + 1
						if (EAST)
							H.pixel_x = -24
							H.layer = src.layer - 1
						if (WEST)
							H.pixel_x = 24
							H.layer = src.layer - 1
					for (var/i = 0, i < 5, i++)
						H.pixel_y += 2
						sleep(0.3 SECONDS)
					src.transforming = 0
					src.bioHolder.AddEffect("fire_resist")
					src.transforming = 1
				//	var/icon/composite = icon(src.icon, src.icon_state, null, 1)
				//	composite.MapColors(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
				//	for (var/O in src.overlays)
				//		var/image/I = O
				//		var/icon/Ic = icon(I.icon, I.icon_state)
				//		Ic.MapColors(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
				//		composite.Blend(Ic, ICON_OVERLAY)
				//	src.overlays = null
				//	src.icon = composite
					playsound(src.loc, "sound/voice/chanting.ogg", 75, 0, 0, src.get_age_pitch())
					src.visible_message("<span class='alert'><b>[src] begins radiating with evil energies!</b></span>")
					sleep(4 SECONDS)
					for (var/mob/N in viewers(src, null))
						N.flash(3 SECONDS)
						if (N.client)
							shake_camera(N, 6, 4)
							N.show_message(text("<span class='alert'><b>A blinding light envelops [src]!</b></span>"), 1)

					playsound(src.loc, "sound/weapons/flashbang.ogg", 50, 1)
					qdel(G)
					src.transforming = 0
					src.bioHolder.RemoveEffect("fire_resist")
					src.verbs += /mob/living/carbon/human/machoman/verb/macho_soulsteal
					for (var/A in src.organs)
						var/obj/item/affecting = null
						if (!src.organs[A])    continue
						affecting = src.organs[A]
						if (!isitem(affecting))
							continue
						affecting.heal_damage(50, 50) //heals 50 burn, 50 brute from all organs
					src.take_toxin_damage(-INFINITY)
					src.UpdateDamageIcon()
					if (H)
						H.pixel_x = 0
						H.pixel_y = 0
						H.take_toxin_damage(5000)
						H.transforming = 0
						if (ishuman(H))
							H.set_mutantrace(/datum/mutantrace/skeleton)
							H.set_body_icon_dirty()
	verb/macho_heal()
		set name = "Macho Healing"
		set desc = "Sacrifice your health to heal someone else"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (isliving(G.affecting))
					src.verbs -= /mob/living/carbon/human/machoman/verb/macho_heal
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.transforming = 1
					src.transforming = 1
					src.dir = get_dir(src, H)
					H.dir = get_dir(H, src)
					src.visible_message("<span class='alert'><B>[src] gently picks up [H]!</B></span>")
					playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
					var/dir_offset = get_dir(src, H)
					switch(dir_offset)
						if (NORTH)
							H.pixel_y = -24
							H.layer = src.layer - 1
						if (SOUTH)
							H.pixel_y = 24
							H.layer = src.layer + 1
						if (EAST)
							H.pixel_x = -24
							H.layer = src.layer - 1
						if (WEST)
							H.pixel_x = 24
							H.layer = src.layer - 1
					for (var/i = 0, i < 5, i++)
						H.pixel_y += 2
						sleep(0.3 SECONDS)
					src.transforming = 0
					src.bioHolder.AddEffect("fire_resist")
					src.transforming = 1
					playsound(src.loc, "sound/voice/heavenly.ogg", 75)
					src.visible_message("<span class='alert'><b>[src] closes \his eyes in silent macho prayer!</b></span>")
					sleep(4 SECONDS)
					for (var/mob/N in viewers(src, null))
						N.flash(3 SECONDS)
						if (N.client)
							shake_camera(N, 6, 4)
							N.show_message(text("<span class='alert'><b>A blinding light envelops [src]!</b></span>"), 1)

					playsound(src.loc, "sound/weapons/flashbang.ogg", 50, 1)
					qdel(G)
					src.transforming = 0
					src.bioHolder.RemoveEffect("fire_resist")
					src.verbs += /mob/living/carbon/human/machoman/verb/macho_heal
					random_brute_damage(src, 25)
					src.UpdateDamageIcon()
					SPAWN_DBG(0)
						if (H)
							H.pixel_x = 0
							H.pixel_y = 0
							H.transforming = 0
							H.full_heal()
	verb/macho_stare()
		set name = "Macho Stare"
		set desc = "Stares deeply at a victim, causing them to explode"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			for (var/obj/item/grab/G in src)
				if (isliving(G.affecting))
					src.verbs -= /mob/living/carbon/human/machoman/verb/macho_stare
					var/mob/living/H = G.affecting
					if (H.lying)
						H.lying = 0
						H.delStatus("paralysis")
						H.delStatus("weakened")
						H.set_clothing_icon_dirty()
					H.jitteriness = 0
					H.transforming = 1
					src.transforming = 1
					src.dir = get_dir(src, H)
					H.dir = get_dir(H, src)
					src.visible_message("<span class='alert'><B>[src] picks up [H] by the throat!</B></span>")
					playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
					var/dir_offset = get_dir(src, H)
					switch(dir_offset)
						if (NORTH)
							H.pixel_y = -24
							H.layer = src.layer - 1
						if (SOUTH)
							H.pixel_y = 24
							H.layer = src.layer + 1
						if (EAST)
							H.pixel_x = -24
							H.layer = src.layer - 1
						if (WEST)
							H.pixel_x = 24
							H.layer = src.layer - 1
					for (var/i = 0, i < 5, i++)
						H.pixel_y += 2
						sleep(0.3 SECONDS)
					src.transforming = 0
					src.bioHolder.AddEffect("fire_resist")
					src.transforming = 1
					playsound(src.loc, "sound/weapons/phaseroverload.ogg", 100)
					src.visible_message("<span class='alert'><b>[src] begins intensely staring [H] in the eyes!</b></span>")
					boutput(H, "<span class='alert'>You feel a horrible pain in your head!</span>")
					sleep(0.5 SECONDS)
					H.make_jittery(1000)
					H.visible_message("<span class='alert'><b>[H] starts violently convulsing!</b></span>")
					sleep(4 SECONDS)
					playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
					qdel(G)
					var/location = get_turf(H)
					src.transforming = 0
					src.bioHolder.RemoveEffect("fire_resist")
					src.verbs += /mob/living/carbon/human/machoman/verb/macho_stare
					if (H.client)
						var/mob/dead/observer/newmob
						newmob = new/mob/dead/observer(H)
						H:client:mob = newmob
						H.mind.transfer_to(newmob)
						newmob.corpse = null
					H.visible_message("<span class='alert'><b>[H] instantly vaporizes into a cloud of blood!</b></span>")
					for (var/mob/N in viewers(src, null))
						if (N.client)
							shake_camera(N, 6, 4)
					qdel(H)
					SPAWN_DBG(0)
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

	verb/macho_heartpunch(var/mob/living/M in oview(1))
		set name = "Macho Heartpunch"
		set desc = "Punches a guy's heart. Right out of their body."
		set category = "Macho Moves"

		var/did_it = 0
		src.verbs -= /mob/living/carbon/human/machoman/verb/macho_heartpunch
		var/direction = get_dir(src,M)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.organHolder && H.organHolder.heart)
				//PUNCH THE HEART! YEAH!
				src.visible_message("<span class='alert'><B>[src] punches out [H]'s heart!</B></span>")
				playsound(src, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)

				var/obj/item/organ/heart/heart_to_punt = H.organHolder.drop_organ("heart")

				for (var/I = 1, I <= 5 && heart_to_punt && step(heart_to_punt,direction, 1), I++)
//						new D(heart_to_punt.loc)
					bleed(H, 25, 5)
					playsound(heart_to_punt,'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

				H.emote("scream")
				did_it = 1
			else
				src.show_text("Man, this poor sucker ain't got a heart to punch, whatta chump.", "blue")
				SPAWN_DBG(2 SECONDS)
					if (!src.stat)
						src.emote("sigh")

		else if (isrobot(M)) //Extra mean to borgs.

			var/mob/living/silicon/robot/R = M
			if (R.part_chest)
				src.visible_message("<span class='alert'><B>[src] punches off [R]'s chest!</B></span>")
				playsound(src, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
				R.emote("scream")
				var/obj/item/parts/robot_parts/chest/chestpunt = new R.part_chest.type(R.loc)
				chestpunt.name = "[R.name]'s [chestpunt.name]"
				R.compborg_lose_limb(R.part_chest)

				for (var/I = 1, I <= 5 && chestpunt && step(chestpunt ,direction, 1), I++)
					make_cleanable(/obj/decal/cleanable/oil,chestpunt.loc)
					playsound(chestpunt,'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

				did_it = 1

			else //Uh?
				src.show_text("Man, this poor sucker ain't even got a chest to punch, whatta chump.", "blue")
				SPAWN_DBG (20)
					if (!src.stat)
						src.emote("sigh")

		else
			src.show_text("You're not entirely sure where the heart is on this thing. Better leave it alone.", "blue")
			SPAWN_DBG (20)
				if (!src.stat)
					src.emote("sigh")

		if (did_it)
			SPAWN_DBG (rand(2,4) * 10)
				playsound(src.loc, pick(snd_macho_rage), 50, 0, 0, src.get_age_pitch())
				src.visible_message("<span class='alert'><b>[src]</b> gloats and boasts!</span>")

		src.verbs += /mob/living/carbon/human/machoman/verb/macho_heartpunch
/*
	verb/macho_meteor()
		set name = "Macho Meteors"
		set desc = "Summon a wave of meteors with dark macho magic"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			src.bioHolder.AddEffect("fire_resist")
			src.transforming = 1
			src.mouse_opacity = 0
			src.verbs -= /mob/living/carbon/human/machoman/verb/macho_meteor
			src.visible_message("<span class='alert'>[src] pauses and curses for a moment.</span>")
			playsound(src.loc, "sound/voice/macho/macho_alert26.ogg", 50)
			sleep(4 SECONDS)
			src.visible_message("<span class='alert'>[src] begins to hover mysteriously above the ground!</span>")
			playsound(src.loc, "sound/effects/bionic_sound.ogg", 50)
			playsound(src.loc, "sound/voice/macho/macho_moan07.ogg", 50)
			src.layer = 10
			src.set_density(0)
			for (var/i = 0, i < 20, i++)
				src.pixel_y += 1
				src.dir = turn(src.dir, 90)
				sleep(0.1 SECONDS)
			src.dir = SOUTH
			var/sound/siren = sound('sound/misc/airraid_loop.ogg')
			var/list/masters = new()
			for (var/area/subs in world)
				if (subs.master && !(subs.master in masters))
					masters += subs.master

			for (var/area/A in masters)
				if (A.type == /area) continue
				for (var/area/R in A.related)
					SPAWN_DBG(0)
						R.eject = 1
						R.updateicon()
			siren.repeat = 1
			siren.channel = 5
			boutput(world, siren)
			randomevent_meteorshower(16)
			sleep(30 SECONDS)
			src.visible_message("<span class='alert'>[src] falls back to the ground!</span>")
			for (var/i = 0, i < 20, i++)
				src.pixel_y -= 1
				src.dir = turn(src.dir, -90)
				sleep(0.1 SECONDS)
			if (istype(src.loc, /turf/simulated/floor))
				src.loc:break_tile()
			for (var/mob/M in viewers(src, 5))
				if (M != src)
					M.weakened = max(M.weakened, 8)
				SPAWN_DBG(0)
					shake_camera(M, 4, 2)
			playsound(src.loc, "explosion", 40, 1)
			playsound(src.loc, pick(snd_macho_rage), 50)
			src.layer = MOB_LAYER
			src.set_density(1)
			src.transforming = 0
			src.bioHolder.RemoveEffect("fire_resist")
			src.mouse_opacity = 1
			SPAWN_DBG(1 MINUTE)
				if (siren)
					siren.repeat = 0
					siren.status = SOUND_UPDATE
					siren.channel = 5
					boutput(world, siren)
				for (var/area/A in masters)
					if (A.type == /area) continue
					for (var/area/R in A.related)
						SPAWN_DBG(0)
							R.eject = 0
							R.updateicon()
				src.verbs += /mob/living/carbon/human/machoman/verb/macho_meteor
*/
	emote(var/act, var/emoteTarget = null)
		switch(act)
			if ("scream")
				if (src.mind && src.mind.special_role && src.mind.special_role == "faustian macho man")
					return
				else
					playsound(src.loc, pick(snd_macho_rage), 75, 0, 0, src.get_age_pitch())
					src.visible_message("<span class='alert'><b>[src] yells out a battle cry!</b></span>")
			else
				..()

/*   // too many issues with canpass and/or lights breaking, maybe sometime in the future?
/turf/unsimulated/floor/specialroom/gym/macho_arena
	var/previous_turf_type

	New(var/loc,var/turf_type)
		..()
		previous_turf_type = turf_type

	proc/change_back()
		var/turf/old_turf = src.ReplaceWith(previous_turf_type)
		animate_buff_in(old_turf)
*/

/obj/critter/microman
	name = "Micro Man"
	desc = "All the macho madness you'd ever need, shrunk down to pocket size."
	icon_state = "microman"
	health = 25
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 1
	density = 0
	angertext = "rages at"

	New()
		..()
		if (prob(50))
			playsound(src.loc, pick(snd_macho_rage), 50, 1, 0, 1.75)

	ai_think()
		..()
		if (prob(10))
			playsound(src.loc, pick(snd_macho_idle), 50, 1, 0, 1.75)

	attack_hand(mob/user as mob)
		if (src.alive && (user.a_intent != INTENT_HARM))
			src.visible_message("<span class='alert'><b>[user]</b> pets [src]!</span>")
			return
		..()

	CritterAttack(mob/M)
		if (ismob(M))
			src.attacking = 1
			var/attack_message = ""
			switch(rand(1,3))
				if (1)
					attack_message = "<B>[src]</B> punches [src.target] in the stomach!"
				if (2)
					attack_message = "<B>[src]</B> kicks [src.target] with his shoes!"
				if (3)
					attack_message = "<B>[src]</B> headbutts [src.target]!"
			for (var/mob/O in viewers(src, null))
				O.show_message("<span class='alert'>[attack_message]</span>", 1)
			playsound(src.loc, "swing_hit", 30, 0)
			if (prob(10))
				playsound(src.loc, pick(snd_macho_rage), 50, 1, 0, 1.75)
			random_brute_damage(src.target, rand(0,1))
			SPAWN_DBG(rand(1,3))
				src.attacking = 0

	ChaseAttack(mob/M)
		for (var/mob/O in viewers(src, null))
			O.show_message("<span class='alert'><B>[src]</B> charges at [M]!</span>", 1)
		if (prob(50))
			playsound(src.loc, pick(snd_macho_rage), 50, 1, 0, 1.75)
		M.changeStatus("stunned", 1 SECOND)
		if (prob(25))
			M.changeStatus("weakened", 2 SECONDS)
			random_brute_damage(M, rand(1,2))
	CritterDeath()
		..()
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 75, 1)
		var/obj/decal/cleanable/blood/gibs/gib = null
		gib = make_cleanable(/obj/decal/cleanable/blood/gibs,src.loc)
		gib.streak(list(NORTH, NORTHEAST, NORTHWEST))
		qdel(src)


/obj/item/clothing/under/gimmick/macho
	name = "wrestling pants"
	desc = "Official pants of the Space Wrestling Federation."
	icon_state = "machopants"
	item_state = "machopants"

/obj/item/clothing/suit/armor/vest/macho
	name = "tiger stripe vest"
	desc = "A flamboyant showman's vest."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_gimmick.dmi'
	icon_state = "machovest"
	item_state = "machovest"

/obj/item/clothing/glasses/macho
	name = "Yellow Shades"
	desc = "A snazzy pair of shades."
	icon_state = "machoglasses"
	item_state = "glasses"

/obj/item/clothing/head/helmet/macho
	name = "Macho Man Doo-Rag"
	desc = "'To my perfect friend' - signed, Mr. Perfect"
	icon_state = "machohat"

/obj/item/storage/belt/macho_belt
	name = "Championship Belt"
	desc = "Awarded to the best space wrestler of the year."
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "machobelt"
	item_state = "machobelt"
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH

/obj/item/clothing/shoes/macho
	name = "Wrestling boots"
	desc = "Cool pair of boots."
	icon_state = "machoboots"

/obj/item/macho_coke
	name = "unmarked white bag"
	desc = "Contains columbian sugar."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cokebag"
	item_state = "chefhat" // lol
	w_class = 1

	attack(mob/target as mob)
		if (istype(target, /mob/living/carbon/human/machoman))
			target.visible_message("<span class='alert'>[target] shoves \his face deep into [src] and breathes deeply!</span>")
			playsound(target.loc, "sound/voice/macho/macho_breathing02.ogg", 50, 1)
			sleep(2.5 SECONDS)
			playsound(target.loc, "sound/voice/macho/macho_freakout.ogg", 50, 1)
			target.visible_message("<span class='alert'>[target] appears visibly stronger!</span>")
			if (target.reagents)
				target.reagents.add_reagent("stimulants", 100)
			if (ishuman(target))
				var/mob/living/carbon/human/machoman/H = target
				for (var/A in H.organs)
					var/obj/item/affecting = null
					if (!H.organs[A])    continue
					affecting = H.organs[A]
					if (!isitem(affecting))
						continue
					affecting.heal_damage(50, 50) //heals 50 burn, 50 brute from all organs
				H.UpdateDamageIcon()
				H.bodytemperature = H.base_body_temp
		else
			target.visible_message("<span class='alert'>[target] shoves \his face deep into [src]!</span>")
			SPAWN_DBG(2.5 SECONDS)
			target.visible_message("<span class='alert'>[target]'s pupils dilate.</span>")
			target.changeStatus("stunned", 10 SECONDS)

/obj/item/reagent_containers/food/snacks/slimjim
	name = "Space Jim"
	desc = "It's a stick of mechanically-separated mystery meat."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "slimjim"
	item_state = "stamp"
	heal_amt = 2
	amount = 5
	initial_volume = 50
	initial_reagents = list("capsaicin"=20,"porktonium"=30)
	New()
		..()

	attack(var/mob/M, var/mob/user, def_zone)
		if (istype(M, /mob/living/carbon/human/machoman) && M == user)
			playsound(user.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 75, 1)
			playsound(user.loc, "sound/voice/macho/macho_slimjim.ogg", 60)
			for (var/mob/O in viewers(user))
				O.show_message("<span class='alert'><B>[user] snaps into a Space Jim!!</B></span>", 1)
			sleep(rand(10,20))
			var/turf/T = get_turf(M)
			playsound(user.loc, "explosion", 100, 1)
			SPAWN_DBG(0)
				var/obj/overlay/O = new/obj/overlay(T)
				O.anchored = 1
				O.name = "Explosion"
				O.layer = NOLIGHT_EFFECTS_LAYER_BASE
				O.pixel_x = -92
				O.pixel_y = -96
				O.icon = 'icons/effects/214x246.dmi'
				O.icon_state = "explosion"
				SPAWN_DBG(3.5 SECONDS) qdel(O)
				for (var/mob/N in viewers(user))
					shake_camera(N, 8, 3)
			SPAWN_DBG(0)
				var/obj/item/old_grenade/emp/temp_nade = new(user.loc)
				temp_nade.prime()
			SPAWN_DBG(0)
				for (var/atom/A in range(user.loc, 4))
					if (ismob(A) && A != user)
						var/mob/N = A
						N.changeStatus("weakened", 80)
						step_away(N, user)
						step_away(N, user)
					else if (isobj(A) || isturf(A))
						A.ex_act(3)
		else
			..()

/mob/living/proc/become_gold_statue()
	var/obj/overlay/goldman = new /obj/overlay(get_turf(src))
	src.pixel_x = 0
	src.pixel_y = 0
	src.set_loc(goldman)
	goldman.name = "golden statue of [src.name]"
	goldman.desc = src.desc
	goldman.anchored = 0
	goldman.set_density(1)
	goldman.layer = MOB_LAYER
	goldman.dir = src.dir

	var/ist = "body_f"
	if (src.gender == "male")
		ist = "body_m"
	var/icon/composite = icon('icons/mob/human.dmi', ist, null, 1)
	for (var/O in src.overlays)
		var/image/I = O
		composite.Blend(icon(I.icon, I.icon_state, null, 1), ICON_OVERLAY)
	composite.ColorTone( rgb(255,215,0) ) // gold
	goldman.icon = composite
	src.remove()

//#undef MAX_MINIONS_PER_SPAWN
