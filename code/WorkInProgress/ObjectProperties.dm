/obj/item/proc/dbg_objectprop()
	set name = "Give Property"
	var/list/ids = list()
	propListCheck()

	for(var/P in globalPropList)
		var/datum/objectProperty/prop = globalPropList[P]
		ids.Add(prop.id)

	var/sel = input(usr,"Type:","Select type") in ids

	var/value = input(usr,"Value:","") as num

	src.setProperty(sel, value)
	return

/obj/var/list/properties = null

var/list/globalPropList = null

//There's only ever one instance of any given property being used for everything. This is for performance/memory reasons
//The properties list on objects is in the format of (instance of property) = (local value of said property)
//These are meant to be a centralized placed for all the different object properties we have. Armor, rad protection etc etc.
//But you can use them for anything.

/proc/propListCheck()
	if(globalPropList != null) return
	else
		globalPropList = list()
		for(var/X in (typesof(/datum/objectProperty) - /datum/objectProperty))
			var/datum/objectProperty/I = new X
			globalPropList.Add(I.id)
			globalPropList[I.id] = I
	return

/obj
	proc/setupProperties() //Should always be called by new(). This will contain all the default property initializations for objects.
		return

	proc/setProperty(var/propId, var/propVal=null) //Adds or sets property.
		propListCheck()

		if(src.properties == null)
			src.properties = list()

		if(globalPropList[propId] != null)
			for(var/datum/objectProperty/X in src.properties)
				if(X.id == propId)
					X.onChange(src, src.properties[X], ((propVal != null) ? propVal : X.defaultValue))
					src.properties[X] = propVal
					return X

			var/datum/objectProperty/P = globalPropList[propId]

			src.properties.Add(P)
			src.properties[P] = ((propVal != null) ? propVal : P.defaultValue)
			P.onAdd(src, propVal)
			return P
		else
			throw EXCEPTION("Invalid property ID passed to setProperty ([propId])")

	proc/getProperty(var/propId) //Gets property value.
		.= null
		if(src.properties && src.properties.len)
			var/datum/objectProperty/X = globalPropList[propId]
			return src.properties[X]
		/*
		if(src.properties && src.properties.len)
			for(var/datum/objectProperty/X in src.properties)
				if(X.id == propId)
					.= src.properties[X] //Assoc. value of property is the value.
		*/

	proc/delProperty(var/propId) //Removes property.
		if(src.properties && src.properties.len)
			for(var/datum/objectProperty/X in src.properties)
				if(X.id == propId)
					. = X
					X.onRemove(src, src.properties[X])
					src.properties.Remove(X)

	proc/hasProperty(var/propId) //Checks if property is on object.
		.= 0
		if(src.properties && src.properties.len)
			for(var/datum/objectProperty/X in src.properties)
				if(X.id == propId)
					.= 1

/obj/item
	setProperty()
		. = ..()
		src.tooltip_rebuild = 1
	delProperty()
		. = ..()
		src.tooltip_rebuild = 1

