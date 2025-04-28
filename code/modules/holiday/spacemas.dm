//Xmas presents/ETC
//CONTAINS:
// * Setup and helper procs
// * Bootleg Guardbuddy Toy
// * Xmas Guardbuddy
// * Xmas Guardbuddy Module - Snowball launcher!
// * Seal Pup + walrus
// * Christmas Tree
// * Snow tiles
// * Christmas decoration
// * Grinch graffiti
// * Santa Claus stuff
// * Santa's letters landmark
// * Krampus 1.0 stuff
// * Stockings - from halloween.dm - wtf

// define used for removing spacemas objects when it's not xmas
#if defined(XMAS) || defined(CI_RUNTIME_CHECKING)
#define EPHEMERAL_XMAS EPHEMERAL_SHOWN
#else
#define EPHEMERAL_XMAS EPHEMERAL_HIDDEN
#endif

var/global/christmas_cheer = 60
var/global/xmas_respawn_lock = 0
var/global/santa_spawned = 0
var/global/krampus_spawned = 0

var/static/list/santa_snacks = list(/obj/item/reagent_containers/food/drinks/eggnog,/obj/item/reagent_containers/food/snacks/cookie,
/obj/item/reagent_containers/food/snacks/ice_cream/random,/obj/item/reagent_containers/food/snacks/pie/apple,/obj/item/reagent_containers/food/snacks/snack_cake,
/obj/item/reagent_containers/food/snacks/yoghurt/frozen,/obj/item/reagent_containers/food/snacks/granola_bar,/obj/item/reagent_containers/food/snacks/candy/chocolate)

/proc/modify_christmas_cheer(var/mod)
	if (!mod || !isnum(mod))
		return
#ifdef XMAS
	christmas_cheer += mod

	if (!xmas_respawn_lock)
		if (christmas_cheer >= 80 && !santa_spawned)
			SPAWN(0) // Might have been responsible for locking up the mob loop via human Life() -> death() -> modify_christmas_cheer() -> santa_krampus_spawn().
				santa_krampus_spawn(0)
#endif
#if defined(XMAS) && !defined(RP_MODE)
		if (christmas_cheer <= 10 && !krampus_spawned)
			SPAWN(0)
				santa_krampus_spawn(1)
#endif

