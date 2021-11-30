////////// Nuclear Bomb Teleporter //////////
/obj/item/remote/nuke_summon_remote
	name = "Nuclear Bomb Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A single-use teleporter remote that summons the nuclear bomb to the user's current location."
	icon_state = "bomb_remote"
	item_state = "electronic"
	density = FALSE
	anchored = FALSE
	w_class = W_CLASS_SMALL

	var/charges = 1
	var/use_sound = "sound/machines/chime.ogg"
	var/atom/movable/the_bomb = null

/obj/item/remote/nuke_summon_remote/attack_self(mob/user as mob)
	if(charges >= 1)
		var/turf/T = get_turf(user)
		if(isnull(the_bomb))
			try_to_find_the_nuke()
		if(isnull(the_bomb))
			boutput(user, "<span class='alert'>No teleportation target found!</span>")
			return
		if(T.z != Z_LEVEL_STATION)
			boutput(user, "<span class='alert'>You cannot summon the bomb here!</span>")
			return
		if(the_bomb.anchored)
			boutput(user, "<span class='alert'>\The [the_bomb] is currently secured to the floor and cannot be teleported.</span>")
			return
		tele_the_bomb(user)
	else
		boutput(user, "<span class='alert'>The [src] is out of charge and can't be used again!</span>")

/obj/item/remote/nuke_summon_remote/proc/try_to_find_the_nuke()
	if(ticker.mode.type == /datum/game_mode/nuclear)
		var/datum/game_mode/nuclear/mode = ticker.mode
		the_bomb = mode.the_bomb
	if(isnull(the_bomb))
		for_by_tcl(nuke, /obj/machinery/nuclearbomb)
			the_bomb = nuke
			break

/obj/item/remote/nuke_summon_remote/proc/tele_the_bomb(mob/user as mob)
	showswirl(the_bomb)
	the_bomb.set_loc(get_turf(src))
	showswirl(src)
	src.visible_message("<span class='alert'>[user] has summoned the [the_bomb]!</span>")
	src.charges -= 1
	playsound(src.loc, use_sound, 70, 1)

////////// Reinforcement Summon Beacon //////////
/obj/item/remote/reinforcement_beacon
	name = "Reinforcement Beacon"
	icon = 'icons/obj/items/device.dmi'
	desc = "A handheld beacon that allows you to call a Syndicate reinforcement to the user's current location."
	icon_state = "beacon" //replace later
	item_state = "electronic"
	density = FALSE
	anchored = TRUE
	w_class = W_CLASS_SMALL
	var/uses = 1
	var/ghost_confirmation_delay = 30 SECONDS

	New()
		..()
		sleep(1)
		desc = "A handheld beacon that allows you to call a Syndicate reinforcement to the user's current location. It has [src.uses] charge left."