/datum/objectProperty
	var/name = ""
	var/id = ""
	var/desc = ""
	var/tooltipImg = "" //Stored in browserassets\images\tooltips
	var/defaultValue = 1 //Default value. Used to get an idea of what's "normal" for any given property.
	var/goodDirection = 1 //Dumb name. Tells us which direction the number should grow in for it to be considered "good", 1=positive, -1 negative

	proc/onAdd(var/obj/owner, var/value) //When property is added to an object
		return

	proc/onChange(var/obj/owner, var/oldValue, var/newValue) //When property value changes.
		return

	proc/onRemove(var/obj/owner, var/value) //When property is removed from an object.
		return

	proc/onUpdate() //Stub; Not implemented.
		return

	proc/getTooltipDesc(var/obj/propOwner, var/propVal)
		return "Value is [propVal]"

	frenzy
		name = "Frenzy"
		id = "frenzy"
		desc = "Attack speed increases with each attack." //Value is attack delay reduction per hit.
		tooltipImg = "frenzy.png"
		defaultValue = 0.5
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "+[propVal] atk. speed"

	impact
		name = "Impact"
		id = "impact"
		desc = "Target is knocked back on attacks." //Value is knockback range.
		tooltipImg = "impact.png"
		defaultValue = 1
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal] tiles"

	pierce
		name = "Piercing"
		id = "piercing"
		desc = "Attacks ignore a percentage of targets armor." //Value is percentage of armor ignored.
		tooltipImg = "pierce.png"
		defaultValue = 10
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal]% armor pierce"

	searing
		name = "Searing"
		id = "searing"
		desc = "Attacks deal increased damage as fire damage." //Value is extra damage.
		tooltipImg = "searing.png"
		defaultValue = 2
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "+[propVal] heat dmg."

	vorpal
		name = "Vorpal"
		id = "vorpal"
		desc = "Attacks deal bleed damage." //Value is extra damage.
		tooltipImg = "bleed.png"
		defaultValue = 2
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "+[propVal] bleed dmg."

	unstable
		name = "Unstable"
		id = "unstable"
		desc = "Attacks deal a random amount of damage." //Damage range is (base damage) -> (base damage * value of this).
		tooltipImg = "unstable.png"
		defaultValue = 1.33
		getTooltipDesc(var/obj/item/propOwner, var/propVal)
			return "[propOwner.force] to [propOwner.force*propVal] dmg"

	block
		name = "Block (Passive)"
		id = "block"
		desc = "Passive chance to block melee attacks." //Value is extra block chance.
		tooltipImg = "block.png"
		defaultValue = 5
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "+[propVal]% block chance"

	deflection
		name = "Deflection"
		id = "deflection"
		desc = "Improves chance to deflect attacks while unarmed." //Value is extra block chance.
		tooltipImg = "block.png"
		defaultValue = 10
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "+[propVal]% additional chance to deflect attacks while blocking"
	pierceprot
		name = "Piercing Resistance"
		id = "pierceprot"
		desc = "Reduces armor piercing on recieved attacks." //Value is flat reduction of incoming piercing %
		tooltipImg = "protpierce.png"
		defaultValue = 30
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal]% pierce resist"

	movement
		name = "Speed"
		id = "movespeed"
		desc = "Modifies movement speed." //Value is additional movement speed delay. (how much slower - negative value for speed increase)
		tooltipImg = "movement.png"
		defaultValue = 1
		goodDirection = -1
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal] movement delay"

		space
			name = "Speed"
			id = "space_movespeed"

			getTooltipDesc(var/obj/propOwner, var/propVal)
				return "[propVal] movement delay - 0 when worn in space."

	viralprot
		name = "Resistance (Viral)"
		id = "viralprot"
		desc = "Protects from diseases." //Value is % protection.
		tooltipImg = "disease.png"
		defaultValue = 10
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal]%"

	conductivity
		name = "Conductivity"
		id = "conductivity"
		desc = "Insulates against electricity." //Value is 0(not conductive) - 1(conductive)
		tooltipImg = "conduct.png"
		defaultValue = 0.1
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal * 100]% [propVal <= 0.2 ? "(Safe)":""]"

	stammax
		name = "Max. Stamina"
		id = "stammax"
		desc = "Affects max. stamina value" //Value is flat effective change to max stamina.
		tooltipImg = "stammax.png"
		defaultValue = 10
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal] max. stamina"

	stamregen
		name = "Stamina regen."
		id = "stamregen"
		desc = "Affects stamina regenration." //Value is flat effective change to stamina regeneration.
		tooltipImg = "stamregen.png"
		defaultValue = 1
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal] stamina regen."

	stamcost
		name = "Stamina cost"
		id = "stamcost"
		desc = "Affects stamina costs." //Value is percentage, global reduction in stamina costs.
		tooltipImg = "stamcost.png"
		defaultValue = 10
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "-[propVal]% stamina costs."

	negate_fluid_speed_penalty //important : delay added to dry land!
		name = "Fluid movement"
		id = "negate_fluid_speed_penalty"
		desc = "Negates fluid speed penalties."
		tooltipImg = "movement.png"
		defaultValue = 1
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "Negates fluid speed penalties.<br>+[propVal] movement delay on dry land."

	momentum // force increases as you attack players.
		name = "Momentum"
		id = "momentum"
		desc = "Attacking living humans increases damage."
		tooltipImg = "stamcost.png"
		defaultValue = 0
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "+[propVal] damage increased."

	disorient_resist
		name = "Body Insulation (Disorient Resist)"
		id = "disorient_resist"
		desc = "Reduces disorient effects on the wearer." //Value is % protection.
		tooltipImg = "protdisorient.png"
		defaultValue = 0
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal]%"

	disorient_resist_eye
		name = "Eye Insulation (Disorient Resist)"
		id = "disorient_resist_eye"
		desc = "Reduces disorient effects that apply through vision on the wearer." //Value is % protection.
		tooltipImg = "protdisorient_eye.png"
		defaultValue = 0
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal]%"

	disorient_resist_ear
		name = "Ear Insulation (Disorient Resist)"
		id = "disorient_resist_ear"
		desc = "Reduces disorient effects that apply through sound on the wearer." //Value is % protection.
		tooltipImg = "protdisorient_ear.png"
		defaultValue = 0
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal]%"

	inline //Seriously, if anyone has a better idea, tell me.
		disorient_resist
			name = "Body Insulation (Disorient Resist)"
			id = "I_disorient_resist"
			desc = "Reduces disorient effects on the wearer." //Value is % protection.
			tooltipImg = "protdisorient.png"
			defaultValue = 0
			getTooltipDesc(var/obj/propOwner, var/propVal)
				return "[propVal]%"
		block_blunt
			name = "Block"
			id = "I_block_blunt"
			desc = "This item could be held to block blunt damage. Use RESIST to block." //Value is % protection.
			tooltipImg = "bluntprot.png"
			defaultValue = 0
			getTooltipDesc(var/obj/propOwner, var/propVal)
				return "Blunt Damage"

		block_cut
			name = "Block"
			id = "I_block_cut"
			desc = "This item could be held to block slashing damage. Use RESIST to block." //Value is % protection.
			tooltipImg = "cutprot.png"
			defaultValue = 0
			getTooltipDesc(var/obj/propOwner, var/propVal)
				return "Slash Damage"

		block_stab
			name = "Block"
			id = "I_block_stab"
			desc = "This item could be held to block stabbing damage. Use RESIST to block." //Value is % protection.
			tooltipImg = "stabprot.png"
			defaultValue = 0
			getTooltipDesc(var/obj/propOwner, var/propVal)
				return "Stab Damage"

		block_burn
			name = "Block"
			id = "I_block_burn"
			desc = "This item could be held to block burn damage. Use RESIST to block." //Value is % protection.
			tooltipImg = "burnprot.png"
			defaultValue = 0
			getTooltipDesc(var/obj/propOwner, var/propVal)
				return "Burn Damage"

