#define RUN_SEEDER(type) get_singleton(type):Seed()
/// Seeders for the local fallback sqlite database
ABSTRACT_TYPE(/datum/seeder)
/datum/seeder

/datum/seeder/proc/Seed(handle)
	return
