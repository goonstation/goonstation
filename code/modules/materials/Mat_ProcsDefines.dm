
var/global/list/material_cache = buildMaterialCache()

/atom/var/datum/material/material = null
/atom/var/material_amt = 1

/proc/isExploitableObject(var/atom/A)
	if(istype(A, /obj/item/tile) || istype(A, /obj/item/rods) || istype(A, /obj/item/sheet) || istype(A, /obj/item/cable_coil) || istype(A, /obj/item/raw_material/shard)) return 1
	return 0

/// This contains the names of the trigger lists on materials. Required for copying materials. Remember to keep this updated if you add new triggers.
var/global/list/triggerVars = list("triggersOnBullet", "triggersOnEat", "triggersTemp", "triggersChem", "triggersPickup", "triggersDrop", "triggersExp", "triggersOnAdd", "triggersOnLife", "triggersOnAttack", "triggersOnAttacked", "triggersOnEntered")

/// Returns one of the base materials by id.
/proc/getMaterial(mat)
	if(!istext(mat))
		return null
	return material_cache?[mat]

/proc/mergeProperties(var/list/leftProps, var/list/rightProps, var/rightBias=0.5)
	var/leftBias = 1 - rightBias

	var/list/merged = list()

	for(var/o in leftProps)
		//merged.Add(o)
		merged[o] = leftProps[o] * leftBias

	if(rightProps)
		for(var/x in rightProps)
			if(x in merged)
				merged[x] += rightProps[x] * rightBias
			else
				merged.Add(x)
				merged[x] = rightProps[x] * rightBias

	for(var/x in merged)
		merged[x] = round(merged[x])

	return merged

/// Returns a copy of a given material.
/proc/copyMaterial(var/datum/material/base)
	if(!base || !istype(base, /datum/material))
		var/datum/material/M = new/datum/material/interpolated()
		return M
	else
		var/datum/material/M = new base.type()
		M.properties = mergeProperties(base.properties, rightBias = 0)
		for(var/X in base.vars)
			if(X == "type" || X == "parent_type" || X == "tag" || X == "vars" || X == "properties" || X == "datum_components" || X == "comp_lookup" || X == "signal_procs") continue

			if(X in triggerVars)
				M.vars[X] = getFusedTriggers(base.vars[X], list(), M) //Pass in an empty list to basically copy the first one.
			else
				if(istype(base.vars[X],/list))
					var/list/oldList = base.vars[X]
					M.vars[X] = oldList.Copy()
				else
					M.vars[X] = base.vars[X]
		return M

/proc/isSameMaterial(var/datum/material/M1, var/datum/material/M2) //Compares two materials to determine if stacking should be allowed.
	if(isnull(M1) != isnull(M2))
		return 0
	if(isnull(M1) && isnull(M2))
		return 1
	if(M1.properties.len != M2.properties.len || M1.mat_id != M2.mat_id)
		return 0
	if(M1.value != M2.value || M1.name != M2.name  || M1.color != M2.color ||M1.alpha != M2.alpha || M1.material_flags != M2.material_flags || M1.texture != M2.texture)
		return 0

	for(var/datum/material_property/P1 in M1.properties)
		if(M2.getProperty(P1.id) != M1.properties[P1]) return 0
	for(var/datum/material_property/P2 in M2.properties)
		if(M1.getProperty(P2.id) != M2.properties[P2]) return 0

	for(var/X in triggerVars)
		for(var/datum/material_property/A in M1.vars[X])
			if(!(locate(A.type) in M2.vars[X])) return 0

		for(var/datum/material_property/B in M2.vars[X])
			if(!(locate(B.type) in M1.vars[X])) return 0

	return 1


/// Called AFTER the material of the object was changed.
/atom/proc/onMaterialChanged()
	if(istype(src.material))
		explosion_resistance = material.hasProperty("density") ? sqrt(round(max(4, material.getProperty("density")) - 4)) : explosion_resistance
		explosion_protection = material.hasProperty("density") ? sqrt(round(max(4, material.getProperty("density")) - 4)) : explosion_protection
		if( !(flags & CONDUCT) && (src.material.getProperty("electrical") >= 5)) flags |= CONDUCT


