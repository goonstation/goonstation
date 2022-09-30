var/list/datum/contextAction/globalContextActions = null
/atom/var/list/datum/contextAction/contextActions = null

/atom/var/datum/contextLayout/contextLayout = null //Targets layout is used if possible, users layout otherwise.

//Uncomment these two lines for expanding menu testing
/*
/obj/item/contextActions = list(/datum/contextAction/expandadd)
/obj/item/contextLayout = new/datum/contextLayout/expandtest()
*/

/datum/contextLayout/proc/showButtons(list/buttons, atom/target)
	return

/datum/contextLayout/proc/addButtonToHud(target, atom/movable/screen/contextButton/C)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		H.hud.add_screen(C)

	else if(istype(target, /mob/living/critter))
		var/mob/living/critter/R = target
		R.hud.add_screen(C)

	else if(istype(target, /mob/wraith))
		var/mob/wraith/W = target
		W.hud.add_screen(C)

	else if (isrobot(target))
		var/mob/living/silicon/robot/robot = target
		robot.hud.add_screen(C)

	else if (isghostdrone(target))
		var/mob/living/silicon/ghostdrone/drone = target
		drone.hud.add_screen(C)

	else if (isAI(target))
		var/mob/living/silicon/ai/A = target
		if (isAIeye(target))
			var/mob/living/intangible/aieye/AE = target
			A = AE.mainframe
		A.hud.add_screen(C)

	else if (ishivebot(target))
		var/mob/living/silicon/hivebot/hivebot = target
		hivebot.hud.add_screen(C)
	else if (istype(target, /mob/living/intangible/flock))
		var/mob/living/intangible/flock/flock_entity = target
		flock_entity.render_special.add_screen(C)


/datum/contextLayout/flexdefault
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
		. = ..()

	showButtons(list/buttons, atom/target)
		var/atom/screenCenter = get_turf(usr.client.virtual_eye)
		var/screenX = ((screenCenter.x - target.x) * (-1)) * 32
		var/screenY = ((screenCenter.y - target.y) * (-1)) * 32
		var/offX = 0
		var/offY = spacingY

		screenX += offsetX
		screenY += offsetY

		for(var/atom/movable/screen/contextButton/C as anything in buttons)
			C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"

			addButtonToHud(usr, C)

			var/matrix/trans = new /matrix
			trans = trans.Reset()
			trans.Translate(offX, offY)

			animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)

			offX += spacingX
			if(offX >= spacingX * width)
				offX = 0
				offY -= spacingY

		. = buttons

/datum/contextLayout/instrumental
	var/spacingX = 16
	var/spacingY = 16
	var/offsetX = 0
	var/offsetY = 0

	New(var/SpacingX = 10, var/SpacingY = 16, var/OffsetX = 0, var/OffsetY = 0)
		spacingX = SpacingX
		spacingY = SpacingY
		offsetX = OffsetX
		offsetY = OffsetY
		. = ..()

	showButtons(list/buttons, atom/target)
		var/offX = 0
		var/offY = spacingY
		var/finalOff = spacingX * (buttons.len-3)
		offX -= finalOff/2

		for(var/atom/movable/screen/contextButton/C as anything in buttons)
			C.screen_loc = "CENTER,CENTER+0.6"

			addButtonToHud(usr, C)

			var/matrix/trans = new /matrix
			trans = trans.Reset()
			trans.Translate(offX, offY)

			animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=1)

			offX += spacingX
			//if(offX >= spacingX)
			//	offX = 0
			//	offY -= spacingY

		. = buttons

