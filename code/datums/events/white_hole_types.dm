
ABSTRACT_TYPE(/datum/whitehole_spawner)
/datum/whitehole_spawner
	/// A list of types that will be used to spawn stuff
	/// - If the type is abstract, a random concrete subtype will be chosen
	/// - If the type is of "/datum/whitehole_spawner", the unleash() proc will be called on that spawner
	/// - If the type is of "/datum/projectile", that projectile will be launched
	/// - If the type is of "/datum/reagent", that reagent will be released
	var/list/spawn_probs = list()
	var/name = "untitled"
	var/icon_view = "" //! The icon_state of the image that will be used inside the white hole

	/// Pick something for the white hole to do. If a movable atom was released, it should return that atom.
	proc/unleash(var/obj/whitehole/whitehole)
		if(length(src.spawn_probs) == 0)
			boutput(world, "Test B")
			return null
		var/spawn_type = weighted_pick(src.spawn_probs)
		boutput(world, "Test: [spawn_type]")

		if(IS_ABSTRACT(spawn_type))
			spawn_type = pick(concrete_typesof(spawn_type))
		if(ispath(spawn_type, /datum/whitehole_spawner))
			var/datum/whitehole_spawner/spawner = new spawn_type
			return spawner.unleash(whitehole)
		else if(ispath(spawn_type, /datum/projectile))
			return src.unleash_projectile(whitehole, spawn_type, 60)
		else if(ispath(spawn_type, /datum/reagent))
			// Can use the reagent datum as a lazy way to spawn reagents without creating a new spawner
			var/datum/whitehole_spawner/reagent/spawner = new()
			spawner.reagent_probs = list(spawn_type = 1)
			if(prob(10))
				spawner.amount_max *= 10
			if(prob(10))
				spawner.amount_max *= 10
			return spawner.unleash(whitehole)

		var/atom/movable/AM = new spawn_type(whitehole.loc)
		return AM

	proc/unleash_projectile(var/obj/whitehole/whitehole, var/proj_path, var/target_prob)
		var/atom/target = null
		if(prob(target_prob))
			target = whitehole.get_target_mob()
		if(isnull(target))
			target = locate(rand(-7, 7) + whitehole.x, rand(-7, 7) + whitehole.y, whitehole.z)
		return shoot_projectile_ST_pixel_spread(whitehole, new proj_path, target)

// ===============================================================================
// =========================== Main White Hole Types =============================
// ===============================================================================

ABSTRACT_TYPE(/datum/whitehole_spawner/main)
/datum/whitehole_spawner/main
/datum/whitehole_spawner/main/artlab
	name = "artlab"
	icon_view = "artlab"
	spawn_probs = list(
		/datum/whitehole_spawner/artifact = 60,
		/datum/whitehole_spawner/written_paper = 5,
		/datum/whitehole_spawner/written_postit = 2,

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
		#ifdef SECRETS_ENABLED
		/mob/living/carbon/human/npc/monkey/extremely_fast = 0.05,
		#endif
	)

/datum/whitehole_spawner/main/teg
	name = "TEG"
	icon_view = "teg"
	spawn_probs = list(
		/datum/whitehole_spawner/gas/plasma_mix_small = 40,
		/datum/whitehole_spawner/gas/plasma_large = 10,
		/datum/whitehole_spawner/arcflash = 30,
		/datum/whitehole_spawner/written_paper = 2,

		/atom/movable/hotspot/gasfire = 90,
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
	)

/datum/whitehole_spawner/main/flock
	name = "flock"
	icon_view = "flock"
	spawn_probs = list(
		/datum/whitehole_spawner/flock_converted = 15,

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
	)

/datum/whitehole_spawner/main/chapel
	name = "chapel"
	icon_view = "chapel"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 3,
		/datum/whitehole_spawner/written_postit = 1,

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
		/obj/item/skull/hunter = 0.1,
		/obj/item/skull/changeling = 0.1,
		/obj/item/skull/wizard = 0.1,
		/obj/item/skull/vampire = 0.1,
		/obj/item/skull/omnitraitor = 0.1,
		/obj/item/skull/macho = 0.1,
		/obj/item/skull/cluwne = 0.1,
		/mob/living/carbon/human/normal/chaplain = 0.2,
		/mob/living/critter/skeleton = 1,
		/obj/item/gun/energy/ghost = 0.2,
		/obj/item/reagent_containers/food/snacks/ectoplasm = 4,
		/datum/reagent/water/water_holy = 1,
		/datum/reagent/blood = 1,
		/obj/item/kitchen/utensil/knife = 1,
		/obj/critter/spirit = 1,
	)