/// Simply removes a material from an object.
/atom/proc/removeMaterial()
	if(src.material)
		src.material.UnregisterSignal(src, COMSIG_ATOM_CROSSED)

	if(src.mat_changename)
		src.remove_prefixes(99)
		src.remove_suffixes(99)
		src.UpdateName()
		//src.name = initial(src.name)

	if(src.mat_changedesc)
		src.desc = initial(src.desc)

	src.alpha = initial(src.alpha)
	src.color = initial(src.color)
	src.icon = initial(src.icon)
	src.icon_state = initial(src.icon_state)
	src.material = null

//Time for some super verbose proc names.
/proc/get_material_trait_desc(var/datum/material/mat1)
	var/string = ""
	var/list/allTriggers = (mat1.triggersTemp + mat1.triggersChem + mat1.triggersPickup + mat1.triggersDrop + mat1.triggersExp + mat1.triggersOnAdd + mat1.triggersOnLife + mat1.triggersOnAttack + mat1.triggersOnAttacked + mat1.triggersOnEntered)
	for(var/datum/materialProc/P in allTriggers)
		if(length(P.desc))
			if(length(string))
				if(!findtext(string,P.desc))
					string += " " + P.desc
			else
				string = P.desc
	return string

/// if a material is listed in here then we don't take on its color/alpha (maybe, if this works)
/atom/var/list/mat_appearances_to_ignore = null

/proc/getMaterialPrefixList(datum/material/base)
	. = list()

	for(var/datum/material_property/P as anything in base.properties)
		if(base.properties[P] >= P.prefix_high_min)
			. |= P.getAdjective(base)
		else if(base.properties[P] <= P.prefix_low_max)
			. |= P.getAdjective(base)

/// Sets the material of an object. PLEASE USE THIS TO SET MATERIALS UNLESS YOU KNOW WHAT YOU'RE DOING.
/atom/proc/setMaterial(datum/material/mat1, appearance = TRUE, setname = TRUE, copy = TRUE, use_descriptors = FALSE)
	if(istext(mat1))
		CRASH("setMaterial() called with a string instead of a material datum.")
	if(!mat1 ||!istype(mat1, /datum/material))
		return
	if(copy)
		mat1 = copyMaterial(mat1)

	var/traitDesc = get_material_trait_desc(mat1)
	var/strPrefix = jointext(mat1.prefixes, " ")
	var/strSuffix = jointext(mat1.suffixes, " ")

	src.material?.UnregisterSignal(src, COMSIG_ATOM_CROSSED)

	if(length(mat1?.triggersOnEntered))
		mat1.RegisterSignal(src, COMSIG_ATOM_CROSSED, /datum/material/proc/triggerOnEntered)

	for(var/X in getMaterialPrefixList(mat1))
		strPrefix += " [X]"
	trim(strPrefix)

	if (src.mat_changename && setname)
		src.remove_prefixes(99)
		src.remove_suffixes(99)
		if(use_descriptors)
			src.name_prefix(strPrefix ? strPrefix : "")
			src.name_prefix(length(getQualityName(mat1.quality)) ? getQualityName(mat1.quality) : "")
		src.name_prefix(mat1.name ? mat1.name : "")
		if(use_descriptors)
			src.name_suffix(strSuffix ? "of [strSuffix]" : "")
		src.UpdateName()

	if (src.mat_changedesc && setname)
		if (istype(src, /obj))
			var/obj/O2 = src
			O2.desc = "[!isnull(O2.real_desc) ? "[O2.real_desc]" : "[initial(O2.desc)]"] It is made of [mat1.name].[length(traitDesc) ? " " + traitDesc : ""]"
		else
			src.desc = "[initial(src.desc)] It is made of [mat1.name].[length(traitDesc) ? " " + traitDesc : ""]"
		if (mat1.mat_id == "gold") //marks material gold as not a good choice to sell for people who dont already know
			src.desc += " It's probably not very valuable to a reputable buyer."
	if(appearance)
		src.setMaterialAppearance(mat1)
	src.material_applied_appearance = appearance //set the flag for whether we want to reapply material appearance on icon update
	src.material?.triggerOnRemove(src)
	src.material = mat1
	mat1.owner = src
	mat1.triggerOnAdd(src)
	src.onMaterialChanged()

