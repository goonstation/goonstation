/datum/contextAction
	var/icon = 'icons/ui/context16x16.dmi'
	var/icon_state = "eye"
	var/icon_background = "bg"
	var/pip_icon = 'icons/ui/context_pips.dmi'
	var/pip_state = ""
	var/pip_enabled = FALSE
	var/name = ""
	var/desc = ""
	var/tooltip_flags = null
	var/use_tooltip = TRUE
	var/close_clicked = TRUE
	///Does the action close when the mob moves
	var/close_moved = TRUE
	var/flick_on_click = null
	var/text = ""
	var/background_color = null

	/// Is this action even allowed to show up under the given circumstances? TRUE=yes, FALSE=no
	proc/checkRequirements(atom/target, mob/user)
		. = FALSE

	/// Make sure that people are really allowed to do the thing they are doing in here. Double check equipped items, distance etc.
	proc/execute(atom/target, mob/user)
		. = 0

	proc/getIcon()
		. = icon

	/// If you want to dynamically change the icon. Cutting/mending wires on doors etc?
	proc/getIconState(atom/target, mob/user)
		. = icon_state

	proc/getBackground(atom/target, mob/user)
		. = icon_background

	proc/buildBackgroundIcon(atom/target, mob/user)
		. = null

	proc/getName(atom/target, mob/user)
		. = name

	proc/getDesc(atom/target, mob/user)
		. = desc

	proc/getTooltipFlags()
		. = tooltip_flags

	expandadd
		name = "expandadd"
		desc = "Test One"
		icon_state = "plus"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user) //Order is important for this. Remove first, add after. Always add the expansion button first.
			target.removeContextAction(/datum/contextAction/expandadd)
			target.addContextAction(/datum/contextAction/expandremove)
			target.addContextAction(/datum/contextAction/expandone)
			target.addContextAction(/datum/contextAction/expandtwo)
			target.addContextAction(/datum/contextAction/expandthree)
			var/list/contexts = user.checkContextActions(target)
			if(length(contexts))
				user.showContextActions(contexts, target)
			. = FALSE

	expandremove
		name = "expandremove"
		desc = "Test Two"
		icon_state = "minus"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user)
			target.removeContextAction(/datum/contextAction/expandremove)
			target.removeContextAction(/datum/contextAction/expandone)
			target.removeContextAction(/datum/contextAction/expandtwo)
			target.removeContextAction(/datum/contextAction/expandthree)
			target.addContextAction(/datum/contextAction/expandadd)
			var/list/contexts = user.checkContextActions(target)
			if(length(contexts))
				user.showContextActions(contexts, target)
			. = 0

	expandone
		name = "expandone"
		desc = "expandone"
		icon_state = "cog"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user)
			. = FALSE

	expandtwo
		name = "expandtwo"
		desc = "expandtwo"
		icon_state = "cog"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user)
			return 0

	expandthree
		name = "expandthree"
		desc = "expandthree"
		icon_state = "cog"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user)
			return 0

	testone
		name = "testone"
		desc = "Test One"
		icon_state = "plus"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user)
			target.addContextAction(/datum/contextAction/testtwo)
			return 0

	testtwo
		name = "testtwo"
		desc = "Test Two"
		icon_state = "plus"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user)
			target.addContextAction(/datum/contextAction/testthree)
			return 0

	testthree
		name = "testthree"
		desc = "Test three"
		icon_state = "plus"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user)
			target.addContextAction(/datum/contextAction/testfour)
			return 0

	testfour
		name = "testfour"
		desc = "Test four"
		icon_state = "minus"
		icon_background = "bg"

		checkRequirements(atom/target, mob/user)
			. = TRUE

		execute(atom/target, mob/user)
			target.removeContextAction(/datum/contextAction/testtwo)
			target.removeContextAction(/datum/contextAction/testthree)
			target.removeContextAction(/datum/contextAction/testfour)
			return 0


/datum/contextAction/ghost_respawn
	name = "ghost"
	desc = "Test"
	icon = 'icons/mob/ghost_observer_abilities.dmi'
	icon_state = "teleport"
	icon_background = ""

	checkRequirements(atom/target, mob/user)
		. = TRUE

	execute(atom/target, mob/user)
		user.closeContextActions()
		return 0

/datum/contextAction/ghost_respawn/close
	name = "Close"
	desc = "Close the menu"
	icon_state = "ghost-close"
	tooltip_flags = TOOLTIP_LEFT

/datum/contextAction/ghost_respawn/virtual_reality
	name = "Ghost VR"
	desc = "Enter ghost virtual reality"
	icon_state = "ghost-vr"
	tooltip_flags = TOOLTIP_LEFT

	execute(atom/target, mob/user)
		if (user && istype(user, /mob/dead/observer))
			var/mob/dead/observer/ghost = user
			SPAWN(1 DECI SECOND)
				ghost.go_to_vr()
		..()

/datum/contextAction/ghost_respawn/respawn_animal
	name = "Respawn Animal"
	desc = "Respawn as a tiny critter"
	icon_state = "respawn-animal"
	tooltip_flags = TOOLTIP_LEFT

	execute(atom/target, mob/user)
		if (user && istype(user, /mob/dead/observer))
			var/mob/dead/observer/ghost = user
			SPAWN(1 DECI SECOND)
				ghost.respawn_as_animal()
		..()

/datum/contextAction/ghost_respawn/respawn_mentor_mouse
	name = "Respawn As a Mentor Mouse"
	desc = "Respawn as a mentor mouse that people can pick up. You can whisper in their ears and click on their screen to point them in the right direction. Please don't abuse this."
	icon_state = "respawn-mentor-mouse"
	tooltip_flags = TOOLTIP_LEFT

	checkRequirements(atom/target, mob/user)
		. = user?.client && (user.client.holder || user.client.player.mentor)

	execute(atom/target, mob/user)
		if (user && istype(user, /mob/dead/observer))
			var/mob/dead/observer/ghost = user
			SPAWN(1 DECI SECOND)
				ghost.respawn_as_mentor_mouse()
		..()

