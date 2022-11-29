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
				desc = "Lead an army of otherwoldly foes."
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
		if (GBP && GB && (BOUNDS_DIST(target, user) == 0 && isliving(user)) && !GB?.occupant)
			. = TRUE
			GB.show_admin_panel(user)

	buildBackgroundIcon(atom/target, mob/user)
		var/image/background = image('icons/ui/context32x32.dmi', src, "[getBackground(target, user)]0")
		background.appearance_flags = RESET_COLOR
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


/datum/contextAction/deconstruction
	icon = 'icons/ui/context16x16.dmi'
	name = "Deconstruct with Tool"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"

	execute(atom/target, mob/user)
		if (isobj(target))
			var/obj/O = target
			if (O.decon_contexts)
				O.decon_contexts -= src
				if (O.decon_contexts.len <= 0)
					user.show_text("Looks like [target] is ready to be deconstructed with the device.", "blue")
				else
					user.showContextActions(O.decon_contexts, O)
		else
			target.removeContextAction(src.type)

	checkRequirements(atom/target, mob/user)
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

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (iswrenchingtool(I))
					user.show_text("You wrench [target]'s bolts.", "blue")
					playsound(target, 'sound/items/Ratchet.ogg', 50, 1)
					return ..()

	cut
		name = "Cut"
		desc = "Cutting required to deconstruct."
		icon_state = "cut"

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (iscuttingtool(I) || issnippingtool(I))
					user.show_text("You cut some vestigial wires from [target].", "blue")
					playsound(target, 'sound/items/Wirecutter.ogg', 50, 1)
					return ..()
	weld
		name = "Weld"
		desc = "Welding required to deconstruct."
		icon_state = "weld"

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (isweldingtool(I))
					if (I:try_weld(user, 2))
						user.show_text("You weld [target] carefully.", "blue")
						return ..()

	pry
		name = "Pry"
		desc = "Prying required to deconstruct. Try a crowbar."
		icon_state = "bar"

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (ispryingtool(I))
					user.show_text("You pry on [target] without remorse.", "blue")
					playsound(target, 'sound/items/Crowbar.ogg', 50, 1)
					return ..()

	screw
		name = "Screw"
		desc = "Screwing required to deconstruct."
		icon_state = "screw"

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (isscrewingtool(I))
					user.show_text("You unscrew some of the screws on [target].", "blue")
					playsound(target, 'sound/items/Screwdriver.ogg', 50, 1)
					return ..()

	pulse
		name = "Pulse"
		desc = "Pulsing required to deconstruct. Try a multitool."
		icon_state = "pulse"

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (ispulsingtool(I))
					user.show_text("You pulse [target]. In a general sense.", "blue")
					playsound(target, 'sound/items/penclick.ogg', 50, 1)
					return ..()