/// sets the *appearance* of a material, but does not trigger any tiggerOnAdd or onMaterialChanged behaviour
/// Order of precedence is as follows:
/// if the material is in the list of appearences to ignore, do nothing
/// If an iconstate exists in the icon for iconstate$$materialID, that is chosen
/// If the material has mat_changeappaerance set, then first texture is applied, then color (including alpha)
/atom/proc/setMaterialAppearance(var/datum/material/mat1)
	src.alpha = 255
	src.color = null
	if (length(src.mat_appearances_to_ignore) && (mat1.name in src.mat_appearances_to_ignore))
		return

	var/potential_new_icon_state = "[splittext(src.icon_state,"$$")[1]]$$[mat1.mat_id]"
	if(src.is_valid_icon_state(potential_new_icon_state))
		src.icon_state = potential_new_icon_state
		return

	if (src.mat_changeappearance)
		if (mat1.texture)
			src.setTexture(mat1.texture, mat1.texture_blend, "material")
		if(mat1.applyColor)
			src.alpha = mat1.alpha
			src.color = mat1.color

/atom/proc/is_valid_icon_state(var/state)
	if(isnull(src.valid_icon_states[src.icon]))
		src.valid_icon_states[src.icon] = list()
		for(var/icon_state in icon_states(src.icon))
			src.valid_icon_states[src.icon][icon_state] = 1
	return state in src.valid_icon_states[src.icon]

/proc/getProcessedMaterialForm(var/datum/material/MAT)
	if (!istype(MAT))
		return /obj/item/material_piece // just in case

	// higher on this list means higher priority, be careful with it!
	if (MAT.material_flags & MATERIAL_CRYSTAL)
		return /obj/item/material_piece/block
	if (MAT.material_flags & MATERIAL_METAL)
		return /obj/item/material_piece
	if (MAT.material_flags & MATERIAL_ORGANIC)
		return /obj/item/material_piece/wad
	if (MAT.material_flags & MATERIAL_CLOTH)
		return /obj/item/material_piece/cloth
	if (MAT.material_flags & MATERIAL_RUBBER)
		return /obj/item/material_piece/block
	if (MAT.material_flags & MATERIAL_ENERGY)
		return /obj/item/material_piece/sphere

	return /obj/item/material_piece

/// Increases generations on material triggers and handles removal if over the generation cap.
/proc/handleTriggerGenerations(var/list/toDo)
	for(var/datum/materialProc/current in toDo)
		if(current.max_generations != -1 && (toDo[current] + 1) > current.max_generations)
			toDo.Remove(current)
		else
			toDo[current] = (toDo[current] + 1)
	return toDo

 /// Fuses two material trigger lists.
/proc/getFusedTriggers(var/list/L1 , var/list/L2, datum/material/newMat)
	var/list/newList = list()
	for(var/datum/materialProc/toCopy in L1) //Copy list 1 with new instances of trigger datum.
		var/datum/materialProc/P = new toCopy.type()
		newList.Add(P)	//Add new instance of datum
		newList[P] = L1[toCopy] //Set generation
		for(var/varCopy in toCopy.vars)
			if(varCopy == "type" || varCopy == "id" || varCopy == "parent_type" || varCopy == "tag" || varCopy == "vars") continue
			if(!issaved(toCopy.vars[varCopy])) continue
			P.vars[varCopy] = toCopy.vars[varCopy]

	for(var/datum/materialProc/A in L2) //Go through second list
		if((locate(A.type) in newList))	//We already have that trigger type from the other list
			var/datum/materialProc/existing = (locate(A.type) in newList) //Get the trigger datum from the other list
			if(newList[existing] <= L2[A]) continue	//If the generation of the datum that already exists is lower or equal to the new one, leave it alone.
			else newList[existing] = L2[A]			//Otherwise set the generation to the generation of the second copy because it is lower.
		else	//Trigger type isnt in the list yet.
			var/datum/materialProc/newProc = new A.type()	//Create a new instance
			newList.Add(newProc)	//Add to list
			newList[newProc] = L2[A]	//Set generation
			for(var/varCopy in A.vars)
				if(varCopy == "type" || varCopy == "id" || varCopy == "parent_type" || varCopy == "tag" || varCopy == "vars") continue
				if(!issaved(A.vars[varCopy])) continue
				newProc.vars[varCopy] = A.vars[varCopy]
	return newList