/datum/contextAction/ghost_respawn/respawn_admin_mouse
	name = "Respawn As an Admin Mouse"
	desc = "Respawn as an admin mouse that people can pick up (or click on them to climb into their pockets). You can whisper in their ears and click on their screen to point them in the right direction. Be a little critter friend!"
	icon_state = "respawn-admin-mouse"
	tooltip_flags = TOOLTIP_LEFT

	checkRequirements(atom/target, mob/user)
		. = user?.client?.holder

	execute(atom/target, mob/user)
		if (user && istype(user, /mob/dead/observer))
			var/mob/dead/observer/ghost = user
			SPAWN(1 DECI SECOND)
				ghost.respawn_as_admin_mouse()
		..()

/datum/contextAction/ghost_respawn/ghostdrone
	name = "Ghost Drone"
	desc = "Step on the ghost catcher and be added to the ghost drone queue"
	icon_state = "ghost-drone"
	tooltip_flags = TOOLTIP_LEFT

	execute(atom/target, mob/user)
		if (user && istype(user, /mob/dead/observer))
			var/mob/dead/observer/ghost = user
			SPAWN(1 DECI SECOND)
				ghost.enter_ghostdrone_queue()
		..()

/datum/contextAction/ghost_respawn/afterlife_bar
	name = "Afterlife Bar"
	desc = "Enter the afterlife Bar"
	icon_state = "afterlife-bar"
	tooltip_flags = TOOLTIP_LEFT

	execute(atom/target, mob/user)
		if (user && istype(user, /mob/dead/observer))
			var/mob/dead/observer/ghost = user
			SPAWN(1 DECI SECOND)
				ghost.go_to_deadbar()
		..()

	// ghost_respawn/blobtutorial
	// 	name = "Blob Tutorial"
	// 	desc = "Practice blobbing around"
	// 	icon_state = "blob-tutorial"
	// 	tooltip_flags = TOOLTIP_LEFT

/datum/contextAction/wraith_spook_button
	name = "wraith"
	desc = "Test"
	icon = 'icons/ui/context32x32.dmi'
	icon_state = "minus"
	icon_background = ""
	var/ability_code = 0

	New(code as num)
		..()
		src.ability_code = code
		switch(code)
			if (1)
				name = "Flip light switches"
				desc = "Flip lights on/off in your area."
				icon_state = "wraith-switch"
			if (2)
				name = "Burn out lights"
				desc = "Break all lights in your area."
				icon_state = "wraith-break-lights"
			if (3)
				name = "Create smoke"
				desc = "Create a smoke that blinds mortals."
				icon_state = "wraith-smoke"
			if (4)
				name = "Create ectoplasm"
				desc = "Summon matter from your realm to you."
				icon_state = "wraith-ectoplasm"
			if (5)
				name = "Sap APC"
				desc = "Drain power from this apc sending it to your realm."
				icon_state = "wraith-apc"
			if (6)
				name = "Haunt PDAs"
				desc = "Haunt PDAs by sending them gruesome and spooky messages."
				icon_state = "wraith-pda"
			if (7)
				name = "Open things"
				desc = "Open doors, lockers, crates"
				icon_state = "wraith-doors"
			if (8)
				name = "random"
				desc = "selects one of the other choices at random to perform."
				icon_state = "wraith-random"

	checkRequirements(atom/target, mob/user)
		. = TRUE
		if (istype(target, /atom/movable/screen/ability/topBar/wraith))
			var/atom/movable/screen/ability/topBar/wraith/B = target
			if (istype(B.owner, /datum/targetable/wraithAbility/spook))
				var/datum/targetable/wraithAbility/spook/A = B.owner
				if (!A.cooldowncheck())
					return FALSE

	execute(atom/target, mob/user)
		if (istype(target, /atom/movable/screen/ability/topBar/wraith))
			var/atom/movable/screen/ability/topBar/wraith/B = target
			if (istype(B.owner, /datum/targetable/wraithAbility/spook))
				var/datum/targetable/wraithAbility/spook/A = B.owner
				A.do_spook_ability(ability_code)
				A.doCooldown()
		user.closeContextActions()
		return 0

/datum/contextAction/wraith_evolve_button
	name = "Specialize"
	desc = "Ascend into a stronger form"
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "minus"
	icon_background = ""
	var/ability_code = 0

	New(code as num)
		..()
		src.ability_code = code
		switch(code)
			if (1)
				name = "Plaguebringer"
				desc = "Become a disease spreading spirit."
				icon_state = "choose_plague"
			if (2)
				name = "Harbinger"
				desc = "Lead an army of otherworldly foes."
				icon_state = "choose_harbinger"
			if (3)
				name = "Trickster"
				desc = "Fool the crew with illusions and let them tear themselves apart."
				icon_state = "choose_trickster"

	checkRequirements(atom/target, mob/user)
		. = TRUE
		if (istype(target, /atom/movable/screen/ability/topBar/wraith))
			var/atom/movable/screen/ability/topBar/wraith/B = target
			if (istype(B.owner, /datum/targetable/wraithAbility/specialize))
				var/datum/targetable/wraithAbility/specialize/A = B.owner
				if (!A.cooldowncheck())
					return FALSE

	execute(atom/target, mob/user)
		if (istype(target, /atom/movable/screen/ability/topBar/wraith))
			var/atom/movable/screen/ability/topBar/wraith/B = target
			if (istype(B.owner, /datum/targetable/wraithAbility/specialize))
				var/datum/targetable/wraithAbility/specialize/A = B.owner
				A.evolve(ability_code)
				A.doCooldown()
		user.closeContextActions()
		return 0

