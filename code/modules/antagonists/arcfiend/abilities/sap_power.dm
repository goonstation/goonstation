#define POWER_CELL_DRAIN_RATE 80 WATTS
#define POWER_CELL_CHARGE_PERCENT_MINIMUM 10
#define SMES_DRAIN_RATE 100 KILO WATTS
#define SAP_LIMIT_APC 30 WATTS
#define SAP_LIMIT_MACHINE (SAP_LIMIT_APC - 5)
#define SAP_LIMIT_MOB (SAP_LIMIT_APC + 10)

/**
 * Arcfiend's main way of obtaining power for their abilities.
 * Can be used on:
 * - Machines (drains from the area APC's cell)
 * - APCs (drains from the cell, 1% chance per tick to break the APC)
 * - SMES units (drains from internal charge)
 * - Humans (quickly saps stamina, causes burn damage)
 * - Cyborgs (drains from the power cell, causes burn damage)
 */
/datum/targetable/arcfiend/sap_power
	name = "Sap Power"
	desc = "Drain power from a target person or machine."
	cooldown = 0
	target_anything = TRUE
	targeted = TRUE
	icon_state = "sap"

	cast(atom/target)
		. = ..()
		if (target == src.holder.owner)
			return TRUE
		if (!(BOUNDS_DIST(src.holder.owner, target) == 0))
			return TRUE
		if (!src.is_valid_target(target, src.holder.owner))
			return TRUE
		src.holder.owner.tri_message(target,
			"<span class='alert'>[src.holder.owner] places [his_or_her(src.holder.owner)] hand on [target]. A static charge fills the air.",
			"<span class='alert'>You place your hand onto [target] and start draining [ismob(target) ? him_or_her(target) : "it"] of energy.</span>",
			"<span class='alert'>[src.holder.owner] places [his_or_her(src.holder.owner)] hand onto you.</span>")
		actions.start(new/datum/action/bar/private/icon/sap_power(src.holder.owner, target, holder), src.holder.owner)
		logTheThing(LOG_COMBAT, src.holder.owner, "[key_name(src.holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(src.holder.owner)].")

	castcheck()
		. = ..()
		if (src.holder.owner.restrained())
			boutput(src.holder.owner, "<span class='alert'>You need an active working hand to sap power from things!</span>")
			return FALSE

	proc/is_valid_target(atom/target, mob/user)
		if (ismob(target))
			var/mob/M = target
			if (isnpc(M))
				boutput(user, "<span class='alert'>[M] lacks sufficient energy to consume.</span>")
				return FALSE
			else if (isdead(M))
				boutput(user, "<span class='alert'>[M] is dead, and can provide no usable energy.</span>")
				return FALSE
			else if (issilicon(M))
				var/mob/living/silicon/S = M
				if ((S.cell?.charge < POWER_CELL_DRAIN_RATE))
					boutput(user, "<span class='alert'>[S]'s power cell is completely drained.</span>")
					return FALSE
		return ishuman(target) || issilicon(target) || istype(target, /obj/machinery)


