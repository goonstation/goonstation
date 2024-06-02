/* These manufacture requirements are meant to simplify checking if a material satisfies a requirement for a blueprint.
   If you want a glass flock piece and don't care about it's material, it'd look like:
   /datum/manufacture_requirement/crystal/flock
   If you want any piece of flock and it must be dense, it'd look like:
   /datum/manufacture_requirement/dense/flock
*/

var/global/list/requirement_cache

/proc/getRequirement(var/R_id)
	#ifdef CHECK_MORE_RUNTIMES
	if (!istext(R_id))
		CRASH("getRequirement() called with a non-text argument [R_id].")
	if (!(R_id in requirement_cache))
		CRASH("getRequirement() called with an invalid requirement id [R_id].")
	#endif
	// Sanity checks that all requirement IDs resolved to instances in the cache
	return requirement_cache?[R_id]

ABSTRACT_TYPE(/datum/manufacturing_requirement)
/datum/manufacturing_requirement
	var/name = "Unknown" //! Player-facing name of the requirement.
	var/id //! Internal, unique ID of the requirement to use for the cache list.

	// ID must be defined, or else we have a problem
	#ifdef CHECK_MORE_RUNTIMES
	New()
		. = ..()
		if (isnull(src.id))
			CRASH("[src] created with null id")
	#endif

	proc/get_id()
		return src.id

	/// Checks whether or not the given material meets the requirements enforced by this proc.
	proc/is_match(var/datum/material/M)
		SHOULD_CALL_PARENT(TRUE)
		return isnull(M)

/datum/manufacturing_requirement/not_null
	name = "Any"
	id = "any"

/// All instances of match_material are generated at runtime for the cache
ABSTRACT_TYPE(/datum/manufacturing_requirement/match_material)
/datum/manufacturing_requirement/match_material
	var/material_id //! Material ID of the material to check. None if null, some string like "erebite" if used. Meant for exact material checks.
	New(var/mat_id)
		src.id = mat_id
		src.material_id = mat_id
		var/datum/material/M = getMaterial(mat_id)
		src.name = capitalize(M.getName())
		. = ..()

	is_match(var/datum/material/M)
		. = ..()
		if (!.) return
		if (src.material_id != M.getID()) return


ABSTRACT_TYPE(/datum/manufacturing_requirement/match_property)
/datum/manufacturing_requirement/match_property
	var/property_id //! Material property to match by its string identifier
	var/property_threshold //! What threshold our property has to match or exceed in order to pass.

	#ifdef CHECK_MORE_RUNTIMES
	New()
		. = ..()
		if (isnull(src.property_id))
			CRASH("[src] created with null property_id")
		if (isnull(src.property_threshold))
			CRASH("[src] created with null property_threshold")
	#endif

	is_match(var/datum/material/M)
		. = ..()
		if (!.) return
		if (!src.match_property(M)) return

	/// Whether or not we match our criteria for this. Override to change behavior on checks
	proc/match_property(var/datum/material/M)
		return M.getProperty(src.property_id) >= property_threshold

/datum/manufacturing_requirement/match_property/conductive
	name = "Conductive"
	id = "electrical_property_>=_6"
	property_id = "electrical"
	property_threshold = 6

/datum/manufacturing_requirement/match_property/conductive/high
	name = "High Energy Conductor"
	id = "electrical_property_>=_8"
	property_threshold = 8

/datum/manufacturing_requirement/match_property/dense
	name = "High Density Matter"
	id = "dense_property_4"
	property_id = "density"
	property_threshold = 4

/datum/manufacturing_requirement/match_property/superdense
	name = "Very High Density Matter"
	id = "dense_property_6"
	property_id = "density"
	property_threshold = 6

/datum/manufacturing_requirement/match_property/ultradense
	name = "Ultra-Dense Matter"
	id = "dense_property_7"
	property_id = "density"
	property_threshold = 7

/datum/manufacturing_requirement/match_property/energy
	name = "Significant Power Source"
	id = "energy_property_3"
	property_id = "radioactive"
	property_threshold = 3

/datum/manufacturing_requirement/match_property/energy/high
	name = "Extreme Power Source"
	id = "energy_property_5"
	property_threshold = 5

/datum/manufacturing_requirement/match_property/insulated
	name = "Insulated Material"
	id = "electrical_property_<=_4"
	property_threshold = 4

	match_property(datum/material/M)
		return M.getProperty("electrical") <= src.property_threshold

/datum/manufacturing_requirement/match_property/insulated/super
	name = "Highly Insulative"
	id = "electrical_property_<=_2"
	property_id = "density"
	property_threshold = 2

/datum/manufacturing_requirement/match_property/tough
	name = "Tough Material"
	id = "tough_property_10"
	property_threshold = 10

	match_property(datum/material/M)
		// This specific check is based off the hardness of mauxite and bohrum.
		// Mauxite ends up being 10 in here, while bohrum ends up being 16.
		return ((M.getProperty("hard") * 2) + M.getProperty("density")) > src.property_threshold

/datum/manufacturing_requirement/match_property/tough/extreme
	name = "Extremely Tough Material"
	id = "tough_property_15"
	property_threshold = 15

/datum/manufacturing_requirement/match_property/reflective
	name = "Reflective"
	id = "reflective_property_6"
	property_id = "reflective"
	property_threshold = 6

#define MATCH_ANY 1 //! Pass as long as at least one flag is set.
#define MATCH_ALL 2 //! Pass if every material flag being checked is set.
#define MATCH_EXACT 3 //! Pass if every material flag being checked is set, and every material flag not checked is not set.

