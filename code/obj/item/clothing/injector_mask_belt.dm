/* CONTAINS:
- Injector belt
- Vapo-Matic mask
- Associated condition datums

There's much less duplicate code here than there used to be, it could probably be improved further using components,
	but I'm not doing that without help on my first pull request in addition to learning TGUI!
*/

/obj/item/injector_belt
	name = "injector belt"
	desc = "Automated injection system attached to a belt."
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "injectorbelt_atm"
	item_state = "injector"
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	mats = 10

	var/can_trigger = 1
	var/mob/owner = null
	var/active = 0
	var/obj/item/reagent_containers/glass/container = null
	var/datum/injector_belt_condition/condition = null
	var/min_time = 10 SECONDS
	var/inj_amount = 5

	equipped(var/mob/user, var/slot)
		..()
		if(slot == SLOT_BELT)
			owner = user
			if (container?.reagents.total_volume && condition)
				active = 1
				check()
				user.show_text("[src]: Injector system initialized.", "blue")
			else
				var/error_message = ""
				if (!container)
					error_message += " no beaker,"
				if (container && !container.reagents.total_volume)
					error_message += " beaker is empty,"
				if (!condition)
					error_message += " no condition selected,"
				var/output = copytext(error_message, 1, -1)
				user.show_text("Injector system not set up properly:[output].", "red")
		return

	unequipped(mob/user as mob)
		..()
		owner = null
		active = 0
		return

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "AutoInjector", name)
			ui.open()

	ui_data(mob/user)
		. = autoinjector_ui_data(src.container?.reagents, src.condition, src.min_time, src.inj_amount)

	ui_act(action, params)
		. = ..()
		if(.)
			return
		. = autoinjector_ui_act(src, action, params, usr, src.container?.reagents.maximum_volume)

	attack_self(mob/user as mob)
		ui_interact(user)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/reagent_containers/glass))
			if (container)
				boutput(user, "<span class='alert'>There is already a container attached to the belt.</span>")
				return
			if (!W.reagents.total_volume)
				user.show_text("[W] is empty.", "red")
				return
			container =  W
			user.drop_item()
			W.set_loc(src)
			if (src.is_equipped() && src.owner == user && src.condition)
				src.active = 1
				src.check()
				user.show_text("You attach the [W] to the [src.name]! The injector system is now operational.", "blue")
			else
				user.show_text("You attach the [W] to the [src.name]! Please select a condition and re-equip [src] to initialize injector system.", "blue")

			tgui_process.update_uis(src)

	proc/check()
		if(!src.is_equipped()) return
		if(!src.active) return

		if(src.condition && src.container?.reagents.total_volume)
			if(src.condition.check_trigger(src.owner) && src.can_trigger)

				src.can_trigger = 0
				SPAWN(src.min_time) src.can_trigger = 1

				playsound(src, 'sound/items/injectorbelt_active.ogg', 33, 0, -5)
				boutput(src.owner, "<span class='notice'>Your Injector belt activates.</span>")

				src.container.reagents.reaction(src.owner, INGEST)
				SPAWN(1.5 SECONDS)
					src.container.reagents.trans_to(src.owner, src.inj_amount)

		SPAWN(2.5 SECONDS)
			if (src) src.check()

	proc/is_equipped()
		if(!owner) return 0
		if(hasvar(owner, "belt"))
			if(owner:belt == src)
				return 1
			else
				return 0
		else
			return 0

//////////////////////////////////////

