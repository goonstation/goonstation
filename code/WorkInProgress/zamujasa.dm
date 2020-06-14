/obj/very_important_wire
	name = "very conspicuous cable"
	desc = "Some sort of cabling that runs under the floor. Looks pretty important."
	density = 0
	anchored = 1
	icon = 'icons/obj/power_cond.dmi'
	icon_state = "1-10"
	layer = CABLE_LAYER
	color = "#037ffc"

	attackby(obj/item/W as obj, mob/user as mob)
		if (issnippingtool(W))
			logTheThing("station", user, null, "cut the don't-cut-this wire and got ghosted/disconnected as a result.")
			//boutput(user, "<span class='alert'>You snip the ca</span>")
			user.visible_message("[user] nearly snips the cable with \the [W], but suddenly freezes in place just before it cuts!", "<span class='alert'>You snip the ca</span>")
			var/client/C = user.client
			user.ghostize()
			del(C)
			return

		..()
		return



/obj/item/device/speechtotext
	name = "dumb microphone"
	desc = "This is really stupid."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "mic"
	item_state = "mic"

	hear_talk(mob/M as mob, msg, real_name, lang_id)
		var/turf/T = get_turf(src)
		if (M in range(1, T))
			src.talk_into(M, msg, null, real_name, lang_id)

	talk_into(mob/M as mob, messages, param, real_name, lang_id)
		new /obj/maptext_junk/speech(M, msg = messages[1])


/obj/maptext_junk
	mouse_opacity = 0
	density = 0
	opacity = 0
	icon = null
	plane = PLANE_HUD - 1
	maptext = ""


#ifdef DEBUG_LIGHTING_UPDATES
/obj/maptext_junk/RL_counter
	icon = null
	maptext = ""
	anchored = 2
	var/applies = 0
	var/updates = 0
	var/gen = 0
	var/wait = 0
	icon = 'icons/effects/white.dmi'

	proc/tick(var/apply = 0, var/update = 0, var/generation)
		if (update)
			updates++
		if (apply)
			applies++
		wait++
		src.gen = generation
		src.maptext = "<span class='c vm ps2p ol'><span style='color: #ffff00'>[updates]</span>\n<span style='color: #00ffff'>[applies]</span>\n<span class='pixel'>[src.gen]</span></span>"
		src.color = null;
		animate(src, color = "#ffffff", time = 15, flags = ANIMATION_END_NOW)
		animate(color = "#999999", time = 2)
#endif