// Might as well tweak Santa/Krampus respawn to make it use the universal player selection proc I wrote (Convair880).
/proc/santa_krampus_spawn(var/which_one = 0, var/confirmation_delay = 1200)
	if ((xmas_respawn_lock != 0) || (!ticker?.mode?.do_antag_random_spawns))
		return
	if (!isnum(confirmation_delay) || confirmation_delay < 0)
		message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (setup failed).")
		return

	xmas_respawn_lock = 1

	// Setup.
	var/list/text_messages = list()
	if (confirmation_delay > 0) // These are irrelevant when player selection is instantaneous (confirmation_delay == 0).
		text_messages.Add("Would you like to respawn as [which_one == 0 ? "Santa Claus" : "Krampus"]? Your name will be added to the list of eligible candidates and may be selected at random by the game.")
		text_messages.Add("You are eligible to be respawned as [which_one == 0 ? "Santa Claus" : "Krampus"]. You have [confirmation_delay / 10] seconds to respond to the offer.")

		message_admins("[which_one == 0 ? "Santa Claus" : "Krampus"] respawn is sending offer to eligible ghosts. They have [confirmation_delay / 10] seconds to respond.")

	// Select player.
	var/list/datum/mind/candidates = dead_player_list(1, confirmation_delay, text_messages, for_antag = which_one)
	if (!islist(candidates) || length(candidates) <= 0)
		message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (no eligible candidates found).")
		xmas_respawn_lock = 0
		return

	var/datum/mind/M = candidates[1]
	if (!(M && istype(M) && M.current))
		message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (candidate selection failed).")
		xmas_respawn_lock = 0
		return

	// Respawn player.
	var/mob/L
	var/ASLoc = pick_landmark(LANDMARK_LATEJOIN)
	var/WSLoc = pick_landmark(LANDMARK_WIZARD)

	if (!ASLoc)
		message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (no late-join landmark found).")
		xmas_respawn_lock = 0
		return
	log_respawn_event(M, "[which_one == 0 ? "Santa Claus" : "Krampus"]", null)
	if (which_one == 0)
		L = new /mob/living/carbon/human/santa
		if (!(L && ismob(L)))
			message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (new mob couldn't be created).")
			xmas_respawn_lock = 0
			return

		if (!WSLoc)
			L.set_loc(ASLoc)
		else
			L.set_loc(WSLoc)

		var/mob/current_mob
		if (M.current)
			current_mob = M.current
		M.transfer_to(L)
		if (current_mob)
			qdel(current_mob)

		M.assigned_role = "Santa Claus"
		boutput(L, SPAN_NOTICE("<b>You have been respawned as Santa Claus!</b>"))
		boutput(L, "Go to the station and reward the crew for their high faith in Spacemas. Use your Spacemas magic!")
		boutput(L, "<b>Do not reference anything that happened during your past life!</b>")
		santa_spawned = 1

		SPAWN(0)
			L.choose_name(3, "Santa Claus", "Santa Claus")

	else
		L = new /mob/living/carbon/cube/meat/krampus
		if (!(L && ismob(L)))
			message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (new mob couldn't be created).")
			xmas_respawn_lock = 0
			return

		L.set_loc(ASLoc)

		var/mob/current_mob
		if (M.current)
			current_mob = M.current
		M.transfer_to(L)
		if (current_mob)
			qdel(current_mob)

		boutput(L, "[SPAN_NOTICE("<b>You have been respawned as Krampus 3.0! [SPAN_NOTICE("CUTTING EDGE!")]</b>")]")
		boutput(L, "The station has been very naughty. <b>FUCK. UP. EVERYTHING.</b> This may be a little harder than usual.")
		boutput(L, "Be on the lookout for grinches. Do not harm them!")
		boutput(L, "<b>Do not reference anything that happened during your past life!</b>")
		krampus_spawned = 1

	message_admins("[which_one == 0 ? "Santa Claus" : "Krampus"] respawn completed successfully for player [L.mind.key] at [log_loc(L)].")
	xmas_respawn_lock = 0
	return

// Grandma, no! you picked the wrong one!
/obj/machinery/bot/guardbot/bootleg
	name = "Super Protector Friend III"
	desc = "The label on the back reads 'New technology! Blinking light action!'."
	icon = 'icons/obj/bots/robuddy/super-protector-friend.dmi'

	speak(var/message)
		var/fontmode = rand(1,4)
		switch(fontmode)
			if(1) return ..("<font face='Comic Sans MS' size=3>[uppertext(message)]!!</font>")
			if(2) return ..("<font face='Curlz MT'size=3>[uppertext(message)]!!</font>")
			if(3) return ..("<font face='System'size=3>[uppertext(message)]!!</font>")
			else
				var/honk = pick("WACKA", "QUACK","QUACKY","GAGGLE")
				if(!ON_COOLDOWN(src, "bootleg_sound", 15 SECONDS))
					playsound(src.loc, 'sound/misc/amusingduck.ogg', 50, 0)
				return ..("<font face='Comic Sans MS' size=3>[honk]!!</font>")
	Move()
		if(..())
			pixel_x = rand(-6, 6)
			pixel_y = rand(-6, 6)
			if(prob(5) && limiter.canISpawn(/obj/effects/sparks))
				var/obj/sparks = new /obj/effects/sparks
				sparks.set_loc(src.loc)
				SPAWN(2 SECONDS) if (sparks) qdel(sparks)
			return TRUE

/obj/machinery/bot/guardbot/xmas
	name = "Jinglebuddy"
	desc = "Festive!"
	skin_icon_state = "xmasbuddy"
	setup_default_tool_path = /obj/item/device/guardbot_tool/xmas

	speak(var/message)
		message = ("<font face='Segoe Script'><i><b>[message]</b></i></font>")
		. = ..()

	explode()
		if(src.exploding) return
		src.exploding = 1
		var/death_message = pick("I'll be back again some day!", "And to all a good night!", "A buddy is never truly happy until it is loved by a child. ", "I guess Spacemas isn't coming this year.", "Ho ho hFATAL ERROR")
		speak(death_message)
		src.visible_message(SPAN_COMBAT("<b>[src] blows apart!</b>"))
		var/turf/T = get_turf(src)
		if(src.mover)
			src.mover.master = null
			qdel(src.mover)

		src.invisibility = INVIS_ALWAYS_ISH
		var/obj/overlay/Ov = new/obj/overlay(T)
		Ov.anchored = ANCHORED
		Ov.name = "Explosion"
		Ov.layer = NOLIGHT_EFFECTS_LAYER_BASE
		Ov.pixel_x = -92
		Ov.pixel_y = -96
		Ov.icon = 'icons/effects/214x246.dmi'
		Ov.icon_state = "explosion"

		src.tool.set_loc(get_turf(src))

		var/list/throwparts = list()
		throwparts += new /obj/item/parts/robot_parts/arm/left/standard(T)
		throwparts += new /obj/item/device/flash(T)
		//throwparts += core
		throwparts += src.tool
		if(src.hat)
			throwparts += src.hat
			src.hat.set_loc(T)

		for(var/obj/O in throwparts) //This is why it is called "throwparts"
			var/edge = get_edge_target_turf(src, pick(alldirs))
			O.throw_at(edge, 100, 4)

		SPAWN(0) //Delete the overlay when finished with it.
			src.on = 0
			sleep(1.5 SECONDS)
			qdel(Ov)
			qdel(src)

		T.hotspot_expose(800,125)
		explosion(src, T, -1, -1, 2, 3)

		return

/obj/item/device/guardbot_tool/xmas
	name = "Snowballer XL tool module"
	desc = "An exotic module for PR-6S Guardbuddies designed to fire snowballs."
	icon_state = "tool_xmas"
	tool_id = "SNOW"
	is_stun = 1
	is_gun = 1
	var/datum/projectile/current_projectile = new/datum/projectile/snowball

	// Updated for new projectile code (Convair880).
	bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
		if(..()) return

		if(src.last_use && world.time < src.last_use + 80)
			return

		if (ranged)
			var/obj/projectile/P = shoot_projectile_ST_pixel_spread(master, current_projectile, target)
			if (!P)
				return

			user.visible_message(SPAN_ALERT("<b>[master] throws a snowball at [target]!</b>"))

		else
			var/obj/projectile/P = initialize_projectile_pixel_spread(master, current_projectile, target)
			if (!P)
				return

			user.visible_message(SPAN_ALERT("<b>[master] beans [target] point-blank with the snowball!</b>"))
			P.was_pointblank = 1
			hit_with_existing_projectile(P, target)

		src.last_use = world.time
		return

/datum/projectile/snowball
	name = "snowball"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "snowball"
	stun = 10
	cost = 25
	dissipation_rate = 2
	dissipation_delay = 4
	sname = "stun"
	shot_sound = 'sound/effects/pop.ogg'
	default_firemode = /datum/firemode/single
	damage_type = 0
	hit_ground_chance = 0
	window_pass = 0

	on_hit(atom/hit)
		if (!iscarbon(hit))
			return

		var/mob/living/carbon/O = hit
		if (!O.lying)
			O.lying = 1
			O.visible_message(SPAN_COMBAT("<b>[O] is knocked down by the snowball!</b>"))
			modify_christmas_cheer(1)
			boutput(O, "Brrr!")

		if (!O.is_hulk())
			O.changeStatus("knockdown", 10 SECONDS)

#ifdef USE_STAMINA_DISORIENT
			O.do_disorient(120, knockdown = 100, disorient = 80)
#else
			O.changeStatus("knockdown", 10 SECONDS)
#endif

		O.bodytemperature = max(0, O.bodytemperature - 5)

		O.set_clothing_icon_dirty()
		return

proc/compare_ornament_score(list/a, list/b)
	. = b["score"] - a["score"]

// Throughout December the icon will change!
/obj/xmastree
	EPHEMERAL_XMAS
	name = "Spacemas tree"
	desc = "O Spacemas tree, O Spacemas tree, Much p- Huh, there's a bunch of crayons and canvases under it, try clicking it?"
	icon = 'icons/obj/xmastree.dmi'
	icon_state = "xmastree_2023"
	anchored = ANCHORED
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	pixel_x = -64
	plane = PLANE_ABOVE_LIGHTING
	pixel_point = TRUE
	var/static/list/ornament_positions = list(
		list(62, 118),
		list(80, 117),
		list(95, 101),
		list(73, 95),
		list(48, 107),
		list(48, 90),
		list(30, 78),
		list(111, 86),
		list(84, 72),
		list(61, 70),
		list(29, 64),
		list(40, 59),
		list(116, 56),
		list(89, 53),
		list(57, 48),
		list(109, 47),
		list(74, 38),
		list(122, 35),
		list(99, 25),
		list(56, 25),
		list(28, 35),
		list(33, 20),
	)
	var/uses_custom_ornaments = TRUE
	var/ornament_sort = "weighted_random"
	var/best_sort_fuzziness = 0
	var/weighted_sort_flat_bonus = 0.15
	var/weighted_sort_reserved_slots_for_new = 8
	var/list/placed_ornaments = null
	var/list/ckeys_placed_this_round
	var/list/got_ornament_kit

	density = 1
	var/on_fire = 0
	var/image/fire_image = null

	latest_ornaments
		ornament_sort = "latest"

	best_ornaments
		ornament_sort = "best"

	fuzzy_top_ornaments
		ornament_sort = "best"
		best_sort_fuzziness = 0.1

	worst_ornaments
		ornament_sort = "worst"

	fewest_votes
		ornament_sort = "fewest_votes"

	random_ornaments
		ornament_sort = "random"

	weighted_random
		ornament_sort = "weighted_random"
		weighted_sort_flat_bonus = 0
		weighted_sort_reserved_slots_for_new = 0

	weighted_random_flatter
		ornament_sort = "weighted_random"
		weighted_sort_flat_bonus = 0.1
		weighted_sort_reserved_slots_for_new = 0

	New()
		..()
		src.fire_image = image('icons/effects/160x160.dmi', "")
		START_TRACKING
		if(uses_custom_ornaments)
			src.decorate()

	/// Calculates the "score" of an ornament based on upvotes and downvotes
	/// which_bound is -1 if you are sorting by best, 1 if you are sorting by worst
	proc/bound_of_wilson_score_confidence_interval_for_a_bernoulli_parameter_of_an_ornament(list/ornament, which_bound = -1)
		var/positive = length(ornament["upvoted"]) + 0.00001
		var/negative = length(ornament["downvoted"]) + 0.00001
		// source: https://www.evanmiller.org/how-not-to-sort-by-average-rating.html
		. = ((positive + 1.9208) / (positive + negative) + which_bound * \
			1.96 * sqrt((positive * negative) / (positive + negative) + 0.9604) / \
			(positive + negative)) / (1 + 3.8416 / (positive + negative))
		if(best_sort_fuzziness > 0)
			var/generator/G = generator("num", -best_sort_fuzziness, best_sort_fuzziness, NORMAL_RAND)
			. += G.Rand()

	proc/decorate()
		remove_all_ornaments()
		var/list/ornament_list = get_spacemas_ornaments().Copy()
		switch(ornament_sort)
			if("random")
				shuffle_list(ornament_list)
			if("latest")
				reverse_list(ornament_list)
			if("best")
				for(var/ornament_name in ornament_list)
					var/list/ornament = ornament_list[ornament_name]
					ornament["score"] = src.bound_of_wilson_score_confidence_interval_for_a_bernoulli_parameter_of_an_ornament(ornament)
				ornament_list = sortList(ornament_list, /proc/compare_ornament_score, associative=TRUE)
			if("worst")
				for(var/ornament_name in ornament_list)
					var/list/ornament = ornament_list[ornament_name]
					ornament["score"] = -src.bound_of_wilson_score_confidence_interval_for_a_bernoulli_parameter_of_an_ornament(ornament, which_bound=1)
				ornament_list = sortList(ornament_list, /proc/compare_ornament_score, associative=TRUE)
			if("fewest_votes")
				for(var/ornament_name in ornament_list)
					var/list/ornament = ornament_list[ornament_name]
					ornament["score"] = -(length(ornament["upvoted"]) + length(ornament["downvoted"]))
				ornament_list = sortList(ornament_list, /proc/compare_ornament_score, associative=TRUE)
			if("weighted_random")
				var/list/ornament_weights = list()
				for(var/ornament_name in ornament_list)
					var/list/ornament = ornament_list[ornament_name]
					ornament_weights[ornament_name] = src.weighted_sort_flat_bonus + \
						src.bound_of_wilson_score_confidence_interval_for_a_bernoulli_parameter_of_an_ornament(ornament)
				var/list/original_ornament_list = ornament_list
				ornament_list = list()
				while(length(ornament_weights) > 0 && length(ornament_list) < length(src.ornament_positions) - weighted_sort_reserved_slots_for_new)
					var/ornament_name = weighted_pick(ornament_weights)
					ornament_list[ornament_name] = get_spacemas_ornaments()[ornament_name]
					ornament_weights -= ornament_name
				var/list/sorted_by_least_votes = list()
				for(var/ornament_name in ornament_weights)
					var/list/ornament = original_ornament_list[ornament_name]
					var/votes = length(ornament["upvoted"]) + length(ornament["downvoted"]) * 2.5
					sorted_by_least_votes[ornament_name] = ornament
					ornament["score"] = -votes
				sorted_by_least_votes = sortList(sorted_by_least_votes, /proc/compare_ornament_score, associative=TRUE)
				ornament_list += sorted_by_least_votes
		src.placed_ornaments = list()
		src.placed_ornaments.len = length(ornament_positions)
		for(var/i = 1 to length(ornament_positions))
			if (length(ornament_list) < i)
				break
			var/ornament_name = ornament_list[i]
			var/ornament_art = ornament_list[ornament_name]["art"]
			var/ornament_artist = ornament_list[ornament_name]["artist"]
			var/obj/item/canvas/tree_ornament/ornament = new(null, ornament_art)
			ornament.name = ornament_name
			ornament.desc = "A Spacemas ornament by [ornament_artist]."
			ornament.upvoted = ornament_list[ornament_name]["upvoted"]
			ornament.downvoted = ornament_list[ornament_name]["downvoted"]
			ornament.main_artist = ornament_artist
			src.place_ornament(ornament, i)

	proc/remove_all_ornaments()
		for(var/obj/item/canvas/tree_ornament/ornament in placed_ornaments)
			qdel(ornament)

	disposing()
		#ifdef XMAS
		STOP_TRACKING
		#endif

		remove_all_ornaments()

		qdel(src.fire_image)
		src.fire_image = null
		..()

	attack_hand(mob/user)
		if(src.on_fire)
			extinguish()
		else if(uses_custom_ornaments)
			if(user?.client?.ckey in src.got_ornament_kit)
				boutput(user, SPAN_ALERT("You've already gotten an ornament kit this round!"))
				return
			var/obj/item/storage/box/ornament_kit/kit = new(user)
			user.put_in_hand_or_drop(kit)
			LAZYLISTADD(src.got_ornament_kit, user.client?.ckey)
			boutput(user, SPAN_NOTICE("You take an ornament kit from under the tree."))
		..()

	proc/extinguish()
		if (!src.on_fire)
			return
		src.visible_message(SPAN_COMBAT("[usr] attempts to extinguish the fire!"))
		if (prob(2))
			src.change_fire_state(0)
		else
			boutput(usr, "You couldn't get the fire out. Keep trying!")

	proc/change_fire_state(var/burning = 0)
		if (src.on_fire && burning == 0)
			src.on_fire = 0
			src.visible_message(SPAN_NOTICE("[src] is extinguished. Phew!"))
		else if (!src.on_fire && burning == 1)
			src.visible_message(SPAN_COMBAT("<b>[src] catches on fire! Oh shit!</b>"))
			src.on_fire = 1
			for(var/obj/item/canvas/tree_ornament/ornament in src.placed_ornaments)
				if(prob(30))
					ornament.combust()
				else if(prob(50))
					var/darkening = rand(0, 255)
					ornament.color = rgb(darkening, darkening, darkening)
			SPAWN(1 MINUTE)
				if (src.on_fire)
					src.visible_message(SPAN_COMBAT("[src] burns down and collapses into a sad pile of ash. <b><i>Spacemas is ruined!!!</i></b>"))
					for (var/turf/simulated/floor/T in range(1,src))
						make_cleanable( /obj/decal/cleanable/ash,T)
					modify_christmas_cheer(-33)
					qdel(src)
					return
		src.UpdateIcon()

	update_icon()
		if (src.on_fire)
			if (!src.fire_image)
				src.fire_image = image('icons/effects/160x160.dmi', "xmastree_2014_burning")
			src.fire_image.icon_state = "xmastree_2014_burning" // it didn't need to change from 2014 to 2015 so I just left it as this one
			src.UpdateOverlays(src.fire_image, "fire")
		else
			src.UpdateOverlays(null, "fire")

	proc/place_ornament(obj/item/canvas/tree_ornament/ornament, slot_number)
		if(src.placed_ornaments[slot_number])
			src.vis_contents -= src.placed_ornaments[slot_number]
			qdel(src.placed_ornaments[slot_number])
		ornament.underlays = null // remove the frame
		ornament.pixel_x = ornament_positions[slot_number][1]
		ornament.pixel_y = ornament_positions[slot_number][2]
		src.vis_contents += ornament
		ornament.layer = src.layer + 0.1
		ornament.plane = src.plane
		ornament.on_tree = src
		ornament.anchored = ANCHORED_ALWAYS
		ornament.set_loc(null)
		src.placed_ornaments[slot_number] = ornament

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/canvas/tree_ornament) && uses_custom_ornaments)
			if(src.on_fire)
				boutput(user, SPAN_ALERT("The tree is on fire! You can't put an ornament on it!"))
				return
			if(global.christmas_cheer < 20)
				boutput(user, SPAN_ALERT("The atmosphere just isn't festive enough. Try increasing the Spacemas cheer!"))
				return
			if(user.ckey in src.ckeys_placed_this_round)
				boutput(user, SPAN_ALERT("You've already hung an ornament this round!"))
				return
			var/obj/item/canvas/tree_ornament/ornament = W
			if(ornament.on_tree)
				boutput(user, SPAN_ALERT("That ornament is already on a tree!"))
				return
			if(ornament.is_ready(user))
				if(tgui_alert(user, "Do you want to hang the ornament on the tree? (You can only do so once per round.)", "Hang ornament?", list("Yes", "No")) != "Yes")
					return
				var/maybe_name = tgui_input_text(user, "What would you like to name your ornament?", "Name your ornament", ornament.name)
				if(!maybe_name)
					return
				if(user.ckey in src.ckeys_placed_this_round)
					boutput(user, SPAN_ALERT("You've already hung an ornament this round!"))
					return
				if(ornament.on_tree)
					boutput(user, SPAN_ALERT("That ornament is already on a tree!"))
					return
				user.drop_item(ornament)
				ornament.name = maybe_name
				ornament.main_artist = user.ckey
				ornament.desc = "A Spacemas ornament by [user.ckey]."
				ornament.finish(user)
				var/empty_index = 0
				for(var/i = 1 to length(src.placed_ornaments))
					if(isnull(src.placed_ornaments[i]))
						empty_index = i
						break
				src.place_ornament(ornament, empty_index || rand(1, length(src.placed_ornaments)))
				logTheThing(LOG_STATION, user, "placed an ornament with name '[ornament.name]' on the Spacemas tree.")
				boutput(user, SPAN_NOTICE("You hang \the [ornament.name] on the tree."))
				LAZYLISTADD(src.ckeys_placed_this_round, user.ckey)
		else
			. = ..()

