#define WHITEHOLE_COMMON 100
#define WHITEHOLE_UNCOMMON 30
#define WHITEHOLE_RARE 10

ABSTRACT_TYPE(/datum/whitehole_spawner)
/datum/whitehole_spawner
	/// A weighted list that will be used to spawn stuff
	/// - Pick instance of "/datum/whitehole_spawner": Call unleash() on it
	/// - Pick abstract path: Pick a random subtype
	/// - Pick path of "/datum/whitehole_spawner": Create and call unleash() on it
	/// - Pick path of "/datum/projectile": Launch that projectile
	var/list/spawn_probs = list()
	var/name = "untitled"
	var/icon_view = "" //! The icon_state of the image that will be displayed inside the white hole
	/// Ignore gasses, reagents, projectiles, spawner effects, or anything that isn't a movable atom.
	/// For white hole spawners, will select from their "spawn_probs" list directly instead of calling "unleash()".
	var/ignore_datums = FALSE
	var/weight_rarity = 0 //! How likely that this type of white hole is going to be chosen randomly

	/// The white hole will call this proc whenever it needs something to spew out.
	/// The proc will either get something, or call "unleash()" on another nested spawner to get something.
	/// When a spawner finally picks a non-spawner, it will create a new instance of that thing.
	/// That thing will then be returned (and possibly modified) back up the chain until it is passed over to the white hole.
	proc/unleash(var/obj/whitehole/whitehole)
		if(length(src.spawn_probs) == 0)
			return null
		var/selected = null
		if(ignore_datums)
			selected = src.pick_movable_atom(whitehole)
		else
			selected = weighted_pick(src.spawn_probs)

		if(istype(selected, /datum/whitehole_spawner))
			var/datum/whitehole_spawner/spawner = selected
			return spawner.unleash(whitehole)

		var/spawn_type = selected
		if(IS_ABSTRACT(spawn_type))
			spawn_type = pick(concrete_typesof(spawn_type))
		if(ispath(spawn_type, /datum/whitehole_spawner))
			var/datum/whitehole_spawner/spawner = new spawn_type
			return spawner.unleash(whitehole)
		else if(ispath(spawn_type, /datum/projectile))
			return src.unleash_projectile(whitehole, spawn_type, 60)

		var/atom/movable/AM = new spawn_type(whitehole.loc)
		return AM

	proc/add_spawn(var/weight, var/datum/whitehole_spawner/new_spawner)
		src.spawn_probs[new_spawner] = weight

	/// Easy way to spawn reagents out of the white hole.
	proc/add_reagent(var/weight, var/reagent_type)
		src.add_spawn(weight, new /datum/whitehole_spawner/reagent(reagent_type))

	/// Adds a gas spawner. If in a list, gases should be weighted based on their relative ratios.
	proc/add_gas(var/weight, var/gases, var/amount_min, var/amount_max, var/temp_min, var/temp_max)
		var/datum/whitehole_spawner/gas/gas_spawner = new(gases, amount_min, amount_max, temp_min, temp_max)
		src.add_spawn(weight, gas_spawner)

	/// Easy way to spawn mobs out of the white hole. Renames and damages them.
	proc/add_mob(var/weight, var/mob_type, var/name_category = null)
		var/datum/whitehole_spawner/damager/dmg_spawner
		if(name_category)
			var/datum/whitehole_spawner/renamer/rename_spawner = new(mob_type, name_category, 80 PERCENT)
			dmg_spawner = new(rename_spawner)
		else
			dmg_spawner = new(mob_type)
		src.add_spawn(weight, dmg_spawner)

	/// Used to return something for transforming, deep frying, gift wrapping, or whatever else.
	/// Will skip over unleash() procs and ignore anything that is not a movable atom, including projectiles.
	proc/pick_movable_atom(var/obj/whitehole/whitehole)
		var/datum/whitehole_spawner/spawner = src
		var/selected = null
		while(!ispath(selected, /atom/movable))
			selected = weighted_pick(src.spawn_probs)
			while(ispath(selected, /datum/whitehole_spawner) || istype(selected, /datum/whitehole_spawner))
				// Keep looking through spawners until you find something or nothing
				if(ispath(selected, /datum/whitehole_spawner))
					spawner = new selected
				else
					spawner = selected
				selected = weighted_pick(spawner.spawn_probs)
		return selected

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

