/obj/item/device/deployment_remote
	name = "Rapid Deployment Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A remote used to signal a place for a set of rapid-troop-deployment personnel missile pods to land."
	icon_state = "satcom"
	item_state = "electronic"
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
			boutput(user, SPAN_ALERT("The [src] has been used up!"))
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
						boutput(user, SPAN_ALERT("You can only deploy from the Cairngorm or Listening Post!"))
						return
					var/list/chosen_mobs = list()
					var/is_the_nuke_there = FALSE
					for(var/mob/living/carbon/found_mob in range(4, user.loc))
						chosen_mobs += found_mob
					for(var/obj/machinery/nuclearbomb/the_nuke in range(4, user.loc))
						is_the_nuke_there = TRUE
						break
					if(!length(overlayed_turfs))
						for(var/turf/T in range(4, user.loc))
							if(!isfloor(T))
								continue
							overlayed_turfs += T
							T.overlays += valid_overlay_area
					SPAWN(5 SECONDS)
						for(var/turf/T in overlayed_turfs)
							T.overlays -= valid_overlay_area
					var/confirmation = input(user, "Are you sure you would like to deploy? [length(chosen_mobs) <= 1 ? (is_the_nuke_there ? "You're currently alone!" : "You don't have the nuke nearby, in addition to you being alone!") : (is_the_nuke_there ? "You have [length(chosen_mobs)] who will deploy with you." : "The nuke isn't close enough to come with you!")]") in list("Yes", "No")
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


	proc/choose_area(mob/user)
		var/temp_people_count = 10 //sanity check to make sure there's enough turfs to land on
		var/list/area/filtered_areas = get_nukie_deployment_areas()
		var/list/turf/check_turfs = list()
		for(var/mob/living/carbon/people_nearby in range(4, user.loc))
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

	proc/send_to_pod(mob/user)
		for(var/mob/living/carbon/M in range(4, user.loc))
			SPAWN(0)
				var/L = pick_landmark(LANDMARK_SYNDICATE_ASSAULT_POD_TELE)
				if(!L) //fuck
					return
				for(var/obj/item/remote/syndicate_teleporter/T in M.get_all_items_on_mob())
					qdel(T) //Emphasizing that there really is no easy way back if you go this way
				playsound(M, 'sound/effects/teleport.ogg', 30, TRUE)
				var/obj/decal/teleport_swirl/S = new/obj/decal/teleport_swirl(M)
				M.set_loc(L)
				var/obj/decal/residual_energy/R = new/obj/decal/residual_energy(L)
				playsound(L, 'sound/effects/teleport.ogg', 30, TRUE)
				SPAWN(1 SECOND)
					qdel(S)
					qdel(R)
			sent_mobs += M
		for(var/obj/machinery/nuclearbomb/the_nuke in range(4, user.loc))
			SPAWN(0)
				var/landmark_teleport = pick_landmark(LANDMARK_SYNDICATE_ASSAULT_POD_TELE)
				if(!landmark_teleport)
					return
				playsound(the_nuke, 'sound/effects/teleport.ogg', 30, TRUE)
				var/obj/decal/teleport_swirl/tele_swirl = new/obj/decal/teleport_swirl(the_nuke)
				the_nuke.set_loc(landmark_teleport)
				var/obj/decal/residual_energy/tele_energy = new/obj/decal/residual_energy(landmark_teleport)
				playsound(landmark_teleport, 'sound/effects/teleport.ogg', 30, TRUE)
				SPAWN(1 SECOND)
					qdel(tele_swirl)
					qdel(tele_energy)
			nuclear_bombs += the_nuke
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
					L.changeStatus("knockdown", 2 SECONDS)
			var/num_players = 0
			for(var/client/C)
				var/mob/new_player/player = C.mob
				if (!istype(player))
					continue
				if(player.ready)
					num_players++
			if (num_players <= 70)
				command_alert("A Syndicate Assault pod is heading towards [station_name], be on high alert.", "Central Command Alert", 'sound/misc/announcement_1.ogg')
			sleep(rand_time / 2)
			command_alert("Our sensors have determined the Syndicate Assault pod is headed towards the [src.landing_area], a response would be advised.", "Central Command Alert", 'sound/misc/announcement_1.ogg')
			sleep(rand_time / 2)
			send_pods()

	proc/send_pods()
		var/list/turf/possible_turfs = list()
		for(var/turf/T in get_area_turfs(src.landing_area, TRUE))
			possible_turfs += T
		for(var/obj/machinery/nuclearbomb/the_nuke in nuclear_bombs)
			var/turf/picked_turf = pick(possible_turfs)
			SPAWN(0)
				launch_with_missile(the_nuke, picked_turf, null, "arrival_missile_synd")
			possible_turfs -= picked_turf
		for(var/mob/living/carbon/C in sent_mobs)
			var/turf/picked_turf = pick(possible_turfs)
			SPAWN(0)
				launch_with_missile(C, picked_turf, null, "arrival_missile_synd")
			possible_turfs -= picked_turf
			if(!length(possible_turfs))
				src.visible_message(SPAN_ALERT("The [src] makes a grumpy beep, it seems not everyone could be sent!"))
				break
		command_alert("A [length(sent_mobs) > 1 ? "group of [length(sent_mobs)] personnel missiles have" : "single personnel missile has"] been spotted launching from a Syndicate Assault pod towards the [src.landing_area], be prepared for heavy contact.","Central Command Alert", 'sound/misc/announcement_1.ogg')
		qdel(src)

/obj/machinery/computer/security/pod_timer
	maptext_x = 0
	maptext_y = 20
	maptext_width = 64
	var/total_pod_time = null
	processing_tier = PROCESSING_QUARTER

	proc/get_pod_timer()
		if(isnull(total_pod_time))
			return "--:--"
		var/timeleft = round((total_pod_time - TIME) / 10, 1)
		timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
		return timeleft

	process()
		if (total_pod_time && TIME >= total_pod_time)
			src.maptext = "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">--:--</span>"
		else
			src.maptext = "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">[get_pod_timer()]</span>"
		..()
