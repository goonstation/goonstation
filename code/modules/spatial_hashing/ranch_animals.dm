/datum/spatial_hashmap/ranch_animals
	cell_size = 10





/mob/living/critter/small_animal/ranch_base/restore_life_processes()
	. = ..()
	global.ranch_animal_hashmap.register_hashmap_entry(src)

/mob/living/critter/small_animal/ranch_base/reduce_lifeprocess_on_death()
	global.ranch_animal_hashmap.unregister_hashmap_entry(src)
	. = ..()
