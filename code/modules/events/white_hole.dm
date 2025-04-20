#define VALID_WHITE_HOLE_LOCATIONS list("artlab", "teg", "flock", "chapel", "trench", "asteroid", \
	"cafeteria", "singulo", "plasma", "nukies", "hell", "botany", "maint", "ai", "bridge", "clown", \
	"medbay", "security", "cargo", "nuclear", "janitorial", "wizard", "spacemas")

TYPEINFO(/datum/random_event/major/white_hole)
	initialization_args = list(
		EVENT_INFO("target_turf", DATA_INPUT_REFPICKER, "Pick location"),
		EVENT_INFO_EXT("grow_duration", DATA_INPUT_NUM, "White Hole Growth Time", 0, 1 HOUR),
		EVENT_INFO_EXT("duration", DATA_INPUT_NUM, "White Hole Duration", 0, 1 HOUR),
		EVENT_INFO_EXT("activity_modifier", DATA_INPUT_NUM, "White Hole Activity Modifier", 0, 250),
		EVENT_INFO_EXT("source_location", DATA_INPUT_LIST_PROVIDED, "Pick source location", VALID_WHITE_HOLE_LOCATIONS)
	)


/datum/random_event/major/white_hole
	name = "White Hole"
	required_elapsed_round_time = 20 MINUTES
	customization_available = TRUE

	var/turf/target_turf
	var/grow_duration = 2 MINUTES
	var/duration = 40 SECONDS
	var/source_location
	var/activity_modifier = 1

	admin_call(source)
		if (..())
			return

		var/datum/random_event_editor/E = new /datum/random_event_editor(usr, src)
		if(E)
			E.ui_interact(usr)
		else
			switch(tgui_alert(usr, "Do you want to pick white hole location?", "Pick location", list("Pick", "Random", "Cancel")))
				if("Pick")
					target_turf = get_turf(pick_ref(usr))
					if(isnull(target_turf))
						boutput(usr, SPAN_ALERT("Cancelled. You must select a turf."))
						return
				if("Random")
					target_turf = null
				if("Cancel")
					boutput(usr, SPAN_ALERT("Cancelled."))
					return

			grow_duration = tgui_input_number(usr, "How long should it take for the white hole to grow?", "White Hole Growth Time", 2 MINUTES, 1 HOUR, 0)
			if(isnull(grow_duration))
				boutput(usr, SPAN_ALERT("Cancelled."))
				return

			duration = tgui_input_number(usr, "How long should the white hole be active?", "White Hole Duration", 40 SECONDS, 1 HOUR, 0)
			if(isnull(duration))
				boutput(usr, SPAN_ALERT("Cancelled."))
				return

			source_location = null
			switch(tgui_alert(usr, "Do you want to pick white hole source location?", "Pick source location", list("Pick", "Random", "Cancel")))
				if("Pick")
					source_location = tgui_input_list(usr, "Which white hole source location?", "White Hole Source Location", VALID_WHITE_HOLE_LOCATIONS)
				if("Random")
					source_location = null
				if("Cancel")
					boutput(usr, SPAN_ALERT("Cancelled."))
					return

			activity_modifier = tgui_input_number(usr, "How much should the white hole activity be modified?", "White Hole Activity Modifier", 1, 10, 0, round_input=FALSE)

			src.event_effect(source, target_turf, grow_duration, duration, source_location, activity_modifier)

	event_effect(source)
		..()
		var/turf/T = target_turf
		if (isatom(T))
			T = get_turf(target_turf)
		if (!istype(T,/turf/))
			if(isnull(random_floor_turfs))
				build_random_floor_turf_list()
			while(isnull(T) || istype(T, /turf/simulated/floor/airless/plating/catwalk) || total_density(T) > 0 || !istype(T.loc, /area/station))
				T = pick(random_floor_turfs)
				if(prob(1)) break // prevent infinite loop

		if(isnull(grow_duration))
			grow_duration = 2 MINUTES + rand(-30 SECONDS, 30 SECONDS)

		if(isnull(duration))
			duration = 40 SECONDS + rand(-10 SECONDS, 10 SECONDS)

		var/obj/whitehole/whitehole = new (T, grow_duration, duration, source_location, TRUE)
		whitehole.activity_modifier = activity_modifier
		message_admins("White Hole anomaly with origin [whitehole.source_location] spawning in [log_loc(T)]")
		message_ghosts("<b>\A [whitehole.source_location] white hole</b> is spawning at [log_loc(T, ghostjump=TRUE)].")
		logTheThing(LOG_ADMIN, usr, "Spawned a white hole anomaly with origin [whitehole.source_location] at [log_loc(T)]")
		src.cleanup()

	cleanup()
		src.target_turf = initial(src.target_turf)
		src.grow_duration = initial(src.grow_duration)
		src.duration = initial(src.duration)
		src.source_location = initial(src.source_location)
		src.activity_modifier = initial(src.activity_modifier)