/datum/contextAction/genebooth_product
	icon = 'icons/ui/context32x32.dmi'
	var/datum/geneboothproduct/GBP = null
	var/obj/machinery/genetics_booth/GB = null

	disposing()
		GBP = null
		GB = null
		..()

	execute(atom/target, mob/user)
		if (GB && GBP && (!GB.occupant || user == GB.occupant))
			GB.select_product(GBP)
		return 0

	checkRequirements(atom/target, mob/user)
		. = FALSE
		if(!can_act(user) || !in_interact_range(target, user) || GB.status & (NOPOWER | BROKEN))
			return FALSE
		if (GBP && GB && (BOUNDS_DIST(target, user) == 0 && isliving(user)) && !GB?.occupant)
			. = TRUE
			GB.show_admin_panel(user)

	buildBackgroundIcon(atom/target, mob/user)
		var/image/background = image('icons/ui/context32x32.dmi', src, "[getBackground(target, user)]0")
		background.appearance_flags = RESET_COLOR | PIXEL_SCALE
		. = background

	getIcon()
		if (GBP?.BE)
			. = GBP.BE.icon
		else
			. = ..()

	getIconState()
		if (GBP?.BE)
			. = GBP.BE.icon_state
		else
			. = ..()

	getName(atom/target, mob/user)
		if (GBP)
			. = GBP.name
		else
			. = ..()

	getDesc(atom/target, mob/user)
		if (GBP)
			. = "PRICE : [GBP.cost]<br>[GBP.desc]<br><br>There are [GBP.uses] applications left."
		else
			. = ..()

#define OMNI_TOOL_WAIT_TIME 0.5 SECONDS

/datum/contextAction/deconstruction
	icon = 'icons/ui/context16x16.dmi'
	name = "Deconstruct with Tool"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"
	var/omni_mode
	var/omni_path
	var/success_text
	var/success_sound

	proc/success_feedback(atom/target, mob/user)
		user.show_text(replacetext(success_text, "%target%", "[target]"), "blue")
		if (success_sound)
			playsound(target, success_sound, 50, TRUE)

	proc/omnitool_swap(atom/target, mob/user, obj/item/tool/omnitool/omni)
		if (!(omni_mode in omni.modes))
			return FALSE
		omni.change_mode(omni_mode, user, omni_path)
		user.show_text("You flip [omni] to [name] mode.", "blue")
		sleep(OMNI_TOOL_WAIT_TIME)
		return TRUE

	execute(atom/target, mob/user)
		if (isobj(target))
			var/obj/O = target
			if (O.decon_contexts)
				success_feedback(target, user)
				O.decon_contexts -= src
				if (length(O.decon_contexts) <= 0)
					user.show_text("Looks like [target] is ready to be deconstructed with the device.", "blue")
				else
					user.showContextActions(O.decon_contexts, O)
		else
			target.removeContextAction(src.type)

	checkRequirements(atom/target, mob/user)
		if(!can_act(user) || !in_interact_range(target, user))
			return FALSE
		. = FALSE
		//I don't think drones have hands technically but they can only hold one item anyway
		if(isghostdrone(user))
			return TRUE
		if(user.find_type_in_hand(/obj/item/deconstructor/))
			return TRUE

	wrench
		name = "Wrench"
		desc = "Wrenching required to deconstruct."
		icon_state = "wrench"
		omni_mode = OMNI_MODE_WRENCHING
		omni_path = /obj/item/wrench
		success_text = "You wrench %target%'s bolts."
		success_sound = 'sound/items/Ratchet.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user, I))
						return ..()
				if (iswrenchingtool(I))
					return ..()

	cut
		name = "Cut"
		desc = "Cutting required to deconstruct."
		icon_state = "cut"
		omni_mode = OMNI_MODE_SNIPPING
		omni_path = /obj/item/wirecutters
		success_text = "You cut some vestigial wires from %target%."
		success_sound = 'sound/items/Wirecutter.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user,I))
						return ..()
				if (iscuttingtool(I) || issnippingtool(I))
					return ..()
	weld
		name = "Weld"
		desc = "Welding required to deconstruct."
		icon_state = "weld"
		omni_mode = OMNI_MODE_WELDING
		omni_path = /obj/item/weldingtool
		success_text = "You weld %target% carefully."
		success_sound = null // sound handled in try_weld

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (isweldingtool(I))
					if (I:try_weld(user, 2))
						return ..()
				if(istype(I, /obj/item/tool/omnitool))
					var/obj/item/tool/omnitool/omni = I
					if(omnitool_swap(target, user,I))
						if (omni:try_weld(user, 2))
							return ..()

	pry
		name = "Pry"
		desc = "Prying required to deconstruct. Try a crowbar."
		icon_state = "bar"
		omni_mode = OMNI_MODE_PRYING
		omni_path = /obj/item/crowbar
		success_text = "You pry on %target% without remorse."
		success_sound = 'sound/items/Crowbar.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user, I))
						return ..()
				if (ispryingtool(I))
					return ..()
	screw
		name = "Screw"
		desc = "Screwing required to deconstruct."
		icon_state = "screw"
		omni_mode = OMNI_MODE_SCREWING
		omni_path = /obj/item/screwdriver
		success_text = "You unscrew some of the screws on %target%."
		success_sound = 'sound/items/Screwdriver.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user, I))
						return ..()
				if (isscrewingtool(I))
					return ..()

	pulse
		name = "Pulse"
		desc = "Pulsing required to deconstruct. Try a multitool."
		icon_state = "pulse"
		omni_mode = OMNI_MODE_PULSING
		omni_path = /obj/item/device/multitool
		success_text = "You pulse %target%. In a general sense."
		success_sound = 'sound/items/penclick.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user, I))
						return ..()
				if (ispulsingtool(I))
					return ..()

#undef OMNI_TOOL_WAIT_TIME

