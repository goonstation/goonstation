/obj/item/artifact/healing_wand
	name = "artifact healing wand"
	artifact = 1
	associated_datum = /datum/artifact/healing_wand
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

/datum/artifact/healing_wand
	associated_object = /obj/item/artifact/healing_wand
	type_name = "Healing Wand"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 100
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	react_xray = list(10,60,92,14,"COMPLEX")
	var/heal_amt = 20
	var/recharge_time = 60 SECONDS
	var/recharging = FALSE
	var/canhealself = FALSE
	var/sound/healsound = null
	examine_hint = "It seems to have a handle you're supposed to hold it by."
	shard_reward = ARTIFACT_SHARD_POWER
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE

	New()
		..()
		if(prob(10)) // very rarely can self heal
			src.canhealself = TRUE
		if(prob(10) && !src.canhealself) // i dont mind some rare good artifacts, but I dont want god tier self healing artifacts
			src.heal_amt = rand(15,40)
		else
			src.heal_amt = rand(5,15)
		src.recharge_time = rand(5, 20) SECONDS
		if(prob(1) && !src.canhealself)
			src.recharge_time = 1 SECOND
		src.healsound = pick('sound/effects/bamf.ogg','sound/effects/electric_shock_short.ogg','sound/effects/flame.ogg','sound/effects/ghost2.ogg','sound/effects/glare.ogg','sound/effects/gust.ogg',
		'sound/effects/heartbeat.ogg','sound/effects/leakoxygen.ogg','sound/effects/power_charge.ogg','sound/effects/poof.ogg','sound/effects/singsuck.ogg','sound/effects/syringeproj.ogg','sound/effects/thump.ogg',
		'sound/effects/toilet_flush.ogg','sound/effects/warp2.ogg') // sounds chosen mostly at random but also sounds that will make nerds jump

	effect_melee_attack(var/obj/O,var/mob/living/user,var/mob/living/target)
		if (..())
			return
		if (!user)
			return
		if (target == user && !src.canhealself)
			boutput(user, SPAN_ALERT("The artifact makes a strange fizzling noise, but nothing else happens."))
			return
		if (recharging)
			boutput(user, SPAN_ALERT("The artifact pulses briefly, but nothing else happens."))
			return
		if (recharge_time > 0)
			recharging = TRUE
		var/turf/T = get_turf(O)
		T.visible_message("<b>[O]</b> emits a wave of energy!")
		if(iscarbon(user))
			var/mob/living/carbon/C = target
			C.HealDamage("All", heal_amt, heal_amt)
			O.ArtifactFaultUsed(C)
			boutput(C, SPAN_NOTICE("Soothing energy saturates your body, making you feel refreshed and healthy."))
			playsound(O.loc, src.healsound, 50, 1, -1)
			logTheThing(LOG_COMBAT, user, "heals [target] ([log_loc(target)]) with \the [src] healing wand artifact at [log_loc(user)] ([src.heal_amt] damage healed).")
		SPAWN(recharge_time)
			recharging = FALSE
			T.visible_message("<b>[O]</b> becomes energized.")
