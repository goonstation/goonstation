/*
	Made by Firebarrage, who has never actually played a battle royale and is basing this on what he knows from memes
*/

var/global/area/current_battle_spawn = null
var/global/list/datum/mind/battle_pass_holders = list()

#define TIME_BETWEEN_SHUTTLE_MOVES 5 SECONDS
#define MAX_TIME_ON_SHUTTLE 60 SECONDS
#define MIN_TIME_BETWEEN_STORMS 240 SECONDS
#define MAX_TIME_BETWEEN_STORMS 480 SECONDS
#define MIN_TIME_BETWEEN_SUPPLY_DROPS 60 SECONDS
#define MAX_TIME_BETWEEN_SUPPLY_DROPS 180 SECONDS


/datum/game_mode/battle_royale
	name = "Battle Royale"
	config_tag = "battle_royale"
	var/list/drop_locations = list()
	var/list/datum/mind/living_battlers = list()
	var/last_shuttle_move = 0
	var/next_storm = 0
	var/next_drop = 0
	var/current_battle_spawn_name = null
	var/damage_tick = 0	// Don't cause off Z1 damage every tick
	var/list/area/excluded_areas = list(/area/shuttle/battle, /area/shuttle/escape/transit, /area/shuttle_transit_space)
	var/datum/random_event/special/battlestorm/storm = null
	var/datum/random_event/special/supplydrop/dropper = null
	var/list/datum/mind/recently_deceased = list()
	do_antag_random_spawns = 0

/datum/game_mode/battle_royale/announce()
	boutput(world, "<B>The current game mode is - Battle Royale!</B>")
	boutput(world, "<B>You are approaching [station_name(1)] in the Battle Shuttle! Jump out of the ship to land on the station!</B>")

/datum/game_mode/battle_royale/pre_setup()
	// EVERYONE IS A BATTLER
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (player.ready)
			src.traitors.Add(player)
			if(player.mind)
				player.mind.assigned_role = "MODE"
				player.mind.special_role = ROLE_BATTLER
				living_battlers.Add(player.mind)

	for (var/turf/space/space in world)
		LAGCHECK(LAG_LOW)
		if(space.icon_state != "darkvoid")
			space.icon_state = "darkvoid"
			space.icon = 'icons/turf/floors.dmi'
			space.name = "void"

	storm = new /datum/random_event/special/battlestorm()
	dropper = new/datum/random_event/special/supplydrop()

	// The places the battle shuttle can take you.
	drop_locations = get_accessible_station_areas()
	/*
	drop_locations = list("security" = /area/station/security,\
	"science wing" = /area/station/science,\
		"the cargo bay" = /area/station/quartermaster/office,\
		"engineering" = /area/station/engine,\
		"medbay" = /area/station/medical,\
		"the cafeteria" = /area/station/crew_quarters/cafeteria,\
		"the chapel" = /area/station/chapel,\
		"hydroponics" = /area/station/hydroponics,\
		"the bridge" = /area/station/bridge)*/

	current_battle_spawn_name = pick(drop_locations)
	current_battle_spawn = drop_locations[current_battle_spawn_name]

	// Remove monkeys
	for (var/mob/M in world)
		var/turf/T = get_turf(M)
		if (!T)
			continue
		if (T.z != Z_LEVEL_STATION)
			continue
		if (isnpcmonkey(M))
			qdel(M)

	for_by_tcl(SV, /obj/submachine)
		if (istype(SV, /obj/submachine/weapon_vendor/security))
			qdel(SV)

	for_by_tcl(MAC, /obj/machinery)
		var/mac_type = MAC.type
		switch (mac_type)
			if (/obj/machinery/clone_scanner)
				qdel(MAC)
			if (/obj/machinery/vending/monkey)
				qdel(MAC)
			if (/obj/machinery/vending/security)
				qdel(MAC)
			if (/obj/machinery/vending/mechanics)
				qdel(MAC)
			if (/obj/machinery/computer/supplycomp)
				qdel(MAC)
			if (/obj/machinery/lrteleporter)
				qdel(MAC)
			if (/obj/machinery/networked/telepad)
				qdel(MAC)
			if (/obj/machinery/portable_atmospherics/canister/sleeping_agent)
				qdel(MAC)
			if (/obj/machinery/portable_atmospherics/canister/toxins)
				qdel(MAC)

	hide_weapons_everywhere(length(living_battlers))
	next_storm = world.time + rand(MIN_TIME_BETWEEN_STORMS,MAX_TIME_BETWEEN_STORMS)
	next_drop = world.time + rand(MIN_TIME_BETWEEN_SUPPLY_DROPS,MAX_TIME_BETWEEN_SUPPLY_DROPS)

	ticker.ai_law_rack_manager.default_ai_rack.DeleteAllLaws()
	ticker.ai_law_rack_manager.default_ai_rack.SetLawCustom("Battle Royale","BR Protocol in effect. Observe the effects of the BR Mind Control Program, do not interfere.",1,true,true)


	emergency_shuttle.disabled = 1
	return 1


	// Things we are skipping:
	// Antag selection. Everyone is an antag!
	// Antag weighting. We dont record this - otherwise playing this round would fuck your weighting chances