/datum/whitehole_spawner/main/trench
	name = "trench"
	icon_view = "trench"
	spawn_probs = list(
		/datum/whitehole_spawner/ore/random = 5,
		/datum/whitehole_spawner/parent/trench_loot = 5,

		/datum/reagent/water/sea = 20,
		/obj/item/seashell = 2,
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
	)

/datum/whitehole_spawner/main/asteroid
	name = "asteroid"
	icon_view = "asteroid"
	spawn_probs = list(
		/datum/whitehole_spawner/ore/random = 200,

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
	)

/datum/whitehole_spawner/main/cafeteria
	name = "cafeteria"
	icon_view = "cafeteria"
	spawn_probs = list(
		/datum/whitehole_spawner/deep_fried = 2,
		/datum/whitehole_spawner/written_paper = 3,

		/obj/item/plate = 10,
		/obj/item/kitchen/utensil/fork = 10,
		/obj/item/kitchen/utensil/knife = 10,
		/obj/item/kitchen/utensil/spoon = 10,
		/obj/item/kitchen/utensil/knife/bread = 1,
		/obj/item/kitchen/utensil/knife/cleaver = 1,
		/obj/item/kitchen/utensil/knife/pizza_cutter = 1,
		/obj/item/ladle = 0.2,
		/obj/item/kitchen/rollingpin = 0.5,

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
	)

/datum/whitehole_spawner/main/singulo
	name = "singulo"
	icon_view = "singulo"
	spawn_probs = list(
		/datum/whitehole_spawner/arcflash = 5,
		/datum/whitehole_spawner/written_paper = 3,

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
	)

/datum/whitehole_spawner/main/plasma
	name = "plasma"
	icon_view = "plasma"
	spawn_probs = list(
		/datum/whitehole_spawner/gas/plasma_mix_small = 80,
		/datum/whitehole_spawner/gas/plasma_large = 20,

		/obj/critter/spore = 3,
		/obj/item/raw_material/shard/plasmacrystal = 1,
		/obj/item/raw_material/plasmastone = 1,
	)

/datum/whitehole_spawner/main/nukies
	name = "nukies"
	icon_view = "nukies"
	spawn_probs = list(
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
	)

/datum/whitehole_spawner/main/hell
	name = "hell"
	icon_view = "hell"
	spawn_probs = list(
		/datum/whitehole_spawner/fireflash = 15,
		/datum/whitehole_spawner/corpse = 5,
		/datum/whitehole_spawner/written_paper = 3,

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
		/obj/critter/bat/hellbat = 5,
		// yeah idk where I was going with "hell" either
	)

/datum/whitehole_spawner/main/botany
	name = "botany"
	icon_view = "botany"
	spawn_probs = list(
		/datum/whitehole_spawner/plant = 100,
		/datum/whitehole_spawner/written_paper = 3,

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
		/obj/critter/killertomato = 0.5,
		/mob/living/critter/small_animal/cat/synth = 1,
		/mob/living/critter/plant/maneater = 0.3,
		/obj/item/plant/tumbling_creeper = 3,
	)

/datum/whitehole_spawner/main/maint
	name = "maintanence"
	icon_view = "maint"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 5,
		/datum/whitehole_spawner/written_postit = 1,
		/datum/whitehole_spawner/bot_named/firebot = 2,
		/datum/whitehole_spawner/bot_named/cleanbot = 2,
		/datum/whitehole_spawner/bot_named/floorbot = 2,

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
		/obj/item/storage/pill_bottle/cyberpunk = 10,
		/obj/item/reagent_containers/food/drinks/bottle/hobo_wine = 10,
		/obj/item/plant/herb/cannabis/spawnable = 5,
		/mob/living/critter/spider/baby = 2,
		/mob/living/critter/spider/nice = 2,
		/mob/living/carbon/human/npc/assistant = 2,
		/mob/living/carbon/human/normal/assistant = 2,
		#ifdef SECRETS_ENABLED
		/mob/living/critter/legman = 1,
		#endif
	)

