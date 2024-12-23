
var/global/list/material_cache

/atom/var/datum/material/material = null
/atom/var/material_amt = 1

/proc/isExploitableObject(var/atom/A)
	if(istype(A, /obj/item/tile) || istype(A, /obj/item/rods) || istype(A, /obj/item/sheet) || istype(A, /obj/item/cable_coil) || istype(A, /obj/item/raw_material/shard)) return 1
	return 0



/// Returns one of the base materials by id.
/proc/getMaterial(mat)
	#ifdef CHECK_MORE_RUNTIMES
	if (!istext(mat))
		CRASH("getMaterial() called with a non-text argument [mat].")
	if (!(mat in material_cache))
		CRASH("getMaterial() called with an invalid material id [mat].")
	#endif
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

	src.setMaterialAppearance(null)
	src.material = null


/// Sets the material of an object. PLEASE USE THIS TO SET MATERIALS UNLESS YOU KNOW WHAT YOU'RE DOING.
/atom/proc/setMaterial(datum/material/mat1, appearance = TRUE, setname = TRUE, mutable = FALSE, use_descriptors = FALSE)
	if(istext(mat1))
		CRASH("setMaterial() called with a string instead of a material datum.")
	if(!mat1 ||!istype(mat1, /datum/material))
		return
	if(mutable)
		mat1 = mat1.getMutable()

	src.material?.UnregisterSignal(src, COMSIG_ATOM_CROSSED)

	if(mat1?.countTriggers(TRIGGERS_ON_ENTERED))
		mat1.RegisterSignal(src, COMSIG_ATOM_CROSSED, /datum/material/proc/triggerOnEntered)

	if(mat1.getID() == default_material && !src.uses_default_material_name)
		setname = FALSE

	if (src.mat_changename && setname)
		src.remove_prefixes(99)
		src.remove_suffixes(99)
		if(mat1.usesSpecialNaming())
			src.UpdateName()
			src.name = mat1.specialNaming(src)
		else
			if(use_descriptors)
				var/strPrefix = jointext(mat1.getPrefixes(), " ")
				for(var/X in mat1.getMaterialPrefixList())
					strPrefix += " [X]"
				strPrefix = trimtext(strPrefix)
				src.name_prefix(strPrefix ? strPrefix : "")
			src.name_prefix(mat1.getName() ? mat1.getName() : "")
			if(use_descriptors)
				var/strSuffix = jointext(mat1.getSuffixes(), " ")
				src.name_suffix(strSuffix ? "of [strSuffix]" : "")
			src.UpdateName()

	if (src.mat_changedesc && setname)
		var/traitDesc = mat1.getMaterialTraitDesc()
		if (istype(src, /obj))
			var/obj/O2 = src
			O2.desc = "[!isnull(O2.real_desc) ? "[O2.real_desc]" : "[initial(O2.desc)]"] It is made of [mat1.getName()].[length(traitDesc) ? " " + traitDesc : ""]"
		else
			src.desc = "[initial(src.desc)] It is made of [mat1.getName()].[length(traitDesc) ? " " + traitDesc : ""]"
		if (mat1.getID() == "gold") //marks material gold as not a good choice to sell for people who dont already know
			src.desc += " It's probably not very valuable to a reputable buyer."
	if(appearance)
		src.setMaterialAppearance(mat1)
	src.material_applied_appearance = appearance //set the flag for whether we want to reapply material appearance on icon update
	src.material?.triggerOnRemove(src)
	src.material = mat1
	mat1.triggerOnAdd(src)
	src.onMaterialChanged()

/atom/proc/materialless_icon_state()
	. = src.icon_state ? splittext(src.icon_state,"$$")[1] : ""

/image/proc/materialless_icon_state()
	. = src.icon_state ? splittext(src.icon_state,"$$")[1] : ""

/// sets the *appearance* of a material, but does not trigger any tiggerOnAdd or onMaterialChanged behaviour
/// Order of precedence is as follows:
/// if the material is in the list of appearences to ignore, do nothing
/// If an iconstate exists in the icon for iconstate$$materialID, that is chosen
/// If the material has mat_changeappaerance set, then first texture is applied, then color (including alpha)
/atom/proc/setMaterialAppearance(datum/material/mat1)
	src.alpha = initial(src.alpha) // these two are technically not ideal but better than nothing I guess
	src.color = initial(src.color)
	var/base_icon_state = materialless_icon_state()

	if (isnull(mat1) || (mat1.getID() in src.get_typeinfo().mat_appearances_to_ignore) || \
			mat1.getID() == default_material && !src.uses_default_material_appearance)
		src.icon_state = base_icon_state
		src.setTexture(null, key="material")
		return

	var/potential_new_icon_state = "[base_icon_state]$$[mat1.getID()]"
	if(src.is_valid_icon_state(potential_new_icon_state))
		src.icon_state = potential_new_icon_state
		src.setTexture(null, key="material")
		return

	if (src.mat_changeappearance)
		if (mat1.getTexture())
			src.setTexture(mat1.getTexture(), mat1.getTextureBlendMode(), "material")
		else
			src.setTexture(null, key="material")
		if(mat1.shouldApplyColor())
			src.alpha = mat1.getAlpha()
			src.color = mat1.getColor()

