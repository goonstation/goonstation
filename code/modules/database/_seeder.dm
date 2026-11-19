#define RUN_SEEDER(type, handle) get_singleton(type):Seed(handle)
/// Seeders for the local fallback sqlite database
ABSTRACT_TYPE(/datum/seeder)
/datum/seeder

/datum/seeder/proc/Seed(handle)
	return
