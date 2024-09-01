/datum/trigger_delegate
	var/datum/owner = null
	var/procname = null

	New(var/datum/D, var/name)
		..()
		owner = D
		procname = name


/**
	* # material
	* Base material datum definition
	*/
ABSTRACT_TYPE(/datum/material)
/datum/material
	///Is this a mutable instance? Defaults to true so creating new materials returns a mutable instance by default
	VAR_PRIVATE/tmp/mutable = TRUE
	/// used to retrieve instances of these base materials from the cache.
	VAR_PROTECTED/mat_id = "ohshitium"
	/// Whether this material should be stored in the material cache - only used for base types, modifying at runtime has no effect
	var/cached = TRUE
	/// Name of the material, used for combination and scanning
	VAR_PROTECTED/name = "Youshouldneverseemeium"
	/// Description of the material, used for scanning
	VAR_PROTECTED/desc = "This is a custom material."
	/// Associated list of all the various [/datum/material_property] that apply.
	/// list[/datum/material_property] = value
	VAR_PROTECTED/list/properties = list()
	/// Various flags. See [material_properties.dm]
	VAR_PROTECTED/material_flags = 0
	/// In percent of a base value. How much this sells for.
	VAR_PROTECTED/value = 100

	//naming stuff
	/// words that go before the name, used in combination
	VAR_PROTECTED/list/prefixes = list()
	/// words that go after the name, used in combination
	VAR_PROTECTED/list/suffixes = list()
	/// Whether the specaialNaming proc is called when this material is applied.
	VAR_PROTECTED/special_naming = FALSE

	//Vars for alloys
	/// Holds the parent materials.
	VAR_PROTECTED/list/parent_materials = list()
	/// Compound generation
	VAR_PROTECTED/generation = 0
	/// Can this be mixed with other materials?
	VAR_PROTECTED/canMix = 1
	/// Can this only be used after being combined with another material?
	VAR_PROTECTED/mixOnly = 0

	//material appearance vars
	/// if not null, texture will be set when mat is applied.
	VAR_PROTECTED/texture = ""
	/// How to blend the [/datum/material/var/texture].
	VAR_PROTECTED/texture_blend = BLEND_ADD
	/// Should this even color the objects made from it? Mostly used for base station materials like steel
	VAR_PROTECTED/applyColor = TRUE
	/// The color of the material
	VAR_PROTECTED/color = "#FFFFFF"
	/// The "transparency" of the material. Kept as alpha for logical reasons. Displayed as percentage ingame.
	VAR_PROTECTED/alpha = 255

	/// The actual value of edibility. Changes internally and sets [/datum/material/var/edible].
	VAR_PROTECTED/edible_exact = 0
	/// The functional value of edibility. Edible or not? This is what you check from the outside to see if material is edible. See [/datum/material/var/edible_exact].
	VAR_PROTECTED/edible = 0

	//triggers
	//IF YOU CHANGE THESE IN ANY WAY, YOU MUST UPDATE _std/defines/materials.dm
	/// Called when exposed to temperatures.
	VAR_PROTECTED/list/triggersTemp = list()
	/// Called when exposed to chemicals.
	VAR_PROTECTED/list/triggersChem = list()
	/// Called when owning object is picked up.
	VAR_PROTECTED/list/triggersPickup = list()
	/// Called when owning object is dropped.
	VAR_PROTECTED/list/triggersDrop = list()
	/// Called when exposed to explosions.
	VAR_PROTECTED/list/triggersExp = list()
	/// Called when the material is added to an object
	VAR_PROTECTED/list/triggersOnAdd = list()
	/// Called when the material is removed from an object
	VAR_PROTECTED/list/triggersOnRemove = list()
	/// Called when the life proc of a mob that has the owning item equipped runs.
	VAR_PROTECTED/list/triggersOnLife = list()
	/// Called when the owning object is used to attack something or someone.
	VAR_PROTECTED/list/triggersOnAttack = list()
	/// Called when a mob wearing the owning object is attacked.
	VAR_PROTECTED/list/triggersOnAttacked = list()
	/// Called when a mob wearing the owning object is shot.
	VAR_PROTECTED/list/triggersOnBullet = list()
	/// Called when *something* enters a turf with the material assigned. Also called on all objects on the turf with a material.
	VAR_PROTECTED/list/triggersOnEntered = list()
	/// Called when someone eats a thing with this material assigned.
	VAR_PROTECTED/list/triggersOnEat = list()
	/// Called when blob hits something with this material assigned.
	VAR_PROTECTED/list/triggersOnBlobHit = list()
	/// Called when an obj hits something with this material assigned.
	VAR_PROTECTED/list/triggersOnHit = list()


	New()
		. = ..()
		for(var/datum/material_property/propPath as anything in concrete_typesof(/datum/material_property))
			if(initial(propPath.default_value) > 0)
				src.setProperty(initial(propPath.id), initial(propPath.default_value))

	//getters for all the protected vars
	proc/getID()
		return src.mat_id

	proc/getName()
		return src.name

	proc/getDesc()
		return src.desc

	proc/getMaterialFlags()
		return src.material_flags

	proc/getValue()
		return src.value

	proc/usesSpecialNaming()
		return src.special_naming

	proc/getPrefixes()
		return src.prefixes.Copy()

	proc/getSuffixes()
		return src.suffixes.Copy()

	proc/getTexture()
		return src.texture

	proc/getTextureBlendMode()
		return src.texture_blend

	proc/shouldApplyColor()
		return src.applyColor

	proc/getColor()
		return src.color

	proc/getAlpha()
		return src.alpha

	proc/getEdible()
		return src.edible

	proc/getCanMix()
		return src.canMix

	proc/getMixOnly()
		return src.mixOnly

	proc/getMaterialProperties()
		return src.properties.Copy()

	proc/getParentMaterials()
		return src.parent_materials.Copy()

	proc/isMutable()
		return src.mutable

	//setters for protected vars
	proc/setID(var/id)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutatble material!")
		src.mat_id = id

	proc/setName(var/name)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutatble material!")
		src.name = name

	proc/setColor(var/color)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutatble material!")
		src.color = color

	proc/setCanMix(var/mix)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutatble material!")
		src.canMix = mix

	//mutability procs

	///Returns a mutable version of this material. Will return a copy of this material if it is already mutable.
	///The reason this is a separate proc and not using in getMaterial() is prevent cargo-culting accidentally reintroducing the
	///issue this was supposed to fix. Force the coders to explicitly ask for a mutable instance, demand to know why they want it to be mutable in reviews!
	proc/getMutable()
		return src.copyMaterial() //copy is mutable by default

	///Returns an immutable version of this material. Will return this material if it is already immutable.
	proc/getImmutable()
		if(!src.mutable)
			return src
		else
			var/datum/material/immutable = src.copyMaterial()
			immutable.mutable = FALSE
			return immutable

	proc/copyMaterial()
		var/datum/material/M = new src.type()
		M.properties = mergeProperties(src.properties, rightBias = 0)
		for(var/X in src.vars)
			if(!issaved(src.vars[X])) continue
			if(X in triggerVars)
				M.vars[X] = getFusedTriggers(src.vars[X], list(), M) //Pass in an empty list to basically copy the first one.
			else
				if(istype(src.vars[X],/list))
					var/list/oldList = src.vars[X]
					M.vars[X] = oldList.Copy()
				else
					M.vars[X] = src.vars[X]
		return M

	///Compares a material to this one to determine if stacking should be allowed.
	proc/isSameMaterial(var/datum/material/M2)
		if(src == M2) //since we're actually doing mutable/immutable now, we can frequently shortcut this with an actual equal check
			return TRUE

		if(isnull(M2))
			return FALSE

		if(length(src.properties) != length(M2.properties) || src.getID() != M2.getID())
			return FALSE

		if(src.value != M2.value || src.name != M2.name  || src.color ~! M2.color ||src.alpha != M2.alpha || src.getMaterialFlags() != M2.getMaterialFlags() || src.texture != M2.texture)
			return FALSE

		for(var/datum/material_property/P1 in src.properties)
			if(M2.getProperty(P1.id) != src.properties[P1]) return FALSE
		for(var/datum/material_property/P2 in M2.properties)
			if(src.getProperty(P2.id) != M2.properties[P2]) return FALSE

		for(var/X in triggerVars)
			for(var/datum/material_property/A in src.vars[X])
				if(!(locate(A.type) in M2.vars[X])) return FALSE

			for(var/datum/material_property/B in M2.vars[X])
				if(!(locate(B.type) in src.vars[X])) return FALSE

		return TRUE

	//utility procs

	///Time for some super verbose proc names.
	proc/getMaterialTraitDesc()
		var/string = ""
		var/list/allTriggers = (src.triggersTemp + src.triggersChem + src.triggersPickup + src.triggersDrop + src.triggersExp + src.triggersOnAdd + src.triggersOnLife + src.triggersOnAttack + src.triggersOnAttacked + src.triggersOnEntered)
		for(var/datum/materialProc/P in allTriggers)
			if(length(P.desc))
				if(length(string))
					if(!findtext(string,P.desc))
						string += " " + P.desc
				else
					string = P.desc
		return string

	//material procs

	proc/getProperty(var/property)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				return properties[P]
		return 0

	proc/getPropertyMin(var/property)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				return P.min_value

	proc/getPropertyMax(var/property)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				return P.max_value

	proc/removeProperty(var/property)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutable material!")
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				P.onRemoved(src)
				properties.Remove(P)
				return
		return

	proc/adjustProperty(var/property, var/value)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutable material!")
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				src.properties[P] = clamp(properties[P]+value, P.min_value, P.max_value)
				P.onValueChanged(src, properties[P])
				return
		return

	proc/setProperty(var/property, var/value)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutable material!")
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				src.properties[P] = clamp(value, P.min_value, P.max_value)
				P.onValueChanged(src, src.properties[P])
				return

		if(!length(materialProps)) //Required so that compile time object materials can have properties.
			buildMaterialPropertyCache()

		//if it's not already in .properties, add it and trigger onadd
		for(var/datum/material_property/P in materialProps)
			if(P.id == property)
				properties.Add(P)
				P.onAdded(src, value)
				src.properties[P] = clamp(value, P.min_value, P.max_value)
				P.onValueChanged(src, src.properties[P])
		return

	proc/hasProperty(var/property)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				return 1
		return 0

	///Triggers is specified using one of the TRIGGER_ON_ defines
	proc/addTrigger(var/triggerListName as text, var/datum/materialProc/D)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutatble material!")
		var/list/L = src.vars[triggerListName]
		for(var/datum/materialProc/P in L)
			if(P.type == D.type) return 0
		L.Add(D)
		L[D] = 0
		return

	/// Checks if material proc type is present for a given trigger in the material
	proc/hasTrigger(var/triggerListName as text, materialProcType)
		var/list/L = src.vars[triggerListName]
		for(var/datum/materialProc/P in L)
			if(istype(P, materialProcType)) return 1
		return 0

	///Triggers is specified using one of the TRIGGER_ON_ defines
	proc/removeTrigger(var/triggerListName as text, var/inType)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutatble material!")
		var/list/L = src.vars[triggerListName]
		for(var/datum/materialProc/P in L)
			if(P.type == inType)
				L.Remove(P)
		return

	///Triggers is specified using one of the TRIGGER_ON_ defines
	proc/removeAllTriggers(var/triggerListName as text)
		if(!src.mutable)
			CRASH("Attempted to mutate an immutatble material!")
		var/list/L = src.vars[triggerListName]
		L.Cut()
		return

	///Triggers is specified using one of the TRIGGER_ON_ defines
	proc/countTriggers(var/triggerListName as text)
		var/list/L = src.vars[triggerListName]
		return length(L)

	proc/interpolateName(datum/material/other, t)
		. = getInterpolatedName(src.name, other.name, t)

	proc/specialNaming(atom/target)
		. = target.name

	proc/triggerOnEntered(var/atom/owner, var/atom/entering)
		for(var/datum/materialProc/X in triggersOnEntered)
			X.execute(owner, entering)
		return

	proc/triggerOnAttacked(var/atom/owner, var/mob/attacker, var/mob/attacked, var/atom/weapon)
		for(var/datum/materialProc/X in triggersOnAttacked)
			X.execute(owner, attacker, attacked, weapon)
		return

	proc/triggerOnBullet(var/atom/owner, var/atom/attacked, var/obj/projectile/projectile)
		for(var/datum/materialProc/X in triggersOnBullet)
			X.execute(owner, attacked, projectile)
		return

	proc/triggerOnAttack(var/atom/owner, var/mob/attacker, var/atom/attacked)
		for(var/datum/materialProc/X in triggersOnAttack)
			X.execute(owner, attacker, attacked)
		return

	proc/triggerOnLife(var/mob/M, var/obj/item/I, mult)
		for(var/datum/materialProc/X in triggersOnLife)
			X.execute(M, I, mult)
		return

	proc/triggerOnAdd(var/location)
		for(var/datum/materialProc/X in triggersOnAdd)
			X.execute(location)
		return

	proc/triggerOnRemove(var/location)
		for(var/datum/materialProc/X in triggersOnRemove)
			X.execute(location)
		return

	proc/triggerChem(var/location, var/chem, var/amount)
		for(var/datum/materialProc/X in triggersChem)
			X.execute(location, chem, amount)
		return

	proc/triggerPickup(var/mob/M, var/obj/item/I)
		for(var/datum/materialProc/X in triggersPickup)
			X.execute(M, I)
		return

	proc/triggerDrop(var/mob/M, var/obj/item/I)
		for(var/datum/materialProc/X in triggersDrop)
			X.execute(M, I)
		return

	proc/triggerTemp(var/location, var/temp)
		for(var/datum/materialProc/X in triggersTemp)
			X.execute(location, temp)
		return

	proc/triggerExp(var/location, var/sev)
		for(var/datum/materialProc/X in triggersExp)
			X.execute(location, sev)
		return

	proc/triggerEat(var/mob/M, var/obj/item/I)
		for(var/datum/materialProc/X in triggersOnEat)
			X.execute(M, I)
		return

	proc/triggerOnBlobHit(var/atom/owner, var/blobPower)
		for(var/datum/materialProc/X in triggersOnBlobHit)
			X.execute(owner, blobPower)
		return

	proc/triggerOnHit(var/atom/owner, var/atom/attackatom, var/mob/attacker, var/meleeorthrow)
		for(var/datum/materialProc/X in triggersOnHit)
			X.execute(owner, attackatom, attacker, meleeorthrow)
		return

