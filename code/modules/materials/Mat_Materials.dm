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
	/// The atom that this material is applied to
	var/atom/owner = null
	/// used to retrieve instances of these base materials from the cache.
	var/mat_id = "ohshitium"
	/// Name of the material, used for combination and scanning
	var/name = "Youshouldneverseemeium"
	/// Description of the material, used for scanning
	var/desc = "This is a custom material."

	/// Holds the parent materials.
	var/list/parent_materials = list()
	/// List of all the various [/datum/material_property] that apply.
	var/list/properties = list()

	/// Compound generation
	var/generation = 0

	/// Can this be mixed with other materials?
	var/canMix = 1
	/// Can this only be used after being combined with another material?
	var/mixOnly = 0

	/// Various flags. See [material_properties.dm]
	var/material_flags = 0
	/// In percent of a base value. How much this sells for.
	var/value = 100

	/// words that go before the name, used in combination
	var/list/prefixes = list()
	/// words that go after the name, used in combination
	var/list/suffixes = list()

	/// if not null, texture will be set when mat is applied.
	var/texture = ""
	/// How to blend the [/datum/material/var/texture].
	var/texture_blend = BLEND_ADD

	/// Should this even color the objects made from it? Mostly used for base station materials like steel
	var/applyColor = 1
	/// The color of the material
	var/color = "#FFFFFF"
	/// The "transparency" of the material. Kept as alpha for logical reasons. Displayed as percentage ingame.
	var/alpha = 255
	/// The 'quality' of the material
	var/quality = 0

	/// The actual value of edibility. Changes internally and sets [/datum/material/var/edible].
	var/edible_exact = 0
	/// The functional value of edibility. Edible or not? This is what you check from the outside to see if material is edible. See [/datum/material/var/edible_exact].
	var/edible = 0

	var/owner_hasentered_added = FALSE

	New()
		. = ..()
		for(var/datum/material_property/propPath as anything in concrete_typesof(/datum/material_property))
			if(initial(propPath.default_value) > 0)
				src.setProperty(initial(propPath.id), initial(propPath.default_value))

	proc/getProperty(var/property, var/type = VALUE_CURRENT)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				switch(type)
					if(VALUE_CURRENT)
						return properties[P]
					if(VALUE_MIN)
						return P.min_value
					if(VALUE_MAX)
						return P.max_value
		return 0

	proc/removeProperty(var/property)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				P.onRemoved(src)
				properties.Remove(P)
				return
		return

	proc/adjustProperty(var/property, var/value)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				P.changeValue(src, properties[P] + value)
				return
		//setProperty(property, value)
		return

	proc/setProperty(var/property, var/value)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				P.changeValue(src, value)
				return

		if(!materialProps.len) //Required so that compile time object materials can have properties.
			buildMaterialPropertyCache()

		for(var/datum/material_property/X in materialProps)
			if(X.id == property)
				properties.Add(X)
				X.onAdded(src, value)
				X.changeValue(src, value)

		return

	proc/hasProperty(var/property)
		for(var/datum/material_property/P in properties)
			if(P.id == property)
				return 1
		return 0

	proc/addTrigger(var/list/L, var/datum/materialProc/D)
		for(var/datum/materialProc/P in L)
			if(P.type == D.type) return 0
		L.Add(D)
		L[D] = 0
		return

	proc/removeTrigger(var/list/L, var/inType)
		for(var/datum/materialProc/P in L)
			if(P.type == inType)
				L.Remove(P)
		return

	proc/fail()
		del(owner)
		return

	/// Called when exposed to temperatures.
	var/list/triggersTemp = list()
	/// Called when exposed to chemicals.
	var/list/triggersChem = list()
	/// Called when owning object is picked up.
	var/list/triggersPickup = list()
	/// Called when owning object is dropped.
	var/list/triggersDrop = list()
	/// Called when exposed to explosions.
	var/list/triggersExp = list()
	/// Called when the material is added to an object
	var/list/triggersOnAdd = list()
	/// Called when the material is removed from an object
	var/list/triggersOnRemove = list()
	/// Called when the life proc of a mob that has the owning item equipped runs.
	var/list/triggersOnLife = list()
	/// Called when the owning object is used to attack something or someone.
	var/list/triggersOnAttack = list()
	/// Called when a mob wearing the owning object is attacked.
	var/list/triggersOnAttacked = list()
	/// Called when a mob wearing the owning object is shot.
	var/list/triggersOnBullet = list()
	/// Called when *something* enters a turf with the material assigned. Also called on all objects on the turf with a material.
	var/list/triggersOnEntered = list()
	/// Called when someone eats a thing with this material assigned.
	var/list/triggersOnEat = list()
	/// Called when blob hits something with this material assigned.
	var/list/triggersOnBlobHit = list()
	/// Called when an obj hits something with this material assigned.
	var/list/triggersOnHit = list()



	proc/triggerOnEntered(var/atom/owner, var/atom/entering)
		for(var/datum/materialProc/X in triggersOnEntered)
			call(X,  "execute")(owner, entering)
		return

	proc/triggerOnAttacked(var/obj/item/owner, var/mob/attacker, var/mob/attacked, var/atom/weapon)
		for(var/datum/materialProc/X in triggersOnAttacked)
			call(X,  "execute")(owner, attacker, attacked, weapon)
		return

	proc/triggerOnBullet(var/obj/item/owner, var/atom/attacked, var/obj/projectile/projectile)
		for(var/datum/materialProc/X in triggersOnBullet)
			call(X,  "execute")(owner, attacked, projectile)
		return

	proc/triggerOnAttack(var/obj/item/owner, var/mob/attacker, var/mob/attacked)
		for(var/datum/materialProc/X in triggersOnAttack)
			call(X,  "execute")(owner, attacker, attacked)
		return

	proc/triggerOnLife(var/mob/M, var/obj/item/I, mult)
		for(var/datum/materialProc/X in triggersOnLife)
			call(X,  "execute")(M, I, mult)
		return

	proc/triggerOnAdd(var/location)
		for(var/datum/materialProc/X in triggersOnAdd)
			call(X,  "execute")(location)
		return

	proc/triggerOnRemove(var/location)
		for(var/datum/materialProc/X in triggersOnRemove)
			call(X,  "execute")(location)
		return

	proc/triggerChem(var/location, var/chem, var/amount)
		for(var/datum/materialProc/X in triggersChem)
			call(X,  "execute")(location, chem, amount)
		return

	proc/triggerPickup(var/mob/M, var/obj/item/I)
		for(var/datum/materialProc/X in triggersPickup)
			call(X,  "execute")(M, I)
		return

	proc/triggerDrop(var/mob/M, var/obj/item/I)
		for(var/datum/materialProc/X in triggersDrop)
			call(X,  "execute")(M, I)
		return

	proc/triggerTemp(var/location, var/temp)
		for(var/datum/materialProc/X in triggersTemp)
			call(X,  "execute")(location, temp)
		return

	proc/triggerExp(var/location, var/sev)
		for(var/datum/materialProc/X in triggersExp)
			call(X,  "execute")(location, sev)
		return

	proc/triggerEat(var/mob/M, var/obj/item/I)
		for(var/datum/materialProc/X in triggersOnEat)
			call(X,  "execute")(M, I)
		return

	proc/triggerOnBlobHit(var/atom/owner, var/blobPower)
		for(var/datum/materialProc/X in triggersOnBlobHit)
			call(X,  "execute")(owner, blobPower)
		return

	proc/triggerOnHit(var/atom/owner, var/obj/attackobj, var/mob/attacker, var/meleeorthrow)
		for(var/datum/materialProc/X in triggersOnHit)
			call(X,  "execute")(owner, attackobj, attacker, meleeorthrow)
		return