/obj/item/remote/reinforcement_beacon/attack_self(mob/user as mob)
	if(isrestrictedz(user.z) || isrestrictedz(src.z))
		boutput(user, "<span class='alert'>The [src] can't be used here, try again on station!</span>")
		return

	if(uses >= 1)
		uses -= 1
		boutput(user, "<span class='alert'>You activate the [src], before setting it down on the ground.</span>")
		src.force_drop(user)
		src.anchored = TRUE
		sleep(1 SECOND)
		src.visible_message("<span class='alert'>The [src] beeps, before locking itself to the ground.</span>")
		src.desc = "A handheld beacon that allows you to call a Syndicate reinforcement to the user's current location. It seems to currently be transmitting something."
		sleep(5 SECONDS)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a nuclear operative reinforcement? You may be randomly selected from the list of candidates.")
		text_messages.Add("You are eligible to be respawned as a nuclear operative reinforcement. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. Please wait for the game to choose, good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending Syndicate Reinforcement offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)
		if(!length(candidates))
			src.visible_message("<span class='alert'>The [src] buzzes, before unbolting itself from the ground. There seems to be no reinforcements available currently.</span>")
			src.anchored = FALSE
		var/datum/mind/chosen = pick(candidates)
		var/mob/living/critter/gunbot/syndicate/synd = new/mob/living/critter/gunbot/syndicate
		chosen.transfer_to(synd)
		//H.mind.transfer_to(synd) //comment out ghost messages & uncomment this to make *you* the reinforcement for testing purposes
		synd.mind.special_role = ROLE_NUKEOP
		synd.mind.current.antagonist_overlay_refresh(1, 0)
		SHOW_NUKEOP_TIPS(synd.mind.current)
		SPAWN_DBG(0)
			launch_with_missile(synd, src.loc)
		sleep(3 SECONDS)
		if(src.uses <= 0)
			elecflash(src)
			src.visible_message("<span class='alert'>The [src] sparks, before exploding!</span>")
			sleep(5 DECI SECONDS)
			explosion_new(src, get_turf(src), 0.1)
			qdel(src)
		else
			src.visible_message("<span class='alert'>The [src] beeps twice, before unbolting itself from the ground.</span>")
	else
		boutput(user, "<span class='alert'>The [src] is out of charge and can't be used again!</span>")

////////// Handheld Vendor //////////
#define WEAPON_VENDOR_CATEGORY_SIDEARM "sidearm"
#define WEAPON_VENDOR_CATEGORY_LOADOUT "loadout"
#define WEAPON_VENDOR_CATEGORY_UTILITY "utility"
#define WEAPON_VENDOR_CATEGORY_ASSISTANT "assistant"

/obj/item/device/weapon_vendor
	name = "Weapon Vendor Uplink"
	icon = 'icons/obj/items/device.dmi'
	desc = "A modified uplink which allows you to buy a loadout on the go. Nifty!"
	icon_state = "uplink" //replace later
	item_state = "electronic"
	density = FALSE
	anchored = FALSE
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | FPRINT

	var/sound_token = 'sound/machines/capsulebuy.ogg'
	var/sound_buy = 'sound/machines/spend.ogg'
	var/list/credits = list(WEAPON_VENDOR_CATEGORY_SIDEARM = 0, WEAPON_VENDOR_CATEGORY_LOADOUT = 0, WEAPON_VENDOR_CATEGORY_UTILITY = 0, WEAPON_VENDOR_CATEGORY_ASSISTANT = 0)
	var/list/datum/materiel_stock = list()
	var/token_accepted = /obj/item/requisition_token
	var/log_purchase = FALSE

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "WeaponVendor", src.name)
			ui.open()

	ui_static_data(mob/user)
		. = list("stock" = list())

		for (var/datum/materiel/M as anything in materiel_stock)
			.["stock"] += list(list(
				"ref" = "\ref[M]",
				"name" = M.name,
				"description" = M.description,
				"cost" = M.cost,
				"category" = M.category,
			))

	ui_data(mob/user)
		. = list(
			"credits" = src.credits,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return

		switch(action)
			if ("purchase")
				var/datum/materiel/M = locate(params["ref"]) in materiel_stock
				if (src.credits[M.category] >= M.cost)
					src.credits[M.category] -= M.cost
					var/atom/A = new M.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)
					src.vended(A)
					usr.put_in_hand_or_eject(A)
					return TRUE

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, token_accepted))
			user.drop_item(I)
			qdel(I)
			accepted_token(I, user)
		else
			..()

	attack_self(mob/user)
		return ui_interact(user)

	proc/accepted_token(var/token, var/mob/user)
		src.ui_interact(user)
		playsound(src.loc, sound_token, 80, 1)
		boutput(user, "<span class='notice'>You insert the requisition token into [src].</span>")
		if(log_purchase)
			logTheThing("debug", user, null, "inserted [token] into [src] at [log_loc(get_turf(src))]")


	proc/vended(var/atom/A)
		if(log_purchase)
			logTheThing("debug", usr, null, "bought [A] from [src] at [log_loc(get_turf(src))]")
		.= 0

/obj/item/device/weapon_vendor/syndicate
	name = "Syndicate Weapons Vendor"
	icon = 'icons/obj/items/device.dmi'
	desc = "A modified uplink which allows you to buy a loadout on the go. Nifty!"
	icon_state = "uplink" //replace later
	item_state = "electronic"
	token_accepted = /obj/item/requisition_token/syndicate
	log_purchase = TRUE

	New()
		..()
		// List of avaliable objects for purchase
		materiel_stock += new/datum/materiel/sidearm/smartgun
		materiel_stock += new/datum/materiel/sidearm/pistol
		materiel_stock += new/datum/materiel/sidearm/revolver

		materiel_stock += new/datum/materiel/loadout/assault
		materiel_stock += new/datum/materiel/loadout/heavy
		materiel_stock += new/datum/materiel/loadout/grenadier
		materiel_stock += new/datum/materiel/loadout/infiltrator
		materiel_stock += new/datum/materiel/loadout/scout
		materiel_stock += new/datum/materiel/loadout/medic
		materiel_stock += new/datum/materiel/loadout/firebrand
		materiel_stock += new/datum/materiel/loadout/engineer
		materiel_stock += new/datum/materiel/loadout/marksman
		materiel_stock += new/datum/materiel/loadout/knight
		materiel_stock += new/datum/materiel/loadout/custom

		materiel_stock += new/datum/materiel/utility/belt
		materiel_stock += new/datum/materiel/utility/knife
		materiel_stock += new/datum/materiel/utility/rpg_ammo
		materiel_stock += new/datum/materiel/utility/donk
		materiel_stock += new/datum/materiel/utility/sarin_grenade
		materiel_stock += new/datum/materiel/utility/noslip_boots
		materiel_stock += new/datum/materiel/utility/bomb_decoy
		materiel_stock += new/datum/materiel/utility/comtac

	accepted_token()
		src.credits[WEAPON_VENDOR_CATEGORY_SIDEARM]++
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
		..()

/obj/item/device/weapon_vendor/syndicate/preloaded
	desc = "A pre-loaded uplink which allows you to buy a sidearm, loadout, and utility on the go. Nifty!"
	token_accepted = null
	credits = list(WEAPON_VENDOR_CATEGORY_SIDEARM = 1, WEAPON_VENDOR_CATEGORY_LOADOUT = 1, WEAPON_VENDOR_CATEGORY_UTILITY = 1, WEAPON_VENDOR_CATEGORY_ASSISTANT = 0)