//material types

//Metals
ABSTRACT_TYPE(/datum/material/metal)
/datum/material/metal
	color = "#8C8C8C"

	New()
		. = ..()
		setProperty("electrical", 45)
		setProperty("thermal", 54)
		setProperty("density", 36)
		setProperty("chemical", 54)

/datum/material/metal/steel
	mat_id = "steel"
	name = "steel"
	desc = "Terrestrial steel from Earth."
	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 27)

/datum/material/metal/copper
	mat_id = "copper"
	name = "copper"
	desc = "Copper is a terrestrial conductive metal from proto-Dan mines. It is inferior to pharosium."
	color = "#B87333" //the hex value known as copper in RGB colorspace
	New()
		..()
		setProperty("electrical", 54)
		setProperty("density", 18)
		setProperty("hard", 9)

/datum/material/metal/pharosium
	mat_id = "pharosium"
	name = "pharosium"
	desc = "Pharosium is a conductive metal."
	color = "#E39362"
	New()
		..()
		setProperty("electrical", 63)
		setProperty("density", 18)
		setProperty("hard", 18)

/datum/material/metal/cobryl
	mat_id = "cobryl"
	name = "cobryl"
	desc = "Cobryl is a somewhat valuable metal."
	color = "#84D5F0"
	New()
		..()
		value = 175
		setProperty("density", 36)
		setProperty("hard", 18)
		setProperty("chemical", 72)