/// A type that is just used to store primary locations that will likely be used by the white hole.
/// "/datum/whitehole_spawner/random_object" will pick something stored in these types.
ABSTRACT_TYPE(/datum/whitehole_spawner/main)
/datum/whitehole_spawner/main
	weight_rarity = WHITEHOLE_COMMON

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
	)

	New()
		. = ..()
		add_mob(0.5, /mob/living/carbon/human/npc/monkey)
		#ifdef SECRETS_ENABLED
		add_mob(0.05, /mob/living/carbon/human/npc/monkey/extremely_fast)
		#endif
		add_mob(0.5, /mob/living/carbon/human/normal/scientist, "name-human")

/datum/whitehole_spawner/main/teg
	name = "TEG"
	icon_view = "teg"
	spawn_probs = list(
		/datum/whitehole_spawner/arcflash = 30,
		/datum/whitehole_spawner/written_paper = 2,
		/datum/whitehole_spawner/hotspot = 90,

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

	New()
		. = ..()
		add_spawn(5, new /datum/whitehole_spawner/grenade_armed(/obj/item/chem_grenade/firefighting))
		add_mob(0.5, /mob/living/carbon/human/normal/engineer, "name-human")
		add_mob(0.1, /mob/living/carbon/human/normal/chiefengineer, "name-human")
		add_mob(0.5, /mob/living/carbon/human/npc/monkey/mr_rathen)
		add_gas(40, list("plasma" = 1, "oxygen" = 1), 1, 20, 0 KELVIN, 100 KELVIN)
		add_gas(10, "plasma", 10, 30, 0 KELVIN, 300 KELVIN)

/datum/whitehole_spawner/main/flock
	name = "flock"
	icon_view = "flock"
	spawn_probs = list(
		/datum/whitehole_spawner/flock_converted = 15,

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
	)

	New()
		. = ..()
		add_mob(2, /mob/living/critter/flock/drone)
		add_reagent(3, /datum/reagent/flockdrone_fluid)

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
		/obj/item/gun/energy/ghost = 0.2,
		/obj/item/reagent_containers/food/snacks/ectoplasm = 4,
		/obj/item/kitchen/utensil/knife = 1,
		/obj/critter/spirit = 1,
	)

	New()
		. = ..()
		add_mob(2, /mob/living/critter/aquatic/fish/nautilus)
		add_mob(0.2, /mob/living/carbon/human/normal/chaplain, "name-human")
		add_mob(1, /mob/living/critter/skeleton)
		add_reagent(1, /datum/reagent/water/water_holy)
		add_reagent(1, /datum/reagent/blood)

/datum/whitehole_spawner/main/trench
	name = "trench"
	icon_view = "trench"
	spawn_probs = list(
		/datum/whitehole_spawner/ore = 5,

		/obj/item/seashell = 2,
		/obj/critter/gunbot/drone/gunshark = 0.5,
		/obj/critter/gunbot/drone/buzzdrone/fish = 0.8,
		/obj/naval_mine/standard = 0.2,
		/obj/naval_mine/vandalized = 0.2,
		/obj/naval_mine/rusted = 0.2,
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
		/obj/machinery/vehicle/tank/minisub/mining = 0.5,
	)

	New()
		. = ..()
		add_spawn(5, new /datum/whitehole_spawner/concrete_typesof(/obj/storage/crate/trench_loot))
		add_reagent(20, /datum/reagent/water/sea)

		add_mob(1, /mob/living/critter/aquatic/shark)
		add_mob(1, /mob/living/critter/small_animal/pikaia)
		add_mob(1, /mob/living/critter/small_animal/hallucigenia)
		add_mob(1, /mob/living/critter/small_animal/trilobite)
		add_mob(1, /mob/living/critter/aquatic/fish/jellyfish)
		add_mob(0.01, /mob/living/critter/aquatic/king_crab)
		add_mob(0.5, /mob/living/critter/aquatic/fish/butterfly)
		add_mob(0.5, /mob/living/critter/aquatic/fish/butterfly/copperbanded)
		add_mob(0.5, /mob/living/critter/aquatic/fish/butterfly/addis)
		add_mob(0.5, /mob/living/critter/aquatic/fish/butterfly/spotted)
		add_mob(0.5, /mob/living/critter/aquatic/fish/butterfly/forceps)
		add_mob(0.5, /mob/living/critter/aquatic/fish/tang)
		add_mob(0.5, /mob/living/critter/aquatic/fish/tang/powderblue)
		add_mob(0.5, /mob/living/critter/aquatic/fish/tang/bluesailfin)
		add_mob(0.5, /mob/living/critter/aquatic/fish/tang/purplesailfin)
		add_mob(0.5, /mob/living/critter/aquatic/fish/tang/regal)
		add_mob(0.5, /mob/living/critter/aquatic/fish/angel)
		add_mob(0.5, /mob/living/critter/aquatic/fish/angel/french)
		add_mob(0.5, /mob/living/critter/aquatic/fish/damsel)
		add_mob(0.5, /mob/living/critter/aquatic/fish/damsel/blue)
		add_mob(0.5, /mob/living/critter/aquatic/fish/gamma)
		add_mob(0.5, /mob/living/critter/aquatic/fish/clown)
		add_mob(0.5, /mob/living/critter/aquatic/fish/nautilus)
		add_mob(0.1, /mob/living/carbon/human/normal/miner, "name-human")

