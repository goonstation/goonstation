#define POWER_CELL_DRAIN_RATE 80
#define POWER_CELL_CHARGE_PERCENT_MINIMUM 10
#define SMES_DRAIN_RATE 100000
#define SAP_LIMIT_APC 30
#define SAP_LIMIT_MACHINE (SAP_LIMIT_APC - 5)
#define SAP_LIMIT_MOB (SAP_LIMIT_APC + 10)

/**
 * Sap Power
 * Arcfiend's main method of obtaining electricity for their abilities.
 * Also very deadly to humans and cyborgs.
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
			boutput(holder.owner, "<span class='notice'>You try to drain power from [src.holder.owner.loc], but some idiot is in the way!</span>")
			return
		if (!(BOUNDS_DIST(src.holder.owner, target) == 0))
			return TRUE
		if (isnpc(target))
			boutput(src.holder.owner, "<span class='alert'>This creature lacks sufficient energy to consume.")
			return
		if (ishuman(target) || issilicon(target) || istype(target, /obj/machinery))
			src.holder.owner.tri_message(target, 
				"<span class='alert'>[src.holder.owner] places [his_or_her(target)] hand on [target]. A static charge fills the air.",
				"<span class='alert'>You place your hand onto [target] and start draining [ismob(target) ? him_or_her(target) : "it"] of energy.</span>",
				"<span class='alert'>[src.holder.owner] places [his_or_her(src.holder.owner)] hand onto you.</span>")
			actions.start(new/datum/action/bar/private/icon/sap_power(src.holder.owner, target, holder), src.holder.owner)
			logTheThing("combat", src.holder.owner, target, "[key_name(src.holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(src.holder.owner)].")

	castcheck()
		. = ..()
		if (src.holder.owner.restrained())
			boutput(src.holder.owner, "<span class='alert'>You need an active working hand to sap power from things!</span>")
			return FALSE


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
		src.user.UpdateParticles(new/particles/arcfiend, "arcfiend")
		P = src.user.GetParticles("arcfiend")

	onUpdate()
		..()
		if(!(BOUNDS_DIST(src.user, src.target) == 0))
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		P.spawning = initial(P.spawning)
		if(!(BOUNDS_DIST(src.user, src.target) == 0))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.loopStart()

	onInterrupt(flag)
		P.spawning = 0
		. = ..()

	onEnd()
		if(!(BOUNDS_DIST(src.user, src.target) == 0))
			..()
			interrupt(INTERRUPT_ALWAYS)

		if (ishuman(src.target))
			var/mob/living/carbon/human/H = src.target
			if (isdead(H))
				boutput(src.holder.owner, "<span class='alert'>[src.target] is dead, and can provide no usable energy.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			if (!src.scary_message)
				H.visible_message("<span class='alert'>[H] starts convulsing violently!</span>", "<span class='alert'>You feel a sharp pain in your chest!</span>")
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

			if (points_gained == 0)
				boutput(src.holder.owner, "<span class='alert'>[src.target] doesn't have enough energy for you to absorb!</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			holder.addPoints(points_gained)
			// drain is proportional to points gained
			target_apc?.cell.use(POWER_CELL_DRAIN_RATE * (points_gained / SAP_LIMIT_APC))
		if (prob(35))
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(2, FALSE, src.holder.owner)
			s.start()

		playsound(owner.loc, "sound/effects/electric_shock_short.ogg", 30, TRUE, FALSE, pitch = 0.8)
		src.holder.owner.set_dir(get_dir(src.holder.owner, src.target))
		src.target.add_fingerprint(holder.owner)
		src.onRestart()

#undef POWER_CELL_DRAIN_RATE
#undef POWER_CELL_CHARGE_PERCENT_MINIMUM
#undef SMES_DRAIN_RATE
#undef SAP_LIMIT_APC
#undef SAP_LIMIT_MACHINE
#undef SAP_LIMIT_MOB