/datum/material/metal/bohrum
	mat_id = "bohrum"
	name = "bohrum"
	desc = "Bohrum is a heavy and highly durable metal."
	color = "#3D692D"
	New()
		..()
		setProperty("density", 54)
		setProperty("hard", 45)
		setProperty("chemical", 63)

/datum/material/metal/mauxite
	mat_id = "mauxite"
	name = "mauxite"
	desc = "Mauxite is a sturdy common metal."
	color = "#534747"
	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 27)

/datum/material/metal/cerenkite
	mat_id = "cerenkite"
	name = "cerenkite"
	desc = "Cerenkite is a highly radioactive metal."
	color = "#CDBDFF"

	New()
		..()
		value = 200

		setProperty("electrical", 54)
		setProperty("radioactive", 45)
		setProperty("hard", 18)

/datum/material/metal/syreline
	mat_id = "syreline"
	name = "syreline"
	desc = "Syreline is an extremely valuable and coveted metal."
	color = "#FAF5D4"

	New()
		..()
		value = 400

		setProperty("density", 9)
		setProperty("hard", 18)
		setProperty("reflective", 72)

		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/gold_add())

/datum/material/metal/gold
	mat_id = "gold"
	name = "gold"
	desc = "A somewhat valuable and conductive metal."
	color = "#F5BE18"

	New()
		..()
		value = 300

		setProperty("density", 54)
		setProperty("hard", 18)
		setProperty("reflective", 54)
		setProperty("electrical", 63)
		setProperty("thermal", 63)

		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/gold_add())

/datum/material/metal/silver
	mat_id = "silver"
	name = "silver"
	desc = "A slightly valuable and conductive metal."
	color = "#C1D1D2"

	New()
		..()
		value = 250

		setProperty("density", 36)
		setProperty("hard", 18)
		setProperty("reflective", 54)
		setProperty("electrical", 54)

/datum/material/metal/electrum
	mat_id = "electrum"
	name = "electrum"
	desc = "Highly conductive alloy of gold and silver."
	color = "#44ACAC"

	New()
		..()
		setProperty("electrical", 81)
		setProperty("density", 36)
		setProperty("hard", 9)

/datum/material/metal/plasmasteel //This should have inverted plasmaglass stats
	mat_id = "plasmasteel"
	name = "plasma steel"
	desc = "A plasmastone/steel alloy. Very dense but quite soft."
	color = "#937d99"
	alpha = 255

	New()
		..()
		setProperty("density", 63)
		setProperty("hard", 27)

/datum/material/metal/iridiumalloy
	mat_id = "iridiumalloy"
	name = "iridium alloy"
	canMix = 0 //Can not be easily modified.
	desc = "Some sort of advanced iridium alloy."
	color = "#756596"

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("density", 72)
		setProperty("hard", 72)
		setProperty("chemical", 81)

/datum/material/metal/soulsteel
	mat_id = "soulsteel"
	name = "soulsteel"
	desc = "A metal imbued with souls. Creepy."
	color = "#73DFF0"

	New()
		..()
		material_flags|= MATERIAL_ENERGY
		setProperty("density", 36)
		setProperty("hard", 18)
		addTrigger(TRIGGERS_ON_ENTERED, new /datum/materialProc/soulsteel_entered())