/// Merges two materials and returns result as new material.
/proc/getFusedMaterial(var/datum/material/mat1,var/datum/material/mat2)
	return getInterpolatedMaterial(mat1, mat2, 0.5)

/proc/getInterpolatedMaterial(var/datum/material/mat1,var/datum/material/mat2,var/t)
	var/ot = 1 - t
	var/datum/material/interpolated/newMat = new()

	newMat.quality = round(mat1.quality * ot + mat2.quality * t)

	newMat.prefixes = (mat1.prefixes | mat2.prefixes)
	newMat.suffixes = (mat1.suffixes | mat2.suffixes)

	newMat.value = round(mat1.value * ot + mat2.value * t)
	newMat.name = getInterpolatedName(mat1.name, mat2.name, 0.5)
	newMat.desc = "This is an alloy of [mat1.name] and [mat2.name]"
	newMat.mat_id = "([mat1.mat_id]+[mat2.mat_id])"
	newMat.alpha = round(mat1.alpha * ot + mat2.alpha * t)
	if(islist(mat1.color) || islist(mat2.color))
		var/list/colA = normalize_color_to_matrix(mat1.color)
		var/list/colB = normalize_color_to_matrix(mat2.color)
		newMat.color = list()
		for(var/i in 1 to length(colA))
			newMat.color += colA[i] * ot + colB[i] * t
	else
		newMat.color = rgb(round(GetRedPart(mat1.color) * ot + GetRedPart(mat2.color) * t), round(GetGreenPart(mat1.color) * ot + GetGreenPart(mat2.color) * t), round(GetBluePart(mat1.color) * ot + GetBluePart(mat2.color) * t))
	newMat.properties = mergeProperties(mat1.properties, mat2.properties, t)

	newMat.edible_exact = round(mat1.edible_exact * ot + mat2.edible_exact * t)
	if(newMat.edible_exact >= 0.5) newMat.edible = TRUE
	else newMat.edible = FALSE

	newMat.mixOnly = FALSE

	//--
	newMat.triggersTemp = getFusedTriggers(mat1.triggersTemp, mat2.triggersTemp, newMat)
	newMat.triggersChem = getFusedTriggers(mat1.triggersChem, mat2.triggersChem, newMat)
	newMat.triggersPickup = getFusedTriggers(mat1.triggersPickup, mat2.triggersPickup, newMat)
	newMat.triggersDrop = getFusedTriggers(mat1.triggersDrop, mat2.triggersDrop, newMat)
	newMat.triggersExp = getFusedTriggers(mat1.triggersExp, mat2.triggersExp, newMat)
	newMat.triggersOnAdd = getFusedTriggers(mat1.triggersOnAdd, mat2.triggersOnAdd, newMat)
	newMat.triggersOnLife = getFusedTriggers(mat1.triggersOnLife, mat2.triggersOnLife, newMat)
	newMat.triggersOnAttack = getFusedTriggers(mat1.triggersOnAttack, mat2.triggersOnAttack, newMat)
	newMat.triggersOnAttacked = getFusedTriggers(mat1.triggersOnAttacked, mat2.triggersOnAttacked, newMat)
	newMat.triggersOnEntered = getFusedTriggers(mat1.triggersOnEntered, mat2.triggersOnEntered, newMat)

	handleTriggerGenerations(newMat.triggersTemp)
	handleTriggerGenerations(newMat.triggersChem)
	handleTriggerGenerations(newMat.triggersPickup)
	handleTriggerGenerations(newMat.triggersDrop)
	handleTriggerGenerations(newMat.triggersExp)
	handleTriggerGenerations(newMat.triggersOnAdd)
	handleTriggerGenerations(newMat.triggersOnLife)
	handleTriggerGenerations(newMat.triggersOnAttack)
	handleTriggerGenerations(newMat.triggersOnAttacked)
	handleTriggerGenerations(newMat.triggersOnEntered)

	//Make sure the newly merged properties are informed about the fact that they just changed. Has to happen after triggers.
	for(var/datum/material_property/nProp in newMat.properties)
		nProp.onValueChanged(newMat, newMat.properties[nProp])

	//--

	//Texture merging. SUPER DUPER UGLY AAAAH
	if(mat2.texture && !mat1.texture)
		newMat.texture = mat2.texture
		newMat.texture_blend = mat2.texture_blend
	else if (mat1.texture && !mat2.texture)
		newMat.texture = mat1.texture
		newMat.texture_blend = mat1.texture_blend
	else if (mat1.texture && mat2.texture)
		if(mat1.generation == mat2.generation)
			//Mat1 has higher priority in this case. Optional: implement some shitty blended texture thing. probably a bad idea.
			newMat.texture = mat1.texture
			newMat.texture_blend = mat1.texture_blend
		else
			if(mat1.generation < mat2.generation)
				newMat.texture = mat1.texture
				newMat.texture_blend = mat1.texture_blend
			else
				newMat.texture = mat2.texture
				newMat.texture_blend = mat2.texture_blend
	//

	//This is sub-optimal and only used because im dumb
	if(mat1.material_flags & MATERIAL_CRYSTAL || mat2.material_flags & MATERIAL_CRYSTAL) newMat.material_flags |= MATERIAL_CRYSTAL
	if(mat1.material_flags & MATERIAL_METAL || mat2.material_flags & MATERIAL_METAL) newMat.material_flags |= MATERIAL_METAL
	if(mat1.material_flags & MATERIAL_CLOTH || mat2.material_flags & MATERIAL_CLOTH) newMat.material_flags |= MATERIAL_CLOTH
	if(mat1.material_flags & MATERIAL_ORGANIC || mat2.material_flags & MATERIAL_ORGANIC) newMat.material_flags |= MATERIAL_ORGANIC
	if(mat1.material_flags & MATERIAL_ENERGY || mat2.material_flags & MATERIAL_ENERGY) newMat.material_flags |= MATERIAL_ENERGY
	if(mat1.material_flags & MATERIAL_RUBBER || mat2.material_flags & MATERIAL_RUBBER) newMat.material_flags |= MATERIAL_RUBBER

	newMat.parent_materials.Add(mat1)
	newMat.parent_materials.Add(mat2)

	//RUN VALUE CHANGED ON ALL PROPERTIES TO TRIGGER PROPERS EVENTS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	return newMat

