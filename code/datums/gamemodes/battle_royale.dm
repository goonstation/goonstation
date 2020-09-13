/*
	Made by Firebarrage, who has never actually played a battle royale and is basing this on what he knows from memes
*/

var/global/area/current_battle_spawn = null
var/global/list/datum/mind/battle_pass_holders = list()

#define TIME_BETWEEN_SHUTTLE_MOVES 50
#define MAX_TIME_ON_SHUTTLE 1 * 60 * 10
#define MIN_TIME_BETWEEN_STORMS 4 * 60 * 10
#define MAX_TIME_BETWEEN_STORMS 8 * 60 * 10
#define MIN_TIME_BETWEEN_SUPPLY_DROPS 1 * 60 * 10
#define MAX_TIME_BETWEEN_SUPPLY_DROPS 3 * 60 * 10


/datum/game_mode/battle_royale
	name = "Battle Royale"
	config_tag = "battle_royale"
	var/list/drop_locations = list()
	var/list/datum/mind/living_battlers = list()
	var/last_shuttle_move = 0
	var/next_storm = 0
	var/next_drop = 0
	var/current_battle_spawn_name = "nowhere!"
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
				player.mind.special_role = "battler"
				living_battlers.Add(player.mind)

	storm = new /datum/random_event/special/battlestorm()
	dropper = new/datum/random_event/special/supplydrop()

	// The places the battle shuttle can take you.
	drop_locations = get_accessible_station_areas()
	/*
	drop_locations = list("security" = /area/station/security,\
	"science wing" = /area/station/science,\
		"the cargo bay" = /area/station/quartermaster,\
		"engineering" = /area/station/engine,\
		"medbay" = /area/station/medical,\
		"the cafeteria" = /area/station/crew_quarters/cafeteria,\
		"the chapel" = /area/station/chapel,\
		"hydroponics" = /area/station/hydroponics,\
		"the bridge" = /area/station/bridge)*/

	current_battle_spawn_name = pick(drop_locations)
	current_battle_spawn = drop_locations[current_battle_spawn_name]


	hide_weapons_everywhere()
	next_storm = world.time + rand(MIN_TIME_BETWEEN_STORMS,MAX_TIME_BETWEEN_STORMS)
	next_drop = world.time + rand(MIN_TIME_BETWEEN_SUPPLY_DROPS,MAX_TIME_BETWEEN_SUPPLY_DROPS)
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
	player.current.nodamage = 1 // No murder on the battle shuttle
		// Stuff them on the shuttle
	player.current.set_loc(pick_landmark(LANDMARK_BATTLE_ROYALE_SPAWN))
	equip_battler(player.current)
	SPAWN_DBG(MAX_TIME_ON_SHUTTLE)
		if(istype(get_area(player.current),/area/shuttle/escape/transit/battle_shuttle))
			boutput(player.current,"<span class='alert'>You are thrown out of the shuttle for taking too long!</span>")
			player.current.set_loc(pick(get_area_turfs(current_battle_spawn,1)))
			player.current.nodamage = 0
			player.current.removeOverlayComposition(/datum/overlayComposition/shuttle_warp)
			player.current.removeOverlayComposition(/datum/overlayComposition/shuttle_warp/ew)
	SHOW_BATTLE_ROYALE_TIPS(player.current)


/datum/game_mode/battle_royale/check_finished()
	var/someone_died = 0
	for(var/datum/mind/M in living_battlers)
		if(isdead(M.current) || issilicon(M.current) || isobserver(M.current) || inafterlife(M.current) || isVRghost(M.current))
			living_battlers.Remove(M)
			DEBUG_MESSAGE("[M.current.name] died. There are [living_battlers.len] left!")
			recently_deceased.Add(M)
			someone_died++
	if(someone_died && living_battlers.len <= 5)
		command_alert("[living_battlers.len] battlers remain!","BATTLE STATUS ANNOUNCEMENT")
	else if(someone_died && living_battlers.len % 10 == 0)
		command_alert("[living_battlers.len] battlers remain!","BATTLE STATUS ANNOUNCEMENT")
	if(living_battlers.len <= 1)
		return 1
	return 0


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
				if(istype(get_area(C.mob),/area/shuttle/escape/transit/battle_shuttle))
					boutput(C.mob, "<span class='notice'>The battle shuttle is now flying over [current_battle_spawn_name]!</span>")

	// Is it time for a storm
	if(src.next_storm < world.time)
		src.next_storm = world.time + rand(MIN_TIME_BETWEEN_STORMS,MAX_TIME_BETWEEN_STORMS)
		SPAWN_DBG(storm.event_effect())
			var/you_died_good_work = recently_deceased.len > 0 ? "The following players recently died: " : ""
			for(var/datum/mind/M in recently_deceased)
				you_died_good_work += " [M.current.name],"
			recently_deceased = list()
			command_alert("The BATTLE STORM has ended. You can run around wherever now. [you_died_good_work]", "All Clear")

	// Is it time for a supply drop?
	if(src.next_drop < world.time)
		next_drop = world.time + rand(MIN_TIME_BETWEEN_SUPPLY_DROPS,MAX_TIME_BETWEEN_SUPPLY_DROPS)
		SPAWN_DBG(0) dropper.event_effect("Gamemode", drop_locations[pick(drop_locations)])


// Does what it says on the tin
proc/hide_weapons_everywhere()
	boutput(world, "<span class='notice'>Now hiding a shitton of goodies on the [station_or_ship()]. Please be patient!</span>")
	// Im stealing the list of items from the surplus crate so this check needs to happen
	if(!syndi_buylist_cache)
		build_syndi_buylist_cache()

	var/list/obj/murder_supplies = list()
	var/obj/weapon = null
	for(var/datum/syndicate_buylist/D in syndi_buylist_cache)
		if(D.item && !istype(D,/datum/syndicate_buylist/traitor/classcrate))
			murder_supplies.Add(D.item)


	// Feel free to add more!
	murder_supplies.Add(/obj/item/gun/kinetic/light_machine_gun)
	murder_supplies.Add(/obj/item/gun/kinetic/assault_rifle)
	murder_supplies.Add(/obj/item/gun/kinetic/pistol)


	for(var/obj/O in by_type[/obj/storage]) // imcoder
		if(prob(33))
			weapon = pick(murder_supplies)
			new weapon(O)
	return



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
	// All areas
	var/list/L = list()
	var/list/areas = childrentypesof(/area/station)
	for(var/A in areas)
		var/area/instance = locate(A)
		for(var/turf/T in instance)
			if(!isfloor(T) && is_blocked_turf(T) && istype(T,/area/station/test_area) && T.z == 1)
				continue
			L[instance.name] = instance
	return L