//Ceramics
//This includes rocks, crystals, glass, and generally most things defined by being hard, inflexible, and not very conductive
ABSTRACT_TYPE(/datum/material/ceramic)
/datum/material/ceramic
	color = "#ACACAC"

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 18)
		setProperty("electrical", 36)
		setProperty("thermal", 36)

/datum/material/ceramic/rock
	mat_id = "rock"
	name = "rock"
	desc = "Near useless asteroid rock with some traces of random metals."
	color = "#ACACAC"
	texture = "rock"

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 18)
		setProperty("electrical", 36)
		setProperty("thermal", 36)

/datum/material/ceramic/glass
	mat_id = "glass"
	name = "glass"
	desc = "Terrestrial glass. Inferior to Molitz."
	color = "#A3DCFF"
	alpha = 180

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 27)

/datum/material/ceramic/slag
	mat_id = "slag"
	name = "slag"
	desc = "A by-product left over after material has been processed."
	color = "#26170F"

	New()
		..()
		value = 10

		setProperty("density", 18)
		setProperty("hard", 18)
		setProperty("electrical", 18)

/datum/material/ceramic/spacelag
	mat_id = "spacelag"
	name = "spacelag"
	desc = "*BUFFERING*"
	color = "#3F3A38"

	New()
		..()
		setProperty("density", 72)
		setProperty("hard", 9)
		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/spacelag_add())

/datum/material/ceramic/plasmastone
	mat_id = "plasmastone"
	name = "plasmastone"
	desc = "Plasma in its solid state."
	color = "#A114FF"

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 9)
		setProperty("hard", 18)
		setProperty("electrical", 45)
		setProperty("radioactive", 18)
		setProperty("thermal", 36)

/datum/material/ceramic/plasmaglass
	mat_id = "plasmaglass"
	name = "plasma glass"
	desc = "Crystallized plasma that has been rendered inert. Very hard and prone to making extremely sharp edges."
	color = "#A114FF"
	alpha = 180

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 63)
		setProperty("electrical", 36)
		setProperty("thermal", 36)

/datum/material/ceramic/lapis
	mat_id = "lapislazuli"
	name = "lapis lazuli"
	color = "#1719BD"
	value = 500
	alpha = 220

	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 45)

/datum/material/ceramic/ice
	mat_id = "ice"
	name = "ice"
	desc = "The frozen state of water."
	color = "#E8F2FF"
	alpha = 100

	edible_exact = 1
	edible = 1

	New()
		..()
		setProperty("electrical", 18)
		setProperty("density", 9)
		setProperty("hard", 18)
		addTrigger(TRIGGERS_ON_LIFE, new /datum/materialProc/ice_life())
		addTrigger(TRIGGERS_ON_ATTACK, new /datum/materialProc/slippery_attack())
		addTrigger(TRIGGERS_ON_ENTERED, new /datum/materialProc/slippery_entered())

//Crystals as a whole are a subtype of ceramics because we have a lot of them and they have some unique properties
ABSTRACT_TYPE(/datum/material/ceramic/crystal)
/datum/material/ceramic/crystal
	color = "#A3DCFF"

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 18)
		setProperty("electrical", 36)
		setProperty("thermal", 36)

/datum/material/ceramic/crystal/molitz
	mat_id = "molitz"
	name = "molitz"
	desc = "Molitz is a common crystalline substance."
	color = "#FFFFFF"
	alpha = 180

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 36)

/datum/material/ceramic/crystal/molitz/beta
	mat_id = "molitz_b"
	name = "molitz β"
	color = "#ff2288"
	desc = "A rare form of Molitz. When heated under special conditions it produces a powerful plasma fire catalyst."

/datum/material/ceramic/crystal/claretine
	mat_id = "claretine"
	name = "claretine"
	desc = "Claretine is a highly conductive salt."
	color = "#C2280A"

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 9)
		setProperty("electrical", 72)

/datum/material/ceramic/crystal/erebite
	mat_id = "erebite"
	name = "erebite"
	desc = "Erebite is an extremely volatile high-energy mineral."
	color = "#FF3700"

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 63)
		setProperty("hard", 27)
		setProperty("electrical", 54)
		setProperty("radioactive", 72)

		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/erebite_flash())
		addTrigger(TRIGGERS_ON_TEMP, new /datum/materialProc/erebite_temp())
		addTrigger(TRIGGERS_ON_EXPLOSION, new /datum/materialProc/erebite_exp())
		addTrigger(TRIGGERS_ON_ATTACK, new /datum/materialProc/generic_explode_attack(33))
		addTrigger(TRIGGERS_ON_ATTACKED, new /datum/materialProc/generic_explode_attack(33))
		addTrigger(TRIGGERS_ON_HIT, new /datum/materialProc/generic_explode_attack(33))

/datum/material/ceramic/crystal/uqill
	mat_id = "uqill"
	name = "uqill"
	desc = "Uqill is a rare and very dense stone."
	color = "#0F0A08"
	alpha = 255

	New()
		..()
		setProperty("density", 72)
		setProperty("hard", 36)
		setProperty("chemical", 81)

/datum/material/ceramic/crystal/uqill/transparent
	mat_id = "uqillglass"
	name = "transparent uqill"
	desc = "Uqill-derived material developed for usage as transparent armor."
	color = "#615757"
	alpha = 180

/datum/material/ceramic/crystal/gnesis
	mat_id = "gnesis"
	name = "gnesis"
	desc = "A rare complex crystalline matrix with a lazily shifting internal structure. Not to be confused with gneiss, a metamorphic rock."
	color = "#1bdebd"
	texture = "flock"
	texture_blend = BLEND_OVERLAY

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 45)
		setProperty("electrical", 63)

/datum/material/ceramic/crystal/gnesis/transparent
	mat_id = "gnesisglass"
	name = "translucent gnesis"
	desc = "A rare complex crystalline matrix with a lazily shifting internal structure. The layers are arranged to let light through."
	color = "#ffffff"
	alpha = 180

/datum/material/ceramic/crystal/telecrystal
	mat_id = "telecrystal"
	name = "telecrystal"
	desc = "Telecrystal is a gemstone with space-warping properties."
	color = "#4C14F5"
	alpha = 100

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 9)
		setProperty("hard", 18)
		setProperty("reflective", 72)
		addTrigger(TRIGGERS_ON_LIFE, new /datum/materialProc/telecrystal_life())
		addTrigger(TRIGGERS_ON_ENTERED, new /datum/materialProc/telecrystal_entered())
		addTrigger(TRIGGERS_ON_ATTACK, new /datum/materialProc/telecrystal_onattack())