/datum/game_mode/battle_royale/post_setup()
	for(var/datum/mind/player in src.living_battlers)
		battle_shuttle_spawn(player)

/datum/game_mode/battle_royale/proc/battle_shuttle_spawn(var/datum/mind/player)
	bestow_objective(player,/datum/objective/battle_royale/win)
	boutput(player.current, "<B>Objective</B>: Defeat all other battlers!")
		// Stuff them on the shuttle
	player.current.set_loc(pick_landmark(LANDMARK_BATTLE_ROYALE_SPAWN))
	equip_battler(player.current)
	if (ishuman(player.current))
		var/mob/living/carbon/human/H = player.current
		H.AddComponent(/datum/component/battleroyale_death)
	SPAWN(MAX_TIME_ON_SHUTTLE)
		if(istype(get_area(player.current),/area/shuttle/battle) || istype(get_area(player.current),/area/shuttle_transit_space/west) )
			boutput(player.current,"<span class='alert'>You are thrown out of the shuttle for taking too long!</span>")
			var/list/found_areas = get_area_turfs(current_battle_spawn,1)
			if (isnull(found_areas))
				player.current.set_loc(pick(get_area_turfs(/area/station/maintenance/,1)))
			else
				player.current.set_loc(pick(found_areas))
			player.current.removeOverlayComposition(/datum/overlayComposition/shuttle_warp)
			player.current.removeOverlayComposition(/datum/overlayComposition/shuttle_warp/ew)
	SHOW_BATTLE_ROYALE_TIPS(player.current)


/datum/game_mode/battle_royale/check_finished()
	var/someone_died = 0
	for(var/datum/mind/M in living_battlers)
		if(isdead(M.current) || !ishuman(M.current) || inafterlife(M.current) || isVRghost(M.current))
			living_battlers.Remove(M)
			DEBUG_MESSAGE("[M.current.name] died. There are [living_battlers.len] left!")
			recently_deceased.Add(M)
			someone_died++
	if(someone_died && living_battlers.len <= 5)
		command_alert("[living_battlers.len] battlers remain!","BATTLE STATUS ANNOUNCEMENT")
	else if(someone_died && living_battlers.len % 10 == 0)
		command_alert("[living_battlers.len] battlers remain!","BATTLE STATUS ANNOUNCEMENT")
	if(living_battlers.len <= 1)
		return TRUE
	return FALSE


/datum/game_mode/battle_royale/declare_completion()
	boutput(world,"<h2>BATTLE COMPLETE</h2>")
	if(living_battlers.len == 1)
		boutput(world,"<h2 class='alert'>[living_battlers[1].current.name] (played by [living_battlers[1].current.ckey]) has won!</h2>")
		boutput(living_battlers[1].current,"<h1 class='notice'>Holy shit you won!!!</h1>")
	else
		boutput(world,"<h2 class='alert'>Literally everyone died. wow.</h2>")