/datum/contextAction/vehicle
	icon = 'icons/ui/context16x16.dmi'
	name = "Vehicle action"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"

	execute(atom/target, mob/user)
		return

	checkRequirements(atom/target, mob/user)
		. = (user.loc == target) && can_act(user) && user.can_interface_with_pods

	board
		name = "Board"
		desc = "Hop on."
		icon_state = "board"

		checkRequirements(atom/target, mob/user)
			var/obj/machinery/vehicle/V = target
			. = ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null && !isAI(user) && user.can_interface_with_pods)

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.board()

	eject_occupants
		name = "Eject Occupants"
		desc = "Force occupants out of the vehicle."
		icon_state = "exit"

		checkRequirements(atom/target, mob/user)
			var/obj/machinery/vehicle/V = target
			. = ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null && !isAI(user) && user.can_interface_with_pods)

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.eject_occupants()

	lock
		name = "Show Lock Panel"
		desc = "Unlock the ship."
		icon_state = "lock"

		checkRequirements(atom/target, mob/user)
			var/obj/machinery/vehicle/V = target
			if (V.locked && V.lock)
				. = ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null && !isAI(user) && user.can_interface_with_pods)

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.lock.show_lock_panel(user,0)

	parts
		name = "Show Parts Panel"
		desc = "Replace ship parts."
		icon_state = "panel"

		checkRequirements(atom/target, mob/user)
			var/obj/machinery/vehicle/V = target
			. = ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null && !isAI(user) && user.can_interface_with_pods)

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.open_parts_panel(user)


	exit_ship
		name = "Exit Ship"
		desc = "Hop off."
		icon_state = "exit"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.exit_ship()

	access_main_computer
		name = "Access Main Computer"
		desc = "Manage some ship functions."
		icon_state = "computer"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.access_main_computer()

	use_external_speaker
		name = "Use External Speaker"
		desc = "Talk to people with your ship intercom."
		icon_state = "speaker"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.use_external_speaker()

	change_thruster_direction
		name = "Lateral Thruster Direction"
		desc = "Change the lateral thrusters to move the ship left"
		icon_state = "thrusters_left"

		checkRequirements(atom/target, mob/user)
			var/obj/machinery/vehicle/V = target
			. = ..() && istype(V.sec_system, /obj/item/shipcomponent/secondary_system/thrusters/lateral)

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			var/obj/item/shipcomponent/secondary_system/thrusters/lateral/thrusters = V.sec_system
			thrusters.change_thruster_direction()
			if (src.icon_state == "thrusters_right")
				src.desc = "Change the lateral thrusters to move the ship left"
				src.icon_state = "thrusters_left"
			else
				src.desc = "Change the lateral thrusters to move the ship right"
				src.icon_state = "thrusters_right"

/datum/contextAction/cellphone
	name = "Cellphone action"
	desc = "You shouldn't see this, bug!"
	icon_state = "wrench"

	checkRequirements(atom/target, mob/user)
		. = (target.loc == user && user.equipped() == target)

	/*mail
		name = "Check Mail"
		desc = "Well aren't you popular?"
		icon_state = "mail"*/

	tetris
		name = "Play Tetris"
		desc = "The wonders of technology!"
		icon_state = "tetris"

		execute(atom/target, mob/user)
			..()
			var/obj/item/toy/cellphone/C = target
			C.icon_state = "cellphone-tetris"
			C.add_dialog(user)
			C.tetris.new_game(user)


/datum/contextAction/instrument
	icon = 'icons/ui/context16x16.dmi'
	name = "Play Note"
	desc = "Click me to play a note!"
	icon_state = "note"
	use_tooltip = 0
	close_clicked = 0
	icon_background = "key"
	flick_on_click = "key2"

	var/note = 0

	execute(atom/target, mob/user)
		var/obj/item/instrument/I = target
		I.play_note(note,user)

	checkRequirements(atom/target, mob/user)
		. = ((user.equipped() == target) || target.density && target.loc == get_turf(target) && BOUNDS_DIST(user, target) == 0 && istype(target,/obj/item/instrument))

	special
		icon_background = "key_special"

	black
		icon_background = "keyb"


/datum/contextAction/kudzu
	icon = 'icons/ui/context16x16.dmi'
	name = "Deconstruct with Tool"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"

	var/creation_path = null	//object to create
	var/extra_time = 0

	execute(atom/target, mob/user)
		playsound(user.loc, 'sound/effects/pop.ogg', 50, 1)
		actions.start(new/datum/action/bar/icon/kudzu_shaping(target,user, creation_path, extra_time), user)

	checkRequirements(atom/target, mob/user)
		if(!can_act(user) || !in_interact_range(target, user))
			return FALSE
		. = FALSE
		if (istype(target, /obj/spacevine))
			var/obj/spacevine/K = target
			if (K.growth >= 20 && istype(user.equipped(), /obj/item/kudzu/kudzumen_vine))
				return TRUE

	plantpot
		name = "Plant pot"
		desc = "Create a plant pot."
		icon_state = "kudzu-plantpot"
		creation_path = /obj/machinery/plantpot/kudzu

		execute(atom/target, mob/user)
			boutput(user, "Shaping [target] into a plantpot, please remain still...")
			extra_time = 2 SECONDS
			. = ..()

	plantmaster
		name = "Kudzu Plantmaster"
		desc = "Create a plantmaster."
		icon_state = "computer"	//"kudzu-plantmaster"
		creation_path = /obj/submachine/seed_manipulator/kudzu

		execute(atom/target, mob/user)
			boutput(user, "Shaping [target] into a plantmaster, please remain still...")
			extra_time = 5 SECONDS
			. = ..()

/datum/contextAction/cake
	icon = 'icons/ui/context16x16.dmi'
	name = "Cake action"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"

	checkRequirements(var/atom/target, var/mob/user)
		. = can_act(user) && in_interact_range(target, user)

	unstack
		name = "Remove Layer"
		desc = "Remove a layer of cake."
		icon_state = "unstack"

		execute(var/atom/target, var/mob/user)
			var/obj/item/reagent_containers/food/snacks/cake/c = target
			c.unstack(user)

	candle
		name = "Extinguish"
		desc = "Blow out the cake's candle."
		icon_state = "candle"

		execute(var/atom/target, var/mob/user)
			var/obj/item/reagent_containers/food/snacks/cake/c = target
			c.extinguish(user)

	pickup
		name = "Pick Up"
		desc = "Pick up the cake."
		icon_state = "up_arrow"

		execute(var/atom/target, var/mob/user)
			var/obj/item/c = target
			if(c.loc == user)
				user.u_equip(c)
			user.put_in_hand_or_drop(c)

/datum/contextAction/lamp_manufacturer
	name = "Lamp Manufacturer Setting"
	desc = "This button seems kinda meta."
	icon_state = "dismiss"

	checkRequirements(var/atom/target, var/mob/user)
		. = can_act(user) && in_interact_range(target, user)

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		if (M.removing_toggled)
			M.set_icon_state("[M.prefix]-remove")
		else
			M.set_icon_state("[M.prefix]-[M.setting]")
		M.tooltip_rebuild = 1