/obj/item/reagent_containers/food/snacks/snowball
	name = "snowball"
	desc = "A snowball. Made of snow."
	icon = 'icons/misc/xmas.dmi'
	icon_state = "snowball"
	item_state = "snowball_h"
	bites_left = 2
	w_class = W_CLASS_TINY
	throwforce = 1
	doants = 0
	food_color = "#FFFFFF"
	var/melts = TRUE

	unmelting
		melts = FALSE

	New()
		..()
		if(melts)
			SPAWN(rand(100,500))
				if (src.loc && (istype(src.loc, /turf/simulated/floor/specialroom/freezer) || src.loc.loc.name == "Space" || src.loc.loc.name == "Ocean"))
					src.visible_message("\The [src] vanishes into thin air, as its subatomic particles decay!")
				else
					src.visible_message("\The [src] melts!")
					make_cleanable( /obj/decal/cleanable/water,get_turf(src))
				qdel(src)

	heal(var/mob/living/M)
		if (!M || !isliving(M))
			return
		var/mob/living/L = M
		L.bodytemperature -= rand(1, 10)
		L.show_text("That was chilly!", "blue")
		..()

	proc/hit(var/mob/living/M as mob, var/message = 1)
		if (!M || !isliving(M))
			return
		M.changeStatus("stunned", 1 SECOND)
		M.take_eye_damage(rand(0, 2))
		M.change_eye_blurry(25)
		M.make_dizzy(rand(0, 5))
		M.stuttering += rand(0, 1)
		M.bodytemperature -= rand(1, 10)
		if (message)
			M.visible_message(SPAN_ALERT("<b>[M]</b> is hit by [src]!"),\
			SPAN_ALERT("You get hit by [src]![pick("", " Brr!", " Ack!", " Cold!")]"))
		src.bites_left -= rand(1, 2)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (user.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message(SPAN_ALERT("[user] plasters the snowball over [his_or_her(user)] face."),\
			SPAN_ALERT("You plaster the snowball over your face."))
			src.hit(user, 0)
			JOB_XP(user, "Clown", 4)
			return

		src.add_fingerprint(user)

		if (src.bites_left <= 0)
			src.visible_message("[src] collapses into a poof of snow!")
			qdel(src)
			return

		else if (user.a_intent == "harm")
			if (target == user)
				target.visible_message(SPAN_ALERT("<b>[user] smushes [src] into [his_or_her(user)] own face!</b>"),\
				SPAN_ALERT("<b>You smush [src] into your own face!</b>"))
			else if ((user != target && iscarbon(target)))
				target.tri_message(user, SPAN_ALERT("<b>[user] smushes [src] into [target]'s face!</b>"),\
					SPAN_ALERT("<b>You smush [src] into [target]'s face!</b>"),\
					SPAN_ALERT("<b>[user] smushes [src] in your face!</b>"))
			src.hit(target, 0)

		else return ..()

	throw_impact(atom/A, datum/thrown_thing/thr)
		if (ismob(A))
			src.hit(A)
		if (src.bites_left <= 0)
			src.visible_message("[src] collapses into a poof of snow!")
			qdel(src)
			return

/obj/decal/garland
	plane = PLANE_DEFAULT
	name = "garland"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "garland"
	layer = 5
	anchored = ANCHORED
	mouse_opacity = FALSE

/obj/decal/tinsel
	plane = PLANE_DEFAULT
	name = "tinsel"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "tinsel-silver"
	layer = 5
	anchored = ANCHORED

/obj/decal/wreath
	plane = PLANE_DEFAULT
	name = "wreath"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "wreath"
	layer = 5
	anchored = ANCHORED
/obj/decal/mistletoe
	plane = PLANE_DEFAULT
	name = "mistletoe"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "mistletoe"
	layer = 9
	anchored = ANCHORED

/obj/decal/xmas_lights
	plane = PLANE_DEFAULT
	name = "spacemas lights"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "lights1"
	layer = 5
	anchored = ANCHORED
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_color(0.2, 0.6, 0.9)
		light.set_brightness(0.3)
		light.attach(src)
		light.enable()

	disposing()
		. = ..()
		qdel(src.light)
		src.light = null

	attack_hand(mob/user)
		change_light_pattern()
		..()

	proc/light_pattern(var/pattern as num)
		if (!pattern)
			src.icon_state = "lights0"
			light.disable()
			return
		if (isnum(pattern) && pattern > 0)
			src.icon_state = "lights[pattern]"
			light.enable()
			return

	proc/change_light_pattern()
		var/pattern = input(usr, "Type number from 0 to 4", "Enter Number", 1) as null|num
		if (!isnum_safe(pattern))
			return
		pattern = clamp(pattern, 0, 4)
		src.light_pattern(pattern)


// Grinch Stuff

/obj/decal/cleanable/grinch_graffiti
	name = "un-jolly graffiti"
	desc = "Wow, rude."
	icon = 'icons/obj/decals/graffiti.dmi'
	random_icon_states = list("grinch1","grinch2","grinch3","grinch4","grinch5","grinch6")

	disposing()
		modify_christmas_cheer(1)
		..()

// Santa Stuff

/obj/item/card/id/captains_spare/santa
	name = "Spacemas Card"
	registered = "Santa Claus"
	assignment = "Spacemas Spirit"

/mob/living/carbon/human/santa
	New()
		..()
		real_name = "Santa Claus"
		desc = "Father Christmas! Santa Claus! Old Nick! ..wait, not that last one. I hope."
		gender = "male"

		src.equip_new_if_possible(/obj/item/clothing/under/shorts/red, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/suit/space/santa, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(/obj/item/clothing/shoes/black, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/glasses/regular, SLOT_GLASSES)
		src.equip_new_if_possible(/obj/item/clothing/head/helmet/space/santahat, SLOT_HEAD)
		src.equip_new_if_possible(/obj/item/storage/backpack/red, SLOT_BACK)
		src.equip_new_if_possible(/obj/item/device/radio/headset, SLOT_EARS)

		var/datum/abilityHolder/HS = src.add_ability_holder(/datum/abilityHolder/santa)
		HS.addAbility(/datum/targetable/santa/heal)
		HS.addAbility(/datum/targetable/santa/gifts)
		HS.addAbility(/datum/targetable/santa/food)
		HS.addAbility(/datum/targetable/santa/warmth)
		HS.addAbility(/datum/targetable/santa/teleport)
		HS.addAbility(/datum/targetable/santa/banish)

	initializeBioholder()
		bioHolder.mobAppearance.customizations["hair_bottom"].style =  new /datum/customization_style/hair/short/balding
		bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/beard/fullbeard
		bioHolder.mobAppearance.customizations["hair_top"].style =  new /datum/customization_style/eyebrows/eyebrows
		bioHolder.mobAppearance.customizations["hair_bottom"].color = "#FFFFFF"
		bioHolder.mobAppearance.customizations["hair_middle"].color = "#FFFFFF"
		bioHolder.mobAppearance.customizations["hair_top"].color = "#FFFFFF"
		. = ..()


	death()
		modify_christmas_cheer(-60)
		..()

	disposing()
		modify_christmas_cheer(-30)
		..()

// Krampus Stuff

/datum/mutantrace/krampus
	name = "krampus"
	icon_state = "hunter"
	human_compatible = 0
	uses_human_clothes = 0
	voice_message = "bellows"
	jerk = 1

	sight_modifier()
		mob.sight |= SEE_MOBS
		mob.see_in_dark = SEE_DARK_FULL
		mob.see_invisible = INVIS_INFRA

/mob/living/carbon/human/krampus
	New()
		..()
		src.mind = new
		real_name = "Krampus"
		desc = "Oh shit! Have you been naughty?!"

		if(!src.reagents)
			src.create_reagents(1000)

		src.set_mutantrace(/datum/mutantrace/krampus)
		src.changeStatus("stimulants", 4 MINUTES)
		src.gender = "male"
		bioHolder.AddEffect("loud_voice")
		bioHolder.AddEffect("cold_resist")

	initializeBioholder()
		bioHolder.mobAppearance.customizations["hair_bottom"].style =  new /datum/customization_style/none
		bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/none
		bioHolder.mobAppearance.customizations["hair_top"].style =  new /datum/customization_style/none
		. = ..()


	bump(atom/movable/AM)
		if(src.stance == "krampage")
			if (src.now_pushing)
				return
			now_pushing = 1
			var/attack_strength = 2
			var/attack_text = "furiously pounds"
			var/attack_volume = 60
			if (src.health <= 80)
				attack_strength = 3
				attack_text = "pounds"
				attack_volume = 30
			else if (src.health < 50)
				attack_strength = 4
				attack_text = "weakly pounds"
				attack_volume = 5
			if(ismob(AM))
				var/mob/M = AM
				for (var/mob/C in viewers(src))
					shake_camera(C, 8, 16)
					C.show_message(SPAN_ALERT("<B>[src] tramples right over [M]!</B>"), 1)
				M.changeStatus("stunned", 8 SECONDS)
				M.changeStatus("knockdown", 5 SECONDS)
				random_brute_damage(M, 10,1)
				M.take_brain_damage(rand(5,10))
				playsound(M.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', attack_volume, 1, -1)
				playsound(M.loc, 'sound/impact_sounds/Flesh_Crush_1.ogg', attack_volume, 1, -1)
				if (istype(M.loc,/turf/))
					src.set_loc(M.loc)
			else if(isobj(AM))
				var/obj/O = AM
				if(O.density)
					playsound(O.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', attack_volume, 1, 0, 0.4)
					for (var/mob/C in viewers(src))
						shake_camera(C, 8, 16)
						C.show_message(SPAN_ALERT("<B>[src] [attack_text] on [O]!</B>"), 1)
					if(istype(O, /obj/window) || istype(O, /obj/mesh/grille) || istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
						qdel(O)
					else
						O.ex_act(attack_strength)
			else if(isturf(AM))
				var/turf/T = AM
				if(T.density && istype(T,/turf/simulated/wall/))
					for (var/mob/C in viewers(src))
						shake_camera(C, 8, 16)
						C.show_message(SPAN_ALERT("<B>[src] [attack_text] on [T]!</B>"), 1)
					playsound(T.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', attack_volume, 1, 0, 0.4)
					T.ex_act(attack_strength)

			now_pushing = 0
		else
			..()
			return

	verb
		krampus_rampage()
			set name = "Krampage"
			set desc = "Go on a rampage, crushing everything in your path."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, SPAN_ALERT("You can't do that while you're incapacitated."))
				return

			src.stance = "krampage"
			playsound(src.loc, 'sound/voice/animal/bull.ogg', 80, 1, 0, 0.4)
			src.visible_message(SPAN_ALERT("<B>[src] goes completely apeshit!</B>"))
			src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_rampage
			SPAWN(30 SECONDS)
				src.stance = "normal"
				boutput(src, SPAN_ALERT("Your rage burns out for a while."))
			SPAWN(1800)
				boutput(src, SPAN_NOTICE("You feel ready to rampage again."))
				src.verbs += /mob/living/carbon/human/krampus/verb/krampus_rampage

		krampus_leap(var/mob/living/M as mob in oview(7))
			set name = "Krampus Leap"
			set desc = "Leap onto someone near you, crushing them underfoot."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, SPAN_ALERT("You can't do that while you're incapacitated."))
				return

			var/turf/target
			if (isturf(M.loc))
				target = M.loc
			else
				return
			src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_leap
			src.transforming = 1
			playsound(src.loc, 'sound/misc/rustle5.ogg', 100, 1, 0, 0.3)
			src.visible_message(SPAN_ALERT("<B>[src] leaps high into the air, heading right for [M]!</B>"))
			animate_fading_leap_up(src)
			sleep(2.5 SECONDS)
			src.set_loc(target)
			playsound(src.loc, 'sound/voice/animal/bull.ogg', 50, 1, 0, 0.8)
			animate_fading_leap_down(src)
			SPAWN(0)
				playsound(M.loc, "explosion", 50, 1, -1)
				for (var/mob/C in viewers(src))
					shake_camera(C, 10, 64)
					C.show_message(SPAN_ALERT("<B>[src] slams down onto the ground!</B>"), 1)
				for (var/turf/T in range(src,3))
					animate_shake(T,5,rand(3,8),rand(3,8))
				for (var/mob/living/X in range(src,1))
					if (X == src)
						continue
					X.ex_act(3)
					playsound(X.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1, -1)
				src.transforming = 0

			SPAWN(1 MINUTE)
				boutput(src, SPAN_NOTICE("You may now leap again."))
				src.verbs += /mob/living/carbon/human/krampus/verb/krampus_leap

		krampus_stomp()
			set name = "Krampus Stomp"
			set desc = "Stomp everyone around you with your mighty feet."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, SPAN_ALERT("You can't do that while you're incapacitated."))
				return

			src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_stomp
			if(!src.stat && !src.transforming)
				for (var/mob/C in viewers(src))
					shake_camera(C, 10, 64)
					C.show_message(SPAN_ALERT("<B>[src] stomps the ground with [his_or_her(src)] huge feet!</B>"), 1)
				playsound(src.loc, 'sound/effects/Explosion2.ogg', 80, 1, 1, 0.6)
				for (var/mob/living/M in view(src,2))
					if (M == src)
						continue
					playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 40, 1, -1)
					M.ex_act(3)
				for (var/turf/T in range(src,3))
					animate_shake(T,5,rand(3,8),rand(3,8))

				SPAWN(1 MINUTE)
					boutput(src, SPAN_NOTICE("You may now stomp again."))
					src.verbs += /mob/living/carbon/human/krampus/verb/krampus_stomp

		krampus_teleport()
			set name = "Krampus Poof"
			set desc = "Warp to somewhere else via the power of Spacemas."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, SPAN_ALERT("You can't do that while you're incapacitated."))
				return

			src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_teleport
			var/A
			A = input("Area to jump to", "TELEPORTATION", A) in get_teleareas()
			var/area/thearea = get_telearea(A)

			src.visible_message(SPAN_ALERT("<B>[src] poofs away in a puff of cold, snowy air!</B>"))
			playsound(usr.loc, 'sound/effects/bamf.ogg', 25, 1, -1)
			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(1, 0, usr.loc)
			smoke.attach(usr)
			smoke.start()
			var/list/L = list()
			for(var/turf/T in get_area_turfs(thearea.type))
				if(!T.density)
					var/clear = 1
					for(var/obj/O in T)
						if(O.density)
							clear = 0
							break
					if(clear)
						L+=T
			src.set_loc(pick(L))

			usr.set_loc(pick(L))
			smoke.start()
			SPAWN(1800)
				boutput(src, SPAN_NOTICE("You may now teleport again."))
				src.verbs += /mob/living/carbon/human/krampus/verb/krampus_teleport

		krampus_snatch(var/mob/living/M as mob in oview(1))
			set name = "Krampus Snatch"
			set desc = "Grab someone nearby you instantly."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, SPAN_ALERT("You can't do that while you're incapacitated."))
				return

			if(istype(M))
				for(var/obj/item/grab/G in src)
					if(G.affecting == M)
						return
				src.visible_message(SPAN_ALERT("<B>[src] snatches up [M] in [his_or_her(src)] huge claws!</B>"))
				var/obj/item/grab/G = new /obj/item/grab(src, src, M)
				usr.put_in_hand_or_drop(G)
				M.changeStatus("stunned", 1 SECOND)
				G.state = GRAB_AGGRESSIVE
				G.UpdateIcon()
				src.set_dir(get_dir(src, M))
				playsound(src.loc, 'sound/voice/animal/werewolf_attack3.ogg', 65, 1, 0, 0.5)
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 65, 1)

		krampus_crush()
			set name = "(G) Krampus Crush"
			set desc = "Gradually crush someone you have held in your claws."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, SPAN_ALERT("You can't do that while you're incapacitated."))
				return

			for(var/obj/item/grab/G in src)
				if(ishuman(G.affecting))
					src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_crush
					var/mob/living/carbon/human/H = G.affecting
					src.visible_message(SPAN_ALERT("<B>[src] begins squeezing [H] in [his_or_her(src)] hand!</B>"))
					H.set_loc(src.loc)
					while (!isdead(H))
						if (src.stat || src.transforming || BOUNDS_DIST(src, H) > 0)
							boutput(src, SPAN_ALERT("Your victim escaped! Curses!"))
							qdel(G)
							src.verbs += /mob/living/carbon/human/krampus/verb/krampus_crush
							return
						random_brute_damage(H, 10,1)
						H.changeStatus("stunned", 8 SECONDS)
						H.changeStatus("knockdown", 5 SECONDS)
						if (H.health < 0)
							src.visible_message(SPAN_ALERT("<B>[H] bursts like a ripe melon! Holy shit!</B>"))
							H.gib()
							qdel(G)
							src.verbs += /mob/living/carbon/human/krampus/verb/krampus_crush
							return
						playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_1.ogg', 75, 0.7)
						H.UpdateDamageIcon()
						sleep(1.5 SECONDS)
				else
					playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 75, 1)
					src.visible_message(SPAN_ALERT("<B>[src] crushes [G.affecting] like a bug!</B>"))
					G.affecting.gib()
					qdel(G)
					src.verbs += /mob/living/carbon/human/krampus/verb/krampus_crush
				break

		krampus_devour()
			set name = "(G) Krampus Devour"
			set desc = "Eat someone you have held in your claws, healing yourself a little."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, SPAN_ALERT("You can't do that while you're incapacitated."))
				return

			for(var/obj/item/grab/G in src)
				if(ishuman(G.affecting))
					var/mob/living/carbon/human/H = G.affecting
					src.visible_message(SPAN_ALERT("<B>[src] raises [H] up to [his_or_her(src)] mouth! Oh shit!</B>"))
					H.set_loc(src.loc)
					sleep(6 SECONDS)
					if (src.stat || src.transforming || BOUNDS_DIST(src, H) > 0)
						boutput(src, SPAN_ALERT("Your prey escaped! Curses!"))
					else
						src.visible_message(SPAN_ALERT("<B>[src] devours [H] whole!</B>"))
						playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
						H.death(TRUE)
						H.ghostize()
						qdel(H)
						qdel(G)
						src.HealDamage("All", 15, 15)
						sleep(1 SECOND)
						playsound(src.loc, pick('sound/voice/burp_alien.ogg'), 50, 1, 0 ,0.5)

