#define TURF_SPAWN_EDGE_LIMIT 5

/datum/mining_encounter
	var/name = null
	var/info = null
	var/rarity_tier = 0
	var/no_pick = 0 //If 1, encounter will not be randomly picked and will not be sorted into rarity lists. Will still appear in "all" list. Used for telescope encounters.

	proc/generate(var/obj/magnet_target_marker/target)
		return 0

/datum/mining_encounter/asteroid_small
	name = "Small Asteroid"
	rarity_tier = -1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = 3
		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedOre(generated_turfs,rand(2,6),rand(0,40))
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(1,6))

/datum/mining_encounter/asteroid
	name = "Asteroid"
	rarity_tier = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			size = target.get_encounter_size(size,P=40)
			area_restriction = null
			size = min(size,min(target.width,target.height))

		var/rand_num = rand(1,3)
		switch(rand_num)
			if (1)
				generated_turfs = Turfspawn_Asteroid_DegradeFromCenter(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 10, area_restriction)
			if (2)
				var/list/turfs_near_center = list()
				for(var/turf/space/S in orange(4,magnetic_center))
					turfs_near_center += S

				if (length(turfs_near_center) > 0) //Wire note: Fix for pick() from empty list
					var/chunks = rand(2,6)
					while(chunks > 0)
						chunks--
						generated_turfs = generated_turfs + Turfspawn_Asteroid_Round(pick(turfs_near_center), /turf/simulated/wall/auto/asteroid, rand(2,4), 0, area_restriction)
			else
				generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedOre(generated_turfs,rand(2,6),0)
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(1,6))

/datum/mining_encounter/comet_chunk
	name = "Comet Chunk"
	rarity_tier = 2

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			size = target.get_encounter_size(size,P=20)
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid/ice, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedOre(generated_turfs,rand(1,2),40)
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(4,12))

/datum/mining_encounter/jean
	name = "Jasteroid"
	#ifdef APRIL_FOOLS
	rarity_tier = 1
	#else
	rarity_tier = 3
	#endif

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid/jean, size, 1, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()
			AST.setMaterial(getMaterial("jean"))

		var/list/turf/floors = list()
		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()
			AST.setMaterial(getMaterial("jean"))
			floors += AST

		for(var/i in 0 to rand(0, 2))
			var/jean_object_type = pick(
				50; /obj/item/clothing/suit/jean_jacket,
				10; /obj/item/clothing/under/misc/casualjeansacid,
				10; /obj/item/clothing/under/misc/casualjeansblue,
				10; /obj/item/clothing/under/misc/casualjeansgrey,
				10; /obj/item/clothing/under/misc/casualjeanskhaki,
				10; /obj/item/clothing/under/misc/casualjeansgrey,
				10; /obj/item/clothing/under/misc/casualjeanspurp,
				10; /obj/item/clothing/under/misc/casualjeansskb,
				10; /obj/item/clothing/under/misc/casualjeansskr,
				10; /obj/item/clothing/under/misc/casualjeanswb,
				10; /obj/item/clothing/under/misc/casualjeansyel,
				50; /obj/item/clothing/under/gimmick/shirtnjeans,
				10; /obj/item/material_piece/cloth/jean,
			)
			var/turf/simulated/floor/plating/airless/asteroid/jean_floor = pick(floors)
			floors -= jean_floor
			var/obj/item/jean_object = new jean_object_type(jean_floor)
			jean_object.pixel_x = rand(-6, 6)
			jean_object.pixel_y = rand(-6, 6)

		Turfspawn_Asteroid_SeedOre(generated_turfs,rand(1,2),40)
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(4,12))

/datum/mining_encounter/wreckage
	name = "Wreckage"
	rarity_tier = 2

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		Turfspawn_Wreckage(center=magnetic_center, size=size, area_restriction=area_restriction)

