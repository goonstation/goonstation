#define MAX_ARCFIEND_POINTS 2500
#define POWER_CELL_DRAIN_RATE 80
#define POWER_CELL_CHARGE_PERCENT_MINIMUM 10
#define SMES_DRAIN_RATE 100000
#define SAP_LIMIT_APC 30
#define SAP_LIMIT_MACHINE (SAP_LIMIT_APC - 5)
#define SAP_LIMIT_MOB (SAP_LIMIT_APC + 10)

/mob/proc/make_arcfiend()
	if (ishuman(src))
		var/datum/abilityHolder/arcfiend/A = src.get_ability_holder(/datum/abilityHolder/arcfiend)
		if (A && istype(A))
			return
		var/datum/abilityHolder/arcfiend/W = src.add_ability_holder(/datum/abilityHolder/arcfiend)

		W.addAbility(/datum/targetable/arcfiend/sap_power)
		W.addAbility(/datum/targetable/arcfiend/discharge)
		W.addAbility(/datum/targetable/arcfiend/elecflash)
		W.addAbility(/datum/targetable/arcfiend/arcFlash)
		W.addAbility(/datum/targetable/arcfiend/polarize)
		W.addAbility(/datum/targetable/arcfiend/voltron)
		W.addAbility(/datum/targetable/arcfiend/jamming_field)
		W.addAbility(/datum/targetable/arcfiend/jolt)

		src.bioHolder.AddEffect("resist_electric", power = 2, magical = TRUE)
		src.ClearSpecificOverlays("resist_electric") // hide smes effect

		if (src.mind && src.mind.special_role != ROLE_OMNITRAITOR)
			SHOW_ARCFIEND_TIPS(src)


/datum/abilityHolder/arcfiend
	usesPoints = 1
	regenRate = 0
	tabName = "Arcfiend"
	var/lifetime_energy = 0

	onAbilityStat()
		..()
		if (src.owner?.mind?.special_role == ROLE_ARCFIEND)
			. = list()
			.["Energy:"] = round(points)
			.["Total:"] = round(lifetime_energy)

	addPoints(add_points, target_ah_type = src.type)
		src.lifetime_energy += add_points
		var/points = min((MAX_ARCFIEND_POINTS - src.points), add_points)
		. = ..(points, target_ah_type)

ABSTRACT_TYPE(/datum/targetable/arcfiend)
/datum/targetable/arcfiend
	name = "base arcfiend ability (you should never see me)"
	icon = 'icons/mob/arcfiend.dmi'
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/arcfiend

	castcheck()
		var/mob/living/M = holder.owner
		if (!can_act(M))
			boutput(holder.owner, __red("Not while incapacitated."))
			return 0
		return 1

/datum/targetable/arcfiend/sap_power
	name = "Sap Power"
	desc = "Drain power from a target entity or machine"
	cooldown = 0
	target_anything = TRUE
	targeted = TRUE
	icon_state = "sap"

	cast(atom/target)
		. = ..()
		if (target == holder.owner) return
		if (!IN_RANGE(holder.owner, target, 1)) return TRUE
		if (isnpcmonkey(target))
			boutput(holder.owner, "<span class='alert'>This creature lacks sufficient energy to consume.")
			return
		if (ishuman(target) || issilicon(target) || istype(target, /obj/machinery))
			holder.owner.visible_message("[holder.owner] places their hand onto [target].", "You place your hand onto [target]", "A static charge fills the air")
			actions.start(new/datum/action/bar/private/icon/sap_power(holder.owner, target, holder), holder.owner)
			logTheThing("combat", holder.owner, target, "[key_name(holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(holder.owner)].")

	castcheck()
		. = ..()
		if (holder.owner.restrained())
			boutput(holder.owner, __red("You need an active working hand to use [src]!"))
			return 0
/**
 * Sap Power
 * Arcfiend's main method of obtaining electrcity for their abilities
 * Also serves as a deadly attack if able to catch a target alone and off guard
 */
