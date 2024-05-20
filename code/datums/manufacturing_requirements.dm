/* These manufacture requirements are meant to simplify checking if a material satisfies a requirement for a blueprint.
   If you want a glass flock piece and don't care about it's material, it'd look like:
   /datum/manufacture_requirement/crystal/flock
   If you want any piece of flock and it must be dense, it'd look like:
   /datum/manufacture_requirement/dense/flock
*/

var/global/list/manufacturing_requirement_cache

/// Helps get an exact material when otherwise it would need to be pre-initialized.
/// Shameless rip off Mat_ProcsDefines.dm since the functionality is p much identical, as we ID specific mat reqs with material ID for this purpose
/proc/getExactMaterialRequirement(var/mat)
	#ifdef CHECK_MORE_RUNTIMES
	if (!istext(mat))
		CRASH("getExactMaterialRequirement() called with a non-text argument [mat].")
	if (!(mat in material_cache))
		CRASH("getExactMaterialRequirement() called with an invalid material id [mat].")
	#endif
	if(!istext(mat))
		return null
	return manufacturing_requirement_cache?[material_id]

ABSTRACT_TYPE(/datum/manufacturing_requirement)
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

	/// Returns whether or not the material in question matches our criteria. Defaults to true
	proc/is_match(var/datum/material/M)
		SHOULD_CALL_PARENT(TRUE)
		if (isnull(M))
			return FALSE
		if (!isnull(src.material_id) && !src.matches_id(M.getID()))
			return FALSE
		if (!isnull(src.material_flags) && !src.matches_flags(M.getMaterialFlags()))
			return FALSE
		if (!isnull(src.material_property) && !isnull(src.material_threshold) && !src.matches_property(M))
			return FALSE
		return TRUE

	/// Returns whether the material id is an exact match for the required id.
	proc/matches_id(var/material_id)
		return src.material_id == material_id

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
                    PLEASE ALPHABETIZE THANKS
***************************************************************/

	exact_material

		New(var/material_id)
			var/datum/material/M = getMaterial(material_id)
			name = initial(M.name)
			material_id = initial(M.getID())
			id = initial(M.getID())
	blob
		name = "Blob"
		material_id = "blob"
		id = "blob"

	butt
		name = "Butt"
		material_id = "butt"
		id = "butt"
	cardboard
		name = "Cardboard"
		material_id = "cardboard"
		id = "cardboard"

	cerenkite
		name = "Cerenkite"
		material_id = "cerenkite"
		id = "cerenkite"

	char
		name = "Char"
		material_id = "char"
		id = "char"

	cobryl
		name = "Cobryl"
		material_id = "cobryl"
		id = "cobryl"

	ectoplasm
		name = "Ectoplasm"
		material_id = "ectoplasm"
		id = "ectoplasm"

	electrum
		name = "Electrum"
		material_id = "electrum"

	erebite
		name = "Erebite"
		material_id = "erebite"

	exoweave
		name = "ExoWeave"
		material_id = "exoweave"

	gold
		name = "Gold"
		material_id = "gold"

	honey
		name = "Honey"
		material_id = "honey"

	ice
		name = "Ice"
		material_id = "ice"

	koshmarite
		name = "Koshmarite"
		material_id = "koshmarite"

	miracle
		name = "Miracle Matter"
		material_id = "miracle"
	molitz
		name = "Molitz"
		material_id = "molitz"

	neutronium
		name = "Neutronium"
		material_id = "neutronium"

	pharosium
		name = "Pharosium"
		material_id = "pharosium"

	plasmastone
		name = "Plasmastone"
		material_id = "plasmastone"

	starstone
		name = "Starstone"
		material_id = "starstone"
	syreline
		name = "Syreline"
		material_id = "Syreline"

	telecrystal
		name = "Telecrystal"
		material_id = "telecrystal"

	uqill
		name = "Uqill"
		material_id = "uqill"

	viscerite
		name = "Viscerite"
		material_id = "viscerite"

/***************************************************************
                      MATERIAL PROPERTIES
                    PLEASE ALPHABETIZE THANKS
***************************************************************/

	crystal
		name = "Crystal"
		material_flags = MATERIAL_CRYSTAL

		dense
			name = "Extraordinarily Dense Crystalline Matter"
			material_property = "density"
			material_threshold = 7

		gemstone
			name = "Gemstone"

			is_match(var/datum/material/M)
				if (!(istype(M, /datum/material/crystal/gemstone)))
					return FALSE
				. = ..()

	dense
		name = "High Density Matter"
		material_property = "density"
		material_threshold = 4

		super
			name = "Very High Density Matter"
			material_threshold = 6

	energy
		name = "Power Source"
		material_property = "radioactive"
		material_flags = MATERIAL_ENERGY

		high
			name = "Significant Power Source"
			material_threshold = 3

		extreme
			name = "Extreme Power Source"
			material_threshold = 5

	insulated
		name = "Insulative"
		material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER
		material_threshold = 4

		super
			name = "Highly Insulative"

		matches_property(datum/material/M)
			if (!(M.getProperty("electrical") <= src.material_threshold))
				return FALSE
			return TRUE

	metal
		name = "Metal"
		material_flags = MATERIAL_METAL

		dense
			name = "Sturdy Metal"
			material_threshold = 10

		superdense
			name = "Extremely Tough Metal"
			material_threshold = 15

		matches_property(var/datum/material/M)
			// Mauxite hardness = 15, Bohrum hardness = 33
			if (!(M.getProperty("hard") * 2 + M.getProperty("density") >= src.material_threshold))
				return FALSE
			return TRUE

	fabric
		name = "Fabric"
		material_flags = MATERIAL_CLOTH | MATERIAL_RUBBER | MATERIAL_ORGANIC

	organic_or_rubber
		name = "Organic or Rubber"
		material_flags = MATERIAL_ORGANIC | MATERIAL_RUBBER

	rubber
		name = "Rubber"
		material_flags = MATERIAL_RUBBER

	wood
		name = "Wood"
		material_flags = MATERIAL_WOOD

	reflective
		name = "Reflective"
		material_property = "reflective"
		material_threshold = 6

	conductive
		name = "Conductive"
		material_threshold = 6

		high
			name = "High Energy Conductor"
			material_threshold = 8

/***************************************************************
                              MISC
***************************************************************/