/datum/mining_encounter/geode
	name = "Geode"
	rarity_tier = 3

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		var/size = 7

		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		var/list/generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid/geode, size, 1, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		var/list/floors = list()
		var/list/gems = list(/obj/item/raw_material/uqill,/obj/item/raw_material/miracle,/obj/item/raw_material/gemstone,
		/obj/item/raw_material/telecrystal,/obj/item/raw_material/fibrilith)
		for (var/turf/simulated/floor/plating/airless/asteroid/T in generated_turfs)
			floors += T

		var/amount = rand(20,40)
		var/the_gem = null
		while (amount > 0)
			amount--
			the_gem = pick(gems)
			if (length(floors))
				var/obj/item/G = new the_gem
				G.set_loc(pick(floors))

/datum/mining_encounter/seafloor
	name = "Hydroscopic Asteroid"
	rarity_tier = 3
	var/static/list/crates = list(
			/obj/storage/crate/trench_loot/meds,
			/obj/storage/crate/trench_loot/meds2,
			/obj/storage/crate/trench_loot/ore3,
			/obj/storage/crate/trench_loot/rad,
			/obj/storage/crate/trench_loot/drug,
			/obj/storage/crate/trench_loot/clothes,
			/obj/storage/crate/trench_loot/tools2,
			/obj/storage/crate/trench_loot/weapons4,
			)
	var/static/list/enemies = list(
			/mob/living/critter/small_animal/trilobite,
			/mob/living/critter/small_animal/hallucigenia,
			/mob/living/critter/small_animal/pikaia
	)

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		var/size = 7

		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		var/list/generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid/algae, size, TRUE, area_restriction)
		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		var/list/floors = list()
		for (var/turf/simulated/floor/plating/airless/asteroid/T in generated_turfs)
			floors += T

		var/the_crate = null
		var/the_enemy = null
		for (var/i in 1 to rand(1,3))
			the_crate = pick(crates)
			the_enemy = pick(enemies)
			if (length(floors))
				var/obj/storage/crate/new_crate = new the_crate
				var/mob/living/critter/small_animal/new_enemy = new the_enemy
				new_crate.set_loc(pick(floors))
				new_enemy.set_loc(pick(floors))

/////////////TELESCOPE ENCOUNTERS BELOW

/datum/mining_encounter/tel_miraclium
	name = "Miraclium asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"miraclium",rand(2,9))

/datum/mining_encounter/tel_mauxite
	name = "Mauxite asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"mauxite",rand(2,5))
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(1,9))

/datum/mining_encounter/tel_valuable
	name = "Valuable asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		var/list/left = Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"gold",rand(2,4))
		Turfspawn_Asteroid_SeedSpecificOre(left,"syreline",rand(3,6))
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(1,9))

/datum/mining_encounter/tel_molitz
	name = "Molitz asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"molitz",rand(2,5))
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(1,9))

/datum/mining_encounter/tel_pharosium
	name = "Pharosium asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"pharosium",rand(2,5))
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(1,9))

/datum/mining_encounter/tel_bohrum
	name = "Bohrum asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"bohrum",rand(2,5))
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(1,9))

/datum/mining_encounter/tel_char
	name = "Char asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"char",rand(2,5))
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs),rand(1,9))

/datum/mining_encounter/tel_nanite
	name = "Nanite asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"nanite cluster",rand(2,5))

/datum/mining_encounter/tel_erebite
	name = "Erebite asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"erebite",rand(1,4))

/datum/mining_encounter/tel_cerenkite
	name = "Cerenkite asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"cerenkite",rand(2,8))

/datum/mining_encounter/tel_koshmarite
	name = "Koshmarite asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"koshmarite",rand(2,8))

/datum/mining_encounter/tel_viscerite
	name = "Viscerite asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"viscerite",rand(2,8))

