/*
Tooltips v2.1 - 20/02/18
Developed by Wire (#goonstation on irc.synirc.net)
- Optimization and improvements aimed at avoiding stolen-focus issues

Configuration:
- Set the window and file vars on /datum/tooltipHolder below
- Attach the datum to the user client on login, e.g.
	/client/New()
		src.tooltipHolder = new /datum/tooltipHolder(src)
		src.tooltipHolder.clearOld() //Clears tooltips stuck from a previous connection

Usage:
- Define mouse event procs on your (probably HUD) object and simply call the show and hide procs respectively:
	/atom/movable/screen/hud
		MouseEntered(location, control, params)
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"content" = (src.desc ? src.desc : null)
			))

		MouseExited()
			usr.client.tooltipHolder.hideHover()

- You may use flags defined in _setup.dm to tweak the tooltip. For example to align it centered:
	usr.client.tooltipHolder.showHover(src, list(
		"params" = params,
		"content" = (src.desc ? src.desc : null),
		"flags" = TOOLTIP_CENTERED
	))

- You can define manual pixel offsets to force the tooltip go a certain direction.
- Both values are optional. You can define an x offset without a y offset.
- Note that the values are pixels based on byond tile size. E.g. an offset of 32 will move it a whole tile
	usr.client.tooltipHolder.showHover(src, list(
		"params" = params,
		"content" = (src.desc ? src.desc : null),
		"offset" = list("x" = 10, "y" = 20)
	))

Customization:
- Theming can be done by passing a "theme" key in the options list and using css in the html file to change the look
- For your convenience some pre-made themes are included

Options:
- Valid values for the options list are:
	- params (required)
	- title (required if no "content" key)
	- content (required if no "title" key)
	- theme (defaults to "default")
	- size (defaults to auto-sizing to content, is given in widthxheight e.g. 300x200, auto does what it sounds like)
	- special (a string to tell the JS to do something ~special~ e.g. edge cases)
	- flags (bitwise property using tooltip alignment flags)
	- offset (manual pixel offsets)
	- transition (string determining how the tooltip should animate in)

Notes:
- You may have noticed 90% of the work is done via javascript on the client. Gotta save those cycles man.
- This is entirely untested in any other codebase besides goonstation so I have no idea if it will port nicely. Good luck!
*/


//Prints a whole bunch of shit to the in-game chat
//#define TOOLTIP_DEBUG 1


#ifdef TOOLTIP_DEBUG
/proc/tooltipDebugOut(who, msg)
	out(who, "<span style='font-size: 0.85em'>\[[time2text(world.realtime, "hh:mm:ss")]\] <strong>(TOOLTIP DEBUG | DM)</strong> [msg]</span>")
#endif

var/global/list/atomTooltips = new()

/datum/tooltipHolder
	//Configurable vars
	var/window = "tooltip" //whatchu want the window to be called
	var/file = "html/tooltip.html" //the browser content file

	//Internal use only, don't fuck with these
	var/client/owner
	var/list/tooltips = new()
	var/datum/tooltip/transient = null
	var/inPod = 0 //for fuck sake


	New(client/C)
		..()
		if (!C) return 0
		src.owner = C

		//For local-testing fallback
		if (!cdn)
			var/list/tooltipResources = list(
				"browserassets/js/jquery.min.js",
				"browserassets/js/jquery.waitForImages.js",
				"browserassets/js/errorHandler.js",
				"browserassets/js/animatePopup.js",
				"browserassets/js/tooltip.js",
				"browserassets/css/fonts/fontawesome-webfont.eot",
				"browserassets/css/fonts/fontawesome-webfont.ttf",
				"browserassets/css/fonts/fontawesome-webfont.woff",
				"browserassets/css/font-awesome.css",
				"browserassets/css/tooltip.css"
			)
			src.owner.loadResourcesFromList(tooltipResources)

		src.transient = src.add(clone = 0, stuck = 0)

		return 1


	//Get rid of any stuck orphaned tooltips (usually from reconnecting)
	proc/clearOld()
		if (!src.owner) return // Guard against bad/missing clients
		var/windows = winget(src.owner, null, "windows")
		var/list/windowIDs = params2list(windows)
		for (var/windowID in windowIDs)
			if (src.owner && dd_hasprefix(windowID, src.window))
				winset(src.owner, windowID, "parent=")


	proc/add(atom/thing = null, clone = 1, stuck = 1)
		var/datum/tooltip/tooltip = new(src.owner, src, clone, stuck, thing)
		src.tooltips.Add(tooltip)
		return tooltip


	proc/remove(datum/tooltip/tooltip)
		if (tooltip in src.tooltips)
			qdel(tooltip)
			return 1

		return 0


	proc/getTooltipFor(atom/thing)
		if (!istype(thing)) return 0

		for (var/datum/tooltip/t in src.tooltips)
			if (t.A == thing)
				return t


	proc/showHover(atom/thing, list/options)
		//User just HATES tooltips :(
		if (src.owner.preferences.tooltip_option == TOOLTIP_NEVER)
			return 0

		//User wants to see tooltips on alt-key-held only, what a weirdo
		if (src.owner.preferences.tooltip_option == TOOLTIP_ALT)
			if (!owner.check_key(KEY_EXAMINE))
				return 0

		src.transient.show(thing, options)


	proc/hideHover()
		src.transient.hide()


	proc/showClickTip(atom/thing, list/options)
		var/datum/tooltip/clickTip = src.getTooltipFor(thing)

		//Clicktip for this atom doesn't exist yet, create it
		if (!clickTip)
			clickTip = src.add(thing)

		//Some stuff relies on currently-viewed-machine being set
		if (src.owner.mob)
			if (isobj(thing))
				thing:add_dialog(src.owner.mob)

		if (clickTip.visible)
			//Clicktip is currently showing, just update it
			clickTip.changeContent(options["title"], options["content"])
		else
			//Show clicktip (and position it ourselves if necessary)
			if (!options["params"])
				options["params"] = thing.getScreenParams()
			clickTip.show(thing, options)
			clickTip.bindCloseHandler()


	proc/hideClickTip(atom/thing)
		var/datum/tooltip/clickTip = src.getTooltipFor(thing)

		if (clickTip)
			clickTip.hide()


