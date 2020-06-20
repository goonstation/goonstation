var/list/globalContextActions = null
/atom/var/list/contextActions = null

/atom/var/datum/contextLayout/contextLayout = null //Targets layout is used if possible, users layout otherwise.

//Uncomment these two lines for expanding menu testing
/*
/obj/item/contextActions = list(/datum/contextAction/expandadd)
/obj/item/contextLayout = new/datum/contextLayout/expandtest()
*/

/datum/contextLayout
	proc/showButtons(var/list/buttons, var/atom/target)
		return

	flexdefault
		var/width = 2
		var/spacingX = 16
		var/spacingY = 16
		var/offsetX = 0
		var/offsetY = 0

		New(var/Width = 2, var/SpacingX = 16, var/SpacingY = 16, var/OffsetX = 0, var/OffsetY = 0)
			width = Width
			spacingX = SpacingX
			spacingY = SpacingY
			offsetX = OffsetX
			offsetY = OffsetY
			return ..()

		showButtons(var/list/buttons, var/atom/target)
			var/atom/screenCenter = get_turf(usr.client.virtual_eye)
			var/screenX = ((screenCenter.x - target.x) * (-1)) * 32
			var/screenY = ((screenCenter.y - target.y) * (-1)) * 32
			var/offX = 0
			var/offY = spacingY

			screenX += offsetX
			screenY += offsetY

			for(var/obj/screen/contextButton/C in buttons) //todo : stop typechecking per context
				C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"

				var/mob/living/carbon/human/H = usr
				if(istype(H)) H.hud.add_screen(C)
				var/mob/living/critter/R = usr
				if(istype(R)) R.hud.add_screen(C)
				var/mob/wraith/W = usr
				if(istype(W)) W.hud.add_screen(C)
				if (isrobot(usr))
					var/mob/living/silicon/robot/robot = usr
					robot.hud.add_screen(C)
				if (ishivebot(usr))
					var/mob/living/silicon/hivebot/hivebot = usr
					hivebot.hud.add_screen(C)

				var/matrix/trans = unpool(/matrix)
				trans = trans.Reset()
				trans.Translate(offX, offY)

				animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)

				offX += spacingX
				if(offX >= spacingX * width)
					offX = 0
					offY -= spacingY

			return buttons

	instrumental
		var/spacingX = 16
		var/spacingY = 16
		var/offsetX = 0
		var/offsetY = 0

		New(var/SpacingX = 10, var/SpacingY = 16, var/OffsetX = 0, var/OffsetY = 0)
			spacingX = SpacingX
			spacingY = SpacingY
			offsetX = OffsetX
			offsetY = OffsetY
			return ..()

		showButtons(var/list/buttons, var/atom/target)
			var/offX = 0
			var/offY = spacingY
			var/finalOff = spacingX * (buttons.len-3)
			offX -= finalOff/2

			for(var/obj/screen/contextButton/C in buttons) //todo : stop typechecking per context
				C.screen_loc = "CENTER,CENTER+0.6"

				var/mob/living/carbon/human/H = usr
				if(istype(H)) H.hud.add_screen(C)
				var/mob/living/critter/R = usr
				if(istype(R)) R.hud.add_screen(C)
				var/mob/wraith/W = usr
				if(istype(W)) W.hud.add_screen(C)
				if (isrobot(usr))
					var/mob/living/silicon/robot/robot = usr
					robot.hud.add_screen(C)
				if (ishivebot(usr))
					var/mob/living/silicon/hivebot/hivebot = usr
					hivebot.hud.add_screen(C)

				var/matrix/trans = unpool(/matrix)
				trans = trans.Reset()
				trans.Translate(offX, offY)

				animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=1)

				offX += spacingX
				//if(offX >= spacingX)
				//	offX = 0
				//	offY -= spacingY

			return buttons

	experimentalcircle
		showButtons(var/list/buttons, var/atom/target)
			var/atom/screenCenter = get_turf(usr.client.virtual_eye)
			var/screenX = ((screenCenter.x - target.x) * (-1)) * 32
			var/screenY = ((screenCenter.y - target.y) * (-1)) * 32

			var/anglePer = round(360 / buttons.len)
			var/dist = 16

			var/count = 0

			var/list/bounds = getIconBounds(icon(target.icon, target.icon_state), target.icon_state)
			var/sizeX = bounds["top"] - bounds["bottom"]
			var/sizeY = bounds["right"] - bounds["left"]

			var/additionalX = target.pixel_x + round((sizeX / 2) )
			var/additionalY = target.pixel_y + round((sizeY / 2) )

			screenX += additionalX
			screenY += additionalY

			for(var/obj/screen/contextButton/C in buttons)
				C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"

				var/mob/living/carbon/human/H = usr
				if(istype(H)) H.hud.add_screen(C)
				var/mob/living/critter/R = usr
				if(istype(R)) R.hud.add_screen(C)
				var/mob/wraith/W = usr
				if(istype(W)) W.hud.add_screen(C)
				if (isrobot(usr))
					var/mob/living/silicon/robot/robot = usr
					robot.hud.add_screen(C)
				if (ishivebot(usr))
					var/mob/living/silicon/hivebot/hivebot = usr
					hivebot.hud.add_screen(C)

				var/offX = round(dist*cos(anglePer*count)) + additionalX
				var/offY = round(dist*sin(anglePer*count))	+ additionalY

				var/matrix/trans = unpool(/matrix)
				trans = trans.Reset()
				trans.Translate(offX, offY)

				animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)
				count++

	default
		showButtons(var/list/buttons, var/atom/target)
			var/atom/screenCenter = get_turf(usr.client.virtual_eye)
			var/screenX = ((screenCenter.x - target.x) * (-1)) * 32
			var/screenY = ((screenCenter.y - target.y) * (-1)) * 32
			var/offX = 0
			var/offY = 16

			for(var/obj/screen/contextButton/C in buttons)
				C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"

				var/mob/living/carbon/human/H = usr
				if(istype(H)) H.hud.add_screen(C)
				var/mob/living/critter/R = usr
				if(istype(R)) R.hud.add_screen(C)
				var/mob/wraith/W = usr
				if(istype(W)) W.hud.add_screen(C)
				if (isrobot(usr))
					var/mob/living/silicon/robot/robot = usr
					robot.hud.add_screen(C)
				if (ishivebot(usr))
					var/mob/living/silicon/hivebot/hivebot = usr
					hivebot.hud.add_screen(C)

				var/matrix/trans = unpool(/matrix)
				trans = trans.Reset()
				trans.Translate(offX, offY)

				animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)

				offX += 16
				if(offX > 16)
					offX = 0
					offY -= 16
			return buttons

	expandtest
		showButtons(var/list/buttons, var/atom/target)
			var/atom/screenCenter = get_turf(usr.client.virtual_eye)
			var/screenX = ((screenCenter.x - target.x) * (-1)) * 32
			var/screenY = ((screenCenter.y - target.y) * (-1)) * 32
			var/offX = 0
			var/offY = 16

			var/first = 1
			for(var/obj/screen/contextButton/C in buttons)
				C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"

				var/mob/living/carbon/human/H = usr
				if(istype(H)) H.hud.add_screen(C)
				var/mob/living/critter/R = usr
				if(istype(R)) R.hud.add_screen(C)
				var/mob/wraith/W = usr
				if(istype(W)) W.hud.add_screen(C)
				if (isrobot(usr))
					var/mob/living/silicon/robot/robot = usr
					robot.hud.add_screen(C)
				if (ishivebot(usr))
					var/mob/living/silicon/hivebot/hivebot = usr
					hivebot.hud.add_screen(C)

				var/matrix/trans = unpool(/matrix)
				trans = trans.Reset()
				trans.Translate(offX, offY + (first ? 16 : 0))

				animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)

				offX += (first ? 0 : 16)
				if(offX > 16)
					offX = 0
					offY -= 16
				first = 0
			return buttons

	//for drawing context menu buttons based on screen_loc position instead of //DONE NOTHING YET
	screen_HUD_default
		var/count_start_pos = 1
		showButtons(var/list/buttons, var/obj/screen/target)
			var/longitude_dir
			var/lattitude_dir
			var/targetx
			var/targety

			// var/atom/screenCenter = usr.client.virtual_eye
			if (istype(target, /obj/screen))
				var/obj/screen/T = target
				var/regex/R1 = regex("(EAST|WEST)((\\-|\\+)\\d+|)")
				R1.Find(T.screen_loc)
				if (R1.match)
					longitude_dir = R1.group[1]
					targetx = R1.group[2]
					if (R1.group[2] == "")
						targetx = 0

				var/regex/R2 = regex("(NORTH|SOUTH)((\\-|\\+)\\d+|)")
				R2.Find(T.screen_loc)
				if (R2.match)
					lattitude_dir = R2.group[1]
					targety = R2.group[2]
					if (R2.group[2] == "")
						targety = 0
			else return 0

			var/count = count_start_pos
			for(var/obj/screen/contextButton/C in buttons)
				//C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"
				C.screen_loc = "[lattitude_dir][targetx],[longitude_dir][targety]"
				var/mob/living/carbon/human/H = usr
				if(istype(H)) H.hud.add_screen(C)
				var/mob/living/critter/R = usr
				if(istype(R)) R.hud.add_screen(C)
				var/mob/wraith/W = usr
				if(istype(W)) W.hud.add_screen(C)
				var/mob/dead/observer/GO = usr
				if(istype(GO)) GO.hud.add_screen(C)
				if (isrobot(usr))
					var/mob/living/silicon/robot/robot = usr
					robot.hud.add_screen(C)
				if (ishivebot(usr))
					var/mob/living/silicon/hivebot/hivebot = usr
					hivebot.hud.add_screen(C)

				var/matrix/trans = unpool(/matrix)
				trans = trans.Reset()
				trans.Translate(0, -32*count)

				animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)

				count++
			return buttons
	screen_HUD_default/click_to_close
		count_start_pos = 0