/datum/material/interpolated
	mat_id = "imcoderium"
	name = "imcoderium"
	desc = "You should not be seeing this"
	color = "#6f00ff"

// Metals

/// Base metal material parent
ABSTRACT_TYPE(/datum/material/metal)
/datum/material/metal
	color = "#8C8C8C"

	New()
		. = ..()
		material_flags |= MATERIAL_METAL
		setProperty("electrical", 5)
		setProperty("thermal", 6)
		setProperty("density", 4)
		setProperty("chemical", 6)

/datum/material/metal/rock
	mat_id = "rock"
	name = "rock"
	desc = "Near useless asteroid rock with some traces of random metals."
	color = "#ACACAC"
	texture = "rock"

	New()
		..()
		setProperty("density", 2)
		setProperty("hard", 2)
		setProperty("electrical", 4)
		setProperty("thermal", 4)


/datum/material/metal/electrum
	mat_id = "electrum"
	name = "electrum"
	desc = "Highly conductive alloy of gold and silver."
	color = "#44ACAC"
	quality = 5

	New()
		..()
		setProperty("electrical", 9)
		setProperty("density", 4)
		setProperty("hard", 1)


/datum/material/metal/steel
	mat_id = "steel"
	name = "steel"
	desc = "Terrestrial steel from Earth."
	New()
		..()
		setProperty("density", 4)
		setProperty("hard", 3)

/datum/material/metal/copper
	mat_id = "copper"
	name = "copper"
	desc = "Copper is a terrestrial conductive metal from proto-Dan mines. It is inferior to pharosium."
	color = "#B87333" //the hex value known as copper in RGB colorspace
	New()
		..()
		setProperty("electrical", 6)
		setProperty("density", 2)
		setProperty("hard", 1)


/datum/material/metal/pharosium
	mat_id = "pharosium"
	name = "pharosium"
	desc = "Pharosium is a conductive metal."
	color = "#E39362"
	New()
		..()
		setProperty("electrical", 7)
		setProperty("density", 2)
		setProperty("hard", 2)