/datum/contextAction/vehicle
	icon = 'icons/ui/context16x16.dmi'
	name = "Vehicle action"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"

	execute(atom/target, mob/user)
		return

	checkRequirements(atom/target, mob/user)
		. = (user.loc == target)

	board
		name = "Board"
		desc = "Hop on."
		icon_state = "board"

		checkRequirements(atom/target, mob/user)
			var/obj/machinery/vehicle/V = target
			. = ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null && !isAI(user))

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
			. = ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null && !isAI(user))

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
				. = ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null && !isAI(user))

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
			. = ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null && !isAI(user))

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

	fire_main_weapon
		name = "Fire Main Weapon"
		desc = "Fire your weapon. But you should probably be pressing SPACE to fire instead..."
		icon_state = "gun"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.fire_main_weapon(user)

	use_external_speaker
		name = "Use External Speaker"
		desc = "Talk to people with your ship intercom."
		icon_state = "speaker"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.use_external_speaker()

	create_wormhole
		name = "Create Wormhole"
		desc = "Warp to a pod beacon."
		icon_state = "portal"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.create_wormhole()

	access_sensors
		name = "Access Sensors"
		desc = "Scan your surroundings."
		icon_state = "radar"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.access_sensors()

	use_secondary_system
		name = "Use Secondary System"
		desc = "Use a secondary systems special function if it exists."
		icon_state = "computer2"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.use_secondary_system()

	open_hangar
		name = "Open Hangar"
		desc = "Toggle nearby hangar blast door remotely."
		icon_state = "door"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.open_hangar()

	return_to_station
		name = "Return To Station"
		desc = "Use the ship's comm system to locate the station's Space GPS beacon and plot a return course."
		icon_state = "return"

		execute(atom/target, mob/user)
			..()
			var/obj/machinery/vehicle/V = target
			V.return_to_station()


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
		return TRUE

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
		. = 1

	execute(var/atom/target, var/mob/user)
		var/obj/item/lamp_manufacturer/M = target
		if (M.removing_toggled)
			M.set_icon_state("[M.prefix]-remove")
		else
			M.set_icon_state("[M.prefix]-[M.setting]")
		M.tooltip_rebuild = 1

	green
		name = "Set Green"
		desc = "Sets the manufacturer to produce green lamps."
		icon_state = "green"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.setting = "green"
			M.dispensing_tube = /obj/item/light/tube/green
			M.dispensing_bulb = /obj/item/light/bulb/green
			..()

	yellow
		name = "Set Yellow"
		desc = "Sets the manufacturer to produce yellow lamps."
		icon_state = "yellow"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.setting = "yellow"
			M.dispensing_tube = /obj/item/light/tube/yellow
			M.dispensing_bulb = /obj/item/light/bulb/yellow
			..()

	red
		name = "Set Red"
		desc = "Sets the manufacturer to produce red lamps."
		icon_state = "red"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.setting = "red"
			M.dispensing_tube = /obj/item/light/tube/red
			M.dispensing_bulb = /obj/item/light/bulb/red
			..()

	white
		name = "Set White"
		desc = "Sets the manufacturer to produce white lamps."
		icon_state = "white"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.setting = "white"
			M.dispensing_tube = /obj/item/light/tube
			M.dispensing_bulb = /obj/item/light/bulb
			..()

	removal
		name = "Toggle Fitting Removal"
		desc = "Toggles the manufacturer between removing fittings and replacing lamps."
		icon_state = "close"
		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.removing_toggled = !M.removing_toggled
			boutput(user, "<span class='notice'>Now set to [M.removing_toggled == TRUE ? "remove fittings" : "replace lamps"].</span>")
			..()

	bulbs
		name = "Fitting Production: Bulbs"
		desc = "Sets the manufacturer to produce bulb wall fittings."
		icon_state = "bulb"
		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.dispensing_fitting = /obj/machinery/light/small
			..()

	tubes
		name = "Fitting Production: Tubes"
		desc = "Sets the manufacturer to produce tube wall fittings."
		icon_state = "tube"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.dispensing_fitting = /obj/machinery/light
			..()

	blacklight
		name = "Set Blacklight"
		desc = "Sets the manufacturer to produce blacklight lamps."
		icon_state = "blacklight"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.setting = "blacklight"
			M.dispensing_tube = /obj/item/light/tube/blacklight
			M.dispensing_bulb = /obj/item/light/bulb/blacklight
			..()

	purple
		name = "Set Purple"
		desc = "Sets the manufacturer to produce purple lamps."
		icon_state = "purple"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.setting = "purple"
			M.dispensing_tube = /obj/item/light/tube/purple
			M.dispensing_bulb = /obj/item/light/bulb/purple
			..()

	blue
		name = "Set Blue"
		desc = "Sets the manufacturer to produce blue lamps."
		icon_state = "blue"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.setting = "blue"
			M.dispensing_tube = /obj/item/light/tube/blue
			M.dispensing_bulb = /obj/item/light/bulb/blue
			..()
	cyan
		name = "Set Cyan"
		desc = "Sets the manufacturer to produce cyan lamps."
		icon_state = "cyan"

		execute(var/atom/target, var/mob/user)
			var/obj/item/lamp_manufacturer/M = target
			M.setting = "cyan"
			M.dispensing_tube = /obj/item/light/tube/cyan
			M.dispensing_bulb = /obj/item/light/bulb/cyan
			..()


/datum/contextAction/card
	icon = 'icons/ui/context16x16.dmi'
	name = "Card action"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"

	checkRequirements(var/atom/target, var/mob/user)
		return TRUE

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
				background.appearance_flags = RESET_COLOR
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

/datum/contextAction/prisoner_scanner
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	close_moved = FALSE
	desc = ""
	icon_state = "wrench"
	var/mode = PRISONER_MODE_NONE

	execute(var/obj/item/device/prisoner_scanner/prisoner_scanner, var/mob/user)
		if(!istype(prisoner_scanner))
			return
		prisoner_scanner.switch_mode(src.mode, user)

	checkRequirements(var/obj/item/device/prisoner_scanner/prisoner_scanner, var/mob/user)
		return prisoner_scanner in user

	none
		name = "None"
		icon_state = "none"
		mode = PRISONER_MODE_NONE
	Paroled
		name = "Paroled"
		icon_state = "paroled"
		mode = PRISONER_MODE_PAROLED
	incarcerated
		name = "Incarcerated"
		icon_state = "incarcerated"
		mode = PRISONER_MODE_INCARCERATED
	released
		name = "Released"
		icon_state = "released"
		mode = PRISONER_MODE_RELEASED