/datum/game_mode/battle_royale/process()
	..()
	// Does the shuttle need to move? if so move it
	if(src.last_shuttle_move + TIME_BETWEEN_SHUTTLE_MOVES < world.time)
		src.last_shuttle_move = world.time
		current_battle_spawn_name = pick(drop_locations)
		current_battle_spawn = drop_locations[current_battle_spawn_name]
		// oh and tell anyone on the shuttle it moved I guess
		for(var/client/C)
			if (C.mob)
				if(istype(get_area(C.mob),/area/shuttle/battle))
					boutput(C.mob, "<span class='notice'>The battle shuttle is now flying over [current_battle_spawn_name]!</span>")

	// Check for players outside Z1
	damage_tick++
	if (damage_tick > 9)
		damage_tick = 0
		if (world.time > MAX_TIME_ON_SHUTTLE)
			for(var/datum/mind/M in living_battlers)
				if (ishuman(M.current))
					var/mob/living/carbon/human/H = M.current
					var/turf/T = get_turf(H)
					if (T.z != Z_LEVEL_STATION)
						var/area/GA = get_area(T)
						var/no_tick_damage = FALSE
						for (var/EA in excluded_areas)
							if(istype(GA, EA))
								no_tick_damage = TRUE
								break
						if (!no_tick_damage)
							boutput(H, "<span class='alert'>You are outside the battle area! Return to the station!</span>")
							random_brute_damage(H, 8, 0)

	// Is it time for a storm
	if(src.next_storm < world.time)
		src.next_storm = world.time + rand(MIN_TIME_BETWEEN_STORMS,MAX_TIME_BETWEEN_STORMS)
		storm.event_effect()
		SPAWN(85 SECONDS)
			var/you_died_good_work = recently_deceased.len > 0 ? "The following players recently died: " : ""
			for(var/datum/mind/M in recently_deceased)
				you_died_good_work += " [M.current.name],"
			recently_deceased = list()
			command_alert("The BATTLE STORM has ended. You can run around wherever now. [you_died_good_work]", "All Clear")

	// Is it time for a supply drop?
	if(src.next_drop < world.time)
		next_drop = world.time + rand(MIN_TIME_BETWEEN_SUPPLY_DROPS,MAX_TIME_BETWEEN_SUPPLY_DROPS)
		SPAWN(0) dropper.event_effect("Gamemode", drop_locations[pick(drop_locations)])


