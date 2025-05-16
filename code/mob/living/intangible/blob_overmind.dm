TYPEINFO(/mob/living/intangible/blob_overmind)
	start_listen_modifiers = list(LISTEN_MODIFIER_MOB_MODIFIERS)
	start_listen_inputs = list(LISTEN_INPUT_EARS, LISTEN_INPUT_BLOBCHAT)
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_BLOBCHAT)

/mob/living/intangible/blob_overmind
	name = "blob overmind"
	real_name = "blob overmind"
	desc = "The disembodied consciousness of a big pile of goop."
	icon = 'icons/mob/mob.dmi'
	icon_state = "blob"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = ANCHORED
	use_stamina = 0
	speech_verb_say = list("wobbles", "wibbles", "jiggles", "wiggles", "undulates", "fidgets", "joggles", "twitches", "waggles", "trembles", "quivers")
	default_speech_output_channel = SAY_CHANNEL_BLOB

	var/datum/tutorial_base/regional/blob/tutorial
	var/attack_power = 1
	var/bio_points = 0
	var/bio_points_max = 1
	var/bio_points_max_bonus = 7 //starting bio point cap should be 10-12 now, i think. a bit more wiggle room for starter blobs.
	var/base_gen_rate = 3
	var/gen_rate_bonus = 0
	var/gen_rate_used = 0
	var/evo_points = 0
	var/next_evo_point = 25
	var/spread_upgrade = 0
	var/spread_mitigation = 0
	var/list/upgrades = list()
	var/list/available_upgrades = list()
	var/viewing_upgrades = 1
	var/help_mode = 0
	var/list/abilities = list()
	var/list/blobs = list()
	var/started = 0
	var/starter_buff = 1
	var/extra_nuclei = 0
	var/next_extra_nucleus = 100
	var/multi_spread = 0
	var/upgrading = 0
	var/upgrade_id = 1
	var/nucleus_reflectivity = 0
	var/image/nucleus_overlay
	var/total_placed = 0
	var/next_pity_point = 100
#ifdef BONUS_POINTS
	bio_points = 999
	bio_points_max = 999
	bio_points_max_bonus = 999
	base_gen_rate = 999
	gen_rate_bonus = 999
	gen_rate_used = 999
	evo_points = 999
