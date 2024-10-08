
/client/proc/wireTest()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "WireTest"
	set hidden = 1
	ADMIN_ONLY

	var/loopTimes = input(src, "How many loops?") as num

	var/counter = 1
	while (counter <= loopTimes)
		SPAWN(0)
			var/response = wireSendTest()
			var/msg = "\[[counter]\] - "
			if (response == "This is a test")
				msg += "Success"
			else
				msg += "Failed"
			boutput(src, msg)
		counter++

	boutput(src, "Done!")

/proc/wireSendTest()
	var/datum/apiModel/Message/message
	try
		var/datum/apiRoute/test/getTest = new
		message = apiHandler.queryAPI(getTest)
	catch (var/exception/e)
		var/datum/apiModel/Error/error = e.name
		return error.message
	return message.message

/proc/mapWorldNew(client/C)
	// future proofing against varied world icon sizes
	var/iconWidth
	var/iconHeight
	var/iconSize = getIconSize()
	if (islist(iconSize))
		iconWidth = iconSize["width"]
		iconHeight = iconSize["height"]
	else
		iconWidth = iconHeight = iconSize

	// user input
	// TODO: sensible maximum values?
	var/areaW = input(C, "How many tiles wide?", "Width", 10) as num
	if (!areaW || areaW < 1)
		return alert("Invalid width given")

	var/areaH = input(C, "How many tiles high?", "Height", 10) as num
	if (!areaH || areaH < 1)
		return alert("Invalid height given")

	// create a blank icon at the appropriate size
	var/icon/canvas = icon('icons/misc/flatBlank.dmi')
	canvas.Crop(1, 1, areaW * iconWidth, areaH * iconHeight)

	var/turf/startT = C.mob.loc
	var/startX = startT.x
	var/startY = startT.y
	var/startZ = startT.z

	boutput(C, "===========================<br>Starting")

	// loop through all tiles in area
	for (var/thisX = startX, thisX < (startX + areaW), thisX++)
		var/currentX = (thisX - startX) + 1
		for (var/thisY = startY, thisY < (startY + areaH), thisY++)
			var/currentY = (thisY - startY) + 1
			boutput(C, "Processing tile: [thisX], [thisY]. CurrentX: [currentX]. CurrentY: [currentY]")

			// get the turf on the loc
			var/turf/T = locate(thisX, thisY, startZ)

			// usually (only?) means we're at a map edge
			if (!T)
				continue

			var/icon/turfIcon = getFlatIcon(T)

			// create a copy of the turf contents sorted by layer (lowest first)
			var/list/contentsCopy = T.contents.Copy()
			for (var/r = 1, r <= contentsCopy.len, r++)
				for (var/i = 1, i < contentsCopy.len, i++)
					var/atom/first = contentsCopy[i]
					var/atom/second = contentsCopy[i + 1]
					if (first.layer > second.layer)
						contentsCopy.Swap(i, i + 1)

			// loop through all things on that loc
			for (var/atom/thing in contentsCopy)
				// ignore things we don't want in the final image. lighting etc
				if (thing.invisibility || istype(thing, /obj/overlay/tile_effect))
					continue

				// TODO: handle large items (multi-tile things)
				// TODO: handle pixel offsets somehow

				// blend each thing onto the initial turf
				var/icon/thingIcon = getFlatIcon(thing)
				turfIcon.Blend(thingIcon, ICON_OVERLAY, 1, 1)

			// blend the composite turf icon into the canvas
			var/offsetX = ((currentX * iconWidth) - iconWidth) + 1
			var/offsetY = ((currentY * iconHeight) - iconHeight) + 1
			//boutput(C, "-- Blending into canvas at [offsetX], [offsetY]")
			canvas.Blend(turfIcon, ICON_OVERLAY, offsetX, offsetY)

	// create a new icon and insert the generated canvas, so that BYOND doesn't generate different directions
	// Wire note: thank you /tg/ for this code snippet
	var/icon/finalCanvas = new /icon()
	finalCanvas.Insert(canvas, "", SOUTH, 1, 0)

	// save constructed image to local disk
	var/dest = "data/test.png"
	if (fcopy(finalCanvas, dest))
		boutput(C, "Done. Canvas saved to [dest]")
	else
		boutput(C, "ERROR saving canvas to [dest]")

	boutput(C, "===========================")


