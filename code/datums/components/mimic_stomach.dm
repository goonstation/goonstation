ABSTRACT_TYPE(/datum/component/mimic_stomach)
/datum/component/mimic_stomach
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/allocated_region/region
	var/turf/center
	var/last_appearance
	var/atom/exit
	var/list/obj/item/parts/limbs_eaten

TYPEINFO(/datum/component/mimic_stomach)
	initialization_args = list(
		ARG_INFO("width", DATA_INPUT_NUM, "Dimension width", 9),
		ARG_INFO("height", DATA_INPUT_NUM, "Dimension height", 9),
	)

/datum/component/mimic_stomach/Initialize(width=9, height=9, region_init_proc=null)
	. = ..()
	region = global.region_allocator.allocate(width, height)
	if(region_init_proc)
		call(region_init_proc)(region, parent)
	else
		src.default_init_region()

/datum/component/mimic_stomach/proc/default_init_region()
	region.clean_up(/turf/unsimulated/floor/setpieces/bloodfloor)

	for (var/x in 1 to region.width)
		for (var/y in 1 to region.height)
			var/turf/T = region.turf_at(x, y)
			if (region.turf_on_border(T))
				T.ReplaceWith(/turf/unsimulated/wall/setpieces/bloodwall)
			var/chance = rand(1,6)
			if (chance == 3)
				make_cleanable(/obj/decal/cleanable/blood/gibs, T)

	center = region.get_center()

/datum/component/mimic_stomach/proc/on_entered()
	var/mob/parent = src.parent
	parent.HealBleeding()
	parent.HealDamage("All", parent.max_health, parent.max_health)
	return

/datum/component/mimic_stomach/proc/on_disposing()
	exit = null
	qdel(src)

/datum/component/mimic_stomach/UnregisterFromParent()
	var/mob/living/critter/mimic/antag_spawn/parent = src.parent
	parent.death_barf()
	region.clean_up(/turf/space, /turf/space)
	qdel(region)
	. = ..()
