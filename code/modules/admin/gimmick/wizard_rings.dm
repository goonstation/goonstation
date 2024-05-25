/obj/item/clothing/gloves/ring/wizard
	name = "wizard ring"
	desc = "Parent object for wizardry rings, you shouldn't see this..."
	icon = 'icons/obj/clothing/item_wizard_rings.dmi'
	icon_state = "ring"
	item_state = "ring"
	burn_possible = FALSE
	magical = 1
	var/ability_path = null			//The ability that this ring is linked to.	//When it's null it's either soulguard or the parent. I'm lazy.
	var/last_cast = 0

	get_desc()
		//only works after you've removed the ring. I don't care enough to make examining it while you're wearing it work. The ability button already has that value.
		if (src.last_cast > world.time)
			. += "Its ability is on cooldown for [round((src.last_cast - world.time) / 10)] seconds."

	equipped(var/mob/user, var/slot)
		..()
		if (istype(user.abilityHolder))
			var/datum/targetable/ability = user.abilityHolder.addAbility(ability_path)
			if (istype(ability))
				ability.last_cast = last_cast

	unequipped(var/mob/user)
		..()
		if (ability_path && istype(user.abilityHolder))

			var/datum/targetable/ability = user.abilityHolder.getAbility(ability_path)
			if (istype(ability))
				src.last_cast = ability.last_cast
			user.abilityHolder.removeAbility(ability_path)
			if (istype(user.abilityHolder, /datum/abilityHolder/wizard))
				user.abilityHolder = null
			else if (istype(user.abilityHolder, /datum/abilityHolder/composite))
				var/datum/abilityHolder/composite/CH = user.abilityHolder
				CH.removeHolder(/datum/abilityHolder/wizard)

	fireball
		name = "ring of fireball"
		desc = "The jewel set in this ring appears to have a flame burning violently."
		icon_state = "fireball"
		ability_path = /datum/targetable/spell/fireball

	magic_missile
		name = "ring of magic missile"
		desc = "The jewel set in this ring is bubbling with pink magical energy ."
		icon_state = "magic_missile"
		ability_path = /datum/targetable/spell/magicmissile

	knock
		name = "ring of knock"
		desc = "Looking at this ring makes you feel like you could go anywhere."
		icon_state = "knock"
		ability_path = /datum/targetable/spell/knock

	blind
		name = "ring of blind"
		desc = "The eyeball on this ring is staring at you."
		icon_state = "blind"
		ability_path = /datum/targetable/spell/blind

	empower
		name = "ring of empower"
		desc = "The red carvings on this ring seem to vibrate."
		icon_state = "empower"
		ability_path = /datum/targetable/spell/mutate

		unequipped(var/mob/user)
			..()
			if (user?.bioHolder.RemoveEffect("hulk"))
				boutput(user, SPAN_ALERT("<b>Removing [src] removes its powers with it!</b>"))
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_PASSIVE_WRESTLE, "empower")
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_STAMINA_REGEN_BONUS, "empower")

	staff
		name = "ring of cthulhu"
		desc = "Looking at this ring makes your head hurt."
		icon_state = "staff"
		ability_path = /datum/targetable/spell/summon_staff
		var/obj/item/staff/cthulhu/created_staff

		equipped(var/mob/user, var/slot)
			..()

			//can only make one staff per ring. Anyone who equips the ring claims the staff
			if (!created_staff)
				var/obj/item/staff/cthulhu/staff = new /obj/item/staff/cthulhu(get_turf(user))
				created_staff = staff

			if (created_staff?.wizard_key != user?.mind.key && !isvirtual(user))
				boutput(user, SPAN_NOTICE("<b>You claim [created_staff] as your own!</b>"))
				created_staff.wizard_key = user?.mind.key

		disposing()
			created_staff = null
			..()

	staff_thunder
		name = "ring of thunder"
		desc = "Little arcs of electricity run along the outside of this ring."
		icon_state = "stave_of_thunder"
		ability_path = /datum/targetable/spell/summon_thunder_staff
		var/obj/item/staff/thunder/created_staff

		equipped(var/mob/user, var/slot)
			..()

			if (!created_staff)
				var/obj/item/staff/thunder/staff = new /obj/item/staff/thunder(get_turf(user))
				created_staff = staff

			if (created_staff?.wizard_key != user?.mind.key && !isvirtual(user))
				boutput(user, SPAN_NOTICE("<b>You claim [created_staff] as your own!</b>"))
				created_staff.wizard_key = user?.mind.key

		disposing()
			created_staff = null
			..()

	phase_shift
		name = "ring of phase shift"
		desc = "The jewel set in this ring looks like it has raining water inside."
		icon_state = "phase_shift"
		ability_path = /datum/targetable/spell/phaseshift

	clairvoyance
		name = "ring of clairvoyance"
		desc = "Looking at this ring makes you feel smarter than everyone else."
		icon_state = "clairvoyance"
		ability_path = /datum/targetable/spell/clairvoyance

	// candy_ring	//????
	// 	name = "ring of candy_ring"
	// 	desc = ""
	// 	icon_state = "candy_ring"
	// 	ability_path = /datum/targetable/spell/candy_ring

	ice_burst
		name = "ring of ice burst"
		desc = "This ring feels wet and cold."
		icon_state = "ice_burst"
		ability_path = /datum/targetable/spell/iceburst

	prismatic_spray
		name = "ring of prismatic_spray"
		desc = "The crystal on this ring hums quietly."
		icon_state = "prismatic_spray"
		ability_path = /datum/targetable/spell/prismatic_spray

	animate_dead
		name = "ring of animate dead"
		desc = "The skull on this ring appears to move when you aren't looking."
		icon_state = "animate_dead"
		ability_path = /datum/targetable/spell/animatedead

	cluwne
		name = "ring of cluwne"
		desc = "This ring feels greasy."
		icon_state = "cluwne"
		ability_path = /datum/targetable/spell/cluwne

	teleport
		name = "ring of teleport"
		desc = "The gemstones encrusted into this ring appear to swap places with each other."
		icon_state = "teleport"
		ability_path = /datum/targetable/spell/teleport

	blink
		name = "ring of blink"
		desc = "The gemstones encrusted into this ring are filled with moving dust particles."
		icon_state = "blink"
		ability_path = /datum/targetable/spell/blink

	shocking_touch
		name = "ring of shocking touch"
		desc = "This ring feels like static."
		icon_state = "shocking_touch"
		ability_path = /datum/targetable/spell/shock

	// shocking_grasp
	// 	name = "ring of shocking grasp"
	// 	desc = ""
	// 	icon_state = "// shocking_grasp"
	// 	ability_path = /datum/targetable/spell/kill

	rathens_secret
		name = "ring of rathens secret"
		desc = "This ring smells bad."
		icon_state = "rathens_secret"
		ability_path = /datum/targetable/spell/rathens

	// shockwave
	// 	name = "ring of rathens shockwave"
	// 	desc = ""
	// 	icon_state = "// shockwave"
	// 	ability_path = /datum/targetable/spell/shockwave

	spell_shield
		name = "ring of protection"
		desc = "The jewel in this ring has a small field around it."
		icon_state = "spell_shield"
		ability_path = /datum/targetable/spell/magshield

	warp
		name = "ring of warp"
		desc = "The jewel set in this ring looks like it's moving, somehow."
		icon_state = "warp"
		ability_path = /datum/targetable/spell/warp

	forcewall
		name = "ring of forcewall"
		desc = "The colorful cube on this ring seems to repel matter around it."
		icon_state = "forcewall"
		ability_path = /datum/targetable/spell/forcewall

	doppelganger
		name = "ring of doppelganger"
		desc = "Inside the jewels on this ring, you see yourself inspecting the jewels on this ring."
		icon_state = "doppelganger"
		ability_path = /datum/targetable/spell/doppelganger

	polymorph
		name = "ring of polymorph"
		desc = "The texture of this ring appears to change periodically."
		icon_state = "polymorph"
		ability_path = /datum/targetable/spell/animal

	bull_charge
		name = "ring of the charging bull"
		desc = "The bull on this ring appears to be breathing."
		icon_state = "bull_charge"
		ability_path = /datum/targetable/spell/bullcharge

	pandemonium
		name = "ring of pandemonium"
		desc = "Looking at this ring makes you feel confused."
		icon_state = "pandemonium"
		ability_path = /datum/targetable/spell/pandemonium

	golem
		name = "ring of golem"
		desc = "The jewel set in this ring appears to be filled with a liquid."
		icon_state = "golem"
		ability_path = /datum/targetable/spell/golem

	sticks_to_snakes
		name = "ring of sticks to snakes"
		desc = "This ring occasionally makes rattling noises."
		icon_state = "sticks_to_snakes"
		ability_path = /datum/targetable/spell/stickstosnakes

	soulguard
		name = "ring of soulguard"
		desc = "Looking at the jewel of this ring makes you feel safe."
		icon_state = "soulguard"
		ability_path = null

		equipped(var/mob/user, var/slot)
			..()
			if (isliving(user))
				var/mob/living/L = user
				L.spell_soulguard = SOULGUARD_RING

		unequipped(var/mob/user)
			..()
			if (isliving(user))
				var/mob/living/L = user
				L.spell_soulguard = SOULGUARD_INACTIVE

