/datum/contextAction
	var/icon = 'icons/ui/context16x16.dmi'
	var/icon_state = "eye"
	var/icon_background = "bg"
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

/// Organ context action to pick a region to operate on
/datum/contextAction/surgery_region
	name = "Open up surgery region"
	icon = 'icons/ui/context16x16.dmi'
	icon_state = "heart"
	var/organ = null
	var/organ_path
	var/surgery_flags = SURGERY_NONE

	execute(atom/target, mob/user)
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (!surgeryCheck(H, user))
				return

	checkRequirements(atom/target, mob/user)
		if(!can_act(user) || !in_interact_range(target, user))
			return FALSE
		if (user.equipped())
			var/obj/item/I = user.equipped()
			if (iscuttingtool(I) || issnippingtool(I) || issawingtool(I))
				return TRUE
		boutput(user, SPAN_NOTICE("You need some sort of surgery tool!"))
		return FALSE

	New(var/region_state = null)
		..()
		switch (region_state)
			if (REGION_CLOSED)
				src.icon_background = "bg"
			if (REGION_HALFWAY)
				src.icon_background = "yellowbg"
			if (REGION_OPENED)
				src.icon_background = "greenbg"

	implant
		name = "implant"
		desc = "Cut out an implant"
		icon_state = "implant"

		execute(atom/target, mob/user)
			if (!istype(target, /mob/living))
				return
			var/mob/living/patient = target
			if (!surgeryCheck(patient, user))
				return
			for (var/obj/item/implant/I in patient.implant)

				// This is kinda important (Convair880).
				if (istype(I, /obj/item/implant/mindhack) && user == patient)
					var/obj/item/implant/mindhack/implant = I
					if (patient != implant.implant_hacker)
						continue

				if (!istype(I, /obj/item/implant/artifact))
					user.tri_message(patient, SPAN_ALERT("<b>[user]</b> cuts out an implant from [patient == user ? "[him_or_her(patient)]self" : "[patient]"] with [src]!"),\
						SPAN_ALERT("You cut out an implant from [user == patient ? "yourself" : "[patient]"] with [src]!"),\
						SPAN_ALERT("[patient == user ? "You cut" : "<b>[user]</b> cuts"] out an implant from you with [src]!"))

					var/obj/item/implantcase/newcase = new /obj/item/implantcase(patient.loc, usedimplant = I)
					newcase.pixel_x = rand(-2, 5)
					newcase.pixel_y = rand(-6, 1)
					I.on_remove(patient)
					patient.implant.Remove(I)
					var/image/wadblood = image('icons/obj/surgery.dmi', icon_state = "implantpaper-blood")
					wadblood.color = patient.blood_color
					newcase.AddOverlays(wadblood, "blood")
					newcase.blood_DNA = patient.bioHolder.Uid
					newcase.blood_type = patient.bioHolder.bloodType
				else
					var/obj/item/implant/artifact/imp = I
					if (imp.cant_take_out)
						user.tri_message(patient, SPAN_ALERT("<b>[user]</b> tries to cut out something from [patient == user ? "[him_or_her(patient)]self" : "[patient]"] with [src]!"),\
							SPAN_ALERT("Whatever you try to cut out from [user == patient ? "yourself" : "[patient]"] won't come out!"),\
							SPAN_ALERT("[patient == user ? "You try to cut" : "<b>[user]</b> tries to cut"] out something from you with [src]!"))
					else
						user.tri_message(patient, SPAN_ALERT("<b>[user]</b> cuts out something alien from [patient == user ? "[him_or_her(patient)]self" : "[patient]"] with [src]!"),\
							SPAN_ALERT("You cut out something alien from [user == patient ? "yourself" : "[patient]"] with [src]!"),\
							SPAN_ALERT("[patient == user ? "You cut" : "<b>[user]</b> cuts"] out something alien from you with [src]!"))
						imp.pixel_x = rand(-2, 5)
						imp.pixel_y = rand(-6, 1)
						imp.set_loc(get_turf(patient))
						imp.on_remove(patient)
						patient.implant.Remove(imp)
				return TRUE

	parasite
		name = "parasite"
		desc = "Cut out one or multiple parasites"
		icon_state = "parasite"
		organ_path = "appendix"

		execute(atom/target, mob/user)
			if (!ishuman(target))
				return
			var/mob/living/carbon/human/H = target
			if (!surgeryCheck(H, user))
				return
			var/attempted_parasite_removal = 0
			for (var/datum/ailment_data/an_ailment in H.ailments)
				if (an_ailment.cure_flags & CURE_SURGERY)
					attempted_parasite_removal = 1
					var/success = an_ailment.surgery(user, H)
					if (success)
						H.cure_disease(an_ailment) // surgeon.cure_disease(an_ailment) no, doctor, DO NOT HEAL THYSELF, HEAL THY PATIENT
					else
						break

					if (attempted_parasite_removal == 1)
						user.tri_message(H, SPAN_ALERT("<b>[user]</b> cuts out a parasite from [H == user ? "[him_or_her(H)]self" : "[H]"] with [src]!"),\
							SPAN_ALERT("You cut out a parasite from [user == H ? "yourself" : "[H]"] with [src]!"),\
							SPAN_ALERT("[H == user ? "You cut" : "<b>[user]</b> cuts"] out a parasite from you with [src]!"))

	chest_item
		name = "implant item"
		desc = "Cut out an item from someone's guts"
		icon_state = "chest_item"

		execute(atom/target, mob/user)
			if (!ishuman(target))
				return
			var/mob/living/carbon/human/H = target
			if (!surgeryCheck(H, user))
				return
			if (H.chest_item != null)
				var/location = get_turf(H)
				var/obj/item/outChestItem = H.chest_item
				outChestItem.set_loc(location)
				user.tri_message(H, SPAN_NOTICE("<b>[user]</b> cuts [H.chest_item] out of [H == user ? "[his_or_her(H)]" : "[H]'s"] chest."),\
					SPAN_NOTICE("You cut [H.chest_item] out of [user == H ? "your" : "[user]'s"] chest."),\
					SPAN_NOTICE("[H == user ? "You cut" : "<b>[user]</b> cuts"] [H.chest_item] out of your chest."))
				H.visible_message(SPAN_ALERT("\The [outChestItem] flops out of [H]."))
				H.chest_item = null
				H.chest_item_sewn = 0
				return

	ribs
		name = "Ribs"
		desc = "Open the patient's ribcage"
		icon_state = "ribs"
		surgery_flags = SURGERY_CUTTING | SURGERY_SAWING | SURGERY_SNIPPING
		var/open = FALSE

		execute(atom/target, mob/user)
			..()
			var/mob/living/carbon/human/H = target
			if (H.organHolder)
				var/region_complexity = H.organHolder.build_rib_region_buttons(src)
				if (!region_complexity)
					boutput(user, SPAN_ALERT("The patient's ribs region cannot be opened. Something went wrong. Dial 1-800-coder."))
					return
			if (src.open)
				if (!H.organHolder.build_inside_ribs_buttons())
					boutput(user, SPAN_NOTICE("[H] doesn't have any organs in their ribs region!"))
					return
				user.showContextActions(H.organHolder.inside_ribs_contexts, H, H.organHolder.contextLayout)
			else
				user.showContextActions(H.organHolder.rib_contexts, H, H.organHolder.contextLayout)
				boutput(user, SPAN_ALERT("You begin surgery on [H]'s ribs region."))
				return

		checkRequirements(atom/target, mob/user)
			var/mob/living/carbon/human/H = target
			if (H.organHolder.rib_contexts && length(H.organHolder.rib_contexts) <= 0)
				src.open = TRUE
				return TRUE
			else
				src.open = FALSE
			. = ..()

	subcostal
		name = "Subcostal"
		desc = "Open the subcostal region"
		icon_state = "subcostal"
		surgery_flags = SURGERY_CUTTING | SURGERY_SNIPPING
		var/open = FALSE

		execute(atom/target, mob/user)
			..()
			var/mob/living/carbon/human/H = target
			if (H.organHolder)
				var/region_complexity = H.organHolder.build_subcostal_region_buttons(src)
				if (!region_complexity)
					boutput(user, SPAN_ALERT("The patient's subcostal region cannot be opened. Something went wrong. Dial 1-800-coder."))
					return
			if (src.open)
				if (!H.organHolder.build_inside_subcostal_buttons())
					boutput(user, SPAN_NOTICE("[H] doesn't have any organs in their subcostal region!"))
					return
				user.showContextActions(H.organHolder.inside_subcostal_contexts, H, H.organHolder.contextLayout)
			else
				user.showContextActions(H.organHolder.subcostal_contexts, H, H.organHolder.contextLayout)
				boutput(user, SPAN_ALERT("You begin surgery on [H]'s subcostal region."))
				return

		checkRequirements(atom/target, mob/user)
			var/mob/living/carbon/human/H = target
			if (H.organHolder.subcostal_contexts && length(H.organHolder.subcostal_contexts) <= 0)
				src.open = TRUE
				return TRUE
			else
				src.open = FALSE
			. = ..()

	abdomen
		name = "Abdomen"
		desc = "Open the abdominal region"
		icon_state = "abdominal"
		surgery_flags = SURGERY_CUTTING | SURGERY_SNIPPING
		var/open = FALSE

		execute(atom/target, mob/user)
			..()
			var/mob/living/carbon/human/H = target
			if (H.organHolder)
				var/region_complexity = H.organHolder.build_abdomen_region_buttons(src)
				if (!region_complexity)
					boutput(user, SPAN_ALERT("The patient's abdominal region cannot be opened. Something went wrong. Dial 1-800-coder."))
					return
			if (src.open)
				if (!H.organHolder.build_inside_abdomen_buttons())
					boutput(user, SPAN_NOTICE("[H] doesn't have any organs in their abdominal region!"))
					return
				user.showContextActions(H.organHolder.inside_abdomen_contexts, H, H.organHolder.contextLayout)
			else
				user.showContextActions(H.organHolder.abdomen_contexts, H, H.organHolder.contextLayout)
				boutput(user, SPAN_ALERT("You begin surgery on [H]'s abdominal region."))
				return

		checkRequirements(atom/target, mob/user)
			var/mob/living/carbon/human/H = target
			if (H.organHolder.abdomen_contexts && length(H.organHolder.abdomen_contexts) <= 0)
				src.open = TRUE
				return TRUE
			else
				src.open = FALSE
			. = ..()

	flanks
		name = "Flanks"
		desc = "Open the patient's flanks"
		icon_state = "flanks"
		surgery_flags = SURGERY_CUTTING | SURGERY_SNIPPING
		var/open = FALSE

		execute(atom/target, mob/user)
			..()
			var/mob/living/carbon/human/H = target
			if (H.organHolder)
				var/region_complexity = H.organHolder.build_flanks_region_buttons(src)
				if (!region_complexity)
					boutput(user, SPAN_ALERT("The patient's flanks cannot be opened. Something went wrong. Dial 1-800-coder."))
					return
			if (src.open)
				if (!H.organHolder.build_inside_flanks_buttons())
					boutput(user, SPAN_NOTICE("[H] doesn't have any organs in their flanks!"))
					return
				user.showContextActions(H.organHolder.inside_flanks_contexts, H, H.organHolder.contextLayout)
			else
				user.showContextActions(H.organHolder.flanks_contexts, H, H.organHolder.contextLayout)
				boutput(user, SPAN_ALERT("You begin surgery on [H]'s flanks."))
				return

		checkRequirements(atom/target, mob/user)
			var/mob/living/carbon/human/H = target
			if (H.organHolder.flanks_contexts && length(H.organHolder.flanks_contexts) <= 0)
				src.open = TRUE
				return TRUE
			else
				src.open = FALSE
			. = ..()