/obj/stocking
	name = "stocking"
	desc = "The most festive kind of sock!"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "stocking_red"
	anchored = ANCHORED
	var/list/giftees = list()
	var/list/gift_paths = null//list()
	var/list/questionable_gift_paths = null//list()
	var/danger_chance = 1
	var/booby_trapped = 0

	safe
		// Has a zero% chance of giving you Fun items
		danger_chance = 0

	very_not_safe
		// has a 100% chance of giving you Fun items
		name = "very fun stocking"
		desc = "This festive little sock is just full of <i>Fun!</i>"
		danger_chance = 100

	New()
		..()
		if (prob(50))
			icon_state = "stocking_green"

	attack_hand(mob/user)
		if (..())
			return
		if (!islist(src.gift_paths) || !length(src.gift_paths))
			src.gift_paths = generic_gift_paths + xmas_gift_paths

		if (!islist(src.questionable_gift_paths) || !length(src.questionable_gift_paths))
			src.questionable_gift_paths = questionable_generic_gift_paths + questionable_xmas_gift_paths

		if (user.key in giftees)
			boutput(user, SPAN_COMBAT("You've already gotten something from here, don't be greedy!"))
			boutput(user, SPAN_COMBAT("<font size=1>Note: If this message is in error, please call 1-555-BAD-GIFT.</font>"))
			return

		giftees += user.key

		if (src.booby_trapped)
			boutput(user, SPAN_ALERT("There is a pissed off snake in the stocking! It bites you! What the hell?!"))
			modify_christmas_cheer(-5)
			if (user.reagents)
				user.reagents.add_reagent("cytotoxin", 5)
		else
			modify_christmas_cheer(2)
			var/dangerous = 0
			var/giftpath
			if (prob(danger_chance))
				dangerous = 1
				giftpath = pick(questionable_gift_paths)
			else
				giftpath = pick(gift_paths)

			var/obj/item/gift = new giftpath
			user.put_in_hand_or_drop(gift)

			if (dangerous)
				user.visible_message(SPAN_COMBAT("<b>[user.name]</b> takes [gift] out of [src]!"), SPAN_COMBAT("You take [gift] out of [src]!<br>This looks dangerous..."))
			else
				user.visible_message(SPAN_NOTICE("<b>[user.name]</b> takes [gift] out of [src]!"), SPAN_NOTICE("You take [gift] out of [src]!"))
		return

