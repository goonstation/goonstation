/**
 * Manufacturing Requirements are datums which check if a material satisfies some given requirements, to determine if a manufacturer can produce
 * a blueprint. Manufacturing datums define them by their string ID, which gets converted to the single instance of it in the cache on New().
 * Not shown in this file are the exact material ID requirement datums, which are generated for the cache on init using the material cache.
 */

var/global/list/requirement_cache

/proc/getManufacturingRequirement(var/R_id)
	// Sanity checks that all requirement IDs resolved to instances in the cache
	#ifdef CHECK_MORE_RUNTIMES
	if (!istext(R_id))
		CRASH("getManufacturingRequirement() called with a non-text argument [R_id].")
	if (!(R_id in requirement_cache))
		CRASH("getManufacturingRequirement() called with an invalid requirement id [R_id].")
	#endif
	return requirement_cache?[R_id]

ABSTRACT_TYPE(/datum/manufacturing_requirement)
/datum/manufacturing_requirement
	VAR_PROTECTED/name = "Unknown" //! Player-facing name of the requirement.
	VAR_PROTECTED/id //! Internal, unique ID of the requirement to use for the cache list.
	VAR_PROTECTED/art_reticulator_breakdown // material id that this requirement corresponds to for the artifact reticulator

	#ifdef CHECK_MORE_RUNTIMES
	New()
		. = ..()
		if (isnull(src.id))
			CRASH("[src] created with null id")
	#endif

	proc/getName()
		return src.name

	proc/getID()
		return src.id

	proc/get_art_ret_breakdown()
		return src.art_reticulator_breakdown

	/// Checks whether or not the given material meets the requirements enforced by this proc.
	proc/is_match(var/datum/material/M)
		SHOULD_CALL_PARENT(TRUE)
		return !isnull(M)

/datum/manufacturing_requirement/not_null
	name = "Any"
	id = "any"

/// All instances of match_material are generated at runtime for the cache
/datum/manufacturing_requirement/match_material
	VAR_PROTECTED/material_id //! Material ID of the material to check. None if null, some string like "erebite" if used. Meant for exact material checks.
	New(var/mat_id)
		src.id = mat_id
		src.material_id = mat_id
		var/datum/material/M = getMaterial(mat_id)
		src.name = capitalize(M.getName())
		. = ..()

	is_match(var/datum/material/M)
		. = ..()
		if (!.) return
		return src.material_id == M.getID()

ABSTRACT_TYPE(/datum/manufacturing_requirement/match_property)
/datum/manufacturing_requirement/match_property
	VAR_PROTECTED/property_id //! Material property to match by its string identifier
	VAR_PROTECTED/property_threshold //! What threshold our property has to match or exceed in order to pass.

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
		return src.match_property(M)

	/// Returns whether the material property meets the threshold. Overwrite to have behavior other than >=
	proc/match_property(var/datum/material/M)
		return M.getProperty(src.property_id) >= src.property_threshold

/datum/manufacturing_requirement/match_property/conductive
	name = "Conductive"
	id = "conductive"
	property_id = "electrical"
	property_threshold = 6
	art_reticulator_breakdown = "copper"


/datum/manufacturing_requirement/match_property/conductive/high
	name = "High Energy Conductor"
	id = "conductive_high"
	property_threshold = 8
	art_reticulator_breakdown = "claretine"

/datum/manufacturing_requirement/match_property/dense
	name = "High Density Matter"
	id = "dense"
	property_id = "density"
	property_threshold = 4
	art_reticulator_breakdown = "steel"

/datum/manufacturing_requirement/match_property/dense/super
	name = "Very High Density Matter"
	id = "dense_super"
	property_threshold = 6
	art_reticulator_breakdown = "bohrum"

/datum/manufacturing_requirement/match_property/dense/ultra
	name = "Ultra-Dense Matter"
	id = "dense_property_ultra"
	property_threshold = 7
	art_reticulator_breakdown = "uqill"

/datum/manufacturing_requirement/match_property/energy
	name = "Radioactive"
	id = "energy_property"
	property_id = "radioactive"
	property_threshold = 2
	art_reticulator_breakdown = "plasmastone"