/*
For properties that are on equipment and should do stuff when the item is equipped / deequipped.

Note for later: it might be worth it to make an intermediate step of /datum/objectProperty/item
for stuff that should apply when the item with the property is picked up / dropped. But it's hard
to say if there's demand for that.
*/
/datum/objectProperty/equipment
	// Called when the property changes / gets added / gets equipped
	proc/updateMob(obj/item/owner, mob/user, value, oldValue=null)
		return

	// Called when the property gets removed or owner gets unequipped
	proc/removeFromMob(obj/item/owner, mob/user, value)
		return

	// Called when owner gets equipped into slot `slot`
	proc/onEquipped(obj/item/owner, mob/user, value, slot)
		src.updateMob(owner, user, value)

	// Called when owner gets unequipped
	proc/onUnequipped(obj/item/owner, mob/user, value)
		src.removeFromMob(owner, user, value)

	onAdd(obj/item/owner, value)
		. = ..()
		if(istype(owner.loc, /mob) && !isnull(owner.equipped_in_slot))
			src.updateMob(owner, owner.loc, value)

	onChange(obj/item/owner, oldValue, newValue)
		. = ..()
		if(istype(owner.loc, /mob) && !isnull(owner.equipped_in_slot))
			src.updateMob(owner, owner.loc, newValue, oldValue)

	onRemove(obj/item/owner, value)
		. = ..()
		if(istype(owner.loc, /mob) && !isnull(owner.equipped_in_slot))
			src.removeFromMob(owner, owner.loc, value)

// at the moment the mob property stuff only makes sense for human mobs!!
// Also currently the "source" of the mob property is the owner of the property (the item).
// If you are adding other properties granting some mob property make sure to use something like "\ref[owner]-something"
// as the source. This might be useful for blocking properties for example.