/datum/material/ceramic/crystal/miracle
	mat_id = "miracle"
	name = "miraclium"
	desc = "Miraclium is a bizarre substance that can have a wide variety of effects."
	color = "#FFFFFF"

	New()
		..()
		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/miracle_add())
		alpha = rand(20, 255)
		setProperty("density", rand(9, 72))
		setProperty("hard", rand(9, 72))
		setProperty("reflective", rand(9, 81))
		setProperty("chemical", rand(9, 72))
		addTrigger(TRIGGERS_ON_TEMP, new /datum/materialProc/temp_miraclium())

/datum/material/ceramic/crystal/starstone
	mat_id = "starstone"
	name = "starstone"
	desc = "An extremely rare jewel."
	color = "#B5E0FF"
	alpha = 80
	value = 1000

	New()
		..()
		setProperty("reflective", 81)
		setProperty("density", 81)
		setProperty("hard", 81)
		setProperty("electrical", 9)
		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/gold_add())

/datum/material/ceramic/crystal/diamond
	mat_id = "diamond"
	name = "diamond"
	color = "#FFFFFF"
	value = 700
	alpha = 220

	New()
		..()
		setProperty("density", 54)
		setProperty("hard", 63)

/datum/material/ceramic/crystal/topaz
	mat_id = "topaz"
	name = "topaz"
	color = "#EBB028"
	value = 700
	alpha = 220

	New()
		..()
		setProperty("density", 54)
		setProperty("hard", 63)

/datum/material/ceramic/crystal/garnet
	mat_id = "garnet"
	name = "garnet"
	color = "#DB8412"
	value = 500
	alpha = 220

	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 45)

/datum/material/ceramic/crystal/peridot
	mat_id = "peridot"
	name = "peridot"
	color = "#9CC748"
	value = 500
	alpha = 220

	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 45)

/datum/material/ceramic/crystal/malachite
	mat_id = "malachite"
	name = "malachite"
	color = "#1DF091"
	value = 500
	alpha = 220

	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 45)

/datum/material/ceramic/crystal/alexandrite
	mat_id = "alexandrite"
	name = "alexandrite"
	color = "#EB2FA9"
	value = 500
	alpha = 220

	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 45)

/datum/material/ceramic/crystal/jade
	mat_id = "jade"
	name = "jade"
	color = "#3C8F4D"
	value = 200
	alpha = 220

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 36)

/datum/material/ceramic/crystal/iolite
	mat_id = "iolite"
	name = "iolite"
	color = "#D5A8FF"
	value = 200
	alpha = 220

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 36)

//aluminum oxide crystals most well-known in sapphire or ruby form
ABSTRACT_TYPE(/datum/material/ceramic/crystal/corundum)
/datum/material/ceramic/crystal/corundum

	New()
		..()
		setProperty("density", 54)
		setProperty("hard", 63)

/datum/material/ceramic/crystal/corundum/ruby
	mat_id = "ruby"
	name = "ruby"
	color = "#D00000"
	value = 700
	alpha = 220

/datum/material/ceramic/crystal/corundum/sapphire
	mat_id = "sapphire"
	name = "sapphire"
	color = "#2789F2"
	value = 700
	alpha = 220

//beryllium-aluminum-sillicate crystals most well known as emeralds or aquamarines
ABSTRACT_TYPE(/datum/material/ceramic/crystal/beryl)
/datum/material/ceramic/crystal/corundum

	New()
		..()
		setProperty("density", 54)
		setProperty("hard", 63)

/datum/material/ceramic/crystal/beryl/emerald
	mat_id = "emerald"
	name = "emerald"
	color = "#3AB818"
	value = 700
	alpha = 220

/datum/material/ceramic/crystal/beryl/aquamarine
	mat_id = "aquamarine"
	name = "aquamarine"
	color = "#68F7D8"
	value = 200
	alpha = 220

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 36)

//silicon-dioxide crystals most well known as various forms of quartz
ABSTRACT_TYPE(/datum/material/ceramic/crystal/quartz)
/datum/material/ceramic/crystal/quartz
	mat_id = "quartz"
	name = "quartz"
	desc = "Quartz is somewhat valuable but not particularly useful."
	color = "#BBBBBB"

	New()
		..()
		setProperty("density", 54)
		setProperty("hard", 63)

/datum/material/ceramic/crystal/quartz/amethyst
	mat_id = "amethyst"
	name = "amethyst"
	color = "#BD0FDB"
	value = 700
	alpha = 220

/datum/material/ceramic/crystal/quartz/jasper
	mat_id = "jasper"
	name = "jasper"
	color = "#FF7A21"
	value = 500
	alpha = 220

	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 45)

/datum/material/ceramic/crystal/quartz/citrine
	mat_id = "citrine"
	name = "citrine"
	color = "#F5F11B"
	value = 200
	alpha = 220

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 36)

/datum/material/ceramic/crystal/quartz/rose
	mat_id = "rosequartz"
	name = "rose quartz"
	color = "#FFC9E8"
	value = 200
	alpha = 220

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 36)

/datum/material/ceramic/crystal/quartz/quartz/onyx
	mat_id = "onyx"
	name = "onyx"
	color = "#000000"
	value = 200
	alpha = 220

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 36)

//Things like flesh, viscerite, and blob.
ABSTRACT_TYPE(/datum/material/blobby)
/datum/material/organic
	color = "#555555"

	New()
		..()
		setProperty("electrical", 36)

//Wood and wood-like materials like bamboo
ABSTRACT_TYPE(/datum/material/woody)
/datum/material/woody
	color = "#331f16"

	New()
		..()
		setProperty("density", 45)
		setProperty("hard", 27)

//Dirt and dirt-like materials like sand and clay
ABSTRACT_TYPE(/datum/material/dirty)
/datum/material/dirty

//Fabric materials such as wool and cotton
ABSTRACT_TYPE(/datum/material/textile)
/datum/material/textile

	New()
		. = ..()
		setProperty("electrical", 36)
		setProperty("hard", 9)
		setProperty("density", 9)

//Animal skins and similar materials
ABSTRACT_TYPE(/datum/material/leathery)
/datum/material/leather
	color = "#8A3B11"

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 9)
		setProperty("thermal", 27)
		setProperty("electrical", 27)

