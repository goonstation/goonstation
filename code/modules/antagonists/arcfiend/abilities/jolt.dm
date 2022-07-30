/**
 * Jolt
 * Killing skill, also decent damage even if you don't finish. The final tick induces cardiac arrest.
 */
/datum/targetable/arcfiend/jolt
	name = "Jolt"
	desc = "Release a series of powerful jolts into your target, burning them and eventually stopping their heart. When used on those resistant to electricity, it can restart their heart instead."
	icon_state = "jolt"
	cooldown = 2 MINUTES
	pointCost = 500
	targeted = TRUE
	target_anything = TRUE

	/// Each individual shock will use this much wattage.
	var/wattage = 2.6 KILO WATTS

	cast(atom/target)
		. = ..()
		if (!(BOUNDS_DIST(holder.owner, target) == 0))
			return TRUE
		if (ishuman(target))
			if (target == holder.owner)
				self_cast(target)
				return
			actions.start(new/datum/action/bar/private/icon/jolt(holder.owner, target, holder, wattage), holder.owner)
			logTheThing("combat", holder.owner, target, "[key_name(holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(holder.owner)].")
		else
			return TRUE

	proc/self_cast(mob/living/carbon/human/self)
		if (self.find_ailment_by_type(/datum/ailment/malady/flatline))
			boutput(self, "<span class='alert'>You feel your heart jolt back into motion!</span>")
		else
			boutput(self, "<span class='alert'>You feel a powerful jolt course through you!</span>")
		playsound(self, 'sound/effects/elec_bigzap.ogg', 30, 1)
		self.cure_disease_by_path(/datum/ailment/malady/flatline)
		self.TakeDamage("chest", 0, 30, 0, DAMAGE_BURN)
		self.take_oxygen_deprivation(-100)
		self.changeStatus("paralysis", 5 SECONDS)
		self.force_laydown_standup()

/datum/action/bar/private/icon/jolt
	duration = 18 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION | INTERRUPT_ACT
	id = "jolt"
	icon = 'icons/mob/arcfiend.dmi'
	icon_state = "jolt_icon"
	var/mob/living/user
	var/mob/living/target
	var/datum/abilityHolder/holder
	var/wattage = 0
	var/particles/P

	New(user, target, holder, wattage)
		. = ..()
		src.user = user
		src.target = target
		src.holder = holder
		src.wattage = wattage
		src.user.UpdateParticles(new/particles/arcfiend, "arcfiend")
		P = src.user.GetParticles("arcfiend")

	onUpdate(timePassed)
		..()
		if(!(BOUNDS_DIST(src.user, src.target) == 0))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!ON_COOLDOWN(src.owner, "jolt", 1 SECOND))
			playsound(src.holder.owner, "sound/effects/elec_bzzz.ogg", 25, TRUE)
			src.target.shock(src.user, wattage, ignore_gloves = TRUE)
			if (src.target.bioHolder?.HasEffect("resist_electric"))
				if (prob(20))
					cure_arrest()
			else //prevent the arcfiend from hurting their heart while shocking it
				src.target.organHolder.damage_organ(0, 4, 0, "heart")
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(5, FALSE, src.target)
			s.start()
			src.owner.set_dir(get_dir(src.owner, src.target))

	onStart()
		..()
		P.spawning = initial(P.spawning)
		if(!(BOUNDS_DIST(src.user, src.target) == 0))
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(flag)
		P.spawning = 0
		..()

	onEnd()
		boutput(src.user, "<span class='alert'>You send a massive electrical surge through [src.target]'s body!</span>")
		P.spawning = 0
		src.target.add_fingerprint(src.user)
		if (!src.target.bioHolder?.HasEffect("resist_electric"))
			boutput(src.target, "<span class='alert'><b>Your heart spasms painfully and stops beating!</b></span>")
			src.target.contract_disease(/datum/ailment/malady/flatline, null, null, TRUE)
		else
			cure_arrest()
		..()

	proc/cure_arrest()
		if (src.target.find_ailment_by_type(/datum/ailment/malady/flatline))
			boutput(src.target, "<span class='alert'>You feel your heart jolt back into motion!</span>")
		src.target.cure_disease_by_path(/datum/ailment/malady/flatline)
		src.target.cure_disease_by_path(/datum/ailment/malady/heartfailure)