/datum/whitehole_spawner/main/asteroid
	name = "asteroid"
	icon_view = "asteroid"
	spawn_probs = list(
		/datum/whitehole_spawner/ore = 200,

		/obj/storage/crate/loot = 4,
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

	New()
		. = ..()
		add_mob(3, /mob/living/critter/rockworm)
		add_mob(10, /mob/living/critter/fermid)
		add_mob(0.1, /mob/living/carbon/human/normal/miner, "name-human")

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

		/obj/stool/bar = 5,
		/obj/item/decoration/ashtray = 1,
		/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
		/obj/item/reagent_containers/food/snacks/cake/chocolate/gateau = 0.5,
		/obj/decal/cleanable/vomit = 0.5,
	)

	New()
		. = ..()
		add_mob(0.1, /mob/living/carbon/human/normal/chef, "name-human")
		add_mob(0.1, /mob/living/carbon/human/normal/bartender, "name-human")
		add_mob(0.1, /mob/living/carbon/human/npc/monkey/angry)
		add_reagent(0.1, /datum/reagent/vomit)

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
		/obj/item/clothing/glasses/toggleable/meson = 0.5,
		/obj/gravity_well_generator = 0.5,
		/obj/item/raw_material/scrap_metal = 4,
		/obj/item/raw_material/shard/glass = 5,
		/obj/item/raw_material/shard/plasmacrystal = 3,
	)

	New()
		. = ..()
		add_spawn(0.2, new /datum/whitehole_spawner/grenade_armed(/obj/item/old_grenade/graviton))
		add_mob(0.5, /mob/living/carbon/human/normal/engineer, "name-human")
		add_mob(0.1, /mob/living/carbon/human/normal/chiefengineer, "name-human")
		add_mob(0.5, /mob/living/carbon/human/npc/monkey/mr_rathen)

/datum/whitehole_spawner/main/plasma
	name = "plasma"
	icon_view = "plasma"
	spawn_probs = list(
		/obj/critter/spore = 3,
		/obj/item/raw_material/shard/plasmacrystal = 1,
		/obj/item/raw_material/plasmastone = 1,
	)

	New()
		. = ..()
		add_spawn(5, new /datum/whitehole_spawner/grenade_armed(/obj/item/chem_grenade/firefighting))
		add_gas(80, list("plasma" = 1, "oxygen" = 1), 1, 20, 0 KELVIN, 100 KELVIN)
		add_gas(20, "plasma", 10, 30, 0 KELVIN, 300 KELVIN)