//Silly little thing that the bans panel calls on refresh
/proc/getWorldMins()
	var/CMinutes = num2text((world.realtime / 10) / 60, 99) //fuck you byond scientific notation
	if (centralConn)
		var/list/returnData = new()
		returnData["cminutes"] = CMinutes
		return json_encode(returnData)
	else
		return CMinutes


/* Death confetti yayyyyyyy */
#ifdef XMAS
var/global/deathConfettiActive = 1
#else
var/global/deathConfettiActive = 0
#endif

/mob/proc/deathConfetti()
	particleMaster.SpawnSystem(new /datum/particleSystem/confetti(src.loc))
	SPAWN(1 SECOND)
		playsound(src.loc, 'sound/voice/yayyy.ogg', 50, 1)

/client/proc/toggle_death_confetti()
	set popup_menu = 0
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Death Confetti"
	set desc = "Toggles the fun confetti effect and sound whenever a mob dies"
	ADMIN_ONLY
	SHOW_VERB_DESC

	deathConfettiActive = !deathConfettiActive

	logTheThing(LOG_ADMIN, src, "toggled Death Confetti [deathConfettiActive ? "on" : "off"]")
	logTheThing(LOG_DIARY, src, "toggled Death Confetti [deathConfettiActive ? "on" : "off"]", "admin")
	message_admins("[key_name(src)] toggled Death Confetti [deathConfettiActive ? "on" : "off"]")


/datum/limb/sun

/mob/living/critter/sun
	name = "sun"
	real_name = "sun"
	desc = "A sentient, very small, star. Why not."
	density = 1
	icon_state = "sun"
	icon_state_dead = "sun-dead"
	custom_gib_handler = /proc/gibs
	hand_count = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	speechverb_say = "booms"
	speechverb_exclaim = "flares"
	speechverb_ask = "spots"
	blood_id = "phlogiston"
	metabolizes = 0
	var/datum/light/glow

	New()
		..()
		src.glow = new /datum/light/point
		src.glow.set_brightness(0.8)
		src.glow.set_color(0.94, 0.69, 0.27)
		src.glow.attach(src)
		src.glow.enable()

	death(gibbed)
		src.glow.disable()
		..(gibbed)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/sun
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.name = "solar wind"
		HH.limb_name = "solar wind"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("flare", "pulsar")
				if (src.emote_check(voluntary, 50))
					return "<b>[src]</b> [act]s!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("flare", "pulsar")
				return 2
		return ..()

	setup_healths()
		add_hh_robot(150, 1.15)


/client/proc/ghostdroneAll()
	set name = "Ghostdrone All"
	set desc = "Makes every single person a ghostdrone. Why are you doing this."
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set hidden = 1
	ADMIN_ONLY

	for (var/mob/living/L in mobs)
		if (L.client && !isghostdrone(L))
			droneize(L, 0)

	logTheThing(LOG_ADMIN, src, "made everyone a ghostdrone!")
	logTheThing(LOG_DIARY, src, "made everyone a ghostdrone!", "admin")
	message_admins("[key_name(src)] made everyone a ghostdrone!")


/client/proc/toggle_hard_reboot()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER) // Not in toggles because it's not enabling/disabling game features
	set name = "Toggle Hard Reboot"
	set desc = "A hard reboot is when the game instance outright ends, and the backend server reinitialises it"

	ADMIN_ONLY
	SHOW_VERB_DESC

	var/hardRebootFileExists = fexists(hardRebootFilePath)
	var/logMessage = ""

	if (hardRebootFileExists && alert("A hard reboot is already queued, would you like to remove it?",, "Yes", "No") == "Yes")
		fdel(hardRebootFilePath)
		logMessage = "removed a server hard reboot"

	else if (!hardRebootFileExists && alert("No hard reboot is queued, would you like to queue one?",, "Yes", "No") == "Yes")
		file(hardRebootFilePath) << ""
		logMessage = "queued a server hard reboot"

	else
		return

	logTheThing(LOG_DEBUG, src, logMessage)
	logTheThing(LOG_DIARY, src, logMessage, "admin")
	message_admins("[key_name(src)] [logMessage]")

	var/ircmsg[] = new()
	ircmsg["key"] = src.key
	ircmsg["msg"] = logMessage
	ircbot.export_async("admin", ircmsg)

/proc/goonhub_href(path, in_byond = FALSE)
	var/url = "[config.goonhub_url][path]"
	if (in_byond)
		return "byond://winset?command=.openlink \"[url_encode(url)]\""
	return url
