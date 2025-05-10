/**
 * Killing skill that does decent damage even when it doesn't finish.
 * The final tick stops the target's heart (or can restart it if they have SMES human.)
 * Use time is instant if the user jolts themselves.
 */
/datum/targetable/arcfiend/jolt
	name = "Jolt"
	desc = "Release a series of powerful jolts into your target over time, burning them and eventually stopping their heart. \
		When used on those resistant to electricity, it can restart their heart instead.<br><br>\
		Self-use is instantaneous, but burns you badly."
	icon_state = "jolt"
	cooldown = 2 MINUTES
	pointCost = 200
	targeted = TRUE
	target_anything = TRUE

	/// Each individual shock will use this much wattage.
	var/wattage = 2.6 KILO WATTS

	tryCast(atom/target, params)
		if (!(BOUNDS_DIST(src.holder.owner, target) == 0))
			boutput(src.holder.owner, SPAN_ALERT("That is too far away!"))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (!ishuman(target))
			boutput(src.holder.owner, SPAN_ALERT("You can only use this on humans!"))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		return ..()

	cast(atom/target)
		. = ..()
		if (target == src.holder.owner)
			self_cast(target)
			return CAST_ATTEMPT_SUCCESS
		actions.start(new/datum/action/bar/private/icon/jolt(src.holder.owner, target, src.holder, src.wattage), src.holder.owner)

	proc/self_cast(mob/living/carbon/human/H)
		boutput(H, SPAN_ALERT("You send a massive electrical surge through yourself!"))
		if (H.find_ailment_by_type(/datum/ailment/malady/flatline))
			boutput(H, SPAN_NOTICE("You inhale deeply as your heart starts beating again!"))
		playsound(H, 'sound/effects/elec_bigzap.ogg', 30, TRUE)
		H.cure_disease_by_path(/datum/ailment/malady/flatline)
		H.TakeDamage("chest", 0, 30, 0, DAMAGE_BURN)
		H.take_oxygen_deprivation(-100)
		H.changeStatus("unconscious", 5 SECONDS)
		H.force_laydown_standup()

/datum/action/bar/private/icon/jolt
	duration = 12 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ACT
	icon = 'icons/mob/arcfiend.dmi'
	icon_state = "jolt_icon"

	var/mob/living/user
	var/mob/living/target
	var/datum/abilityHolder/holder
	var/particles/particles

	/// Wattage for each shock. This is inherited from the parent ability in New().
	var/wattage = 0

	New(user, target, holder, wattage)
		. = ..()
		src.user = user
		src.target = target
		src.holder = holder
		src.wattage = wattage
		src.user.UpdateParticles(new/particles/arcfiend, "arcfiend")
		src.particles = src.user.GetParticles("arcfiend")

	onUpdate(timePassed)
		..()
		if (!(BOUNDS_DIST(src.user, src.target) == 0))
			src.interrupt(INTERRUPT_ALWAYS)
			return
		if (!ON_COOLDOWN(src.owner, "jolt", 1 SECOND))
			playsound(src.holder.owner, 'sound/effects/elec_bzzz.ogg', 25, TRUE)
			src.target.shock(src.user, wattage, ignore_gloves = TRUE)
			if (src.target.bioHolder?.HasEffect("resist_electric"))
				if (prob(20))
					cure_arrest()
			else
				src.target.organHolder.damage_organ(0, 4, 0, "heart")
			var/datum/effects/system/spark_spread/S = new /datum/effects/system/spark_spread
			S.set_up(5, FALSE, src.target)
			S.start()
			src.owner.set_dir(get_dir(src.owner, src.target))

		if (!ON_COOLDOWN(src.owner, "jolt_arc", 2 SECONDS))
			var/list/targets = list()
			for (var/mob/living/M in range(4, src.owner))
				if (M != src.target && M != src.owner)
					targets += M
			if (!length(targets)) //no mobs, pick a turf instead
				for (var/turf/T in range(3, src.owner))
					targets += T
			if (length(targets))
				var/atom/target = pick(targets)
				arcFlash(src.owner, target, 200 KILO WATTS) // 1/3 of the arcflash ability

	onStart()
		..()
		src.particles.spawning = initial(src.particles.spawning)
		if (!(BOUNDS_DIST(src.user, src.target) == 0))
			src.interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(flag)
		src.particles.spawning = FALSE
		..()

	onEnd()
		boutput(src.user, SPAN_ALERT("You send a massive electrical surge through [src.target]'s body!"))
		playsound(src.target, 'sound/impact_sounds/Energy_Hit_3.ogg', 100)
		playsound(src.target, 'sound/effects/elec_bzzz.ogg', 25, TRUE)
		src.target.emote("twitch_v")
		src.particles.spawning = FALSE
		src.target.add_fingerprint(src.user)
		if (!src.target.bioHolder?.HasEffect("resist_electric"))
			boutput(src.target, SPAN_ALERT("<b>Your heart spasms painfully and stops beating!</b>"))
			src.target.contract_disease(/datum/ailment/malady/flatline, null, null, TRUE)
			var/datum/abilityHolder/arcfiend/AH = src.holder
			AH.hearts_stopped++
		else
			cure_arrest()
		..()

	proc/cure_arrest()
		if (src.target.find_ailment_by_type(/datum/ailment/malady/flatline))
			boutput(src.target, SPAN_NOTICE("Your heart starts beating again!"))
		src.target.cure_disease_by_path(/datum/ailment/malady/flatline)
		src.target.cure_disease_by_path(/datum/ailment/malady/heartfailure)