/datum/whitehole_spawner/main/nukies
	name = "nukies"
	icon_view = "nukies"
	spawn_probs = list(
		/datum/projectile/bullet/minigun = 5,
		/datum/projectile/energy_bolt = 5,
		/datum/projectile/bullet/rpg = 0.5,
		/datum/projectile/bullet/assault_rifle = 5,
		/datum/projectile/bullet/grenade_round/explosive = 0.5,
		/obj/machinery/bot/guardbot = 2,
		/obj/barricade = 1,
		/obj/item/deployer/barricade = 0.5,
		/obj/item/mine/blast/armed = 1,
		/obj/item/mine/incendiary/armed = 1,
		/obj/item/mine/radiation/armed = 1,
		/obj/item/mine/stun/armed = 1,
		/obj/stool/chair/office/syndie = 1,
		/obj/item/paper/book/from_file/syndies_guide = 0.5,
		/obj/item/beartrap/armed = 1,
		/obj/item/reagent_containers/food/snacks/donkpocket_w = 1,
		/obj/bomb_decoy = 0.4,
		/obj/machinery/nuclearbomb/event/micronuke = 0.05,
	)

	New()
		. = ..()
		add_spawn(2, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/secbot, "name-secbot", 33 PERCENT))
		add_mob(0.5, /mob/living/carbon/human/npc/monkey/oppenheimer)
		add_mob(2, /mob/living/critter/robotic/sawfly)

		add_spawn(1, new /datum/whitehole_spawner/grenade_armed(/obj/item/old_grenade/stinger))
		add_spawn(1, new /datum/whitehole_spawner/grenade_armed(/obj/item/old_grenade/stinger/frag))
		add_spawn(1, new /datum/whitehole_spawner/grenade_armed(/obj/item/chem_grenade/incendiary))
		add_spawn(0.5, new /datum/whitehole_spawner/grenade_armed(/obj/item/chem_grenade/very_incendiary))
		add_reagent(0.1, /datum/reagent/harmful/saxitoxin)
		add_reagent(1, /datum/reagent/blood)

/datum/whitehole_spawner/main/hell
	name = "hell"
	icon_view = "hell"
	spawn_probs = list(
		/datum/whitehole_spawner/fireflash = 15,
		/datum/whitehole_spawner/corpse = 5,
		/datum/whitehole_spawner/written_paper = 3,
		/datum/whitehole_spawner/hotspot = 10,

		/obj/submachine/slot_machine = 5,
		#ifdef SECRETS_ENABLED
		/obj/critter/slime/magma = 2,
		/obj/critter/slime/large/magma = 0.3,
		#endif
		/obj/decal/cleanable/ash = 10,
		/obj/decal/stalagmite = 5,
		/obj/decal/cleanable/molten_item = 10,
		/obj/critter/bat/hellbat = 5,
		// yeah idk where I was going with "hell" either
	)

	New()
		. = ..()
		add_mob(5, /mob/living/critter/small_animal/crab/lava)
		add_mob(5, /mob/living/carbon/human/normal, "name-human")

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
		/obj/item/plant/tumbling_creeper = 3,
	)

	New()
		. = ..()
		add_mob(1, /mob/living/critter/small_animal/cat/synth)
		add_mob(0.3, /mob/living/critter/plant/maneater)
		add_reagent(1, /datum/reagent/fooddrink/juice_tomato)
		add_reagent(1, /datum/reagent/drug/THC)
		add_reagent(1, /datum/reagent/poo)

/datum/whitehole_spawner/main/maint
	name = "maintanence"
	icon_view = "maint"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 5,
		/datum/whitehole_spawner/written_postit = 1,

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
	)

	New()
		. = ..()
		add_spawn(2, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/firebot, "name-firebot", 33 PERCENT))
		add_spawn(2, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/cleanbot, "name-cleanbot", 33 PERCENT))
		add_spawn(2, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/floorbot, "name-floorbot", 33 PERCENT))
		add_mob(2, /mob/living/critter/spider/baby)
		add_mob(2, /mob/living/critter/spider/nice)
		add_mob(2, /mob/living/carbon/human/npc/assistant, "name-human")
		add_mob(2, /mob/living/carbon/human/normal/assistant, "name-human")
		#ifdef SECRETS_ENABLED
		add_mob(1, /mob/living/critter/legman)
		#endif

/datum/whitehole_spawner/main/ai
	name = "AI"
	icon_view = "ai"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 2,

		/datum/projectile/laser/heavy/ai_turret = 30,
		/datum/projectile/energy_bolt/robust = 30,
		/obj/item/aiModule/random = 20,
		/obj/item/circuitboard/robotics = 2,
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

	New()
		. = ..()
		add_mob(10, /mob/living/silicon/hivebot/eyebot)
		add_mob(1, /mob/living/silicon/ai/latejoin, "name-ai")

/datum/whitehole_spawner/main/bridge
	name = "bridge"
	icon_view = "bridge"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 6,
		/datum/whitehole_spawner/written_postit = 4,

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

	New()
		. = ..()
		add_spawn(4, new /datum/whitehole_spawner/concrete_typesof(/obj/item/sticker))
		add_mob(5, /mob/living/critter/small_animal/cat/jones)

