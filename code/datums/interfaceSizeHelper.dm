/*
* A small thing that handles these little utility invisible html windows I added
* The windows use JS to get certain screen dimensions and so on
*/

/datum/interfaceSizeHelper
	var/client/owner = null
	var/window = "" //the...specific browser element to load into. look just roll with this
	var/interface = "" //the name of the window
	var/dataProp = "saved-params" //the interface property that contains the computed json
	var/htmlFile = "" //the html file to load into the interface
	var/loaded = 0 //has the interface loaded + set it's own saved-params
	var/list/lastData = new()
	var/list/onLoadCallbacks = new()

	New(client/C)
		..()
		if (!C) return
		src.owner = C
		src.load()

	//loads the html into the interface
	proc/load()
		if (!cdn)
			src.owner.loadResourcesFromList(list(
				"browserassets/src/js/interfaceSizeHelper.js"
			))

		var/html = src.get_html()
		src.owner.Browse(html, "window=[src.window];titlebar=0;can_close=0;can_resize=0;border=0")

	proc/get_html()
		. = grabResource(src.htmlFile)
		. = replacetext(., "holderRefHere", "\ref[src]")
		. = replacetext(., "interfaceHere", src.interface)
		. = replacetext(., "dataPropHere", src.dataProp)

	//tells the interface to recompute properties
	proc/update()
		if (!src.loaded || !src.owner || !src.interface) return
		src.owner << output("", "[src.interface]:sizeHelper.update")

	//fetches the computed data from the interface
	proc/getData()
		if (!src.loaded || !src.owner || !src.interface || !src.dataProp) return
		var/json = winget(src.owner, src.interface, src.dataProp)
		if (!rustg_json_is_valid(json)) return
		src.lastData = json_decode(json)
		return src.lastData

	//register procs to run after interface loaded
	proc/registerOnLoadCallback(datum/callback/callback)
		if (src.loaded)
			//we've already loaded! call the callback straight away
			callback.Invoke(src.lastData)
		else
			src.onLoadCallbacks += callback

	//run once on fully loaded
	proc/onLoad()
		if (src.loaded) return
		src.loaded = 1
		src.getData()

		for (var/datum/callback/callback in src.onLoadCallbacks)
			callback.Invoke(src.lastData)

		src.onLoadCallbacks = new()

	Topic(href, href_list)
		//tells us when the html/js is done loading
		if (href_list["action"] == "loaded")
			src.onLoad()

/datum/interfaceSizeHelper/screen
	window = "screenSizeHelper.screenSizeHelperBrowser"
	interface = "screenSizeHelper"
	htmlFile = "html/screenSizeHelper.html"

/datum/interfaceSizeHelper/map
	window = "mapwindow.mapSizeHelper"
	interface = "mapwindow.mapSizeHelper"
	htmlFile = "html/mapSizeHelper.html"