// Does what it says on the tin
proc/hide_weapons_everywhere(var/total_battlers = 1)
	boutput(world, "<span class='notice'>Now hiding a shitton of goodies on the [station_or_ship()]. Please be patient!</span>")
	// Replace all lockers with generic syndicate to clear out junk items, remove sec lockers so it's not too much of a hot spot
	// Im stealing the list of items from the surplus crate so this check needs to happen
	if(!syndi_buylist_cache)
		build_syndi_buylist_cache()

	var/list/obj/murder_supplies = list()
	var/list/banned_items = list(/datum/syndicate_buylist/traitor/classcrate,
	/datum/syndicate_buylist/traitor/surplus,
	/datum/syndicate_buylist/traitor/floorcloset,
	/datum/syndicate_buylist/traitor/wiretap,
	/datum/syndicate_buylist/traitor/buddy_ammofab,
	/datum/syndicate_buylist/traitor/chargehacker,
	/datum/syndicate_buylist/generic/psink,
	/datum/syndicate_buylist/traitor/shotglass,
	/datum/syndicate_buylist/generic/chamsuit,
	/datum/syndicate_buylist/generic/telecrystal,
	/datum/syndicate_buylist/generic/trick_telecrystal,
	/datum/syndicate_buylist/traitor/idtracker,
	/datum/syndicate_buylist/traitor/mindslave,
	/datum/syndicate_buylist/traitor/deluxe_mindslave,
	/datum/syndicate_buylist/generic/detomatix,
	/datum/syndicate_buylist/generic/spy_sticker_kit,
	/datum/syndicate_buylist/traitor/ringtone,
	/datum/syndicate_buylist/traitor/sinjector,
	/datum/syndicate_buylist/traitor/minibible,
	/datum/syndicate_buylist/traitor/contract,
	/datum/syndicate_buylist/traitor/maneater,
	/datum/syndicate_buylist/traitor/hotbox_lighter,
	/datum/syndicate_buylist/traitor/syndanalyser,
	/datum/syndicate_buylist/traitor/powergloves,
	/datum/syndicate_buylist/traitor/chemicompiler,
	/datum/syndicate_buylist/traitor/robosuit,
	/datum/syndicate_buylist/traitor/conversion_chamber,
	/datum/syndicate_buylist/traitor/telegun,
	/datum/syndicate_buylist/traitor/mindslave_module,
	/datum/syndicate_buylist/traitor/deluxe_mindslave_module,
	/datum/syndicate_buylist/surplus/cybereye_kit_sechud,
	/datum/syndicate_buylist/generic/head_rev/revflash,
	/datum/syndicate_buylist/generic/head_rev/revflashbang,
	/datum/syndicate_buylist/generic/head_rev/revsign,
	/datum/syndicate_buylist/generic/head_rev/rev_normal_flash,
	/datum/syndicate_buylist/traitor/kudzuseed,
	/datum/syndicate_buylist/traitor/moonshine)

	for(var/datum/syndicate_buylist/D in syndi_buylist_cache)
		if(D.item)
			var/add_item = TRUE
			for (var/B in banned_items)
				if (istype(D, B))
					add_item = FALSE
					break
			if (add_item)
				murder_supplies.Add(D.item)

	var/list/chest_supplies = list()
	// Feel free to add more!
	chest_supplies.Add(/obj/item/gun/kinetic/light_machine_gun)
	chest_supplies.Add(/obj/item/gun/kinetic/assault_rifle)
	chest_supplies.Add(/obj/item/gun/kinetic/pistol)
	chest_supplies.Add(/obj/item/gun/kinetic/detectiverevolver)
	chest_supplies.Add(/obj/item/gun/kinetic/colt_saa)
	chest_supplies.Add(/obj/item/gun/kinetic/riotgun)
	chest_supplies.Add(/obj/item/gun/kinetic/airzooka)
	chest_supplies.Add(/obj/item/gun/energy/laser_gun)
	chest_supplies.Add(/obj/item/gun/energy/alastor)
	chest_supplies.Add(/obj/item/gun/energy/pulse_rifle)
	chest_supplies.Add(/obj/item/bat)
	chest_supplies.Add(/obj/item/ratstick)
	chest_supplies.Add(/obj/item/sword/discount)
	chest_supplies.Add(/obj/item/nunchucks)
	chest_supplies.Add(/obj/item/quarterstaff)
	chest_supplies.Add(/obj/item/knife/butcher/hunterspear)
	chest_supplies.Add(/obj/item/fireaxe)
	chest_supplies.Add(/obj/item/katana/reverse)
	chest_supplies.Add(/obj/item/katana_sheath/captain)
	chest_supplies.Add(/obj/item/katana_sheath/nukeop)
	chest_supplies.Add(/obj/item/clothing/shoes/swat)
	chest_supplies.Add(/obj/item/clothing/shoes/swat/heavy)
	chest_supplies.Add(/obj/item/clothing/shoes/galoshes)
	chest_supplies.Add(/obj/item/clothing/suit/armor/vest)
	chest_supplies.Add(/obj/item/clothing/suit/armor/NT)
	chest_supplies.Add(/obj/item/clothing/suit/armor/NT_alt)
	chest_supplies.Add(/obj/item/clothing/suit/armor/EOD)
	chest_supplies.Add(/obj/item/clothing/suit/armor/hoscape)
	chest_supplies.Add(/obj/item/clothing/suit/armor/heavy)
	chest_supplies.Add(/obj/item/clothing/suit/armor/centcomm)
	chest_supplies.Add(/obj/item/clothing/suit/armor/centcommcoat)
	chest_supplies.Add(/obj/item/clothing/suit/armor/captain)
	chest_supplies.Add(/obj/item/clothing/suit/armor/makeshift)
	chest_supplies.Add(/obj/item/clothing/suit/armor/batman)
	chest_supplies.Add(/obj/item/clothing/suit/armor/football)
	chest_supplies.Add(/obj/item/clothing/head/helmet/hardhat/security)
	chest_supplies.Add(/obj/item/clothing/head/helmet/hardhat/security/improved)
	chest_supplies.Add(/obj/item/clothing/head/helmet/swat)
	chest_supplies.Add(/obj/item/clothing/head/helmet/space/syndicate/specialist)
	chest_supplies.Add(/obj/item/clothing/head/helmet/space/syndicate/specialist/knight)
	chest_supplies.Add(/obj/item/clothing/head/helmet/space/syndicate/commissar_cap)
	chest_supplies.Add(/obj/item/clothing/head/helmet/space/ntso)
	chest_supplies.Add(/obj/item/clothing/head/helmet/space/nanotrasen)
	chest_supplies.Add(/obj/item/clothing/head/helmet/viking)
	chest_supplies.Add(/obj/item/clothing/head/helmet/football)
	chest_supplies.Add(/obj/item/clothing/head/helmet/batman)

	var/total_storage
	switch(total_battlers)
		if(100 to 999)
			total_storage = 0.1
		if(70 to 99)
			total_storage = 0.2
		if(50 to 69)
			total_storage = 0.3
		if(0 to 49)
			total_storage = 0.4

	var/total_utility
	for_by_tcl(S, /obj/storage)
		var/turf/T = get_turf(S)
		if (T.z != Z_LEVEL_STATION)
			continue
		if (istype(S, /obj/storage/secure/closet) || istype(S, /obj/storage/closet) || istype(S, /obj/storage/crate) || istype(S, /obj/storage/cart))
			qdel(S)
			var/rand_storage = rand()
			if (rand_storage <= total_storage)
				if (total_utility < 30)
					if (prob((100 - ((total_storage + 0.1) * 100))))
						total_utility++
						if (prob(50))
							new /obj/storage/closet/emergency(T)
						else
							new /obj/storage/closet/fire(T)
				else
					continue
			else
				if (prob(50))
					var/obj/storage/closet/locker = new /obj/storage/closet/syndicate(T)
					var/obj/weapon = pick(murder_supplies)
					new weapon(locker)
				else
					var/obj/storage/crate/chest/chest = new /obj/storage/crate/chest(T)
					var/obj/weapon = pick(chest_supplies)
					new weapon(chest)