/datum/whitehole_spawner/main/ai
	name = "AI"
	icon_view = "ai"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 2,

		/datum/projectile/laser/heavy/ai_turret = 30,
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
		/obj/item/clothing/suit/cardboard_box/ai = 1,
		/obj/item/disk/data/floppy/manudrive/ai = 1,
		/obj/item/aiModule/ability_expansion/doctor_vision = 0.5,
		/obj/item/aiModule/ability_expansion/proto_teleman = 0.2
	)

/datum/whitehole_spawner/main/bridge
	name = "bridge"
	icon_view = "bridge"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 6,
		/datum/whitehole_spawner/written_postit = 4,
		/datum/whitehole_spawner/parent/sticker = 4,

		/obj/item/reagent_containers/food/drinks/drinkingglass/flute = 10,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 3,
		/obj/item/toy/judge_gavel = 1,
		/obj/stool/chair/comfy = 5,
		/mob/living/critter/small_animal/cat/jones = 5,
		/obj/item/clothing/suit/bedsheet/captain = 2,
		/obj/item/card/id/gold/captains_spare = 0.1,
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
	)

/datum/whitehole_spawner/main/clown
	name = "clown"
	icon_view = "clown"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 1,
		/datum/whitehole_spawner/written_postit = 1,
		/datum/whitehole_spawner/parent/sticker = 3,

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
	)

/datum/whitehole_spawner/main/medbay
	name = "medbay"
	icon_view = "medbay"
	spawn_probs = list(
		/datum/whitehole_spawner/bot_named/medbot = 6,
		/datum/whitehole_spawner/parent/medicine = 20,
		/datum/whitehole_spawner/parent/organ = 20,
		/datum/whitehole_spawner/corpse = 2,
		/datum/whitehole_spawner/gene_injector = 3,
		/datum/whitehole_spawner/written_paper = 1,
		/datum/whitehole_spawner/written_postit = 0.5,

		/obj/item/surgical_spoon = 5,
		/obj/item/scalpel = 5,
		/obj/item/circular_saw = 5,
		/obj/item/hemostat = 5,
		/obj/item/scissors/surgical_scissors = 5,
		/obj/machinery/optable = 2,
		/obj/item/reagent_containers/hypospray = 5,
		/obj/item/reagent_containers/syringe = 10,
		/obj/item/clothing/gloves/latex = 5,
		/obj/item/robodefibrillator = 1,
		/obj/item/storage/firstaid/oxygen = 4,
		/obj/item/storage/firstaid/brute = 4,
		/obj/item/storage/firstaid/fire = 4,
		/obj/item/storage/firstaid/regular = 4,
		/obj/item/storage/firstaid/toxin = 4,
		/obj/machinery/manufacturer/medical = 2,
		/datum/reagent/blood = 5,
		/datum/reagent/fooddrink/caffeinated/coffee = 2,
	)

/datum/whitehole_spawner/main/security
	name = "security"
	icon_view = "security"
	spawn_probs = list(
		/datum/whitehole_spawner/bot_named = 4,
		/datum/whitehole_spawner/written_paper = 1,
		/datum/whitehole_spawner/written_postit = 0.5,

		/obj/item/handcuffs/guardbot = 5,
		/datum/projectile/special/spawner/handcuff = 5,
		/obj/item/handcuffs = 2,
		/obj/itemspecialeffect/barrier = 3,
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
		/obj/item/barrier/collapsible/security = 1,
		/mob/living/carbon/human/npc/monkey/stirstir = 1,
		/datum/projectile/energy_bolt = 3,
		/datum/projectile/energy_bolt/burst = 3,
		/datum/projectile/energy_bolt/tasershotgun = 3,
		/datum/projectile/energy_bolt/bouncy = 3,
	)

/datum/whitehole_spawner/main/cargo
	name = "cargo"
	icon_view = "cargo"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 15,

		/obj/item/currency/spacecash/five = 10,
		/obj/item/currency/spacecash/ten = 10,
		/obj/item/currency/spacecash/twenty = 10,
		/obj/item/currency/spacecash/fifty = 5,
		/obj/item/currency/spacecash/hundred = 3,
		/obj/item/currency/spacecash/fivehundred = 0.3,
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
	)

/datum/whitehole_spawner/main/nuclear
	name = "nuclear reactor"
	icon_view = "nuclear"
	spawn_probs = list(
		/datum/whitehole_spawner/gas/radgas_small = 40,
		/datum/whitehole_spawner/gas/radgas_large = 10,
		/datum/whitehole_spawner/gas/plasma_mix_small = 25,
		/datum/whitehole_spawner/gas/plasma_large = 5,

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
	)

