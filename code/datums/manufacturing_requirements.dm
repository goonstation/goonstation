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
	/// Material ID of the material to check. None if null, some string like "erebite" if used. Meant for exact material checks.
	var/material_id = null
	/// Material flags of the material to check. None of null, can be made like MATERIAL_A | MATERIAL_B if needed to check for either.
	var/material_flags = null

	// ID must be defined, or else we have a problem
	#ifdef CHECK_MORE_RUNTIMES
	New()
		. = ..()
		if (isnull(id))
			CRASH("[src] created with a null id")
	#endif

	proc/get_id()
		return src.id

	/// Checks whether or not the given material meets the requirements enforced by this proc.
	proc/is_match(var/datum/material/M)
		// This should always be a sequence of checks which return FALSE if the material does not match a requirement.
		// See the check in match_material for a good example on this.
		SHOULD_CALL_PARENT(TRUE)
		if (isnull(M))
			return FALSE
		return TRUE

/datum/manufacturing_requirement/not_null
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
		. = ..()
		if (!.)
			return FALSE
		if (src.material_id != M.getID())
			return FALSE

/***************************************************************
                      MATERIAL PROPERTIES

          Match for a specific threshold of a property

                    PLEASE ALPHABETIZE THANKS
***************************************************************/

/datum/manufacturing_requirement/match_property

	/// Material property to match by its string identifier
	var/property_id
	/// What threshold our property has to match or exceed in order to pass.
	var/property_threshold = 0

	is_match(var/datum/material/M)
		. = ..()
		if (!.)
			return FALSE
		if (M.getProperty(src.property_id) < property_threshold)
			return FALSE
		return TRUE

/datum/manufacturing_requirement/match_property/conductive
	name = "Conductive"
	id = "conductive"
	property_id = "electrical"
	property_threshold = 6

/datum/manufacturing_requirement/match_property/conductive/high
	name = "High Energy Conductor"
	id = "conductive_high"
	property_threshold = 8

/datum/manufacturing_requirement/match_property/crystal
	name = "Crystal"
	id = "crystal"
	material_flags = MATERIAL_CRYSTAL

/datum/manufacturing_requirement/match_property/crystal/dense
	name = "Extraordinarily Dense Crystalline Matter"
	id = "crystal_dense"
	property_id = "density"
	property_threshold = 7

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
	property_id = "density"
	property_threshold = 4

/datum/manufacturing_requirement/match_property/dense/super
	name = "Very High Density Matter"
	id = "dense_super"
	property_threshold = 6

/datum/manufacturing_requirement/match_property/energy
	name = "Power Source"
	id = "energy"
	property_id = "radioactive"
	material_flags = MATERIAL_ENERGY

/datum/manufacturing_requirement/match_property/energy/high
	name = "Significant Power Source"
	id = "energy_high"
	property_threshold = 3

/datum/manufacturing_requirement/match_property/energy/extreme
	name = "Extreme Power Source"
	id = "energy_extreme"
	property_threshold = 5

/datum/manufacturing_requirement/match_property/fabric
	name = "Fabric"
	id = "fabric"
	material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER | MATERIAL_ORGANIC

/datum/manufacturing_requirement/match_property/insulated
	name = "Insulative"
	id = "insulated"
	material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER
	property_threshold = 4

	matches_property(datum/material/M)
		if (!(M.getProperty("electrical") <= src.property_threshold))
			return FALSE
		return TRUE

/datum/manufacturing_requirement/match_property/insulated/super
	id = "insulative_high"
	name = "Highly Insulative"
	property_threshold = 2

/datum/manufacturing_requirement/match_property/metal
	name = "Metal"
	id = "metal"
	material_flags = MATERIAL_METAL
	property_threshold = 0 // So we try to match properties

	matches_property(var/datum/material/M)
		// This specific check is based off the hardness of mauxite and bohrum.
		// Mauxite ends up being 10 in here, while bohrum ends up being 16.
		if (((M.getProperty("hard") * 2) + M.getProperty("density")) >= src.property_threshold)
			return TRUE
		return FALSE

/datum/manufacturing_requirement/match_property/metal/dense
	name = "Sturdy Metal"
	id = "metal_dense"
	property_threshold = 10

/datum/manufacturing_requirement/match_property/metal/superdense
	name = "Extremely Tough Metal"
	id = "metal_superdense"
	property_threshold = 15

/datum/manufacturing_requirement/match_property/organic_or_rubber
	name = "Organic or Rubber"
	id = "organic_or_rubber"
	material_flags = MATERIAL_ORGANIC | MATERIAL_RUBBER

/datum/manufacturing_requirement/match_property/reflective
	name = "Reflective"
	id = "reflective"
	property_id = "reflective"
	property_threshold = 6

/datum/manufacturing_requirement/match_property/rubber
	name = "Rubber"
	id = "rubber"
	material_flags = MATERIAL_RUBBER

/datum/manufacturing_requirement/match_property/wood
	name = "Wood"
	id = "wood"
	material_flags = MATERIAL_WOOD

/***************************************************************
                         MATERIAL FLAGS

              Requirements which only need flag checks

                    PLEASE ALPHABETIZE THANKS
***************************************************************/

/datum/manufacturing_requirement/match_flag

	is_match(datum/material/M)


	/// Returns whether the material flags are matched. This will return true should any flag match.
	proc/matches_flags(var/material_flags)
		return material_flags & src.material_flags


/// Manufacturing requirements which check several conditions at once.
/datum/manufacturing_requirement/mixed

	var/list/datum/manufacturing_requirement/requirements = list() //! A list of requirements which must all be satisfied for this to return TRUE

	is_match(datum/material/M)
		for (var/datum/manufacturing_requirement/R as anything in src.requirements)
			if (!R.is_match(M))
				return FALSE
		return TRUE

