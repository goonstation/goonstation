/obj/item/clothing/gloves/ring/wizard
	name = "wizard ring"
	desc = "Parent object for wizadry rings, you shouldn't see this..."
	icon_state = "ring"
	item_state = "ring"
	burn_possible = 0
	var/ability_path = null			//The ability that this ring is linked to.	//When it's null it's either soulguard or the parent. I'm lazy.

	equipped(var/mob/user, var/slot)
		..()
		if (istype(user.abilityHolder))
			user.abilityHolder.addAbility(ability_path)

	unequipped(var/mob/user)
		..()
		if (ability_path && istype(user.abilityHolder))
			user.abilityHolder.removeAbility(ability_path)
			if (istype(user.abilityHolder, /datum/abilityHolder/wizard))
				user.abilityHolder = null
			else if (istype(user.abilityHolder, /datum/abilityHolder/composite))
				var/datum/abilityHolder/composite/CH = user.abilityHolder
				CH.removeHolder(/datum/abilityHolder/wizard)

	fireball
		name = "ring of fireball"
		desc = ""
		icon_state = "fireball"
		ability_path = /datum/targetable/spell/fireball

	magic_missile
		name = "ring of magic missile"
		desc = ""
		icon_state = "magic_missile"
		ability_path = /datum/targetable/spell/magicmissile

	knock
		name = "ring of knock"
		desc = ""
		icon_state = "knock"
		ability_path = /datum/targetable/spell/knock

	blind
		name = "ring of blind"
		desc = ""
		icon_state = "blind"
		ability_path = /datum/targetable/spell/blind

	empower
		name = "ring of empower"
		desc = ""
		icon_state = "empower"
		ability_path = /datum/targetable/spell/mutate

	staff
		name = "ring of cthulhu"
		desc = ""
		icon_state = "staff"
		ability_path = /datum/targetable/spell/summon_staff

	phase_shift
		name = "ring of phase shift"
		desc = ""
		icon_state = "phase_shift"
		ability_path = /datum/targetable/spell/phaseshift

	clairvoyance
		name = "ring of clairvoyance"
		desc = ""
		icon_state = "clairvoyance"
		ability_path = /datum/targetable/spell/clairvoyance

	// candy_ring	//????
	// 	name = "ring of candy_ring"
	// 	desc = ""
	// 	icon_state = "candy_ring"
	// 	ability_path = /datum/targetable/spell/candy_ring

	ice_burst
		name = "ring of ice burst"
		desc = ""
		icon_state = "ice_burst"
		ability_path = /datum/targetable/spell/iceburst

	prismatic_spray
		name = "ring of prismatic_spray"
		desc = ""
		icon_state = "prismatic_spray"
		ability_path = /datum/targetable/spell/prismatic_spray

	animate_dead
		name = "ring of animate dead"
		desc = ""
		icon_state = "animate_dead"
		ability_path = /datum/targetable/spell/animatedead

	cluwne
		name = "ring of cluwne"
		desc = ""
		icon_state = "cluwne"
		ability_path = /datum/targetable/spell/cluwne

	teleport
		name = "ring of teleport"
		desc = ""
		icon_state = "teleport"
		ability_path = /datum/targetable/spell/teleport

	blink
		name = "ring of blink"
		desc = ""
		icon_state = "blink"
		ability_path = /datum/targetable/spell/blink

	shocking_touch
		name = "ring of shocking touch"
		desc = ""
		icon_state = "shocking_touch"
		ability_path = /datum/targetable/spell/shock

	// shocking_grasp
	// 	name = "ring of shocking grasp"
	// 	desc = ""
	// 	icon_state = "// shocking_grasp"
	// 	ability_path = /datum/targetable/spell/kill

	rathens_secret
		name = "ring of rathens secret"
		desc = ""
		icon_state = "rathens_secret"
		ability_path = /datum/targetable/spell/rathens

	// shockwave
	// 	name = "ring of rathens shockwave"
	// 	desc = ""
	// 	icon_state = "// shockwave"
	// 	ability_path = /datum/targetable/spell/shockwave

	spell_sheild
		name = "ring of protection"
		desc = ""
		icon_state = "spell_sheild"
		ability_path = /datum/targetable/spell/magshield

	warp
		name = "ring of warp"
		desc = ""
		icon_state = "warp"
		ability_path = /datum/targetable/spell/warp

	forcewall
		name = "ring of forcewall"
		desc = ""
		icon_state = "forcewall"
		ability_path = /datum/targetable/spell/forcewall

	doppelganger
		name = "ring of doppelganger"
		desc = ""
		icon_state = "doppelganger"
		ability_path = /datum/targetable/spell/doppelganger

	polymorph
		name = "ring of polymorph"
		desc = ""
		icon_state = "polymorph"
		ability_path = /datum/targetable/spell/animal

	bullcharge
		name = "ring of the charging bull"
		desc = ""
		icon_state = "bullcharge"
		ability_path = /datum/targetable/spell/bullcharge

	pandemonium
		name = "ring of pandemonium"
		desc = ""
		icon_state = "pandemonium"
		ability_path = /datum/targetable/spell/pandemonium

	golem
		name = "ring of golem"
		desc = ""
		icon_state = "golem"
		ability_path = /datum/targetable/spell/golem

	sticks_to_snakes
		name = "ring of sticks to snakes"
		desc = ""
		icon_state = "sticks_to_snakes"
		ability_path = /datum/targetable/spell/stickstosnakes

	soulguard
		name = "ring of soulguard"
		desc = ""
		icon_state = "soulguard"
		ability_path = null

		equipped(var/mob/user, var/slot)
			..()
			if (isliving(user))
				var/mob/living/L = user
				L.spell_soulguard = 1

		unequipped(var/mob/user)
			..()
			if (isliving(user))
				var/mob/living/L = user
				L.spell_soulguard = 0

	random_type
		//Doesn't have these spells. no ring for em: kill, shockwave, and candy_ring. (last one isn't actually a spell)

		New()
			var/list/L = list(/datum/targetable/spell/fireball,/datum/targetable/spell/magicmissile,/datum/targetable/spell/knock,/datum/targetable/spell/blind,/datum/targetable/spell/mutate,/datum/targetable/spell/summon_staff,/datum/targetable/spell/phaseshift,/datum/targetable/spell/clairvoyance,/datum/targetable/spell/iceburst,/datum/targetable/spell/prismatic_spray,/datum/targetable/spell/animatedead,/datum/targetable/spell/cluwne,/datum/targetable/spell/teleport,/datum/targetable/spell/blink,/datum/targetable/spell/shock,/datum/targetable/spell/rathens,/datum/targetable/spell/magshield,/datum/targetable/spell/warp,/datum/targetable/spell/forcewall,/datum/targetable/spell/doppelganger,/datum/targetable/spell/animal,/datum/targetable/spell/bullcharge,/datum/targetable/spell/pandemonium,/datum/targetable/spell/golem,/datum/targetable/spell/stickstosnakes,null)
			ability_path = pick(L)
			..()
