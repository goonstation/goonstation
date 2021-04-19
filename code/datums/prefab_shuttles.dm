var/list/prefab_shuttles = list()
/datum/prefab_shuttle
	var/prefab_path = null
	var/landmark = null

	proc/inialize_prefabs()
		switch(map_settings.escape_centcom)
			if(/area/shuttle/escape/centcom/cogmap)
				for(var/prefab_type in concrete_typesof(/datum/prefab_shuttle/cog1))
					var/datum/prefab_shuttle/D = new prefab_type()
					prefab_shuttles.Add(D)
			if(/area/shuttle/escape/centcom/cogmap2)
				for(var/prefab_type in concrete_typesof(/datum/prefab_shuttle/cog2))
					var/datum/prefab_shuttle/D = new prefab_type()
					prefab_shuttles.Add(D)
			if(/area/shuttle/escape/centcom/manta)
				for(var/prefab_type in concrete_typesof(/datum/prefab_shuttle/manta))
					var/datum/prefab_shuttle/D = new prefab_type()
					prefab_shuttles.Add(D)
			if(/area/shuttle/escape/centcom/sealab)
				for(var/prefab_type in concrete_typesof(/datum/prefab_shuttle/sealab))
					var/datum/prefab_shuttle/D = new prefab_type()
					prefab_shuttles.Add(D)
			if(/area/shuttle/escape/centcom/donut2)
				for(var/prefab_type in concrete_typesof(/datum/prefab_shuttle/donut2))
					var/datum/prefab_shuttle/D = new prefab_type()
					prefab_shuttles.Add(D)
			if(/area/shuttle/escape/centcom/donut3)
				for(var/prefab_type in concrete_typesof(/datum/prefab_shuttle/donut3))
					var/datum/prefab_shuttle/D = new prefab_type()
					prefab_shuttles.Add(D)
			if(/area/shuttle/escape/centcom/destiny)
				for(var/prefab_type in concrete_typesof(/datum/prefab_shuttle/destiny))
					var/datum/prefab_shuttle/D = new prefab_type()
					prefab_shuttles.Add(D)
			else
				return

/datum/prefab_shuttle/cog1
	prefab_path = "assets/maps/shuttles/cog1/cog1_default.dmm"
	landmark = LANDMARK_SHUTTLE_COG1

	dojo
		prefab_path = "assets/maps/shuttles/cog1/cog1-dojo.dmm"
	dream
		prefab_path = "assets/maps/shuttles/cog1/cog1-dream.dmm"
	iomoon
		prefab_path = "assets/maps/shuttles/cog1/cog1-iomoon.dmm"
	martian
		prefab_path = "assets/maps/shuttles/cog1/cog1-martian.dmm"
	syndicate
		prefab_path = "assets/maps/shuttles/cog1/cog1-syndicate.dmm"
	zen
		prefab_path = "assets/maps/shuttles/cog1/cog1-zenshuttle.dmm"

/datum/prefab_shuttle/cog2
	prefab_path = "assets/maps/shuttles/cog2/cog2_default.dmm"
	landmark = LANDMARK_SHUTTLE_COG2

	martian
		prefab_path = "assets/maps/shuttles/cog2/cog2_martian.dmm"

/datum/prefab_shuttle/manta
	prefab_path = "assets/maps/shuttles/manta/manta_default.dmm"
	landmark = LANDMARK_SHUTTLE_MANTA

/datum/prefab_shuttle/sealab
	prefab_path = "assets/maps/shuttles/sealab/oshan_default.dmm"
	landmark = LANDMARK_SHUTTLE_SEALAB

	meat
		prefab_path = "assets/maps/shuttles/sealab/oshan-meat.dmm"
	minisubs
		prefab_path = "assets/maps/shuttles/sealab/oshan-minisubs.dmm"

/datum/prefab_shuttle/donut2
	prefab_path = "assets/maps/shuttles/donut2/donut2_default.dmm"
	landmark = LANDMARK_SHUTTLE_DONUT2

/datum/prefab_shuttle/donut3
	prefab_path = "assets/maps/shuttles/donut3/donut3_default.dmm"
	landmark = LANDMARK_SHUTTLE_DONUT3

	cave
		prefab_path = "assets/maps/shuttles/donut3/donut3-cave.dmm"

/datum/prefab_shuttle/destiny
	prefab_path = "assets/maps/shuttles/destiny/destiny_default.dmm"
	landmark = LANDMARK_SHUTTLE_DESTINY
