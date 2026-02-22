/obj/item/device/brainjar
	name = "janky assembly"
	desc = "What the fuck is this!?"
	icon_state = "tb-blue"
	w_class = W_CLASS_NORMAL


	var/mob/living/intangible/brainmob/controller = null
	var/obj/item/organ/brain/the_brain = null
	var/obj/item/device/radio/rad = null

	var/obj/item/device/radio/signaler/signal = null
	var/obj/item/canbomb_detonator/detonator_part = null

	var/colour = "blue"
	var/list/icon/overlays_list = list()
	var/crafting_stage = 0
	var/crafting_stage_max = 5
	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK, PROC_REF(assembly_check))
		overlays_list["wires"] = new /icon('icons/obj/items/device.dmi', "bjwires")
		overlays_list["radio"] = new /icon('icons/obj/items/device.dmi', "bjradio")
		overlays_list["analyzer"] = new /icon('icons/obj/items/device.dmi', "bjhealthanalyzer")
		overlays_list["head_01"] = new /icon('icons/obj/items/device.dmi', "head-nobrain")
		overlays_list["head_00"] = new /icon('icons/obj/items/device.dmi', "head-nobrain-unpow")
		overlays_list["head_11"] = new /icon('icons/obj/items/device.dmi', "head-brain")
		overlays_list["head_10"] = new /icon('icons/obj/items/device.dmi', "head-brain-unpow")

		controller = new(src)
		controller.container = src
		/*
		rad = new(src)
		*/
		update_controller_verbs()
		UpdateIcon()

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK)
		controller?.ghostize()
		..()

	disposing()
		controller?.ghostize()
		..()

	complete
		New()
			rad = new(src)
			crafting_stage = crafting_stage_max
			..()

	complete/signaller
		New()
			signal = new(src.controller)
			..()


	proc/set_appearance(var/colour="blue")
		if(colour in list("blue", "red", "green", "yellow"))
			src.colour = colour
			UpdateIcon()
			. = 1

	proc/update_controller_verbs()
		if(rad)
			src.verbs |= /obj/item/device/brainjar/proc/control_radio
		else
			src.verbs -= /obj/item/device/brainjar/proc/control_radio

		if(signal)
			src.verbs |= /obj/item/device/brainjar/proc/control_signaller
		else
			src.verbs -= /obj/item/device/brainjar/proc/control_signaller

		if(detonator_part)
			src.verbs |= /obj/item/device/brainjar/proc/control_canister_detonator
			src.verbs |= /obj/item/device/brainjar/proc/expedite_canbomb_detonation
		else
			src.verbs -= /obj/item/device/brainjar/proc/control_canister_detonator
			src.verbs -= /obj/item/device/brainjar/proc/expedite_canbomb_detonation

		if(istype(src.master, /obj/item/device/transfer_valve))
			src.verbs |= /obj/item/device/brainjar/proc/detonate_tank_transfer_valve
		else
			src.verbs -= /obj/item/device/brainjar/proc/detonate_tank_transfer_valve

	update_icon()
		icon_state = "tb-[colour]"
		overlays.Cut()

		if(crafting_stage > 0)
			overlays += overlays_list["wires"]
		if(crafting_stage > 1)
			overlays += overlays_list["analyzer"]

		if(signal) //Is there a remote signalling device attached?
			overlays += overlays_list["radio"]

		overlays += overlays_list["head_[!isnull(the_brain)][crafting_stage >= 4]"]

		if(crafting_stage < crafting_stage_max)
			name = "janky assembly"

			switch(crafting_stage)
				if(0)
					desc = "A cyborg's head affixed to a toolbox. Must be some kind of art."
				if(1)
					desc = "A cyborg's head affixed to a toolbox. Someone's put wires all over it. Huh."
				if(2)
					desc = "A toolbox containing a health analyzer and a cyborg's head. All components have been butchered horribly. <I>You hope objects can't feel pain.</I>"
				if(3)
					desc = "A toolbox containing a health analyzer and a cyborg's head. Someone has flashed a custom OS on that analyzer. What the f..."
				if(4)
					desc = "This looks decidedly unsafe!"
		else
			name = "Brain Assembly"
			desc = "A mess of wires and speakers. It looks <B>extremely</B> unethical."