/datum/whitehole_spawner/main/janitorial
	name = "janitorial"
	icon_view = "janitorial"
	spawn_probs = list(
		/datum/whitehole_spawner/corpse/bagged = 2,

		/obj/machinery/bot/cleanbot = 5,
		/obj/machinery/bot/cleanbot/emagged = 3,
		/obj/item/caution = 10,
		/obj/item/caution/traitor = 2,
		/obj/item/spraybottle/cleaner = 5,
		/obj/item/reagent_containers/glass/bottle/cleaner = 3,
		/obj/item/reagent_containers/glass/bottle/acetone/janitors = 3,
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
	)

/datum/whitehole_spawner/main/wizard
	name = "wizard"
	icon_view = "wizard"
	spawn_probs = list(
		/datum/whitehole_spawner/snake = 10,
		/obj/item/wizard_crystal = 1,

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
		/obj/item/paper/image/businesscard/cosmicacres = 2,
		/datum/projectile/fireball = 5,
		/datum/projectile/special/homing/magicmissile/weak = 20,
		/datum/projectile/special/homing/magicmissile = 15,
		/datum/projectile/artifact/prismatic_projectile = 20,
		/obj/forcefield/autoexpire = 4,
		/obj/decal/icefloor = 10,
		/obj/lightning_target = 10,
		/obj/item/clothing/gloves/ring/wizard/blink = 0.1,
		/obj/item/clothing/gloves/ring/wizard/forcewall = 0.1,
		/obj/item/enchantment_scroll = 0.5,
	)

/datum/whitehole_spawner/main/spacemas
	name = "spacemas"
	icon_view = "spacemas"
	spawn_probs = list(
		/datum/whitehole_spawner/gift = 25,

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
	)

/datum/whitehole_spawner/main/basketball
	name = "basketball"
	icon_view = "basketball"
	spawn_probs = list(
		/obj/item/basketball = 15,
		/obj/item/bballbasket = 4,
		/obj/item/clothing/under/referee = 3,
		/obj/item/clothing/under/jersey/red = 5,
		/obj/item/clothing/under/jersey/blue = 5,
		/obj/item/clothing/under/jersey/green = 4,
		/obj/item/clothing/under/jersey/purple = 4,
		/obj/item/clothing/under/jersey/black = 3,
		/obj/item/clothing/shoes/white = 2,
		/obj/newmeteor/basketball = 4,
		/obj/item/trophy = 1,
		/obj/item/instrument/whistle = 4,
		/obj/item/instrument/bikehorn/airhorn = 3,
		/obj/item/basketball/lethal = 0.3,
		/obj/item/reagent_containers/food/snacks/hotdog = 3,
		/obj/item/reagent_containers/food/drinks/energyshake = 3,
		/obj/item/reagent_containers/pill/crank = 2,
		/obj/item/reagent_containers/pill/methamphetamine = 4,
		/mob/living/carbon/human/referee = 1
	)

// ===============================================================================
// ============================== Spawner Subtypes ===============================
// ===============================================================================

/// Used to return random objects for transforming, deep frying, gift wrapping, or whatever else.
/// Will avoid anything that is not a movable atom, including projectiles.
/datum/whitehole_spawner/random_object
	name = "random object"
	unleash(var/obj/whitehole/whitehole)
		RETURN_TYPE(/atom/movable)
		var/list/availible_types = concrete_typesof(/datum/whitehole_spawner/main)
		var/spawn_type = null
		while(!ispath(spawn_type, /atom/movable))
			spawn_type = pick(availible_types)
			while(ispath(spawn_type, /datum/whitehole_spawner))
				// Keep looking through spawners until you find something or nothing
				var/datum/whitehole_spawner/spawner = new spawn_type
				spawn_type = weighted_pick(spawner.spawn_probs)
		var/atom/movable/AM = new spawn_type(whitehole.loc)
		return AM

/datum/whitehole_spawner/artifact
	name = "random artifact"
	icon_view = "artlab"
	var/force_origin = null //! If set with an ID, will force the artifact to be of that origin
	var/auto_activate_prob = 25 //! Percent chance that the artifact will activate itself
	var/auto_activate_delay_max = 15 SECONDS //! Maximum delay before the artifact self-activates

	unleash(var/obj/whitehole/whitehole)
		var/datum/artifact_origin/origin = artifact_controls.get_origin_from_string(src.force_origin)
		var/obj/artifact = Artifact_Spawn(whitehole.loc, origin)
		if(prob(src.auto_activate_prob))
			SPAWN(randfloat(0.1 SECONDS, src.auto_activate_delay_max))
				artifact?.ArtifactActivated()
		return artifact