/datum/mining_encounter/tel_starstone
	name = "Starstone asteroid"
	rarity_tier = 1
	no_pick = 1

	generate(var/obj/magnet_target_marker/target)
		if (..())
			return
		var/list/generated_turfs
		var/size = rand(mining_controls.min_magnet_spawn_size, mining_controls.max_magnet_spawn_size)

		var/magnetic_center = mining_controls.magnetic_center
		var/area_restriction = /area/mining/magnet
		if (target)
			magnetic_center = target.magnetic_center
			area_restriction = null
			size = min(size,min(target.width,target.height))

		generated_turfs = Turfspawn_Asteroid_Round(magnetic_center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedSpecificOre(generated_turfs,"starstone",rand(1,2))
// Terrain Gen Procs

/// ASTEROIDS ///

/obj/landmark/asteroid_spawn_blocker //Blocks the creation of an asteroid on this tile, as you would expect
	name = "asteroid blocker"
	icon_state = "x4"

/turf/proc/GenerateAsteroid(var/size, var/alt_stones = TRUE)
	// Sanity Checks
	if (!size || !isnum(size) || size < 1 || size > 15)
		size = rand(4,15)
	var/list/turfcheck = Turfspawn_CheckForFreeSpace(src,size)
	if (length(turfcheck) < 1)
		return

	var/list/generated_turfs
	var/roidpath = /turf/simulated/wall/auto/asteroid
	if (alt_stones && prob(15))
		roidpath = pick(typesof(/turf/simulated/wall/auto/asteroid))

	if (rand(0,1))
		size = max(size,9)
		generated_turfs = Turfspawn_Asteroid_Round(src, roidpath, size)
	else
		generated_turfs = Turfspawn_Asteroid_DegradeFromCenter(src, roidpath, size, 10)

	for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
		AST.space_overlays()

	Turfspawn_Asteroid_SeedOre(generated_turfs)
	Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs))

	return generated_turfs

// Checks

/proc/Turfspawn_CheckForNearbyTurfsOfType(var/turf/center,var/turfpath,var/include_diagonals = 1)
	if (!center || !istype(center,/turf/) || !ispath(turfpath))
		return 0
	if (include_diagonals)
		for (var/turf/A in range(1,center))
			if (A.type == turfpath)
				return 1
	else
		var/turf/checked
		for (var/dir in cardinal)
			checked = get_step(center, dir)
			if (istype(checked,turfpath))
				return 1
	return 0

/proc/Turfspawn_CheckForFreeSpace(var/turf/space/center,var/size)
	if (!istype(center))
		return list()
	if (!isnum(size))
		return list()

	var/list/acceptable_turfs = list()
	var/loopbroken = 0

	for (var/turf/space/TF in range(center,size))
		loopbroken = 0
		if (TF.loc.type != /area)
			asteroid_blocked_turfs += TF
			continue
		if (TF.x <= TURF_SPAWN_EDGE_LIMIT || TF.x >= world.maxx - TURF_SPAWN_EDGE_LIMIT)
			asteroid_blocked_turfs += TF
			continue
		if (TF.y <= TURF_SPAWN_EDGE_LIMIT || TF.y >= world.maxy - TURF_SPAWN_EDGE_LIMIT)
			asteroid_blocked_turfs += TF
			continue
		for (var/obj/O in TF.contents)
			if (O.density)
				asteroid_blocked_turfs += TF
				loopbroken = 1
				break
			if (istype(O, /obj/landmark/asteroid_spawn_blocker))
				qdel(O)
				asteroid_blocked_turfs += TF
				loopbroken = 1
				break
		if (!loopbroken)
			acceptable_turfs += TF

	return acceptable_turfs

/proc/Turfspawn_Asteroid_CheckForModifiableTurfs(var/list/turfs)
	if (!turfs || length(turfs) < 1)
		return list()
	var/list/acceptable_turfs = list()

	for (var/turf/simulated/wall/auto/asteroid/AST in turfs)
		if (AST.ore || AST.event)
			continue
		acceptable_turfs += AST

	return acceptable_turfs

// Generators