/// Organ context action to pick an organ to operate on
/datum/contextAction/organs
	name = "Cut out organ"
	icon = 'icons/ui/context16x16.dmi'
	icon_state = "heart"
	var/organ = null
	var/organ_path

	execute(atom/target, mob/user)
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (!surgeryCheck(H, user))
				return
			if (H.organHolder?.chest?.op_stage >= 2)
				//Check if the organ didn't get removed in the meantime
				var/datum/organHolder/organs = H.organHolder
				if (!organs.organ_list[src.organ_path])
					boutput(user, SPAN_NOTICE("[H] doesn't have a [src.name]."))
					return
				var/obj/item/organ/organ_target = organs.get_organ(src.organ_path)
				if (!user.equipped())
					actions.start(new/datum/action/bar/icon/remove_organ(user, H, organ_path, src.name, TRUE, organ_target.icon, organ_target.icon_state), user)
					return
				var/organ_complexity = organ_target.build_organ_buttons()
				if (!organ_complexity)
					boutput(user, SPAN_ALERT("[organ_target] cannot be surgeried out. Something went wrong. Dial 1-800-coder."))
					return
				if (organ_target.surgery_contexts && length(organ_target.surgery_contexts) <= 0)
					user.tri_message(H, SPAN_NOTICE("<b>[user]</b> takes out [user == H ? "[his_or_her(H)]" : "[H]'s"] [src.name]."),\
						SPAN_NOTICE("You take out [user == H ? "your" : "[H]'s"] [src.name]."),\
						SPAN_ALERT("[H == user ? "You take" : "<b>[user]</b> takes"] out your [src.name]!"))
					logTheThing(LOG_COMBAT, user, "removed [constructTarget(H,"combat")]'s [src.name].")
					organs.drop_organ(src.organ_path)
					playsound(H, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)
					switch(organ_target.region)
						if (RIBS)
							if (!organs.build_inside_ribs_buttons())
								user.showContextActions(organs.contexts, H, organs.contextLayout)
							else
								user.showContextActions(organs.inside_ribs_contexts, organs.donor, organs.contextLayout)
						if (SUBCOSTAL)
							if (!organs.build_inside_subcostal_buttons())
								user.showContextActions(organs.contexts, H, organs.contextLayout)
							else
								user.showContextActions(organs.inside_subcostal_contexts, organs.donor, organs.contextLayout)
						if (ABDOMINAL)
							if (!organs.build_inside_abdomen_buttons())
								user.showContextActions(organs.contexts, H, organs.contextLayout)
							else
								user.showContextActions(organs.inside_abdomen_contexts, organs.donor, organs.contextLayout)
						if (FLANKS)
							if (!organs.build_inside_flanks_buttons())
								user.showContextActions(organs.contexts, H, organs.contextLayout)
							else
								user.showContextActions(organs.inside_flanks_contexts, organs.donor, organs.contextLayout)
				else
					user.showContextActions(organ_target.surgery_contexts, organ_target, organ_target.contextLayout)
					boutput(user, SPAN_NOTICE("You begin surgery on [H]'s [src.name]."))
					return
		else
			target.removeContextAction(src.type)

	checkRequirements(atom/target, mob/user)
		if(!can_act(user) || !in_interact_range(target, user))
			return FALSE
		if (user.equipped())
			var/obj/item/I = user.equipped()
			if (iscuttingtool(I) || issnippingtool(I) || issawingtool(I))
				return TRUE
		if (!user.equipped())
			return TRUE
		boutput(user, SPAN_NOTICE("You need some sort of surgery tool or an empty hand!"))
		return FALSE

