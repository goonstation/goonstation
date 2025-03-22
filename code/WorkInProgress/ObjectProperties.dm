#define ASSOCIATE_ATOM_PROPERTY(PROP) \
	updateMob(obj/item/owner, mob/user, value, oldValue=null) { \
		. = ..(); \
		APPLY_ATOM_PROPERTY(user, PROP, owner, value); \
	} \
	removeFromMob(obj/item/owner, mob/user, value) { \
		. = ..(); \
		REMOVE_ATOM_PROPERTY(user, PROP, owner); \
	}

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
		SHOULD_CALL_PARENT(TRUE)
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
		if(src.properties && length(src.properties))
			var/datum/objectProperty/X = globalPropList[propId]
			return src.properties[X]
		/*
		if(src.properties && length(src.properties))
			for(var/datum/objectProperty/X in src.properties)
				if(X.id == propId)
					.= src.properties[X] //Assoc. value of property is the value.
		*/

	proc/delProperty(var/propId) //Removes property.
		if(src.properties && length(src.properties))
			for(var/datum/objectProperty/X in src.properties)
				if(X.id == propId)
					. = X
					X.onRemove(src, src.properties[X])
					src.properties.Remove(X)

	proc/hasProperty(var/propId) //Checks if property is on object.
		.= 0
		if(src.properties && length(src.properties))
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
	var/tooltipImg = "" //Stored in browserassets\src\images\tooltips
	var/defaultValue = 1 //Default value. Used to get an idea of what's "normal" for any given property.
	var/goodDirection = 1 //Dumb name. Tells us which direction the number should grow in for it to be considered "good", 1=positive, -1 negative
	var/hidden = 0 //does not get printed in item tooltips
	var/inline = 0 //For use on properties on blocks only: gets printed in the the blocking-inline section of tooltips
				   //ignores hidden (and should be used with hidden unless you want it printed both in the inline section and with the rest of the properties)

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

	pierceprot
		name = "Piercing Resistance"
		id = "pierceprot"
		desc = "Reduces armor piercing on received attacks." //Value is flat reduction of incoming piercing %
		tooltipImg = "protpierce.png"
		defaultValue = 30
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal]% pierce resist"

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
			return "[propVal * 100]% [propVal <= 0.29 ? "(Safe)":""]"

	stammax
		name = "Max. Stamina"
		id = "stammax"
		desc = "Affects max. stamina value" //Value is flat effective change to max stamina.
		tooltipImg = "stammax.png"
		defaultValue = 10
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal] max. stamina"

	stamcost
		name = "Stamina cost"
		id = "stamcost"
		desc = "Affects stamina costs." //Value is percentage, global reduction in stamina costs.
		tooltipImg = "stamcost.png"
		defaultValue = 10
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "-[propVal]% stamina costs."

	momentum // force increases as you attack players.
		name = "Momentum"
		id = "momentum"
		desc = "Attacking living humans increases damage."
		tooltipImg = "stamcost.png"
		defaultValue = 0
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "+[propVal] damage increased."

	enchantweapon
		hidden = 1
		name = "Enchantment"
		id = "enchantweapon"
		desc = "Magical improvements to melee weaponry"
		tooltipImg = "bleed.png"
		defaultValue = 1
		onAdd(obj/item/owner, value)
			if(istype(owner))
				owner.force += value
		onChange(obj/item/owner, oldValue, newValue)
			if(istype(owner))
				owner.force += (newValue - oldValue)
		onRemove(obj/item/owner, value)
			if(istype(owner))
				owner.force -= value

	genericenchant
		hidden = 1
		name = "Enchantment"
		id = "enchant"
		desc = "Magic!"
		tooltipImg = "block.png"
		defaultValue = 1

		onAdd(obj/item/owner, value)
			. = ..()
			for(var/datum/objectProperty/P in owner.properties)
				if(P.id == "enchant") continue
				var/val = owner.getProperty(P.id)
				owner.setProperty(P.id, val * (1+(P.goodDirection * sign(val) * (value/10))))
			owner.force *= (1+value/10)

		onChange(obj/item/owner, oldValue, newValue)
			. = ..()
			onRemove(owner, oldValue)
			onAdd(owner, newValue)

		onRemove(obj/item/owner, value)
			. = ..()
			for(var/datum/objectProperty/P in owner.properties)
				if(P.id == "enchant") continue
				var/val = owner.getProperty(P.id)
				owner.setProperty(P.id, val / (1+(P.goodDirection * sign(val) * (value/10))))
			owner.force /= (1+value/10)

	inline //Seriously, if anyone has a better idea, tell me.
		inline = 1
		hidden = 1

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