#undef WEAPON_VENDOR_CATEGORY_SIDEARM
#undef WEAPON_VENDOR_CATEGORY_LOADOUT
#undef WEAPON_VENDOR_CATEGORY_UTILITY
#undef WEAPON_VENDOR_CATEGORY_ASSISTANT

////////// Rapid Deployment Pods //////////
/obj/item/device/deployment_remote
	name = "Rapid Deployment Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A remote used to signal a place for a set of rapid-troop-deployment personnel missile pods to land."
	icon_state = "satcom"
	item_state = "electronic"
	density = 0
	anchored = 0.0
	w_class = W_CLASS_SMALL
	var/area/landing_area = null
	var/list/mob/sent_mobs = list()
	var/list/obj/nuclear_bombs = list() //why the fuck would there be multiple
	var/total_pod_time
	var/used = FALSE
	var/image/valid_overlay_area = null //5 second overlay to indicate the area that will grab people & the nuke
	var/list/turf/overlayed_turfs = list()

	New()
		..()
		valid_overlay_area = image('icons/effects/alert.dmi', "green")

	disposing()
		landing_area = null
		sent_mobs = null
		nuclear_bombs = null
		for(var/turf/T in overlayed_turfs)
			T.overlays -= valid_overlay_area
		overlayed_turfs = null
		valid_overlay_area = null
		..()

	attack_self(mob/user)
		if(src.used)
			boutput(user, "<span class='alert'>The [src] has been used up!</span>")
			return
		if(!src.landing_area)
			choose_area(user)
		else
			var/choice = input(user, "Would you like to reset your area, or deploy to the assault pod?") in list("Reset", "Deploy", "Cancel")
			switch(choice)
				if("Reset")
					src.landing_area = null
					return
				if("Deploy")
					if(!istype(get_area(user), /area/listeningpost) && !istype(get_area(user), /area/syndicate_station))
						boutput(user, "<span class='alert'>You can only deploy from the Cairngorm or Listening Post!</span>")
						return
					var/list/chosen_mobs = list()
					var/is_the_nuke_there = FALSE
					for(var/mob/living/carbon/M in range(4, user.loc))
						chosen_mobs += M
					for(var/obj/machinery/nuclearbomb/NB in range(4, user.loc))
						is_the_nuke_there = TRUE
					for(var/turf/T in range(4, user.loc))
						if(length(overlayed_turfs))
							break
						if(!isfloor(T))
							continue
						overlayed_turfs += T
						T.overlays += valid_overlay_area
					SPAWN_DBG(5 SECONDS)
						for(var/turf/T in overlayed_turfs)
							T.overlays -= valid_overlay_area
					if((length(chosen_mobs) <= 1) && !is_the_nuke_there)
						var/confirmation = input(user, "Are you sure you would like to deploy? You don't have the nuke nearby, in addition to you being alone!") in list("Yes", "No")
						if(confirmation == "Yes")
							var/confirmation2 = input(user, "Are you EXTREMELY sure? There's no coming back!") in list("Yes", "No")
							if(confirmation2 == "Yes")
								send_to_pod(user)
							else
								return
						else
							return
					else if(length(chosen_mobs) <= 1)
						var/confirmation = input(user, "Are you sure you would like to deploy? You're currently alone!") in list("Yes", "No")
						if(confirmation == "Yes")
							var/confirmation2 = input(user, "Are you EXTREMELY sure? There's no coming back!") in list("Yes", "No")
							if(confirmation2 == "Yes")
								send_to_pod(user)
							else
								return
						else
							return
					else if(!is_the_nuke_there)
						var/confirmation = input(user, "Are you sure you would like to deploy? The nuke isn't close enough to come with you!") in list("Yes", "No")
						if(confirmation == "Yes")
							var/confirmation2 = input(user, "Are you EXTREMELY sure? There's no coming back!") in list("Yes", "No")
							if(confirmation2 == "Yes")
								send_to_pod(user)
							else
								return
						else
							return
					else
						var/confirmation = input(user, "Are you sure you would like to deploy? You have [length(chosen_mobs)] who will deploy with you.") in list("Yes", "No")
						if(confirmation == "Yes")
							var/confirmation2 = input(user, "Are you EXTREMELY sure? There's no coming back!") in list("Yes", "No")
							if(confirmation2 == "Yes")
								send_to_pod(user)
							else
								return
						else
							return
				if("Cancel")
					return


	proc/choose_area(var/mob/user)
		var/temp_people_count = 10 //sanity check to make sure there's enough turfs to land on
		var/list/area/filtered_areas = get_teleareas()
		var/list/turf/check_turfs = list()
		for(var/mob/living/carbon/M in range(4, user.loc))
			temp_people_count += 1
		for(var/area/A in filtered_areas)
			for(var/turf/T in get_area_turfs(A, TRUE))
				check_turfs += T
			if(!(length(check_turfs) >= temp_people_count))
				filtered_areas -= A
				continue
		var/area/temp_area = input("Choose Landing Area") as null|anything in filtered_areas
		src.landing_area = get_telearea(temp_area)
		if (!src.landing_area)
			return FALSE
		var/list/turf/possible_turfs = list()
		for(var/turf/T in get_area_turfs(src.landing_area, TRUE))
			possible_turfs += T

	proc/send_to_pod(var/mob/user)
		for(var/mob/living/carbon/M in range(4, user.loc))
			SPAWN_DBG(0)
				var/L = pick_landmark(LANDMARK_SYNDICATE_ASSAULT_POD_TELE)
				if(!L) //fuck
					return
				for(var/obj/item/remote/syndicate_teleporter/T in M.get_all_items_on_mob())
					qdel(T) //Emphasizing that there really is no easy way back if you go this way
				playsound(M, "sound/effects/teleport.ogg", 30, 1)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(M)
				M.set_loc(L)
				var/obj/decal/residual_energy/R = new/obj/decal/residual_energy(L)
				playsound(L, "sound/effects/teleport.ogg", 30, 1)
				SPAWN_DBG(1 SECOND)
					qdel(S)
					qdel(R)
			sent_mobs += M
		for(var/obj/machinery/nuclearbomb/NB in range(4, user.loc))
			SPAWN_DBG(0)
				var/L = pick_landmark(LANDMARK_SYNDICATE_ASSAULT_POD_TELE)
				if(!L)
					return
				playsound(NB, "sound/effects/teleport.ogg", 30, 1)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(NB)
				NB.set_loc(L)
				var/obj/decal/residual_energy/R = new/obj/decal/residual_energy(L)
				playsound(L, "sound/effects/teleport.ogg", 30, 1)
				SPAWN_DBG(1 SECOND)
					qdel(S)
					qdel(R)
			nuclear_bombs += NB
		src.used = TRUE
		for(var/obj/machinery/computer/security/pod_timer/S in range(1, pick_landmark(LANDMARK_SYNDICATE_ASSAULT_POD_COMP))) //This is the only way I could make this work
			var/rand_time = rand(45 SECONDS, 60 SECONDS)
			S.total_pod_time = TIME + rand_time + 7.5 SECONDS
			sleep(7.5 SECONDS)
			for(var/mob/living/L in sent_mobs)
				shake_camera(L, 16, 16)
				var/atom/target = get_edge_target_turf(L, pick(alldirs))
				if(target && !L.buckled)
					L.throw_at(target, 3, 1)
					L.changeStatus("stunned", 2 SECONDS)
					L.changeStatus("weakened", 2 SECONDS)
			command_alert("A Syndicate Assault pod is heading towards [station_name], be on high alert.", "Central Command Alert", "sound/misc/announcement_1.ogg")
			sleep(rand_time / 2)
			command_alert("Our sensors have determined the Syndicate Assault pod is headed towards [src.landing_area], a response would be advised.", "Central Command Alert", "sound/misc/announcement_1.ogg")
			sleep(rand_time / 2)
			send_pods()

	proc/send_pods()
		var/list/turf/possible_turfs = list()
		for(var/turf/T in get_area_turfs(src.landing_area, TRUE))
			possible_turfs += T
		for(var/obj/machinery/nuclearbomb/NB in nuclear_bombs)
			var/turf/picked_turf = pick(possible_turfs)
			SPAWN_DBG(0)
				launch_with_missile(NB, picked_turf)
			possible_turfs -= picked_turf
		for(var/mob/living/carbon/C in sent_mobs)
			var/turf/picked_turf = pick(possible_turfs)
			SPAWN_DBG(0)
				launch_with_missile(C, picked_turf)
			possible_turfs -= picked_turf
			if(!length(possible_turfs))
				src.visible_message("<span class='alert'>The [src] makes a grumpy beep, it seems not everyone could be sent!</span>")
				break
		command_alert("A group of [length(sent_mobs)] personnel missiles have been spotted launching from a Syndicate Assault pod towards [src.landing_area], be prepared for heavy contact.","Central Command Alert", "sound/misc/announcement_1.ogg")
		qdel(src)