/datum/contextAction/lamp_manufacturer/col_page_1/to_page_2
	name = "Page 2"
	desc = "Switch to a palette of milder colors."
	icon_state = "page_2"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		var/datum/contextLayout/experimentalcircle/layout = M.contextLayout
		layout.dist = 40 //more options, bigger
		M.setting_context_actions = M.page_2_actions + M.common_actions
		M.AttackSelf(user)
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/to_page_1
	name = "Page 1"
	desc = "Switch to a palette of flashier colors."
	icon_state = "page_1"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		var/datum/contextLayout/experimentalcircle/layout = M.contextLayout
		layout.dist = 34 //less options, smaller
		M.setting_context_actions = M.page_1_actions + M.common_actions
		M.AttackSelf(user)
		..()

/datum/contextAction/lamp_manufacturer/col_page_1/white
	name = "Set White"
	desc = "Sets the manufacturer to produce white lamps."
	icon_state = "white"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "white"
		M.dispensing_tube = /obj/item/light/tube
		M.dispensing_bulb = /obj/item/light/bulb
		..()

/datum/contextAction/lamp_manufacturer/col_page_1/red
	name = "Set Red"
	desc = "Sets the manufacturer to produce red lamps."
	icon_state = "red"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "red"
		M.dispensing_tube = /obj/item/light/tube/red
		M.dispensing_bulb = /obj/item/light/bulb/red
		..()

/datum/contextAction/lamp_manufacturer/col_page_1/yellow
	name = "Set Yellow"
	desc = "Sets the manufacturer to produce yellow lamps."
	icon_state = "yellow"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "yellow"
		M.dispensing_tube = /obj/item/light/tube/yellow
		M.dispensing_bulb = /obj/item/light/bulb/yellow
		..()

/datum/contextAction/lamp_manufacturer/col_page_1/green
	name = "Set Green"
	desc = "Sets the manufacturer to produce green lamps."
	icon_state = "green"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "green"
		M.dispensing_tube = /obj/item/light/tube/green
		M.dispensing_bulb = /obj/item/light/bulb/green
		..()

/datum/contextAction/lamp_manufacturer/col_page_1/cyan
	name = "Set Cyan"
	desc = "Sets the manufacturer to produce cyan lamps."
	icon_state = "cyan"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "cyan"
		M.dispensing_tube = /obj/item/light/tube/cyan
		M.dispensing_bulb = /obj/item/light/bulb/cyan
		..()

/datum/contextAction/lamp_manufacturer/col_page_1/blue
	name = "Set Blue"
	desc = "Sets the manufacturer to produce blue lamps."
	icon_state = "blue"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "blue"
		M.dispensing_tube = /obj/item/light/tube/blue
		M.dispensing_bulb = /obj/item/light/bulb/blue
		..()

/datum/contextAction/lamp_manufacturer/col_page_1/purple
	name = "Set Purple"
	desc = "Sets the manufacturer to produce purple lamps."
	icon_state = "purple"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "purple"
		M.dispensing_tube = /obj/item/light/tube/purple
		M.dispensing_bulb = /obj/item/light/bulb/purple
		..()

/datum/contextAction/lamp_manufacturer/col_page_1/blacklight
	name = "Set Blacklight"
	desc = "Sets the manufacturer to produce blacklight lamps."
	icon_state = "blacklight"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "blacklight"
		M.dispensing_tube = /obj/item/light/tube/blacklight
		M.dispensing_bulb = /obj/item/light/bulb/blacklight
		..()

//work harder, not smarter
/datum/contextAction/lamp_manufacturer/col_page_2/cool
	name = "Set Cool"
	desc = "Sets the manufacturer to produce cool lamps."
	icon_state = "cool"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "cool"
		M.dispensing_tube = /obj/item/light/tube/cool
		M.dispensing_bulb = /obj/item/light/bulb/cool
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/very_cool
	name = "Set Very Cool"
	desc = "Sets the manufacturer to produce very cool lamps. Very cool as in colour temperature, the lamps themselves don't enjoy significant reputations."
	icon_state = "very_cool"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "very cool"
		M.dispensing_tube = /obj/item/light/tube/cool/very
		M.dispensing_bulb = /obj/item/light/bulb/cool/very
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/warm
	name = "Set Warm"
	desc = "Sets the manufacturer to produce warm lamps."
	icon_state = "warm"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "warm"
		M.dispensing_tube = /obj/item/light/tube/warm
		M.dispensing_bulb = /obj/item/light/bulb/warm
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/very_warm
	name = "Set Very Warm"
	desc = "Sets the manufacturer to produce very warm lamps."
	icon_state = "very_warm"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "very warm"
		M.dispensing_tube = /obj/item/light/tube/warm/very
		M.dispensing_bulb = /obj/item/light/bulb/warm/very
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/harsh
	name = "Set Harsh"
	desc = "Sets the manufacturer to produce harsh lamps."
	icon_state = "harsh"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "harsh"
		M.dispensing_tube = /obj/item/light/tube/harsh
		M.dispensing_bulb = /obj/item/light/bulb/harsh
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/very_harsh
	name = "Set Very Harsh"
	desc = "Sets the manufacturer to produce very harsh lamps."
	icon_state = "very_harsh"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "very harsh"
		M.dispensing_tube = /obj/item/light/tube/harsh/very
		M.dispensing_bulb = /obj/item/light/bulb/harsh/very
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/reddish
	name = "Set Reddish"
	desc = "Sets the manufacturer to produce reddish lamps."
	icon_state = "reddish"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "reddish"
		M.dispensing_tube = /obj/item/light/tube/reddish
		M.dispensing_bulb = /obj/item/light/bulb/reddish
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/yellowish
	name = "Set Yellowish"
	desc = "Sets the manufacturer to produce yellowish lamps."
	icon_state = "yellowish"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "yellowish"
		M.dispensing_tube = /obj/item/light/tube/yellowish
		M.dispensing_bulb = /obj/item/light/bulb/yellowish
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/greenish
	name = "Set Greenish"
	desc = "Sets the manufacturer to produce greenish lamps."
	icon_state = "greenish"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "greenish"
		M.dispensing_tube = /obj/item/light/tube/greenish
		M.dispensing_bulb = /obj/item/light/bulb/greenish
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/blueish
	name = "Set Blueish"
	desc = "Sets the manufacturer to produce blueish lamps."
	icon_state = "blueish"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "blueish"
		M.dispensing_tube = /obj/item/light/tube/blueish
		M.dispensing_bulb = /obj/item/light/bulb/blueish
		..()