/datum/whitehole_spawner/main/clown
	name = "clown"
	icon_view = "clown"
	spawn_probs = list(
		/datum/whitehole_spawner/written_paper = 1,
		/datum/whitehole_spawner/written_postit = 1,

		/obj/item/bananapeel = 20,
		/obj/item/instrument/bikehorn = 10,
		/obj/item/toy/sword = 3,
		/obj/item/rubber_chicken = 1,
		/obj/item/rubber_hammer = 1,
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
	)

	New()
		. = ..()
		add_spawn(1, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/duckbot, "name-duckbot", 33 PERCENT))
		add_spawn(3, new /datum/whitehole_spawner/concrete_typesof(/obj/item/sticker))
		add_mob(1, /mob/living/carbon/human/normal/clown, "name-clown")
		add_mob(1, /mob/living/critter/spider/clown)
		add_mob(0.1, /mob/living/critter/spider/clownqueen)

/datum/whitehole_spawner/main/medbay
	name = "medbay"
	icon_view = "medbay"
	spawn_probs = list(
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
	)

	New()
		. = ..()
		add_spawn(5, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/medbot, "name-medbot", 33 PERCENT))
		add_spawn(1, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/medbot/mysterious/emagged, "name-medbot", 33 PERCENT))
		add_spawn(2, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/firebot, "name-firebot", 33 PERCENT))
		add_spawn(20, new /datum/whitehole_spawner/concrete_typesof(/obj/item/reagent_containers/glass/bottle))
		add_spawn(20, new /datum/whitehole_spawner/concrete_typesof(/obj/item/organ))
		add_reagent(5, /datum/reagent/blood)
		add_reagent(2, /datum/reagent/fooddrink/caffeinated/coffee)

/datum/whitehole_spawner/main/security
	name = "security"
	icon_view = "security"
	spawn_probs = list(
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
		/datum/projectile/energy_bolt = 3,
		/datum/projectile/energy_bolt/burst = 3,
		/datum/projectile/energy_bolt/tasershotgun = 3,
		/datum/projectile/energy_bolt/bouncy = 3,
	)

	New()
		. = ..()
		add_spawn(1, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/secbot, "name-secbot", 33 PERCENT))
		add_spawn(3, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/secbot/emagged, "name-secbot", 33 PERCENT))
		add_mob(1, /mob/living/carbon/human/npc/monkey/stirstir)

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

	New()
		. = ..()
		add_spawn(2, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/mulebot, "name-mulebot", 33 PERCENT))

/datum/whitehole_spawner/main/nuclear
	name = "nuclear reactor"
	icon_view = "nuclear"
	spawn_probs = list(
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
		/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake = 1,
		/obj/item/material_piece/plutonium = 1,
		/obj/item/raw_material/cerenkite = 10,
	)

	New()
		. = ..()
		add_spawn(5, new /datum/whitehole_spawner/grenade_armed(/obj/item/chem_grenade/firefighting))
		add_gas(40, "radgas", 10, 100, 0 KELVIN, 300 KELVIN)
		add_gas(10, "radgas", 100, 500, 0 KELVIN, 300 KELVIN)
		add_gas(25, list("plasma" = 1, "oxygen" = 1), 1, 20, 0 KELVIN, 100 KELVIN)
		add_gas(5, "plasma", 10, 30, 0 KELVIN, 300 KELVIN)