/mob
	var/list/contextButtons = list()
	contextLayout = new/datum/contextLayout/flexdefault()

	proc/checkContextActions(var/atom/target)
		var/list/applicable = list()
		var/obj/item/W = src.equipped()
		if(W && W.contextActions && W.contextActions.len)
			for(var/datum/contextAction/C in W.contextActions)
				var/action = C.checkRequirements(target, src)
				if(action) applicable.Add(action)

		if(target && target.contextActions && target.contextActions.len)
			for(var/datum/contextAction/C in target.contextActions)
				var/action = C.checkRequirements(target, src)
				if(action) applicable.Add(C)

		if(src.contextActions && src.contextActions.len)
			for(var/datum/contextAction/C in src.contextActions)
				var/action = C.checkRequirements(target, src)
				if(action) applicable.Add(C)

		if(applicable.len) return applicable
		else return list()

	proc/showContextActions(var/list/applicable, var/atom/target)
		if(contextButtons.len)
			closeContextActions()
		var/list/buttons = list()
		for(var/datum/contextAction/C in applicable)
			var/obj/screen/contextButton/B = unpool(/obj/screen/contextButton)
			B.setup(C, src, target)
			B.alpha = 0
			buttons.Add(B)
		if(target.contextLayout)
			target.contextLayout.showButtons(buttons,target)
		else
			contextLayout.showButtons(buttons,target)

		contextButtons = buttons
		return

	proc/closeContextActions()
		for(var/obj/screen/contextButton/C in contextButtons)//todo : stop typechecking per context
			var/mob/living/carbon/human/H = src
			if(istype(H)) H.hud.remove_screen(C)
			var/mob/living/critter/R = src
			if(istype(R)) R.hud.remove_screen(C)
			var/mob/wraith/W = src
			if(istype(W)) W.hud.remove_screen(C)
			var/mob/dead/observer/GO = usr
			if(istype(GO)) GO.hud.remove_screen(C)
			if (isrobot(src))
				var/mob/living/silicon/robot/robot = src
				robot.hud.remove_screen(C)
			if (ishivebot(src))
				var/mob/living/silicon/hivebot/hivebot = src
				hivebot.hud.remove_screen(C)

			contextButtons.Remove(C)
			if(C.overlays)
				C.overlays = list()
			/*if(C.underlays)
				C.underlays = list()*/

			pool(C)
		return