/datum/contextAction/lamp_manufacturer/col_page_2/purpleish
	name = "Set Purpleish"
	desc = "Sets the manufacturer to produce purpleish lamps."
	icon_state = "purpleish"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.setting = "purpleish"
		M.dispensing_tube = /obj/item/light/tube/purpleish
		M.dispensing_bulb = /obj/item/light/bulb/purpleish
		..()

/datum/contextAction/lamp_manufacturer/setting/tubes
	name = "Fitting Production: Tubes"
	desc = "Sets the manufacturer to produce tube wall fittings."
	icon_state = "tube"

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.dispensing_fitting = /obj/machinery/light
		..()

/datum/contextAction/lamp_manufacturer/setting/bulbs
	name = "Fitting Production: Bulbs"
	desc = "Sets the manufacturer to produce bulb wall fittings."
	icon_state = "bulb"
	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.dispensing_fitting = /obj/machinery/light/small
		..()

/datum/contextAction/lamp_manufacturer/setting/removal
	name = "Toggle Fitting Removal"
	desc = "Toggles the manufacturer between removing fittings and replacing lamps."
	icon_state = "remove"
	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		M.removing_toggled = !M.removing_toggled
		boutput(user, "<span class='notice'>Now set to [M.removing_toggled == TRUE ? "remove fittings" : "replace lamps"].</span>")
		..()

/datum/contextAction/card
	icon = 'icons/ui/context16x16.dmi'
	name = "Card action"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"

	checkRequirements(var/atom/target, var/mob/user)
		. = can_act(user) && in_interact_range(target, user)

	solitaire
		name = "Solitaire Stack"
		desc = "Stack cards with a slight offset."
		icon_state = "solitaire"

		execute(var/atom/target, var/mob/user)
			var/obj/item/playing_card/card = target
			card.solitaire(user)

	fan
		name = "Fan"
		desc = "Spread the cards into an easily readable fan."
		icon_state = "fan"

		execute(var/atom/target, var/mob/user)
			if(istype(target,/obj/item/playing_card))
				var/obj/item/playing_card/card = target
				card.deck_or_hand(user,TRUE)
			else if(istype(target,/obj/item/card_group))
				var/obj/item/card_group/group = target
				group.fan(user)

	stack
		name = "Stack"
		desc = "Gather the cards into a deck."
		icon_state = "stack"

		execute(var/atom/target, var/mob/user)
			if(istype(target,/obj/item/playing_card))
				var/obj/item/playing_card/card = target
				card.deck_or_hand(user)
			else if(istype(target,/obj/item/card_group))
				var/obj/item/card_group/group = target
				group.stack(user)

	draw
		name = "Draw"
		desc = "Add a card to your hand."
		icon_state = "draw"

		execute(var/atom/target, var/mob/user)
			var/obj/item/card_group/card = target
			card.draw(user)

	draw_facedown
		name = "Draw Face-down"
		desc = "Add a card to your hand face-down."
		icon_state = "draw_facedown"

		execute(var/atom/target, var/mob/user)
			var/obj/item/card_group/card = target
			card.draw(user,1)

	draw_multiple
		name = "Draw Multiple Cards"
		desc = "Add many cards to your hand."
		icon_state = "multiple"

		execute(var/atom/target, var/mob/user)
			var/obj/item/card_group/card = target
			card.draw_multiple(user)

	topdeck
		name = "Add to Top"
		desc = "Add cards to the top of the deck."
		icon_state = "deck_top"

		execute(var/atom/target, var/mob/user)
			var/obj/item/card_group/group = target
			group.top_or_bottom(user,user.equipped(),"top")

	bottomdeck
		name = "Add to Bottom"
		desc = "Add cards to the top of the deck."
		icon_state = "deck_bottom"

		execute(var/atom/target, var/mob/user)
			var/obj/item/card_group/card = target
			card.top_or_bottom(user,user.equipped(),"bottom")

	search
		name = "Search"
		desc = "Search for a card."
		icon_state = "search"

		execute(var/atom/target, var/mob/user)
			var/obj/item/card_group/group = target
			group.search(user)

	reveal
		name = "Reveal"
		desc = "Reveal the cards to all players nearby."
		icon_state = "eye"

		execute(var/atom/target, var/mob/user)
			var/obj/item/card_group/group = target
			group.reveal(user)

	pickup
		name = "Pick Up"
		desc = "Pick up cards."
		icon_state = "up_arrow"

		execute(var/atom/target, var/mob/user)
			var/obj/item/cards = target
			if(cards.loc == user) //checks hand for card to allow taking from pockets/storage
				user.u_equip(cards)
			user.put_in_hand_or_drop(cards)

	close
		name = "Close"
		desc = "Close this menu."
		icon_state = "close"

		execute(var/atom/target, var/mob/user)
			user.closeContextActions()

/*
	offered
		icon = null
		icon_background = null

		maptext = "<span class='ps2p ol vt c' style='color: #f00;'>Do you want to?</span>"
		charge.maptext_y = -5
		charge.maptext_width = 96
		charge.maptext_x = -9

		execute(atom/target, mob/user)
			.= 0

		checkRequirements(atom/target, mob/user)
			.= 0

		item
			var/obj/item/I = null

			disposing()
				I = null
				..()

			buildBackgroundIcon-(atom/target, mob/user)
				var/image/background = image('icons/ui/context32x32.dmi', src, "[getBackground(target, user)]0")
				background.appearance_flags = RESET_COLOR | PIXEL_SCALE
				.= background


			getIcon()
				if (I)
					.= I.icon
				else
					..()

			getIconState()
				if (I)
					.= I.icon_state
				else
					..()

			getName(atom/target, mob/user)
				if (I)
					.= I.name
				else
					..()

			getDesc(atom/target, mob/user)
				if (I)
					.= I.desc
				else
					..()

	accept
		icon_state = "yes"
		var/datum/yesno_dialog/give_dialog = null

		checkRequirements(atom/target, mob/user)
			return 1

		execute(atom/target, mob/user)
			target.addContextAction(/datum/contextAction/testfour)
			return 0

	refuse
		icon_state = "no"
		var/datum/yesno_dialog/give_dialog = null


		checkRequirements(atom/target, mob/user)
			return 1

		execute(atom/target, mob/user)
			target.addContextAction(/datum/contextAction/testfour)
			return 0
*/