/datum/material/metal/cobryl
	mat_id = "cobryl"
	name = "cobryl"
	desc = "Cobryl is a somewhat valuable metal."
	color = "#84D5F0"
	New()
		..()
		value = 175
		setProperty("density", 4)
		setProperty("hard", 2)
		setProperty("chemical", 8)



/datum/material/metal/bohrum
	mat_id = "bohrum"
	name = "bohrum"
	desc = "Bohrum is a heavy and highly durable metal."
	color = "#3D692D"
	New()
		..()
		setProperty("density", 6)
		setProperty("hard", 5)
		setProperty("chemical", 7)


/datum/material/metal/mauxite
	mat_id = "mauxite"
	name = "mauxite"
	desc = "Mauxite is a sturdy common metal."
	color = "#574846"
	New()
		..()
		setProperty("density", 4)
		setProperty("hard", 3)


/datum/material/metal/cerenkite
	mat_id = "cerenkite"
	name = "cerenkite"
	desc = "Cerenkite is a highly radioactive metal."
	color = "#CDBDFF"

	New()
		..()
		value = 200

		material_flags |= MATERIAL_ENERGY
		setProperty("electrical", 6)
		setProperty("radioactive", 5)
		setProperty("hard", 2)


/datum/material/metal/syreline
	mat_id = "syreline"
	name = "syreline"
	desc = "Syreline is an extremely valuable and coveted metal."
	color = "#FAF5D4"
	quality = 30

	New()
		..()
		value = 400

		setProperty("density", 1)
		setProperty("hard", 2)
		setProperty("reflective", 8)

		addTrigger(triggersOnAdd, new /datum/materialProc/gold_add())


/datum/material/metal/gold
	mat_id = "gold"
	name = "gold"
	desc = "A somewhat valuable and conductive metal."
	color = "#F5BE18"
	quality = 30

	New()
		..()
		value = 300

		setProperty("density", 5)
		setProperty("hard", 2)
		setProperty("reflective", 6)
		setProperty("electrical", 7)
		setProperty("thermal", 7)

		addTrigger(triggersOnAdd, new /datum/materialProc/gold_add())


/datum/material/metal/silver
	mat_id = "silver"
	name = "silver"
	desc = "A slightly valuable and conductive metal."
	color = "#C1D1D2"
	quality = 5

	New()
		..()
		value = 250

		setProperty("density", 4)
		setProperty("hard", 2)
		setProperty("reflective", 6)
		setProperty("electrical", 6)


/datum/material/metal/plasmasteel //This should have inverted plasmaglass stats
	mat_id = "plasmasteel"
	name = "plasma steel"
	desc = "A plasmastone/steel alloy. Very dense but quite soft."
	color = "#937d99"
	alpha = 255

	New()
		..()
		setProperty("density", 7)
		setProperty("hard", 3)


/datum/material/metal/neutronium
	mat_id = "neutronium"
	name = "neutronium"
	desc = "Neutrons condensed into a solid form."
	color = "#043e9b"
	alpha = 255

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 9)
		setProperty("hard", 3)
		setProperty("electrical", 7)
		setProperty("n_radioactive", 8)



// Special Metals

/datum/material/metal/slag
	mat_id = "slag"
	name = "slag"
	desc = "A by-product left over after material has been processed."
	color = "#26170F"
	quality = -50

	New()
		..()
		value = 10

		setProperty("density", 2) //fucked up values for fucked up material but not silly putty
		setProperty("hard", 2)
		setProperty("electrical", 2)


/datum/material/metal/spacelag
	mat_id = "spacelag"
	name = "spacelag"
	desc = "*BUFFERING*"
	color = "#0F0A08"

	New()
		..()
		setProperty("density", 8)
		setProperty("hard", 1)


/datum/material/metal/iridiumalloy
	mat_id = "iridiumalloy"
	name = "iridium alloy"
	canMix = 0 //Can not be easily modified.
	desc = "Some sort of advanced iridium alloy."
	color = "#756596"
	quality = 60

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("density", 8)
		setProperty("hard", 8)
		setProperty("chemical", 9)


/datum/material/metal/negativematter
	mat_id = "negativematter"
	name = "negative matter"
	desc = "It seems to repel matter."
	color = list(-1, 0, 0, 0, -1, 0, 0, 0, -1, 1, 1, 1)

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		addTrigger(triggersOnAdd, new /datum/materialProc/negative_add())


//GIVE THIS STATS AND SPECIAL EFFECTS.
/datum/material/metal/soulsteel
	mat_id = "soulsteel"
	name = "soulsteel"
	desc = "A metal imbued with souls. Creepy."
	color = "#73DFF0"

	New()
		..()
		material_flags|= MATERIAL_ENERGY
		setProperty("density", 4)
		setProperty("hard", 2)
		addTrigger(triggersOnEntered, new /datum/materialProc/soulsteel_entered())