#endif


	var/datum/blob_ability/shift_power = null
	var/datum/blob_ability/ctrl_power = null
	var/datum/blob_ability/alt_power = null
	var/list/lipids = list()
	var/list/nuclei = list()

	var/datum/material/my_material = null
	var/datum/material/initial_material = null

	var/organ_color = "#ffffff"
	var/obj/item/clothing/head/hat = null

	var/debuff_timestamp = 0
	var/debuff_duration = 1200 //deciseconds. 1200 = 2 minutes

	//give blobs who get rekt soon after starting another chance
	var/spawn_time = 0
	var/respawned = FALSE

	var/random_event_spawn = FALSE

	var/last_blob_life_tick = 0 //needed for mult to properly work for blob abilities

	var/admin_override = FALSE //for sudo blobs

	proc/start_tutorial()
		if (tutorial)
			return
		tutorial = new(src)
		if (tutorial.initial_turf)
			tutorial.Start()
		else
			boutput(src, SPAN_ALERT("Could not start tutorial! Please try again later or call Wire."))
			tutorial = null
			return

	New()
		..()
		src.add_ability(/datum/blob_ability/plant_nucleus)
		src.add_ability(/datum/blob_ability/set_color)
		src.add_ability(/datum/blob_ability/tutorial)
		src.add_ability(/datum/blob_ability/help)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_SPOOKY)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.see_invisible = INVIS_SPOOKY
		src.see_in_dark = SEE_DARK_FULL
		src.my_material = getMaterial("blob")
		src.my_material = src.my_material.getMutable()
		src.my_material.setColor("#ffffff")
		initial_material = getMaterial("blob")

		//set start grace-period timestamp
		src.spawn_time = TIME

		src.nucleus_overlay = image('icons/mob/blob.dmi', null, "reflective_overlay")
		src.nucleus_overlay.alpha = 0
		src.nucleus_overlay.appearance_flags = RESET_COLOR | PIXEL_SCALE

		SPAWN(0)
			while (src)
				if (src.client)
					update_cooldown_costs()
				sleep(1 SECOND)

	Move(atom/NewLoc)
		if (tutorial)
			if (!tutorial.PerformAction("move", NewLoc))
				return 0
		if (isturf(NewLoc))
			if (istype(NewLoc, /turf/unsimulated/wall))
				return 0
		..()

	set_loc(atom/newloc)
		// Blobs can only move to turfs. Blobs shouldn't be moving off station Z UNLESS they're riding the escape shuttle or the game has ended (so they can spread to centcom)
		// Letting them move off station Z causes Issues when blobs take the mining shuttle, sea elevator, etc
		if (isturf(newloc) && newloc.z != Z_LEVEL_STATION && !tutorial && !istype(get_area(newloc), /area/shuttle/escape/transit) && global.current_state < GAME_STATE_FINISHED)
			return
		..()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (started && (length(nuclei) == 0 || length(blobs) == 0))
			death()
			return

		//time to un-apply the nucleus-destroyed debuff
		if (src.debuff_timestamp && world.timeofday >= src.debuff_timestamp)
			src.debuff_timestamp = 0
			boutput(src, SPAN_ALERT("<b>You can feel your former power returning!</b>"))

		if (length(blobs) > 0)
			/**
			 * at 2175 blobs, blob points max will reach about 350. It will begin decreasing sharply after that
			 * This is a size penalty. Basically if the blob gets too damn big, the crew has some chance of
			 * fighting it back because it will run out of points.
			 */
			src.bio_points_max = BlobPointsBezierApproximation(round(blobs.len / 5)) + bio_points_max_bonus

		var/newBioPoints
		var/mult = (max(tick_spacing, TIME - last_blob_life_tick) / tick_spacing)
		//debuff active
		if (src.debuff_timestamp)
			var/genBonus = gen_rate_bonus
			if (genBonus > 0)
				genBonus = round(genBonus / 2)

			//maybe other debuffs here in the future

			newBioPoints = clamp((src.bio_points + (base_gen_rate + genBonus - gen_rate_used) * mult), 0, src.bio_points_max + (base_gen_rate + gen_rate_bonus - gen_rate_used) * (mult - 1)) //these are rounded in point displays

		else
			newBioPoints = clamp((src.bio_points + (base_gen_rate + gen_rate_bonus - gen_rate_used) * mult), 0, src.bio_points_max + (base_gen_rate + gen_rate_bonus - gen_rate_used) * (mult - 1)) //ditto above

		src.bio_points = newBioPoints

		if (tutorial)
			if (!tutorial.PerformSilentAction("life", null))
				return

		if (starter_buff == 1)
			if (length(blobs) >= 25)
				boutput(src, SPAN_ALERT("<b>You no longer have the starter assistance.</b>"))
				starter_buff = 0

		if (length(blobs) >= next_evo_point)
			next_evo_point += initial(next_evo_point)
			evo_points++
			boutput(src, SPAN_NOTICE("<b>You have expanded enough to earn one evo point! You will be granted another at size [next_evo_point]. Good luck!</b>"))

		if (total_placed >= next_pity_point)
			next_pity_point += initial(next_pity_point)
			evo_points++
			boutput(src, SPAN_NOTICE("<b>You have performed enough spreads to earn one evo point! You will be granted another after placing [next_pity_point] tiles. Good luck!</b>"))

		if (length(blobs) >= next_extra_nucleus)
			next_extra_nucleus += initial(next_extra_nucleus)
			extra_nuclei++
			boutput(src, SPAN_NOTICE("<b>You have expanded enough to earn one extra nucleus! You will be granted another at size [next_extra_nucleus]. Good luck!</b>"))

		src.nucleus_reflectivity = length(src.blobs) < 151 ? 100 : 100 - ((src.blobs.len - 150)/2)
		var/old_alpha = src.nucleus_overlay.alpha
		var/new_alpha = clamp(src.nucleus_reflectivity * 2, 0, 255)
		if(abs(old_alpha - new_alpha) >= 25 || (old_alpha != new_alpha && (new_alpha == 0 || old_alpha == 0)))
			src.nucleus_overlay.alpha = new_alpha
			for(var/obj/blob/nucleus/N in src.nuclei)
				if(new_alpha)
					N.UpdateOverlays(src.nucleus_overlay, "reflectivity")
				else
					N.UpdateOverlays(null, "reflectivity")

		src.last_blob_life_tick = TIME

	death()
		. = ..()

		//if within grace period, respawn
		var/respawn_time = !src.random_event_spawn ? 15 MINUTES : 7 MINUTES
		if (!src.respawned && (TIME - src.spawn_time <= respawn_time))
			src.respawned = TRUE
			src.reset()
			boutput(src, SPAN_NOTICE("<b>In a desperate act of self preservation you avoid your untimely death by concentrating what energy you had left! You feel ready to try again!</b>"))

		//no grace, go die scrub
		else
			src.remove_all_abilities()
			src.remove_all_upgrades()

			boutput(src, SPAN_ALERT("<b>With no nuclei to bind it to your biomass, your consciousness slips away into nothingness...</b>"))
			src.ghostize()
			SPAWN(0)
				qdel(src)

	Stat()
		..()
		stat(null, " ")
		stat("--Blob--", " ")
		stat("Bio Points:", "[round(bio_points)]/[bio_points_max]")
		//debuff active
		if (src.debuff_timestamp && gen_rate_bonus > 0)
			var/genBonus = round(gen_rate_bonus / 2)
			stat("Generation Rate:", "[base_gen_rate + genBonus - gen_rate_used]/[base_gen_rate + gen_rate_bonus] BP [SPAN_ALERT("(WEAKENED)")]")

		else
			stat("Generation Rate:", "[base_gen_rate + gen_rate_bonus - gen_rate_used]/[base_gen_rate + gen_rate_bonus] BP")

		stat("Blob Size:", blobs.len)
		stat("Total spreads:", total_placed)
		stat("Evo Points:", evo_points)
		stat("Next Evo Point at size:", next_evo_point)
		stat("Total spreads needed for additional point:", next_pity_point)
		stat("Living nuclei:", nuclei.len)
		stat("Unplaced extra nuclei:", extra_nuclei)
		stat("Next Extra Nucleus at size:", next_extra_nucleus)

	Login()
		..()
		src.update_buttons()
		client.show_popup_menus = 0
		var/atom/plane = client.get_plane(PLANE_LIGHTING)
		plane.alpha = 200

	Logout()
		..()
		if (src.last_client)
			if (src.last_client.buildmode)
				if (src.last_client.buildmode.is_active)
					return
			src.last_client.show_popup_menus = 1

			var/atom/plane = last_client.get_plane(PLANE_LIGHTING)
			if (plane)
				plane.alpha = 255

	mouse_drop()
		return

	MouseDrop_T()
		return

	meteorhit()
		return

	is_spacefaring()
		return 1

	movement_delay()
		if (src.client && src.client.check_key(KEY_RUN))
			return 0.4 + movement_delay_modifier
		else
			return 0.75 + movement_delay_modifier

	click(atom/target, params)
		if (istype(target,/atom/movable/screen/blob/))
			if (params["middle"])
				var/atom/movable/screen/blob/B = target
				if (B.ability)
					B.ability.onUse()
					return
			..()
			return
		var/turf/T = get_turf(target)
		if (params["alt"] && istype(src.alt_power))
			src.alt_power.onUse(T)
			src.update_buttons()
			return
		else if (params["shift"] && istype(src.shift_power))
			src.shift_power.onUse(T)
			src.update_buttons()
			return
		else if (params["ctrl"] && istype(src.ctrl_power))
			src.ctrl_power.onUse(T)
			src.update_buttons()
			return
		else
			if(params["left"])
				var/datum/blob_ability/spread_abil = src.get_ability(/datum/blob_ability/spread)
				spread_abil?.onUse(T)
			else if(params["right"])
				if (T && (!isghostrestrictedz(T.z) || (isghostrestrictedz(T.z) && restricted_z_allowed(src, T)) || src.tutorial || (src.client && src.client.holder)))
					if (src.tutorial)
						if (!tutorial.PerformAction("clickmove", T))
							return
					src.Move(T)

	can_use_hands()	return 0

	//reset the blob to starting state
	proc/reset()
		src.attack_power = initial(src.attack_power)
		src.bio_points = 0
		src.bio_points_max = initial(src.bio_points_max)
		src.bio_points_max_bonus = initial(src.bio_points_max_bonus)
		src.base_gen_rate = initial(src.base_gen_rate)
		src.gen_rate_bonus = 0
		src.gen_rate_used = 0
		src.evo_points = 0
		src.next_evo_point = initial(src.next_evo_point)
		src.next_pity_point = initial(src.next_pity_point)
		src.total_placed = 0
		src.spread_upgrade = 0
		src.spread_mitigation = 0
		src.viewing_upgrades = 1
		src.help_mode = 0
		src.blobs = new()
		src.started = 0
		src.starter_buff = 1
		src.extra_nuclei = 0
		src.next_extra_nucleus = initial(src.next_extra_nucleus)
		src.multi_spread = 0
		src.upgrading = 0
		src.upgrade_id = 1
		src.lipids = new()
		src.nuclei = new()
		src.my_material = getMaterial("blob")
		src.my_material = src.my_material.getMutable()
		src.my_material.setColor("#ffffff")
		src.initial_material = getMaterial("blob")
		src.organ_color = initial(src.organ_color)
		src.debuff_timestamp = 0

		src.remove_all_abilities()
		src.remove_all_upgrades()

		src.add_ability(/datum/blob_ability/plant_nucleus)
		src.add_ability(/datum/blob_ability/set_color)
		src.add_ability(/datum/blob_ability/tutorial)
		src.add_ability(/datum/blob_ability/help)

	proc/get_gen_rate()
		return base_gen_rate + gen_rate_bonus - gen_rate_used

	proc/onBlobHit(var/obj/blob/B, var/mob/M)
		return

	proc/onBlobDeath(var/obj/blob/B, var/mob/M)
		return

	proc/add_ability(var/ability_type)
		if (!ispath(ability_type))
			return
		var/datum/blob_ability/A = new ability_type
		A.owner = src
		src.abilities += A
		src.update_buttons()

	proc/add_upgrade(var/upgrade_type, var/skip_disabled = 0)
		if (!ispath(upgrade_type))
			return
		var/datum/blob_upgrade/A = new upgrade_type
		if (skip_disabled && A.initially_disabled)
			return
		A.owner = src
		src.available_upgrades += A
		src.update_buttons()

	proc/remove_all_upgrades()
		for (var/datum/blob_upgrade/U in src.upgrades)
			src.upgrades -= U
			qdel(U)

		for (var/datum/blob_upgrade/U in src.available_upgrades)
			src.available_upgrades -= U
			qdel(U)
		src.update_buttons()

	proc/remove_ability(var/ability_type)
		if (!ispath(ability_type))
			return
		for (var/datum/blob_ability/A in src.abilities)
			if (A.type == ability_type)
				src.abilities -= A
				if (A == src.alt_power)
					src.alt_power = null
				if (A == src.ctrl_power)
					src.ctrl_power = null
				if (A == src.shift_power)
					src.shift_power = null
				qdel(A)
				return
		src.update_buttons()

	proc/remove_all_abilities()
		for (var/datum/blob_ability/A in src.abilities)
			src.abilities -= A
			if (A == src.alt_power)
				src.alt_power = null
			if (A == src.ctrl_power)
				src.ctrl_power = null
			if (A == src.shift_power)
				src.shift_power = null
			qdel(A)
		src.update_buttons()

	proc/get_ability(var/ability_type)
		if (!ispath(ability_type))
			return null
		for (var/datum/blob_ability/A in src.abilities)
			if (A.type == ability_type)
				return A
		return null

	proc/get_upgrade(var/upgrade_type)
		if (!ispath(upgrade_type))
			return null
		for (var/datum/blob_upgrade/A in src.available_upgrades)
			if (A.type == upgrade_type)
				return A
		return null

	proc/update_buttons()
		if(!src.client)
			return

		//src.client.screen -= src.item_abilities
		for(var/atom/movable/screen/blob/B in src.client.screen)
			src.client.screen -= B

		var/pos_x = 1
		var/pos_y = 0

		for(var/datum/blob_ability/B in src.abilities)
			if (!istype(B.button))
				continue
			if (B.special_screen_loc)
				B.button.screen_loc = B.special_screen_loc
			else
				B.button.screen_loc = "NORTH-[pos_y],[pos_x]"
			B.button.overlays = list()
			/*
			if (B.cooldown_time > 0 && B.last_used > world.time)
				B.button.overlays += B.button.darkener
				B.button.overlays += B.button.cooldown
			*/


			if (B == src.shift_power)
				B.button.overlays += B.button.shift_highlight
			if (B == src.ctrl_power)
				B.button.overlays += B.button.ctrl_highlight
			if (B == src.alt_power)
				B.button.overlays += B.button.alt_highlight
			src.client.screen += B.button
			if (!B.special_screen_loc)
				pos_x++
				if(pos_x > 15)
					pos_x = 1
					pos_y++

		if (viewing_upgrades)
			pos_x = 0
			pos_y = 14

			for(var/datum/blob_upgrade/B in src.available_upgrades)
				if (!istype(B.button))
					continue
				//B.button.screen_loc = "SOUTH,[pos_x]:9"
				B.button.screen_loc = "WEST+[pos_x]:9,NORTH-[pos_y]"
				src.client.screen += B.button
				B.button.overlays = list()
				//if (!B.check_requirements())
				//	B.button.overlays += B.button.darkener
				pos_x++
				if(pos_x > 15)
					pos_x = 0
					pos_y--

		src.update_cooldown_costs()


	proc/update_cooldown_costs()
		for(var/datum/blob_ability/B in src.abilities)
			if (!istype(B.button))
				continue
			B.update_cooldown_cost()

		if (viewing_upgrades)
			for(var/datum/blob_upgrade/B in src.available_upgrades)
				if (!istype(B.button))
					continue
				B.update_cooldown_cost()


	proc/has_ability(var/ability_path)
		for (var/datum/blob_ability/B in src.abilities)
			if (B.type == ability_path)
				return 1
		return 0

	proc/has_upgrade(var/upgrade_path)
		for (var/datum/blob_upgrade/B in src.upgrades)
			if (B.type == upgrade_path)
				return 1
		return 0

	proc/BlobPointsBezierApproximation(var/t)
		// t = number of tiles occupied by the blob
		t = clamp(t, 0, 1000)
		var/points

		if (t < 514)
			points = t - ((t ** 2) / 4000) - (eulers ** ((t-252)/50)) + 1
		else if (t >= 514)
			// Oh dear, you seem to be too fucking big. Whoopsie daisies...
			// Marq update: gonna flatline this at 40 so big blobs aren't completely useless
			// The idea is not that we should be punishing big blobs, rather we should be making progress progressively difficult.
			points = max(40, 30000 / (t - 417) - 51)

		return round(max(0, points))

	proc/usePoints(var/amt, var/force = 1)
		if (bio_points < amt)
			var/needed = amt - bio_points
			if (lipids.len * 4 >= needed)
				while (bio_points < amt)
					if (!lipids.len)
						break
					var/obj/blob/lipid/L = pick(lipids)
					if (!istype(L))
						lipids -= L
						continue
					L.use()
		if (bio_points < amt)
			if (force)
				bio_points -= amt
			return 0
		bio_points -= amt
		return 1

	proc/hasPoints(var/amt)
		for (var/Q in lipids)
			if (!istype(Q, /obj/blob/lipid))
				lipids -= Q
		return bio_points + lipids.len * 4 >= amt



	proc/setHat( var/obj/item/clothing/head/hat )
		hat.pixel_y = 10
		//hat.pixel_x = -3
		hat.appearance_flags |= (RESET_ALPHA)
		for( var/obj/blob/b in nuclei )
			if(src.hat)
				b.overlays -= src.hat
			b.overlays += hat
		if( src.hat )
			overlays -= src.hat
			qdel(src.hat)
		overlays += hat
		src.hat = hat
		hat.set_loc(src)

	proc/go_critical() //I'm sure this won't turn out to be a bad idea
		SPAWN(0)
			while (TRUE)
				if (prob(10)) //pfff sure
					sleep(1)
				var/emergency_var = 0 //no infinite loops if we *really* can't find one
				var/obj/blob/blob = pick(by_type[/obj/blob])
				while ((blob.surrounded == (NORTH | SOUTH | EAST | WEST)) && emergency_var < 100)
					blob = pick(by_type[/obj/blob])
					emergency_var++
				if (!blob) //give up and try again next iteration
					continue
				for (var/dir in cardinal)
					if (!(blob.surrounded & dir))
						var/turf/T = get_step(blob, dir)
						if (T?.can_blob_spread_here(skip_adjacent = TRUE))
							var/obj/blob/new_blob = new(T)
							new_blob.setOvermind(blob.overmind)
							blob.overmind.total_placed++