/datum/tooltip
	//Internal use only, don't fuck with these
	var/datum/tooltipHolder/holder
	var/screenProperties = ""
	var/window
	var/file
	var/client/owner
	var/atom/A
	var/showing = 0
	var/init = 0
	var/uid = 0
	var/isClone = 0
	var/isStuck = 1
	var/creating = 0
	var/created = 0
	var/visible = 0
	var/hasCloseHandler = 0
	//var/list/specialFlags = new()
	var/list/savedOptions


	New(client/C, datum/tooltipHolder/tipHolder, clone = 1, stuck = 1, atom/thing = null)
		..()
		if (!C) return 0
		src.owner = C
		src.holder = tipHolder
		src.isClone = clone
		src.isStuck = stuck
		src.A = thing //HARD DELETE FIX IT!!

		src.window = tipHolder.window
		src.file = tipHolder.file

		if (clone && thing)
			var/list/atomTipRefs = new()
			atomTipRefs.Add(src)
			atomTooltips[thing] = atomTipRefs

		#ifdef TOOLTIP_DEBUG
		tooltipDebugOut(src.owner, "New() called. clone: [clone]. stuck: [stuck]. thing: [thing] (\ref[thing])")
		#endif

		return 1


	disposing()
		if (src.A && atomTooltips[src.A] && (src in atomTooltips[src.A]))
			var/list/atomTipRefs = atomTooltips[src.A]
			atomTipRefs.Remove(src)

		if (src.owner)
			if (src.holder && (src in holder.tooltips))
				src.holder.tooltips.Remove(src)

			if (src.hasCloseHandler)
				src.closeHandler()

			src.owner << browse(null, "window=[src.window]")

		A = null

		..()


	Topic(href, href_list[])
		switch (href_list["action"])
			if ("log")
				out(src.owner, "<span style='font-size: 0.85em'>\[[time2text(world.realtime, "hh:mm:ss")]\] <strong>(TOOLTIP DEBUG | JS)</strong> [href_list["msg"]]</span>")
			if ("show")
				src.show2(src.savedOptions)
			if ("hide")
				var/force = href_list["force"] ? text2num(href_list["force"]) : 0
				src.hide(force, 1)


	proc/create()
		if (!src.created && !src.creating)
			src.creating = 1
			src.screenProperties = src.owner.screenSizeHelper.getData()

			if (src.isClone)
				src.uid = "[world.timeofday][rand(1,10000)]"
				var/newWindow = "[src.window][src.uid]"
				winclone(src.owner, newWindow, src.window)
				src.window = newWindow

			#ifdef TOOLTIP_DEBUG
			tooltipDebugOut(src.owner, "create() called")
			#endif

			var/fileText = replacetext(grabResource(src.file), "TOOLTIPREFPLACE", "\ref[src]");
			#ifdef TOOLTIP_DEBUG
			fileText = replacetext(fileText, "var tooltipDebug = false;", "var tooltipDebug = true;")
			#endif

			//Create the window, and set options on the browser control (while at the same time forcing focus back to the map)
			src.owner << browse(fileText, "window=[src.window];titlebar=0;can_close=0;can_resize=0;can-minimize=0;border=0;size=1,1;")
			winset(src.owner, null, "mapwindow.map.focus=true;[src.window].alpha=0;[src.window].pos=0,0;[src.window].background-color=[transparentColor];[src.window].transparent-color=[transparentColor];")
			return 1
		return 0


	proc/show(atom/thing, list/options)
		if (src.showing || !thing || !istype(thing) || !src.owner || !options || !options["params"] || (!options["title"] && !options["content"]) || (options["flags"] && !isnum(options["flags"])))
			return 0

		#ifdef TOOLTIP_DEBUG
		tooltipDebugOut(src.owner, "show() called. args: [html_encode(json_encode(args))]")
		#endif

		if (options["title"])
			options["title"] = stripTextMacros(options["title"])
		if (options["content"])
			options["content"] = stripTextMacros(options["content"])

		if (!options["theme"])
			options["theme"] = "default"

		//if (options["theme"] == "default" && "tooltipTheme" in thing.vars)
		//	options["theme"] = thing.vars["tooltipTheme"]

		//if (options["special"] == "none" && "tooltipSpecial" in thing.vars)
		//	options["special"] = thing.vars["tooltipSpecial"]

		//I hate that I need this
		if (src.holder.inPod)
			options["special"] = "pod"

		src.showing = 1
		src.A = thing
		src.savedOptions = options

		if (src.created)
			src.show2(options)
		else
			src.create()


	proc/show2(options)
		if (!src.created || src.creating)
			src.created = 1
			src.creating = 0

		src.visible = 1
		var/list/params = new()

		if (!src.init)
			//Initialize some vars
			src.init = 1
			params["init"] = list(
				"iconSize" = world.icon_size,
				"window" = src.window,
				"map" = json_encode(list("parent" = "mapwindow", "control" = "map", "helper" = "mapSizeHelper")),
				"screen" = src.screenProperties
			)

		if (options["flags"])
			var/list/extra = new()
			if (options["flags"] & TOOLTIP_TOP)
				extra += "top"
			if (options["flags"] & TOOLTIP_RIGHT)
				extra += "right"
			if (options["flags"] & TOOLTIP_LEFT)
				extra += "left"
			if (options["flags"] & TOOLTIP_CENTER)
				extra += "center"
			if (options["flags"] & TOOLTIP_TOP2)
				extra += "top2"

			params["flags"] = extra
			//src.specialFlags = extra

		params["cursor"] = islist(options["params"]) ? list2params(options["params"]) : options["params"]
		params["screenLoc"] = istype(src.A, /atom/movable) ? (src.A:screen_loc) : null

		#ifdef TOOLTIP_DEBUG
		//Payload: { "cursor": "icon-x=11;icon-y=22;screen-loc=6:11,2:22", "screenLoc": "CENTER-2, SOUTH+1", "flags": [] }. Theme: item. Special: none
		tooltipDebugOut(src.owner, "show2() calling update. Params: [json_encode(params)]. Theme: [options["theme"]]. Size: [options["size"]]. Special: [options["special"]]")
		#endif

		var/viewX = src.owner.view
		var/viewY = src.owner.view
		if (istext(src.owner.view))
			var/list/viewSizes = splittext(src.owner.view, "x")
			viewX = (text2num(viewSizes[1]) - 1) / 2
			viewY = (text2num(viewSizes[2]) - 1) / 2

		//Send stuff to the tooltip
		src.owner << output(list2params(list(
				json_encode(params),
				json_encode(options),
				viewX,
				viewY,
				src.isStuck
			)), "[src.window].browser:tooltip.update")

		src.showing = 0
		return 1


	proc/changeContent(title = "", content = "")
		if (!title && !content) return 0

		src.owner << output(list2params(list(title, content)), "[src.window].browser:tooltip.changeContent")

		return 1


	proc/hide(force = 0, fromJS = 0)
		if (!force && (!src.created || !src.owner || !src.visible)) return 0

		src.visible = 0

		#ifdef TOOLTIP_DEBUG
		tooltipDebugOut(src.owner, "hide() called. force: [force]. fromJS: [fromJS]. src.visible: [src.visible]. src.created: [src.created]. src.isStuck: [src.isStuck]")
		#endif

		if (!fromJS && src.owner)
			src.owner << output(1, "[src.window].browser:tooltip.setInterrupt")

		if(src.owner)
			winset(src.owner, src.window, "alpha=0;size=1x1;pos=0,0")

		if (src.hasCloseHandler)
			src.closeHandler()

		return 1


	proc/position(params)
		src.owner << output(list2params(list(params)), "[src.window].browser:tooltip.position")


	proc/isVisible()
		var/visible = winget(src.owner, src.window, "alpha")
		return visible != "0"


	proc/detachMachine()
		if (src.owner && src.owner.mob)
			if (src.A && isobj(src.A))
				src.A:remove_dialog(src.owner.mob)

	proc/closeHandler()
		if (!src.hasCloseHandler) return 0

		src.detachMachine()
		src.hasCloseHandler = 0


	proc/bindCloseHandler()
		src.hasCloseHandler = 1