/obj/item/device/brainjar/attackby(var/obj/item/W, var/mob/user)

	if(crafting_stage < crafting_stage_max)
		switch(crafting_stage)
			if(0)
				if(istype(W, /obj/item/cable_coil))
					var/obj/item/cable_coil/C = W
					if(C.use(5))
						user.show_text("You attach the wires to the cyborg head and secure them to the assembly. Needs a monitoring tool before it'll work, by all appearances.", "blue")
						playsound(src.loc, 'sound/impact_sounds/Generic_Stab_1.ogg', 20, 1)
						crafting_stage = 1
						UpdateIcon()
					else
						user.show_text("There's not enough wire on \the [C]!.", "red")
					return
			if(1)
				if(istype(W, /obj/item/device/analyzer/healthanalyzer))
					var/grump_text = prob(90) ? "The health analyzer isn't configured to support this, however." : "The health analyzer beeps grumpily; it didn't sign up for this shit!"
					user.show_text("You wire up the sensors on the analyzer and connect the mental interface to the i/o port. [grump_text]", "blue")
					user.u_equip(W)
					qdel(W)
					crafting_stage = 2
					UpdateIcon()
					return
			if(2)
				if (ispulsingtool(W))
					user.show_text("You use \the [W] to root the health analyzer, voiding the warranty! Probably won't be enough to power the assembly, though.", "blue")
					playsound(src.loc, 'sound/effects/brrp.ogg', 50, 1)
					crafting_stage = 3
					return
			if(3)
				if (istype(W, /obj/item/cell))
					user.show_text("You attach \the [W] to the assembly. It drones slightly. Won't do much good without a comms interface, however.", "blue")
					playsound(src.loc, 'sound/impact_sounds/Generic_Stab_1.ogg', 20, 1)
					user.u_equip(W)
					qdel(W)
					crafting_stage = 4
					UpdateIcon()
					return
			if(4)
				if(istype(W, /obj/item/device/radio))
					user.show_text("You hook up \the [W] to the assembly. It emits a loud screech!", "blue")
					var/bad_noise = pick('sound/machines/glitch1.ogg', 'sound/machines/glitch2.ogg', 'sound/machines/glitch3.ogg', 'sound/machines/glitch4.ogg', 'sound/machines/glitch5.ogg')
					playsound(src.loc, bad_noise, 50, 1)
					user.u_equip(W)
					rad = W
					W.set_loc(src)
					crafting_stage = 5
					update_controller_verbs()
					return
			if(5)
				user.show_text("Oh shit. Something went wrong. Roll 1d20 to cast Summon Coder.", "red")
				return
		..()

	else
		//Shit what is done after the assembly is complete
		if(istype(W, /obj/item/organ/brain)) //Insert a brain into the assembly
			if(crafting_stage < crafting_stage_max)
				user.show_text("The assembly is not ready for \the [W] yet", "red")
				return

			if(the_brain)
				user.show_text("There's already a brain inserted into \the [src]!", "red")
				return

			var/obj/item/organ/brain/B = W
			if(B.owner && !B.owner.get_player().dnr)
				the_brain = B
				user.u_equip(B)
				B.set_loc(src)
				B.owner.transfer_to(controller)
				user.show_text("You install \the [B] in \the [src].", "blue")
				logTheThing(LOG_COMBAT, user, "installs [constructTarget(controller,"combat")] into a brain assembly!")
				UpdateIcon()
			else
				user.show_text("This brain seems unfit to use in the assembly.", "red")
			update_controller_verbs()
			return

		else if(istype(W, /obj/item/device/radio/signaler)) //Insert a signaller
			if(crafting_stage < 3)
				user.show_text("The assembly is not ready for \the [W] yet", "red")
				return

			if(signal)
				user.show_text("A remote signalling device is already installed in \the [src]", "red")
				return
			signal = W
			user.u_equip(W)
			W.set_loc(controller)
			user.show_text("You hook up \the [W] to \the [src].", "blue")
			update_controller_verbs()
			UpdateIcon()
			return

		else ..()

/// ----------- Trigger/Applier-Assembly-Related Procs -----------

/obj/item/device/brainjar/proc/assembly_check(var/manipulated_brainjar, var/obj/item/second_part, var/mob/user)
	//if secured, we return TRUE and prevent the combination
	if (src.crafting_stage < src.crafting_stage_max || !src.the_brain)
		boutput(user, SPAN_NOTICE("The [src] is not ready yet."))
		return TRUE