/datum/whitehole_spawner/ore
	name = "ore"
	var/stack_max = 1
	var/stack_min = 1

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		if(isitem(selected))
			var/obj/item/I = selected
			var/stack_size = min(rand(src.stack_min, src.stack_max), I.max_stack)
			I.set_stack_amount(stack_size)
		return selected

	random
		name = "ore random"
		spawn_probs = list(
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
		)

ABSTRACT_TYPE(/datum/whitehole_spawner/gas)
/datum/whitehole_spawner/gas
	var/list/gas_list = null //! Which gases will be released and how much
	var/amount_mult_max = 1 //! Randomly multiplies the amount of each gas by 1 to "mult_max"
	var/temperature_max = 0
	var/temperature_min = 0

	unleash(var/obj/whitehole/whitehole)
		var/datum/gas_mixture/mixture = new()
		src.set_gases(mixture)
		src.set_temperature(mixture)
		var/turf/T = get_turf(whitehole)
		T.assume_air(mixture)
		return null

	proc/set_gases(var/datum/gas_mixture/mixture)
		for(var/gas in src.gas_list)
			switch(gas)
				if("oxygen")
					mixture.oxygen = src.gas_list[gas] * rand(1, src.amount_mult_max)
				if("plasma")
					mixture.toxins = src.gas_list[gas] * rand(1, src.amount_mult_max)
				if("radgas")
					mixture.radgas = src.gas_list[gas] * rand(1, src.amount_mult_max)
				if("nitrogen")
					mixture.nitrogen = src.gas_list[gas] * rand(1, src.amount_mult_max)

	proc/set_temperature(var/datum/gas_mixture/mixture)
		mixture.temperature = rand(src.temperature_min, temperature_max)

	plasma_mix_small
		name = "gas: plasma small"
		gas_list = list("plasma" = 1, "oxygen" = 1)
		amount_mult_max = 10

	plasma_large
		name = "gas: plasma large"
		gas_list = list("plasma" = 10)
		amount_mult_max = 3
		temperature_max = 300

	radgas_small
		name = "gas: fallout small"
		gas_list = list("radgas" = 10)
		amount_mult_max = 10
		temperature_max = 300

	radgas_large
		name = "gas: fallout large"
		gas_list = list("radgas" = 100)
		amount_mult_max = 5
		temperature_max = 300

/datum/whitehole_spawner/plant
	name = "random plant"
	icon_view = "botany"
	spawn_probs = list(
		/obj/item/reagent_containers/food/snacks/plant = 1,
		/obj/item/plant = 1,
		/obj/item/clothing/head/flower = 1
	)

/datum/whitehole_spawner/corpse
	name = "corpse"
	spawn_probs = list(
		/mob/living/carbon/human/normal = 6,
		/mob/living/carbon/human/normal/assistant = 1,
		/mob/living/carbon/human/normal/clown = 1,
		/mob/living/carbon/human/normal/chef = 1,
		/mob/living/carbon/human/normal/botanist = 1,
		/mob/living/carbon/human/normal/janitor = 1,
		/mob/living/carbon/human/normal/miner = 1
	)
	var/bagged = FALSE
	var/decomp_max = DECOMP_STAGE_SKELETONIZED
	var/decomp_min = DECOMP_STAGE_NO_ROT

	unleash(var/obj/whitehole/whitehole)
		. = ..()
		var/mob/living/carbon/human/H = .
		H.decomp_stage = rand(src.decomp_min, src.decomp_max)
		for (var/i in 1 to rand(1, 4))
			var/obj/item/organ/organ = H.drop_organ(pick("left_eye","right_eye","left_lung","right_lung","butt","left_kidney","right_kidney","liver","stomach","intestines","spleen","pancreas","appendix"))
			qdel(organ)
		H.death()
		if(src.bagged)
			var/obj/item/body_bag/bag = new(whitehole.loc)
			bag.UpdateIcon()
			H.is_npc = TRUE // NPC is set for direct mob returns separately
			H.set_loc(bag)
			return bag
		return H

/datum/whitehole_spawner/corpse/bagged
	name = "corpse: bagged"
	bagged = TRUE