//random rings
/obj/wizard_ring_generator
	mouse_opacity = 0

	var/list/possible_rings = null	//instead of picking from all spell types, pick from this list of spells to make the ring. should be the lowest level path name of the ring

	New()
		..()

		var/path
		if (possible_rings)
			var/ring_type = pick(possible_rings)
			path = text2path("/obj/item/clothing/gloves/ring/wizard/[ring_type]")
		else
			path = pick(typesof(/obj/item/clothing/gloves/ring/wizard) - /obj/item/clothing/gloves/ring/wizard)

		new path(src.loc)
		possible_rings = null
		//Need the spawn for it to work with the admin spawn menu properly
		SPAWN(1 SECOND)
			qdel(src)

	offensive
		possible_rings = list("fireball", "magic_missile", "blind", "ice_burst", "prismatic_spray", "cluwne", "shocking_touch", "rathens_secret", "pandemonium", "sticks_to_snakes", "staff", "golem", "polymorph")

		less_deadly
			possible_rings = list("fireball", "magic_missile", "blind", "ice_burst", "prismatic_spray", "pandemonium", "sticks_to_snakes", "golem")
	defensive
		possible_rings = list("phase_shift", "teleport", "blink", "spell_shield", "warp", "forcewall", "pandemonium", "doppelganger", "soulguard")
	utility
		possible_rings = list("knock", "empower", "phase_shift", "clairvoyance", "animate_dead", "teleport", "pandemonium", "sticks_to_snakes", "soulguard")
	less_deadly
		possible_rings = list("fireball", "magic_missile", "knock", "blind", "empower", "phase_shift", "clairvoyance", "ice_burst", "prismatic_spray", "animate_dead", "teleport", "blink", "rathens_secret", "spell_shield", "warp", "forcewall", "pandemonium", "bull_charge", "sticks_to_snakes", "doppelganger", "soulguard")

/client/proc/create_all_wizard_rings()
	set name = "Create All Wizard Rings"
	set desc = "Spawn all of the magical wizard rings."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC
	if (alert(usr, "Are you sure you want to spawn all wizard rings at your current location?", "Spawn rings", "Yes", "No, I misclicked") == "No, I misclicked")
		return
	var/turf/T_LOC = get_turf(src.mob)

	var/list/L = concrete_typesof(/obj/item/clothing/gloves/ring/wizard)
	var/index = 1
	for (var/turf/T in range(T_LOC, 3))
		if (index <= L.len)
			var/path = L[index]
			if (ispath(path))
				new path(T)
				index++
		else break