/client/proc/resizeTooltipEvent()
	if (src.tooltipHolder)
		for (var/datum/tooltip/t in src.tooltipHolder.tooltips)
			t.hide()


/client/proc/cmd_tooltip_debug()
	set name = "Debug Tooltips"
	set desc = "Returns the amount of tooltips in existence everywhere"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

	ADMIN_ONLY

	var/holderCount = 0
	var/tooltipCount = 0
	for (var/client/C in clients)
		if (C.tooltipHolder)
			holderCount++
			for (var/datum/tooltip/t in C.tooltipHolder.tooltips)
				tooltipCount++

	var/msg = {"----------<br />
		<strong>[holderCount]</strong> tooltip holder datums exist<br />
		<strong>[tooltipCount]</strong> tooltip datums exist<br />
		<strong>[length(atomTooltips)]</strong> atoms have tooltips<br />
		<strong>atomTooltips:</strong> [json_encode(atomTooltips)]<br />
	----------"}

	out(src, msg)


//Mimics the params list given in Click() or MouseEntered()
//Useful if you don't have access to the params those supply (e.g. programmatically showing a tooltip)
/atom/proc/getScreenParams()
	set src in view()

	if (!usr || !usr.client)
		return 0

	var/atom/screenCenter = usr.client.virtual_eye
	var/viewCenterX = usr.client.view
	var/viewCenterY = usr.client.view

	if (istext(usr.client.view))
		var/list/viewSizes = splittext(usr.client.view, "x")
		viewCenterX = (text2num(viewSizes[1])-1)/2
		viewCenterY = (text2num(viewSizes[2])-1)/2

	var/xDist = screenCenter.x - src.x
	var/yDist = screenCenter.y - src.y
	var/screenX = (viewCenterX + 1) - xDist
	var/screenY = (viewCenterY + 1) - yDist

	if (src.pixel_x || src.pixel_y)
		var/iconWidth
		var/iconHeight
		var/iconSize = getIconSize()
		if (islist(iconSize))
			iconWidth = iconSize["width"]
			iconHeight = iconSize["height"]
		else
			iconWidth = iconHeight = iconSize

		if (src.pixel_x)
			screenX += round(src.pixel_x / iconWidth)

		if (src.pixel_y)
			screenY += round(src.pixel_y / iconHeight)

	var/list/params = list(
		"icon-x" = 1,
		"icon-y" = 1,
		"screen-loc" = "[screenX]:1,[screenY]:1"
	)

	return params



//Hides click-toggle tooltips on player movement
/mob/OnMove(source = null)
	..()

	if (usr && src.client && src.client.tooltipHolder)
		for (var/datum/tooltip/t in src.client.tooltipHolder.tooltips)
			if (t.isStuck)
				t.hide()



//Look this just makes sense ok
/mob/death(gibbed)
	..(gibbed)

	if (usr && src.client && src.client.tooltipHolder)
		for (var/datum/tooltip/t in src.client.tooltipHolder.tooltips)
			t.hide()


/atom/disposing()
	if ((src in atomTooltips) && islist(atomTooltips[src]))
		var/list/thingTooltips = atomTooltips[src]

		for (var/datum/tooltip/t in thingTooltips)
			qdel(t)

		atomTooltips.Remove(src)
	if(!ismob(src)) // I want centcom cloner to look good, sue me
		ClearAllOverlays()
	. = ..()


// DEBUG
#ifdef TOOLTIP_DEBUG
/client/verb/reloadTooltip()
	set name = "Reload Tooltips"

	for (var/datum/tooltip/t in src.tooltipHolder.tooltips)
		qdel(t)

	del(src.tooltipHolder)
	src.tooltipHolder = new /datum/tooltipHolder(src)

	out(src, "Reloaded tooltips")
#endif

/* experiments with trigger tracking, probably horribly performance intensive
/mob/OnMove()
	..()

	if (usr && src.client)
		for (var/datum/tooltip/t in src.client.tooltipHolder.tooltips)
			if (t.trackThing)
				if (src in view(usr))
					var/list/objLoc = t.A.getScreenParams()

					//Payload: { "cursor": "icon-x=11;icon-y=22;screen-loc=6:11,2:22", "screenLoc": "CENTER-2, SOUTH+1", "flags": [] }. Theme: item. Special: none
					var/list/payload = new()
					payload["cursor"] = "icon-x=1;icon-y=1;screen-loc=[objLoc["screen_x"]]:1,[objLoc["screen_y"]]:1"
					payload["screenLoc"] = t.A.screen_loc
					payload["flags"] = t.specialFlags

					t.position(json_encode(payload))

				else
					t.hide()

			else
				t.hide()
*/
