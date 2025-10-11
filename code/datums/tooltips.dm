/datum/tooltips
	/// The client
	var/client/owner = null
	/// All created tooltip window IDs will have this prefix
	var/windowPrefix = "tooltip"
	/// The window ID that contains the map
	var/mapId = "mapwindow"
	/// The control ID of the map
	var/mapControl = "map"
	/// The tooltip HTML, for caching
	var/html = ""
	/// Whether tooltip debugging enabled
	var/debug = FALSE
	/// The tooltip used for hovering over a target (we assume clients can only hover over one thing at a time)
	var/datum/tooltip/hoverTip = null
	/// All the tooltips opened by clicking on targets. _Should_ contain only visible tooltips
	var/list/datum/tooltip/clicktip/clickTips = list()
	/// A preloaded tooltip to use for the next shown pinned tooltip
	var/datum/tooltip/clicktip/preloadedClickTip = null

	New(client/C)
		..()
		if (!isclient(C)) return
		SPAWN(0)
			if (!isclient(C)) return
			src.owner = C
			src.clearAll()
			src.loadAssets()
			src.preload(TOOLTIP_HOVER)
			src.preload(TOOLTIP_PINNED)

	/// Special method to remove all tooltip windows
	/// Used on client login to clean up any tooltips that might have been stuck open from a previous round
	proc/clearAll()
		PRIVATE_PROC(TRUE)
		if (!src.owner) return
		for (var/window, windowId in params2list(winget(src.owner, "[src.mapId].*", "id")))
			if (findtext(windowId, src.windowPrefix, 1, length(src.windowPrefix) + 1))
				winset(src.owner, windowId, "parent=none")

	/// Send browser assets to the client
	proc/loadAssets()
		PRIVATE_PROC(TRUE)
		if (!cdn)
			src.owner.loadResourcesFromList(list(
				"browserassets/src/css/tooltip.css",
				"browserassets/src/vendor/js/eta.min.js",
				"browserassets/src/js/tooltip.js",
			) + recursiveFileList("browserassets/src/html/tooltips/"))

		src.html = grabResource("html/tooltip.html")
		// if (cdn)
		// 	src.html = replacetext(src.html, "<!-- TOOLTIP_CACHE -->", {"
		// 		<iframe src="[resource("html/tooltip_cache.html")]" id="cache-storage"></iframe>
		// 	"})

	/// Determine if we're allowed to show hover tooltips to a client
	proc/canShowHover()
		PRIVATE_PROC(TRUE)
		// Never show tooltips
		if (src.owner.preferences.tooltip_option == TOOLTIP_NEVER)
			return FALSE

		// Only show tooltips if ALT key pressed
		if (src.owner.preferences.tooltip_option == TOOLTIP_ALT && !src.owner.check_key(KEY_EXAMINE))
			return FALSE

		return TRUE

	/**
	 * Show a tooltip
	 *
	 * Arguments:
	 * * type (int) - Type of tooltip to show. One of `TOOLTIP_HOVER` or `TOOLTIP_PINNED`
	 * * target (atom) - The target of the tooltip
	 * * mouse (string) - Provided from MouseEntered (and similar) procs
	 * * title (string) - The text to display as a title
	 * * content (string) - The main content body to display
	 * * theme (string) - What theme to apply. See `tooltip.css` for available themes
	 * * align (list) - Bitmask representing alignment. See `_std\defines\tooltips.dm` for available flags.
	 * 									Multiple flags can be combined, e.g. `TOOLTIP_TOP | TOOLTIP_CENTER`
	 * * size (list) - Width and height respectively, e.g. `list(200, 300)`
	 * 								 Use `0` for either to use the automatic size for that axis
	 * * offset (list) - X and Y pixels respectively, e.g. `list(10, 20)`
	 * * bounds (list) - Width and height respectively, e.g. `list(200, 300)`
	 * * extra (list) - Any random extra stuff
	 */
	proc/show(type = TOOLTIP_HOVER, atom/target, mouse, title, content, theme, list/align, list/size, list/offset, list/bounds, list/extra)
		var/datum/tooltip/toShow = null
		if (type == TOOLTIP_HOVER && src.canShowHover())
			if (!src.hoverTip) src.hoverTip = new /datum/tooltip(src)
			toShow = src.hoverTip
		else if (type == TOOLTIP_PINNED)
			var/datum/tooltip/clicktip/clicktip = src.findClickTip(target)
			if (!clicktip)
				if (src.preloadedClickTip)
					clicktip = src.preloadedClickTip
					src.preloadedClickTip = null
				else
					clicktip = new /datum/tooltip/clicktip(src)
				src.clickTips += clicktip
				SPAWN(0)
					src.preload(TOOLTIP_PINNED)
			toShow = clicktip
		if (toShow)
			toShow.show(target, mouse, title, content, theme, align, size, offset, bounds, extra)

	/// Preload a tooltip by creating it ahead of time whilst remaining invisible
	/// Intended to speed up initial show times
	proc/preload(type)
		PRIVATE_PROC(TRUE)
		var/datum/tooltip/tooltip = null
		if (type == TOOLTIP_HOVER)
			tooltip = new /datum/tooltip(src)
			src.hoverTip = tooltip
		else if (type == TOOLTIP_PINNED)
			tooltip = new /datum/tooltip/clicktip(src)
			src.preloadedClickTip = tooltip
		tooltip.preloading = TRUE
		tooltip.create()
		return tooltip

	/**
	 * Hide a tooltip
	 *
	 * Arguments:
	 * * type (int) - Type of tooltip to hide. One of `TOOLTIP_HOVER` or `TOOLTIP_PINNED`
	 * * target (atom) - The target of the tooltip (only required if hiding a pinned tooltip)
	 */
	proc/hide(type = TOOLTIP_HOVER, atom/target)
		if (type == TOOLTIP_HOVER)
			src.hoverTip?.hide()
		else if (type == TOOLTIP_PINNED)
			var/datum/tooltip/clicktip/clicktip = src.findClickTip(target)
			if (clicktip) clicktip.remove()

	/// Hide all tooltips that were opened by clicking on any target
	proc/hideAllClickTips()
		for (var/datum/tooltip/clicktip/clicktip in src.clickTips)
			clicktip.remove()

	/// Find a tooltip that was opened by clicking on a specific target
	proc/findClickTip(atom/target)
		for (var/datum/tooltip/clicktip/clicktip in src.clickTips)
			var/atom/clicktipTarget = clicktip.target.deref()
			if (clicktipTarget == target) return clicktip

	/// Hide any type of tooltip opened on a specific target
	proc/hideOnTarget(atom/target)
		if (src.hoverTip)
			var/atom/hoverTarget = src.hoverTip.target.deref()
			if (hoverTarget == target) src.hide(TOOLTIP_HOVER)
		src.hide(TOOLTIP_PINNED, target)

	/// Hide all tooltips of any type
	proc/hideAll()
		src.hide(TOOLTIP_HOVER)
		src.hideAllClickTips()

	/// Move all visible tooltips
	/// Experimental and incomplete, do not use
	// proc/moveAll(move_dir)
	// 	src.hoverTip?.move(move_dir)
	// 	for (var/datum/tooltip/clicktip/clicktip in src.clickTips)
	// 		clicktip.move(move_dir)

	/// Escape hatch to completely reset in case of a broken state
	proc/reset()
		src.loadAssets()
		src.hoverTip?.remove()
		src.hideAllClickTips()
		src.preloadedClickTip = null
		src.clearAll()
		src.preload(TOOLTIP_HOVER)
		src.preload(TOOLTIP_PINNED)

	proc/toggleDebug()
		src.debug = !src.debug
		src.reset()

	/// Called when a tooltip is deleted. Do not call manually.
	proc/onTooltipRemoved(datum/tooltip/tooltip)
		if (istype(tooltip, /datum/tooltip/clicktip))
			src.clickTips -= tooltip
		else if (src.hoverTip == tooltip)
			src.hoverTip = null

	/// Called on mob move
	proc/onMove(move_dir)
		src.hideAllClickTips()
		// src.moveAll(move_dir)

	/// Called on window resize
	proc/onResize()
		src.hideAll()