/obj/item/clothing/mask/gas/injector_mask
	name = "Vapo-Matic"
	desc = "Automated chemical vaporizer system built into an old industrial respirator. Doesn't look very safe at all!"
	flags = FPRINT | TABLEPASS  | NOSPLASH
	c_flags =  COVERSMOUTH | MASKINTERNALS
	mats = 10
	icon_state = "gas_injector"
	item_state = "gas_injector"

	var/can_trigger = 1
	var/mob/owner = null
	var/active = 0
	var/obj/item/reagent_containers/glass/container = null
	var/datum/injector_belt_condition/condition = null
	var/min_time = 10 SECONDS
	var/inj_amount = 5

	equipped(var/mob/user, var/slot)
		..()
		if(slot == SLOT_WEAR_MASK)
			owner = user
			if (container?.reagents.total_volume && condition)
				active = 1
				check()
				user.show_text("[src]: Injector system initialized.", "blue")
			else
				var/error_message = ""
				if (!container)
					error_message += " no beaker,"
				if (container && !container.reagents.total_volume)
					error_message += " beaker is empty,"
				if (!condition)
					error_message += " no condition selected,"
				var/output = copytext(error_message, 1, -1)
				user.show_text("Injector system not set up properly:[output].", "red")
		return

	unequipped(mob/user as mob)
		..()
		owner = null
		active = 0
		return

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "AutoInjector", name)
			ui.open()

	ui_data(mob/user)
		. = autoinjector_ui_data(src.container?.reagents, src.condition, src.min_time, src.inj_amount)

	ui_act(action, params)
		. = ..()
		if(.)
			return
		. = autoinjector_ui_act(src, action, params, usr, src.container?.reagents.maximum_volume)

	attack_self(mob/user as mob)
		ui_interact(user)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/reagent_containers/glass))
			if (container)
				boutput(user, "<span class='alert'>There is already a container attached to the mask.</span>")
				return
			if (!W.reagents.total_volume)
				user.show_text("[W] is empty.", "red")
				return
			container =  W
			user.drop_item()
			W.set_loc(src)
			if (src.is_equipped() && src.owner == user && src.condition)
				src.active = 1
				src.check()
				user.show_text("You attach the [W] to the [src.name]! The injector system is now operational.", "blue")
			else
				user.show_text("You attach the [W] to the [src.name]! Please select a condition and re-equip [src] to initialize injector system.", "blue")

			tgui_process.update_uis(src)
		else
			return ..()

	proc/check()
		if(!src.is_equipped()) return
		if(!src.active) return

		if(src.condition && src.container?.reagents.total_volume)
			if(src.condition.check_trigger(src.owner) && src.can_trigger)

				src.can_trigger = 0
				SPAWN(src.min_time) src.can_trigger = 1
				var/turf/T = get_turf(src)
				if(T)
					playsound(T, 'sound/items/injectorbelt_active.ogg', 33, 0, -5)
					SPAWN(0.5 SECONDS)
						playsound(T, 'sound/machines/hiss.ogg', 40, 1, -5)

				boutput(src.owner, "<span class='notice'>Your [src] activates.</span>")

				src.container.reagents.reaction(src.owner, INGEST)
				SPAWN(1.5 SECONDS)
					src.container.reagents.trans_to(src.owner, src.inj_amount)

		SPAWN(2.5 SECONDS)
			if (src) src.check()

	proc/is_equipped()
		if(!owner) return 0
		if(hasvar(owner, "wear_mask"))
			if(owner:wear_mask == src)
				return 1
			else
				return 0
		else
			return 0

//////////////////////////////////////

/datum/injector_belt_condition
	var/name = ""
	var/desc = ""

	proc/setup(mob/M)
		return

	proc/check_trigger(mob/M)
		return 0

ABSTRACT_TYPE(/datum/injector_belt_condition/with_threshold)
/datum/injector_belt_condition/with_threshold
	var/threshold
	var/minValue
	var/maxValue
	var/suffix

	proc/update_desc()
		return

/datum/injector_belt_condition/with_threshold/health
	name = "Health"
	threshold = 0
	suffix = " health"
	minValue = 0
	maxValue = 100

	New()
		..()
		update_desc()

	setup(mob/M, var/th)
		threshold = th
		update_desc()
		return 1

	update_desc()
		..()
		desc = "Triggers when health falls below [threshold]."

	check_trigger(mob/M)
		if(M.health < src.threshold) return 1
		else return 0