/obj/machinery/computer/security/pod_timer
	maptext_x = 0
	maptext_y = 20
	maptext_width = 64
	var/total_pod_time
	processing_tier = PROCESSING_QUARTER

	proc/get_pod_timer()
		var/timeleft = round((total_pod_time - TIME) / 10, 1)
		timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
		return timeleft

	process()
		if (total_pod_time && TIME >= total_pod_time)
			src.maptext = "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">--:--</span>"
		else
			src.maptext = "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">[get_pod_timer()]</span>"
		..()


#define DESIGNATOR_MAX_RANGE 30

////////// Laser Designator & Airstrikes //////////
/obj/item/device/laser_designator
	name = "Laser Designator"
	icon = 'icons/obj/items/device.dmi'
	desc = "A handheld monocular device with a laser built into it, used for calling in fire support."
	icon_state = "laser_designator"
	item_state = "electronic"
	density = FALSE
	anchored = FALSE
	w_class = W_CLASS_SMALL
	///How many times can this be used?
	var/uses = 1
	///Movement controller for the designator's "scope"
	var/datum/movement_controller/designatormove = null
	///TRUE if an air strike is waiting to happen/happening
	var/in_use = FALSE
	///The gun that "fires" the shell
	var/obj/machinery/broadside_gun/linked_gun = null
	///Takes a string for a ship that's set in the `linked_gun`'s vars, e.g. "Cairngorm"
	var/ship_looking_for = ""
	///Overlay sprite for where the strike will land, set to null for no overlay
	var/image/target_overlay = null

	New()
		..()
		designatormove = new/datum/movement_controller/designator_look()
		desc = "A handheld monocular device with a laser built into it, used for calling in fire support. It has [src.uses] charge left."
		target_overlay = image('icons/effects/effects.dmi', "spinny_red")

	disposing()
		designatormove = null
		linked_gun = null
		target_overlay = null
		..()

	dropped(mob/M)
		remove_self(M)
		..()

	move_callback(var/mob/living/M, var/turf/source, var/turf/target)
		if (M.use_movement_controller)
			if (source != target)
				just_stop_designating(M)

	proc/airstrike(atom/target, params, mob/user, reach)
		uses -= 1
		in_use = TRUE
		linked_gun.bombard(target, user)
		in_use = FALSE

	proc/remove_self(var/mob/living/M)
		if (islist(M.move_laying))
			M.move_laying -= src
		else
			M.move_laying = null

		if (ishuman(M))
			M:special_sprint &= ~SPRINT_DESIGNATOR

		just_stop_designating(M)

	proc/just_stop_designating(var/mob/living/M) // remove overlay here
		if (M.client)
			M.client.pixel_x = 0
			M.client.pixel_y = 0

		M.use_movement_controller = null
		M.keys_changed(0,0xFFFF)
		M.removeOverlayComposition(/datum/overlayComposition/sniper_scope)

	attack_hand(mob/user as mob)
		if (..() & ishuman(user))
			user:special_sprint |= SPRINT_DESIGNATOR
			var/mob/living/L = user

			//set move callback (when user moves, designator go down)
			if (islist(L.move_laying))
				L.move_laying += src
			else
				if (L.move_laying)
					L.move_laying = list(L.move_laying, src)
				else
					L.move_laying = list(src)

	get_movement_controller()
		.= designatormove