/proc/Turfspawn_Asteroid_DegradeFromCenter(var/turf/space/center, var/base_rock = /turf/simulated/wall/auto/asteroid, var/size = 8, var/degradation = 10, var/area/area_restriction = null)
	if (!istype(center))
		return list()
	if (!isnum(size) || size < 1)
		size = rand(5,15)
	if (!ispath(base_rock,/turf/simulated/wall/auto/asteroid))
		return list()

	var/current_chance = 100
	var/current_range = 0
	var/list/generated_turfs = list()

	var/turf/simulated/wall/auto/asteroid/A
	A = new base_rock(locate(center.x, center.y, center.z),0)
	generated_turfs += A
	var/turf/simulated/wall/auto/asteroid/B

	while (current_range < size - 1)
		current_range++
		current_chance -= degradation
		for (var/turf/space/S in range(current_range,A))
			if (GET_DIST(S,A) == current_range)
				if (S in asteroid_blocked_turfs)
					continue
				if (!Turfspawn_CheckForNearbyTurfsOfType(S,base_rock,1))
					continue
				if (!prob(current_chance))
					continue
				if (area_restriction && S.loc.type != area_restriction)
					continue
				B = new base_rock(locate(S.x, S.y, S.z),0)
				generated_turfs += B

	return generated_turfs

/proc/Turfspawn_Asteroid_Round(var/turf/space/center, var/base_rock = /turf/simulated/wall/auto/asteroid, var/size = 8, var/hollow = 0, var/area/area_restriction = null)
	if (!istype(center))
		return list()
	if (!isnum(size) || size < 1)
		size = rand(5,15)
	if (!ispath(base_rock,/turf/simulated/wall/auto/asteroid))
		return list()

	var/current_range = 0
	var/list/generated_turfs = list()


	var/turf/simulated/wall/auto/asteroid/rock_dummy = base_rock
	var/floor_type = initial(rock_dummy.replace_type)
	var/turf/A = locate(center.x, center.y, center.z)
	if (hollow)
		A = A.ReplaceWith(floor_type, FALSE, TRUE, FALSE, TRUE)
	else
		A = A.ReplaceWith(base_rock, FALSE, TRUE, FALSE, TRUE)
	generated_turfs += A
	var/turf/simulated/wall/auto/asteroid/B
	var/turf/simulated/floor/plating/airless/asteroid/F

	var/corner_range = round(size * 1.5)
	var/total_distance = 0

	var/stone_color

	while (current_range < size - 1)
		current_range++
		total_distance = 0
		for (var/turf/space/S in range(current_range,A))
			if (GET_DIST(S,A) == current_range)
				if (S in asteroid_blocked_turfs)
					continue
				total_distance = abs(A.x - S.x) + abs(A.y - S.y) + (current_range / 2)
				if (total_distance > corner_range)
					continue
				if (area_restriction && S.loc.type != area_restriction)
					continue
				if (hollow && total_distance < size / 2)
					var/turf/T = locate(S.x, S.y, S.z)
					F = T.ReplaceWith(floor_type, FALSE, TRUE, FALSE, TRUE)
					generated_turfs += F
				else
					var/turf/T = locate(S.x, S.y, S.z)
					B = T.ReplaceWith(base_rock, FALSE, TRUE, FALSE, TRUE)
					stone_color = B.stone_color
					generated_turfs += B


		for (var/turf/simulated/floor/plating/airless/asteroid/FLOOR in generated_turfs)
			FLOOR.color = stone_color

	return generated_turfs

/obj/mapping_helper/procgen/wreckage
	var/size
	var/area_restriction

	setup()
		..()
		Turfspawn_Wreckage(src.loc, size, area_restriction, allow_non_space=TRUE)


/obj/mapping_helper/procgen/asteroid
	var/size
	var/area_restriction

	setup()
		var/turf/center = get_turf(src)
		var/list/turf/generated_turfs
		if(!size)
			size = rand(4,7)

		var/rand_num = rand(1,3)
		switch(rand_num)
			if (1)
				generated_turfs = Turfspawn_Asteroid_DegradeFromCenter(center, /turf/simulated/wall/auto/asteroid, size, 10, area_restriction)
			if (2)
				var/list/turfs_near_center = list()
				for(var/turf/space/S in orange(4,center))
					turfs_near_center += S

				if (length(turfs_near_center) > 0) //Wire note: Fix for pick() from empty list
					var/chunks = rand(2,6)
					while(chunks > 0)
						chunks--
						generated_turfs = generated_turfs + Turfspawn_Asteroid_Round(pick(turfs_near_center), /turf/simulated/wall/auto/asteroid, rand(2,4), 0, area_restriction)
			else
				generated_turfs = Turfspawn_Asteroid_Round(center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

		for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
			AST.space_overlays()

		for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
			AST.UpdateIcon()

		Turfspawn_Asteroid_SeedOre(generated_turfs, rand(2,6), 0)
		Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs), rand(1,6))