//Rubber and rubber-like materials
ABSTRACT_TYPE(/datum/material/rubbery)
/datum/material/rubbery
	New()
		. = ..()
		setProperty("electrical", 27)

//Anomolous things that can't be traditionally classified
ABSTRACT_TYPE(/datum/material/degenerate)
/datum/material/degenerate

/datum/material/degenerate/neutronium
	mat_id = "neutronium"
	name = "neutronium"
	desc = "Neutrons condensed into a solid form."
	color = "#043e9b"
	alpha = 255

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 81)
		setProperty("hard", 27)
		setProperty("electrical", 63)
		setProperty("n_radioactive", 72)

/datum/material/degenerate/negativematter
	mat_id = "negativematter"
	name = "negative matter"
	desc = "It seems to repel matter."
	color = list(-1, 0, 0, 0, -1, 0, 0, 0, -1, 1, 1, 1)

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/negative_add())

ABSTRACT_TYPE(/datum/material/organic)
/datum/material/organic
	color = "#555555"
	alpha 				   = 255

	New()
		. = ..()
		material_flags |= MATERIAL_ORGANIC
		setProperty("flammable", 27)
		setProperty("electrical", 36)

/datum/material/organic/blob
	mat_id = "blob"
	name = "blob"
	desc = "The material of the feared giant space amoeba."
	color = "#44cc44"
	alpha = 180
	texture = "bubbles"
	texture_blend = BLEND_ADD

	edible_exact = 0.6 //Just barely edible
	edible = 1

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL | MATERIAL_CLOTH
		setProperty("chemical", 27)
		setProperty("density", 45)
		setProperty("hard", 9)
		setProperty("flammable", 45)
		addTrigger(TRIGGERS_ON_EAT, new /datum/materialProc/oneat_blob())



/datum/material/organic/flesh
	mat_id = "flesh"
	name = "flesh"
	desc = "Meat from a carbon-based lifeform."
	color = "#574846"

	edible_exact = 0.6 //Just barely edible.
	edible = 1

	New()
		..()
		material_flags |= MATERIAL_CLOTH
		setProperty("density", 27)
		setProperty("hard", 9)
		//addTrigger(TRIGGERS_ON_EAT, new /datum/materialProc/oneat_flesh())


	butt
		color = "#ebbd97"
		mat_id = "butt"
		name = "butt"
		texture = "buttgrey"
		texture_blend = BLEND_OVERLAY
		desc = "...it's butt flesh. Why is this here. Why do you somehow know it's butt flesh. Fuck."

		New()
			..()
			addTrigger(TRIGGERS_ON_PICKUP, new /datum/materialProc/onpickup_butt)
			addTrigger(TRIGGERS_ON_HIT, new /datum/materialProc/onpickup_butt)

	greymatter
		mat_id = "greymatter"
		name = "grey matter"
		desc = "It makes your brain think good."
		color = "#b99696"

/datum/material/organic/char
	mat_id = "char"
	name = "char"
	desc = "Char is a fossil energy source similar to coal."
	color = "#555555"

	New()
		..()
		setProperty("flammable", 45)
		setProperty("hard", 27)
		setProperty("density", 18)


/datum/material/organic/koshmarite
	mat_id = "koshmarite"
	name = "koshmarite"
	desc = "An unusual dense pulsating stone. You feel uneasy just looking at it."
	color = "#600066"

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("hard", 27)
		setProperty("reflective", 54)
		setProperty("n_radioactive", 9)
		setProperty("density", 45)


/datum/material/organic/viscerite
	mat_id = "viscerite"
	name = "viscerite"
	desc = "A disgusting flesh-like material. Ugh. What the hell is this?"
	color = "#D04FFF"

	edible_exact = 0.6 //Just barely edible.
	edible = 1

	New()
		..()
		material_flags |= MATERIAL_CLOTH
		setProperty("density", 36)
		setProperty("hard", 9)
		setProperty("chemical", 54)
		setProperty("flammable", 18)
		addTrigger(TRIGGERS_ON_EAT, new /datum/materialProc/oneat_viscerite())

/datum/material/organic/tensed_viscerite
	mat_id = "tensed_viscerite"
	name = "tensed viscerite"
	desc = "Fleshy mass drawn out under tension. It's translucent and thready."
	color = "#dd81ff"
	alpha = 180

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 27)
		setProperty("chemical", 72)
		setProperty("flammable", 18)

/datum/material/organic/bone
	mat_id = "bone"
	name = "bone"
	desc = "Bone is pretty spooky stuff."
	color = "#DDDDDD"

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 45)
		setProperty("flammable", 18)


/datum/material/organic/wood
	mat_id = "wood"
	name = "wood"
	desc = "Wood from some sort of tree."
	color = "#331f16"
	texture_blend = BLEND_ADD

	New()
		..()
		material_flags |= MATERIAL_WOOD
		setProperty("density", 45)
		setProperty("hard", 27)
		setProperty("flammable", 36)


/datum/material/organic/bamboo
	mat_id = "bamboo"
	name = "bamboo"
	desc = "Bamboo is a giant woody grass."
	color = "#544c24"
	texture_blend = BLEND_ADD

	New()
		..()
		material_flags |= MATERIAL_WOOD
		setProperty("density", 36)
		setProperty("flammable", 36)


/datum/material/organic/cardboard
	mat_id = "cardboard"
	name = "cardboard"
	desc = "Perfect for making boxes."
	color = "#d3b173"

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 9)
		setProperty("flammable", 36)
		addTrigger(TRIGGERS_ON_BLOBHIT, new /datum/materialProc/cardboard_blob_hit())
		addTrigger(TRIGGERS_ON_HIT, new /datum/materialProc/cardboard_on_hit())


/datum/material/organic/chitin
	mat_id = "chitin"
	name = "chitin"
	desc = "Chitin is an organic material found in the exoskeletons of insects."
	color = "#118800"

	New()
		..()
		material_flags |= MATERIAL_METAL
		setProperty("density", 18)
		setProperty("hard", 54)


/datum/material/organic/beeswax
	mat_id = "beeswax"
	name = "beeswax"
	desc = "An organic material consisting of pollen and space-bee secretions.  Mind your own."
	color = "#C8BB62"

	New()
		..()
		setProperty("density", 9)
		setProperty("hard", 18)
		setProperty("flammable", 36)


