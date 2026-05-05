TYPEINFO(/obj/machinery/chemicompiler_stationary)
	mats = 15
	start_speech_modifiers = list(SPEECH_MODIFIER_MACHINERY, SPEECH_MODIFIER_CHEMICOMPILER)

/obj/machinery/chemicompiler_stationary
	name = "ChemiCompiler CCS1001"
	desc = "This device looks very difficult to use."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chemicompiler_st_off"
	flags = NOSPLASH
	processing_tier = PROCESSING_FULL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/datum/chemicompiler_executor/executor
	var/datum/light/light

	New()
		..()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "Run Script", PROC_REF(runscript))
		executor = new(src, /datum/chemicompiler_core/stationaryCore)
		light = new /datum/light/point
		light.set_brightness(0.4)
		light.attach(src)

	proc/runscript(var/datum/mechanicsMessage/input)
		var/buttId = executor.core.validateButtId(input.signal)
		if(!buttId || executor.core.running)
			return
		if(islist(executor.core.cbf[buttId]))
			executor.core.runCBF(executor.core.cbf[buttId])

	ex_act(severity)
		switch (severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	was_deconstructed_to_frame(mob/user)
		status = NOPOWER // If it works.
		SEND_SIGNAL(src, COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attack_hand(mob/user)
		if (status & BROKEN || !powered())
			boutput( user, SPAN_ALERT("You can't seem to power it on!") )
			return
		ui_interact(user)
		return

	attackby(var/obj/item/reagent_containers/glass/B, var/mob/user)
		if (!istype(B, /obj/item/reagent_containers/glass))
			return
		if (isrobot(user)) return attack_ai(user)
		return src.Attackhand(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ChemiCompiler", src.name)
			ui.open()

	ui_data(mob/user)
		. = executor.get_ui_data()

	ui_act(action, list/params)
		. = ..()
		if (.)
			return

		return executor.execute_ui_act(action, params)

	power_change()

		if(status & BROKEN)
			icon_state = "chemicompiler_st_off"
			light.disable()

		else if(powered())
			status &= ~NOPOWER
			if (executor.core.running)
				icon_state = "chemicompiler_st_working"
				light.set_brightness(0.6)
				light.enable()
			else
				icon_state = "chemicompiler_st_on"
				light.set_brightness(0.4)
				light.enable()
		else
			SPAWN(rand(0, 15))
				icon_state = "chemicompiler_st_off"
				status |= NOPOWER
				light.disable()

	process()
		. = ..()
		if ( src.executor )
			src.executor.on_process()

	proc
		statusChange(oldStatus, newStatus)
			power_change()