// Crystals
ABSTRACT_TYPE(/datum/material/crystal)
/datum/material/crystal
	color = "#A3DCFF"

	New()
		. = ..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("hard", 3)
		setProperty("electrical", 3)
		setProperty("thermal", 3)
		setProperty("chemical", 5)

/datum/material/crystal/glass
	mat_id = "glass"
	name = "glass"
	desc = "Terrestrial glass. Inferior to Molitz."
	color = "#A3DCFF"
	alpha = 180
	New()
		..()
		setProperty("density", 2)
		setProperty("hard", 3)


/datum/material/crystal/molitz
	mat_id = "molitz"
	name = "molitz"
	desc = "Molitz is a common crystalline substance."
	color = "#FFFFFF"
	alpha = 180
	var/unexploded = 1
	var/iterations = 4

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 4)
		addTrigger(triggersTemp, new /datum/materialProc/molitz_temp())
		addTrigger(triggersOnHit, new /datum/materialProc/molitz_on_hit())
		addTrigger(triggersExp, new /datum/materialProc/molitz_exp())

	beta
		mat_id = "molitz_b"
		name = "molitz beta"
		color = "#ff2288"
		desc = "A rare form of Molitz. When heated under special conditions it produces a powerful plasma fire catalyst."

		New()
			..()
			// no need to remove molitz_on_hit, all it does is call molitz_temp
			removeTrigger(triggersTemp, /datum/materialProc/molitz_temp)
			addTrigger(triggersTemp, new /datum/materialProc/molitz_temp/agent_b())
			return

/datum/material/crystal/claretine
	mat_id = "claretine"
	name = "claretine"
	desc = "Claretine is a highly conductive salt."
	color = "#C2280A"

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 1)
		setProperty("electrical", 8)


/datum/material/crystal/erebite
	mat_id = "erebite"
	name = "erebite"
	desc = "Erebite is an extremely volatile high-energy mineral."
	color = "#FF3700"

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 2)
		setProperty("hard", 3)
		setProperty("electrical", 6)
		setProperty("radioactive", 8)

		addTrigger(triggersOnAdd, new /datum/materialProc/erebite_flash())
		addTrigger(triggersTemp, new /datum/materialProc/erebite_temp())
		addTrigger(triggersExp, new /datum/materialProc/erebite_exp())
		addTrigger(triggersOnAttack, new /datum/materialProc/generic_explode_attack(33))
		addTrigger(triggersOnAttacked, new /datum/materialProc/generic_explode_attack(33))
		addTrigger(triggersOnHit, new /datum/materialProc/generic_explode_attack(33))


/datum/material/crystal/plasmastone
	mat_id = "plasmastone"
	name = "plasmastone"
	desc = "Plasma in its solid state."
	color = "#A114FF"

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 1)
		setProperty("hard", 2)
		setProperty("electrical", 5)
		setProperty("radioactive", 2)
		setProperty("flammable", 8)

		addTrigger(triggersTemp, new /datum/materialProc/plasmastone())
		addTrigger(triggersExp, new /datum/materialProc/plasmastone())
		addTrigger(triggersOnHit, new /datum/materialProc/plasmastone_on_hit())


/datum/material/crystal/plasmaglass
	mat_id = "plasmaglass"
	name = "plasma glass"
	desc = "Crystallized plasma that has been rendered inert. Very hard and prone to making extremely sharp edges."
	color = "#A114FF"
	alpha = 180

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 7)