/datum/manufacturing_requirement/match_property/energy/high
	name = "Highly Radioactive"
	id = "energy_property_high"
	property_threshold = 5
	art_reticulator_breakdown = "cerenkite"

/datum/manufacturing_requirement/match_property/insulated
	name = "Insulative Material"
	id = "insulated_property"
	property_id = "electrical"
	property_threshold = 4
	art_reticulator_breakdown = "latex"

	match_property(datum/material/M)
		return M.getProperty(src.property_id) <= src.property_threshold

/datum/manufacturing_requirement/match_property/insulated/super
	name = "Highly Insulative"
	id = "insulated_property_high"
	property_threshold = 2
	art_reticulator_breakdown = "synthrubber"

/datum/manufacturing_requirement/match_property/tough
	name = "Tough Material"
	id = "tough"
	property_id = "density"
	property_threshold = 10
	art_reticulator_breakdown = "mauxite"

	match_property(datum/material/M)
		// This specific check is based off the hardness of mauxite and bohrum.
		// Mauxite ends up being 10 in here, while bohrum ends up being 16.
		return ((M.getProperty("hard") * 2) + M.getProperty("density")) >= src.property_threshold

/datum/manufacturing_requirement/match_property/tough/extreme
	name = "Extremely Tough Material"
	id = "tough_super"
	property_threshold = 15
	art_reticulator_breakdown = "bohrum"

/datum/manufacturing_requirement/match_property/reflective
	name = "Reflective"
	id = "reflective"
	property_id = "reflective"
	property_threshold = 6
	art_reticulator_breakdown = "silver"

#define MATCH_ANY 1 //! Pass as long as at least one flag is set.
#define MATCH_ALL 2 //! Pass if every material flag being checked is set.
#define MATCH_EXACT 3 //! Pass if every material flag being checked is set, and every material flag not checked is not set.

ABSTRACT_TYPE(/datum/manufacturing_requirement/match_flags)
/datum/manufacturing_requirement/match_flags
	VAR_PROTECTED/material_flags //! The flag(s) of the material to match. This can be just one flag, or several with FLAG_A | FLAG_B | ...
	VAR_PROTECTED/match_type = MATCH_ANY //! How we want to define a successful match. By default, pass as long as at least one flag is set.

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
				return (M.getMaterialFlags(M) & src.material_flags) > 0
			if (MATCH_ALL)
				return (M.getMaterialFlags(M) & src.material_flags) == src.material_flags
			if (MATCH_EXACT)
				return (M.getMaterialFlags(M) == src.material_flags)

/datum/manufacturing_requirement/match_flags/metal
	name = "Metallic"
	id = "metal_flag"
	material_flags = MATERIAL_METAL
	art_reticulator_breakdown = "steel"

/datum/manufacturing_requirement/match_flags/wood
	name = "Wood"
	id = "wood_flag"
	material_flags = MATERIAL_WOOD
	art_reticulator_breakdown = "wood"

/datum/manufacturing_requirement/match_flags/rubber
	name = "Rubber"
	id = "rubber"
	material_flags = MATERIAL_RUBBER
	art_reticulator_breakdown = "latex"

/datum/manufacturing_requirement/match_flags/organic_or_rubber
	name = "Organic or Rubber"
	id = "organic_or_rubber"
	material_flags = MATERIAL_ORGANIC | MATERIAL_RUBBER
	art_reticulator_breakdown = "char"

/datum/manufacturing_requirement/match_flags/fabric
	name = "Fabric"
	id = "fabric"
	material_flags = MATERIAL_RUBBER | MATERIAL_ORGANIC | MATERIAL_CLOTH
	art_reticulator_breakdown = "cotton"

/datum/manufacturing_requirement/match_flags/crystal
	name = "Crystal"
	id = "crystal"
	material_flags = MATERIAL_CRYSTAL
	art_reticulator_breakdown = "silver"