/datum/contextLayout/experimentalcircle
	var/dist
	///If true the first button in the list will be rendered in the center of the circle
	var/center = FALSE

	New(var/Dist = 32)
		dist = Dist
		return ..()

	showButtons(list/buttons, atom/target)
		var/atom/screenCenter = get_turf(usr.client.virtual_eye)
		var/screenX
		var/screenY
		if (!isturf(target.loc)) //hackish in-inventory compatability for lamp manufacturer, I don't understand HUD coordinate stuff
			var/turf/temp = get_turf(target)
			screenX = (screenCenter.x - temp.x) * -1 * 32
			screenY = (screenCenter.y - temp.y) * -1 * 32
		else
			screenX = (screenCenter.x - target.x) * -1 * 32
			screenY = (screenCenter.y - target.y) * -1 * 32

		var/anglePer = round(360 / (length(buttons) - (center ? 1 : 0)))

		var/count = 0

		for(var/atom/movable/screen/contextButton/C as anything in buttons)
			C.screen_loc = "CENTER:[screenX],CENTER:[screenY]"

			addButtonToHud(usr, C)

			// Uh, hardcoded sizes. getIconBounds doesnt work here since our icons can have empty pixels and then they wont be properly aligned with our button background.
			var/icon/Icon = icon(C.action.icon, C.action.icon_state)
			var/sizeX = Icon.Width()
			var/sizeY = Icon.Height()

			var/offX = round(dist * cos(anglePer * count)) + round(sizeX / 2)
			var/offY = round(dist * sin(anglePer * count)) + round(sizeY / 2)
			if (center && count == 0)
				offX = round(sizeX / 2)
				offY = round(sizeY / 2)
			var/matrix/trans = new /matrix
			trans = trans.Reset()
			trans.Translate(offX, offY)

			animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)
			count++

/datum/contextLayout/default

	showButtons(list/buttons, atom/target)
		var/atom/screenCenter = get_turf(usr.client.virtual_eye)
		var/screenX = ((screenCenter.x - target.x) * (-1)) * 32
		var/screenY = ((screenCenter.y - target.y) * (-1)) * 32
		var/offX = 0
		var/offY = 16

		for(var/atom/movable/screen/contextButton/C as anything in buttons)
			C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"

			addButtonToHud(usr, C)

			var/matrix/trans = new /matrix
			trans = trans.Reset()
			trans.Translate(offX, offY)

			animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)

			offX += 16
			if(offX > 16)
				offX = 0
				offY -= 16
		. = buttons

/datum/contextLayout/expandtest

	showButtons(list/buttons, atom/target)
		var/atom/screenCenter = get_turf(usr.client.virtual_eye)
		var/screenX = ((screenCenter.x - target.x) * (-1)) * 32
		var/screenY = ((screenCenter.y - target.y) * (-1)) * 32
		var/offX = 0
		var/offY = 16

		var/first = 1
		for(var/atom/movable/screen/contextButton/C as anything in buttons)
			C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"

			addButtonToHud(usr, C)

			var/matrix/trans = new /matrix
			trans = trans.Reset()
			trans.Translate(offX, offY + (first ? 16 : 0))

			animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)

			offX += (first ? 0 : 16)
			if(offX > 16)
				offX = 0
				offY -= 16
			first = 0
		. = buttons

/// for drawing context menu buttons based on screen_loc position instead of //DONE NOTHING YET
/datum/contextLayout/screen_HUD_default
	var/count_start_pos = 1

	showButtons(list/buttons, atom/movable/screen/target)
		var/longitude_dir
		var/lattitude_dir
		var/targetx
		var/targety

		// var/atom/screenCenter = usr.client.virtual_eye
		if (istype(target, /atom/movable/screen))
			var/atom/movable/screen/T = target
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
		else
			return 0

		var/count = count_start_pos
		for(var/atom/movable/screen/contextButton/C as anything in buttons)
			//C.screen_loc = "CENTER[(screenX) < 0 ? ":[screenX]":":[screenX]"],CENTER[(screenY) < 0 ? ":[screenY]":":[screenY]"]"
			C.screen_loc = "[lattitude_dir][targetx],[longitude_dir][targety]"

			addButtonToHud(usr, C)
			var/mob/dead/observer/GO = usr
			if(istype(GO)) GO.hud.add_screen(C)

			var/matrix/trans = new /matrix
			trans = trans.Reset()
			trans.Translate(0, -32*count)

			animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=5)

			count++
		. = buttons

/datum/contextLayout/screen_HUD_default/click_to_close
	count_start_pos = 0
