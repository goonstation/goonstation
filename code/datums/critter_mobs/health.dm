/datum/healthHolder
	var/name = "generic health"
	var/associated_damage_type = "none"
	var/overlay_icon = null
	var/list/threshold_values = list()
	var/list/threshold_icon_states = list()
	var/mob/living/holder = null
	var/image/damage_overlay
	var/maximum_value = 100						// the maximum amount of health this holder has
	var/value = 100								// the current amount of health this holder has
	var/last_value = 100						// value at the last call of Life() - maintained automatically
	var/minimum_value = -INFINITY					// the lowest amount of health this holder can represent
	var/depletion_threshold = -INFINITY				// if the value reaches this threshold, on_deplete() is called
	var/current_overlay = 0						// currently displayed level of overlay, helps to check if update is needed
	var/assume_blood_color = 0					// if true, damage overlay will be blood colored
	var/damage_multiplier = 1
	var/count_in_total = 1						// if true, the mob's health will be increased by the value of this
												// and maximum health will be increased by the maximum value of this
												// The mob still dies at health = 0

	New(var/mob/M)
		..()
		holder = M
		value = maximum_value

	disposing()
		holder = null
		..()

	proc/TakeDamage(var/amt, var/bypass_multiplier = 0)
		if (!bypass_multiplier && amt > 0)
			amt *= damage_multiplier
		if (minimum_value < maximum_value)
			value = clamp(value - amt, minimum_value, maximum_value)
		else
			value = min(value - amt, maximum_value)
		health_update_queue |= holder

	proc/HealDamage(var/amt)
		TakeDamage(-amt)

	proc/prevents_speech()
		return 0

	proc/damaged()
		return value < maximum_value

	proc/on_deplete()
		holder.death(FALSE)

	proc/Life()
		if (value != last_value)
			update_overlay()
		on_life()
		last_value = value

	proc/on_life()

	proc/update_overlay()
		if (!overlay_icon || !threshold_icon_states.len || !length(threshold_values))
			return
		var/next_overlay = 0
		while (next_overlay < threshold_values.len && value < threshold_values[next_overlay + 1])
			next_overlay++
		if (next_overlay == current_overlay)
			return
		if (!damage_overlay && next_overlay != 0)
			damage_overlay = image(overlay_icon, threshold_icon_states[next_overlay])
			if (assume_blood_color && holder.blood_id)
				var/datum/reagent/R = reagents_cache[holder.blood_id]
				if (R)
					damage_overlay.color = rgb(R.fluid_r, R.fluid_g, R.fluid_b)
		else if (damage_overlay)
			holder.overlays -= damage_overlay
		if (next_overlay != 0)
			damage_overlay.icon_state = threshold_icon_states[next_overlay]
			holder.overlays += damage_overlay
		current_overlay = next_overlay

	proc/on_react(var/datum/reagents/R, var/method = 1, var/react_volume = null)

	proc/on_attack(var/obj/item/I, var/mob/M)
		return 1

	proc/get_damage_assessment()
		if (maximum_value > 0)
			return "[name] health: [value]/[maximum_value]"
		else
			return "[name] damage: [maximum_value - value]"