/datum/contextAction/rcd
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	desc = ""
	icon_state = "wrench"
	var/mode = RCD_MODE_FLOORSWALLS

	execute(var/obj/item/rcd/rcd, var/mob/user)
		if (!istype(rcd))
			return
		rcd.switch_mode(src.mode, user)

	checkRequirements(var/obj/item/rcd/rcd, var/mob/user)
		if(!can_act(user) || !in_interact_range(rcd, user))
			return FALSE
		return rcd in user

	deconstruct
		name = "Deconstruct"
		icon_state = "close"
		mode = RCD_MODE_DECONSTRUCT
	airlock
		name = "Airlocks"
		icon_state = "door"
		mode = RCD_MODE_AIRLOCK
	floorswalls
		name = "Floors/walls"
		icon_state = "wall"
		mode = RCD_MODE_FLOORSWALLS
	lighttubes
		name = "Light tubes"
		icon_state = "tube"
		mode = RCD_MODE_LIGHTTUBES
	lightbulbs
		name = "Lightbulbs"
		icon_state = "bulb"
		mode = RCD_MODE_LIGHTBULBS
	windows
		name = "Windows"
		icon_state = "window"
		mode = RCD_MODE_WINDOWS

/datum/contextAction/reagent
	icon_background = "whitebg"
	icon_state = "note"
	var/reagent_id = ""

	New(var/reagent_id)
		..()
		src.reagent_id = reagent_id || src.reagent_id
		var/datum/reagent/reagent = reagents_cache[reagent_id]
		if (!istype(reagent))
			return
		src.background_color = rgb(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b)
		src.text = reagent_shorthands[reagent_id] || copytext(capitalize(reagent.name), 1, 3)
		src.name = capitalize(reagent.name)

/datum/contextAction/reagent/robospray
	close_moved = FALSE
	checkRequirements(var/obj/item/robospray/robospray, var/mob/user)
		return robospray in user
	execute(var/obj/item/robospray/robospray, var/mob/user)
		robospray.change_reagent(src.reagent_id, user)

/// surgical step - performs a step of a surgery
/datum/contextAction/surgical_step
	name = "Generic Surgery Step"
	desc = "Call 1-800-IMCODER."
	icon_state = "heal_generic"
	var/datum/surgery_step/step = null
	var/datum/surgery/surgery = null
	pip_enabled = TRUE

	checkRequirements(atom/target, mob/user)
		return TRUE

	execute(atom/target, mob/user)
		..()
		var/obj/item/I = user.equipped()
		surgery.perform_step(step, user,I)

/// surgery context menu - starts/continues a surgery
/datum/contextAction/surgery
	name = "Generic Surgery"
	desc = "Call 1-800-IMCODER."
	icon_state = "heal_generic"
	var/datum/surgeryHolder/holder = null
	var/datum/surgery/surgery = null
	checkRequirements(atom/target, mob/user)
		..()
		return TRUE
	execute(atom/target, mob/user)
		..()
		var/obj/item/I = user.equipped()
		holder.surgery_clicked(surgery,user,I)
/datum/contextAction/surgery/cancel
	name = "Cancel"
	desc = "Cancels this surgery, and all surgeries beneath it."
	icon_state = "cancel"

	New(var/datum/surgeryHolder/holder, var/datum/surgery/surgery)
		src.holder = holder
		src.surgery = surgery
		name = "Cancel [surgery?.name]"
		..()
	execute(atom/target, mob/user)
		..()
		user.closeContextActions()
		var/obj/item/I = user.equipped()
		holder.cancel_surgery_context(surgery,user,I)
/datum/contextAction/surgery/step_up
	name = "Back"
	desc = "Go up a level."
	icon_state = "back_arrow"

	New(var/datum/surgeryHolder/holder, var/datum/surgery/surgery)
		src.holder = holder
		src.surgery = surgery
		..()
	execute(atom/target, mob/user)
		..()
		user.closeContextActions()
		var/obj/item/I = user.equipped()
		holder.exit_surgery(surgery,user,I)


#define BUNSEN_OFF "off"
#define BUNSEN_LOW "low"
#define BUNSEN_MEDIUM "medium"
#define BUNSEN_HIGH "high"

/datum/contextAction/bunsen
	icon = 'icons/ui/context16x16.dmi'
	name = "you shouldnt see me"
	icon_state = "wrench"
	icon_background = "bunsen_bg"
	use_tooltip = FALSE
	close_moved = TRUE

	var/temperature = null

	checkRequirements(var/obj/item/bunsen_burner/bunsen_burner, var/mob/user)
		if(!can_act(user) || !in_interact_range(bunsen_burner, user))
			return FALSE
		if(GET_DIST(bunsen_burner, user) > 1)
			return FALSE
		else
			return TRUE

	execute(var/obj/item/bunsen_burner/bunsen_burner, mob/user)
		bunsen_burner.change_status(temperature)
		bunsen_burner.UpdateIcon()
		boutput(user, SPAN_NOTICE("You set the [bunsen_burner] to [temperature]."))

	heat_off
		name = "Off"
		icon_state = "bunsen_off"

		execute(var/obj/item/bunsen_burner/bunsen_burner, mob/user)
			bunsen_burner.change_status(BUNSEN_OFF)
			boutput(user, SPAN_NOTICE("You turn the [bunsen_burner] off."))
			bunsen_burner.UpdateIcon()

	heat_low
		name = "Low"
		icon_state = "bunsen_1"
		temperature = BUNSEN_LOW

	heat_medium
		name = "Medium"
		icon_state = "bunsen_2"
		temperature = BUNSEN_MEDIUM

	heat_high
		name = "High"
		icon_state = "bunsen_3"
		temperature = BUNSEN_HIGH