/atom
	New()
		if(contextActions != null)
			if(globalContextActions == null)
				buildContextActions()

			var/list/newList = list()
			for(var/A in contextActions) //List of typepaths gets turned into references to instance at runtime.
				if(ispath(A))
					if(globalContextActions && globalContextActions[A])
						if(!(globalContextActions[A] in newList))
							newList.Add(globalContextActions[A])
			contextActions = newList
		..()

	proc/addContextAction(var/contextType)
		if(!ispath(contextType)) return
		if(globalContextActions && globalContextActions[contextType])
			if(!(globalContextActions[contextType] in contextActions))
				contextActions.Add(globalContextActions[contextType])
		return

	proc/removeContextAction(var/contextType)
		if(!ispath(contextType)) return
		for(var/datum/contextAction/C in contextActions)
			if(C.type == contextType)
				contextActions.Remove(C)
		return

/proc/buildContextActions()
	globalContextActions = list()
	for(var/A in childrentypesof(/datum/contextAction))
		globalContextActions.Add(A)
		globalContextActions[A] = new A()
	return

/obj/screen/contextButton
	name = ""
	icon = 'icons/ui/context16x16.dmi'
	icon_state = ""
	var/datum/contextAction/action = null
	var/image/background = null
	var/mob/user = null
	var/atom/target = null

	proc/setup(var/datum/contextAction/A, var/mob/U, var/atom/T)
		if(!A || !U || !T)
			CRASH("Context Button setup called without valid instances [A],[U],[T]")
		action = A
		user = U
		target = T
		icon = action.getIcon(target,user)
		icon_state = action.getIconState(target, user)
		name = action.getName(target, user)

		var/matrix/trans = unpool(/matrix)
		trans = trans.Reset()
		trans.Translate(8, 16)


		//var/matrix/trans = unpool(/matrix)
		//trans = trans.Reset()
		transform = trans

		background = null
		src.underlays.Cut()

		var/possible_bg = action.buildBackgroundIcon(target,user)
		if (possible_bg)
			background = possible_bg
			src.underlays += background

		if(background == null)
			background = image('icons/ui/context16x16.dmi', src, "[action.getBackground(target, user)]0")
			background.appearance_flags = RESET_COLOR
			src.underlays += background
		return

	MouseEntered(location,control,params)
		if (usr != user) return
		src.underlays.Cut()
		background.icon_state = "[action.getBackground(target, user)]1"
		src.underlays += background
		if (usr.client.tooltipHolder && (action != null) && action.use_tooltip)
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = action.getName(target, user),
				"content" = action.getDesc(target, user),
				"theme" = "stamina",
				"flags" = action.getTooltipFlags()
			))
		return

	MouseExited(location,control,params)
		if (usr != user) return
		src.underlays.Cut()
		background.icon_state = "[action.getBackground(target, user)]0"
		src.underlays += background
		if (usr.client.tooltipHolder && action.use_tooltip)
			usr.client.tooltipHolder.hideHover()
		return

	clicked(list/params)
		if(action.checkRequirements(target, user)) //Let's just check again, just in case.
			SPAWN_DBG(0) action.execute(target, user)
			if (action.flick_on_click)
				flick(action.flick_on_click, src)
			if (action.close_clicked)
				user.closeContextActions()