/atom/movable/screen/blob
	plane = PLANE_HUD
	var/datum/blob_ability/ability = null
	var/datum/blob_upgrade/upgrade = null
	var/image/ctrl_highlight = null
	var/image/shift_highlight = null
	var/image/alt_highlight = null
	var/image/cooldown = null
	var/image/darkener = null

	var/atom/movable/screen/pseudo_overlay/point_overlay
	var/atom/movable/screen/pseudo_overlay/cooldown_overlay

	New()
		..()
		ctrl_highlight = image('icons/mob/blob_ui.dmi',"ctrl")
		shift_highlight = image('icons/mob/blob_ui.dmi',"shift")
		alt_highlight = image('icons/mob/blob_ui.dmi',"alt")
		cooldown = image('icons/mob/blob_ui.dmi',"cooldown")
		var/image/I = image('icons/mob/blob_ui.dmi',"darkener")
		I.alpha = 100
		darkener = I
		//var/atom/movable/screen/pseudo_overlay/T = new /atom/movable/screen/pseudo_overlay(src)
		//var/atom/movable/screen/pseudo_overlay/S = new /atom/movable/screen/pseudo_overlay(src)
		point_overlay = new /atom/movable/screen/pseudo_overlay()
		cooldown_overlay = new /atom/movable/screen/pseudo_overlay()
		src.vis_contents += point_overlay
		src.vis_contents += cooldown_overlay
		cooldown_overlay.icon = 'icons/mob/spell_buttons.dmi'
		cooldown_overlay.icon_state = "cooldown"
		cooldown_overlay.alpha = 0
		point_overlay.maptext_x = -2
		point_overlay.maptext_y = 2
		cooldown_overlay.pixel_y = 4
		cooldown_overlay.maptext_y = 1
		cooldown_overlay.maptext_x = 1

	disposing()
		if(ability)
			ability.button = null
			ability = null
		if(upgrade)
			upgrade.button = null
			upgrade = null
		..()


	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!istype(O,/atom/movable/screen/blob/) || !isblob(user))
			return
		var/atom/movable/screen/blob/source = O
		if (!istype(src.ability) || !istype(source.ability))
			boutput(user, SPAN_ALERT("You may only switch the places of ability buttons."))
			return
		var/mob/living/intangible/blob_overmind/owner = user

		var/index_source = owner.abilities.Find(source.ability)
		var/index_target = owner.abilities.Find(src.ability)
		owner.abilities.Swap(index_source,index_target)
		owner.update_buttons()

	//Click(location,control,params)
	clicked(parameters)
		if (!isblob(usr))
			return

		var/mob/living/intangible/blob_overmind/user = usr

		if (!istype(user))
			return
		if (!istype(ability) && !istype(upgrade))
			return

		if (ability)
			if (!ability.helpable)
				ability.onUse()
				return

		if (upgrade)
			if ((parameters["shift"] || !user.help_mode) && upgrade.check_requirements())
				if (user.upgrading)
					return
				var/my_upgrade_id = user.upgrade_id
				user.upgrading = my_upgrade_id
				SPAWN(2 SECONDS)
					if (user.upgrading <= my_upgrade_id)
						user.upgrading = 0
					else
						sleep(2 SECONDS)
						user.upgrading = 0
				if (!upgrade.take_upgrade())
					upgrade.deduct_evo_points()
				user.update_buttons()
			else
				boutput(user, "<b>Upgrade:</b> [upgrade.name]")
				boutput(user, "[upgrade.desc]")
				boutput(user, "<b>Evo Point Cost:</b> [upgrade.evo_point_cost]")
				if (upgrade.check_requirements())
					boutput(user, SPAN_NOTICE("Shift-click on this icon to take the upgrade."))
				else
					boutput(user, SPAN_ALERT("You cannot take this upgrade yet."))
			return

		if (parameters["ctrl"] && ability.targeted)
			if (ability == user.alt_power || ability == user.shift_power)
				boutput(user, SPAN_ALERT("That ability is already bound to another key."))
				return

			if (ability == user.ctrl_power)
				user.ctrl_power = null
				boutput(user, SPAN_NOTICE("<b>[ability.name] has been unbound from Ctrl-Click.</b>"))
				user.update_buttons()
			else
				user.ctrl_power = ability
				boutput(user, SPAN_NOTICE("<b>[ability.name] is now bound to Ctrl-Click.</b>"))

		else if (parameters["alt"] && ability.targeted)
			if (ability == user.shift_power || ability == user.ctrl_power)
				boutput(user, SPAN_ALERT("That ability is already bound to another key."))
				return

			if (ability == user.alt_power)
				user.alt_power = null
				boutput(user, SPAN_NOTICE("<b>[ability.name] has been unbound from Alt-Click.</b>"))
				user.update_buttons()
			else
				user.alt_power = ability
				boutput(user, SPAN_NOTICE("<b>[ability.name] is now bound to Alt-Click.</b>"))

		else if (parameters["shift"] && ability.targeted)
			if (ability == user.alt_power || ability == user.ctrl_power)
				boutput(user, SPAN_ALERT("That ability is already bound to another key."))
				return

			if (ability == user.shift_power)
				user.shift_power = null
				boutput(user, SPAN_NOTICE("<b>[ability.name] has been unbound from Shift-Click.</b>"))
				user.update_buttons()
			else
				user.shift_power = ability
				boutput(user, SPAN_NOTICE("<b>[ability.name] is now bound to Shift-Click.</b>"))

		else
			if (user.help_mode)
				boutput(user, SPAN_NOTICE("<b>This is your [ability.name] ability.</b>"))
				boutput(user, SPAN_NOTICE("It costs [ability.bio_point_cost] bio points to use."))
				if (istype(ability,/datum/blob_ability/build))
					var/datum/blob_ability/build/AB = ability
					boutput(user, SPAN_NOTICE("This is a building ability - you need to use it on a regular blob tile."))
					if (AB.gen_rate_invest > 0)
						boutput(user, SPAN_NOTICE("This ability requires you to invest [AB.gen_rate_invest] of your BP generation rate in it. It will be returned when the cell is destroyed."))
				boutput(user, SPAN_NOTICE("[ability.desc]"))
				boutput(user, SPAN_NOTICE("Hold down Shift, Ctrl or Alt while clicking the button to set it to that key."))
				boutput(user, SPAN_NOTICE("You will then be able to use it freely by holding that button and left-clicking a tile."))
				boutput(user, SPAN_NOTICE("Alternatively, you can click with your middle mouse button to use the ability on your current tile."))
				boutput(user, SPAN_NOTICE("If you want to swap the places of two buttons on this bar, click and drag one to the position you want it to occupy."))
			else
				ability.onUse()

		user.update_buttons()

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder)
			var/cost = null
			if (ability)
				cost = "<BR>Cost: [ability.bio_point_cost] BP<BR>Cooldown: [ability.cooldown_time / 10] s"
			else if (upgrade)
				cost = "<BR>Cost: [upgrade.evo_point_cost] EP"


			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = "[src.name][cost]",
				"content" = src.desc ,
				"theme" = "blob"
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

/mob/living/intangible/blob_overmind/checkContextActions(atom/target)
	// a bit oh a hack, no multicontext for blobs now because it keeps overriding attacking pods :/
	return list()