/datum/material/crystal/gemstone
	mat_id = "quartz"
	name = "quartz"
	desc = "Quartz is somewhat valuable but not paticularly useful."
	color = "#BBBBBB"
	alpha = 220
	quality = 50
	var/gem_tier = 3

	New()
		..()
		switch(gem_tier)
			if(1)
				value = 700
				name = "clear [src.name]"
				setProperty("density", 6)
				setProperty("hard", 7)
				addTrigger(triggersOnAdd, new /datum/materialProc/gold_add())
			if(2)
				value = 500
				name = "flawed [src.name]"
				setProperty("density", 4)
				setProperty("hard", 5)
			if(3)
				value = 200
				name = "inferior [src.name]"
				setProperty("density", 3)
				setProperty("hard", 4)


	diamond
		mat_id = "diamond"
		name = "diamond"
		color = "#FFFFFF"
		quality = 100
		gem_tier = 1

	onyx
		mat_id = "onyx"
		name = "onyx"
		color = "#000000"

	ruby
		mat_id = "ruby"
		name = "ruby"
		color = "#D00000"
		quality = 100
		gem_tier = 1

	rose_quartz
		mat_id = "rosequartz"
		name = "rose quartz"
		color = "#FFC9E8"

	jasper
		mat_id = "jasper"
		name = "jasper"
		color = "#FF7A21"
		quality = 75
		gem_tier = 2

	garnet
		mat_id = "garnet"
		name = "garnet"
		color = "#DB8412"
		quality = 75
		gem_tier = 2

	topaz
		mat_id = "topaz"
		name = "topaz"
		color = "#EBB028"
		quality = 100
		gem_tier = 1

	citrine
		mat_id = "citrine"
		name = "citrine"
		color = "#F5F11B"

	peridot
		mat_id = "peridot"
		name = "peridot"
		color = "#9CC748"
		quality = 75
		gem_tier = 2

	emerald
		mat_id = "emerald"
		name = "emerald"
		color = "#3AB818"
		quality = 100
		gem_tier = 1

	jade
		mat_id = "jade"
		name = "jade"
		color = "#3C8F4D"

	malachite
		mat_id = "malachite"
		name = "malachite"
		color = "#1DF091"
		quality = 75
		gem_tier = 2

	aquamarine
		mat_id = "aquamarine"
		name = "aquamarine"
		color = "#68F7D8"

	sapphire
		mat_id = "sapphire"
		name = "sapphire"
		color = "#2789F2"
		quality = 100
		gem_tier = 1

	lapis
		mat_id = "lapislazuli"
		name = "lapis lazuli"
		color = "#1719BD"
		quality = 75
		gem_tier = 2

	iolite
		mat_id = "iolite"
		name = "iolite"
		color = "#D5A8FF"

	amethyst
		mat_id = "amethyst"
		name = "amethyst"
		color = "#BD0FDB"
		quality = 100
		gem_tier = 1

	alexandrite
		mat_id = "alexandrite"
		name = "alexandrite"
		color = "#EB2FA9"
		quality = 75
		gem_tier = 2

/datum/material/crystal/uqill //Ancients
	mat_id = "uqill"
	name = "uqill"
	desc = "Uqill is a rare and very dense stone."
	color = "#0F0A08"
	alpha = 255

	transparent // For bulletproof windows.
		mat_id = "uqillglass"
		name = "transparent uqill"
		desc = "Uqill-derived material developed for usage as transparent armor."
		color = "#615757"
		alpha = 180

	New()
		..()
		setProperty("density", 8)
		setProperty("hard", 4)
		setProperty("chemical", 9)


// hi it me cirr im doing dumb
/datum/material/crystal/gnesis //Feather
	mat_id = "gnesis"
	name = "gnesis"
	desc = "A rare complex crystalline matrix with a lazily shifting internal structure. Not to be confused with gneiss, a metamorphic rock."
	color = "#1bdebd"
	texture = "flock"
	texture_blend = BLEND_OVERLAY

	transparent
		mat_id = "gnesisglass"
		name = "transclucent gnesis"
		desc = "A rare complex crystalline matrix with a lazily shifting internal structure. The layers are arranged to let light through."
		color = "#ffffff"
		alpha = 180

	New()
		..()
		material_flags |= MATERIAL_METAL
		setProperty("density", 2) //light
		setProperty("hard", 5) // very hard
		setProperty("reflective", 9) // shiny
		setProperty("electrical", 7) // good conductor


/datum/material/crystal/telecrystal
	mat_id = "telecrystal"
	name = "telecrystal"
	desc = "Telecrystal is a gemstone with space-warping properties."
	color = "#4C14F5"
	alpha = 100

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 1)
		setProperty("hard", 2)
		setProperty("reflective", 8)
		addTrigger(triggersOnLife, new /datum/materialProc/telecrystal_life())
		addTrigger(triggersOnEntered, new /datum/materialProc/telecrystal_entered())
		addTrigger(triggersOnAttack, new /datum/materialProc/telecrystal_onattack())



/datum/material/crystal/miracle
	mat_id = "miracle"
	name = "miraclium"
	desc = "Miraclium is a bizarre substance that can have a wide variety of effects."
	color = "#FFFFFF"

	New()
		..()
		addTrigger(triggersOnAdd, new /datum/materialProc/miracle_add())
		quality = rand(-50, 100)
		alpha = rand(20, 255)
		setProperty("density", rand(1, 8))
		setProperty("hard", rand(1, 8))
		setProperty("reflective", rand(1, 9))
		setProperty("chemical", rand(1, 8))
		addTrigger(triggersTemp, new /datum/materialProc/temp_miraclium())


/datum/material/crystal/starstone
	mat_id = "starstone"
	name = "starstone"
	desc = "An extremely rare jewel."
	color = "#B5E0FF"
	alpha = 80
	quality = 45
	value = 1000

	New()
		..()
		setProperty("reflective", 9)
		setProperty("density", 9)
		setProperty("hard", 9)
		setProperty("electrical", 1)
		addTrigger(triggersOnAdd, new /datum/materialProc/gold_add())