// at the moment the atom property stuff only makes sense for human mobs!!
// Also currently the "source" of the atom property is the owner of the property (the item).
// If you are adding other properties granting some atom property make sure to use something like "\ref[owner]-something"
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
		ASSOCIATE_ATOM_PROPERTY(PROP_MOB_MELEEPROT_BODY)

	head //ugly hack im sorry, this is used for head, mask, glasses and ear clothing
		id = "meleeprot_head"
		ASSOCIATE_ATOM_PROPERTY(PROP_MOB_MELEEPROT_HEAD)

	all //ugly hack but I'm not sorry, this is used for barriers
		id = "meleeprot_all"
		updateMob(obj/item/owner, mob/user, value, oldValue=null)
			. = ..()
			APPLY_ATOM_PROPERTY(user, PROP_MOB_MELEEPROT_BODY, owner, value)
			APPLY_ATOM_PROPERTY(user, PROP_MOB_MELEEPROT_HEAD, owner, value)
		removeFromMob(obj/item/owner, mob/user, value)
			. = ..()
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_MELEEPROT_BODY, owner)
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_MELEEPROT_HEAD, owner)

/datum/objectProperty/equipment/rangedprot
	name = "Resistance (Ranged)"
	id = "rangedprot"
	desc = "Protects from ranged damage." //Value is divisor applied to bullet power on hit. For humans, the sum of all equipment is used. Base value is 1, so one item with 1 additional armor = 2, half the damage
	tooltipImg = "bullet.png"
	defaultValue = 0.15
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal] prot."

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_RANGEDPROT)

/datum/objectProperty/equipment/radiationprot
	name = "Resistance (Radiation)"
	id = "radprot"
	desc = "Protects from harmful radiation." //Value is vaguely related to % protection.
	tooltipImg = "radiation.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal] radOhms"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_RADPROT_EXT)

/datum/objectProperty/equipment/coldprot
	name = "Resistance (Cold)"
	id = "coldprot"
	desc = "Protects from low temperatures." //Value is % protection.
	tooltipImg = "cold.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_COLDPROT)

/datum/objectProperty/equipment/heatprot
	name = "Resistance (Heat)"
	id = "heatprot"
	desc = "Protects from high temperatures." //Value is % protection.
	tooltipImg = "heat.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_HEATPROT)

/datum/objectProperty/equipment/exploprot
	name = "Resistance (Explosion)"
	id = "exploprot"
	desc = "Protects from explosions." //Value is % protection.
	tooltipImg = "explosion.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_EXPLOPROT)

/datum/objectProperty/equipment/chemprot
	name = "Resistance (Chemical)"
	id = "chemprot"
	desc = "Protects from chemicals." //Value is % of chemicals blocked
	tooltipImg = "chemical.png"
	defaultValue = 10
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_CHEMPROT)

/datum/objectProperty/equipment/reflection // force increases as you attack players.
	name = "Reflection"
	id = "reflection"
	desc = "Reflects projectiles while held."
	tooltipImg = "disorient_resist.png"
	defaultValue = 0
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "Reflecting projectiles"

	// no ASSOCIATE_ATOM_PROPERTY because this one is simple, valueless
	updateMob(obj/item/owner, mob/user, value, oldValue=null)
		. = ..()
		APPLY_ATOM_PROPERTY(user, PROP_MOB_REFLECTPROT, owner)
	removeFromMob(obj/item/owner, mob/user, value)
		. = ..()
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_REFLECTPROT, owner)

/datum/objectProperty/equipment/toy_reflection // reflects foam darts.
	name = "Toy Reflection"
	id = "toyreflection"
	desc = "Reflects toy projectiles while held."
	tooltipImg = "disorient_resist.png"
	defaultValue = 0
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "Reflecting toy projectiles"

	// no ASSOCIATE_ATOM_PROPERTY because this one is simple, valueless
	updateMob(obj/item/owner, mob/user, value, oldValue=null)
		. = ..()
		APPLY_ATOM_PROPERTY(user, PROP_MOB_TOYREFLECTPROT, owner)
	removeFromMob(obj/item/owner, mob/user, value)
		. = ..()
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_TOYREFLECTPROT, owner)

/datum/objectProperty/equipment/enchantarmor
	hidden = 1
	name = "Enchantment"
	id = "enchantarmor"
	desc = "Magical improvements to defensive clothing"
	tooltipImg = "block.png"
	defaultValue = 1

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_ENCHANT_ARMOR)