/proc/Turfspawn_Wreckage(var/turf/space/center, var/size = 6, var/area/area_restriction = null, var/allow_non_space)
	if (!istype(center) && !allow_non_space)
		return list()
	if (!isnum(size) || size < 1)
		size = rand(3,6)

	var/current_chance = 100
	var/current_range = 0
	var/list/generated_turfs = list()

	var/turf/A = locate(center.x, center.y, center.z)
	A = A.ReplaceWith(/turf/simulated/floor/plating/airless, FALSE, TRUE, FALSE, TRUE)
	generated_turfs += A
	var/turf/B = null

	while (current_range < size - 1)
		current_range++
		current_chance = clamp(current_chance - 25, 2, 100)
		for (var/turf/space/S in range(current_range,A))
			if (GET_DIST(S,A) == current_range)
				if (S in asteroid_blocked_turfs)
					continue
				if (!Turfspawn_CheckForNearbyTurfsOfType(S, /turf/simulated/floor/plating/airless, TRUE))
					continue
				if (area_restriction && S.loc.type != area_restriction)
					continue

				if (prob(current_chance))
					B = locate(S.x, S.y, S.z)
					B = B.ReplaceWith(/turf/simulated/floor/plating/airless, FALSE, TRUE, FALSE, TRUE)
					generated_turfs += B
				else
					if (prob(round(current_chance / 2)))
						switch(rand(1,6))
							if(4)
								make_cleanable(/obj/decal/cleanable/robot_debris/gib, locate(S.x, S.y, S.z),0)
							if(5)
								make_cleanable(/obj/decal/cleanable/machine_debris, locate(S.x, S.y, S.z),0)
							if(6)
								new /obj/mesh/grille/steel/broken(locate(S.x, S.y, S.z),0)
							else
								var/obj/lattice/lattice = new /obj/lattice/auto/turf_attaching(locate(S.x, S.y, S.z))
								var/dirmask = lattice.dirmask | rand(0, 1 | 2 | 4 | 8) // randomly add some directions to the lattice to make it look more broken
								lattice.set_dirmask(dirmask)

	var/num_items = rand(4,20)
	var/datum/material/scrap_material = null

	switch(RarityClassRoll(100,0,list(90,50)))
		if(1)
			scrap_material = getMaterial(pick("steel","mauxite"))
		if(2)
			scrap_material = getMaterial(pick("cobryl","bohrum"))
		if(3)
			scrap_material = getMaterial(pick("gold","syreline"))

	var/list/turfs_near_center = list()
	for(var/turf/T in range(size - 1,center))
		turfs_near_center += T

	var/picker = 0
	var/obj/item/I = null
	while(num_items > 0)
		num_items--
		picker = rand(1,6)
		switch(picker)
			if (1 to 3)
				if(prob(10))
					new /obj/storage/crate/loot(pick(turfs_near_center))
			if (4)
				I = new /obj/item/sheet(pick(turfs_near_center))
				I.amount = rand(1,5)
				I.setMaterial(scrap_material)
			if (5)
				if (prob(25))
					Artifact_Spawn(pick(turfs_near_center))
				else
					I = new /obj/item/rods(pick(turfs_near_center))
					I.amount = rand(2,10)
					I.setMaterial(scrap_material)
			if (6)
				I = new /obj/item/raw_material/scrap_metal
				I.set_loc(pick(turfs_near_center))
				I.setMaterial(scrap_material)

	return generated_turfs

// Modifiers