/obj/maptext_junk/damage
	name = "damage popup"
	maptext_y = 16
	maptext_x = -32
	maptext_width = 96

	New(var/change = 0)
		if (abs(change) < 1)
			del(src)
			return

		var/hcol = (change > 0) ? "#88ff88" : "#ff6666"
		maptext = "<span class='ps2p c sh' style='color: [hcol];'>[change > 0 ? "+" : ""][round(change, 1)]</span>"

		if (change < 0)
			var/xofs = rand(32, 78) * (prob(50) ? 1 : -1)
			var/yofs = rand(60, 100)
			animate(src, maptext_y = yofs, time = 8, easing = EASE_OUT | QUAD_EASING, flags = ANIMATION_RELATIVE)
			animate(alpha = -255, maptext_y = yofs * -1, time = 8, easing = EASE_IN | QUAD_EASING, flags = ANIMATION_RELATIVE)
			animate(maptext_x = xofs * 1.5, time = 16, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		else
			animate(src, maptext_y = 56, time = 8, easing = EASE_OUT | QUAD_EASING)
			animate(time = 8)
			animate(maptext_y = 52, alpha = 0, time = 4, easing = EASE_OUT | CUBIC_EASING)

		// ptoato said to just call del directly so blame them
		SPAWN_DBG(4 SECONDS)
			del(src)


/obj/maptext_junk/speech
	name = "spoken chat"
	maptext_x = -64
	maptext_y = 28
	maptext_width = 160
	maptext_height = 48
	alpha = 0
	var/bumped = 0

	New(mob/M as mob, msg, style = "")
		for (var/obj/maptext_junk/speech/O in M.vis_contents)
			if (!istype(O))
				continue
			O.bump_up()

		M.vis_contents += src

		maptext = "<span class='pixel c sh' style=\"[style]\">[msg]</span>"
		animate(src, alpha = 255, maptext_y = 34, time = 4)

		SPAWN_DBG(4 SECONDS)
			bump_up()


		SPAWN_DBG(7 SECONDS)
			del(src)

	proc/bump_up()
		if (bumped)
			return
		src.bumped = 1
		animate(src, alpha = 0, maptext_y = maptext_y + 8, time = 4)


/obj/ptl_mirror
#define NW_SE 0
#define SW_NE 1

	anchored = 1
	density = 1
	opacity = 0
	icon = 'icons/obj/glass.dmi'
	icon_state = "sheet"

	var/facing = NW_SE
	var/list/affecting = list()

	attack_hand(mob/user as mob)
		boutput(usr, "rotating mirror...")
		facing = 1 - facing
		for (var/obj/machinery/power/pt_laser/PTL in affecting)
			//
			boutput(usr, "[PTL] would be notified")


	attackby(obj/item/W as obj, mob/user as mob)
		if (iswrenchingtool(W))
			boutput(usr, "this would deconstruct it.")
			return

		..()
		return

#undef NW_SE
#undef SW_NE





/obj/invisible_teleporter
	name = "invisible teleporter side 1"
	desc = "Totally not a portal."
	event_handler_flags = USE_HASENTERED
	icon = 'icons/effects/letter_overlay.dmi'
	icon_state = "A"
	anchored = 1
	density = 0
	var/id = null
	var/which_end = 0
	invisibility = 0
	var/busy = 0

	New()
		..()
		if (!id)
			id = icon_state
		src.tag = "invisportal[id][which_end]"
		desc += " Tag: [tag]"
		/*
		src.maptext = "<span class='pixel sh'>[tag]</span>"
		src.maptext_width = 128
		*/

	HasEntered(AM as mob|obj)
		if (AM == src)
			// jesus christ don't teleport OURSELVES
			return
		Z_LOG_DEBUG("shit", "Checking things: event_handler_flags [event_handler_flags], [AM] entered")
		if (busy || istype(AM, /obj/overlay/tile_effect) || istype(AM, /mob/dead) || istype(AM, /mob/wraith) || istype(AM, /mob/living/intangible))
			Z_LOG_DEBUG("shit", "Decided not to teleport")
			return ..()

		Z_LOG_DEBUG("shit", "Doing teleport")
		do_the_teleport(AM)


	proc/do_the_teleport(atom/movable/AM as mob|obj)
		Z_LOG_DEBUG("shit", "Teleporting [AM]")
		var/obj/invisible_teleporter/other_side = locate("invisportal[id][which_end ? "0" : "1"]")
		if (!istype(other_side))
			Z_LOG_DEBUG("shit", "Couldn't find another warp point (invisportal[id][which_end ? "0" : "1"]) ??????? ")
			return
		other_side.busy = 1
		Z_LOG_DEBUG("shit", "okie dokie warpy popry")
		AM.set_loc(get_turf(other_side))
		other_side.busy = 0

	destination
		name = "invisible teleporter side 2"
		which_end = 1
		icon_state = "A"


	receive_only
		name = "invisible teleporter (exit only)"
		icon_state = "A"
		which_end = 1
		color = "#FF0000"
		event_handler_flags = 0




/obj/afterlife_donations
	name = "afterlife thing"
	icon = 'icons/obj/32x64.dmi'
	icon_state = "voting_box"
	density = 1
	flags = FPRINT
	anchored = 1
	desc = "Funds further renovations for the afterlife. You can put the fruits / vegetables / minerals / bombs you grew into this (click this with them or click-drag them onto it)."
	var/total_score = 0
	var/round_score = 0
	var/obj/maptext_junk/tracker = null
	var/working = 0

	New()
		total_score = world.load_intra_round_value("afterlife_donations")
		tracker = new /obj/maptext_junk()
		tracker.pixel_y = 40
		tracker.pixel_x = -48
		tracker.maptext_width = 128
		tracker.alpha = 120
		src.vis_contents += tracker
		update_totals()

	get_desc()
		return " It's saved a total of [round(total_score)] points, with [round(round_score)] points added today."

	proc/update_totals()
		tracker.maptext = "<span class='c vt ps2p sh'>TOTAL [add_lspace(round(total_score), 7)]\nROUND [add_lspace(round(round_score), 7)]</span>"


	attackby(obj/item/W as obj, mob/user as mob)
		var/score = get_item_value(W)
		if (score == -1)
			return ..()

		boutput(user, "<span class='notice'>[src] mulches up [W].</span>")
		user.u_equip(W)
		W.dropped()
		mulch_item(W, score)
		var/MT = start_scoring()
		update_score(MT, score)
		finish_scoring(MT)
		//give_points(W, score)
		return



	proc/get_item_value(obj/item/W as obj)
		var/base_score = 0

		if (istype(W, /obj/item/reagent_containers/food/snacks/plant))
			var/obj/item/reagent_containers/food/snacks/plant/I = W
			base_score = 2 + I.quality

		else if (istype(W, /obj/item/plant))
			var/obj/item/plant/I = W
			base_score = 2 + I.quality

		else if (istype(W, /obj/item/reagent_containers/food/snacks/mushroom))
			var/obj/item/reagent_containers/food/snacks/mushroom/I = W
			base_score = 2 + I.quality

		else if (istype(W, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/I = W
			base_score = 2 + I.quality

		else if (istype(W, /obj/item/raw_material))
			// todo : itd be nice to use matsci but thats supposedly getting updated soon agani
			var/obj/item/raw_material/I = W
			base_score = (3 + (I.metal + I.conductor + I.dense + I.crystal + I.powersource) * 2.5) * I.quality
			base_score *= I.amount
		else
			return -1

		return max(0, base_score)


	proc/mulch_item(var/obj/I, score)
		playsound(src.loc, "sound/impact_sounds/Slimy_Hit_4.ogg", 50, 1)
		pool( I )
		total_score += score
		round_score += score
		update_totals()

	proc/start_scoring()
		var/obj/maptext_junk/M = new /obj/maptext_junk()
		tracker.alpha = 255
		M.pixel_y = 20
		M.pixel_x = -16
		M.maptext_width = 64
		M.transform = matrix(2, 0, -16, 0, 2, 0)
		src.vis_contents += M
		working++
		return M

	proc/update_score(var/obj/maptext_junk/M, var/score)
		M.maptext = "<span class='ps2p c vm sh'>+[round(score)]</span>"

	proc/finish_scoring(var/obj/maptext_junk/M)
		animate(M, time = 2)
		animate(transform = matrix(1, 0, 0, 0, 1, 0), time = 5)
		animate(pixel_y = 20 + 6, time = 5)
		animate(pixel_y = 20 + 12, alpha = 0, time = 5)
		SPAWN_DBG(4 SECONDS)
			working--
			if (working == 0)
				// if > 1 then the score is still changing so just wait a while...
				world.save_intra_round_value("afterlife_donations", total_score)
				animate(tracker, alpha = 160, time = 10)
			src.vis_contents -= M
			qdel(M)


	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			boutput(user, "<span class='alert'>Excuse me you are dead, get your gross dead hands off that!</span>")
			return
		if (get_dist(user,src) > 1)
			boutput(user, "<span class='alert'>You need to move closer to [src] to do that.</span>")
			return
		if (get_dist(O,src) > 1 || get_dist(O,user) > 1)
			boutput(user, "<span class='alert'>[O] is too far away to load into [src]!</span>")
			return

		var/score = 0
		if (get_item_value(O) != -1)
			var/MT = start_scoring()
			user.visible_message("<span class='notice'>[user] begins quickly stuffing things into [src]!</span>")
			var/staystill = user.loc

			for(var/obj/item/P in view(1,user))
				if (user.loc != staystill) break
				var/addscore = get_item_value(P)
				if (addscore == -1)
					continue
				score += addscore
				mulch_item(P, addscore)
				update_score(MT, score)
				sleep(0.1 SECONDS)

			boutput(user, "<span class='notice'>You finish stuffing things into [src]!</span>")
			finish_scoring(MT)
		else ..()

/obj/death_button/clean_gunsim
	name = "button that will clean the murderbox"
	desc = "push this to clean the murderbox and probably not get killed. takes a minute."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "cleanbot1"

	var/area/sim/gunsim/gunsim
	var/active = 0

	New()
		SPAWN_DBG(0.5 SECONDS)
			gunsim = locate() in world

	attack_hand(mob/user as mob)
		if (active)
			boutput(user, "It just did some cleaning give it a minute!!!")
			return

		active = 1
		alpha = 128
		icon_state = "cleanbot-c"
		user.visible_message("CLEANIN UP THE MURDERBOX STAND CLEAR")

		SPAWN_DBG(0)
			for (var/obj/item/I in gunsim)
				if(istype(I, /obj/item/device/radio/intercom)) //lets not delete the intercoms inside shall we?
					continue
				else
					qdel(I)

			for (var/atom/S in gunsim)
				if(istype(S, /obj/storage) || istype(S, /obj/artifact) || istype(S, /obj/critter) || istype(S, /obj/machinery/bot) || istype(S, /obj/decal) || istype(S, /mob/living/carbon/human/tdummy))
					qdel(S)


/*
			for (var/obj/storage/S in gunsim)
				qdel(S)
			for (var/obj/artifact/A in gunsim)
				qdel(A)
			for (var/obj/critter/C in gunsim)
				qdel(C)
			for (var/obj/machinery/bot/B in gunsim)
				qdel(B)
			for (var/obj/decal/D in gunsim)
				qdel(D)
*/
		SPAWN_DBG(60 SECONDS)
			active = 0
			alpha = 255
			icon_state = "cleanbot1"


/obj/death_button/create_dummy
	name = "Button that creates a test dummy"
	desc = "click this to create a test dummy"
	icon = 'icons/mob/human.dmi'
	icon_state = "ghost"
	var/active = 0
	alpha = 255

	attack_hand(mob/user as mob)
		if (active)
			boutput(user, "did you already kill the dummy? either way wait a bit!")
			return

		active = 1
		alpha = 128
		boutput(user, "Spawning target dummy, stand by") //no need to be rude

		new /mob/living/carbon/human/tdummy(locate(src.x+1, src.y, src.z))
		//T.x = src.x + 1 // move it to the right


		SPAWN_DBG(10 SECONDS)
			active = 0
			alpha = 255


/proc/fancy_pressure_bar(var/pressure, var/max_pressure, var/width = 300)

	var/pct = max_pressure && pressure / max_pressure
	var/bar_bg_color = "#000000"
	var/bar_color = "#00cc00"
	var/bar_width = clamp(pct, 0, 1)
	if (pct > 1)
		bar_width = clamp((pressure / (max_pressure * 10)), 0, 1)
		bar_bg_color = "#b00000"
		bar_color = "#ffff00"

	. = {"
		<div style="width: [width + 2]px; border: 1px solid #000000; height: 1.25em; background: black;">
			<div style="width: [width + 2]px; border: 1px solid #bbbbbb; height: 100%; background: [bar_bg_color]; position: relative;">
				<div style="position: absolute; top: 2px; bottom: 2px; left: 1px; right: [round(100 - bar_width * 100)]%; background-color: [bar_color];"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 0%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 10%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 20%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 30%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 40%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 50%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 60%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 70%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 80%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -2px; left: 90%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: -3px; margin-left: -3px; left: 100%; background: #ffffff; height: 4px; border: 1px solid black; width: 1px;"></div>
				<div style="position: absolute; top: 0.12em; left: 100%; width: 7em; text-align: right; margin-left: 1em; font-weight: bold;">[pressure] kPa</div>
			</div>
		</div>
	"}




// if haine can have sailor moon, then i'm doing this and you cant stop me
/obj/item/clow_key
	name = "\improper Clow key"
	desc = "RELEEEAAAAAAAAAASSSSEEEEEEEEEEEEEEEEEEEE!"
	icon = 'icons/obj/junk.dmi'
	icon_state = "clowkey"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "nothing"
	uses_multiple_icon_states = 1
	flags = FPRINT | TABLEPASS | ONBELT
	force = 0
	w_class = 1
	throwforce = 1
	throw_speed = 3
	throw_range = 8
	stamina_damage = 1
	stamina_cost = 1
	stamina_crit_chance = 0
	var/active = 0

	attack_self(mob/user as mob)
		src.active = !( src.active )
		if (src.active)
			src.name = "\improper Clow wand"
			src.desc = "Hoeeeh!? This is only useful if you're decked out."
			src.icon_state = "clowwand"
			src.item_state = "clowwand"
			src.w_class = 4
		else
			src.name = initial(src.name)
			src.desc = initial(src.desc)
			src.icon_state = initial(src.icon_state)
			src.item_state = initial(src.item_state)
			src.w_class = initial(src.w_class)

		user.update_inhands()
		src.add_fingerprint(user)
		..()




/obj/decal/big_number
	name = "big number"
	mouse_opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/32x64.dmi'
	icon_state = "num0"
	layer = TURF_LAYER + 0.1 // it should basically be part of a turf
	plane = PLANE_FLOOR // hence, they should be on the same plane!



/area/football
	name = "Space American Football Stadium"
	force_fullbright = 1
	icon_state = "purple"

/area/football/field
	name = "Space American Football Field"
	icon_state = "green"

	endzone
		icon_state = "yellow"
		var/team = null

		red
			name = "Red Team Endzone"
			icon_state = "red"
			team = "blue"
		blue
			name = "Blue Team Endzone"
			icon_state = "blue"
			team = "red"

		Entered(atom/movable/O)
			..()
			if (isobserver(O) || !istype(ticker.mode, /datum/game_mode/football))
				return
			var/datum/game_mode/football/F = ticker.mode
			if (ismob(O))
				var/mob/jerk = O
				if (F.the_football in jerk.contents)
					F.score_a_goal(src.team)

			else if (O == F.the_football)
				F.score_a_goal(src.team, 1)

			return



/area/football/staging
	name = "Football Locker Rooms"
	sanctuary = 1
	icon_state = "death"



/obj/landmark/football
	name = "join"
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "landmark"
	New()
		football_spawns[src.name] += src.loc
		qdel(src)

	blue
		name = "blue"
		color = "#8888ff"
		field
			name = "bluefield"
			color = "#0000ff"
	red
		name = "red"
		color = "#ff8888"
		field
			name = "redfield"
			color = "#ff0000"

	football
		name = "football"
		color = "#00ff00"


/*
	Entered(atom/movable/O)
		var/dest = null
		..()
		if (isobserver(O))
			return
		if (ismob(O))
			var/mob/jerk = O
			dest = pick(get_area_turfs(current_battle_spawn,1))
			if(!dest)
				dest= pick(get_area_turfs(/area/station/maintenance/,1))
				boutput(jerk, "You somehow land in maintenance! Weird!")
			jerk.set_loc(dest)
			jerk.nodamage = 0
			jerk.removeOverlayComposition(/datum/overlayComposition/shuttle_warp)
			jerk.removeOverlayComposition(/datum/overlayComposition/shuttle_warp/ew)
		else if (isobj(O) && !istype(O, /obj/overlay/tile_effect))
			qdel(O)
		return
*/



/obj/machinery/fix_this_shit
	name = "\proper imcoder"
	desc = "They're not bugs, okay? They're <em>features</em>."
	icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "DONGS"
	plane = PLANE_HUD
	anchored = 1
	density = 1

	var/last_count = -1


	New()
		SubscribeToProcess()
		src.process()

	disposing()
		UnsubscribeProcess()
		..()

	process()
		if (src.last_count != runtime_count)
			src.last_count = runtime_count
			animate_storage_rustle(src)
			playsound(src, "sound/mksounds/gotitem.ogg",33, 0)
			src.maptext = "<span class='ps2p sh vb c'><span style='font-size: 12px;'>[runtime_count]</span>\nruntimes</span>"
			src.maptext_x = -100
			src.maptext_width = 232
			src.maptext_y = 34

	ex_act()
		return