/datum/whitehole_spawner/gene_injector
	name = "gene injector"
	var/unlabeled_prob = 50 //! Percent chance that the injector will be labed as "???"

	unleash(var/obj/whitehole/whitehole)
		var/datum/bioEffect/effect = global.mutini_effects[pick(global.mutini_effects)]
		for(var/i in pick(100; 0,   80; 1,   25; 2,   10; 3,   1; 4))
			var/chromosome_type = pick(typesof(/datum/dna_chromosome))
			var/datum/dna_chromosome/chromosome = new chromosome_type()
			// yes we skipping the apply_check here, the other dimension can break laws of genetics
			chromosome.apply(effect)
		var/obj/item/genetics_injector/dna_injector/inj = new(whitehole.loc)
		if(prob(src.unlabeled_prob))
			inj.name = "dna injector - [effect.name]"
		else
			inj.name = "dna injector - ???"
		inj.BE = effect
		return inj

/datum/whitehole_spawner/arcflash
	name = "arcflash"
	var/watts_max = 6 KILO WATTS
	var/watts_min = 4 KILO WATTS
	var/target_chance = 60

	unleash(var/obj/whitehole/whitehole)
		var/atom/target = null
		if(prob(src.target_chance))
			target = whitehole.get_target_mob()
		if(isnull(target))
			target = locate(rand(-7, 7) + whitehole.x, rand(-7, 7) + whitehole.y, whitehole.z)
		arcFlash(whitehole, target, rand(watts_min, watts_max))
		return null

/datum/whitehole_spawner/fireflash
	name = "fireflash"
	var/radius_max = 6
	var/radius_min = 1
	var/temperature_max = 3000 KELVIN
	var/temperature_min = 200 KELVIN
	var/falloff_max = 300
	var/falloff_min = 50

	unleash(var/obj/whitehole/whitehole)
		var/radius = rand(src.radius_min, src.radius_max)
		var/temperature = rand(src.temperature_min, src.temperature_max)
		var/falloff = rand(src.falloff_min, src.falloff_max)
		fireflash_melting(whitehole, radius, temperature, falloff)
		return null

/datum/whitehole_spawner/reagent
	var/list/reagent_probs = list()
	var/amount_max = 150
	var/amount_min = 20

	unleash(var/obj/whitehole/whitehole)
		var/reagent_type = weighted_pick(src.reagent_probs)
		var/datum/reagent/dummy = new reagent_type
		var/reagent_id = initial(dummy.id)
		var/amount = rand(src.amount_min, src.amount_max)
		if(prob(10))
			amount *= 10
		if(prob(10))
			amount *= 10
		var/turf/T = get_turf(src)
		T.fluid_react_single(reagent_id, amount)
		return null

ABSTRACT_TYPE(/datum/whitehole_spawner/child_types)
/// Used to spawn child types of a thing instead of the type itself
/datum/whitehole_spawner/parent
	var/list/spawn_probs_parents = list()

	unleash(var/obj/whitehole/whitehole)
		src.spawn_probs = list(pick(concrete_typesof(weighted_pick(src.spawn_probs_parents))) = 1)
		return ..()

	sticker
		name = "random sticker"
		spawn_probs_parents = list(/obj/item/sticker = 1)
	medicine
		name = "random medicine"
		spawn_probs_parents = list(/obj/item/reagent_containers/glass/bottle = 1)
	organ
		name = "random organ"
		spawn_probs_parents = list(/obj/item/organ = 1)
	trench_loot
		name = "random trench loot"
		spawn_probs_parents = list(/obj/storage/crate/trench_loot = 1)

/datum/whitehole_spawner/gift
	name = "random gift"
	spawn_probs = list(/datum/whitehole_spawner/random_object = 1)

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		if(istype(selected, /atom/movable))
			var/atom/movable/AM = selected
			return AM.gift_wrap(xmas_style = TRUE)
		return new /obj/item/a_gift/festive(whitehole.loc)

/datum/whitehole_spawner/flock_converted
	name = "converted flock"
	spawn_probs = list(/datum/whitehole_spawner/random_object = 1)

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		if(isatom(selected))
			var/atom/A = selected
			A.color = list(-0.2,-0.2,-0.2,-0.2,-0.2,-0.2,-0.25,-0.2,-0.15,0.368627,0.764706,0.666667)
		return selected