/datum/action/bar/private/icon/sap_power
	duration = 1 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION | INTERRUPT_ACT
	id = "sap_power"
	icon = 'icons/mob/arcfiend.dmi'
	icon_state = "sap_icon"

	var/mob/living/user
	var/atom/movable/target
	var/datum/abilityHolder/holder
	var/particles/P

	/// For mobs being targeted, shows them a spooky message on the first tick of the ability
	var/scary_message = FALSE

	New(user, target, holder)
		. = ..()
		src.user = user
		src.target = target
		src.holder = holder
		P = src.user.GetParticles("arcfiend")
		if (!P) // only needs to be made on the mob once
			src.user.UpdateParticles(new/particles/arcfiend, "arcfiend")
			P = src.user.GetParticles("arcfiend")

	onUpdate()
		..()
		if (!(BOUNDS_DIST(src.user, src.target) == 0))
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		P.spawning = initial(P.spawning)
		if (!(BOUNDS_DIST(src.user, src.target) == 0))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.loopStart()

	onInterrupt(flag)
		P.spawning = 0
		. = ..()

	onEnd()
		if (!(BOUNDS_DIST(src.user, src.target) == 0))
			..()
			interrupt(INTERRUPT_ALWAYS)

		if (ishuman(src.target))
			var/mob/living/carbon/human/H = src.target
			if (isdead(H))
				boutput(src.holder.owner, "<span class='alert'>[src.target] has died, and can no longer provide usable energy.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			if (!src.scary_message)
				H.visible_message("<span class='alert'>[H] spasms violently!</span>", "<span class='alert'>Sharp pains start wracking your chest!</span>")
				src.scary_message = TRUE
			H.TakeDamage("All", 0, 5)
			H.do_disorient(stamina_damage = 50, weakened = 1 SECONDS, disorient = 2 SECOND)
			holder.addPoints(SAP_LIMIT_MOB)

		else if (issilicon(src.target))
			var/mob/living/silicon/S = src.target
			if (isdead(S) || (S.cell?.charge < POWER_CELL_DRAIN_RATE))
				boutput(src.holder.owner, "<span class='alert'>[src.target]'s power cell is completely drained.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			if (!src.scary_message)
				boutput(S, "<span class='alert'>Short circuit detected. Power cell integrity failing.</span>")
				src.scary_message = TRUE
			S.TakeDamage("chest", 3, 0, DAMAGE_BURN)
			S.cell.use(POWER_CELL_DRAIN_RATE)
			holder.addPoints(SAP_LIMIT_MOB)
			S.do_disorient(stamina_damage = 50, weakened = 1 SECONDS, disorient = 2 SECOND)

		else if (istype(src.target, /obj/machinery))
			var/area/A = get_area(src.target)
			var/obj/machinery/power/apc/target_apc = A?.area_apc
			var/points_gained = 0

			if (istype(src.target, /obj/machinery/power))
				if (istype(src.target, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/apc = src.target
					points_gained = SAP_LIMIT_APC
					target_apc = apc // drain the target APC instead of the area's
					if (!target_apc.cell || target_apc.cell.charge <= ((target_apc.cell.maxcharge / POWER_CELL_CHARGE_PERCENT_MINIMUM) + POWER_CELL_DRAIN_RATE)) //not enough power
						boutput(src.holder.owner, "<span class='alert'>[target] doesn't have enough energy for you to absorb!</span>")
						interrupt(INTERRUPT_ALWAYS)
						return
					if (prob(1))
						boutput(src.holder.owner, "<span class'alert'>You feel a brief power surge underneath your hand as the APC fails and shuts down.</span>")
						apc.set_broken()
				else if (istype(src.target, /obj/machinery/power/smes))
					target_apc = null
					var/obj/machinery/power/smes/smes = src.target
					if (smes.charge < SMES_DRAIN_RATE)
						boutput(src.holder.owner, "<span class='alert'>[src.target] doesn't have enough energy for you to absorb!</span>")
						interrupt(INTERRUPT_ALWAYS)
						return
					smes.charge -= SMES_DRAIN_RATE
					points_gained = SAP_LIMIT_APC
			else
				if (!target_apc?.cell || target_apc.cell.charge <= ((target_apc.cell.maxcharge / POWER_CELL_CHARGE_PERCENT_MINIMUM) + POWER_CELL_DRAIN_RATE)) //not enough power
					boutput(src.holder.owner, "<span class='alert'>[src.target] doesn't have enough energy for you to absorb!</span>")
					interrupt(INTERRUPT_ALWAYS)
					return
				var/obj/machinery/M = src.target
				points_gained = clamp(round((M.power_usage * 0.1)), 0, SAP_LIMIT_MACHINE)

			if (!points_gained)
				boutput(src.holder.owner, "<span class='alert'>[src.target] doesn't have enough energy for you to absorb!</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			holder.addPoints(points_gained)
			// drain is proportional to points gained
			target_apc?.cell.use(POWER_CELL_DRAIN_RATE * (points_gained / SAP_LIMIT_APC))

		if (prob(35))
			var/datum/effects/system/spark_spread/S = new /datum/effects/system/spark_spread
			S.set_up(2, FALSE, src.holder.owner)
			S.start()
		playsound(owner.loc, 'sound/effects/electric_shock_short.ogg', 30, TRUE, FALSE, pitch = 0.8)
		src.holder.owner.set_dir(get_dir(src.holder.owner, src.target))
		src.target.add_fingerprint(holder.owner)
		src.onRestart()

#undef POWER_CELL_DRAIN_RATE
#undef POWER_CELL_CHARGE_PERCENT_MINIMUM
#undef SMES_DRAIN_RATE
#undef SAP_LIMIT_APC
#undef SAP_LIMIT_MACHINE
#undef SAP_LIMIT_MOB
