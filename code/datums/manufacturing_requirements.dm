/* These manufacture requirements are meant to simplify checking if a material satisfies a requirement for a blueprint.
   If you want a glass flock piece and don't care about it's material, it'd look like:
   /datum/manufacture_requirement/crystal/flock
   If you want any piece of flock and it must be dense, it'd look like:
   /datum/manufacture_requirement/dense/flock
*/

var/global/list/requirement_cache

/proc/getRequirement(var/R_id)
	return requirement_cache?[R_id]

ABSTRACT_TYPE(/datum/manufacturing_requirement)
ABSTRACT_TYPE(/datum/manufacturing_requirement/match_property)
/datum/manufacturing_requirement
	/// Player-facing name of the requirement.
	var/name = "Unknown"
	/// Internal, unique ID of the requirement to use for the cache list.
	var/id = null
	/// Material ID of the material to checl. None if null, some string like "erebite" if used. Meant for exact material checks.
	var/material_id = null
	/// Material flags of the material to check. None of null, can be made like MATERIAL_A | MATERIAL_B if needed to check for either.
	var/material_flags = null
	/// Property of the material to check. None if null, some string like "radioactive" if used
	var/material_property = null
	/// Context-dependent material threshold for an item. Use if you want to check a material property of something. Currently just checks if >=
	var/material_threshold = null

	// ID must be defined, or else we have a problem
	#ifdef CHECK_MORE_RUNTIMES
	New()
		. = ..()
		if (isnull(id))
			CRASH("[src] created with a null id")
	#endif

	proc/get_id()
		return src.id

	/// Returns whether or not the material in question matches our criteria. Defaults to true
	proc/is_match(var/datum/material/M)
		SHOULD_CALL_PARENT(TRUE)
		if (isnull(M))
			return FALSE
		return TRUE

/datum/manufacturing_requirement/any
	name = "Any"
	id = "any"

/// All instances of this are generated at runtime for the cache
/datum/manufacturing_requirement/match_material
	/// All you need to do is define the material id. we can take it from there ;P
	New(var/material_id)
		src.id = material_id
		src.material_id = material_id
		var/datum/material/M = getMaterial(src.id)
		src.name = capitalize(M.getName())
		. = ..()

	is_match(var/datum/material/M)
		if (!isnull(src.material_id) && !src.matches_id(M.getID()))
			return FALSE
		. = ..()

	/// Returns whether the material id is an exact match for the required id.
	proc/matches_id(var/material_id)
		return src.material_id == material_id

/***************************************************************
                      MATERIAL PROPERTIES

           Includes material flag checks with properties

                    PLEASE ALPHABETIZE THANKS
***************************************************************/

/datum/manufacturing_requirement/match_property
	is_match(var/datum/material/M)
		var/should_match_property = !isnull(src.material_property) || !isnull(src.material_threshold)
		if (should_match_property && !src.matches_property(M))
			return FALSE
		if (!isnull(src.material_flags) && !src.matches_flags(M.getMaterialFlags()))
			return FALSE
		. = ..()

	/// Returns whether the material flags are matched. This will return true should any flag match.
	proc/matches_flags(var/material_flags)
		return material_flags & src.material_flags

	/// Returns whether the material property matches the given criterion. Default behavior is to check if >=, override w/o calling parent for diff behavior.
	proc/matches_property(var/datum/material/M)
		return M.getProperty(src.material_property) >= src.material_threshold

/datum/manufacturing_requirement/match_property/conductive
	name = "Conductive"
	id = "conductive"
	material_property = "electrical"
	material_threshold = 6

/datum/manufacturing_requirement/match_property/conductive/high
	name = "High Energy Conductor"
	id = "conductive_high"
	material_threshold = 8

/datum/manufacturing_requirement/match_property/crystal
	name = "Crystal"
	id = "crystal"
	material_flags = MATERIAL_CRYSTAL

/datum/manufacturing_requirement/match_property/crystal/dense
	name = "Extraordinarily Dense Crystalline Matter"
	id = "crystal_dense"
	material_property = "density"
	material_threshold = 7

/datum/manufacturing_requirement/match_property/crystal/gemstone
	name = "Gemstone"
	id = "gemstone"

	is_match(var/datum/material/M)
		if (!(istype(M, /datum/material/crystal/gemstone)))
			return FALSE
		. = ..()

/datum/manufacturing_requirement/match_property/dense
	name = "High Density Matter"
	id = "dense"
	material_property = "density"
	material_threshold = 4

/datum/manufacturing_requirement/match_property/dense/super
	name = "Very High Density Matter"
	id = "dense_super"
	material_threshold = 6

/datum/manufacturing_requirement/match_property/energy
	name = "Power Source"
	id = "energy"
	material_property = "radioactive"
	material_flags = MATERIAL_ENERGY

/datum/manufacturing_requirement/match_property/energy/high
	name = "Significant Power Source"
	id = "energy_high"
	material_threshold = 3

/datum/manufacturing_requirement/match_property/energy/extreme
	name = "Extreme Power Source"
	id = "energy_extreme"
	material_threshold = 5

/datum/manufacturing_requirement/match_property/fabric
	name = "Fabric"
	id = "fabric"
	material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER | MATERIAL_ORGANIC

/datum/manufacturing_requirement/match_property/insulated
	name = "Insulative"
	id = "insulated"
	material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER
	material_threshold = 4

	matches_property(datum/material/M)
		if (!(M.getProperty("electrical") <= src.material_threshold))
			return FALSE
		return TRUE

/datum/manufacturing_requirement/match_property/insulated/super
	id = "insulative_high"
	name = "Highly Insulative"
	material_threshold = 2

/datum/manufacturing_requirement/match_property/metal
	name = "Metal"
	id = "metal"
	material_flags = MATERIAL_METAL
	material_threshold = 0 // So we try to match properties

	matches_property(var/datum/material/M)
		// This specific check is based off the hardness of mauxite and bohrum.
		// Mauxite ends up being 10 in here, while bohrum ends up being 16.
		if (((M.getProperty("hard") * 2) + M.getProperty("density")) >= src.material_threshold)
			return TRUE
		return FALSE

/datum/manufacturing_requirement/match_property/metal/dense
	name = "Sturdy Metal"
	id = "metal_dense"
	material_threshold = 10

/datum/manufacturing_requirement/match_property/metal/superdense
	name = "Extremely Tough Metal"
	id = "metal_superdense"
	material_threshold = 15

/datum/manufacturing_requirement/match_property/organic_or_rubber
	name = "Organic or Rubber"
	id = "organic_or_rubber"
	material_flags = MATERIAL_ORGANIC | MATERIAL_RUBBER

/datum/manufacturing_requirement/match_property/reflective
	name = "Reflective"
	id = "reflective"
	material_property = "reflective"
	material_threshold = 6

/datum/manufacturing_requirement/match_property/rubber
	name = "Rubber"
	id = "rubber"
	material_flags = MATERIAL_RUBBER

/datum/manufacturing_requirement/match_property/wood
	name = "Wood"
	id = "wood"
	material_flags = MATERIAL_WOOD