/datum/whitehole_spawner/deep_fried
	name = "deep fried"
	spawn_probs = list(/datum/whitehole_spawner/random_object = 1)

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		if(!istype(selected, /atom/movable))
			return null
		var/atom/movable/AM = selected
		var/obj/item/reagent_containers/food/snacks/shell/deepfry/fryholder = new(whitehole.loc)
		var/icon/composite = new(AM.icon, AM.icon_state)
		for(var/O in AM.underlays + AM.overlays)
			var/image/I = O
			composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)
		switch(rand(0, 2))
			if (0)
				fryholder.name = "lightly-fried [AM.name]"
				fryholder.color = ( rgb(166,103,54) )
			if (1)
				fryholder.name = "fried [AM.name]"
				fryholder.color = ( rgb(103,63,24) )
			if (2)
				fryholder.name = "deep-fried [AM.name]"
				fryholder.color = ( rgb(63, 23, 4) )
		fryholder.icon = composite
		fryholder.overlays = AM.overlays
		fryholder.bites_left = 5
		fryholder.uneaten_bites_left = fryholder.bites_left
		if (ismob(AM))
			fryholder.w_class = W_CLASS_BULKY
		if(AM.reagents)
			fryholder.reagents.maximum_volume += AM.reagents.total_volume
			AM.reagents.trans_to(fryholder, AM.reagents.total_volume)
		fryholder.reagents.my_atom = fryholder
		AM.set_loc(fryholder)
		return fryholder

/datum/whitehole_spawner/written_postit
	name = "written sticky note"

	unleash(var/obj/whitehole/whitehole)
		// Done like this in case alternative postit note types are added in the future
		var/obj/item/sticker/postit/postit = new(whitehole.loc)
		if(length(postit.words) == 0)
			postit.words = phrase_log.random_phrase("paper")
			postit.icon_state = "postit-writing"
		return postit

/datum/whitehole_spawner/written_paper
	name = "written paper"

	unleash(var/obj/whitehole/whitehole)
		var/obj/item/paper/paper = new(whitehole.loc)
		if(length(paper.info) == 0)
			paper.info = phrase_log.random_phrase("paper")
		return paper

ABSTRACT_TYPE(/datum/whitehole_spawner/bot_named)
/datum/whitehole_spawner/bot_named
	var/name_category = null
	var/name_prob = 33

	unleash(var/obj/whitehole/whitehole)
		var/obj/machinery/bot/B = ..()
		if(prob(name_prob))
			B.name = phrase_log.random_phrase(name_category)
		return B

	firebot
		name = "bot: firebot"
		spawn_probs = list(/obj/machinery/bot/firebot = 1)
		name_category = "name-firebot"
	floorbot
		name = "bot: floorbot"
		spawn_probs = list(/obj/machinery/bot/floorbot = 1)
		name_category = "name-floorbot"
	secbot
		name = "bot: secbot"
		spawn_probs = list(
			/obj/machinery/bot/secbot = 1,
			/obj/machinery/bot/secbot/emagged = 3,
		)
		name_category = "name-secbot"
	cleanbot
		name = "bot: cleanbot"
		spawn_probs = list(
			/obj/machinery/bot/cleanbot = 5,
			/obj/machinery/bot/cleanbot/emagged = 3
		)
		name_category = "name-cleanbot"
	mulebot
		name = "bot: mulebot"
		spawn_probs = list(/obj/machinery/bot/mulebot = 1)
		name_category = "name-mulebot"
	medbot
		name = "bot: medbot"
		spawn_probs = list(
			/obj/machinery/bot/medbot = 5,
			/obj/machinery/bot/medbot/mysterious/emagged = 1,
		)
		name_category = "name-medbot"
	cambot
		name = "bot: cambot"
		spawn_probs = list(/obj/machinery/bot/cambot = 1)
		name_category = "name-cambot"
	duckbot
		name = "bot: duckbot"
		spawn_probs = list(/obj/machinery/bot/duckbot = 1)
		name_category = "name-duckbot"

/datum/whitehole_spawner/snake
	name = "wizard snake"
	spawn_probs = list(
		/datum/whitehole_spawner/main/wizard = 1
	)

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		if(!istype(selected, /atom/movable))
			return selected
		var/atom/movable/AM = selected
		if(QDELETED(AM))
			return selected
		if(istype(AM, /obj/projectile))
			return selected
		var/mob/living/critter/small_animal/snake/snake = new(whitehole.loc, AM)
		snake.start_expiration(2 MINUTES)