/datum/tooltip
	var/datum/tooltips/holder
	var/datum/weakref/target
	var/datum/tooltipOptions/options
	var/window = ""
	var/preloading = FALSE
	var/loaded = FALSE
	var/showing = FALSE
	var/hiding = FALSE
	var/pinned = FALSE

	New(datum/tooltips/holder)
		..()
		src.holder = holder
		src.window = "[holder.windowPrefix][time2text(world.realtime, "DDhhmmss")][floor(world.time)][rand(1, 69420)]"
		src.options = new()

	disposing()
		src.remove()
		..()

	proc/create()
		var/isDisabled = !src.pinned
		if (src.holder.debug) isDisabled = FALSE
		winset(src.holder.owner, src.window, list2params(alist(
			"parent" = src.holder.mapId,
			"type" = "browser",
			"pos" = "0,0",
			"size" = "1x1",
			"anchor1" = "0,0",
			"is-visible" = FALSE,
			"is-disabled" = isDisabled,
			"background-color" = "#000",
			"use-title" = TRUE,
		)))

		var/html = replacetext(src.holder.html, "<!-- TOOLTIP_CONFIG -->", {"
			<script>
				window.tooltip_config = {
					ref: '\ref[src]',
					windowId: '[src.window]',
					mapControlId: '[src.holder.mapId].[src.holder.mapControl]',
					debug: [src.holder.debug ? "true" : "false"],
				};
			</script>
		"})

		src.holder.owner << browse(html, list2params(list("window" = src.window)))
		src.focusMap()

	proc/getIconSize()
		PRIVATE_PROC(TRUE)
		var/iconW = world.icon_size
		var/iconH = world.icon_size
		if (istext(world.icon_size))
			var/list/iconSizes = splittext(world.icon_size, "x")
			iconW = text2num(iconSizes[1])
			iconH = text2num(iconSizes[2])
		return alist("width" = iconW, "height" = iconH)

	proc/getView()
		PRIVATE_PROC(TRUE)
		var/viewX = src.holder.owner.view
		var/viewY = src.holder.owner.view
		if (istext(src.holder.owner.view))
			var/list/viewSizes = splittext(src.holder.owner.view, "x")
			viewX = (text2num(viewSizes[1]) - 1) / 2
			viewY = (text2num(viewSizes[2]) - 1) / 2
		return alist("x" = viewX, "y" = viewY)

	proc/setMouseWithoutParams(alist/clientView, alist/iconSize)
		PRIVATE_PROC(TRUE)
		var/atom/refTarget = src.target.deref()
		#ifndef SPACEMAN_DMM // pixloc var def broken
		var/pixloc/clientLoc = bound_pixloc(src.holder.owner.virtual_eye, SOUTHWEST)
		var/pixloc/targetLoc = bound_pixloc(refTarget, SOUTHWEST)
		var/tilesLeft = clientView["x"] + 1 - ((clientLoc.x - targetLoc.x) / iconSize["width"])
		var/tilesBottom = clientView["y"] + 1 - ((clientLoc.y - targetLoc.y) / iconSize["height"])
		src.options.mouse = alist(
			"left" = alist("tiles" = tilesLeft, "pixels" = 1, "icon" = refTarget.pixel_x * -1),
			"bottom" = alist("tiles" = tilesBottom, "pixels" = 1, "icon" = refTarget.pixel_y * -1),
		)
		#endif

	proc/shouldUpdate(atom/target)
		PRIVATE_PROC(TRUE)
		if (!src.target) return FALSE
		var/atom/refTarget = src.target.deref()
		return src.showing && !src.hiding && src.loaded && refTarget && target == refTarget

	proc/build()
		PRIVATE_PROC(TRUE)
		var/atom/refTarget = src.target.deref()
		if (!refTarget) return

		if (!src.options.bounds["width"] && !src.options.bounds["height"])
			var/icon/targetIcon = icon(refTarget.icon)
			src.options.setBounds(list(targetIcon.Width(), targetIcon.Height()))

		src.options.pinned = src.pinned
		src.options.transform = refTarget.transform
		src.options.hud = !refTarget.z

		if (hascall(refTarget, "tooltipHook"))
			refTarget:tooltipHook(src.options)

		var/list/iconSize = src.getIconSize()
		var/list/clientView = src.getView()

		if (length(src.options.mouse["left"]) == 0)
			src.setMouseWithoutParams(clientView, iconSize)

		var/params = list2params(list(
			json_encode(alist(
				"options" = src.options.toList(),
				"world" = alist(
					"maxx" = world.maxx,
					"maxy" = world.maxy,
					"icon_size" = iconSize,
				),
				"client" = alist(
					"view" = clientView,
					"bounds" = alist(
						"width" = src.holder.owner.bound_width,
						"height" = src.holder.owner.bound_height,
					),
				),
			))
		))

		if (src.hiding) return
		src.holder.owner << output(params, "[src.window]:tooltip.init")

	proc/update()
		PRIVATE_PROC(TRUE)
		if (src.hiding) return
		src.holder.owner << output(list2params(list(json_encode(alist(
			"options" = src.options.toList(),
		)))), "[src.window]:tooltip.update")

	// proc/move(move_dir)
	// 	if (!src.showing || src.options.hud) return
	// 	src.holder.owner << output(list2params(list(
	// 		move_dir,
	// 		src.holder.owner.fps || world.fps,
	// 		src.holder.owner.mob.step_size,
	// 		src.holder.owner.mob.glide_size,
	// 	)), "[src.window]:tooltip.reposition")

	proc/show(atom/target, mouse, title, content, theme, list/align, list/size, list/offset, list/bounds, list/extra)
		if (!src.holder) return
		var/update = src.shouldUpdate(target)
		src.preloading = FALSE
		src.hiding = FALSE
		src.target = get_weakref(target)

		if (isnull(src.target))
			// Failed to get a weakref to the target, it's probably queued for deletion
			return

		if (!update) src.options.reset()
		if (mouse) src.options.setMouse(mouse)
		if (title) src.options.title = title
		if (content) src.options.setContent(content)
		if (theme) src.options.theme = theme
		if (align) src.options.setAlign(align)
		if (size) src.options.setSize(size)
		if (offset) src.options.setOffset(offset)
		if (bounds) src.options.setBounds(bounds)
		if (extra) src.options.extra = extra

		if (update)
			src.update()
		else
			RegisterSignal(src.holder.owner.mob, COMSIG_MOB_DEATH, PROC_REF(hide), TRUE)
			RegisterSignal(target, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(hide), TRUE)
			src.updateObjDialog(TRUE)
			src.loaded ? src.build() : src.create()

	proc/hide()
		if (src.hiding || !src.holder) return
		src.hiding = TRUE
		src.holder.owner << output("", "[src.window]:tooltip.hide")

	proc/onHidden()
		PRIVATE_PROC(TRUE)
		src.showing = FALSE
		if (src.holder?.owner?.mob)
			UnregisterSignal(src.holder.owner.mob, COMSIG_MOB_DEATH)
		if (src.target)
			var/atom/refTarget = src.target.deref()
			UnregisterSignal(refTarget, COMSIG_PARENT_PRE_DISPOSING)
		src.updateObjDialog(FALSE)

	proc/remove()
		src.hiding = TRUE
		winset(src.holder.owner, src.window, "parent=null")
		src.onHidden()
		src.holder.onTooltipRemoved(src)

	proc/focusMap()
		PRIVATE_PROC(TRUE)
		winset(src.holder.owner, "[src.holder.mapId].[src.holder.mapControl]", "focus=1")

	/// Integration with `objDialog.dm`
	proc/updateObjDialog(add)
		PRIVATE_PROC(TRUE)
		if (!src.holder?.owner?.mob || !src.target) return
		var/atom/refTarget = src.target.deref()
		if (!refTarget || !isobj(refTarget)) return
		if (add)
			refTarget:add_dialog(src.holder.owner.mob)
		else
			refTarget:remove_dialog(src.holder.owner.mob)

	Topic(href, href_list)
		switch (href_list["action"])
			if ("loaded")
				src.loaded = TRUE
				if (!src.preloading) src.build()
			if ("showing")
				src.showing = TRUE
			if ("hidden")
				src.onHidden()
			if ("error")
				logTheThing(LOG_DEBUG, src.holder.owner, "<b>TOOLTIP ERROR:</b> [href_list["message"]]")


/datum/tooltip/clicktip
	pinned = TRUE


/datum/tooltipOptions
	/// The text to display as a title
	var/title
	/// The main content body to display
	var/content
	/// What theme to apply. See `tooltip.css` for available themes
	var/theme
	/// The transform matrix applied to the target atom
	var/transform
	/// Pinned means the tooltip requires clicking to open and close
	var/pinned = FALSE
	/// Whether the target is a non-map atom
	var/hud = FALSE
	/// Parsed coordinate data as provided from MouseEntered etc procs in params
	var/list/mouse
	/// Computed axis alignment
	var/list/align
	/// Computed tooltip size overrides
	var/list/size
	/// Computed tooltip positioning offsets
	var/list/offset
	/// Parsed target dimensions
	var/list/bounds
	/// Any random extra stuff
	var/list/extra

	proc/reset()
		src.title = null
		src.content = null
		src.theme = null
		src.transform = null
		src.pinned = FALSE
		src.hud = FALSE
		src.mouse = alist("left" = alist(), "bottom" = alist())
		src.align = alist("x" = "left", "y" = "bottom")
		src.size = alist("width" = 0, "height" = 0)
		src.offset = alist("x" = 0, "y" = 0, "tiles" = alist())
		src.bounds = alist("width" = 0, "height" = 0)
		src.extra = alist()

	proc/toList()
		return alist(
			"title" = src.title,
			"content" = src.content,
			"theme" = src.theme,
			"transform" = src.transform,
			"pinned" = src.pinned,
			"hud" = src.hud,
			"mouse" = src.mouse,
			"align" = src.align,
			"size" = src.size,
			"offset" = src.offset,
			"bounds" = src.bounds,
			"extra" = src.extra,
		)

	proc/setContent(content)
		if (islist(content) && content["file"])
			content["file_resource"] = resource("html/tooltips/[content["file"]]")
		src.content = content

	/**
	 * Parse and set the mouse target position
	 *
	 * Arguments:
	 * * params (string) - Provided from MouseEntered (and similar) procs
	 */
	proc/setMouse(params)
		src.mouse = alist("left" = alist(), "bottom" = alist())
		if (!params) return
		params = params2list(params)

		src.mouse["left"]["icon"] = text2num(params["icon-x"])
		src.mouse["bottom"]["icon"] = text2num(params["icon-y"])

		if (params["vis-x"]) src.mouse["left"]["vis"] = text2num(params["vis-x"])
		if (params["vis-y"]) src.mouse["bottom"]["vis"] = text2num(params["vis-y"])

		var/list/screenLoc = splittext(params["screen-loc"], ",")
		var/list/screenLocLeft = splittext(screenLoc[1], ":")
		src.mouse["left"]["tiles"] = text2num(screenLocLeft[1])
		src.mouse["left"]["pixels"] = text2num(screenLocLeft[2])
		var/list/screenLocBottom = splittext(screenLoc[2], ":")
		src.mouse["bottom"]["tiles"] = text2num(screenLocBottom[1])
		src.mouse["bottom"]["pixels"] = text2num(screenLocBottom[2])

	/**
	 * Set the position of the tooltip around the target
	 *
	 * Arguments:
	 * * flags (int) - Bitmask representing alignment. See `_std\defines\tooltips.dm` for available flags.
	 * 					 			 Multiple flags can be combined, e.g. `TOOLTIP_TOP | TOOLTIP_CENTER`
	 */
	proc/setAlign(flags)
		src.align = alist("x" = "left", "y" = "bottom")
		if (!flags) return

		var/list/newAlign = alist("x" = "", "y" = "")
		if (flags & TOOLTIP_TOP) newAlign["y"] = "top"
		else if (flags & TOOLTIP_BOTTOM) newAlign["y"] = "bottom"
		if (flags & TOOLTIP_RIGHT) newAlign["x"] = "right"
		else if (flags & TOOLTIP_LEFT) newAlign["x"] = "left"
		if (flags & TOOLTIP_CENTER)
			if (newAlign["x"]) newAlign["y"] = "center"
			else newAlign["x"] = "center"

		if (!newAlign["x"]) newAlign["x"] = "left"
		if (!newAlign["y"]) newAlign["y"] = "bottom"
		src.align = newAlign

	/**
	 * Override the size of the tooltip.
	 * Note that dimensions will still not exceed maximums set in `tooltip.css`, and are still subject to window/dpi scaling.
	 *
	 * Arguments:
	 * * newSize (list) - Width and height respectively, e.g. `list(200, 300)`
	 * 										Use `0` for either to use the automatic size for that axis
	 */
	proc/setSize(list/newSize)
		src.size = alist(
			"width" = newSize.len >= 1 ? newSize[1] : 0,
			"height" = newSize.len >= 2 ? newSize[2] : 0,
		)

	/**
	 * Set positioning offsets around the target, for example to push the tooltip down further away.
	 *
	 * Arguments:
	 * * newOffset (list) - X and Y pixels respectively, e.g. `list(10, 20)`
	 */
	proc/setOffset(list/newOffset)
		src.offset["x"] = newOffset.len >= 1 ? newOffset[1] : 0
		src.offset["y"] = newOffset.len >= 2 ? newOffset[2] : 0

	/**
	 * Set the dimensions of the target, required for tooltip positioning.
	 * Unlikely you will need to use this directly.
	 *
	 * Arguments:
	 * * newBounds (list) - Width and height respectively, e.g. `list(200, 300)`
	 */
	proc/setBounds(list/newBounds)
		src.bounds = alist(
			"width" = newBounds.len >= 1 ? newBounds[1] : 0,
			"height" = newBounds.len >= 2 ? newBounds[2] : 0,
		)

	/**
	 * Apply an extra positioning offset to the tooltip.
	 *
	 * Arguments:
	 * * direction (int) - Which way to push the tooltip, e.g. `NORTH`
	 * * amount (int) - How many tiles to move
	 */
	proc/pushTiles(direction, amount)
		src.offset["tiles"][direction] = amount


/client/verb/reloadTooltips()
	set name = "Reload Tooltips"
	set desc = "Use this if your tooltips are broken"
	src.tooltips.reset()
	boutput(src, "Tooltips reloaded")

/client/verb/debugTooltips()
	set hidden = TRUE
	set name = "Debug Tooltips"
	set desc = "Toggle tooltip debugging"
	src.tooltips.toggleDebug()
	boutput(src, "Tooltip debugging [src.tooltips.debug ? "enabled" : "disabled"]")