/datum/material/crystal/ice
	mat_id = "ice"
	name = "ice"
	desc = "The frozen state of water."
	color = "#E8F2FF"
	alpha = 100

	edible_exact = 1
	edible = 1

	New()
		..()
		setProperty("electrical", 6)
		setProperty("density", 1)
		setProperty("hard", 2)
		addTrigger(triggersOnLife, new /datum/materialProc/ice_life())
		addTrigger(triggersOnAttack, new /datum/materialProc/slippery_attack())
		addTrigger(triggersOnEntered, new /datum/materialProc/slippery_entered())


/datum/material/crystal/wizard
	quality = 50
	alpha = 100
	value = 650

	New()
		..()
		setProperty("density", 6)
		setProperty("hard", 6)
		addTrigger(triggersOnAdd, new /datum/materialProc/enchanted_add())


	quartz // basically wizard glass
		mat_id = "wiz_quartz"
		name = "enchanted quartz"
		color = "#A3DCFF"

	topaz
		mat_id = "wiz_topaz"
		name = "enchanted topaz"
		color = "#FFC87C"

	ruby
		mat_id = "wiz_ruby"
		name = "enchanted ruby"
		color = "#991933"

	amethyst
		mat_id = "wiz_amethyst"
		name = "enchanted amethyst"
		color = "#9966FF"

	emerald
		mat_id = "wiz_emerald"
		name = "enchanted emerald"
		color = "#4CCC66"

	sapphire
		mat_id = "wiz_sapphire"
		name = "enchanted sapphire"
		color = "#1966B3"

// Organics

/// Base organic material parent
ABSTRACT_TYPE(/datum/material/organic)
/datum/material/organic
	color = "#555555"
	alpha 				   = 255
	quality				   = 0

	New()
		. = ..()
		material_flags |= MATERIAL_ORGANIC
		setProperty("flammable", 3)
		setProperty("electrical", 4)

/datum/material/organic/blob
	mat_id = "blob"
	name = "blob"
	desc = "The material of the feared giant space amobea."
	color = "#44cc44"
	alpha = 180
	quality = 2
	texture = "bubbles"
	texture_blend = BLEND_ADD

	edible_exact = 0.6 //Just barely edible
	edible = 1

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL | MATERIAL_CLOTH
		setProperty("chemical", 3)
		setProperty("density", 5)
		setProperty("hard", 1)
		setProperty("flammable", 5)
		addTrigger(triggersOnEat, new /datum/materialProc/oneat_blob())



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
		setProperty("density", 3)
		setProperty("hard", 1)
		//addTrigger(triggersOnEat, new /datum/materialProc/oneat_flesh())


	butt
		color = "#ebbd97"
		mat_id = "butt"
		name = "butt"
		texture = "buttgrey"
		texture_blend = BLEND_OVERLAY
		desc = "...it's butt flesh. Why is this here. Why do you somehow know it's butt flesh. Fuck."

		New()
			..()
			addTrigger(triggersPickup, new /datum/materialProc/onpickup_butt)
			addTrigger(triggersOnHit, new /datum/materialProc/onpickup_butt)

/datum/material/organic/char
	mat_id = "char"
	name = "char"
	desc = "Char is a fossil energy source similar to coal."
	color = "#555555"

	New()
		..()
		setProperty("flammable", 5)
		setProperty("hard", 3)
		setProperty("density", 2)


/datum/material/organic/koshmarite
	mat_id = "koshmarite"
	name = "koshmarite"
	desc = "An unusual dense pulsating stone. You feel uneasy just looking at it."
	color = "#600066"

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("hard", 3)
		setProperty("reflective", 6)
		setProperty("n_radioactive", 1)
		setProperty("density", 5)


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
		setProperty("density", 4)
		setProperty("hard", 1)
		setProperty("chemical", 6)
		setProperty("flammable", 2)
		addTrigger(triggersOnEat, new /datum/materialProc/oneat_viscerite())


/datum/material/organic/bone
	mat_id = "bone"
	name = "bone"
	desc = "Bone is pretty spooky stuff."
	color = "#DDDDDD"

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 5)
		setProperty("flammable", 2)


/datum/material/organic/wood
	mat_id = "wood"
	name = "wood"
	desc = "Wood from some sort of tree."
	color = "#331f16"
	texture = "wood"
	texture_blend = BLEND_ADD

	New()
		..()
		setProperty("density", 5)
		setProperty("hard", 3)
		setProperty("flammable", 4)


/datum/material/organic/bamboo
	mat_id = "bamboo"
	name = "bamboo"
	desc = "Bamboo is a giant woody grass."
	color = "#544c24"
	texture = "bamboo"
	texture_blend = BLEND_ADD

	New()
		..()
		setProperty("density", 4)
		setProperty("flammable", 4)


/datum/material/organic/cardboard
	mat_id = "cardboard"
	name = "cardboard"
	desc = "Perfect for making boxes."
	color = "#d3b173"

	New()
		..()
		setProperty("density", 2)
		setProperty("hard", 1)
		setProperty("flammable", 4)
		addTrigger(triggersOnBlobHit, new /datum/materialProc/cardboard_blob_hit())
		addTrigger(triggersOnHit, new /datum/materialProc/cardboard_on_hit())