#undef BUNSEN_OFF
#undef BUNSEN_LOW
#undef BUNSEN_MEDIUM
#undef BUNSEN_HIGH
/datum/contextAction/t_scanner
	icon = 'icons/ui/context16x16.dmi'
	icon_state = "dismiss"
	close_clicked = TRUE
	close_moved = FALSE
	var/base_icon_state = ""

	checkRequirements(var/obj/item/device/t_scanner/t_scanner, mob/user)
		if(!can_act(user) || !in_interact_range(t_scanner, user))
			return FALSE
		return t_scanner in user

	active
		name = "Active"
		desc = "Toggle T-ray scanner"
		icon_state = "tray_scanner_off"
		base_icon_state = "tray_scanner_"

		execute(var/obj/item/device/t_scanner/t_scanner, mob/user)
			t_scanner.set_on(!t_scanner.on)
			var/obj/ability_button/tscanner_toggle/tscanner_button = locate(/obj/ability_button/tscanner_toggle) in t_scanner.ability_buttons
			tscanner_button.icon_state = t_scanner.on ? "tray_on" : "tray_off"

	underfloor_cables
		name = "Cables"
		desc = "Current underfloor cables"
		icon_state = "tray_cable_on"
		base_icon_state = "tray_cable_"

		execute(obj/item/device/t_scanner/t_scanner, mob/user)
			t_scanner.set_underfloor_cables(!t_scanner.show_underfloor_cables, user)

	underfloor_disposal_pipes
		name = "Disposal Pipes"
		desc = "Current underfloor disposal pipes"
		icon_state = "tray_pipes_on"
		base_icon_state = "tray_pipes_"

		execute(obj/item/device/t_scanner/t_scanner, mob/user)
			t_scanner.set_underfloor_disposal_pipes(!t_scanner.show_underfloor_disposal_pipes, user)

	blueprint_disposal_pipes
		name = "Pipe Blueprints"
		desc = "Original pipe blueprints"
		icon_state = "tray_blueprint_on"
		base_icon_state = "tray_blueprint_"

		execute(obj/item/device/t_scanner/t_scanner, mob/user)
			t_scanner.set_blueprint_disposal_pipes(!t_scanner.show_blueprint_disposal_pipes, user)

/datum/contextAction/speech_pro
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	desc = ""
	icon_state = "hey"
	var/speech_text = "Hello!"
	var/speech_sound = 'sound/misc/talk/cyborg_exclaim.ogg'
	var/phrase = SPEECH_PRO_SAY_HELLO

	execute(var/obj/item/device/speech_pro/sp, var/mob/user)
		if (!istype(sp, /obj/item/device/speech_pro))
			return
		if (!ON_COOLDOWN(user, "use_speech_pro", 3 SECONDS))
			sp.speak(src.speech_text, user)
			playsound(sp, src.speech_sound, 50, 1)
		else
			boutput(user, SPAN_ALERT("Your [sp] is still loading..."))

	checkRequirements(var/obj/item/device/speech_pro/sp, var/mob/user)
		if(!can_act(user))
			return FALSE
		return sp == user.equipped()

	greeting
		name = "Greeting"
		icon_state = "hey"
		phrase = SPEECH_PRO_SAY_HELLO
		speech_text = "Hello!"
		speech_sound = 'sound/misc/talk/cyborg_exclaim.ogg'

	farewell
		name = "Farewell"
		icon_state = "bye"
		phrase = SPEECH_PRO_SAY_BYE
		speech_text = "Goodbye!"
		speech_sound = 'sound/misc/talk/cyborg_exclaim.ogg'

	assistance
		name = "Assistance"
		icon_state = "caution"
		phrase = SPEECH_PRO_SAY_HELP
		speech_text = "I require assistance."
		speech_sound = 'sound/misc/talk/cyborg.ogg'

	confusion
		name = "Confusion"
		icon_state = "what"
		phrase = SPEECH_PRO_SAY_WHAT
		speech_text = "I don't understand."
		speech_sound = 'sound/misc/talk/cyborg_ask.ogg'

	gratitude
		name = "Gratitude"
		icon_state = "thx"
		phrase = SPEECH_PRO_SAY_THX
		speech_text = "Thank you."
		speech_sound = 'sound/misc/talk/cyborg.ogg'

	apology
		name = "Apology"
		icon_state = "sry"
		phrase = SPEECH_PRO_SAY_SRY
		speech_text = "I'm sorry."
		speech_sound = 'sound/misc/talk/cyborg.ogg'

	congratulations
		name = "Congratulations"
		icon_state = "happy_face"
		phrase = SPEECH_PRO_SAY_GJ
		speech_text = "Good job!"
		speech_sound = 'sound/misc/talk/cyborg_exclaim.ogg'

	wait
		name = "Wait"
		icon_state = "wait"
		phrase = SPEECH_PRO_SAY_WAIT
		speech_text = "Please wait."
		speech_sound = 'sound/misc/talk/cyborg_ask.ogg'

	affirmation
		name = "Affirmation"
		icon_state = "yes"
		phrase = SPEECH_PRO_SAY_YES
		speech_text = "Yes."
		speech_sound = 'sound/misc/talk/cyborg.ogg'

	rejection
		name = "Rejection"
		icon_state = "no"
		phrase = SPEECH_PRO_SAY_NO
		speech_text = "No."
		speech_sound = 'sound/misc/talk/cyborg.ogg'

	follow
		name = "Follow"
		icon_state = "board"
		phrase = SPEECH_PRO_SAY_FOLLOW
		speech_text = "Follow me."
		speech_sound = 'sound/misc/talk/cyborg.ogg'

	explanation
		name = "Explanation"
		icon_state = "computer"
		phrase = SPEECH_PRO_SAY_SP
		speech_text = "I am using a Speech Pro."
		speech_sound = 'sound/misc/talk/cyborg_exclaim.ogg'