/mob/living/proc/begin_designating() //add overlay + sound here
	for (var/obj/item/device/laser_designator/S in equipped_list(check_for_magtractor = 0))
		src.use_movement_controller = S
		src.keys_changed(0,0xFFFF)
		if(!src.hasOverlayComposition(/datum/overlayComposition/sniper_scope))
			src.addOverlayComposition(/datum/overlayComposition/sniper_scope)
		playsound(src, "sound/weapons/scope.ogg", 50, 1)
		break

/obj/item/device/laser_designator/syndicate
	name = "Laser Designator"
	desc = "A handheld monocular device with a laser built into it, used for calling in fire support from the Cairngorm."
	w_class = W_CLASS_SMALL
	uses = 2
	ship_looking_for = "Cairngorm"

	New()
		..()
		desc = "A handheld monocular device with a laser built into it, used for calling in fire support from the Cairngorm. It has [src.uses] charge left."

	airstrike(atom/target, params, mob/user, reach)
		..()
		src.desc = "A handheld monocular device with a laser built into it, used for calling in fire support from the Cairngorm. It has [src.uses] charge left."
		return TRUE

	pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
		if (reach)
			return FALSE
		if (!isturf(user.loc))
			return FALSE
		if (uses <= 0)
			return FALSE
		if (in_use)
			return FALSE
		if(target.z != 1 || user.z != 1)
			return

		for_by_tcl(A, /obj/machinery/broadside_gun)
			var/obj/machinery/broadside_gun/C = A
			if(C.firingfrom == src.ship_looking_for && !C.broken && ((C.ammo <= 0) || (!C.ammo == -1)))
				src.linked_gun = C
				break

		if(!src.linked_gun)
			boutput(user, "<span class='alert'>The [src] makes a grumpy beep. It seems there's no artillery guns in position currently.</span>")
			playsound(src, "sound/machines/buzz-sigh.ogg", 50, 1)
			return FALSE

		return src.airstrike(target, params, user, reach)



/obj/machinery/broadside_gun //Thanks to Cogwerks for the sprites
	name = "Broadside Gun Parent"
	icon = 'icons/obj/large/96x32.dmi'
	icon_state = "artillery_cannon"
	desc = "Parent of broadside guns for fire support."
	density = 1
	anchored = 1
	processing_tier = PROCESSING_EIGHTH
	bound_width = 96
	///Ship name you're firing from, important for the designator
	var/firingfrom = ""
	var/broken = FALSE
	///Amount of ammo the gun has, set to -1 for infinite
	var/ammo = 1
	///In case you need to offset the gun firing's sound by offset tiles (if it's aiming left for example)
	var/sound_offset_length
	///In case you need to offset the gun firing's sound dir (if it's aiming left for example)
	var/sound_offset_dir
	///Holding var for the exact turf to play the gun's firing sound from
	var/turf/sound_turf
	///Overlay sprite for where the strike will land, set to null for no overlay
	var/image/target_overlay = null


	proc/bombard(var/atom/target, var/mob/user)
		return

	New()
		. = ..()
		START_TRACKING
		target_overlay = image('icons/effects/effects.dmi', "spinny_red")
		sound_turf = get_turf(src)

	disposing()
		. = ..()
		STOP_TRACKING
		target_overlay = null