/datum/objectProperty/equipment/meleeprot
	name = "Resistance (Melee)"
	id = "meleeprot_parent"
	desc = "Protects from melee damage." //Value is flat damage reduction.
	tooltipImg = "melee.png"
	defaultValue = 2
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "-[propVal] dmg"

	body
		id = "meleeprot"
		updateMob(obj/item/owner, mob/user, value, oldValue=null)
			. = ..()
			APPLY_MOB_PROPERTY(user, PROP_MELEEPROT_BODY, owner, value)
		removeFromMob(obj/item/owner, mob/user, value)
			. = ..()
			REMOVE_MOB_PROPERTY(user, PROP_MELEEPROT_BODY, owner)

	head //ugly hack im sorry, this is used for head, mask, glasses and ear clothing
		id = "meleeprot_head"
		updateMob(obj/item/owner, mob/user, value, oldValue=null)
			. = ..()
			APPLY_MOB_PROPERTY(user, PROP_MELEEPROT_HEAD, owner, value)
		removeFromMob(obj/item/owner, mob/user, value)
			. = ..()
			REMOVE_MOB_PROPERTY(user, PROP_MELEEPROT_HEAD, owner)

	all //ugly hack but I'm not sorry, this is used for barriers
		id = "meleeprot_all"
		updateMob(obj/item/owner, mob/user, value, oldValue=null)
			. = ..()
			APPLY_MOB_PROPERTY(user, PROP_MELEEPROT_BODY, owner, value)
			APPLY_MOB_PROPERTY(user, PROP_MELEEPROT_HEAD, owner, value)
		removeFromMob(obj/item/owner, mob/user, value)
			. = ..()
			REMOVE_MOB_PROPERTY(user, PROP_MELEEPROT_BODY, owner)
			REMOVE_MOB_PROPERTY(user, PROP_MELEEPROT_HEAD, owner)

/datum/objectProperty/equipment/rangedprot
	name = "Resistance (Ranged)"
	id = "rangedprot"
	desc = "Protects from ranged damage." //Value is divisor applied to bullet power on hit. For humans, the sum of all equipment is used. Base value is 1, so one item with 1 additional armor = 2, half the damage
	tooltipImg = "bullet.png"
	defaultValue = 0.15
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal] prot."

	updateMob(obj/item/owner, mob/user, value, oldValue=null)
		. = ..()
		APPLY_MOB_PROPERTY(user, PROP_RANGEDPROT, owner, value)
	removeFromMob(obj/item/owner, mob/user, value)
		. = ..()
		REMOVE_MOB_PROPERTY(user, PROP_RANGEDPROT, owner)

/datum/objectProperty/equipment/radiationprot
	name = "Resistance (Radiation)"
	id = "radprot"
	desc = "Protects from harmful radiation." //Value is % protection.
	tooltipImg = "radiation.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	updateMob(obj/item/owner, mob/user, value, oldValue=null)
		. = ..()
		APPLY_MOB_PROPERTY(user, PROP_RADPROT, owner, value)
	removeFromMob(obj/item/owner, mob/user, value)
		. = ..()
		REMOVE_MOB_PROPERTY(user, PROP_RADPROT, owner)

/datum/objectProperty/equipment/coldprot
	name = "Resistance (Cold)"
	id = "coldprot"
	desc = "Protects from low temperatures." //Value is % protection.
	tooltipImg = "cold.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	updateMob(obj/item/owner, mob/user, value, oldValue=null)
		. = ..()
		APPLY_MOB_PROPERTY(user, PROP_COLDPROT, owner, value)
	removeFromMob(obj/item/owner, mob/user, value)
		. = ..()
		REMOVE_MOB_PROPERTY(user, PROP_COLDPROT, owner)

/datum/objectProperty/equipment/heatprot
	name = "Resistance (Heat)"
	id = "heatprot"
	desc = "Protects from high temperatures." //Value is % protection.
	tooltipImg = "heat.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	updateMob(obj/item/owner, mob/user, value, oldValue=null)
		. = ..()
		APPLY_MOB_PROPERTY(user, PROP_HEATPROT, owner, value)
	removeFromMob(obj/item/owner, mob/user, value)
		. = ..()
		REMOVE_MOB_PROPERTY(user, PROP_HEATPROT, owner)

/datum/objectProperty/equipment/exploprot
	name = "Resistance (Explosion)"
	id = "exploprot"
	desc = "Protects from explosions." //Value is % protection.
	tooltipImg = "explosion.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]"

	updateMob(obj/item/owner, mob/user, value, oldValue=null)
		. = ..()
		APPLY_MOB_PROPERTY(user, PROP_EXPLOPROT, owner, value)
	removeFromMob(obj/item/owner, mob/user, value)
		. = ..()
		REMOVE_MOB_PROPERTY(user, PROP_EXPLOPROT, owner)



/datum/objectProperty/equipment/reflection // force increases as you attack players.
	name = "Reflection"
	id = "reflection"
	desc = "Reflects projectiles while held."
	tooltipImg = "disorient_resist.png"
	defaultValue = 0
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "Reflecting projectiles"

	updateMob(obj/item/owner, mob/user, value, oldValue=null)
		. = ..()
		APPLY_MOB_PROPERTY(user, PROP_REFLECTPROT, owner)

	removeFromMob(obj/item/owner, mob/user, value)
		. = ..()
		REMOVE_MOB_PROPERTY(user, PROP_REFLECTPROT, owner)