/datum/whitehole_spawner/main/janitorial
	name = "janitorial"
	icon_view = "janitorial"
	spawn_probs = list(
		/datum/whitehole_spawner/corpse/bagged = 2,

		/obj/item/caution = 10,
		/obj/item/caution/traitor = 2,
		/obj/item/spraybottle/cleaner = 5,
		/obj/item/reagent_containers/glass/bottle/cleaner = 3,
		/obj/item/reagent_containers/glass/bottle/acetone/janitors = 3,
		/obj/item/mop = 5,
		/obj/item/sponge = 5,
		/obj/item/mousetrap/armed = 5,
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

	New()
		. = ..()
		add_spawn(5, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/cleanbot, "name-cleanbot", 33 PERCENT))
		add_spawn(3, new /datum/whitehole_spawner/renamer(/obj/machinery/bot/cleanbot/emagged, "name-cleanbot", 33 PERCENT))
		add_spawn(10, new /datum/whitehole_spawner/grenade_armed(/obj/item/chem_grenade/cleaner))
		add_reagent(10, /datum/reagent/water)
		add_reagent(5, /datum/reagent/space_cleaner)

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
		/obj/item/raw_material/char = 3,
		/obj/critter/domestic_bee/reindeer = 1,
		/obj/critter/domestic_bee/santa = 1,
		/obj/item/material_piece/organic/wood = 3,
		/obj/item/clothing/head/helmet/space/santahat = 3,
		/obj/item/clothing/suit/space/santa = 2,
		#ifdef XMAS
		/datum/figure_info/santa = 1,
		#endif
	)

	New()
		. = ..()
		add_reagent(2, /datum/reagent/fooddrink/alcoholic/mulled_wine)
		add_mob(1, /mob/living/critter/small_animal/bird/turkey)
		add_mob(1, /mob/living/critter/small_animal/bunny/hare)

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
	)

	New()
		. = ..()
		add_mob(1, /mob/living/carbon/human/referee, "name-human")

// ===============================================================================
// ============================== Spawner Subtypes ===============================
// ===============================================================================

/// Pick something out of any type of white hole
/datum/whitehole_spawner/random_object
	name = "random object"
	icon_view = "cargo"

	New()
		. = ..()
		for(var/spawner_type in concrete_typesof(/datum/whitehole_spawner/main))
			var/datum/whitehole_spawner/spawner = spawner_type
			src.spawn_probs[spawner_type] = initial(spawner.weight_rarity)

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
	icon_view = "asteroid"
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

/datum/whitehole_spawner/gas
	icon_view = "plasma"
	var/list/gas_list = list() //! Which gases will be released. Weights are their relative ratios.
	var/amount_max = 10
	var/amount_min = 1
	var/temperature_max = 0
	var/temperature_min = 0

	New(var/gases, var/amount_min, var/amount_max, var/temp_min, var/temp_max)
		. = ..()
		if(!islist(gases))
			gas_list[gases] = 1
		else
			src.gas_list = gases
		src.amount_min = amount_min
		src.amount_max = amount_max
		src.temperature_min = temp_min
		src.temperature_max = temp_max

	unleash(var/obj/whitehole/whitehole)
		var/datum/gas_mixture/mixture = new()
		src.setup_gases(mixture, rand(src.amount_min, src.amount_max))
		mixture.temperature = rand(src.temperature_min, src.temperature_max)
		var/turf/T = get_turf(whitehole)
		T.assume_air(mixture)
		return null

	proc/setup_gases(var/datum/gas_mixture/mixture, var/amount)
		var/ratio_div = 0
		for(var/gas in src.gas_list)
			ratio_div += src.gas_list[gas]
		if(ratio_div == 0)
			ratio_div = 1
		for(var/gas in src.gas_list)
			var/gas_amount = (src.gas_list[gas] / ratio_div) * amount
			switch(gas)
				if("oxygen") mixture.oxygen = gas_amount
				if("plasma") mixture.toxins = gas_amount
				if("radgas") mixture.radgas = gas_amount
				if("nitrogen") mixture.nitrogen = gas_amount
				if("co2") mixture.carbon_dioxide = gas_amount
				if("farts") mixture.farts = gas_amount
				if("n2o") mixture.nitrous_oxide = gas_amount
				if("oxygen_b") mixture.oxygen_agent_b = gas_amount


/datum/whitehole_spawner/plant
	name = "random plant"
	icon_view = "botany"
	spawn_probs = list(
		/obj/item/reagent_containers/food/snacks/plant = 1,
		/obj/item/plant = 1,
		// /obj/item/clothing/head/flower = 1
	)

	unleash(obj/whitehole/whitehole)
		var/atom/movable/AM = ..()
		if(istype(AM, /obj/item/reagent_containers/food/snacks/plant/tomato))
			var/obj/item/reagent_containers/food/snacks/plant/tomato/tomato = AM
			tomato.reagents.add_reagent("juice_tomato", rand(5, 15))
		return AM