/obj/machinery/broadside_gun/artillery_cannon
	name = "Artillery Cannon"
	icon = 'icons/obj/large/96x32.dmi'
	icon_state = "152mm"
	desc = "A 152 millimeter artillery cannon, used for heavy fire support."
	bound_width = 96
	firingfrom = ""
	ammo = -1
	sound_offset_dir = EAST
	sound_offset_length = 3

	bombard(atom/target, mob/user)
		var/turf/target_turf = get_turf(target)
		var/turf/firing_turf = get_turf(src)
		if(!(target_turf in view(DESIGNATOR_MAX_RANGE, usr.loc))) //view() is bad and slow but I cannot find a better way to do this
			return FALSE
		if(!isnull(src.target_overlay))
			target_turf.overlays += src.target_overlay
		while(sound_offset_length > 0)
			sound_turf = get_step(src, sound_offset_dir)
			sound_offset_length--
		playsound(user, "sound/machines/whistlebeep.ogg", 50, 1)
		playsound(sound_turf, "sound/weapons/energy/howitzer_firing.ogg", 50, 1)
		sleep(2.5 SECONDS)
		var/area/designated_area = get_area(target_turf)
		command_alert("Heavy ordinace has been detected launching from the Cairngorm towards the [initial(designated_area.name)], ETA 10 seconds.","Central Command Alert", "sound/machines/alarm_a.ogg")
		flick("152mm_firing", src)
		firing_turf = get_step(firing_turf, WEST)
		firing_turf = get_step(firing_turf, WEST)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(firing_turf)
		animation.icon = 'icons/obj/large/96x32.dmi'
		animation.icon_state = "nothing"
		SPAWN_DBG(0)
			flick("152mm-flash", animation)
			sleep(1.2 SECONDS)
			qdel(animation)
		playsound(sound_turf, "sound/weapons/energy/howitzer_shot.ogg", 50, 1)
		sleep(rand(60, 110))
		if(!isnull(src.target_overlay))
			target_turf.overlays -= src.target_overlay
		explosion_new(user, target_turf, 75)
		return TRUE


	syndicate
		firingfrom = "Cairngorm"

#undef DESIGNATOR_MAX_RANGE
////////// Ammoboxes & ammobags //////////
//Not all used for nukeops, but theme stays the same throughout so they're all here

/obj/item/ammo/ammobox
	sname = "Generic Ammobox"
	name = "Generic Ammobox"
	desc = "You shouldn't see me!"
	icon_state = "lmg_ammo-0-old"
	ammo_type = null
	caliber = null
	var/list/valid_calibers = list() //supports lists and single, set to "All" for any gun

	attackby(obj/item/gun/kinetic/W, mob/user)
		if(istype(W, /obj/item/gun/kinetic))
			if((islist(valid_calibers) && valid_calibers.Find(initial(W.caliber))) || (!islist(valid_calibers) && valid_calibers == initial(W.caliber)))
				new W.default_magazine(get_turf(src))
				var/obj/O = W.default_magazine
				boutput(user, "<span class='alert'>You get a [O.name] out of [src].</span>")
				qdel(src)
			if(valid_calibers == "All")
				new W.default_magazine(get_turf(src))
				var/obj/O = W.default_magazine
				boutput(user, "<span class='alert'>You get a [O.name] out of [src].</span>")
				qdel(src)
		else
			..()

/obj/item/ammo/ammobox/pistol_smg
	name = "Pistol / SMG Ammo Box"
	desc = "A box containing a magazine of pistol- and sub-machine gun caliber ammo."
	valid_calibers = list(0.22, 0.355, 0.50, 0.512) //not adding .357 and .38 because they're special

/obj/item/ammo/ammobox/revolver
	name = "revolver ammo box"
	desc = "A box containing a speedloader of revolver-caliber ammo."
	valid_calibers = list(0.357, 0.38)

/obj/item/ammo/ammobox/rifle
	name = "rifle ammo box"
	desc = "A box containing a magazine of rifle-caliber ammo."
	valid_calibers = list(0.065, 0.223, 0.308)

