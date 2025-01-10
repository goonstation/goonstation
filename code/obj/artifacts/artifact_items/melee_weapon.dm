/obj/item/artifact/melee_weapon
	name = "artifact melee weapon"
	artifact = 1
	associated_datum = /datum/artifact/melee
	click_delay = COMBAT_CLICK_DELAY

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (A.activated)
			A.effect_melee_attack(src,user,target)
			src.ArtifactFaultUsed(user)
			src.ArtifactFaultUsed(target)
		else
			..()

/datum/artifact/melee
	associated_object = /obj/item/artifact/melee_weapon
	type_name = "Melee Weapon"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 350
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	react_xray = list(14,95,95,7,"DENSE")
	var/damtype = "brute"
	var/dmg_amount = 5
	var/stamina_dmg = 0
	var/sound/hitsound = null
	examine_hint = "It seems to have a handle you're supposed to hold it by."
	shard_reward = ARTIFACT_SHARD_POWER

	New()
		..()
		src.damtype = pick("brute", "fire", "toxin")
		src.dmg_amount = rand(3,6)
		src.dmg_amount *= rand(1,5)
		if (prob(45))
			src.stamina_dmg = rand(50,120)
		src.hitsound = pick('sound/impact_sounds/Metal_Hit_Heavy_1.ogg','sound/impact_sounds/Wood_Hit_1.ogg','sound/effects/exlow.ogg','sound/effects/mag_magmisimpact.ogg','sound/impact_sounds/Energy_Hit_1.ogg',
		'sound/impact_sounds/Generic_Snap_1.ogg','sound/machines/mixer.ogg','sound/impact_sounds/Generic_Hit_Heavy_1.ogg','sound/weapons/ACgun2.ogg','sound/impact_sounds/Energy_Hit_3.ogg','sound/weapons/flashbang.ogg',
		'sound/weapons/grenade.ogg','sound/weapons/railgun.ogg')

	effect_melee_attack(var/obj/O,var/mob/living/user,var/mob/living/target)
		if (..())
			return
		if (!isliving(user) || !isliving(target))
			return
		user.visible_message(SPAN_ALERT("<b>[user.name]</b> attacks [target.name] with [O]!"))
		var/turf/T = get_turf(user)
		playsound(T, hitsound, 50, TRUE, -1)
		switch(damtype)
			if ("brute")
				random_brute_damage(target, dmg_amount,1)
			if ("fire")
				random_burn_damage(target, dmg_amount)
			if ("toxin")
				target.take_toxin_damage(rand(1, dmg_amount))
		if (src.stamina_dmg)
			target.do_disorient(stamina_damage = src.stamina_dmg, knockdown = src.stamina_dmg - 20, disorient = src.stamina_dmg - 40)
