/* These manufacture requirements are meant to simplify checking if a material satisfies a requirement for a blueprint.
   If you want a glass flock piece and don't care about it's material, it'd look like:
   /datum/manufacture_requirement/crystal/flock
   If you want any piece of flock and it must be dense, it'd look like:
   /datum/manufacture_requirement/dense/flock
*/

var/global/list/requirement_cache

/// Helps get an exact requirement when otherwise it would need to be pre-initialized.
/// Shameless rip off Mat_ProcsDefines.dm since the functionality is p much identical
/proc/getRequirement(var/datum/manufacturing_requirement/R)
	#ifdef CHECK_MORE_RUNTIMES
	if (!istype(R, /datum/manufacturing_requirement/))
		CRASH("getMaterialsRequirementSatisfies() called with non-datum argument [R].")
	if (!(R in requirement_cache))
		CRASH("getMaterialsRequirementSatisfies() called with an invalid datum [R].")
	#endif
	if (!istype(R, /datum/manufacturing_requirement/))
		return null
	return requirement_cache?[R]

ABSTRACT_TYPE(/datum/manufacturing_requirement)
ABSTRACT_TYPE(/datum/manufacturing_requirement/match_material)
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

	/// Returns whether or not the material in question matches our criteria. Defaults to true
	proc/is_match(var/datum/material/M)
		SHOULD_CALL_PARENT(TRUE)
		if (isnull(M))
			return FALSE
		if (!isnull(src.material_flags) && !src.matches_flags(M.getMaterialFlags()))
			return FALSE
		return TRUE

	/// Returns whether the material flags are matched. This will return true should any flag match.
	proc/matches_flags(var/material_flags)
		return material_flags & src.material_flags

	/// Returns whether the material property matches the given criterion. Default behavior is to check if >=, override w/o calling parent for diff behavior.
	proc/matches_property(var/datum/material/M)
		return M.getProperty(src.material_property) >= src.material_threshold

	any
		name = "Any"
		id = "any"

/***************************************************************
                      EXACT MATERIAL MATCH

	     These are subtypes so only one instance is needed.
       If you're adding one, just add the material id as the
			       id property and type name.

                    PLEASE ALPHABETIZE THANKS
***************************************************************/
	match_material
		/// All you need to do is define the material id. we can take it from there ;P
		New()
			..()
			var/datum/material/M = getMaterial(src.id)
			src.name = M.getName()
			src.material_id = initial(src.id)

		is_match(var/datum/material/M)
			if (!isnull(src.material_id) && !src.matches_id(M.getID()))
				return FALSE
			. = ..()

		/// Returns whether the material id is an exact match for the required id.
		proc/matches_id(var/material_id)
			return src.material_id == material_id

		bamboo
			id = "bamboo"

		blob
			id = "blob"

		butt
			id = "butt"

		cardboard
			id = "cardboard"

		cerenkite
			id = "cerenkite"

		char
			id = "char"

		claretine
			id = "claretine"

		cobryl
			id = "cobryl"

		ectoplasm
			id = "ectoplasm"

		electrum
			id = "electrum"

		erebite
			id = "erebite"

		exoweave
			id = "exoweave"

		gold
			id = "gold"

		honey
			id = "honey"

		ice
			id = "ice"

		iridiumalloy
			id = "iridiumalloy"

		koshmarite
			id = "koshmarite"

		miracle
			id = "miracle"

		molitz
			id = "molitz"

		neutronium
			id = "neutronium"

		pharosium
			id = "pharosium"

		plasmastone
			id = "plasmastone"

		plutonium
			id = "plutonium"

		starstone
			id = "starstone"

		syreline
			id = "syreline"

		telecrystal
			id = "telecrystal"

		uqill
			id = "uqill"

		viscerite
			id = "viscerite"

/***************************************************************
                      MATERIAL PROPERTIES

           Includes material flag checks with properties

                    PLEASE ALPHABETIZE THANKS
***************************************************************/

	match_property
		is_match(var/datum/material/M)
			if (!isnull(src.material_property) && !isnull(src.material_threshold) && !src.matches_property(M))
				return FALSE
			. = ..()
		conductive
			name = "Conductive"
			id = "conductive"
			material_threshold = 6

			high
				name = "High Energy Conductor"
				id = "conductive_high"
				material_threshold = 8

		crystal
			name = "Crystal"
			id = "crystal"
			material_flags = MATERIAL_CRYSTAL

			dense
				name = "Extraordinarily Dense Crystalline Matter"
				id = "crystal_dense"
				material_property = "density"
				material_threshold = 7

			gemstone
				name = "Gemstone"
				id = "gemstone"

				is_match(var/datum/material/M)
					if (!(istype(M, /datum/material/crystal/gemstone)))
						return FALSE
					. = ..()

		dense
			name = "High Density Matter"
			id = "dense"
			material_property = "density"
			material_threshold = 4

			super
				name = "Very High Density Matter"
				id = "dense_high"
				material_threshold = 6

		energy
			name = "Power Source"
			id = "power"
			material_property = "radioactive"
			material_flags = MATERIAL_ENERGY

			high
				name = "Significant Power Source"
				id = "power_high"
				material_threshold = 3

			extreme
				name = "Extreme Power Source"
				id = "power_extreme"
				material_threshold = 5

		fabric
			name = "Fabric"
			id = "fabric"
			material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER | MATERIAL_ORGANIC

		insulated
			name = "Insulative"
			id = "insulative"
			material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER
			material_threshold = 4

			super
				id = "insulative_high"
				name = "Highly Insulative"

			matches_property(datum/material/M)
				if (!(M.getProperty("electrical") <= src.material_threshold))
					return FALSE
				return TRUE

		metal
			name = "Metal"
			id = "metal"
			material_flags = MATERIAL_METAL

			dense
				name = "Sturdy Metal"
				id = "metal_high"
				material_threshold = 10

			superdense
				name = "Extremely Tough Metal"
				id = "metal_extreme"
				material_threshold = 15

			matches_property(var/datum/material/M)
				// This specific check is based off the hardness of mauxite and bohrum.
				// Mauxite ends up being 15 in here, while bohrum ends up being 33.
				if (!(M.getProperty("hard") * 2 + M.getProperty("density") >= src.material_threshold))
					return FALSE
				return TRUE

		organic_or_rubber
			name = "Organic or Rubber"
			id = "organic_or_rubber"
			material_flags = MATERIAL_ORGANIC | MATERIAL_RUBBER

		reflective
			name = "Reflective"
			id = "reflective"
			material_property = "reflective"
			material_threshold = 6

		rubber
			name = "Rubber"
			id = "rubber"
			material_flags = MATERIAL_RUBBER

		wood
			name = "Wood"
			id = "wood"
			material_flags = MATERIAL_WOOD