/obj/decal/tile_edge/stripe/xmas
	icon_state = "xmas"

/obj/item/reagent_containers/food/drinks/eggnog
	name = "Egg Nog"
	desc = "A festive beverage made with eggs. Please eat the eggs. Eat the eggs up."
	icon_state = "nog"
	heal_amt = 1
	festivity = 1
	rc_flags = RC_FULLNESS
	initial_volume = 50
	initial_reagents = list("eggnog"=40)

/obj/storage/crate/xmas
	name = "\improper Spacemas crate"
	icon_state = "xmascrate"
	icon_opened = "xmascrateopen"
	icon_closed = "xmascrate"

/obj/landmark/santa_mail
	name = "santa_mail"
	add_to_landmarks = TRUE
	desc = "All of Santa's mail gets spawned here."
	icon_state = "x"


proc/get_spacemas_ornaments(only_if_loaded=FALSE)
	RETURN_TYPE(/list)
	var/static/spacemas_ornament_data = null
	if(isnull(spacemas_ornament_data) && !only_if_loaded)
		var/year = BUILD_TIME_MONTH < 12 ? BUILD_TIME_YEAR - 1 : BUILD_TIME_YEAR
		spacemas_ornament_data = world.load_intra_round_value("tree_ornaments_[year]") || list()
	. = spacemas_ornament_data

