var/list/areaColorList = new/list()
// meh
var/list/stationMap_bannedAreas = list("Space", "Wizard's Den", "Abandoned ship")

proc/getAreaColor(var/area/A)
	if (areaColorList.Find(A.type))
		return areaColorList[A.type]
	else
		var/newCol = rgb(rand(30, 255),rand(30, 255),rand(30, 255))
		areaColorList.Add(A.type)
		areaColorList[A.type] = newCol
		return newCol

var/global/icon/station_map = null

// now that the map is cached, maybe we can have it black out turfs that get destroyed and replaced with space?
/proc/generateStationMap(var/obj/source)
	if (!station_map)
		station_map = icon('icons/misc/mapEmpty.dmi', "template")
		for (var/y=world.maxy, y > 0, y--)
			for (var/x=1, x<=world.maxx, x++)
				var/turf/located = locate(x,y,1)
				if (located.loc.name in stationMap_bannedAreas) //This might look like i don't know how to code but there's a reason for this, trust me.
					station_map.DrawBox(rgb(15,15,15), x,y)
				else
					station_map.DrawBox(getAreaColor(located.loc), x,y)

	var/icon/map = new(station_map)
	var/icon/marker = icon('icons/obj/stationobjs.dmi', "youmark")
	map.Blend(marker, ICON_OVERLAY, source.x - 2, source.y - 2)

	var/icon/overlay = icon('icons/misc/mapEmpty.dmi', "overlay")
	map.Blend(overlay, ICON_OVERLAY, 1, 1)

	return map

/obj/stationMapObj
	name = "Map (Click somewhere in space to close)"
	desc = "A map of the station. Click somewhere in space on the map to close it."

	anchored = 1
	density = 0
	opacity = 0
	layer = HUD_LAYER
	screen_loc = "CENTER-3, CENTER-3"

	MouseUp(var/location,var/control,var/params)
		var/list/paramList = params2list(params)
		if (paramList.Find("left"))
			var/turf/clicked = locate(text2num(paramList["icon-x"]),text2num(paramList["icon-y"]),1)

			if (clicked.loc.name in stationMap_bannedAreas)
				qdel(src)
				return

			boutput(usr, "<span class='notice'>That is <B>[clicked.loc.name]</B>.</span>")
/*			boutput(usr, "<span class='success'><I>[clicked.loc.desc]</I></span>") // none of these fucking things have descriptions anyway
			boutput(usr, " ") // no fuck you too
*/
/obj/stationMapWall
	name = "Station Map"
	desc = "A map of the station."

	layer = EFFECTS_LAYER_BASE
	anchored = 1

	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "stationmap"

	Click()
		if (..(usr))
			return

		if (locate(/obj/stationMapObj) in usr) return

		var/icon/mapIcon = generateStationMap(usr)
		var/obj/stationMapObj/S = new/obj/stationMapObj(usr)

		S.icon = mapIcon
		S.icon_state = "template"

		usr.client.screen += S
		return