/// ----------------------------------------------

/obj/item/device/brainjar/detonator_act(event, var/obj/item/canbomb_detonator/det)
	switch (event)
		if("attach")
			detonator_part = det
			controller.show_text("You interface with the detonator assembly controls.", "blue")
			det.initial_wire_functions += src
			update_controller_verbs()
		if("detach")
			detonator_part = null
			controller.show_text("You are disconnected from the detonator assembly!", "red")
			update_controller_verbs()
		if ("pulse")
			controller.say("[pick("BZ", "FZ", "GZ")][pick("A", "U", "O")][pick("P", "T", "ZZ")]")
			playsound(src, 'sound/voice/screams/robot_scream.ogg', 10, TRUE)
		if ("cut")
			controller.show_text("You no longer feel connected to the [det]!", "red")
			playsound(src, 'sound/voice/screams/robot_scream.ogg', 70, TRUE)
			detonator_part = null
			update_controller_verbs()


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				VERBS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/obj/item/device/brainjar/proc/control_radio()
	set name = "Control Radio"
	set desc = "Allows you to edit the settings of the assembly's built-in radio"
	set category = "Brain Jar"
	set src = usr.loc
	if(!src.rad)
		controller.show_text("Interface failure with the radio!", "red")
		return

	src.rad.AttackSelf(controller)

/obj/item/device/brainjar/proc/control_signaller()
	set name = "Control Signaller"
	set desc = "Allows you to edit the settings of the assembly's built-in remote signalling device"
	set category = "Brain Jar"
	set src = usr.loc

	if(!src.signal)
		controller.show_text("Interface failure with the remote signalling device!", "red")
		return

	src.signal.AttackSelf(controller)


/obj/item/device/brainjar/proc/control_canister_detonator()
	set name = "Detonator Controls"
	set desc = "Lets you control the various settings of the canister bomb."
	set category = "Brain Jar"
	set src = usr.loc

	if(!src.detonator_part)
		controller.show_text("Interface failure with the canister bomb!", "red")
		return
	if(!src.detonator_part.attachedTo)
		controller.show_text("\The [detonator_part] is inert without a canister to attach it to!", "red")
		return

	src.detonator_part.attachedTo.Attackhand(controller)

/obj/item/device/brainjar/proc/expedite_canbomb_detonation()
	set name = "Expedite detonation!"
	set desc = "Man, this is taking way too long!"
	set category = "Brain Jar"
	set src = usr.loc

	if(!src.detonator_part)
		controller.show_text("Interface failure with the canister bomb!")
		return

	if(!src.detonator_part.attachedTo)
		controller.show_text("\The [detonator_part] is inert without a canister to attach it to!", "red")
		return

	if(alert("Are you sure you want to expedite the detonation?", "Bomb controls.", "Yes", "No") != "Yes") return

	var/obj/item/canbomb_detonator/det = src.detonator_part

	if(istype(det))
		var/obj/item/device/timer/checked_timer = det.part_assembly.trigger
		if(checked_timer.time <= 10)
			src.controller.show_text("It's less than ten seconds left until the bomb blows up!", "red")
			return
		var/timing = checked_timer.timing
		checked_timer.time = 10
		det.failsafe_engage()

		if(timing)
			AIviewers(get_turf(src)) << SPAN_ALERT("<B>The [src] accelerates the priming process! <I>There are only 10 seconds left!!</I></B>")

/obj/item/device/brainjar/proc/detonate_tank_transfer_valve()
	set name = "Detonate bomb!"
	set desc = "Fulfill your destiny."
	set category = "Brain Jar"
	set src = usr.loc

	if(!istype(src.master, /obj/item/device/transfer_valve))
		boutput(usr, SPAN_ALERT("Interface failure with the valve controls!"))
		return

	var/obj/item/device/transfer_valve/TV = src.master

	if(alert("Blow up?", "im bomb.", "Yes", "No") != "Yes") return

	if(TV.valve_open)
		controller.show_text("The valve is already open, simmer down, feller.", "red")
		return

	controller.show_text("You open the valve on \the [TV]! [prob(20) ? "This is gonna be good!" : null]")
	TV.toggle_valve()
	logTheThing(LOG_BOMBING, controller, "opened the valve on a tank-transfer bomb.")