/proc/Turfspawn_Asteroid_SeedSpecificOre(var/list/turfs,var/ore_name = "mauxite",var/veins = 0,fullbright=TRUE)
	if (!turfs || length(turfs) < 1)
		return list()

	if (!isnum(veins) && veins <= 1)
		veins = rand(2,6)

	while (veins > 0)
		veins--
		if (length(turfs) < 1)
			break

		var/datum/ore/O = mining_controls.get_ore_from_string(ore_name)
		var/ore_tiles = rand(O.tiles_per_rock_min,O.tiles_per_rock_max)

		while (ore_tiles > 0)
			if (length(turfs) < 1)
				break
			ore_tiles--
			var/turf/simulated/wall/auto/asteroid/AST = pick(turfs)
			if (!istype(AST))
				turfs -= AST
				ore_tiles++
				continue
			AST.ore = O
			AST.hardness += O.hardness_mod
			AST.amount = rand(O.amount_per_tile_min,O.amount_per_tile_max)
			AST.UpdateIcon()
#ifndef UNDERWATER_MAP // We don't want fullbright ore underwater.
			if(fullbright)
				AST.AddOverlays(new /image/fullbright, "fullbright")
#endif
			O.onGenerate(AST)
			AST.mining_health = O.mining_health
			AST.mining_max_health = O.mining_health
			if (prob(O.event_chance) && length(O.events) > 0)
				var/new_event = pick(O.events)
				var/datum/ore/event/E = new new_event
				E.set_up(O)
				AST.set_event(E)

			turfs -= AST
	return turfs

/proc/Turfspawn_Asteroid_SeedOre(var/list/turfs,var/veins,var/rarity_mod = 0,fullbright=TRUE)
	if (!turfs || length(turfs) < 1)
		return list()

	if (!isnum(veins) && veins <= 1)
		veins = rand(2,6)
	if (!isnum(rarity_mod))
		rarity_mod = 0

	while (veins > 0)
		veins--
		if (length(turfs) < 1)
			break
		var/rarity_roller = RarityClassRoll(100,rarity_mod,list(90,50))
		var/list/ores_to_pick = list()
		switch(rarity_roller)
			if(3) // rare tier
				ores_to_pick = mining_controls.ore_types_rare
			if(2) // uncommon tier
				ores_to_pick = mining_controls.ore_types_uncommon
			else // common tier
				ores_to_pick = mining_controls.ore_types_common

		var/datum/ore/O = pick(ores_to_pick)
		var/ore_tiles = rand(O.tiles_per_rock_min,O.tiles_per_rock_max)

		while (ore_tiles > 0)
			if (length(turfs) < 1)
				break
			ore_tiles--
			var/turf/simulated/wall/auto/asteroid/AST = pick(turfs)
			if (!istype(AST))
				turfs -= AST
				ore_tiles++
				continue
			AST.ore = O
			AST.hardness += O.hardness_mod
			AST.amount = rand(O.amount_per_tile_min,O.amount_per_tile_max)
			AST.UpdateIcon()
#ifndef UNDERWATER_MAP // We don't want fullbright ore underwater.
			if(fullbright)
				AST.AddOverlays(new /image/fullbright, "fullbright")
#endif

			O.onGenerate(AST)
			AST.mining_health = O.mining_health
			AST.mining_max_health = O.mining_health
			if (prob(O.event_chance) && length(O.events) > 0)
				var/new_event = pick(O.events)
				var/datum/ore/event/E = new new_event
				E.set_up(O)
				AST.set_event(E)

			turfs -= AST
	return turfs

/proc/Turfspawn_Asteroid_SeedEvents(var/list/turfs,var/amount)
	if (!turfs || length(turfs) < 1)
		return list()
	if (!isnum(amount) || amount <= 0)
		amount = rand(1,6)

	var/datum/ore/event/E
	var/turf/simulated/wall/auto/asteroid/AST

	while (amount > 0)
		amount--
		if (length(turfs) < 1)
			break
		E = weighted_pick(mining_controls.weighted_events)
		AST = pick(turfs)
		if (!istype(AST) || (E.restrict_to_turf_type && AST.type != E.restrict_to_turf_type))
			turfs -= AST
			amount++
			continue
		AST.set_event(E)

#undef TURF_SPAWN_EDGE_LIMIT
