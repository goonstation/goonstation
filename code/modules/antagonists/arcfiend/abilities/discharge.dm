/// Melee attack. Shocks a targeted mob, or can be used on an airlock to temporarily cut its power.
/datum/targetable/arcfiend/discharge
	name = "Discharge"
	desc = "Run a powerful current through a target in melee range. Mobs will be shocked, while airlocks will be briefly depowered."
	icon_state = "discharge"
	cooldown = 15 SECONDS
	target_anything = TRUE
	targeted = TRUE
	pointCost = 25

	/// This is the amount of power considered to be in use when we're shocking a mob.
	var/wattage = 750 KILO WATTS

	cast(atom/target)
		. = ..()
		if (target == src.holder.owner)
			return TRUE
		if (!(BOUNDS_DIST(src.holder.owner, target) == 0))
			return TRUE
		if (ismob(target))
			var/mob/M = target
			M.shock(src.holder.owner, src.wattage, ignore_gloves = TRUE)
			target.add_fingerprint(src.holder.owner)
			logTheThing(LOG_COMBAT, src.holder.owner, "[key_name(src.holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(src.holder.owner)].")
		else if (istype(target, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/airlock = target
			airlock.loseMainPower()
			target.add_fingerprint(src.holder.owner)
			playsound(src.holder.owner, 'sound/effects/electric_shock.ogg', 50, TRUE)
			boutput(src.holder.owner, "<span class='alert'>You run a powerful current into [target], temporarily cutting its power!</span>")
		else
			return TRUE
		var/datum/effects/system/spark_spread/S = new /datum/effects/system/spark_spread
		S.set_up(2, FALSE, target)
		S.start()
		src.holder.owner.set_dir(get_dir(src.holder.owner, target))