/datum/material/organic/honey
	mat_id = "honey"
	name = "refined honey" //Look calling both the globs and the material just "honey" isn't helping people's confusion wrt making clone pods
	desc = ""
	color = "#f1da10"
	edible_exact = TRUE
	edible = TRUE

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 9)
		setProperty("flammable", 36)
		// addTrigger(TRIGGERS_ON_EAT, new /datum/materialProc/oneat_honey())
		// maybe make it sticky somehow?


/datum/material/organic/frozenfart
	mat_id = "frozenfart"
	name = "frozen fart"
	desc = "A semi-solid state of farts originally proposed to exist by Dr. Prof. Wonk in 2016."
	color = "#003300"

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 18)
		setProperty("thermal", 9)
		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/ffart_add())
		addTrigger(TRIGGERS_ON_PICKUP, new /datum/materialProc/ffart_pickup())


/datum/material/organic/hamburgris
	mat_id = "hamburgris"
	name = "hamburgris"
	desc = "Ancient medium ground chuck, petrified by the ages into a sturdy composite. Or worse."
	color = "#816962"

	New()
		..()
		setProperty("density", 45)
		setProperty("chemical", 63)
		setProperty("thermal", 18)
		setProperty("flammable", 9)
		addTrigger(TRIGGERS_ON_LIFE, new /datum/materialProc/generic_reagent_onlife("cholesterol", 1))



/datum/material/organic/pizza
	mat_id = "pizza"
	name = "pizza"
	desc = "It's pepperoni pizza. Some would say the best kind of pizza"
	color = "#FFFFFF"
	texture = "pizza2"
	texture_blend = BLEND_SUBTRACT
	edible_exact = 1
	edible = 1

	New()
		..()
		setProperty("hard", 9)


/datum/material/organic/coral
	mat_id = "coral"
	name = "coral"
	desc = "Coral harvested from the sea floor."
	color = "#990099"
	texture = "coral"
	texture_blend = BLEND_SUBTRACT

	New()
		..()
		material_flags |= MATERIAL_METAL | MATERIAL_CRYSTAL
		setProperty("density", 18)
		setProperty("hard", 45)


/datum/material/organic/ectoplasm
	mat_id = "ectoplasm"
	name = "ectoplasm"
	desc = "Ghostly residue. Not terribly useful on it's own."
	color = "#ccffcc"

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 9)
		setProperty("hard", 9)
		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/ethereal_add())
// Fabrics

ABSTRACT_TYPE(/datum/material/fabric)
/datum/material/fabric

	New()
		. = ..()
		material_flags |= MATERIAL_CLOTH
		setProperty("flammable", 18)
		setProperty("electrical", 36)
		setProperty("hard", 9)
		setProperty("density", 9)

/datum/material/fabric/leather
	mat_id = "leather"
	name = "leather"
	desc = "Leather is a flexible material derived from processed animal skins."
	color = "#8A3B11"

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 9)
		setProperty("thermal", 27)
		setProperty("electrical", 27)


/datum/material/fabric/synthleather
	mat_id = "synthleather"
	name = "synthleather"
	desc = "Synthleather is an artificial leather."
	color = "#BB3B11"

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 9)
		setProperty("thermal", 36)
		setProperty("electrical", 36)


/datum/material/fabric/brullbarhide
	mat_id = "brullbarhide"
	name = "brullbar hide"
	desc = "The hide of a fearsome brullbar!"
	color = "#CCCCCC"

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 18)
		setProperty("thermal", 18)
		setProperty("electrical", 36)


/datum/material/fabric/brullbarhide/king
	mat_id = "kingbrullbarhide"
	name = "king brullbar hide"
	desc = "The hide of a terrifying brullbar king!!!"
	color = "#EFEEEE"

	New()
		..()
		setProperty("density", 63)
		setProperty("hard", 27)
		setProperty("thermal", 9)
		setProperty("electrical", 36)
		setProperty("flammable", 9)


/datum/material/fabric/cotton
	mat_id = "cotton"
	name = "cotton"
	desc = "Cotton is a soft and fluffy material obtained from certain plants."
	color = "#FFFFFF"

	New()
		..()
		setProperty("density", 9)
		setProperty("hard", 9)
		setProperty("thermal", 36)
		setProperty("flammable", 36)

/datum/material/fabric/jean
	mat_id = "jean"
	name = "jean"
	desc = "The jean jaterial (used to be known as denim in the early 21st century) is a sturdy jotton jarp-faced jextile in which the jeft passes under two or more jarp threads."
	color = "#88c2ff"
	special_naming = TRUE
	texture = "jean"
	texture_blend = BLEND_MULTIPLY

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 9)
		setProperty("thermal", 18)
		setProperty("flammable", 18)

	proc/jeplacement(text)
		var/first_letter = copytext(text, 1, 2)
		if(first_letter == uppertext(first_letter))
			. = "J"
		else
			. = "j"

	proc/replace_first_consonant_cluster(text, replacement)
		var/original_text = text
		var/static/regex/regex = regex(@"\b(?:[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ][bcdfghjklmnpqrstvwxyz]?)", "g")
		. = regex.Replace(text, /datum/material/fabric/jean/proc/jeplacement)
		. = replacetext(., "'j ", "'s ") // fix Jaff assistant'j jumpsuit
		if(. == original_text)
			. = "jean [.]"

	interpolateName(datum/material/other, t)
		. = replace_first_consonant_cluster(other.name, copytext(src.name , 1, 2))

	specialNaming(atom/target)
		. = replace_first_consonant_cluster(target.name, copytext(src.name , 1, 2))

/datum/material/fabric/carpet
	mat_id = "carpet"
	name = "carpet"
	desc = "Disgusting grimy carpet which hasn't been cleaned in 40 years. Probably the kind of carpet that is host to all kind of gross bugs"
	color = "#fcfff2"
	texture = "carpet"
	texture_blend = BLEND_MULTIPLY

	New()
		..()
		setProperty("density", 9)
		setProperty("hard", 9)
		setProperty("thermal", 36)
		setProperty("flammable", 36)

/datum/material/organic/pickle
	mat_id = "pickle"
	name = "pickle"
	desc = "Pure pickle, presumably pickled previously."
	color = "#b8db56"
	texture = "pickle"
	texture_blend = BLEND_MULTIPLY
	edible_exact = 1
	edible = 1

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 9)
		setProperty("thermal", 18)
		setProperty("flammable", 18)