ADMIN_INTERACT_PROCS(/obj/whitehole, proc/admin_activate)
/obj/whitehole
	name = "white hole"
	icon = 'icons/effects/160x160.dmi'
	desc = "HHHAAA KCUF KCUF KCUF"
	icon_state = "whole"
	opacity = 0
	density = 1
	anchored = ANCHORED_ALWAYS
	pixel_x = -64
	pixel_y = -64
	event_handler_flags = IMMUNE_SINGULARITY
	plane = PLANE_NOSHADOW_BELOW
	pixel_point = TRUE
	var/static/list/valid_locations = VALID_WHITE_HOLE_LOCATIONS
	var/source_location = null
	var/start_time
	var/state = "static"
	var/triggered_by_event = FALSE
	var/grow_duration = 0
	var/active_duration = 0
	var/activity_modifier = 1.0 // multiplies how many objects spawn each "tick"
	var/datum/light/light = null

	var/static/list/spawn_probs = list(
		"artlab" = list(
			"artifact" = 60,
			/obj/item/pen = 10,
			/obj/item/pen/pencil = 10,
			/obj/item/sticker/postit/artifact_paper = 20,
			/obj/item/parts/robot_parts/arm/right/light = 20,
			/obj/item/hand_labeler = 20,
			/obj/item/device/multitool = 10,
			/obj/item/weldingtool = 10,
			/obj/stool/chair/office = 10,
			/obj/item/cargotele = 2,
			/obj/item/disk/data/tape = 2,
			/mob/living/carbon/human/npc/monkey = 0.5,
			/mob/living/carbon/human/normal/scientist = 0.5,
			/obj/item/paper = 5,
			/obj/item/sticker/postit = 2,
			#ifdef SECRETS_ENABLED
			/mob/living/carbon/human/npc/monkey/extremely_fast = 0.05,
			#endif
		),
		"teg" = list(
			/atom/movable/hotspot/gasfire = 90,
			"plasma" = 50,
			"arcflash" = 30,
			/obj/item/wrench/yellow = 10,
			/obj/item/weldingtool/yellow = 10,
			/obj/item/crowbar/yellow = 10,
			/obj/item/screwdriver/yellow = 10,
			/obj/item/wirecutters/yellow = 10,
			/obj/item/cable_coil = 10,
			/obj/item/sheet/steel/fullstack = 10,
			/obj/item/sheet/glass/fullstack = 10,
			/obj/item/rods/steel/fullstack = 10,
			/obj/item/tile/steel/fullstack = 10,
			/obj/item/extinguisher = 10,
			/obj/item/device/light/flashlight = 10,
			/obj/machinery/portable_atmospherics/canister/toxins = 2,
			/obj/machinery/portable_atmospherics/canister/oxygen = 2,
			/obj/machinery/portable_atmospherics/canister/nitrogen = 2,
			/obj/machinery/portable_atmospherics/canister/carbon_dioxide = 2,
			/obj/item/paper/engine = 5,
			/obj/item/chem_grenade/firefighting = 5,
			/obj/item/clothing/mask/gas = 2,
			/obj/item/clothing/head/helmet/hardhat = 2,
			/obj/item/clothing/gloves/yellow = 1,
			/obj/item/clothing/shoes/magnetic = 1,
			/obj/machinery/portable_atmospherics/pump = 1,
			/obj/item/deconstructor = 1,
			/obj/item/raw_material/shard/glass = 5,
			/obj/item/rcd = 0.5,
			/obj/item/assembly/timer_ignite_pipebomb/syndicate = 0.1,
			/obj/item/assembly/timer_ignite_pipebomb/engineering = 0.3,
			/mob/living/carbon/human/normal/engineer = 0.5,
			/mob/living/carbon/human/normal/chiefengineer = 0.1,
			/mob/living/carbon/human/npc/monkey/mr_rathen = 0.5,
			/obj/item/paper = 2,
		),
		"flock" = list(
			"flockconverted" = 15,
			/mob/living/critter/flock/drone = 2,
			/obj/flock_structure/egg/bit = 2,
			/obj/item/organ/brain/flockdrone = 2,
			/obj/item/organ/flock_crystal = 2,
			/datum/projectile/energy_bolt/flockdrone = 4,
			/obj/item/reagent_containers/gnesis = 2,
			/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock = 3,
			/obj/item/reagent_containers/food/snacks/burger/flockburger = 3,
			/obj/storage/closet/flock = 2,
			/obj/item/furniture_parts/flock_chair = 7,
			/obj/stool/chair/comfy/flock = 3,
			/obj/item/furniture_parts/table/flock = 7,
			/obj/table/flock = 3,
			/obj/item/device/flockblocker = 3,
			/obj/item/paper/flockstatsnote = 1,
			/obj/window/feather = 1,
			/obj/mesh/flock/barricade = 1,
			/obj/fakeobject/flock/antenna/not_dense = 1,
			/obj/decal/cleanable/flockdrone_debris = 1,
			/obj/decal/cleanable/flockdrone_debris/fluid = 1,
			/obj/item/gun/energy/flock = 0.05,
			/obj/item/material_piece/gnesisglass = 5,
			/obj/item/material_piece/gnesis = 5,
			/datum/reagent/flockdrone_fluid = 3,
		),
		"chapel" = list(
			/obj/item/bible = 2,
			/obj/item/device/light/candle = 10,
			/obj/item/device/light/candle/small = 15,
			/obj/item/device/light/candle/spooky = 2,
			/obj/item/device/light/candle/haunted = 2,
			/obj/item/strange_candle = 2,
			/obj/item/spook = 5,
			/obj/storage/closet/coffin = 5,
			/obj/storage/closet/coffin/wood = 2,
			/obj/item/card_box/tarot = 2,
			/obj/item/reagent_containers/glass/bottle/holywater = 3,
			/obj/stool/chair/pew = 3,
			/obj/item/ghostboard = 5,
			/obj/item/ghostboard/emouija = 1,
			/mob/living/critter/aquatic/fish/nautilus = 2,
			/obj/item/instrument/large/piano = 3,
			/obj/storage/closet/dresser = 3,
			/obj/machinery/traymachine/morgue = 1,
			/obj/item/body_bag = 2,
			/obj/item/reagent_containers/glass/bottle/formaldehyde = 1,
			/obj/item/skull = 5,
			/obj/item/skull/strange = 0.1,
			/obj/item/skull/odd = 0.1,
			/obj/item/skull/peculiar = 0.1,
			/obj/item/skull/menacing = 0.1,
			/obj/item/skull/crystal = 0.1,
			/obj/item/skull/gold = 0.1,
			/obj/item/skull/noface = 0.1,
			/mob/living/carbon/human/normal/chaplain = 0.2,
			/mob/living/critter/skeleton = 1,
			/obj/item/gun/energy/ghost = 0.2,
			/obj/item/reagent_containers/food/snacks/ectoplasm = 4,
			/datum/reagent/water/water_holy = 1,
			/datum/reagent/blood = 1,
			/obj/item/kitchen/utensil/knife = 1,
			/obj/critter/spirit = 1,
			/obj/item/paper = 3,
			/obj/item/sticker/postit = 1,
		),
		"trench" = list(
			/datum/reagent/water/sea = 20,
			// /datum/reagent/harmful/tene = 1,
			/obj/item/seashell = 2,
			"trenchloot" = 5,
			"ore" = 5,
			/mob/living/critter/aquatic/shark = 1,
			/obj/critter/gunbot/drone/gunshark = 0.5,
			/obj/critter/gunbot/drone/buzzdrone/fish = 0.8,
			/obj/naval_mine/standard = 0.2,
			/obj/naval_mine/vandalized = 0.2,
			/obj/naval_mine/rusted = 0.2,
			/mob/living/critter/small_animal/pikaia = 1,
			/mob/living/critter/small_animal/hallucigenia = 1,
			/mob/living/critter/small_animal/trilobite = 1,

			/mob/living/critter/aquatic/fish/jellyfish = 1,
			/mob/living/critter/aquatic/king_crab = 0.01,

			/mob/living/critter/aquatic/fish/butterfly = 0.5,
			/mob/living/critter/aquatic/fish/butterfly/copperbanded = 0.5,
			/mob/living/critter/aquatic/fish/butterfly/addis = 0.5,
			/mob/living/critter/aquatic/fish/butterfly/spotted = 0.5,
			/mob/living/critter/aquatic/fish/butterfly/forceps = 0.5,
			/mob/living/critter/aquatic/fish/tang = 0.5,
			/mob/living/critter/aquatic/fish/tang/powderblue = 0.5,
			/mob/living/critter/aquatic/fish/tang/bluesailfin = 0.5,
			/mob/living/critter/aquatic/fish/tang/purplesailfin = 0.5,
			/mob/living/critter/aquatic/fish/tang/regal = 0.5,
			/mob/living/critter/aquatic/fish/angel = 0.5,
			/mob/living/critter/aquatic/fish/angel/french = 0.5,
			/mob/living/critter/aquatic/fish/damsel = 0.5,
			/mob/living/critter/aquatic/fish/damsel/blue = 0.5,
			/mob/living/critter/aquatic/fish/gamma = 0.5,
			/mob/living/critter/aquatic/fish/clown = 0.5,
			/mob/living/critter/aquatic/fish/nautilus = 0.5,

			/obj/sea_plant/kelp = 0.5,
			/obj/sea_plant/seaweed = 0.5,
			/obj/sea_plant/tubesponge = 0.5,
			/obj/sea_plant/tubesponge/small = 0.5,
			/obj/sea_plant/anemone/lit = 0.5,
			/obj/sea_plant/anemone = 0.5,
			/obj/sea_plant/coralfingers = 0.5,
			/obj/sea_plant/branching = 0.5,
			/obj/sea_plant/bulbous = 0.5,
			/obj/nadir_doodad/sinkspires = 0.5,
			/obj/nadir_doodad/bitelung = 0.5,

			/mob/living/carbon/human/normal/miner = 0.1,
			/obj/machinery/vehicle/tank/minisub/mining = 0.5,
		),
		"asteroid" = list(
			"ore" = 200,
			/mob/living/critter/rockworm = 3,
			/mob/living/critter/fermid = 10,
			/obj/storage/crate/loot = 4,
			/mob/living/carbon/human/normal/miner = 0.1,
			/obj/item/raw_material/scrap_metal = 4,
			/obj/machinery/portable_reclaimer = 1,
			/obj/item/mining_tool/powered/drill = 0.5,
			/obj/item/mining_tool/powered/pickaxe = 0.5,
			/obj/item/mining_tool/powered/shovel = 0.5,
			/obj/item/mining_tool/powered/hammer = 0.5,

			/obj/critter/gunbot/drone = 0.5,
			/obj/critter/gunbot/drone/heavydrone = 0.1,
			/obj/critter/gunbot/drone/cannondrone = 0.1,
			/obj/critter/gunbot/drone/minigundrone = 0.1,
			/obj/critter/gunbot/drone/raildrone = 0.03,
			/obj/critter/gunbot/drone/buzzdrone = 1,
			/obj/critter/gunbot/drone/laser = 0.1,
			/obj/critter/gunbot/drone/cutterdrone = 0.1,
			/obj/critter/gunbot/drone/assdrone = 0.1,
			/obj/critter/gunbot/drone/aciddrone = 0.1,
		),
		"cafeteria" = list(
			"deepfried" = 2,
			/obj/item/plate = 10,
			/obj/item/kitchen/utensil/fork = 10,
			/obj/item/kitchen/utensil/knife = 10,
			/obj/item/kitchen/utensil/spoon = 10,
			/obj/item/kitchen/utensil/knife/bread = 1,
			/obj/item/kitchen/utensil/knife/cleaver = 1,
			/obj/item/kitchen/utensil/knife/pizza_cutter = 1,
			/obj/item/ladle = 0.2,
			/obj/item/kitchen/rollingpin = 0.5,
			/obj/item/paper = 3,

			/obj/item/reagent_containers/food/drinks/drinkingglass = 2,
			/obj/item/reagent_containers/food/drinks/drinkingglass/cocktail = 2,
			/obj/item/reagent_containers/food/drinks/drinkingglass/shot = 2,
			/obj/item/reagent_containers/food/drinks/drinkingglass/flute = 2,
			/obj/item/reagent_containers/food/drinks/drinkingglass/wine = 2,
			/obj/item/reagent_containers/food/drinks/drinkingglass/oldf = 2,
			/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher = 2,
			/obj/item/reagent_containers/food/drinks/drinkingglass/round = 2,
			/obj/item/reagent_containers/food/drinks/espressocup = 1,
			/obj/item/reagent_containers/food/drinks/mug = 1,
			/obj/item/reagent_containers/food/drinks/tea = 1,
			/obj/item/reagent_containers/food/drinks/coffee = 1,

			/datum/reagent/vomit = 0.1,

			/obj/stool/bar = 5,
			/obj/item/decoration/ashtray = 1,
			/mob/living/carbon/human/normal/chef = 0.1,
			/mob/living/carbon/human/normal/bartender = 0.1,
			/mob/living/carbon/human/npc/monkey/angry = 0.1,
			/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
			/obj/item/reagent_containers/food/snacks/cake/chocolate/gateau = 0.5,
			/obj/decal/cleanable/vomit = 0.5,
		),
		"singulo" = list(
			"arcflash" = 5,
			/obj/storage/closet/extradimensional = 0.2,
			/datum/projectile/laser/heavy = 5,
			/obj/item/tile/steel = 10,
			/obj/item/rods/steel = 10,
			/obj/mesh/grille/steel = 2,
			/obj/window = 2,
			/obj/machinery/emitter = 0.3,
			/obj/item/toy/plush/small/singuloose = 0.1,
			/mob/living/carbon/human/normal/engineer = 0.5,
			/mob/living/carbon/human/normal/chiefengineer = 0.1,
			/mob/living/carbon/human/npc/monkey/mr_rathen = 0.5,
			/obj/item/clothing/glasses/toggleable/meson = 0.5,
			/obj/item/old_grenade/graviton = 0.2,
			/obj/gravity_well_generator = 0.5,
			/obj/item/raw_material/scrap_metal = 4,
			/obj/item/raw_material/shard/glass = 5,
			/obj/item/raw_material/shard/plasmacrystal = 3,
			/obj/item/paper = 3,
		),
		"plasma" = list(
			"plasma" = 100,
			/obj/critter/spore = 3,
			/obj/item/raw_material/shard/plasmacrystal = 1,
			/obj/item/raw_material/plasmastone = 1,
		),
		"nukies" = list(
			/datum/projectile/bullet/minigun = 5,
			/datum/projectile/energy_bolt = 5,
			/datum/projectile/bullet/rpg = 0.5,
			/datum/projectile/bullet/assault_rifle = 5,
			/datum/projectile/bullet/grenade_round/explosive = 0.5,
			/obj/machinery/bot/secbot = 2,
			/obj/machinery/bot/guardbot = 2,
			/obj/barricade = 1,
			/obj/item/deployer/barricade = 0.5,
			/mob/living/carbon/human/npc/monkey/oppenheimer = 0.5,
			/obj/item/mine/blast/armed = 1,
			/obj/item/mine/incendiary/armed = 1,
			/obj/item/mine/radiation/armed = 1,
			/obj/item/mine/stun/armed = 1,
			/obj/item/old_grenade/stinger/frag = 1,
			/obj/item/old_grenade/stinger = 1,
			/obj/item/chem_grenade/very_incendiary = 0.5,
			/obj/item/chem_grenade/incendiary = 1,
			/obj/stool/chair/office/syndie = 1,
			/obj/item/paper/book/from_file/syndies_guide = 0.5,
			/obj/item/beartrap/armed = 1,
			/datum/reagent/harmful/saxitoxin = 0.1,
			/datum/reagent/blood = 1,
			/mob/living/critter/robotic/sawfly = 2,
			/obj/item/reagent_containers/food/snacks/donkpocket_w = 1,
			/obj/bomb_decoy = 0.4,
			/obj/machinery/nuclearbomb/event/micronuke = 0.05,
			'sound/effects/first_reality.ogg' = 0.5,
		),
		"hell" = list(
			"fireflash" = 15,
			/atom/movable/hotspot/gasfire = 10,
			/mob/living/critter/small_animal/crab/lava = 5,
			/obj/submachine/slot_machine = 5,
			#ifdef SECRETS_ENABLED
			/obj/critter/slime/magma = 2,
			/obj/critter/slime/large/magma = 0.3,
			#endif
			/obj/decal/cleanable/ash = 10,
			/mob/living/carbon/human/normal = 5,
			/obj/decal/stalagmite = 5,
			/obj/decal/cleanable/molten_item = 10,
			/obj/item/paper = 3,
			/obj/critter/bat/hellbat = 5,
			"corpse" = 5,
			// yeah idk where I was going with "hell" either
		),
		"botany" = list(
			"randomplant" = 100,
			/obj/item/reagent_containers/food/snacks/plant/tomato = 100,
			/obj/item/reagent_containers/food/snacks/ingredient/egg/bee = 100,
			/obj/item/plant/herb/cannabis/spawnable = 80,
			/obj/item/plant/herb/cannabis/mega/spawnable = 10,
			/obj/item/plant/herb/cannabis/black/spawnable = 10,
			/obj/item/plant/herb/cannabis/white/spawnable = 5,
			/obj/item/plant/herb/cannabis/omega/spawnable = 3,
			/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 50,
			/obj/critter/domestic_bee = 10,
			/obj/critter/domestic_bee_larva = 10,
			/datum/reagent/fooddrink/juice_tomato = 1,
			/datum/reagent/drug/THC = 1,
			/datum/reagent/poo = 1,
			/obj/item/reagent_containers/food/snacks/plant/melonslice = 10,
			/obj/item/reagent_containers/food/snacks/plant/melon = 20,
			/obj/item/reagent_containers/food/snacks/plant/melon/bowling = 20,
			/obj/item/seed/alien = 2,
			/obj/machinery/plantpot = 10,
			/obj/reagent_dispensers/watertank = 2,
			/obj/reagent_dispensers/compostbin = 2,
			/obj/item/clothing/mask/cigarette = 10,
			/obj/item/reagent_containers/glass/water_pipe = 1,
			/obj/item/device/light/lava_lamp = 1,
			/obj/item/paper = 3,
			/obj/critter/killertomato = 0.5,
			/mob/living/critter/small_animal/cat/synth = 1,
			/mob/living/critter/plant/maneater = 0.3,
			/obj/item/plant/tumbling_creeper = 3,
		),
		"maint" = list(
			/obj/decal/cleanable/rust = 10,
			/obj/decal/cleanable/dirt = 10,
			/obj/decal/cleanable/fungus = 10,
			/obj/decal/cleanable/oil = 10,
			/obj/reagent_dispensers/fueltank = 2,
			/obj/item/wrench = 10,
			/obj/item/crowbar = 10,
			/obj/item/screwdriver = 10,
			/obj/item/weldingtool = 10,
			/obj/item/device/radio = 10,
			/obj/item/tank/air = 10,
			/obj/item/tank/pocket/oxygen = 2,
			/obj/item/extinguisher = 10,
			/obj/item/clothing/mask/gas/emergency = 3,
			/obj/burning_barrel = 2,
			/obj/item/device/light/glowstick = 5,
			/obj/storage/closet/fire = 2,
			/obj/storage/closet/emergency = 2,
			/obj/item/storage/toilet = 1,
			/obj/machinery/bot/firebot = 2,
			/obj/machinery/bot/cleanbot = 2,
			/obj/machinery/bot/floorbot = 2,
			/obj/item/storage/pill_bottle/cyberpunk = 10,
			/obj/item/reagent_containers/food/drinks/bottle/hobo_wine = 10,
			/obj/item/plant/herb/cannabis/spawnable = 5,
			/mob/living/critter/spider/baby = 2,
			/mob/living/critter/spider/nice = 2,
			/mob/living/carbon/human/npc/assistant = 2,
			/mob/living/carbon/human/normal/assistant = 2,
			/obj/item/paper = 5,
			/obj/item/sticker/postit = 1,
			#ifdef SECRETS_ENABLED
			/mob/living/critter/legman = 1,
			#endif
		),
		"ai" = list(
			/datum/projectile/laser/heavy/law_safe = 30,
			/datum/projectile/energy_bolt/robust = 30,
			/obj/item/aiModule/random = 20,
			/mob/living/silicon/hivebot/eyebot = 10,
			/obj/item/circuitboard/robotics = 2,
			/mob/living/silicon/ai/latejoin = 1,
			/obj/item/storage/box/diskbox = 1,
			/obj/item/storage/box/tapebox = 1,
			/obj/item/paper/book/from_file/guardbot_guide = 1,
			/obj/item/paper/book/from_file/dwainedummies = 1,
			/obj/item/disk/data/tape/master/readonly = 1,
			/obj/item/disk/data/tape = 1,
			/obj/item/disk/data/floppy/read_only/network_progs = 1,
			/obj/item/disk/data/floppy/read_only/communications = 1,
			/obj/item/aiModule/makeCaptain = 1,
			/obj/item/aiModule/emergency = 1,
			/obj/machinery/recharge_station = 1,
			/obj/machinery/manufacturer/robotics = 1,
			/obj/item/robot_module = 1,
			/obj/item/parts/robot_parts/robot_frame = 1,
			/obj/ai_core_frame = 1,
			/obj/item/parts/robot_parts/chest/standard = 1,
			/obj/item/parts/robot_parts/head/standard = 1,
			/obj/item/organ/brain/latejoin = 1,
			/obj/item/cell/supercell/charged = 1,
			/obj/item/parts/robot_parts/arm/left/standard = 1,
			/obj/item/parts/robot_parts/arm/right/standard = 1,
			/obj/item/parts/robot_parts/leg/left/standard = 1,
			/obj/item/parts/robot_parts/leg/right/standard = 1,
			/obj/item/cable_coil = 1,
			/obj/item/wrench = 1,
			/obj/item/paper = 2,
			/obj/item/clothing/suit/cardboard_box/ai = 1,
			/obj/item/disk/data/floppy/manudrive/ai = 1,
			/obj/item/aiModule/ability_expansion/doctor_vision = 0.5,
			/obj/item/aiModule/ability_expansion/proto_teleman = 0.2
		),
		"bridge" = list(
			/obj/item/reagent_containers/food/drinks/drinkingglass/flute = 10,
			/obj/item/reagent_containers/food/drinks/bottle/champagne = 3,
			/obj/item/toy/judge_gavel = 1,
			/obj/stool/chair/comfy = 5,
			/mob/living/critter/small_animal/cat/jones = 5,
			/obj/item/clothing/suit/bedsheet/captain = 2,
			/obj/item/card/id/captains_spare = 0.1,
			/obj/item/currency/spacecash/small = 5,
			/obj/item/stamp/hop = 1,
			/obj/item/stamp/cap = 1,
			/obj/item/stamp/centcom = 1,
			/obj/item/coin = 1,
			/obj/machinery/coffeemaker = 1,
			/obj/item/pen/fancy = 1,
			/obj/item/storage/toilet/goldentoilet = 1,
			/obj/item/storage/box/id_kit = 1,
			/obj/item/storage/box/clothing/captain = 1,
			/obj/item/item_box/gold_star = 1,
			/obj/item/hand_tele = 2,
			/obj/machinery/shipalert = 1,
			/obj/item/storage/box/PDAbox = 1,
			/obj/item/storage/box/trackimp_kit = 1,
			/obj/item/cigarbox/gold = 2,
			/obj/item/paper/book/from_file/captaining_101 = 1,
			/obj/shrub/captainshrub = 0.5,
			/obj/captain_bottleship = 0.5,
			/obj/fitness/speedbag/captain = 1,
			/obj/item/disk/data/floppy/read_only/communications = 1,
			/obj/machinery/manufacturer/hop_and_uniform = 0.5,
			/obj/item/paper = 6,
			/obj/item/sticker/postit = 4,
			"sticker" = 4,
		),
		"clown" = list(
			/obj/item/bananapeel = 20,
			/obj/item/instrument/bikehorn = 10,
			/obj/item/toy/sword = 3,
			/obj/item/rubber_chicken = 1,
			/obj/item/rubber_hammer = 1,
			/obj/machinery/bot/duckbot = 1,
			/obj/item/a_gift/easter = 1,
			/obj/item/paper/book/from_file/the_trial = 1,
			/obj/item/reagent_containers/food/snacks/pie/cream = 5,
			/obj/item/gnomechompski = 3,
			/obj/item/aiModule/hologram_expansion/clown = 1,
			/obj/item/balloon_animal/random = 5,
			/obj/item/pen/crayon/rainbow = 2,
			/obj/item/pen/crayon/random = 1,
			/obj/item/clothing/suit/bedsheet/captain = 2,
			/obj/item/storage/pill_bottle/cyberpunk = 1,
			/obj/vehicle/clowncar = 0.03,
			/obj/reagent_dispensers/heliumtank = 1,
			/obj/item/storage/goodybag = 3,
			/obj/stool/chair/syndicate = 3,
			/obj/item/paper/fortune = 1,
			/obj/item/toy/plush = 1,
			/obj/item/toy/figure = 1,
			/obj/item/toy/diploma = 1,
			/obj/item/toy/gooncode = 1,
			/obj/item/toy/cellphone = 1,
			/obj/item/toy/handheld/robustris = 1,
			/obj/item/toy/handheld/arcade = 1,
			/obj/item/toy/ornate_baton = 1,
			/obj/fitness/speedbag/clown = 1,
			/obj/item/storage/box/costume/clown = 2,
			/obj/item/reagent_containers/food/drinks/milk/clownspider = 1,
			/obj/item/ai_plating_kit/clown = 0.5,
			/mob/living/carbon/human/normal/clown = 1,
			/mob/living/critter/spider/clown = 1,
			/mob/living/critter/spider/clownqueen = 0.1,
			/obj/item/paper = 1,
			/obj/item/sticker/postit = 1,
			"sticker" = 3,
		),
		"medbay" = list(
			/obj/item/surgical_spoon = 5,
			/obj/item/scalpel = 5,
			/obj/item/circular_saw = 5,
			/obj/item/hemostat = 5,
			/obj/item/scissors/surgical_scissors = 5,
			/obj/machinery/optable = 2,
			"medicine" = 20,
			"organ" = 20,
			/obj/item/reagent_containers/hypospray = 5,
			"corpse" = 2,
			"geneinjector" = 3,
			/obj/item/reagent_containers/syringe = 10,
			/obj/item/clothing/gloves/latex = 5,
			/obj/item/robodefibrillator = 1,
			/obj/item/storage/firstaid/oxygen = 4,
			/obj/item/storage/firstaid/brute = 4,
			/obj/item/storage/firstaid/fire = 4,
			/obj/item/storage/firstaid/regular = 4,
			/obj/item/storage/firstaid/toxin = 4,
			/obj/machinery/manufacturer/medical = 2,
			/obj/machinery/bot/medbot = 5,
			/obj/machinery/bot/medbot/mysterious/emagged = 1,
			/datum/reagent/blood = 5,
			/datum/reagent/fooddrink/caffeinated/coffee = 2,
			/obj/item/paper = 1,
			/obj/item/sticker/postit = 0.5,
		),
		"security" = list(
			/obj/item/handcuffs/guardbot = 5,
			/datum/projectile/special/spawner/handcuff = 5,
			/obj/item/handcuffs = 2,
			/obj/itemspecialeffect/barrier = 3,
			/obj/machinery/bot/secbot = 1,
			/obj/machinery/bot/secbot/emagged = 3,
			/obj/item/reagent_containers/food/snacks/donut/custom/random = 15,
			/obj/item/reagent_containers/food/snacks/donut/custom/robust = 1,
			/obj/item/reagent_containers/food/snacks/donut/custom/robusted = 1,
			/obj/item/device/flash = 3,
			/obj/item/clothing/head/beret/prisoner = 5,
			/obj/item/clothing/shoes/orange = 5,
			/obj/item/clothing/under/misc/prisoner = 5,
			/obj/item/clothing/shoes/swat = 2,
			/obj/item/clothing/head/red = 4,
			/obj/item/clothing/head/helmet/siren = 2,
			/obj/machinery/flasher/portable = 1,
			/obj/item/barrier = 1,
			/mob/living/carbon/human/npc/monkey/stirstir = 1,
			/datum/projectile/energy_bolt = 3,
			/datum/projectile/energy_bolt/burst = 3,
			/datum/projectile/energy_bolt/tasershotgun = 3,
			/datum/projectile/energy_bolt/bouncy = 3,
			/obj/item/paper = 1,
			/obj/item/sticker/postit = 0.5,
		),
		"cargo" = list(
			/obj/item/currency/spacecash/five = 10,
			/obj/item/currency/spacecash/ten = 10,
			/obj/item/currency/spacecash/twenty = 10,
			/obj/item/currency/spacecash/fifty = 5,
			/obj/item/currency/spacecash/hundred = 3,
			/obj/item/currency/spacecash/fivehundred = 0.3,
			/obj/item/paper = 15,
			/obj/item/paper_bin = 5,
			/obj/item/hand_labeler = 5,
			/obj/item/stamp/qm = 5,
			/obj/storage/crate = 5,
			/obj/storage/crate/internals = 1,
			/obj/storage/crate/freezer = 0.75,
			/obj/storage/secure/crate/dan = 0.25,
			/obj/storage/crate/medical = 0.75,
			/obj/storage/crate/biohazard = 0.25,
			/obj/storage/crate/packing = 1,
			/obj/storage/crate/wooden = 1,
			/obj/storage/crate/bee = 0.25,
			/obj/storage/crate/bloody = 0.25,
			/obj/storage/crate/classcrate/qm = 0.25,
			/obj/item/cargotele = 3,
			/obj/item/device/appraisal = 5,
			/obj/item/paper/book/from_file/pocketguide/quartermaster = 3,
			/obj/item/storage/box/clothing/qm = 3,
			/obj/machinery/manufacturer/qm = 1,
			/obj/machinery/bot/mulebot = 0.3,
			/obj/vehicle/forklift = 0.2
		),

		// not actual location, just a helper thing since it's shared between asteroid and trench
		"ore" = list(
			/obj/item/raw_material/rock = 100,
			/obj/item/raw_material/ice = 50,

			/obj/item/raw_material/mauxite = 20,
			/obj/item/raw_material/pharosium = 20,
			/obj/item/raw_material/uqill = 0.5,
			/obj/item/raw_material/fibrilith = 3,
			/obj/item/raw_material/molitz = 20,
			/obj/item/raw_material/char = 5,
			/obj/item/raw_material/cobryl = 3,
			/obj/item/raw_material/bohrum = 2,
			/obj/item/raw_material/claretine = 5,
			/obj/item/raw_material/martian = 5,
			/obj/item/raw_material/syreline = 2,
			/obj/item/raw_material/cerenkite = 1,
			/obj/item/raw_material/plasmastone = 1,
			/obj/item/raw_material/eldritch = 1,
			/obj/item/raw_material/gold = 2,
			/obj/item/raw_material/miracle = 1,
			/obj/item/raw_material/erebite = 0.5,
			/obj/item/raw_material/starstone = 0.01,
			/obj/item/material_piece/cloth/carbon = 0.02,
			/obj/item/raw_material/gemstone = 3,
		),
		//haha get irradiated nerds
		"nuclear" = list(
			"radgas" = 50,
			"plasma" = 30,
			/obj/item/reactor_component/control_rod/random_material = 20,
			/obj/item/reactor_component/fuel_rod/random_material = 20,
			/obj/item/reactor_component/gas_channel/random_material= 20,
			/obj/item/reactor_component/heat_exchanger/random_material = 20,
			/datum/projectile/neutron = 50,
			/obj/item/nuclear_waste = 20,
			/obj/decal/cleanable/machine_debris/radioactive = 20,
			/obj/item/storage/pill_bottle/antirad = 15,
			/obj/item/clothing/glasses/toggleable/meson = 1,
			/obj/item/reagent_containers/emergency_injector/anti_rad = 15,
			/obj/storage/closet/radiation = 10,
			/obj/item/reagent_containers/pill/antirad = 10,
			/obj/item/clothing/mask/gas = 5,
			/obj/item/clothing/suit/hazard/rad = 5,
			/obj/item/clothing/gloves/yellow = 5,
			/obj/item/clothing/head/rad_hood = 5,
			/obj/item/wrench/yellow = 10,
			/obj/item/weldingtool/yellow = 10,
			/obj/item/crowbar/yellow = 10,
			/obj/item/extinguisher = 10,
			/obj/machinery/portable_atmospherics/canister/toxins = 4,
			/obj/machinery/portable_atmospherics/canister/oxygen = 2,
			/obj/machinery/portable_atmospherics/canister/nitrogen = 2,
			/obj/machinery/portable_atmospherics/canister/carbon_dioxide = 2,
			/obj/item/paper/book/from_file/nuclear_engineering = 10,
			/obj/item/chem_grenade/firefighting = 5,
			/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake = 1,
			/obj/item/material_piece/plutonium = 1,
			/obj/item/raw_material/cerenkite = 10,
		),
		"janitorial" = list(
			/obj/machinery/bot/cleanbot = 5,
			/obj/machinery/bot/cleanbot/emagged = 3,
			/obj/item/caution = 10,
			/obj/item/caution/traitor = 2,
			/obj/item/spraybottle/cleaner = 5,
			/obj/item/reagent_containers/glass/bottle/cleaner = 3,
			/obj/item/reagent_containers/glass/bottle/acetone/janitors = 3,
			"body_bag" = 2,
			/obj/item/mop = 5,
			/obj/item/sponge = 5,
			/datum/reagent/water = 10,
			/datum/reagent/space_cleaner = 5,
			/obj/item/mousetrap/armed = 5,
			/obj/item/chem_grenade/cleaner = 10,
			/obj/item/clothing/gloves/long = 3,
			/obj/item/clothing/suit/hazard/bio_suit = 1,
			/obj/item/clothing/head/bio_hood = 1,
			/obj/item/clothing/shoes/white = 1,
			/obj/mopbucket = 3,
			/obj/submachine/laundry_machine = 1,
			/obj/item/reagent_containers/bath_bomb = 10,
			/obj/storage/cart/trash = 2,
			/obj/item/scrap = 5,
			/obj/item/reagent_containers/glass/bucket = 4,
			/obj/vehicle/floorbuffer = 1,
			/obj/item/handheld_vacuum = 1
		),
		"wizard" = list(
			/obj/item/reagent_containers/food/drinks/tea/mugwort = 10,
			/obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor = 30,
			/obj/item/kitchen/everyflavor_box = 3,
			/obj/item/staff = 10,
			/obj/item/staff/crystal = 5,
			/obj/item/staff/monkey_staff = 0.05,
			/obj/item/clothing/head/wizard = 5,
			/obj/item/clothing/head/wizard/purple = 5,
			/obj/item/clothing/head/wizard/red = 5,
			/obj/item/clothing/head/wizard/green = 5,
			/obj/item/clothing/head/wizard/witch = 5,
			/obj/item/clothing/head/wizard/necro = 2,
			/obj/item/clothing/suit/wizrobe = 3,
			/obj/item/clothing/suit/wizrobe/purple = 3,
			/obj/item/clothing/suit/wizrobe/green = 3,
			/obj/item/clothing/suit/wizrobe/red = 3,
			/obj/item/clothing/suit/wizrobe/necro = 1,
			/obj/item/clothing/suit/bathrobe = 1,
			/obj/item/clothing/head/apprentice = 1,
			/obj/item/toy/plush/small/kitten/wizard = 1,
			/obj/item/paper/Wizardry101 = 10,
			/obj/item/paper/businesscard/cosmicacres = 2,
			/datum/projectile/fireball = 5,
			/datum/projectile/special/homing/magicmissile/weak = 20,
			/datum/projectile/special/homing/magicmissile = 15,
			/datum/projectile/artifact/prismatic_projectile = 20,
			"snake" = 10,
			/obj/forcefield/autoexpire = 4,
			/obj/decal/icefloor = 10,
			/obj/lightning_target = 10,
			/obj/item/clothing/gloves/ring/wizard/blink = 0.1,
			/obj/item/clothing/gloves/ring/wizard/forcewall = 0.1,
			/obj/item/enchantment_scroll = 0.5,
			"wizard crystal" = 1
		),
		"spacemas" = list(
			"present" = 25,
			/obj/item/reagent_containers/food/snacks/breadloaf/fruit_cake = 4,
			/obj/item/reagent_containers/food/snacks/breadslice/fruit_cake = 7,
			/obj/item/reagent_containers/food/snacks/turkey = 5,
			/mob/living/critter/small_animal/bird/turkey = 1,
			/obj/item/reagent_containers/food/snacks/candy/candy_cane = 5,
			/obj/item/reagent_containers/food/snacks/candy/nougat = 3,
			/obj/item/reagent_containers/food/snacks/candy/negativeonebar = 3,
			/obj/item/reagent_containers/food/snacks/candy/chocolate = 3,
			/obj/item/reagent_containers/food/snacks/candy/pbcup = 2,
			/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/taffy/cherry = 2,
			/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/butterscotch = 1,
			/obj/item/reagent_containers/food/drinks/eggnog = 5,
			/obj/item/reagent_containers/food/drinks/bottle/soda/xmas = 5,
			/obj/item/reagent_containers/food/snacks/plant/orange = 3,
			/obj/item/reagent_containers/food/snacks/snowball = 15,
			/obj/decal/wreath = 1,
			/mob/living/critter/small_animal/bunny/hare = 1,
			/obj/item/raw_material/char = 3,
			/obj/critter/domestic_bee/reindeer = 1,
			/obj/critter/domestic_bee/santa = 1,
			/obj/item/material_piece/organic/wood = 3,
			/obj/item/clothing/head/helmet/space/santahat = 3,
			/obj/item/clothing/suit/space/santa = 2,
#ifdef XMAS
			/datum/figure_info/santa = 1,
#endif
			/datum/reagent/fooddrink/alcoholic/mulled_wine = 2,
		),
	)

	New(var/loc, grow_duration = 0, active_duration = null, source_location = null, triggered_by_event = FALSE)
		..()
		src.start_time = TIME
		src.triggered_by_event = triggered_by_event
		src.grow_duration = grow_duration

		if (active_duration < 1)
			active_duration = rand(5 SECONDS, 40 SECONDS)
		src.active_duration = active_duration

		if(isnull(source_location))
			source_location = pick(valid_locations)
		src.source_location = source_location

		var/image/illum = image(src.icon, src.icon_state)
		illum.plane = PLANE_LIGHTING
		illum.blend_mode = BLEND_ADD
		illum.alpha = 100
		src.AddOverlays(illum, "illum")

		light = new /datum/light/point
		light.set_brightness(0.7)
		light.attach(src)
		light.enable()

		var/image/location_image = image('icons/effects/white_hole_views96x96.dmi', src.source_location)
		location_image.alpha = 160
		location_image.pixel_x = 32
		location_image.pixel_y = 32
		src.AddOverlays(location_image, "source_location")

		src.transform = matrix(32 / 160, MATRIX_SCALE)

		if(!particleMaster.CheckSystemExists(/datum/particleSystem/whitehole_warning, src))
			particleMaster.SpawnSystem(new /datum/particleSystem/whitehole_warning(src))

		if(triggered_by_event)
			var/turf/T = get_turf(src)
			for (var/client/C in GET_NEARBY(/datum/spatial_hashmap/clients, T, 15))
				boutput(C, SPAN_ALERT("The air grows light and thin. Something feels terribly wrong."))
				shake_camera(C.mob, 5, 16)
			playsound(src,'sound/effects/creaking_metal1.ogg',100,FALSE,5,-0.5)

		processing_items |= src

	proc/admin_activate()
		set name = "Activate"
		start_time = TIME - grow_duration

	bullet_act(obj/projectile/P)
		shoot_reflected_to_sender(P, src)
		P.die()

	Bumped(atom/movable/A)
		if(QDELETED(A) || A.throwing || istype(A, /obj/projectile))
			return
		if(!ON_COOLDOWN(A, "white_hole_bump", 0.2 SECONDS)) //okay this will REALLY prevent infinite loops (hopefully)
			step_away(A, src)

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/fishing_rod))
			. = ..()
		else
			boutput(user, SPAN_ALERT("\The [I] seems to be repulsed by the anti-gravitational field of [src]!"))

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		. = ..()
		SPAWN(0)
			AM.throw_at( \
				thr.thrown_from,
				thr.range,
				thr.speed
			)

	ex_act(severity)
		return

	proc/process()
		var/time_since_start = TIME - start_time

		if(state == "dying")
			qdel(src)

		if(triggered_by_event)
			//spatial interdictor: can't stop the white hole, but it can mitigate it
			//consumes 500 units of charge (250,000 joules) to reduce white hole duration
			for_by_tcl(IX, /obj/machinery/interdictor)
				if (IX.expend_interdict(500, src))
					if(prob(20))
						playsound(IX,'sound/machines/alarm_a.ogg',20,FALSE,5,-1.5)
						IX.visible_message(SPAN_ALERT("<b>[IX] emits an anti-gravitational anomaly warning!</b>"))
					if(state != "active")
						grow_duration += 4 SECOND
					else
						active_duration -= 1 SECOND

		if(time_since_start < grow_duration)
			var/scale = 32 / 160 + (160 - 32) / 160 * clamp(((time_since_start + 3 SECONDS) - grow_duration / 3) / (grow_duration * 2 / 3), 0, 1)
			animate(src, transform = matrix(scale, MATRIX_SCALE), time = 3 SECONDS, loop = 0, easing = LINEAR_EASING)

		if(time_since_start < grow_duration / 3)
			return
		else if(time_since_start < grow_duration)
			if(state == "static")
				state = "growing"
				src.visible_message(SPAN_ALERT("<b>[src] begins to uncollapse out of itself!</b>"))
				playsound(src,'sound/machines/engine_alert3.ogg',100,FALSE,5,-0.5)
				if (random_events.announce_events && triggered_by_event)
					command_alert("A severe anti-gravitational anomaly has been detected on the [station_or_ship()] in [get_area(src)]. It will uncollapse into a white hole. Consider quarantining it off.", "Gravitational Anomaly", alert_origin = ALERT_ANOMALY)
			return

		if(state == "growing")
			state = "active"
			src.visible_message(SPAN_ALERT("<b>[src] uncollapses into a white hole!</b>"))
			playsound(src, 'sound/machines/singulo_start.ogg', 90, FALSE, 5, -1)
			animate(src, transform = matrix(1.2, MATRIX_SCALE), time = 0.3 SECONDS, loop = 0, easing = BOUNCE_EASING)
			animate(transform = matrix(1, MATRIX_SCALE), time = 0.3 SECONDS, loop = 0, easing = BOUNCE_EASING)

		if(time_since_start > grow_duration + active_duration)
			animate(src)
			SPAWN(0)
				animate(src, transform = matrix() / 100, time = 3 SECONDS, loop = 0)
			state = "dying"
			playsound(src, 'sound/machines/singulo_start.ogg', 90, FALSE, 5, -2)

		// push or throw things away from the white hole
		for (var/atom/movable/X in range(7,src))
			if (istype(X, /obj/structure/girder) && prob(40)) //mess up girders too
				X.ex_act(3)
			if (X.event_handler_flags & IMMUNE_SINGULARITY || X.anchored)
				continue

			if(prob(30))
				continue
			else if(prob(50))
				step_away(X, src)
			else
				X.throw_at( \
					locate_throw_target(X), \
					rand(1, 6), \
					randfloat(1, 3), \
					bonus_throwforce = 50 / (1 + GET_DIST(X, src)) \
				)

		for (var/turf/simulated/wall/wall in range(1, src)) //make it a little harder to wall them off
			wall.ex_act(3)
			break //just smack one wall at a time

		var/time_interval = 3 SECONDS
		var/spew_count = round(randfloat(1, 15 * src.activity_modifier))
		spew_out_stuff(src.source_location)
		if(spew_count > 1)
			SPAWN(time_interval / spew_count)
				for(var/i = 1 to spew_count - 1)
					if(QDELETED(src) || state == "dying")
						return
					spew_out_stuff(src.source_location)
					sleep(time_interval / spew_count)


	proc/get_target_mob()
		var/list/mob/living/valid_mobs = list()
		for(var/mob/living/L in view(7, src))
			if(isdead(L))
				continue
			if(ismobcritter(L) && prob(80))
				continue
			valid_mobs += L
		if(length(valid_mobs))
			return pick(valid_mobs)

	proc/generate_thing(source_location)
		var/spawn_type = weighted_pick(src.spawn_probs[source_location])

		// if we roll hotspot or plasma in an "inner" call (for example for flockification or deep frying)
		// we get one reroll to get something else
		if((spawn_type in list(/atom/movable/hotspot/gasfire, "plasma")) && source_location != src.source_location)
			spawn_type = weighted_pick(src.spawn_probs[source_location])
		if (isresource(spawn_type)) //assume it's a sound because it doesn't make sense to shove an icon in here
			playsound(src.loc, spawn_type, 80, FALSE)
			return src.generate_thing(source_location) //re-roll something else so we don't return null
		if(ispath(spawn_type, /atom/movable))
			. = new spawn_type(src.loc)
		else if(ispath(spawn_type, /datum/projectile))
			var/atom/target = null
			if(prob(60))
				target = src.get_target_mob()
			if(isnull(target))
				target = locate(rand(-7, 7) + src.x, rand(-7, 7) + src.y, src.z)
			. = shoot_projectile_ST_pixel_spread(src, new spawn_type, target)
		else if(ispath(spawn_type, /datum/reagent))
			var/datum/reagent/dummy = spawn_type
			var/reagent_id = initial(dummy.id)
			var/amount = rand(20, 150)
			if(prob(10))
				amount *= 10
			if(prob(10))
				amount *= 10
			var/turf/T = get_turf(src)
			T.fluid_react_single(reagent_id, amount)
		else switch(spawn_type)
			if("artifact")
				var/obj/artifact = Artifact_Spawn(src.loc)
				. = artifact
				if(prob(25))
					SPAWN(randfloat(0.1 SECONDS, 15 SECONDS))
						artifact?.ArtifactActivated()
			if("plasma")
				var/datum/gas_mixture/gas = new
				gas.toxins += rand(1, 10)
				if(prob(20))
					gas.toxins += rand(10, 30)
				if(prob(20))
					gas.temperature += rand(100, 300)
				if(prob(20))
					gas.oxygen += rand(1, 10)
				var/turf/T = get_turf(src)
				T.assume_air(gas)
			if("radgas")
				var/datum/gas_mixture/gas = new
				gas.radgas += rand(10, 100)
				if(prob(20))
					gas.radgas += rand(100, 500)
				if(prob(20))
					gas.temperature += rand(100, 3000)
				var/turf/T = get_turf(src)
				T.assume_air(gas)
			if("flockconverted")
				. = generate_thing(pick(valid_locations - list("flock")))
				var/atom/A = .
				if(istype(A))
					A.color = list(-0.2,-0.2,-0.2,-0.2,-0.2,-0.2,-0.25,-0.2,-0.15,0.368627,0.764706,0.666667)
			if("trenchloot")
				spawn_type = pick(childrentypesof(/obj/storage/crate/trench_loot))
				. = new spawn_type(src.loc)
			if("ore")
				. = generate_thing("ore")
			if("randomplant")
				spawn_type = pick(concrete_typesof(pick( \
						/obj/item/reagent_containers/food/snacks/plant, \
						/obj/item/plant \
					)))
				. = new spawn_type(src.loc)
			if("deepfried")
				. = generate_thing(pick(valid_locations))
				var/atom/movable/thing = .
				if(istype(thing))
					var/obj/item/reagent_containers/food/snacks/shell/deepfry/fryholder = new(src.loc)
					var/icon/composite = new(thing.icon, thing.icon_state)
					for(var/O in thing.underlays + thing.overlays)
						var/image/I = O
						composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)
					switch(rand(0, 2))
						if (0)
							fryholder.name = "lightly-fried [thing.name]"
							fryholder.color = ( rgb(166,103,54) )
						if (1)
							fryholder.name = "fried [thing.name]"
							fryholder.color = ( rgb(103,63,24) )
						if (2)
							fryholder.name = "deep-fried [thing.name]"
							fryholder.color = ( rgb(63, 23, 4) )
					fryholder.icon = composite
					fryholder.overlays = thing.overlays
					fryholder.bites_left = 5
					fryholder.uneaten_bites_left = fryholder.bites_left
					if (ismob(thing))
						fryholder.w_class = W_CLASS_BULKY
					if(thing.reagents)
						fryholder.reagents.maximum_volume += thing.reagents.total_volume
						thing.reagents.trans_to(fryholder, thing.reagents.total_volume)
					fryholder.reagents.my_atom = fryholder
					thing.set_loc(fryholder)
					. = fryholder
			if ("medicine")
				spawn_type = pick(concrete_typesof(/obj/item/reagent_containers/glass/bottle))
				. = new spawn_type(src.loc)
			if ("organ")
				spawn_type = pick(concrete_typesof(/obj/item/organ))
				. = new spawn_type(src.loc)
			if ("corpse", "body_bag")
				var/bag_it = (spawn_type == "body_bag")
				spawn_type = pick( //safe jobs that don't introduce too much loot
					1; /mob/living/carbon/human/normal/assistant,
					1; /mob/living/carbon/human/normal/clown,
					1; /mob/living/carbon/human/normal/chef,
					1; /mob/living/carbon/human/normal/botanist,
					1; /mob/living/carbon/human/normal/janitor,
					1; /mob/living/carbon/human/normal/miner,
					6; /mob/living/carbon/human/normal)
				var/mob/living/carbon/human/normal/human = new spawn_type(null)
				human.decomp_stage = rand(DECOMP_STAGE_NO_ROT, DECOMP_STAGE_SKELETONIZED)
				for (var/i in 1 to rand(1, 4))
					var/obj/item/organ/organ = human.drop_organ(pick("left_eye","right_eye","left_lung","right_lung","butt","left_kidney","right_kidney","liver","stomach","intestines","spleen","pancreas","appendix"))
					qdel(organ)
				human.death()
				human.set_loc(src.loc)
				. = human
				if (bag_it)
					var/obj/item/body_bag/bag = new(src.loc)
					bag.UpdateIcon()
					human.is_npc = TRUE // NPC is set for direct mob returns separately
					human.set_loc(bag)
					. = bag
			if("geneinjector")
				var/datum/bioEffect/effect = global.mutini_effects[pick(global.mutini_effects)]
				for(var/i in pick(100; 0,   80; 1,   25; 2,   10; 3,   1; 4))
					var/chromosome_type = pick(typesof(/datum/dna_chromosome))
					var/datum/dna_chromosome/chromosome = new chromosome_type()
					// yes we skipping the apply_check here, the other dimension can break laws of genetics
					chromosome.apply(effect)
				var/obj/item/genetics_injector/dna_injector/inj = new(src.loc)
				if(prob(50))
					inj.name = "dna injector - [effect.name]"
				else
					inj.name = "dna injector - ???"
				inj.BE = effect
				. = inj
			if ("arcflash")
				var/atom/target = null
				if(prob(60))
					target = src.get_target_mob()
				if(isnull(target))
					target = locate(rand(-7, 7) + src.x, rand(-7, 7) + src.y, src.z)
				arcFlash(src, target, rand(4, 6) KILO WATTS)
			if ("fireflash")
				fireflash_melting(src, rand(1, 6), rand(200, 3000), rand(50, 300))
			if ("sticker")
				spawn_type = pick(concrete_typesof(/obj/item/sticker))
				. = new spawn_type(src.loc)
			if ("snake")
				. = generate_thing("wizard")
				var/atom/movable/AM = .
				if (istype(AM) && !QDELETED(AM) && !istype(AM, /obj/projectile))
					var/mob/living/critter/small_animal/snake/snake = new(src.loc, .)
					snake.start_expiration(2 MINUTES)
			if ("wizard crystal")
				spawn_type = pick(concrete_typesof(/obj/item/wizard_crystal))
				. = new spawn_type(src.loc)
			if ("present")
				var/atom/movable/thing = generate_thing(pick(valid_locations))
				if (istype(thing, /obj/projectile))
					qdel(thing)
					. = new /obj/item/a_gift/festive(src.loc)
				else
					. = thing?.gift_wrap(xmas_style = TRUE)
			else
				CRASH("Unknown spawn type: [spawn_type]")

		if(istype(., /obj/item))
			var/obj/item/I = .
			if(I.pixel_x == 0 && I.pixel_y == 0)
				I.pixel_x = rand(-16, 16)
				I.pixel_y = rand(-16, 16)

		if(istype(., /mob/living))
			var/mob/living/L = .
			if(ismobcritter(L))
				L.TakeDamage("chest", rand(0, 15), rand(0, 15), rand(0, 15))
			else
				L.TakeDamage("chest", rand(0, 80), rand(0, 80), rand(0, 80))
			if(ishuman(.))
				var/mob/living/carbon/human/H = .
				H.is_npc = TRUE
				SPAWN(1)
					var/list/limbs = list("l_arm", "r_arm", "l_leg", "r_leg")
					shuffle_list(limbs)
					for(var/i in 1 to pick(5; 0,   10; 1,   10; 2,   5; 3,   2; 4))
						H.limbs?.sever(limbs[i])
					if(prob(25))
						H.emote("scream")
					if(prob(25))
						for(var/i in 1 to 20)
							sleep(rand(3 SECONDS, 35 SECONDS))
							if(isdead(H))
								break
							if(prob(90))
								H.say(phrase_log.random_phrase("say"))
							else
								H.emote("me", TRUE, phrase_log.random_phrase("emote"))
		else if(istype(., /atom/movable/hotspot/gasfire))
			var/atom/movable/hotspot/gasfire/hotspot = .
			hotspot.temperature = rand(FIRE_MINIMUM_TEMPERATURE_TO_EXIST, 6000)
			hotspot.set_real_color()
			SPAWN(rand(10 SECONDS, 2 MINUTES))
				if(!QDELETED(hotspot))
					qdel(hotspot)
		else if(istype(., /obj/item/old_grenade))
			var/obj/item/old_grenade/grenade = .
			if(prob(50))
				SPAWN(rand(1 SECOND, 10 SECONDS))
					grenade.detonate()
		else if(istype(., /obj/item/chem_grenade))
			var/obj/item/chem_grenade/grenade = .
			if(prob(50))
				grenade.arm()
		else if(istype(., /obj/item/reagent_containers/food/snacks/plant/tomato))
			var/obj/item/reagent_containers/food/snacks/plant/tomato/tomato = .
			tomato.reagents.add_reagent("juice_tomato", rand(5, 15))
		else if(istype(., /obj/item/paper))
			var/obj/item/paper/paper = .
			if(!length(paper.info))
				paper.info = phrase_log.random_phrase("paper")
		else if(istype(., /obj/item/sticker/postit) && !istype(., /obj/item/sticker/postit/artifact_paper))
			var/obj/item/sticker/postit/postit = .
			if(!length(postit.words))
				postit.words = phrase_log.random_phrase("paper")
				postit.icon_state = "postit-writing"

		// renaming
		if(istype(., /mob))
			var/mob/M = .
			if(istype(M, /mob/living/silicon/ai) && prob(80))
				M.real_name = phrase_log.random_phrase("name-ai")
			else if(istype(M, /mob/living/silicon/robot) && prob(80))
				M.real_name = phrase_log.random_phrase("name-cyborg")
			else if(istype(M, /mob/living/carbon/human/normal/clown) && prob(80))
				M.real_name = phrase_log.random_phrase("name-clown")
			else if(istype(M, /mob/living/carbon/human) && prob(80))
				M.real_name = phrase_log.random_phrase("name-human")
			if(!M.real_name)
				M.real_name = M.name // revert in case of a fail
			M.name = M.real_name
			M.choose_name(1, null, M.real_name, force_instead=TRUE)

		if(istype(., /obj/machinery/bot))
			var/obj/machinery/bot/B = .
			if(istype(B, /obj/machinery/bot/firebot) && prob(33))
				B.name = phrase_log.random_phrase("name-firebot")
			else if(istype(B, /obj/machinery/bot/secbot) && prob(33))
				B.name = phrase_log.random_phrase("name-secbot")
			else if(istype(B, /obj/machinery/bot/cleanbot) && prob(33))
				B.name = phrase_log.random_phrase("name-cleanbot")
			else if(istype(B, /obj/machinery/bot/mulebot) && prob(33))
				B.name = phrase_log.random_phrase("name-mulebot")
			else if(istype(B, /obj/machinery/bot/medbot) && prob(33))
				B.name = phrase_log.random_phrase("name-medbot")
			else if(istype(B, /obj/machinery/bot/cambot) && prob(33))
				B.name = phrase_log.random_phrase("name-cambot")
			else if(istype(B, /obj/machinery/bot/duckbot) && prob(33))
				B.name = phrase_log.random_phrase("name-duckbot")
			if(!B.name)
				B.name = initial(B.name) // revert in case of a fail

	proc/locate_throw_target(atom/thrown, turf_search_dist = 64)
		var/turf/init_turf = get_turf(thrown)
		var/turf/hole_turf = get_turf(src)
		if(!init_turf || !hole_turf)
			return null
		if(hole_turf.z != init_turf.z)
			return null

		// basically make sure we're not throwing it into a wall
		var/list/valid_sectors = list()
		for(var/dir in global.cardinal)
			var/turf/first_turf = get_step(init_turf, dir)
			if(init_turf != hole_turf && get_step_towards(init_turf, hole_turf) == first_turf) // skip the dir towards the hole
				continue
			if(first_turf.density)
				continue
			for(var/atom/movable/AM in first_turf)
				if(AM.density)
					continue
			var/angle = dir_to_angle(dir)
			// this asymmetry really sucks but that's just how our throwing works :whelm:
			var/angle_size = (dir & (NORTH|SOUTH)) ? 28 : 180 - 28
			valid_sectors += list(list(angle - angle_size / 2, angle + angle_size / 2))

		var/angle
		if(!length(valid_sectors))
			angle = rand(0, 360)
		else
			var/list/sector = pick(valid_sectors)
			angle = rand(sector[1], sector[2])

		var/turf/T = null
		while(isnull(T) && turf_search_dist >= 0)
			T = locate(
				round(init_turf.x + cos(angle) * turf_search_dist),
				round(init_turf.y + sin(angle) * turf_search_dist),
				init_turf.z
			)
			turf_search_dist -= 4

		return T


	proc/spew_out_stuff(source_location)
		if(QDELETED(src))
			return

		animate(src, transform = matrix(1.05, MATRIX_SCALE), time = 0.1 SECONDS, loop = 0, easing = SINE_EASING, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(transform = matrix(1, MATRIX_SCALE), time = 0.1 SECONDS, loop = 0, easing = SINE_EASING)

		var/atom/movable/thing = generate_thing(source_location)
		if(!thing)
			return

		if(istype(thing, /obj/projectile))
			return // don't throw bullets

		var/throw_speed = randfloat(1, 3)
		var/throw_range = 50

		var/turf/T = locate_throw_target(thing)
		if(isnull(T))
			return
		// TODO make the thing pass through things for first few tiles
		thing.throw_at(T, throw_range, throw_speed, allow_anchored=TRUE, bonus_throwforce=30)

	disposing()
		if(src.light)
			qdel(src.light)
			src.light = null
		processing_items.Remove(src)
		if(particleMaster.CheckSystemExists(/datum/particleSystem/whitehole_warning, src))
			particleMaster.RemoveSystem(/datum/particleSystem/whitehole_warning)
		..()



// Particle FX

/datum/particleSystem/whitehole_warning
	New(var/atom/location = null)
		..(location, "whitehole_warning", 300)

	Run()
		if (..())
			for(var/i=0, i<10, i++)
				sleep(rand(3,6))
				SpawnParticle()
			state = 1

/datum/particleType/whitehole_warning
	name = "whitehole_warning"
	icon = 'icons/effects/particles.dmi'
	icon_state = "32x32circle"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += rand(-128,128)
			par.pixel_y += rand(-128,128)
			par.color = "#ffffff"
			par.alpha = 2
			par.plane = PLANE_NOSHADOW_ABOVE

			var/image/illum = par.SafeGetOverlayImage("illum", src.icon, src.icon_state)
			illum.appearance_flags = PIXEL_SCALE | RESET_ALPHA
			illum.plane = PLANE_LIGHTING
			illum.blend_mode = BLEND_ADD
			illum.alpha = 6
			par.AddOverlays(illum, "illum")

			first.Scale(0.1,0.1)
			par.transform = first

			first.Scale(50)
			animate(par, transform = first, time = 15 SECONDS, alpha = 30)

			first.Scale(0.1 / 50)
			animate(transform = first, time = 15 SECONDS, alpha = 5)
			first.Reset()


/datum/fishing_spot/whitehole
	rod_tier_required = 2
	fishing_atom_type = /obj/whitehole

	generate_fish(mob/user, obj/item/fishing_rod/fishing_rod, atom/target)
		var/obj/whitehole/whitehole = target
		if(!istype(whitehole))
			CRASH("generate_fish called on whitehole fishing spot with non-whitehole target")
		var/atom/fish = whitehole.generate_thing(whitehole.source_location)
		fish.name += "fish"
		return fish

	try_fish(mob/user, obj/item/fishing_rod/fishing_rod, atom/target)
		. = ..()
		if(.)
			var/obj/whitehole/whitehole = target
			if(!istype(whitehole))
				CRASH("try_fish called on whitehole fishing spot with non-whitehole target")
			if(prob(5))
				whitehole.spew_out_stuff(whitehole.source_location)
			if(whitehole.state in list("static", "growing"))
				whitehole.grow_duration += 10 SECONDS
				boutput(user, SPAN_NOTICE("You feel the white hole shrink a little."))
			else
				whitehole.active_duration -= 5 SECONDS

#undef VALID_WHITE_HOLE_LOCATIONS