/// Merges two material names into one.
/proc/getInterpolatedName(var/mat1, var/mat2, var/t)
	var/ot = 1 - t
	var/part1 = copytext(mat1, 1, round((length(mat1) * ot) + 0.5))
	var/part2 = copytext(mat2, round((length(mat2) * ot) + 0.5), 0)
	return capitalize(ckey("[part1][part2]"))

/// Returns a string for when a material fail or breaks depending on its material flags.
/proc/getMatFailString(var/flag)
	if(flag & MATERIAL_METAL && flag & MATERIAL_CRYSTAL && flag & MATERIAL_CLOTH)
		return "frays apart into worthless dusty fibers"
	if(flag & MATERIAL_METAL && flag & MATERIAL_CRYSTAL)
		return "cracks and shatters into unworkable dust"
	if(flag & MATERIAL_CLOTH && flag & MATERIAL_CRYSTAL)
		return "shatters into useless brittle fibers"
	if(flag & MATERIAL_ENERGY && flag & MATERIAL_CRYSTAL)
		return "violently disintegrates into vapor"
	if(flag & MATERIAL_ENERGY && flag & MATERIAL_METAL)
		return "shines brightly before self-vaporizing"
	if(flag & MATERIAL_ENERGY && flag & MATERIAL_CLOTH)
		return "bursts into flames and is gone almost instantly"
	if(flag & MATERIAL_ENERGY && flag & MATERIAL_ORGANIC)
		return "catches on fire and rapidly burns to ash"
	if(flag & MATERIAL_ORGANIC)
		return "crumbles into worthless slime"
	if(flag & MATERIAL_CRYSTAL)
		return "shatters to dust and blows away"
	if(flag & MATERIAL_METAL)
		return "disintegrates into useless flakes"
	if(flag & MATERIAL_CLOTH)
		return "frays apart into useless strands"
	if(flag & MATERIAL_ENERGY)
		return "suddenly vanishes into nothingness"
	if(flag & MATERIAL_RUBBER)
		return "melts into an unworkable pile of slop"
	return "comes apart"