/// Applies material icon_state override to an /image based on this atom's material (or the material provided)
/atom/proc/setMaterialAppearanceForImage(image/img, datum/material/mat=null)
	if(isnull(mat))
		mat = src.material
	var/base_icon_state = img.materialless_icon_state()
	if (isnull(mat) || (mat.getID() in src.get_typeinfo().mat_appearances_to_ignore))
		img.icon_state = base_icon_state
		return
	var/potential_new_icon_state = "[base_icon_state]$$[mat.getID()]"
	if(src.is_valid_icon_state(potential_new_icon_state))
		img.icon_state = potential_new_icon_state
		return

/atom/proc/is_valid_icon_state(var/state, icon=null)
	if(isnull(icon))
		icon = src.icon
	if(isnull(global.valid_icon_states[icon]))
		global.valid_icon_states[icon] = list()
		var/start_time = TIME
		for(var/icon_state in icon_states(icon))
			global.valid_icon_states[icon][icon_state] = 1
		if (TIME != start_time) //we took longer than a tick
			logTheThing(LOG_DEBUG, src, "is_valid_icon_state took [TIME - start_time] ticks(!!!) to cache [icon]")
	return state in global.valid_icon_states[icon]

/proc/getProcessedMaterialForm(var/datum/material/MAT)
	if (!istype(MAT))
		return /obj/item/material_piece // just in case

	// higher on this list means higher priority, be careful with it!
	if (MAT.getMaterialFlags() & MATERIAL_CRYSTAL)
		return /obj/item/material_piece/block
	if (MAT.getMaterialFlags() & MATERIAL_METAL)
		return /obj/item/material_piece/metal
	if (MAT.getMaterialFlags() & MATERIAL_ORGANIC)
		return /obj/item/material_piece/wad
	if (MAT.getMaterialFlags() & MATERIAL_CLOTH)
		return /obj/item/material_piece/cloth
	if (MAT.getMaterialFlags() & MATERIAL_RUBBER)
		return /obj/item/material_piece/block
	if (MAT.getMaterialFlags() & MATERIAL_ENERGY)
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
	return new /datum/material/interpolated(mat1, mat2, 0.5)

//custom matsci event procs
//Use these if you want the stom in general to interact in a special way with the items procs e.g. spears on attack triggering the tip, but on pickup the shafts material
//situation_modifier is for when you want something like specifying "chest" or "L_hand" for clothes

/// Called when a mob holding this atom is attacked for mat effects
/atom/proc/material_trigger_on_mob_attacked(var/mob/attacker, var/mob/attacked, var/atom/weapon, var/situation_modifier)
	if (src.material)
		src.material.triggerOnAttacked(src, attacker, attacked, weapon)
	return

/// Called when an atom is hit by a bullet for mat effects
/atom/proc/material_trigger_on_bullet(var/atom/attacked, var/obj/projectile/projectile, var/situation_modifier)
	if (src.material)
		src.material.triggerOnBullet(src, attacked, projectile)
	return

/// Called when an atom is hit by a bullet for mat effects
/atom/proc/material_trigger_on_chems(var/chem, var/amount)
	if (src.material)
		src.material.triggerChem(src, chem, amount)
	return

/// Called when an atom or someone wearing the material is attacked for mat effects
/atom/proc/material_trigger_on_blob_attacked(var/blobPower, var/situation_modifier)
	if (src.material)
		src.material.triggerOnBlobHit(src, blobPower)
	return

/// Called when an atom is used for an attack a atom for mat effects
/atom/proc/material_on_attack_use(var/mob/attacker, var/atom/attacked)
	if (src.material)
		src.material.triggerOnAttack(src, attacker, attacked)
	return

/// Called when an atom is caught in an explosion
/atom/proc/material_trigger_on_explosion(var/severity)
	if (src.material)
		src.material.triggerExp(src, severity)
	return