/datum/contextAction/organs/ribs

	heart
		name = "heart"
		desc = "Cut out the heart."
		icon_state = "heart"
		organ_path = "heart"

	right_lung
		name = "right lung"
		desc = "Cut out the right lung."
		icon_state = "right_lung"
		organ_path = "right_lung"

	left_lung
		name = "left lung"
		desc = "Cut out the left lung."
		icon_state = "left_lung"
		organ_path = "left_lung"

/datum/contextAction/organs/subcostal

	liver
		name = "liver"
		desc = "Cut out the liver."
		icon_state = "liver"
		organ_path = "liver"

	spleen
		name = "spleen"
		desc = "Cut out the spleen."
		icon_state = "spleen"
		organ_path = "spleen"

	pancreas
		name = "pancreas"
		desc = "Cut out the pancreas."
		icon_state = "pancreas"
		organ_path = "pancreas"

/datum/contextAction/organs/flanks

	right_kidney
		name = "right kidney"
		desc = "Cut out the right kidney."
		icon_state = "right_kidney"
		organ_path = "right_kidney"

	left_kidney
		name = "left kidney"
		desc = "Cut out the left kidney."
		icon_state = "left_kidney"
		organ_path = "left_kidney"


/datum/contextAction/organs/abdominal

	stomach
		name = "stomach"
		desc = "Cut out the stomach."
		icon_state = "stomach"
		organ_path = "stomach"

	intestines
		name = "intestines"
		desc = "Cut out the intestines."
		icon_state = "intestines"
		organ_path = "intestines"

	appendix
		name = "appendix"
		desc = "Cut out the appendix."
		icon_state = "appendix"
		organ_path = "appendix"