ABSTRACT_TYPE(/datum/manufacturing_requirement/match_flags)
/datum/manufacturing_requirement/match_flags
	var/material_flags //! The flag(s) of the material to match. This can be just one flag, or several with FLAG_A | FLAG_B | ...
	var/match_type = MATCH_ANY //! How we want to define a successful match. By default, pass as long as at least one flag is set.

	#ifdef CHECK_MORE_RUNTIMES
	#define VALID_MATCHES list(MATCH_ANY, MATCH_ALL, MATCH_EXACT) //! Values which match_type can be set to
	New()
		. = ..()
		if (isnull(src.material_flags))
			CRASH("[src] created with null material_flags")
		if (!(src.match_type in VALID_MATCHES))
			CRASH("[src] has invalid match_type [src.match_type], allowed values are [VALID_MATCHES]")
	#endif

	is_match(datum/material/M)
		. = ..()
		if (!.) return
		switch(src.match_type)
			if (MATCH_ANY)
				return material_flags & src.material_flags
			if (MATCH_ALL)
				CRASH("NYI")
			if (MATCH_EXACT)
				CRASH("NYI")

/datum/manufacturing_requirement/match_flags/metal
	name = "Metallic"
	id = "metal_flag"
	material_flags = MATERIAL_METAL

/datum/manufacturing_requirement/match_flags/wood
	name = "Wood"
	id = "wood_flag"
	material_flags = MATERIAL_WOOD

/datum/manufacturing_requirement/match_flags/rubber
	name = "Rubber"
	id = "rubber_flag"
	material_flags = MATERIAL_RUBBER

/datum/manufacturing_requirement/match_flags/organic_or_rubber
	name = "Organic or Rubber"
	id = "organic_or_rubber_flag"
	material_flags = MATERIAL_ORGANIC | MATERIAL_RUBBER


/datum/manufacturing_requirement/match_flags/fabric
	name = "Fabric"
	id = "fabric_flag"
	material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER | MATERIAL_ORGANIC

/datum/manufacturing_requirement/match_flags/crystal
	name = "Crystal"
	id = "crystal_flag"
	material_flags = MATERIAL_CRYSTAL

/datum/manufacturing_requirement/match_flags/energy
	name = "Energy Source"
	id = "energy_flag"
	material_flags = MATERIAL_ENERGY

/datum/manufacturing_requirement/match_flags/insulated
	name = "Insulative Material"
	id = "insulative_flags"
	material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER

#undef MATCH_ANY
#undef MATCH_ALL
#undef MATCH_EXACT

ABSTRACT_TYPE(/datum/manufacturing_requirement/match_subtypes)
/datum/manufacturing_requirement/match_subtypes
	var/match_typepath //! The parent type to use for istype() checks

	#ifdef CHECK_MORE_RUNTIMES
	New()
		. = ..()
		if (isnull(src.match_typepath) || !ispath(src.match_typepath))
			CRASH("[src] has invalid match_typepath [src.match_typepath], it must be non-null and a valid path (not an instance!)")
	#endif

	is_match(var/datum/material/M)
		. = ..()
		if (!.) return
		if (!(istype(M, src.match_typepath))) return

/datum/manufacturing_requirement/match_subtypes/gemstone
	name = "gemstone_subtypes"
	id = "gemstone_subtypes"
	match_typepath = /datum/material/crystal/gemstone

/// Manufacturing requirements which check several conditions at once.
ABSTRACT_TYPE(/datum/manufacturing_requirement/mixed)
/datum/manufacturing_requirement/mixed
	var/list/datum/manufacturing_requirement/requirements = list() //! A list of requirements which must all be satisfied for this to return TRUE

	is_match(datum/material/M)
		. = ..()
		if (!.) return
		for (var/datum/manufacturing_requirement/R as anything in src.requirements)
			if (!R.is_match(M)) return

/datum/manufacturing_requirement/mixed/dense_crystal
	name = "Extraordinarily Dense Crystalline Matter"
	id = "crystal_dense"
	requirements = list(
		/datum/manufacturing_requirement/match_property/ultradense,
		/datum/manufacturing_requirement/match_flags/crystal,
	)

/datum/manufacturing_requirement/mixed/metal
	name = "Metal"
	id = "metal"
	requirements = list(
		/datum/manufacturing_requirement/match_flags/metal,
	)

/datum/manufacturing_requirement/mixed/metal_tough
	name = "Sturdy Metal"
	id = "metal_tough"
	requirements = list(
		/datum/manufacturing_requirement/match_flags/metal,
		/datum/manufacturing_requirement/match_property/tough,
	)

/datum/manufacturing_requirement/mixed/metal_tough_extreme
	name = "Extremely Tough Metal"
	id = "metal_tough_extreme"
	requirements = list(
		/datum/manufacturing_requirement/match_flags/metal,
		/datum/manufacturing_requirement/match_property/tough/extreme,
	)

/datum/manufacturing_requirement/mixed/insulated
	name = "Insulative"
	id = "insulated"
	requirements = list(
		/datum/manufacturing_requirement/match_flags/insulated,
		/datum/manufacturing_requirement/match_property/insulated,
	)

/datum/manufacturing_requirement/mixed/insulated_high
	name = "Highly Insulative"
	id = "insulated_high"
	requirements = list(
		/datum/manufacturing_requirement/match_flags/insulated,
		/datum/manufacturing_requirement/match_property/insulated,
	)

/datum/manufacturing_requirement/mixed/energy_high
	name = "Significant Power Source"
	id = "energy_high"
	requirements = list(
		/datum/manufacturing_requirement/match_flags/energy,
		/datum/manufacturing_requirement/match_property/energy,
	)
/datum/manufacturing_requirement/mixed/energy_extreme
	name = "Extreme Power Source"
	id = "energy_extreme"
	requirements = list(
		/datum/manufacturing_requirement/match_flags/energy,
		/datum/manufacturing_requirement/match_property/energy/high,
	)