/obj/item/canvas/tree_ornament
	name = "spacemas tree ornament"
	desc = "A canvas where you can paint a spacemas tree ornament and hang it on the tree."
	canvas_width = 16
	canvas_height = 16
	left = 9
	bottom = 9
	instructions = "Paint on this canvas with crayons/pens to make a spacemas tree ornament. Click on the tree with it afterwards. You can make a single ornament per round."
	var/list/upvoted
	var/list/downvoted
	var/obj/xmastree/on_tree = null
	var/main_artist = null

	New(atom/loc, icon/art)
		..()
		if(art)
			src.art = art
			src.icon = art

	Click(location, control, params)
		. = ..()
		if(on_tree)
			pop_open_a_browser_box(usr)

	get_instructions(mob/user)
		. = ..()
		if(!src.on_tree)
			return
		. = "A cool Spacemas ornament drawn by [src.main_artist].<br>"
		var/highlight_up = ""
		var/highlight_down = ""
		if(user.ckey in src.upvoted)
			highlight_up = "font-weight: 900;"
		if(user.ckey in src.downvoted)
			highlight_down = "font-weight: 900;"
		. += {"<br>
		<a href='byond://?src=\ref[src];upvote=1' style='color:#88ff88;[highlight_up]'>👍 (like)</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href='byond://?src=\ref[src];downvote=1' style='color:#ff8888;[highlight_down]'>👎 (dislike)</a>"}
		if(user?.client?.holder?.level >= LEVEL_SA)
			. += "<br><a href='byond://?src=\ref[src];remove_ornament=1' style='color:red;'>Annihilate ornament</a>"

	Topic(href, href_list)
		if(href_list["remove_ornament"])
			if(src.on_tree && usr?.client?.holder?.level >= LEVEL_SA)
				if(tgui_alert(usr, "Are you sure you want to remove \the [src] not only from the tree but also from the ornament database?", "Remove ornament", list("Yes", "No")) != "Yes")
					return
				get_spacemas_ornaments().Remove(src.name)
				logTheThing(LOG_ADMIN, usr, "Removed ornament '[src.name]' from the tree and the ornament database.")
				qdel(src)
				boutput(usr, SPAN_ALERT("You removed \the [src] from the tree and the ornament database."))
			return
		if(href_list["upvote"])
			if(src.on_tree)
				if(!src.upvoted)
					src.upvoted = list()
				if(!src.downvoted)
					src.downvoted = list()
				if(usr.ckey == src.main_artist)
					boutput(usr, SPAN_ALERT("You can't upvote your own ornament."))
					return
				if(usr.client?.player?.get_rounds_participated() <= 10)
					boutput(usr, SPAN_ALERT("You need to play at least 10 rounds to be able to downvote ornaments."))
					return
				if(usr.ckey in src.downvoted)
					src.downvoted.Remove(usr.ckey)
					src.upvoted += usr.ckey
					boutput(usr, SPAN_ALERT("You changed your vote to upvote \the [src]."))
				else if(usr.ckey in src.upvoted)
					src.upvoted.Remove(usr.ckey)
					boutput(usr, SPAN_ALERT("You removed your upvote from \the [src]."))
				else
					src.upvoted += usr.ckey
					boutput(usr, SPAN_ALERT("You upvoted \the [src]."))
				get_spacemas_ornaments()[src.name]["upvoted"] = src.upvoted
				get_spacemas_ornaments()[src.name]["downvoted"] = src.downvoted
				pop_open_a_browser_box(usr)
			return
		if(href_list["downvote"])
			if(src.on_tree)
				if(!src.upvoted)
					src.upvoted = list()
				if(!src.downvoted)
					src.downvoted = list()
				if(usr.ckey == src.main_artist)
					boutput(usr, SPAN_ALERT("You can't downvote your own ornament."))
					return
				if(usr.client?.player?.get_rounds_participated() <= 10)
					boutput(usr, SPAN_ALERT("You need to play at least 10 rounds to be able to downvote ornaments."))
					return
				if(usr.ckey in src.upvoted)
					src.upvoted.Remove(usr.ckey)
					src.downvoted += usr.ckey
					boutput(usr, SPAN_ALERT("You changed your vote to downvote \the [src]."))
				else if(usr.ckey in src.downvoted)
					src.downvoted.Remove(usr.ckey)
					boutput(usr, SPAN_ALERT("You removed your downvote from \the [src]."))
				else
					src.downvoted += usr.ckey
					boutput(usr, SPAN_ALERT("You downvoted \the [src]."))
				get_spacemas_ornaments()[src.name]["upvoted"] = src.upvoted
				get_spacemas_ornaments()[src.name]["downvoted"] = src.downvoted
				pop_open_a_browser_box(usr)
			return
		. = ..()

	init_canvas()
		base = icon(src.icon, icon_state = "ornament_base")
		art = icon(src.icon, icon_state = "ornament_blank")

		underlays += base
		icon = art
		pixel_artists = list()

	is_writing_implament_valid(obj/item/W, mob/user)
		if(istype(W, /obj/item/pen/ornament_paintbrush) || istype(W, /obj/item/pen/ornament_eraser))
			return TRUE
		. = ..()

	proc/is_ready(mob/send_errors_to_this_guy)
		if(length(pixel_artists) < 30)
			if(send_errors_to_this_guy)
				boutput(send_errors_to_this_guy, SPAN_ALERT("You need at least 30 pixels to finish this ornament!"))
			return FALSE
		return TRUE

	proc/finish(mob/artist)
		src.icon = src.art
		var/name = src.name
		var/i = 1
		while(name in get_spacemas_ornaments())
			name = "[src.name] ([i])"
			i++
		get_spacemas_ornaments()[name] = list(
			"art" = src.art,
			"artist" = artist.ckey,
			"upvoted" = list(),
			"downvoted" = list(),
		)

	disposing()
		if(on_tree)
			var/index = on_tree.placed_ornaments.Find(src)
			if(index)
				on_tree.placed_ornaments[index] = null
			on_tree = null
		..()


/obj/item/pen/ornament_paintbrush
	name = "ornament paintbrush"
	desc = "A paintbrush for painting ornaments. It's a bit small for painting on much else. You can use it in your hand to change its color."
	font_color = "#ffffff"
	icon_state = "brush"
	clicknoise = FALSE
	suitable_for_canvas = FALSE

	update_icon()
		. = ..()
		var/image/color_overlay = SafeGetOverlayImage("color", src.icon, "brush-paint")
		color_overlay.color = font_color
		src.UpdateOverlays(color_overlay, "color")

	attack_self(mob/user)
		..()
		if(global.christmas_cheer < 20)
			boutput(user, SPAN_ALERT("The Spacemas cheer is too low, Spacemas spirit doesn't have enough power to change the color of this paintbrush!"))
			return
		var/new_color = input(user, "Choose a color:", "Ornament paintbrush", src.font_color) as color|null
		if(new_color)
			src.font_color = new_color
			boutput(user, SPAN_NOTICE("You twirl the paintbrush and the Spacemas spirit changes it to this color: <a href='byond://?src=\ref[src];setcolor=[copytext(src.font_color, 2)]' style='color: [src.font_color]'>[src.font_color]</a>."))
			src.UpdateIcon()

	Topic(href, href_list)
		. = ..()
		if(href_list["setcolor"] && can_reach(usr, src) && can_act(usr, 1))
			src.font_color = "#" + href_list["setcolor"]
			boutput(usr, SPAN_NOTICE("You twirl the paintbrush and the Spacemas spirit changes it to this color again: <a href='byond://?src=\ref[src];setcolor=[copytext(src.font_color, 2)]' style='color: [src.font_color]'>[src.font_color]</a>."))
			src.UpdateIcon()

	afterattack(atom/target, mob/user)
		return

	write_on_turf(turf/T, mob/user, params)
		return


/obj/item/pen/ornament_eraser
	name = "ornament eraser"
	desc = "An eraser for erasing stuff from ornaments. It's a bit small for erasing much else."
	icon_state = "eraser"
	clicknoise = FALSE
	suitable_for_canvas = FALSE
	font_color = "#00000000"

	write_on_turf(turf/T, mob/user, params)
		return


/obj/item/storage/box/ornament_kit
	name = "ornament kit"
	desc = "A kit for making ornaments. Comes with a paintbrush, an eraser, and a canvas."
	icon_state = "box_snowflake"
	slots = 3
	max_wclass = 1
	can_hold = list(/obj/item/canvas/tree_ornament, /obj/item/pen/ornament_paintbrush, /obj/item/pen/ornament_eraser)
	spawn_contents = list(/obj/item/canvas/tree_ornament, /obj/item/pen/ornament_paintbrush, /obj/item/pen/ornament_eraser)

/obj/item/spacemas_card
	name = "spacemas card"
	desc = null
	icon = 'icons/obj/items/items.dmi'
	icon_state = "mail-1"
	item_state = "gift"
	w_class = W_CLASS_TINY

	New()
		..()
		desc = "Dear [pick("comrade", "colleague", "friend", "crewmate")], wishing you [pick("many large and valuable presents!", "a satisfactory festive annual event!", "a wonderful holiday!", "a merry spacemas!", "happy holidays!")] From [pick("your friends back home", "your local Syndicate cell", "a mysterious benefactor", "all of us on-station", "your best buddy", "Nanotrasen Central Command")]."
		var/n = rand(1,6)
		icon_state = "card-[n]"