/// Organ context action (tails/butts)
/datum/contextAction/back_surgery
	name = "Back surgery"
	icon = 'icons/ui/context16x16.dmi'
	icon_state = "heart"
	var/organ = null
	var/organ_path

	proc/success_feedback(atom/target, mob/user)
		boutput(user, SPAN_NOTICE("You remove [target]'s [src.name]."))
		playsound(target, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

	execute(atom/target, mob/user)
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (!surgeryCheck(H, user))
				return
			if (H.organHolder)
				var/datum/organHolder/organs = H.organHolder
				success_feedback(target, user)
				organs.contexts -= src
				actions.start(new/datum/action/bar/icon/remove_organ(user, H, organ_path, src.name), user)
		else
			target.removeContextAction(src.type)

	checkRequirements(atom/target, mob/user)
		if(!can_act(user) || !in_interact_range(target, user))
			return FALSE
		if (user.equipped())
			var/obj/item/I = user.equipped()
			if (iscuttingtool(I) || issawingtool(I))
				return TRUE
		boutput(user, SPAN_NOTICE("You need some sort of knife or saw!"))
		return FALSE

	butt
		name = "butt"
		desc = "Cut out the butt."
		icon_state = "butt"
		organ_path = "butt"

	tail
		name = "tail"
		desc = "Cut out the tail."
		icon_state = "tail"
		organ_path = "tail"

///Context action for the steps to remove a specific organ
/datum/contextAction/organ_surgery
	icon = 'icons/ui/context16x16.dmi'
	name = "Prepare an organ to be taken out"
	icon_state = "scalpel"
	var/success_text = null
	var/success_sound
	var/slipup_text = null

	execute(atom/target, mob/user)
		if (istype(target, /obj/item/organ))
			var/obj/item/organ/O = target
			if (!O)
				boutput(user, SPAN_ALERT("The organ you are operating on is no longer in the patient."))
				return
			if (!O.holder || !O.holder.donor)
				return
			if (!ishuman(O.holder.donor))
				return
			var/mob/living/carbon/human/H = O.holder.donor
			if (!surgeryCheck(H, user))
				return
			var/screw_up_prob = calc_screw_up_prob(H, user)
			if (prob(screw_up_prob))
				var/damage = calc_surgery_damage(user, screw_up_prob, rand(5,10))
				do_slipup(user, H, "chest", damage, slipup_text)
				user.showContextActions(O.surgery_contexts, O, O.contextLayout)
				return
			if (O.surgery_contexts)
				if (src.success_text)
					user.visible_message(SPAN_NOTICE("[user] [success_text]."))
				if (src.success_sound)
					if (O.holder?.donor)
						playsound(O.holder.donor, src.success_sound, 50, 1)
				attack_particle(user, H)
				attack_twitch(user)
				random_brute_damage(H, rand(2, 4))
				O.surgery_contexts -= src
				O.removal_stage = 1
				switch (O.region)
					if (RIBS)
						if (!H.organHolder.build_inside_ribs_buttons())
							boutput(user, SPAN_NOTICE("The organ is somehow missing! This shouldnt be happening! Dial 1-800 coder!"))
							return
					if (SUBCOSTAL)
						if (!H.organHolder.build_inside_subcostal_buttons())
							boutput(user, SPAN_NOTICE("The organ is somehow missing! This shouldnt be happening! Dial 1-800 coder!"))
							return
					if (ABDOMINAL)
						if (!H.organHolder.build_inside_abdomen_buttons())
							boutput(user, SPAN_NOTICE("The organ is somehow missing! This shouldnt be happening! Dial 1-800 coder!"))
							return
					if (FLANKS)
						if (!H.organHolder.build_inside_flanks_buttons())
							boutput(user, SPAN_NOTICE("The organ is somehow missing! This shouldnt be happening! Dial 1-800 coder!"))
							return
				if (length(O.surgery_contexts) <= 0)
					boutput(user, SPAN_NOTICE("It seems the organ is ready to be removed."))
					if (O.holder)
						O.removal_stage = 2
						switch (O.region)
							if (RIBS)
								if (!H.organHolder.build_inside_ribs_buttons())
									boutput(user, SPAN_NOTICE("The organ is somehow missing! This shouldnt be happening! Dial 1-800 coder!"))
									return
							if (SUBCOSTAL)
								if (!H.organHolder.build_inside_subcostal_buttons())
									boutput(user, SPAN_NOTICE("The organ is somehow missing! This shouldnt be happening! Dial 1-800 coder!"))
									return
							if (ABDOMINAL)
								if (!H.organHolder.build_inside_abdomen_buttons())
									boutput(user, SPAN_NOTICE("The organ is somehow missing! This shouldnt be happening! Dial 1-800 coder!"))
									return
							if (FLANKS)
								if (!H.organHolder.build_inside_flanks_buttons())
									boutput(user, SPAN_NOTICE("The organ is somehow missing! This shouldnt be happening! Dial 1-800 coder!"))
									return
						switch (O.region)
							if (RIBS)
								user.showContextActions(O.holder.inside_ribs_contexts, O.holder.donor, O.holder.contextLayout)
							if (SUBCOSTAL)
								user.showContextActions(O.holder.inside_subcostal_contexts, O.holder.donor, O.holder.contextLayout)
							if (ABDOMINAL)
								user.showContextActions(O.holder.inside_abdomen_contexts, O.holder.donor, O.holder.contextLayout)
							if (FLANKS)
								user.showContextActions(O.holder.inside_flanks_contexts, O.holder.donor, O.holder.contextLayout)
					return
				else
					user.showContextActions(O.surgery_contexts, O, O.contextLayout)
					return
		else
			target.removeContextAction(src.type)
			return

	cut
		name = "Cut"
		desc = "Cut surrounding tissues."
		icon_state = "scalpel"
		success_text = "cuts some tissues"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = " slips up and slices something important looking"

		checkRequirements(atom/target, mob/user)
			if(!can_act(user) || !in_interact_range(target, user))
				return FALSE
			if (!user.equipped())
				boutput(user, SPAN_NOTICE("You do not have a tool in hand."))
				return FALSE
			var/obj/item/I = user.equipped()
			if (!iscuttingtool(I))
				boutput(user, SPAN_NOTICE("You need a cutting tool."))
				return FALSE
			return TRUE

	saw
		name = "Saw"
		desc = "Saw out the organ."
		icon_state = "saw"
		success_text = "saws various connections to the organ"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = " doesn't hold the saw properly and messes up"

		checkRequirements(atom/target, mob/user)
			if(!can_act(user) || !in_interact_range(target, user))
				return FALSE
			if (!user.equipped())
				boutput(user, SPAN_NOTICE("You do not have a tool in hand."))
				return FALSE
			var/obj/item/I = user.equipped()
			if (!issawingtool(I))
				boutput(user, SPAN_NOTICE("You need a sawing tool."))
				return FALSE
			return TRUE

	snip
		name = "Snip"
		desc = "Snip out veins and tendons."
		icon_state = "scissor"
		success_text = "snips out various veins and tendons"
		success_sound = 'sound/items/Scissor.ogg'
		slipup_text = " snips directly into the organ"

		checkRequirements(atom/target, mob/user)
			if(!can_act(user) || !in_interact_range(target, user))
				return FALSE
			if (!user.equipped())
				boutput(user, SPAN_NOTICE("You do not have a tool in hand."))
				return FALSE
			var/obj/item/I = user.equipped()
			if (!issnippingtool(I))
				boutput(user, SPAN_NOTICE("You need a snipping tool."))
				return FALSE
			return TRUE

///Context action for the steps to remove a specific organ
/datum/contextAction/region_surgery
	icon = 'icons/ui/context16x16.dmi'
	name = "Open up a region of the patient's body"
	icon_state = "scalpel"
	var/success_text = null
	var/success_sound
	var/slipup_text = null
	var/region = null

	execute(atom/target, mob/user)
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (!surgeryCheck(H, user))
				return
			var/screw_up_prob = calc_screw_up_prob(H, user)

			switch (src.region)
				if ("ribs")
					if (prob(screw_up_prob))
						var/damage = calc_surgery_damage(user, screw_up_prob, rand(5,10))
						do_slipup(user, H, "chest", damage, slipup_text)
						user.showContextActions(H.organHolder.rib_contexts, H, H.organHolder.contextLayout)
						return
					attack_particle(user, H)
					attack_twitch(user)
					random_brute_damage(H, rand(2, 4))
					if (H.organHolder.rib_contexts)
						if (src.success_text)
							user.visible_message(SPAN_NOTICE("[user] [success_text]."))
						if (src.success_sound)
							playsound(H, src.success_sound, 50, 1)
						H.organHolder.rib_contexts -= src
						H.organHolder.ribs_stage = REGION_HALFWAY
						if (!H.organHolder.build_region_buttons())
							boutput(user, "[H] has no more organs!")
							return
					if (length(H.organHolder.rib_contexts) <= 0)
						boutput(user, SPAN_NOTICE("It seems the region is ready to be operated on."))
						H.organHolder.ribs_stage = REGION_OPENED
						if (!H.organHolder.build_region_buttons())
							boutput(user, "[H] has no more organs!")
							return
						user.showContextActions(H.organHolder.contexts, H, H.organHolder.contextLayout)
						return
					else
						user.showContextActions(H.organHolder.rib_contexts, H, H.organHolder.contextLayout)
						return
				if ("subcostal")
					if (prob(screw_up_prob))
						var/damage = calc_surgery_damage(user, screw_up_prob, rand(5,10))
						do_slipup(user, H, "chest", damage, slipup_text)
						user.showContextActions(H.organHolder.subcostal_contexts, H, H.organHolder.contextLayout)
						return
					attack_particle(user, H)
					attack_twitch(user)
					random_brute_damage(H, rand(2, 4))
					if (H.organHolder.subcostal_contexts)
						if (src.success_text)
							user.visible_message(SPAN_NOTICE("[user] [success_text]."))
						if (src.success_sound)
							playsound(H, src.success_sound, 50, 1)
						H.organHolder.subcostal_contexts -= src
						H.organHolder.subcostal_stage = REGION_HALFWAY
						if (!H.organHolder.build_region_buttons())
							boutput(user, "[H] has no more organs!")
							return
					if (length(H.organHolder.subcostal_contexts) <= 0)
						boutput(user, SPAN_NOTICE("It seems the region is ready to be operated on."))
						H.organHolder.subcostal_stage = REGION_OPENED
						if (!H.organHolder.build_region_buttons())
							boutput(user, "[H] has no more organs!")
							return
						user.showContextActions(H.organHolder.contexts, H, H.organHolder.contextLayout)
						return
					else
						user.showContextActions(H.organHolder.subcostal_contexts, H, H.organHolder.contextLayout)
						return
				if ("abdomen")
					if (prob(screw_up_prob))
						var/damage = calc_surgery_damage(user, screw_up_prob, rand(5,10))
						do_slipup(user, H, "chest", damage, slipup_text)
						user.showContextActions(H.organHolder.abdomen_contexts, H, H.organHolder.contextLayout)
						return
					attack_particle(user, H)
					attack_twitch(user)
					random_brute_damage(H, rand(2, 4))
					if (H.organHolder.abdomen_contexts)
						if (src.success_text)
							user.visible_message(SPAN_NOTICE("[user] [success_text]."))
						if (src.success_sound)
							playsound(H, src.success_sound, 50, 1)
						H.organHolder.abdomen_contexts -= src
						H.organHolder.abdominal_stage = REGION_HALFWAY
						if (!H.organHolder.build_region_buttons())
							boutput(user, "[H] has no more organs!")
							return
					if (length(H.organHolder.abdomen_contexts) <= 0)
						boutput(user, SPAN_NOTICE("It seems the region is ready to be operated on."))
						H.organHolder.abdominal_stage = REGION_OPENED
						if (!H.organHolder.build_region_buttons())
							boutput(user, "[H] has no more organs!")
							return
						user.showContextActions(H.organHolder.contexts, H, H.organHolder.contextLayout)
						return
					else
						user.showContextActions(H.organHolder.abdomen_contexts, H, H.organHolder.contextLayout)
						return
				if ("flanks")
					if (prob(screw_up_prob))
						var/damage = calc_surgery_damage(user, screw_up_prob, rand(5,10))
						do_slipup(user, H, "chest", damage, slipup_text)
						user.showContextActions(H.organHolder.flanks_contexts, H, H.organHolder.contextLayout)
						return
					attack_particle(user, H)
					attack_twitch(user)
					random_brute_damage(H, rand(2, 4))
					if (H.organHolder.flanks_contexts)
						if (src.success_text)
							user.visible_message(SPAN_NOTICE("[user] [success_text]."))
						if (src.success_sound)
							playsound(H, src.success_sound, 50, 1)
						H.organHolder.flanks_contexts -= src
						H.organHolder.flanks_stage = REGION_HALFWAY
						if (!H.organHolder.build_region_buttons())
							boutput(user, "[H] has no more organs!")
							return
					if (length(H.organHolder.flanks_contexts) <= 0)
						boutput(user, SPAN_NOTICE("It seems the region is ready to be operated on."))
						H.organHolder.flanks_stage = REGION_OPENED
						if (!H.organHolder.build_region_buttons())
							boutput(user, "[H] has no more organs!")
							return
						user.showContextActions(H.organHolder.contexts, H, H.organHolder.contextLayout)
						return
					else
						user.showContextActions(H.organHolder.flanks_contexts, H, H.organHolder.contextLayout)
						return
		else
			target.removeContextAction(src.type)
			return

	cut
		name = "Cut"
		desc = "Slice open the flesh."
		icon_state = "scalpel"
		success_text = "slices open the flesh protecting the organs"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = " slips up and stabs into the patient"

		checkRequirements(atom/target, mob/user)
			if(!can_act(user) || !in_interact_range(target, user))
				return FALSE
			if (!user.equipped())
				boutput(user, SPAN_NOTICE("You do not have a tool in hand."))
				return FALSE
			var/obj/item/I = user.equipped()
			if (!iscuttingtool(I))
				boutput(user, SPAN_NOTICE("You need a cutting tool."))
				return FALSE
			return TRUE

	saw
		name = "Saw"
		desc = "Saw open the ribcage."
		icon_state = "saw"
		success_text = "saws open the ribcage"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = " doesn't hold the saw properly and cracks a rib"

		checkRequirements(atom/target, mob/user)
			if(!can_act(user) || !in_interact_range(target, user))
				return FALSE
			if (!user.equipped())
				boutput(user, SPAN_NOTICE("You do not have a tool in hand."))
				return FALSE
			var/obj/item/I = user.equipped()
			if (!issawingtool(I))
				boutput(user, SPAN_NOTICE("You need a sawing tool."))
				return FALSE
			return TRUE

	snip
		name = "Snip"
		desc = "Snip out some tissue."
		icon_state = "scissor"
		success_text = "snips out various tissues and tendons"
		success_sound = 'sound/items/Scissor.ogg'
		slipup_text = " loses control of the scissors and drags it across the patient's entire chest"

		checkRequirements(atom/target, mob/user)
			if(!can_act(user) || !in_interact_range(target, user))
				return FALSE
			if (!user.equipped())
				boutput(user, SPAN_NOTICE("You do not have a tool in hand."))
				return FALSE
			var/obj/item/I = user.equipped()
			if (!issnippingtool(I))
				boutput(user, SPAN_NOTICE("You need a snipping tool."))
				return FALSE
			return TRUE
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
			sp.say(src.speech_text)
			playsound(sp, src.speech_sound, 50, 1)
			logTheThing(LOG_DEBUG, sp, "[user] said [src.speech_text] using [sp].")
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