/obj/item/ammo/ammobox/rifle/spec
	name = "specialist rifle ammo box"
	desc = "A box containing a magazine of specialist rifle-caliber ammo. A label on the side reads 'Not for use with all weapons'."

	attackby(obj/item/gun/kinetic/W, mob/user) //I detest having to do each gun individually but so many guns use rifle caliber aaaaaaa
		if(istype(W, /obj/item/gun/kinetic/assault_rifle))
			new/obj/item/ammo/bullets/assault_rifle/armor_piercing(get_turf(src))
			boutput(user, "<span class='alert'>You get an AP STENAG magazine out of [src].</span>")
			qdel(src)
		else if(istype(W, /obj/item/gun/kinetic/hunting_rifle) || istype(W, /obj/item/gun/kinetic/dart_rifle))
			var/picked_ammo = pick(/obj/item/ammo/bullets/tranq_darts/syndicate, /obj/item/ammo/bullets/tranq_darts/anti_mutant, /obj/item/ammo/bullets/rifle_3006, /obj/item/ammo/bullets/rifle_3006/rakshasa) //this won't go poorly at all :shelterfrog:
			new picked_ammo(get_turf(src))
			var/obj/O = picked_ammo
			boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
			qdel(src)
		else if(istype(W, /obj/item/gun/kinetic/g11))
			var/picked_ammo = pick(/obj/item/ammo/bullets/g11/blast, /obj/item/ammo/bullets/g11/void)
			new picked_ammo(get_turf(src))
			var/obj/O = picked_ammo
			boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
			qdel(src)
		else
			..()

/obj/item/ammo/ammobox/shotgun
	name = "shotgun ammo box"
	desc = "A box containing a box of shotgun-caliber ammo."
	valid_calibers = 0.72

/obj/item/ammo/ammobox/shotgun/spec
	name = "specialist shotgun ammo box"
	desc = "A box containing a box of specialist shotgun ammunition."

	attackby(obj/item/gun/kinetic/W, mob/user)
		if(istype(W, /obj/item/gun/kinetic))
			if((islist(valid_calibers) && valid_calibers.Find(initial(W.caliber))) || (!islist(valid_calibers) && valid_calibers == initial(W.caliber)))
				var/picked_ammo = pick(/obj/item/ammo/bullets/a12, /obj/item/ammo/bullets/aex, /obj/item/ammo/bullets/abg, /obj/item/ammo/bullets/flare)
				new picked_ammo(get_turf(src))
				var/obj/O = picked_ammo
				boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
				qdel(src)
		else
			..()

/obj/item/ammo/ammobox/ltl_grenade
	name = "weak grenade ammo box"
	desc = "A box containing less-than-lethal grenade launcher ammunition."
	valid_calibers = 1.57

	attackby(obj/item/gun/kinetic/W, mob/user)
		if(istype(W, /obj/item/gun/kinetic))
			if((islist(valid_calibers) && valid_calibers.Find(initial(W.caliber))) || (!islist(valid_calibers) && valid_calibers == initial(W.caliber)))
				var/picked_ammo = pick(/obj/item/ammo/bullets/smoke, /obj/item/ammo/bullets/marker, /obj/item/ammo/bullets/pbr)
				new picked_ammo(get_turf(src))
				var/obj/O = picked_ammo
				boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
				qdel(src)
		else
			..()

/obj/item/ammo/ammobox/he_grenade
	name = "explosive ammo box"
	desc = "A box containing high-explosive launcher ammunition."
	valid_calibers = list(1.57, 1.58, 0.787)

	attackby(obj/item/gun/kinetic/W, mob/user)
		if(istype(W, /obj/item/gun/kinetic))
			if(initial(W.caliber) == 1.57)
				var/picked_ammo = pick(/obj/item/ammo/bullets/autocannon, /obj/item/ammo/bullets/autocannon/knocker, /obj/item/ammo/bullets/grenade_round/explosive, /obj/item/ammo/bullets/grenade_round/high_explosive)
				new picked_ammo(get_turf(src))
				var/obj/O = picked_ammo
				boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
			else if(initial(W.caliber) == 1.58)
				new /obj/item/ammo/bullets/rpg(get_turf(src))
				boutput(user, "<span class='alert'>You get a MPRT rocket out of [src].</span>")
			qdel(src)
		else
			..()