/datum/injector_belt_condition/with_threshold/damage
	name = "Damage"
	threshold = 0
	var/damagetype = "brute"
	minValue = 5
	maxValue = 100

	New()
		..()
		suffix = " " + damagetype
		update_desc()

	setup(mob/M, var/th)
		threshold = th
		update_desc()
		return 1

	update_desc()
		..()
		desc = "Triggers when [damagetype] damage exceeds [threshold]."

	proc/setupDamageType(mob/M, var/dt)
		damagetype = dt
		suffix = " " + damagetype
		update_desc()
		return 1

	check_trigger(mob/M)
		switch(src.damagetype)
			if("brute")
				if(M.get_brute_damage() > src.threshold) return 1
			if("burn")
				if(M.get_burn_damage() > src.threshold) return 1
			if("toxin")
				if(M.get_toxin_damage() > src.threshold) return 1
			if("oxygen")
				if(M.get_oxygen_deprivation() > src.threshold) return 1
		return 0

/datum/injector_belt_condition/tempdiff
	name = "Temperature !="
	desc = "Triggers when temperature reaches abnormal levels."
	var/standard_temp = 307 KELVIN

	setup(mob/M)
		return 1

	check_trigger(mob/M)
		if(M.bodytemperature > standard_temp)
			if((M.bodytemperature - src.standard_temp) > 20) return 1
		else
			if((src.standard_temp - M.bodytemperature) > 20) return 1
		return 0

/datum/injector_belt_condition/with_threshold/tempover
	name = "Temperature >"
	threshold = 315 KELVIN
	suffix = " k"
	minValue = 315 KELVIN
	maxValue = 600 KELVIN

	New()
		..()
		update_desc()

	setup(mob/M, var/th)
		threshold = th
		update_desc()
		return 1

	update_desc()
		..()
		desc = "Triggers when temperature rises above [threshold]."

	check_trigger(mob/M)
		if(M.bodytemperature > src.threshold) return 1
		else return 0

/datum/injector_belt_condition/with_threshold/tempunder
	name = "Temperature <"
	threshold = 300 KELVIN
	suffix = " k"
	minValue = 25 KELVIN
	maxValue = 300 KELVIN

	New()
		..()
		update_desc()

	setup(mob/M, var/th)
		threshold = th
		update_desc()
		return 1

	update_desc()
		..()
		desc = "Triggers when temperature falls below [threshold]."

	check_trigger(mob/M)
		if(M.bodytemperature < src.threshold) return 1
		else return 0

/datum/injector_belt_condition/incapacitated
	name = "Incapacitated"
	desc = "Triggers when incapacitated."

	setup(mob/M)
		return 1

	check_trigger(mob/M)
		if(M.getStatusDuration("stunned") || M.getStatusDuration("paralysis") || M.getStatusDuration("weakened") || isunconscious(M)) return 1
		else return 0

/datum/injector_belt_condition/life
	name = "Death"
	desc = "Triggers on Death."

	setup(mob/M)
		return 1

	check_trigger(mob/M)
		if(isdead(M)) return 1
		else return 0

/proc/autoinjector_trigger_names(var/setType)
	var/list/cond_types = concrete_typesof(/datum/injector_belt_condition)
	. = new/list()

	if (!setType)
		. += "None"

	for(var/A in cond_types)
		var/datum/injector_belt_condition/C = A
		. += initial(C.name)
		if (setType)
			.[initial(C.name)] = A