/datum/contextAction
	var/icon = 'icons/ui/context16x16.dmi'
	var/icon_state = "eye"
	var/icon_background = "bg"
	var/name = ""
	var/desc = ""
	var/tooltip_flags = null
	var/use_tooltip = 1
	var/close_clicked = 1
	var/flick_on_click = null

	proc/checkRequirements(var/atom/target, var/mob/user) //Is this action even allowed to show up under the given circumstances? 1=yes, 0=no
		return 0

	proc/execute(var/atom/target, var/mob/user) //Make sure that people are really allowed to do the thing they are doing in here. Double check equipped items, distance etc.
		return 0

	proc/getIcon()
		.= icon

	proc/getIconState(var/atom/target, var/mob/user) //If you want to dynamically change the icon. Cutting/mending wires on doors etc?
		return icon_state

	proc/getBackground(var/atom/target, var/mob/user)
		return icon_background

	proc/buildBackgroundIcon(var/atom/target, var/mob/user)
		.= null

	proc/getName(var/atom/target, var/mob/user)
		return name

	proc/getDesc(var/atom/target, var/mob/user)
		return desc

	proc/getTooltipFlags()
		return tooltip_flags

	expandadd
		name = "expandadd"
		desc = "Test One"
		icon_state = "plus"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user) //Order is important for this. Remove first, add after. Always add the expansion button first.
			target.removeContextAction(/datum/contextAction/expandadd)
			target.addContextAction(/datum/contextAction/expandremove)
			target.addContextAction(/datum/contextAction/expandone)
			target.addContextAction(/datum/contextAction/expandtwo)
			target.addContextAction(/datum/contextAction/expandthree)
			var/list/contexts = user.checkContextActions(target)
			if(contexts.len)
				user.showContextActions(contexts, target)
			return 0

	expandremove
		name = "expandremove"
		desc = "Test Two"
		icon_state = "minus"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			target.removeContextAction(/datum/contextAction/expandremove)
			target.removeContextAction(/datum/contextAction/expandone)
			target.removeContextAction(/datum/contextAction/expandtwo)
			target.removeContextAction(/datum/contextAction/expandthree)
			target.addContextAction(/datum/contextAction/expandadd)
			var/list/contexts = user.checkContextActions(target)
			if(contexts.len)
				user.showContextActions(contexts, target)
			return 0

	expandone
		name = "expandone"
		desc = "expandone"
		icon_state = "cog"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			return 0

	expandtwo
		name = "expandtwo"
		desc = "expandtwo"
		icon_state = "cog"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			return 0

	expandthree
		name = "expandthree"
		desc = "expandthree"
		icon_state = "cog"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			return 0

	testone
		name = "testone"
		desc = "Test One"
		icon_state = "plus"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			target.addContextAction(/datum/contextAction/testtwo)
			return 0

	testtwo
		name = "testtwo"
		desc = "Test Two"
		icon_state = "plus"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			target.addContextAction(/datum/contextAction/testthree)
			return 0

	testthree
		name = "testthree"
		desc = "Test three"
		icon_state = "plus"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			target.addContextAction(/datum/contextAction/testfour)
			return 0

	testfour
		name = "testfour"
		desc = "Test four"
		icon_state = "minus"
		icon_background = "bg"

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			target.removeContextAction(/datum/contextAction/testtwo)
			target.removeContextAction(/datum/contextAction/testthree)
			target.removeContextAction(/datum/contextAction/testfour)
			return 0

	ghost_respawn
		name = "ghost"
		desc = "Test"
		icon = 'icons/mob/ghost_observer_abilities.dmi'
		icon_state = "teleport"
		icon_background = ""

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			user.closeContextActions()
			return 0

	ghost_respawn/close
		name = "Close"
		desc = "Close the menu"
		icon_state = "ghost-close"
		tooltip_flags = TOOLTIP_LEFT

	ghost_respawn/virtual_reality
		name = "Ghost VR"
		desc = "Enter ghost virtual reality"
		icon_state = "ghost-vr"
		tooltip_flags = TOOLTIP_LEFT

		execute(var/atom/target, var/mob/user)
			if (user && istype(user, /mob/dead/observer))
				var/mob/dead/observer/ghost = user
				SPAWN_DBG(1 DECI SECOND)
					ghost.go_to_vr()
			..()

	ghost_respawn/respawn_animal
		name = "Respawn Animal"
		desc = "Respawn as a tiny critter"
		icon_state = "respawn-animal"
		tooltip_flags = TOOLTIP_LEFT

		execute(var/atom/target, var/mob/user)
			if (user && istype(user, /mob/dead/observer))
				var/mob/dead/observer/ghost = user
				SPAWN_DBG(1 DECI SECOND)
					ghost.respawn_as_animal()
			..()

	ghost_respawn/respawn_mentor_mouse
		name = "Respawn As a Mentor Mouse"
		desc = "Respawn as a mentor mouse that people can pick up. You can whisper in their ears and click on their screen to point them in the right direction. Please don't abuse this."
		icon_state = "respawn-mentor-mouse"
		tooltip_flags = TOOLTIP_LEFT

		checkRequirements(var/atom/target, var/mob/user)
			return user && user.client && (user.client.holder || user.client.player.mentor)

		execute(var/atom/target, var/mob/user)
			if (user && istype(user, /mob/dead/observer))
				var/mob/dead/observer/ghost = user
				SPAWN_DBG(1 DECI SECOND)
					ghost.respawn_as_mentor_mouse()
			..()

	ghost_respawn/respawn_admin_mouse
		name = "Respawn As an Admin Mouse"
		desc = "Respawn as an admin mouse that people can pick up (or click on them to climb into their pockets). You can whisper in their ears and click on their screen to point them in the right direction. Be a little critter friend!"
		icon_state = "respawn-admin-mouse"
		tooltip_flags = TOOLTIP_LEFT

		checkRequirements(var/atom/target, var/mob/user)
			return user && user.client && user.client.holder

		execute(var/atom/target, var/mob/user)
			if (user && istype(user, /mob/dead/observer))
				var/mob/dead/observer/ghost = user
				SPAWN_DBG(1 DECI SECOND)
					ghost.respawn_as_admin_mouse()
			..()

	ghost_respawn/ghostdrone
		name = "Ghost Drone"
		desc = "Step on the ghost catcher and be added to the ghost drone queue"
		icon_state = "ghost-drone"
		tooltip_flags = TOOLTIP_LEFT

		execute(var/atom/target, var/mob/user)
			if (user && istype(user, /mob/dead/observer))
				var/mob/dead/observer/ghost = user
				SPAWN_DBG(1 DECI SECOND)
					ghost.enter_ghostdrone_queue()
			..()

	ghost_respawn/afterlife_bar
		name = "Afterlife Bar"
		desc = "Enter the afterlife Bar"
		icon_state = "afterlife-bar"
		tooltip_flags = TOOLTIP_LEFT

		execute(var/atom/target, var/mob/user)
			if (user && istype(user, /mob/dead/observer))
				var/mob/dead/observer/ghost = user
				SPAWN_DBG(1 DECI SECOND)
					ghost.go_to_deadbar()
			..()

	// ghost_respawn/blobtutorial
	// 	name = "Blob Tutorial"
	// 	desc = "Practice blobbing around"
	// 	icon_state = "blob-tutorial"
	// 	tooltip_flags = TOOLTIP_LEFT

	wraith_spook_button
		name = "wraith"
		desc = "Test"
		icon = 'icons/ui/context32x32.dmi'
		icon_state = "minus"
		icon_background = ""
		var/ability_code = 0

		New(var/code as num)
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

		checkRequirements(var/atom/target, var/mob/user)
			if (istype(target, /obj/screen/ability/topBar/wraith))
				var/obj/screen/ability/topBar/wraith/B = target
				if (istype(B.owner, /datum/targetable/wraithAbility/spook))
					var/datum/targetable/wraithAbility/spook/A = B.owner
					if (A.cooldowncheck())
						return 1
					else
						return 0
			return 1

		execute(var/atom/target, var/mob/user)
			if (istype(target, /obj/screen/ability/topBar/wraith))
				var/obj/screen/ability/topBar/wraith/B = target
				if (istype(B.owner, /datum/targetable/wraithAbility/spook))
					var/datum/targetable/wraithAbility/spook/A = B.owner
					A.do_spook_ability(ability_code)
					A.doCooldown()
			// target.addContextAction(/datum/contextAction/testfour)
			user.closeContextActions()
			return 0


	genebooth_product
		icon = 'icons/ui/context32x32.dmi'
		var/datum/geneboothproduct/GBP = 0
		var/obj/machinery/genetics_booth/GB = 0
		var/spamt = 0

		disposing()
			GBP = 0
			GB = 0
			..()

		execute(var/atom/target, var/mob/user)
			if (GB && GBP && (!GB.occupant || user == GB.occupant))
				GB.select_product(GBP)
			return 0

		checkRequirements(var/atom/target, var/mob/user)
			.= 0
			if (get_dist(target,user) <= 1 && isliving(user))
				.= GBP && GB
				if (GB && GB.occupant && world.time > spamt + 5)
					user.show_text("[target] is currently occupied. Wait until it's done.", "blue")
					spamt = world.time
					.= 0

		buildBackgroundIcon(var/atom/target, var/mob/user)
			var/image/background = image('icons/ui/context32x32.dmi', src, "[getBackground(target, user)]0")
			background.appearance_flags = RESET_COLOR
			.= background

		getIcon()
			if (GBP && GBP.BE)
				.= GBP.BE.icon
			else
				..()

		getIconState()
			if (GBP && GBP.BE)
				.= GBP.BE.icon_state
			else
				..()

		getName(var/atom/target, var/mob/user)
			if (GBP)
				.= GBP.name
			else
				..()

		getDesc(var/atom/target, var/mob/user)
			if (GBP)
				.= "PRICE : [GBP.cost]<br>[GBP.desc]<br><br>There are [GBP.uses] applications left."
			else
				..()

	deconstruction
		icon = 'icons/ui/context16x16.dmi'
		name = "Deconstruct with Tool"
		desc = "You shouldn't be reading this, bug."
		icon_state = "wrench"

		execute(var/atom/target, var/mob/user)
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

		checkRequirements(var/atom/target, var/mob/user)
			.= 0
			for (var/obj/item/deconstructor/D in user.equipped_list())
				return 1

		wrench
			name = "Wrench"
			desc = "Wrenching required to deconstruct."
			icon_state = "wrench"

			execute(var/atom/target, var/mob/user)
				for (var/obj/item/I in user.equipped_list())
					if (iswrenchingtool(I))
						user.show_text("You wrench [target]'s bolts.", "blue")
						playsound(get_turf(target), "sound/items/Ratchet.ogg", 50, 1)
						return ..()

		cut
			name = "Cut"
			desc = "Cutting required to deconstruct."
			icon_state = "cut"

			execute(var/atom/target, var/mob/user)
				for (var/obj/item/I in user.equipped_list())
					if (iscuttingtool(I) || issnippingtool(I))
						user.show_text("You cut some vestigial wires from [target].", "blue")
						playsound(get_turf(target), "sound/items/Wirecutter.ogg", 50, 1)
						return ..()
		weld
			name = "Weld"
			desc = "Welding required to deconstruct."
			icon_state = "weld"

			execute(var/atom/target, var/mob/user)
				user.show_text("You weld [target] carefully.", "blue")
				for (var/obj/item/weldingtool/W in user.equipped_list())
					if(W.try_weld(user, 2))
						return ..()

		pry
			name = "Pry"
			desc = "Prying required to deconstruct. Try a crowbar."
			icon_state = "bar"

			execute(var/atom/target, var/mob/user)
				for (var/obj/item/I in user.equipped_list())
					if (ispryingtool(I))
						user.show_text("You pry on [target] without remorse.", "blue")
						playsound(get_turf(target), "sound/items/Crowbar.ogg", 50, 1)
						return ..()

		screw
			name = "Screw"
			desc = "Screwing required to deconstruct."
			icon_state = "screw"

			execute(var/atom/target, var/mob/user)
				for (var/obj/item/I in user.equipped_list())
					if (isscrewingtool(I))
						user.show_text("You unscrew some of the screws on [target].", "blue")
						playsound(get_turf(target), "sound/items/Screwdriver.ogg", 50, 1)
						return ..()

		pulse
			name = "Pulse"
			desc = "Pulsing required to deconstruct. Try a multitool."
			icon_state = "pulse"

			execute(var/atom/target, var/mob/user)
				for (var/obj/item/I in user.equipped_list())
					if (ispulsingtool(I))
						user.show_text("You pulse [target]. In a general sense.", "blue")
						playsound(get_turf(target), "sound/items/penclick.ogg", 50, 1)
						return ..()

	vehicle
		icon = 'icons/ui/context16x16.dmi'
		name = "Vehicle action"
		desc = "You shouldn't be reading this, bug."
		icon_state = "wrench"

		execute(var/atom/target, var/mob/user)

		checkRequirements(var/atom/target, var/mob/user)
			.= (user.loc == target)


		board
			name = "Board"
			desc = "Hop on."
			icon_state = "board"

			checkRequirements(var/atom/target, var/mob/user)
				var/obj/machinery/vehicle/V = target
				.= ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null)

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.board()

		eject_occupants
			name = "Eject Occupants"
			desc = "Force occupants out of the vehicle."
			icon_state = "exit"

			checkRequirements(var/atom/target, var/mob/user)
				var/obj/machinery/vehicle/V = target
				.= ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null)

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.eject_occupants()

		lock
			name = "Show Lock Panel"
			desc = "Unlock the ship."
			icon_state = "lock"

			checkRequirements(var/atom/target, var/mob/user)
				var/obj/machinery/vehicle/V = target
				if (V.locked && V.lock)
					.= ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null)

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.lock.show_lock_panel(user,0)

		parts
			name = "Show Parts Panel"
			desc = "Replace ship parts."
			icon_state = "panel"

			checkRequirements(var/atom/target, var/mob/user)
				var/obj/machinery/vehicle/V = target
				.= ((user.loc != target) && BOARD_DIST_ALLOWED(user,V) && user.equipped() == null)

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.open_parts_panel(user)


		exit_ship
			name = "Exit Ship"
			desc = "Hop off."
			icon_state = "exit"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.exit_ship()

		access_main_computer
			name = "Access Main Computer"
			desc = "Manage some ship functions."
			icon_state = "computer"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.access_main_computer()

		fire_main_weapon
			name = "Fire Main Weapon"
			desc = "Fire your weapon. But you should probably be pressing SPACE to fire instead..."
			icon_state = "gun"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.fire_main_weapon()

		use_external_speaker
			name = "Use External Speaker"
			desc = "Talk to people with your ship intercom."
			icon_state = "speaker"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.use_external_speaker()

		create_wormhole
			name = "Create Wormhole"
			desc = "Warp to a pod beacon."
			icon_state = "portal"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.create_wormhole()

		access_sensors
			name = "Access Sensors"
			desc = "Scan your surroundings."
			icon_state = "radar"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.access_sensors()

		use_secondary_system
			name = "Use Secondary System"
			desc = "Use a secondary systems special function if it exists."
			icon_state = "computer2"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.use_secondary_system()

		open_hangar
			name = "Open Hangar"
			desc = "Toggle nearby hangar blast door remotely."
			icon_state = "door"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.open_hangar()

		return_to_station
			name = "Return To Station"
			desc = "Use the ship's comm system to locate the station's Space GPS beacon and plot a return course."
			icon_state = "return"

			execute(var/atom/target, var/mob/user)
				..()
				var/obj/machinery/vehicle/V = target
				V.return_to_station()


	instrument
		icon = 'icons/ui/context16x16.dmi'
		name = "Play Note"
		desc = "Click me to play a note!"
		icon_state = "note"
		use_tooltip = 0
		close_clicked = 0
		icon_background = "key"
		flick_on_click = "key2"

		var/note = 0

		execute(var/atom/target, var/mob/user)
			var/obj/item/instrument/I = target
			I.play_note(note,user)

		checkRequirements(var/atom/target, var/mob/user)
			.= ((user.equipped() == target) || target.density && target.loc == get_turf(target) && get_dist(user,target)<=1 && istype(target,/obj/item/instrument))

		special
			icon_background = "key_special"
/*
	offered
		icon = null
		icon_background = null

		maptext = "<span class='ps2p ol vt c' style='color: #f00;'>Do you want to?</span>"
		charge.maptext_y = -5
		charge.maptext_width = 96
		charge.maptext_x = -9

		execute(var/atom/target, var/mob/user)
			.= 0

		checkRequirements(var/atom/target, var/mob/user)
			.= 0

		item
			var/obj/item/I = null

			disposing()
				I = null
				..()

			buildBackgroundIcon-(var/atom/target, var/mob/user)
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

			getName(var/atom/target, var/mob/user)
				if (I)
					.= I.name
				else
					..()

			getDesc(var/atom/target, var/mob/user)
				if (I)
					.= I.desc
				else
					..()

	accept
		icon_state = "yes"
		var/datum/yesno_dialog/give_dialog = null

		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			target.addContextAction(/datum/contextAction/testfour)
			return 0

	refuse
		icon_state = "no"
		var/datum/yesno_dialog/give_dialog = null


		checkRequirements(var/atom/target, var/mob/user)
			return 1

		execute(var/atom/target, var/mob/user)
			target.addContextAction(/datum/contextAction/testfour)
			return 0
*/
