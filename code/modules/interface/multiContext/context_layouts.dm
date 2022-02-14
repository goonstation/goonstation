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
			var/mob/dead/aieye/AE = target
			A = AE.mainframe
		A.hud.add_screen(C)

	else if (ishivebot(target))
		var/mob/living/silicon/hivebot/hivebot = target
		hivebot.hud.add_screen(C)


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

/datum/contextLayout/newinstrumental
	var/spacingX = 16
	var/spacingY = 16
	var/offsetX = 0
	var/offsetY = 0
	var/keyOffset = 1

	New(var/SpacingX = 5, var/SpacingY = 16, var/OffsetX = 0, var/OffsetY = 0, var/KeyOffset = 1)
		spacingX = SpacingX
		spacingY = SpacingY
		offsetX = OffsetX
		offsetY = OffsetY
		keyOffset = KeyOffset
		. = ..()

	showButtons(list/buttons, atom/target)
		var/offX = 0
		var/offY = spacingY
		var/finalOff = spacingX * (length(buttons)-3)
		offX -= finalOff/2

		var/buttonIndex = keyOffset

		var/list/blackKeys = list()
		var/list/blackKeysOffX = list()

		var/blackKeyYOff = 12

		var/keyCIndex = 1
		var/keyFIndex = 6
		var/keyBIndex = 12

		for(var/atom/movable/screen/contextButton/C as anything in buttons)
			C.screen_loc = "CENTER,CENTER+0.6"

			if(buttonIndex > keyBIndex)
				offX += 5
				buttonIndex = keyCIndex

			if(buttonIndex == keyFIndex)
				offX += 5

			switch(buttonIndex)
				if(2,4,7,9,11) // C#, D#, F#, G#, A# added to blackKeys list for proper rendering
					blackKeys += C
					blackKeysOffX += offX
					offY = spacingY + 12
				else
					offY = spacingY
					addButtonToHud(usr, C)

					var/matrix/trans = new /matrix
					trans = trans.Reset()
					trans.Translate(offX, offY)

					animate(C, alpha=255, transform=trans, easing=CUBIC_EASING, time=1)

			buttonIndex += 1
			offX += spacingX

		for(var/i in 1 to length(blackKeys))
			var/key = blackKeys[i]
			addButtonToHud(usr, key)

			var/matrix/trans = new /matrix
			trans = trans.Reset()
			trans.Translate(blackKeysOffX[i], offY+blackKeyYOff)

			animate(key, alpha=255, transform=trans, easing=CUBIC_EASING, time=1)

		. = buttons

/datum/contextLayout/experimentalcircle
	var/dist

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

		var/anglePer = round(360 / buttons.len)

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
