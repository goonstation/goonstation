// Prefabs that can spawn anywhere
TYPEINFO(/datum/mapPrefab/mining/anywhere)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining/anywhere)
/datum/mapPrefab/mining/anywhere
	tags = PREFAB_ANYWHERE

	vault
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/anywhere/prefab_vault.dmm"
		prefabSizeX = 7
		prefabSizeY = 7

	tomb // small little tomb
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/anywhere/prefab_tomb.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	beacon // warp beacon for easy z5 teleporting.
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/anywhere/prefab_beacon.dmm"
		prefabSizeX = 5
		prefabSizeY = 5