/proc/autoinjector_ui_data(var/datum/reagents/R, var/datum/injector_belt_condition/condition, var/min_time, var/inj_amount)
	. = list()

	var/list/reagentData = null
	if (R)
		reagentData = list(
			maxVolume = R.maximum_volume,
			totalVolume = R.total_volume,
			contents = list(),
			finalColor = "#000000"
		)

		var/list/contents = reagentData["contents"]
		if(istype(R) && length(R.reagent_list) > 0)
			reagentData["finalColor"] = R.get_average_rgb()
			for(var/reagent_id in R.reagent_list)
				var/datum/reagent/current_reagent = R.reagent_list[reagent_id]

				contents.Add(list(list(
					name = reagents_cache[reagent_id],
					id = reagent_id,
					colorR = current_reagent.fluid_r,
					colorG = current_reagent.fluid_g,
					colorB = current_reagent.fluid_b,
					volume = current_reagent.volume
				)))
	.["reagentData"] = reagentData

	.["conditions"] = autoinjector_trigger_names(FALSE)

	.["condition"] = null
	.["conditionTreshold"] = null
	.["conditionDamage"] = null
	if (condition)
		.["condition"] = list(
			name = condition.name,
			desc = condition.desc,
		)

		if (istype(condition, /datum/injector_belt_condition/with_threshold))
			var/datum/injector_belt_condition/with_threshold/tresholdCondition = condition
			.["conditionTreshold"]  = list(
				currentValue = tresholdCondition.threshold,
				suffix = tresholdCondition.suffix,
				minValue = tresholdCondition.minValue,
				maxValue = tresholdCondition.maxValue,
			)

			if (istype(condition, /datum/injector_belt_condition/with_threshold/damage))
				var/datum/injector_belt_condition/with_threshold/damage/damageCondition = condition
				.["conditionDamage"]  = list(
					damagetype = damageCondition.damagetype
				)

	.["injectionAmount"] = inj_amount
	.["minimumTime"] = min_time / (1 SECOND)

/proc/autoinjector_ui_act(obj/source, action, params, mob/user, var/maximum_volume)
	var/obj/item/injector_belt/current_belt = null
	var/obj/item/clothing/mask/gas/injector_mask/current_mask = null
	if (istype(source, /obj/item/injector_belt))
		current_belt = source
	else if (istype(source, /obj/item/clothing/mask/gas/injector_mask))
		current_mask = source

	switch(action)
		if ("remove_cont")
			if (current_belt)
				usr.put_in_hand_or_drop(current_belt.container)
				current_belt.container = null
			else if (current_mask)
				usr.put_in_hand_or_drop(current_mask.container)
				current_mask.container = null
			. = TRUE

		if ("remove_cond")
			if (current_belt)
				current_belt.condition = null
			else if (current_mask)
				current_mask.condition = null
			. = TRUE

		if ("sel_cond")
			var/list/filtered = autoinjector_trigger_names(TRUE)

			var/selected = params["condition"]
			var/selected_type
			var/datum/injector_belt_condition/selected_condition = null
			if (selected != "None")
				selected_type = filtered[selected]
				selected_condition = new selected_type()

			if (current_belt)
				current_belt.condition = selected_condition
			else if (current_mask)
				current_mask.condition = selected_condition

			if (selected_condition && !istype(selected_condition, /datum/injector_belt_condition/with_threshold))
				selected_condition.setup(user)
			. = TRUE

		if ("sel_damage_type")
			var/datum/injector_belt_condition/with_threshold/damage/currentCondition
			if (current_belt)
				currentCondition = current_belt.condition
			else if (current_mask)
				currentCondition = current_mask.condition

			currentCondition.setupDamageType(user, params["damagetype"])
			. = TRUE

		if("changeConditionValue")
			var/datum/injector_belt_condition/currentCondition
			if (current_belt)
				currentCondition = current_belt.condition
			else if (current_mask)
				currentCondition = current_mask.condition

			currentCondition.setup(user, params["conditionValue"])
			. = TRUE

		if("changeAmount")
			var/clampedVolume = clamp(round(params["amount"]), 1, maximum_volume);
			if (current_belt)
				current_belt.inj_amount = clampedVolume
			else if (current_mask)
				current_mask.inj_amount = clampedVolume
			. = TRUE

		if ("changeMintime")
			var/clampedTime = clamp(round(params["mintime"]) SECONDS, 3 SECONDS, 300 SECONDS)
			if (current_belt)
				current_belt.min_time = clampedTime
			else if (current_mask)
				current_mask.min_time = clampedTime
			. = TRUE