/datum/manufacturing_requirement/match_flags/energy
	name = "Energy Source"
	id = "energy"
	material_flags = MATERIAL_ENERGY
	art_reticulator_breakdown = "plasmastone"

/datum/manufacturing_requirement/match_flags/insulated
	name = "Insulative Material"
	id = "insulative_flags"
	material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER
	art_reticulator_breakdown = "synthrubber"

#undef MATCH_ANY
#undef MATCH_ALL
#undef MATCH_EXACT

ABSTRACT_TYPE(/datum/manufacturing_requirement/match_subtypes)
/datum/manufacturing_requirement/match_subtypes
	VAR_PROTECTED/match_typepath //! The parent type to use for istype() checks

	#ifdef CHECK_MORE_RUNTIMES
	New()
		. = ..()
		if (isnull(src.match_typepath) || !ispath(src.match_typepath))
			CRASH("[src] has invalid match_typepath [src.match_typepath], it must be non-null and a valid path (not an instance!)")
	#endif

	is_match(var/datum/material/M)
		. = ..()
		if (!.) return
		return istype(M, src.match_typepath)

/datum/manufacturing_requirement/match_subtypes/gemstone
	name = "Gemstone"
	id = "gemstone"
	match_typepath = /datum/material/crystal/gemstone
	art_reticulator_breakdown = "quartz"

/// Manufacturing requirements which check several conditions at once.
ABSTRACT_TYPE(/datum/manufacturing_requirement/mixed)
/datum/manufacturing_requirement/mixed
	VAR_PROTECTED/list/requirement_ids = list() //! A list of requirement IDs to populate requirements with their instances in the cache
	VAR_PROTECTED/list/datum/manufacturing_requirement/requirements = null //! A list of requirements which must all be satisfied for this to return TRUE

	/// Resolve the requirement paths to instances in the cache.
	New()
		. = ..()
		src.requirements = new
		for (var/requirement_id as anything in src.requirement_ids)
			src.requirements += getManufacturingRequirement(requirement_id)

	is_match(datum/material/M)
		. = ..()
		if (!.) return
		for (var/datum/manufacturing_requirement/R as anything in src.requirements)
			if (!R.is_match(M)) return FALSE

/datum/manufacturing_requirement/mixed/dense_crystal
	name = "Extraordinarily Dense Crystalline Matter"
	id = "crystal_dense"
	requirement_ids = list(
		"dense_property_ultra",
		"crystal",
	)

/datum/manufacturing_requirement/mixed/metal
	name = "Metal"
	id = "metal"
	requirement_ids = list(
		"metal_flag",
	)
	art_reticulator_breakdown = "steel"

/datum/manufacturing_requirement/mixed/metal_tough
	name = "Sturdy Metal"
	id = "metal_dense"
	requirement_ids = list(
		"metal_flag",
		"tough",
	)
	art_reticulator_breakdown = "bohrum"

/datum/manufacturing_requirement/mixed/metal_tough_extreme
	name = "Extremely Tough Metal"
	id = "metal_superdense"
	requirement_ids = list(
		"metal_flag",
		"tough_super",
	)
	art_reticulator_breakdown = "uqill"

/datum/manufacturing_requirement/mixed/insulated
	name = "Insulative"
	id = "insulated"
	requirement_ids = list(
		"insulative_flags",
		"insulated_property",
	)
	art_reticulator_breakdown = "latex"

/datum/manufacturing_requirement/mixed/insulated_high
	name = "Highly Insulative"
	id = "insulative_high"
	requirement_ids = list(
		"insulative_flags",
		"insulated_property_high",
	)
	art_reticulator_breakdown = "synthrubber"

/datum/manufacturing_requirement/mixed/energy_high
	name = "Significant Power Source"
	id = "energy_high"
	requirement_ids = list(
		"energy",
		"energy_property",
	)
	art_reticulator_breakdown = "plasmastone"

/datum/manufacturing_requirement/mixed/energy_extreme
	name = "Extreme Power Source"
	id = "energy_extreme"
	requirement_ids = list(
		"energy",
		"energy_property_high",
	)
	art_reticulator_breakdown = "cerenkite"