/// Translates a material flag into a string.
/proc/getMatFlagString(var/flag)
	switch(flag)
		if(MATERIAL_CRYSTAL)
			return "Crystal"
		if(MATERIAL_METAL)
			return "Metal"
		if(MATERIAL_CLOTH)
			return "Fabric"
		if(MATERIAL_ORGANIC)
			return "Organic Matter"
		if(MATERIAL_ENERGY)
			return "Energy Source"
		if(MATERIAL_RUBBER)
			return "Rubber"
		else
			return "Unknown"

/// Simply returns a string for a given quality. Used as prefix for objects.
/proc/getQualityName(var/quality)
	switch(quality)
		if(-INFINITY to -101)
			return "useless"
		if(-100 to -91)
			return "atrocious"
		if(-90 to -81)
			return "wretched"
		if(-80 to -71)
			return "crap"
		if(-70 to -61)
			return "awful"
		if(-60 to -51)
			return "terrible"
		if(-50 to -41)
			return "bad"
		if(-40 to -31)
			return "shabby"
		if(-30 to -21)
			return "mediocre"
		if(-20 to -11)
			return "low-quality"
		if(-10 to -1)
			return "poor"
		if(0)
			return ""
		if(1 to 10)
			return "decent"
		if(11 to 20)
			return "fine"
		if(21 to 30)
			return "good"
		if(31 to 40)
			return "great"
		if(41 to 50)
			return "high-quality"
		if(51 to 60)
			return "excellent"
		if(61 to 70)
			return "superb"
		if(71 to 80)
			return "incredible"
		if(81 to 90)
			return "amazing"
		if(91 to 100)
			return "supreme"
		if(101 to INFINITY)
			return "perfect"
		else
			return "odd"

/// Checks if a material matches a recipe and returns the recipe if a match is found. returns null if nothing matches it.
/proc/matchesMaterialRecipe(var/datum/material/M)
	for(var/datum/material_recipe/R in materialRecipes)
		if(R.validate(M)) return R
	return null

/**
	* Searches the parent materials of the given material, up to a given generation, for an id.
	*
	* Useful if you want to figure out if a given material was used in the making of another material.
	*
	* Keep in mind that this can be expensive so use it only when you have to.
	*/
/proc/hasParentMaterial(var/datum/material/M, var/search_id, var/max_generations = 3)
	return searchMatTree(M, search_id, 0, max_generations)

/proc/searchMatTree(var/datum/material/M, var/id, var/current_depth, var/max_depth = 3)
	if(!M || !id) return null
	if(!M.parent_materials.len) return null
	for(var/datum/material/CM in M.parent_materials)
		if(CM.mat_id == id) return CM
		if(current_depth + 1 <= max_depth)
			var/temp = searchMatTree(CM, id, current_depth + 1, max_depth)
			if(temp) return temp
	return null

/// Yes hello apparently we need a proc for this because theres a million types of different wires and cables.
/proc/applyCableMaterials(atom/C, datum/material/insulator, datum/material/conductor, copy_material = TRUE)
	if(!conductor) return // silly

	if(istype(C, /obj/cable))
		var/obj/cable/cable = C
		cable.insulator = insulator
		cable.conductor = conductor

		if (cable.insulator)
			cable.setMaterial(cable.insulator, copy = copy_material)
			cable.name = "[cable.insulator.name]-insulated [cable.conductor.name]-cable"
			cable.color = cable.insulator.color
		else
			cable.setMaterial(cable.conductor, copy = copy_material)
			cable.name = "uninsulated [cable.conductor.name]-cable"
			cable.color = cable.conductor.color

	else if(istype(C, /obj/item/cable_coil))
		var/obj/item/cable_coil/coil = C

		coil.insulator = insulator
		coil.conductor = conductor

		if (coil.insulator)
			coil.setMaterial(coil.insulator, copy = copy_material)
			coil.color = coil.insulator.color
		else
			coil.setMaterial(coil.conductor, copy = copy_material)
			coil.color = coil.conductor.color
		coil.updateName()