proc/equip_battler(mob/living/carbon/human/battler)
	if (!ishuman(battler))
		return

	battler.equip_if_possible(new /obj/item/device/radio/headset(battler), battler.slot_ears)

	// Battle royale crewmembers are rainbow flavored
	var/obj/item/clothing/under/jumpsuit = null
	var/suit_type = pick(
		/obj/item/clothing/under/gimmick/macho,
		/obj/item/clothing/under/gimmick/bowling,
		/obj/item/clothing/under/gimmick/hunter,
		/obj/item/clothing/under/gimmick/owl,
		/obj/item/clothing/under/gimmick/waldo,
		/obj/item/clothing/under/gimmick/odlaw,
		/obj/item/clothing/under/gimmick/fake_waldo,
		/obj/item/clothing/under/gimmick/johnny,
		/obj/item/clothing/under/gimmick/police,
		/obj/item/clothing/under/gimmick/blackstronaut,
		/obj/item/clothing/under/gimmick/duke,
		/obj/item/clothing/under/gimmick/mj_clothes,
		/obj/item/clothing/under/gimmick/viking,
		/obj/item/clothing/under/gimmick/merchant,
		/obj/item/clothing/under/gimmick/spiderman,
		/obj/item/clothing/under/gimmick/birdman,
		/obj/item/clothing/under/gimmick/dawson,
		/obj/item/clothing/under/gimmick/chav,
		/obj/item/clothing/under/gimmick/safari,
		/obj/item/clothing/under/gimmick/utena,
		/obj/item/clothing/under/gimmick/anthy,
		/obj/item/clothing/under/gimmick/butler,
		/obj/item/clothing/under/gimmick/maid,
		/obj/item/clothing/under/gimmick/kilt,
		/obj/item/clothing/under/gimmick/wedding_dress,
		/obj/item/clothing/under/gimmick/psyche,
		/obj/item/clothing/under/gimmick/dolan,
		/obj/item/clothing/under/gimmick/jetson,
		/obj/item/clothing/under/gimmick/princess,
		/obj/item/clothing/under/gimmick/chaps,
		/obj/item/clothing/under/gimmick/vault13,
		/obj/item/clothing/under/gimmick/murph,
		/obj/item/clothing/under/gimmick/sealab,
		/obj/item/clothing/under/gimmick/rainbow,
		/obj/item/clothing/under/gimmick/yay,
		/obj/item/clothing/under/gimmick/cloud,
		/obj/item/clothing/under/gimmick/mario/luigi,
		/obj/item/clothing/under/gimmick/mario/wario,
		/obj/item/clothing/under/gimmick/mario/waluigi,
		/obj/item/clothing/under/gimmick/mario,
		/obj/item/clothing/under/gimmick/shirtnjeans,
		/obj/item/clothing/under/gimmick/hakama/random)
	jumpsuit = new suit_type(battler)
	battler.equip_if_possible(jumpsuit, battler.slot_w_uniform)
	battler.equip_if_possible(new /obj/item/clothing/shoes/swat(battler), battler.slot_shoes)
	battler.equip_if_possible(new /obj/item/storage/backpack(battler), battler.slot_back)
	battler.equip_if_possible(new /obj/item/reagent_containers/food/snacks/donkpocket_w(battler), battler.slot_l_store)
	battler.equip_if_possible(new /obj/item/reagent_containers/food/snacks/donkpocket_w(battler), battler.slot_r_store)

	var/obj/item/card/id/captains_spare/I = new /obj/item/card/id/captains_spare // for whatever reason, this is neccessary
	I.registered = "[battler.name]"
	I.assignment = "Battler"
	I.icon_state = "gold"
	I.icon = 'icons/obj/items/card.dmi'
	battler.equip_if_possible(I, battler.slot_wear_id)
	//battler.Equip_Bank_Purchase(battler.mind.purchased_bank_item)
	battler.set_clothing_icon_dirty()

//returns a list of all areas on a station
// Maybe nuclear could use this in the future???
proc/get_accessible_station_areas()
	if(global.station_areas && global.area_list_is_up_to_date) // In case someone makes a new area
		return global.station_areas
	// All areas
	var/list/L = list()
	for_by_tcl(AR, /area/station)
		for(var/turf/T in AR)
			if(!isfloor(T) && is_blocked_turf(T) && istype(T,/area/sim/test_area) && T.z == 1)
				continue
			L[AR.name] = AR
	global.area_list_is_up_to_date = 1
	global.station_areas = L
	return L