/datum/whitehole_spawner/corpse
	name = "corpse"
	icon_view = "chapel"
	var/bagged_chance = 0 PERCENT
	var/decomp_max = DECOMP_STAGE_SKELETONIZED
	var/decomp_min = DECOMP_STAGE_NO_ROT

	New()
		. = ..()
		add_mob(6, /mob/living/carbon/human/normal, "name-human")
		add_mob(1, /mob/living/carbon/human/normal/assistant, "name-human")
		add_mob(1, /mob/living/carbon/human/normal/clown, "name-clown")
		add_mob(1, /mob/living/carbon/human/normal/chef, "name-human")
		add_mob(1, /mob/living/carbon/human/normal/botanist, "name-human")
		add_mob(1, /mob/living/carbon/human/normal/janitor, "name-human")
		add_mob(1, /mob/living/carbon/human/normal/miner, "name-human")

	unleash(var/obj/whitehole/whitehole)
		. = ..()
		var/mob/living/carbon/human/H = .
		H.decomp_stage = rand(src.decomp_min, src.decomp_max)
		for (var/i in 1 to rand(1, 4))
			var/obj/item/organ/organ = H.drop_organ(pick("left_eye","right_eye","left_lung","right_lung","butt","left_kidney","right_kidney","liver","stomach","intestines","spleen","pancreas","appendix"))
			qdel(organ)
		H.death()
		if(prob(src.bagged_chance))
			var/obj/item/body_bag/bag = new(whitehole.loc)
			bag.UpdateIcon()
			H.is_npc = TRUE // NPC is set for direct mob returns separately
			H.set_loc(bag)
			return bag
		return H

/datum/whitehole_spawner/corpse/bagged
	name = "bagged corpse"
	bagged_chance = 100 PERCENT

/datum/whitehole_spawner/gene_injector
	name = "gene injector"
	icon_view = "medbay"
	var/unlabeled_prob = 50 PERCENT //! Chance that the injector will be labed as "???"

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
	icon_view = "teg"
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
	icon_view = "teg"
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
	var/reagent_type = null
	var/amount_max = 150
	var/amount_min = 20
	var/flood_prob = 10 PERCENT

	New(var/reagent_type)
		. = ..()
		src.reagent_type = reagent_type

	unleash(var/obj/whitehole/whitehole)
		var/datum/reagent/dummy = new src.reagent_type
		var/reagent_id = initial(dummy.id)
		var/amount = rand(src.amount_min, src.amount_max)
		if(prob(src.flood_prob))
			amount *= 10
		if(prob(src.flood_prob))
			amount *= 10
		var/turf/T = get_turf(whitehole)
		T.fluid_react_single(reagent_id, amount)
		return null

/// Used to spawn subtypes of a thing instead of the type itself
/datum/whitehole_spawner/concrete_typesof
	var/source_type = null

	New(var/source_type)
		. = ..()
		src.source_type = source_type

	unleash(var/obj/whitehole/whitehole)
		var/chosen_type = pick(concrete_typesof(src.source_type))
		return new chosen_type(whitehole.loc)

/datum/whitehole_spawner/gift
	name = "random gift"
	icon_view = "spacemas"
	ignore_datums = TRUE

	New()
		. = ..()
		add_spawn(1, new /datum/whitehole_spawner/random_object())

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		if(istype(selected, /atom/movable))
			var/atom/movable/AM = selected
			return AM.gift_wrap(xmas_style = TRUE)
		return new /obj/item/a_gift/festive(whitehole.loc)

/datum/whitehole_spawner/flock_converted
	name = "converted flock"
	icon_view = "flock"
	ignore_datums = TRUE

	New()
		. = ..()
		var/datum/whitehole_spawner/random_object/rand_spawner = new()
		rand_spawner.spawn_probs[/datum/whitehole_spawner/main/flock] = 0 // Don't flock convert flock stuff
		add_spawn(1, rand_spawner)

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		if(isatom(selected))
			var/atom/A = selected
			A.color = list(-0.2,-0.2,-0.2,-0.2,-0.2,-0.2,-0.25,-0.2,-0.15,0.368627,0.764706,0.666667)
		return selected

/datum/whitehole_spawner/deep_fried
	name = "deep fried"
	icon_view = "cafeteria"
	ignore_datums = TRUE

	New()
		. = ..()
		add_spawn(1, new /datum/whitehole_spawner/random_object())

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		if(!istype(selected, /atom/movable))
			return null
		if(istype(selected, /obj/item/reagent_containers/food/snacks/shell/deepfry))
			return selected
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
	icon_view = "bridge"

	unleash(var/obj/whitehole/whitehole)
		// Done like this in case alternative postit note types are added in the future
		var/obj/item/sticker/postit/postit = new(whitehole.loc)
		if(length(postit.words) == 0)
			postit.words = phrase_log.random_phrase("paper")
			postit.icon_state = "postit-writing"
		return postit