/datum/material/organic/chitin
	mat_id = "chitin"
	name = "chitin"
	desc = "Chitin is an organic material found in the exoskeletons of insects."
	color = "#118800"

	New()
		..()
		material_flags |= MATERIAL_METAL
		setProperty("density", 2)
		setProperty("hard", 6)


/datum/material/organic/beeswax
	mat_id = "beeswax"
	name = "beeswax"
	desc = "An organic material consisting of pollen and space-bee secretions.  Mind your own."
	color = "#C8BB62"

	New()
		..()
		setProperty("density", 1)
		setProperty("hard", 2)
		setProperty("flammable", 4)


/datum/material/organic/honey
	mat_id = "honey"
	name = "refined honey" //Look calling both the globs and the material just "honey" isn't helping people's confusion wrt making clone pods
	desc = ""
	color = "#f1da10"
	edible_exact = TRUE
	edible = TRUE

	New()
		..()
		setProperty("density", 2)
		setProperty("hard", 1)
		setProperty("flammable", 4)
		// addTrigger(triggersOnEat, new /datum/materialProc/oneat_honey())
		// maybe make it sticky somehow?


/datum/material/organic/frozenfart
	mat_id = "frozenfart"
	name = "frozen fart"
	desc = "A semi-solid state of farts originally proposed to exist by Dr. Prof. Wonk in 2016."
	color = "#003300"

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 2)
		setProperty("thermal", 1)
		addTrigger(triggersOnAdd, new /datum/materialProc/ffart_add())
		addTrigger(triggersPickup, new /datum/materialProc/ffart_pickup())


/datum/material/organic/hamburgris
	mat_id = "hamburgris"
	name = "hamburgris"
	desc = "Ancient medium ground chuck, petrified by the ages into a sturdy composite. Or worse."
	color = "#816962"

	New()
		..()
		setProperty("density", 5)
		setProperty("chemical", 7)
		setProperty("thermal", 2)
		setProperty("flammable", 1)
		addTrigger(triggersOnLife, new /datum/materialProc/generic_reagent_onlife("cholesterol", 1))



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
		setProperty("hard", 1)


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
		setProperty("density", 2)
		setProperty("hard", 5)


/datum/material/organic/ectoplasm
	mat_id = "ectoplasm"
	name = "ectoplasm"
	desc = "Ghostly residue. Not terribly useful on it's own."
	color = "#ccffcc"

	New()
		..()
		material_flags |= MATERIAL_ENERGY
		setProperty("density", 1)
		setProperty("hard", 1)
		addTrigger(triggersOnAdd, new /datum/materialProc/ethereal_add())
// Fabrics

ABSTRACT_TYPE(/datum/material/fabric)
/datum/material/fabric
	quality				   = 5

	New()
		. = ..()
		material_flags |= MATERIAL_CLOTH
		setProperty("flammable", 2)
		setProperty("electrical", 4)
		setProperty("hard", 1)
		setProperty("density", 1)

/datum/material/fabric/leather
	mat_id = "leather"
	name = "leather"
	desc = "Leather is a flexible material derived from processed animal skins."
	color = "#8A3B11"

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 1)
		setProperty("thermal", 3)
		setProperty("electrical", 3)


/datum/material/fabric/synthleather
	mat_id = "synthleather"
	name = "synthleather"
	desc = "Synthleather is an artificial leather."
	color = "#BB3B11"

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 1)
		setProperty("thermal", 4)
		setProperty("electrical", 4)


/datum/material/fabric/brullbarhide
	mat_id = "brullbarhide"
	name = "brullbar hide"
	desc = "The hide of a fearsome brullbar!"
	color = "#CCCCCC"

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 2)
		setProperty("thermal", 2)
		setProperty("electrical", 4)


/datum/material/fabric/brullbarhide/king
	mat_id = "kingbrullbarhide"
	name = "king brullbar hide"
	desc = "The hide of a terrifying brullbar king!!!"
	color = "#EFEEEE"

	New()
		..()
		setProperty("density", 7)
		setProperty("hard", 3)
		setProperty("thermal", 1)
		setProperty("electrical", 4)
		setProperty("flammable", 1)


/datum/material/fabric/cotton
	mat_id = "cotton"
	name = "cotton"
	desc = "Cotton is a soft and fluffy material obtained from certain plants."
	color = "#FFFFFF"

	New()
		..()
		setProperty("density", 1)
		setProperty("hard", 1)
		setProperty("thermal", 4)
		setProperty("flammable", 4)


/datum/material/fabric/fibrilith
	mat_id = "fibrilith"
	name = "fibrilith"
	desc = "Fibrilith is an odd fibrous crystal known for its high tensile strength. Seems a bit similar to asbestos."
	color = "#E0FFF6"

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("density", 3)
		setProperty("hard", 2)
		setProperty("thermal", 1)
		setProperty("flammable", 1)


	New()
		..()
		addTrigger(triggersOnLife, new /datum/materialProc/generic_itchy_onlife())