/obj/item/ammo/ammobox/nukeop
	name = "Syndicate Ammo Bag"
	desc = "A bag that can fabricate magazines for standard syndicate weapons. Technology!"
	var/charge = 10
	var/spec_ammo = FALSE
	var/deployed = FALSE

	New()
		..()
		sleep(5)
		if(!deployed)
			src.desc = "A folded up bag that, once deployed, can fabricate magazines for standard syndicate weapons. It has [src.charge] charge left."
		else
			src.desc = "A bag that can fabricate magazines for standard syndicate weapons. Technology! It has [src.charge] charge left."

	attack_self(mob/user)
		if(!deployed)
			user.visible_message("[user] begins unfolding a [src].", "You begin unfolding a [src].")
			SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, /obj/item/ammo/ammobox/nukeop/proc/deploy_ammobag, user, src.icon, src.icon_state,"[user] finishes deploying a [src].", null)

	MouseDrop(atom/over_object, src_location, over_location, over_control, params)
		if(deployed)
			usr.visible_message("[usr] begins folding up [src].", "You begin folding up [src].")
			SETUP_GENERIC_ACTIONBAR(usr, src, 5 SECONDS, /obj/item/ammo/ammobox/nukeop/proc/fold_ammobag, usr, src.icon, src.icon_state,"[usr] finishes folding up [src].", null)


	proc/deploy_ammobag(var/mob/user)
		src.force_drop(user)
		src.anchored = TRUE
		src.deployed = TRUE

	proc/fold_ammobag(var/mob/user)
		src.anchored = FALSE
		src.deployed = FALSE
		sleep(1 DECI SECOND)
		src.Attackhand(user)

	attackby(obj/item/gun/kinetic/W, mob/user) //I detest having to do guns individually but it's for the sake of balance & special ammo types
		if(!deployed)
			boutput(user, "<span class='alert'>The [src] isn't unfolded!</span>")
			return

		if(!istype(W))
			return

		if(!ON_COOLDOWN(user, "nukeop_ammobag", 10 SECONDS))
			// Guns with special ammo types below //
			if(istype(W, /obj/item/gun/kinetic/assault_rifle))
				if(src.charge >= 2)
					var/obj/O = W.default_magazine
					if(spec_ammo)
						O = /obj/item/ammo/bullets/assault_rifle/armor_piercing
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get an [initial(O.name)] out of [src].</span>")
					else
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					if(spec_ammo && istype(O, /obj/item/ammo/bullets/assault_rifle) && !istype(O, /obj/item/ammo/bullets/assault_rifle/armor_piercing)) //pity mechanic if they get weaker ammo
						src.charge -= 1
					else
						src.charge -= 2
				else
					boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
					return

			else if(istype(W, /obj/item/gun/kinetic/spes/engineer))
				if(src.charge >= 2)
					var/obj/O = W.default_magazine
					if(spec_ammo)
						O = /obj/item/ammo/bullets/a12
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					else
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					if(spec_ammo && istype(O, /obj/item/ammo/bullets/a12/weak))
						src.charge -= 1
					else
						src.charge -= 2
				else
					boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
					return

			else if(istype(W, /obj/item/gun/kinetic/revolver))
				if(src.charge >= 2)
					var/obj/O = W.default_magazine
					if(spec_ammo)
						O = /obj/item/ammo/bullets/a357/AP
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					else
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					if(spec_ammo && istype(O, /obj/item/ammo/bullets/a357) && !istype(O, /obj/item/ammo/bullets/a357/AP))
						src.charge -= 1
					else
						src.charge -= 2
				else
					boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
					return

			else if(istype(W, /obj/item/gun/kinetic/silenced_22))
				if(src.charge >= 1)
					var/obj/O = W.default_magazine
					if(spec_ammo)
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					else
						O = /obj/item/ammo/bullets/bullet_22
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					src.charge -= 1
				else
					boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
					return

			// Guns with special ammo types above //
			else if(istype(W, /obj/item/gun/kinetic/pistol))
				if(src.charge >= 1)
					var/obj/O = W.default_magazine
					new O(get_turf(src))
					boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					src.charge -= 1
				else
					boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
					return

			else if(istype(W, /obj/item/gun/kinetic/smg) || istype(W, /obj/item/gun/kinetic/tranq_pistol) || istype(W, /obj/item/gun/kinetic/spes))
				if(src.charge >= 2)
					var/obj/O = W.default_magazine
					new O(get_turf(src))
					boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					if(spec_ammo)
						src.charge -= 1
					else
						src.charge -= 2
				else
					boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
					return

			else if(istype(W, /obj/item/gun/kinetic/light_machine_gun) || istype(W, /obj/item/gun/kinetic/sniper))
				if(src.charge >= 3)
					var/obj/O = W.default_magazine
					new O(get_turf(src))
					boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
					if(spec_ammo)
						src.charge -= 2
					else
						src.charge -= 3
				else
					boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
					return

			else if(spec_ammo) //guns that can ONLY be restocked from special ammo bags
				if(istype(W, /obj/item/gun/kinetic/grenade_launcher))
					if(src.charge >= 3)
						var/obj/O = W.default_magazine
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
						src.charge -= 3
					else
						boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
						return

				if(istype(W, /obj/item/gun/kinetic/rpg7))
					if(src.charge >= 4)
						var/obj/O = W.default_magazine
						new O(get_turf(src))
						boutput(user, "<span class='alert'>You get a [initial(O.name)] out of [src].</span>")
						src.charge -= 4
					else
						boutput(user, "<span class='alert'>The [src] doesn't have enough charge left to fabricate the ammo for [W]!</span>")
						return
			else
				..()

			src.desc = "A bag that can fabricate magazines for standard syndicate weapons. Technology! It has [src.charge] charge left."
			if(src.charge <= 0)
				qdel(src)


/obj/item/ammo/ammobox/nukeop/spec_ammo
	name = "Syndicate Specialist Ammo Bag"
	desc = "A bag that can fabricate specialist magazines for standard syndicate weapons. Technology!"
	spec_ammo = TRUE

	New()
		..()
		sleep(5)
		src.desc = "A bag that can fabricate specialist magazines for standard syndicate weapons. Technology! It has [src.charge] charge left."