/datum/objectProperty/equipment/stamregen
	name = "Stamina regen."
	id = "stamregen"
	desc = "Affects stamina regenration." //Value is flat effective change to stamina regeneration.
	tooltipImg = "stamregen.png"
	defaultValue = 1

	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal] stamina regen."

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_STAMINA_REGEN_BONUS)

/datum/objectProperty/equipment/deflection
	name = "Deflection"
	id = "deflection"
	desc = "Improves chance to resist being disarmed." //Value is extra block chance.
	tooltipImg = "block.png"
	defaultValue = 10

	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "+[propVal]% additional chance to deflect disarm attempts"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_DISARM_RESIST)

/datum/objectProperty/equipment/disorient_resist
	name = "Body Insulation (Disorient Resist)"
	id = "disorient_resist"
	desc = "Reduces disorient effects on the wearer." //Value is % protection.
	tooltipImg = "protdisorient.png"
	defaultValue = 0
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_DISORIENT_RESIST_BODY)
	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_DISORIENT_RESIST_BODY_MAX)

	inline
		inline = 1
		hidden = 1
		name = "Body Insulation (Disorient Resist)"
		id = "I_disorient_resist"
		desc = "Reduces disorient effects on the wearer." //Value is % protection.
		tooltipImg = "protdisorient.png"
		defaultValue = 0
		getTooltipDesc(var/obj/propOwner, var/propVal)
			return "[propVal]%"

/datum/objectProperty/equipment/disorient_resist_eye
	name = "Eye Insulation (Disorient Resist)"
	id = "disorient_resist_eye"
	desc = "Reduces disorient effects that apply through vision on the wearer." //Value is % protection.
	tooltipImg = "protdisorient_eye.png"
	defaultValue = 0
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_DISORIENT_RESIST_EYE)
	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_DISORIENT_RESIST_EYE_MAX)

/datum/objectProperty/equipment/disorient_resist_ear
	name = "Ear Insulation (Disorient Resist)"
	id = "disorient_resist_ear"
	desc = "Reduces disorient effects that apply through sound on the wearer." //Value is % protection.
	tooltipImg = "protdisorient_ear.png"
	defaultValue = 0
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal]%"

	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_DISORIENT_RESIST_EAR)
	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_DISORIENT_RESIST_EAR_MAX)

/datum/objectProperty/equipment/vault_speed
	name = "Vault Speed"
	id = "vault_speed"
	desc = "Reduces the time needed to vault over a railing."
	tooltipImg = "movement.png"
	defaultValue = 1
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "+[propVal]x"
	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_VAULT_SPEED)

/datum/objectProperty/equipment/movement
	name = "Speed"
	id = "movespeed"
	desc = "Modifies movement speed." //Value is additional movement speed delay. (how much slower - negative value for speed increase)
	tooltipImg = "movement.png"
	defaultValue = 1
	goodDirection = -1
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal] movement delay"
	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_EQUIPMENT_MOVESPEED)

/datum/objectProperty/equipment/movement/in_hand
	name = "Speed"
	id = "carried_movespeed"
	desc = "Modifies movement speed." //Value is additional movement speed delay. (how much slower - negative value for speed increase)

	onEquipped(obj/item/owner, mob/user, value, slot)
		if(slot != SLOT_L_HAND && slot != SLOT_R_HAND)
			return 0
		. = ..()

	onUnequipped(obj/item/owner, mob/user, value)
		if(owner.equipped_in_slot != SLOT_L_HAND && owner.equipped_in_slot != SLOT_R_HAND)
			return 0
		. = ..()

	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal] movement delay - 0 when worn."

/datum/objectProperty/equipment/movement/space
	name = "Speed"
	id = "space_movespeed"

	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "[propVal] movement delay - 0 when worn in space."
	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_EQUIPMENT_MOVESPEED_SPACE)

/datum/objectProperty/equipment/movement/fluid //important : delay added to dry land!
	name = "Fluid movement"
	id = "negate_fluid_speed_penalty"
	desc = "Negates fluid speed penalties."
	tooltipImg = "movement.png"
	defaultValue = 1
	getTooltipDesc(var/obj/propOwner, var/propVal)
		return "Negates fluid speed penalties.<br>+[propVal] movement delay on dry land."
	ASSOCIATE_ATOM_PROPERTY(PROP_MOB_EQUIPMENT_MOVESPEED_FLUID)


#undef ASSOCIATE_ATOM_PROPERTY