/datum/action/bar/private/icon/sap_power
	duration = 1 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION | INTERRUPT_ACT
	id = "sap_power"
	icon = 'icons/mob/arcfiend.dmi'
	icon_state = "sap_icon"
	var/mob/living/user
	var/atom/movable/target
	var/datum/abilityHolder/holder

	New(user, target, holder)
		. = ..()
		src.user = user
		src.target = target
		src.holder = holder

	onUpdate()
		..()
		if(!IN_RANGE(user, target, 1))
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if(!IN_RANGE(user, target, 1))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.loopStart()


	onEnd()
		if(!IN_RANGE(user, target, 1))
			..()
			interrupt(INTERRUPT_ALWAYS)

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (isdead(H))
				boutput(holder.owner, "<span class='alert'>[target] doesn't have enough energy for you to absorb!")
				interrupt(INTERRUPT_ALWAYS)
				return
			H.TakeDamage("All", 0, 5)
			H.do_disorient(stamina_damage = 50, weakened = 1 SECONDS, disorient = 2 SECOND)
			holder.addPoints(SAP_LIMIT_MOB)

		else if (issilicon(target))
			var/mob/living/silicon/S = target
			if (isdead(S) || (S.cell?.charge < POWER_CELL_DRAIN_RATE))
				boutput(holder.owner, "<span class='alert'>[target] doesn't have enough energy for you to absorb!")
				interrupt(INTERRUPT_ALWAYS)
				return
			S.TakeDamage("chest", 3, 0, DAMAGE_BURN)
			S.cell.use(POWER_CELL_DRAIN_RATE)
			holder.addPoints(SAP_LIMIT_MOB)
			S.do_disorient(stamina_damage = 50, weakened = 1 SECONDS, disorient = 2 SECOND)

		else if (istype(target, /obj/machinery))
			var/area/A = get_area(target)
			var/obj/machinery/power/apc/target_apc = A?.area_apc
			var/points_gained = 0

			if (istype(target, /obj/machinery/power))
				if (istype(target, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/apc = target
					points_gained = SAP_LIMIT_APC
					target_apc = apc // drain the target APC instead of the area's
					if (!target_apc.cell || target_apc.cell.charge <= ((target_apc.cell.maxcharge / POWER_CELL_CHARGE_PERCENT_MINIMUM) + POWER_CELL_DRAIN_RATE)) //not enough power
						boutput(holder.owner, "<span class='alert'>[target] doesn't have enough energy for you to absorb!")
						interrupt(INTERRUPT_ALWAYS)
						return
					if (prob(1))
						apc.set_broken()
				else if (istype(target, /obj/machinery/power/smes))
					target_apc = null
					var/obj/machinery/power/smes/smes = target
					if (smes.charge < SMES_DRAIN_RATE)
						boutput(holder.owner, "<span class='alert'>[target] doesn't have enough energy for you to absorb!")
						interrupt(INTERRUPT_ALWAYS)
						return
					smes.charge -= SMES_DRAIN_RATE
					points_gained = SAP_LIMIT_APC
			else
				if (!target_apc.cell || target_apc.cell.charge <= ((target_apc.cell.maxcharge / POWER_CELL_CHARGE_PERCENT_MINIMUM) + POWER_CELL_DRAIN_RATE)) //not enough power
					boutput(holder.owner, "<span class='alert'>[target] doesn't have enough energy for you to absorb!")
					interrupt(INTERRUPT_ALWAYS)
					return
				var/obj/machinery/M = target
				points_gained = clamp(round((M.power_usage * 0.1)), 0, SAP_LIMIT_MACHINE)

			if (points_gained == 0)
				boutput(holder.owner, "<span class='alert'>[target] doesn't have enough energy for you to absorb!")
				interrupt(INTERRUPT_ALWAYS)
				return
			holder.addPoints(points_gained)
			// drain is proportional to points gained
			target_apc?.cell.use(POWER_CELL_DRAIN_RATE * (points_gained / SAP_LIMIT_APC))
		if (prob(35))
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(2, FALSE, holder.owner)
			s.start()

		playsound(owner.loc, "sound/effects/electric_shock_short.ogg", 30, 1, 0, pitch = 0.8)
		holder.owner.set_dir(get_dir(holder.owner, target))
		target.add_fingerprint(holder.owner)
		src.onRestart()

/**
 * Discharge
 * Melee attack, unleash stored charge to burn a target and blast them backwards
 */
/datum/targetable/arcfiend/discharge
	name = "Discharge"
	desc = "Run a powerful current through a target in melee range damaging mobs and depowering doors"
	icon_state = "discharge"
	cooldown = 15 SECONDS
	target_anything = TRUE
	targeted = TRUE
	pointCost = 25
	var/wattage = 750 KILO WATTS

	cast(atom/target)
		. = ..()
		if (target == holder.owner) return TRUE
		if (!IN_RANGE(holder.owner, target, 1)) return TRUE
		if (ismob(target))
			var/mob/M = target
			M.shock(holder.owner, wattage, ignore_gloves = TRUE)
			target.add_fingerprint(holder.owner)
			logTheThing("combat", holder.owner, target, "[key_name(holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(holder.owner)].")
		else if (istype(target, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/airlock = target
			airlock.loseMainPower()
			target.add_fingerprint(holder.owner)
			playsound(holder.owner, "sound/effects/electric_shock.ogg", 50, 1)
			boutput(holder.owner, "<span class='alert'>You run a powerful current into [target] temporarily cutting the power!")
		else
			return TRUE
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(2, FALSE, target)
		s.start()
		holder.owner.set_dir(get_dir(holder.owner, target))

/**
 * Jamming Field
 * Makes you into a walking radio jammer for 30 seconds
 */
/datum/targetable/arcfiend/jamming_field
	name = "Jamming Field"
	desc = "Jam nearby electrical signals such as radio communications for 30 seconds"
	icon_state = "jamming_field"
	cooldown = 2 MINUTES
	var/duration = 30 SECONDS
	pointCost = 150

	cast(atom/target)
		. = ..()
		holder.owner.changeStatus("jamming_field", duration)
		playsound(holder.owner, "sound/effects/radio_sweep2.ogg", 30)

/datum/statusEffect/jamming_field
	id = "jamming_field"
	name = "Jamming Field"
	desc = "You're radiating out electromagnetic waves and jamming nearby broadcasts"
	icon_state = "empulsar"
	unique = TRUE
	maxDuration = 30 SECONDS
	var/image/aura = null

	New()
		. = ..()
		aura = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
		aura.color = "#FF0"

	onAdd(optional)
		. = ..()
		if (!(owner in radio_controller.active_jammers))
			radio_controller.active_jammers.Add(owner)
		owner.UpdateOverlays(aura, "jamming_field_aura")

	onRemove()
		. = ..()
		if (owner in radio_controller.active_jammers)
			radio_controller.active_jammers.Remove(owner)
		owner.ClearSpecificOverlays("jamming_field_aura")

/datum/targetable/arcfiend/elecflash
	name = "Flash"
	desc = "Release a sudden burst of power around yourself disorienting nearby foes"
	icon_state = "flash"
	cooldown = 10 SECONDS
	pointCost = 25

	cast(atom/target)
		. = ..()
		elecflash(holder.owner, 2, 6, TRUE)

/**
 * Arc Flash
 * A ranged chain lightning attack
 */
/datum/targetable/arcfiend/arcFlash
	name = "Arc Flash"
	desc = "Unleash a ranged bolt of electricity that chains to nearby targets with reduced damage"
	icon_state = "arcflash"
	cooldown = 15 SECONDS
	pointCost = 50
	target_anything = TRUE
	targeted = TRUE
	var/wattage = 600 KILO WATT
	/// max range between mobs to chain lightning
	var/chain_range = 3
	/// max number of additional mobs to chain to
	var/chain_count = 2

	cast(atom/target)
		. = ..()
		if (!ismob(target)) return TRUE // no point in wasting it on a turf
		if (target == holder.owner) return TRUE
		if (!IN_RANGE(holder.owner, target, (WIDE_TILE_WIDTH / 2))) return TRUE
		arcFlash(holder.owner, target, wattage)
		logTheThing("combat", holder.owner, target, "[key_name(holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(holder.owner)].")

		var/list/exempt_targets = list(holder.owner, target)
		var/mob/chain_source = target
		var/mob/chain_target = null
		for (var/i in 1 to chain_count)
			var/list/potential_targets = list()
			for (var/mob/M as anything in mobs)
				if (M in exempt_targets) continue
				if (IN_RANGE(chain_source, M, 3))
					potential_targets += M
			if (length(potential_targets))
				chain_target = pick(potential_targets)
				exempt_targets += chain_target
			else break
			arcFlash(chain_source, chain_target, (wattage / (i + 1)))
			logTheThing("combat", holder.owner, target, "[key_name(holder.owner)] hit [key_name(target)] with chain lightning [log_loc(holder.owner)].")
			chain_source = chain_target

/**
 * Jolt
 * Killing skill, also decent damage even if you don't finish. The final tick induces cardiac arrest
 */
/datum/targetable/arcfiend/jolt
	name = "Jolt"
	desc = "Charge up and release a series of powerful jolts into your target, eventually stopping their heart"
	icon_state = "jolt"
	cooldown = 2 MINUTES
	pointCost = 500
	targeted = TRUE
	target_anything = TRUE
	var/wattage = 2.6 KILO WATTS

	cast(atom/target)
		. = ..()
		if (target == holder.owner) return TRUE
		if (!IN_RANGE(holder.owner, target, 1)) return TRUE
		if (ishuman(target))
			actions.start(new/datum/action/bar/private/icon/jolt(holder.owner, target, holder, wattage), holder.owner)
			logTheThing("combat", holder.owner, target, "[key_name(holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(holder.owner)].")
		else return TRUE

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

	New(user, target, holder, wattage)
		. = ..()
		src.user = user
		src.target = target
		src.holder = holder
		src.wattage = wattage

	onUpdate(timePassed)
		..()
		if(!IN_RANGE(user, target, 1))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!ON_COOLDOWN(owner, "jolt", 1 SECOND))
			playsound(holder.owner, "sound/effects/elec_bzzz.ogg", 25, 1)
			target.shock(user, wattage, ignore_gloves = TRUE)
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(5, FALSE, target)
			s.start()
			owner.set_dir(get_dir(owner, target))

	onStart()
		..()
		if(!IN_RANGE(user, target, 1))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.loopStart()


	onEnd()
		target.add_fingerprint(user)
		if (!target.bioHolder?.HasEffect("resist_electric"))
			target.contract_disease(/datum/ailment/malady/flatline, null, null, 1)
		..()

/datum/targetable/arcfiend/voltron
	name = "Ride The Lightning"
	desc = "Expend energy to travel through electrical cables"
	icon_state = "voltron"
	cooldown = 0 SECONDS
	pointCost = 75
	var/active = FALSE
	var/view_range = 2
	var/list/cable_images = null
	var/obj/dummy/voltron/D = null
	var/step_cost = 3

	New(datum/abilityHolder/holder)
		. = ..()
		var/obj/cable/ctype = /obj/cable
		var/cicon = initial(ctype.icon)

		// fill up the list with however many image object we're going to be using
		cable_images = new/list((view_range*2+1)**2)
		for(var/i in 1 to length(cable_images))
			var/image/cimg = image(cicon)
			cimg.layer = 100
			cimg.plane = 100
			cable_images[i] = cimg

	cast(atom/target)
		. = ..()
		if (active)
			deactivate()
		else
			var/turf/T = get_turf(holder.owner)
			if (!T.z || isrestrictedz(T.z))
				boutput(holder.owner, __red("You are forbidden from using that here!"))
				return TRUE
			if (!(locate(/obj/cable) in T))
				boutput(holder.owner, __red("You must use this ability on top of a cable!"))
				return TRUE
			playsound(holder.owner, "sound/machines/ArtifactBee2.ogg", 30, 1, -2)
			actions.start(new/datum/action/bar/private/voltron(src), holder.owner)

	proc/activate()
		active = TRUE
		handle_move()
		D = new/obj/dummy/voltron(holder.owner, get_turf(holder.owner))
		RegisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), .proc/handle_move)
		pointCost = 0
		var/atom/movable/screen/ability/topBar/B = src.object
		B.point_overlay.maptext = null
		holder.owner.setStatus("ev_voltron", INFINITE_STATUS, list(holder, src))

	proc/handle_move()
		var/turf/user_turf = get_turf(holder.owner)
		if (isrestrictedz(user_turf) || is_incapacitated(holder.owner))
			deactivate()
			active = FALSE
			return
		var/turf/T1 = locate(clamp((user_turf.x - view_range), 1, world.maxx), clamp((user_turf.y - view_range), 1, world.maxy), user_turf.z)
		var/turf/T2 = locate(clamp((user_turf.x + view_range), 1, world.maxx), clamp((user_turf.y + view_range), 1, world.maxy), user_turf.z)

		for(var/turf/T as anything in block(T1, T2))
			for(var/obj/cable/C in T)
				var/idx = ((C.y - user_turf.y + src.view_range) * src.view_range*2) + (C.x - user_turf.x + src.view_range*2) + 1
				var/image/img = cable_images[idx]
				img.appearance = C.appearance
				img.invisibility = 0
				img.alpha = 255
				img.layer = 100
				img.plane = 100
				img.loc = locate(C.x, C.y, C.z)

		send_images_to_client()
		holder.points = max((holder.points - step_cost), 0)
		if (!holder.points)
			deactivate()

	proc/deactivate()
		boutput(holder.owner, __red("You are ejected from the cable!"))
		active = FALSE
		//ensure points cost is set back to where it belongs
		pointCost = initial(pointCost)
		var/atom/movable/screen/ability/topBar/B = src.object
		B.update_cooldown_cost()

		UnregisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
		src.holder.owner.client?.images -= cable_images
		qdel(D)
		D = null
		holder.owner.delStatus("ev_voltron")

	proc/send_images_to_client()
		if ((!holder.owner?.client) || (!isalive(holder.owner)) || (isrestrictedz(holder.owner.z)))
			deactivate()
			return
		holder.owner.client.images += cable_images

/datum/action/bar/private/voltron
	duration = 1 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION | INTERRUPT_ACT
	var/datum/targetable/arcfiend/voltron/abil

	New(abil)
		. = ..()
		src.abil = abil

	onEnd()
		. = ..()
		abil.activate()

/datum/statusEffect/ev_voltron
	id = "ev_voltron"
	name = "Ride The Lightning"
	desc = "You're expending energy to travel through electrical cables"
	icon_state = "empulsar"
	unique = TRUE
	maxDuration = null
	var/datum/abilityHolder/arcfiend/holder
	var/datum/targetable/arcfiend/voltron/ability

	onAdd(optional)
		. = ..()
		if (islist(optional))
			src.holder = optional[1]
			src.ability = optional[2]
		if (!istype(src.holder) || !istype(src.ability))
			owner.delStatus(id)

	onUpdate(timePassed)
		. = ..()
		if (!ON_COOLDOWN(owner, "ev_voltron", 1 SECOND))
			src.holder.points = max((holder.points - (timePassed)), 0)
			if (!holder.points)
				ability.deactivate()

/**
 * Polarize
 * Applies the magnetic aura effect to nearby mobs
 */
/datum/targetable/arcfiend/polarize
	name = "Polarize"
	desc = "Unleash a wave of charged particles polarizing nearby mobs giving them magnetic auras"
	icon_state = "polarize"
	cooldown = 12 SECONDS
	pointCost = 50
	var/range = 4
	var/duration = 20 SECONDS

	cast(atom/target)
		. = ..()
		var/charge = pick("magnets_pos", "magnets_neg")
		playsound(holder.owner, 'sound/impact_sounds/Energy_Hit_2.ogg', 65, 1)
		for (var/mob/M as anything in mobs)
			if (M == holder.owner)
				continue
			if (!IN_RANGE(holder.owner, M, range))
				continue
			if (!ishuman(M))
				continue
			M.changeStatus("magnetized", duration, charge)

#undef MAX_ARCFIEND_POINTS
#undef POWER_CELL_DRAIN_RATE
#undef POWER_CELL_CHARGE_PERCENT_MINIMUM
#undef SMES_DRAIN_RATE
#undef SAP_LIMIT_APC
#undef SAP_LIMIT_MACHINE
#undef SAP_LIMIT_MOB