/// Called when an atom is affected by a heat change
/atom/proc/material_trigger_on_temp(var/temperature_applied)
	if (src.material)
		src.material.triggerTemp(src, temperature_applied)
	return

/// Called when the item is attacked with another atom for mat effects.
/// If someone is smashed against the item or with hands, the mob itself is expected to be passed as attackatom
/atom/proc/material_trigger_when_attacked(var/atom/attackatom, var/mob/attacker, var/meleeorthrow, var/situation_modifier)
	if (src.material)
		src.material.triggerOnHit(src, attackatom, attacker, meleeorthrow)
	return

///Called when an item is picked up for mat effects
/obj/item/proc/material_on_pickup(mob/user)
	if (src.material)
		src.material.triggerPickup(user, src)
	return

///Called when an item is dropped for mat effects
/obj/item/proc/material_on_drop(mob/user)
	if (src.material)
		src.material.triggerDrop(user, src)
	return


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

/// Checks if a material matches a recipe and returns the recipe if a match is found. returns null if nothing matches it.
/proc/matchesMaterialRecipe(var/datum/material/M)
	for(var/datum/material_recipe/R in materialRecipes)
		if(R.validate(M)) return R
	return null

/proc/findRecipeName(var/obj/item/One,var/obj/item/Two)
	var/tempmerge = getFusedMaterial(One.material, Two.material)
	for(var/datum/material_recipe/R in materialRecipes)
		if(R.validate(tempmerge)) return R
	return getInterpolatedName(One.material.getName(), Two.material.getName(), 0.5)

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
	if(!length(M.getParentMaterials())) return null
	for(var/datum/material/CM in M.getParentMaterials())
		if(CM.getID() == id) return CM
		if(current_depth + 1 <= max_depth)
			var/temp = searchMatTree(CM, id, current_depth + 1, max_depth)
			if(temp) return temp
	return null

/// Yes hello apparently we need a proc for this because theres a million types of different wires and cables.
/proc/applyCableMaterials(atom/C, datum/material/insulator, datum/material/conductor, copy_material = FALSE)
	if(!conductor) return // silly

	if(istype(C, /obj/cable))
		var/obj/cable/cable = C
		cable.insulator = insulator
		cable.conductor = conductor

		if (cable.insulator)
			cable.setMaterial(cable.insulator, mutable = copy_material)
			cable.name = "[cable.insulator.getName()]-insulated [cable.conductor.getName()]-cable"
			cable.color = cable.insulator.getColor()
		else
			cable.setMaterial(cable.conductor, mutable = copy_material)
			cable.name = "uninsulated [cable.conductor.getName()]-cable"
			cable.color = cable.conductor.getColor()

	else if(istype(C, /obj/item/cable_coil))
		var/obj/item/cable_coil/coil = C

		coil.insulator = insulator
		coil.conductor = conductor

		if (coil.insulator)
			coil.setMaterial(coil.insulator, mutable = copy_material)
			coil.color = coil.insulator.getColor()
		else
			coil.setMaterial(coil.conductor, mutable = copy_material)
			coil.color = coil.conductor.getColor()
		coil.updateName()

/**
 * Returns the thermal conductivity between two materials, based on thermal and electrical conductivity mat property.
 * Thermal conductivity ranges from 0 (perfect insulator) to infinity. Excellent conductors like copper are about 100
*/
proc/calculateHeatTransferCoefficient(var/datum/material/matA, var/datum/material/matB)
	var/hTC1 = 5
	var/hTC2 = 5
	if(matA)
		if(matA.hasProperty("thermal") && matA.hasProperty("electrical"))
			hTC1 = (max(matA.getProperty("thermal"),0) + max(matA.getProperty("electrical"),0))/2
		else if(matA.hasProperty("thermal"))
			hTC1 = max(matA.getProperty("thermal"),0)
		else if(matA.hasProperty("electrical"))
			hTC1 = max(matA.getProperty("electrical"),0)
	if(matB)
		if(matB.hasProperty("thermal") && matB.hasProperty("electrical"))
			hTC2 = (max(matB.getProperty("thermal"),0) + max(matB.getProperty("electrical"),0))/2
		else if(matB.hasProperty("thermal"))
			hTC2 = max(matB.getProperty("thermal"),0)
		else if(matB.hasProperty("electrical"))
			hTC2 = max(matB.getProperty("electrical"),0)
	//average thermal conductivity approximated as 10^(x/5)-1
	//common values 0 = 0, 5 = 10, 10 = 100
	return ((10**(hTC1/5)-1)+(10**(hTC2/5)-1))/2