/datum/material/fabric/fibrilith
	mat_id = "fibrilith"
	name = "fibrilith"
	desc = "Fibrilith is an odd fibrous crystal known for its high tensile strength. Seems a bit similar to asbestos."
	color = "#E0FFF6"

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("density", 27)
		setProperty("hard", 18)
		setProperty("thermal", 9)
		setProperty("flammable", 9)


	New()
		..()
		addTrigger(TRIGGERS_ON_LIFE, new /datum/materialProc/generic_itchy_onlife())


/datum/material/fabric/spidersilk
	mat_id = "spidersilk"
	name = "spider silk"
	desc = "Spider silk is a protein fiber spun by space spiders."
	color = "#CCCCCC"

	New()
		..()
		setProperty("density", 54)
		setProperty("hard", 9)
		setProperty("thermal", 36)
		setProperty("flammable", 45)


/datum/material/fabric/carbonfibre
	mat_id = "carbonfibre"
	name = "carbon nanofiber"
	desc = "Carbon Nanofibers are highly graphitic carbon nanomaterials with excellent mechanical properties, electrical conductivity and thermal conductivity."
	color = "#333333"

	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 36)
		setProperty("thermal", 81)
		setProperty("electrical", 63)

/datum/material/metal/censorium
	mat_id = "censorium"
	name = "censorium"
	desc = "A charred rock. Doesn't do much."
	color = "#948686"

	New()
		..()
		setProperty("flammable", 18)
		setProperty("density", 18)
		setProperty("hard", 18)
		setProperty("thermal", 9)

/datum/material/fabric/hauntium
	mat_id = "hauntium"
	name = "hauntium"
	desc = "A silky smooth fabric that almost seems alive."
	color = "#8c87b2"


	New()
		..()
		material_flags |= MATERIAL_METAL | MATERIAL_ENERGY
		setProperty("density", 9)
		setProperty("hard", 9)
		setProperty("electrical", 9)
		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/ethereal_add())
		addTrigger(TRIGGERS_ON_ENTERED, new /datum/materialProc/soulsteel_entered())


/datum/material/fabric/ectofibre
	mat_id = "ectofibre"
	name = "ectofibre"
	desc = "Ectoplasmic fibres. Sort of transparent. Seems to be rather strong yet flexible."
	color = "#ffffff"
	alpha = 128

	New()
		..()
		material_flags |= MATERIAL_ENERGY | MATERIAL_CRYSTAL
		setProperty("density", 54)
		setProperty("hard", 9)
		setProperty("thermal", 81)
		setProperty("radioactive", 27)
		setProperty("electrical", 63)
		addTrigger(TRIGGERS_ON_LIFE, new /datum/materialProc/generic_itchy_onlife())


/datum/material/fabric/dyneema
	mat_id = "dyneema"
	name = "dyneema"
	desc = "A blend of carbon nanofibres and space spider silk. Highly versatile."
	color = "#333333"

	New()
		..()
		setProperty("density", 72)
		setProperty("hard", 36)
		setProperty("chemical", 81)
		setProperty("electrical", 63)
		setProperty("flammable", 9)


/datum/material/fabric/exoweave
	mat_id = "exoweave"
	name = "ExoWeave"
	desc = "A prototype composite fabric designed for EVA activity, comprised primarily of carbon fibers treated with a silica-based solution."
	color = "#3d666b"

	New()
		..()
		setProperty("density", 45)
		setProperty("hard", 36)
		setProperty("chemical", 63)
		setProperty("thermal", 81)
		setProperty("electrical", 72)


/datum/material/fabric/beewool
	mat_id = "beewool"
	name = "bee wool"
	desc = "Wool of adorable furry space bees."
	color = "#ffcc00"
	texture = "bee"
	texture_blend = BLEND_SUBTRACT

	New()
		..()
		setProperty("hard", 18)
		setProperty("density", 18)
		setProperty("flammable", 54)
		setProperty("electrical", 27)
		setProperty("thermal", 63)

ABSTRACT_TYPE(/datum/material/rubber)
/datum/material/rubber
	New()
		. = ..()
		material_flags |= MATERIAL_RUBBER
		setProperty("electrical", 27)

/datum/material/rubber/latex
	mat_id = "latex"
	name = "latex"
	desc = "A type of synthetic rubber. Conducts electricity poorly."
	color = "#DDDDDD" //"#FF0000" idgaf ok I want red cables back. no haine, this stuff isnt red.

	New()
		..()
		setProperty("density", 18)
		setProperty("hard", 9)
		setProperty("electrical", 27)
		setProperty("thermal", 36)

/datum/material/rubber/synthrubber
	mat_id = "synthrubber"
	name = "synthrubber"
	desc = "A type of synthetic rubber. Quite garish, really."
	color = "#FF0000" //But this is red okay.

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 9)
		setProperty("electrical", 18)
		setProperty("thermal", 36)


/datum/material/rubber/synthblubber //it had to be done
	mat_id = "synthblubber"
	name = "synthblubber"
	desc = "A type of synthetic blubber. Hold on. Blubber?!"
	color = "#1EA082"

	New()
		..()
		setProperty("density", 36)
		setProperty("hard", 9)
		setProperty("electrical", 9)
		setProperty("thermal", 27)
		setProperty("flammable", 27)

/datum/material/rubber/plastic
	mat_id = "plastic"
	name = "plastic"
	desc = "A synthetic material made of polymers. Great for polluting oceans."
	color = "#baccd3"

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 9)
		setProperty("electrical", 18)
		setProperty("thermal", 27)
		setProperty("chemical", 45)

/datum/material/metal/plutonium
	mat_id = "plutonium"
	name = "plutonium 239"
	canMix = 0 //Can not be easily modified.
	desc = "Weapons grade refined plutonium."
	color = "#230e4d"

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("density", 72)
		setProperty("hard", 63)
		setProperty("n_radioactive", 45)
		setProperty("radioactive", 27)
		setProperty("electrical", 63)

/// Material for bundles of glowsticks as fuel rods
/datum/material/metal/glowstick
	mat_id = "glowstick"
	name = "glowsticks" //"it is made of glowsticks"
	canMix = 0 //don't make alloys of this
	desc = "It's just a bunch of glowsticks stuck together. How is this an ingot?"
	color = "#00e618"
	alpha = 200

	New()
		..()
		setProperty("density", 27)
		setProperty("hard", 27)
		setProperty("radioactive", 9)
		setProperty("electrical", 18)
		setProperty("thermal", 27)
		addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/glowstick_add())