/datum/whitehole_spawner/written_paper
	name = "written paper"
	icon_view = "bridge"

	unleash(var/obj/whitehole/whitehole)
		var/obj/item/paper/paper = new(whitehole.loc)
		if(length(paper.info) == 0)
			paper.info = phrase_log.random_phrase("paper")
		return paper

/// Used to rename mobs before unleashing them
/datum/whitehole_spawner/renamer
	name = "mob"
	icon_view = "medbay"
	var/rename_category = null
	var/rename_chance = 33 PERCENT

	New(var/input_type, var/rename_category, var/rename_chance = 100 PERCENT)
		. = ..()
		src.spawn_probs[input_type] = 1
		src.rename_category = rename_category
		src.rename_chance = rename_chance

	unleash(var/obj/whitehole/whitehole)
		var/atom/movable/AM = ..()
		if(!prob(rename_chance))
			return AM
		var/new_name = phrase_log.random_phrase(src.rename_category)
		if(!new_name)
			return AM
		AM.name = new_name
		if(ismob(AM))
			var/mob/M = AM
			M.real_name = new_name
			M.choose_name(1, null, M.real_name, force_instead=TRUE)
		return AM

/// Break some bones before launching.
/datum/whitehole_spawner/damager
	name = "damaged"
	icon_view = "medbay"

	New(var/input_type)
		. = ..()
		src.spawn_probs[input_type] = 1

	unleash(var/obj/whitehole/whitehole)
		var/atom/movable/AM = ..()
		if(istype(AM, /mob/living))
			damage_mob(AM)
		return AM

	proc/damage_mob(var/mob/living/L)
		if(ismobcritter(L))
			L.TakeDamage("chest", rand(0, 15), rand(0, 15), rand(0, 15))
		else
			L.TakeDamage("chest", rand(0, 80), rand(0, 80), rand(0, 80))

		if(!ishuman(L))
			return
		var/mob/living/carbon/human/H = L
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

/datum/whitehole_spawner/snake
	name = "wizard snake"
	icon_view = "wizard"
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
		return snake

/datum/whitehole_spawner/hotspot
	name = "hotspot"
	icon_view = "hell"

	unleash(var/obj/whitehole/whitehole)
		// We don't want hotspots getting deep fried or anything, so create one directly
		var/atom/movable/hotspot/gasfire/hotspot = new(whitehole.loc)
		hotspot.temperature = rand(FIRE_MINIMUM_TEMPERATURE_TO_EXIST, 6000)
		hotspot.set_real_color()
		SPAWN(rand(10 SECONDS, 2 MINUTES))
			if(!QDELETED(hotspot))
				qdel(hotspot)
		return hotspot

/datum/whitehole_spawner/grenade_armed
	name = "grenade"
	icon_view = "nukies"
	var/arm_chance = 50 PERCENT
	var/explode_delay_max = 10 SECONDS
	var/explode_delay_min = 1 SECOND

	New(var/grenade_type)
		. = ..()
		if(grenade_type)
			src.spawn_probs[grenade_type] = 1
		else
			add_spawn(1, new /datum/whitehole_spawner/concrete_typesof(/obj/item/old_grenade))
			add_spawn(1, new /datum/whitehole_spawner/concrete_typesof(/obj/item/chem_grenade))

	unleash(var/obj/whitehole/whitehole)
		var/selected = ..()
		src.arm_grenade(selected)
		return selected

	proc/arm_grenade(var/selected)
		if(!prob(arm_chance))
			return
		if(istype(selected, /obj/item/old_grenade))
			var/obj/item/old_grenade/grenade = selected
			SPAWN(rand(src.explode_delay_min, src.explode_delay_max))
				if(!QDELETED(grenade))
					grenade.detonate()
		else if(istype(selected, /obj/item/chem_grenade))
			var/obj/item/chem_grenade/grenade = selected
			grenade.arm()

#undef WHITEHOLE_COMMON
#undef WHITEHOLE_UNCOMMON
#undef WHITEHOLE_RARE