/datum/material/fabric/spidersilk
	mat_id = "spidersilk"
	name = "spider silk"
	desc = "Spider silk is a protein fiber spun by space spiders."
	color = "#CCCCCC"

	New()
		..()
		setProperty("density", 6)
		setProperty("hard", 1)
		setProperty("thermal", 4)
		setProperty("flammable", 5)


/datum/material/fabric/carbonfibre
	mat_id = "carbonfibre"
	name = "carbon nanofiber"
	desc = "Carbon Nanofibers are highly graphitic carbon nanomaterials with excellent mechanical properties, electrical conductivity and thermal conductivity."
	color = "#333333"

	New()
		..()
		setProperty("density", 4)
		setProperty("hard", 4)
		setProperty("thermal", 9)
		setProperty("electrical", 7)


/datum/material/fabric/hauntium
	mat_id = "hauntium"
	name = "hauntium"
	desc = "A silky smooth fabric that almost seems alive."
	color = "#8c87b2"


	New()
		..()
		material_flags |= MATERIAL_METAL | MATERIAL_ENERGY
		setProperty("density", 1)
		setProperty("hard", 1)
		setProperty("electrical", 1)
		addTrigger(triggersOnAdd, new /datum/materialProc/ethereal_add())
		addTrigger(triggersOnEntered, new /datum/materialProc/soulsteel_entered())


/datum/material/fabric/ectofibre
	mat_id = "ectofibre"
	name = "ectofibre"
	desc = "Ectoplasmic fibres. Sort of transparent. Seems to be rather strong yet flexible."
	color = "#ffffff"
	alpha = 128

	New()
		..()
		material_flags |= MATERIAL_ENERGY | MATERIAL_CRYSTAL
		setProperty("density", 6)
		setProperty("hard", 1)
		setProperty("thermal", 9)
		setProperty("radioactive", 3)
		setProperty("electrical", 7)
		addTrigger(triggersOnLife, new /datum/materialProc/generic_itchy_onlife())


/datum/material/fabric/dyneema
	mat_id = "dyneema"
	name = "dyneema"
	desc = "A blend of carbon nanofibres and space spider silk. Highly versatile."
	color = "#333333"

	New()
		..()
		setProperty("density", 8)
		setProperty("hard", 4)
		setProperty("chemical", 9)
		setProperty("electrical", 7)
		setProperty("flammable", 1)



/datum/material/fabric/beewool
	mat_id = "beewool"
	name = "bee wool"
	desc = "Wool of adorable furry space bees."
	color = "#ffcc00"
	texture = "bee"
	texture_blend = BLEND_SUBTRACT

	New()
		..()
		setProperty("hard", 2)
		setProperty("density", 2)
		setProperty("flammable", 6)
		setProperty("electrical", 3)
		setProperty("thermal", 7)

ABSTRACT_TYPE(/datum/material/rubber)
/datum/material/rubber
	New()
		. = ..()
		material_flags |= MATERIAL_RUBBER
		setProperty("electrical", 3)

/datum/material/rubber/latex
	mat_id = "latex"
	name = "latex"
	desc = "A type of synthetic rubber. Conducts electricity poorly."
	color = "#DDDDDD" //"#FF0000" idgaf ok I want red cables back. no haine, this stuff isnt red.

	New()
		..()
		setProperty("density", 2)
		setProperty("hard", 1)
		setProperty("electrical", 3)
		setProperty("thermal", 4)


/datum/material/rubber/synthrubber
	mat_id = "synthrubber"
	name = "synthrubber"
	desc = "A type of synthetic rubber. Quite garish, really."
	color = "#FF0000" //But this is red okay.

	New()
		..()
		setProperty("density", 3)
		setProperty("hard", 1)
		setProperty("electrical", 2)
		setProperty("thermal", 4)


/datum/material/rubber/synthblubber //it had to be done
	mat_id = "synthblubber"
	name = "synthblubber"
	desc = "A type of synthetic blubber. Hold on. Blubber?!"
	color = "#1EA082"

	New()
		..()
		setProperty("density", 4)
		setProperty("hard", 1)
		setProperty("electrical", 1)
		setProperty("thermal", 3)
		setProperty("flammable", 3)

/datum/material/metal/plutonium
	mat_id = "plutonium"
	name = "plutonium 239"
	canMix = 0 //Can not be easily modified.
	desc = "Weapons grade refined plutonium."
	color = "#230e4d"
	quality = 60

	New()
		..()
		material_flags |= MATERIAL_CRYSTAL
		setProperty("density", 8)
		setProperty("hard", 7)
		setProperty("n_radioactive", 5)
		setProperty("radioactive", 3)
		setProperty("electrical", 7)
