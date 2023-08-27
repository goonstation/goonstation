/obj/abcuMarker
	desc = "Denotes a valid tile."
	icon = 'icons/obj/objects.dmi'
	name = "Building marker (valid)"
	icon_state = "bmarker"
	anchored = ANCHORED
	density = 0
	layer = TURF_LAYER

/obj/abcuMarker/red
	desc = "Denotes an invalid tile."
	icon = 'icons/obj/objects.dmi'
	name = "Building marker (invalid)"
	icon_state = "bmarkerred"
	anchored = ANCHORED
	density = 0
	layer = TURF_LAYER

/obj/machinery/abcu
	icon = 'icons/obj/objects.dmi'
	icon_state = "builder"
	name = "Automated Blueprint Construction Unit (ABC-U)"
	desc = "This fine piece of machinery can construct entire rooms from blueprints."
	density = 1
	opacity = 0
	anchored = UNANCHORED

	var/invalidCount = 0

	var/obj/item/blueprint/currentBp = null
	var/locked = 0
	var/building = 0

	var/off_x = 0
	var/off_y = 0

	var/list/markers = new/list()

	New()
		..()
		UnsubscribeProcess()

	attack_ai(mob/user)
		boutput(user, "<span class='alert'>This machine is not linked to your network.</span>")
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/blueprint))
			if(currentBp)
				boutput(user, "<span class='alert'>Theres already a blueprint in the machine.</span>")
				return
			else
				boutput(user, "<span class='notice'>You insert the blueprint into the machine.</span>")
				user.drop_item()
				W.set_loc(src)
				currentBp = W
				return
		else if (istype(W, /obj/item/sheet))
			boutput(user, "<span class='notice'>You insert the sheet into the machine.</span>")
			user.drop_item()
			W.set_loc(src)
			return
		return

	attack_hand(mob/user)
		if(building)
			boutput(user, "<span class='alert'>The machine is currently constructing something. Best not touch it until it's done.</span>")
			return

		var/list/options = list(locked ? "Unlock":"Lock", "Begin Building", "Dump Materials", "Check Materials" ,currentBp ? "Eject Blueprint":null)
		var/input = input(user,"Select option:","Option") in options
		switch(input)
			if("Unlock")
				if(!locked || building) return
				boutput(user, "<span class='notice'>The machine unlocks and shuts down.</span>")
				deactivate()

			if("Lock")
				if(locked || building) return
				if(!currentBp)
					boutput(user, "<span class='alert'>The machine requires a blueprint before it can be locked</span>")
					return
				boutput(user, "<span class='notice'>The machine locks into place and begins humming softly.</span>")
				activate()

			if("Begin Building")
				if(building) return
				if(!locked)
					boutput(user, "<span class='alert'>The machine must be locked into place before activating it.</span>")
					return
				if(!currentBp)
					boutput(user, "<span class='alert'>The machine requires a blueprint before it can build anything.</span>")
					return
				build()

			if("Eject Blueprint")
				if(building) return
				if(locked)
					boutput(user, "<span class='alert'>Can not eject blueprint while machine is locked.</span>")
					return
				currentBp.set_loc(src.loc)
				currentBp = null

			if("Dump Materials")
				if(building) return
				for(var/obj/o in src)
					if(o == currentBp) continue
					o.set_loc(src.loc)

			if("Check Materials")
				if(building) return
				var/metal_cnt = 0
				var/glass_cnt = 0

				for(var/obj/O in src)
					if(O == currentBp) continue
					if(istype(O, /obj/item/sheet))
						var/obj/item/sheet/S = O
						if (S.material)
							if (S.material.getMaterialFlags() & MATERIAL_METAL)
								metal_cnt += S.amount
							if (S.material.getMaterialFlags() & MATERIAL_CRYSTAL)
								glass_cnt += S.amount

				boutput(user, "<span class='notice'>Currently loaded :</span>")
				boutput(user, "<span class='notice'>[metal_cnt] of [currentBp ? currentBp.req_metal : "-"] required metal</span>")
				boutput(user, "<span class='notice'>[glass_cnt] of [currentBp ? currentBp.req_glass : "-"] required glass</span>")
		return

	proc/deactivate()
		for(var/obj/O in markers)
			qdel(O)
		locked = 0
		anchored = UNANCHORED
		return

	proc/activate()
		locked = 1
		anchored = ANCHORED
		invalidCount = 0
		for(var/datum/tileinfo/T in currentBp.roominfo)
			var/turf/pos = locate(text2num(T.posx) + src.x,text2num(T.posy) + src.y, src.z)
			var/obj/abcuMarker/O = null

			if(istype(pos, /turf/space))
				O = new/obj/abcuMarker(pos)
			else
				O = new/obj/abcuMarker/red(pos)
				invalidCount++

			markers.Add(O)
		boutput(usr, "<span class='notice'>Building this will require [currentBp.req_metal] metal and [currentBp.req_glass] glass sheets.</span>")
		return

	proc/build()
		var/metal_cnt = 0
		var/glass_cnt = 0

		if(invalidCount)
			boutput(usr, "<span class='alert'>The machine can not build on anything but empty space. Check for red markers.</span>")
			return

		for(var/obj/O in src)
			if(O == currentBp) continue
			if(istype(O, /obj/item/sheet))
				var/obj/item/sheet/S = O
				if (S.material)
					if (S.material.getMaterialFlags() & MATERIAL_METAL)
						metal_cnt += S.amount
					if (S.material.getMaterialFlags() & MATERIAL_CRYSTAL)
						glass_cnt += S.amount

		if(metal_cnt < currentBp.req_metal || glass_cnt < currentBp.req_glass)
			boutput(usr, "<span class='alert'>The machine buzzes in protest. Seems like it doesn't have enough material to work with.</span>")
			return

		boutput(usr, "<span class='notice'>The machine starts to buzz and vibrate.</span>")

		building = 1
		icon_state = "builder1"

		SPAWN(0)

			for(var/datum/tileinfo/T in currentBp.roominfo)
				var/turf/pos = locate(text2num(T.posx) + src.x,text2num(T.posy) + src.y, src.z)

				var/obj/overlay/V = new/obj/overlay(pos)
				V.icon = 'icons/obj/objects.dmi'
				V.icon_state = "buildeffect"
				V.name = "energy"
				V.anchored = ANCHORED
				V.set_density(0)
				V.layer = EFFECTS_LAYER_BASE

				sleep(1.5 SECONDS)

				qdel(V)

				for(var/obj/O in markers)
					if(O.loc == pos)
						qdel(O)
						break
				if(T.tiletype != null)
					var/turf/newTile = get_turf(pos)
					newTile.ReplaceWith(T.tiletype)
					newTile.icon_state = T.state
					newTile.set_dir(T.direction)
					newTile.inherit_area()

				for(var/datum/objectinfo/O in T.objects)
					if(O.objecttype == null) continue
					var/atom/A = new O.objecttype(pos)
					A.set_dir(O.direction)
					A.layer = O.layer
					A.pixel_x = O.px
					A.pixel_y = O.py


			for(var/obj/J in src)
				qdel(J)

			building = 0
			icon_state = "builder"
			makepowernets()
			qdel(src) //Blah

		return

/datum/objectinfo
	var/objecttype = null
	var/direction = 0
	var/layer = 0
	var/px = 0
	var/py = 0

/datum/tileinfo
	var/list/objects = new/list()
	var/state = ""
	var/direction = 0
	var/tiletype = null
	var/posx = 0
	var/posy = 0

/verb/adminCreateBlueprint()
	set name = "Create Blueprint"
	set desc = "Allows creation of blueprints of any user."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)

	var/list/bps = new/list()
	var/savefile/save = new/savefile("data/blueprints.dat")
	save.cd = "/"

	for(var/currckey in save.dir)
		save.cd = "/[currckey]"
		for(var/currroom in save.dir)
			save.cd = "/[currckey]/[currroom]"
			bps.Add("[currckey]/[currroom]")

	save.cd = "/"

	if(!length(bps))
		boutput(usr, "<span class='alert'>No blueprints found.</span>")
		return
	var/input = tgui_input_list(usr, "Select a blueprint to create.", "Blueprints", bps)
	if(!input) return
	var/list/split = splittext(input, "/")
	var/key = input
	if(save.dir.Find("[split[1]]"))
		save.cd = "/[split[1]]"
		if(save.dir.Find("[split[2]]"))
			var/obj/item/blueprint/bp = new/obj/item/blueprint(get_turf(usr))

			save.cd = "/[key]"
			boutput(usr, "<span class='notice'>Printed Blueprint for '[save["roomname"]]'</span>")
			var/roomname = save["roomname"]
			bp.size_x = save["sizex"]
			bp.size_y = save["sizey"]

			for (var/A in save.dir)
				if(A == "sizex" || A == "sizey" || A == "roomname") continue
				save.cd = "/[key]/[A]"
				var/list/coords = splittext(A, ",")
				var/datum/tileinfo/tf = new/datum/tileinfo()
				tf.posx = coords[1]
				tf.posy = coords[2]
				tf.tiletype = save["type"]
				tf.state = save["state"]
				tf.direction = save["dir"]
				for (var/B in save.dir)
					if(B == "type" || B == "state") continue
					save.cd = "/[key]/[A]/[B]"
					var/datum/objectinfo/O = new/datum/objectinfo()
					O.objecttype = save["type"]
					O.direction = save["dir"]
					O.layer = save["layer"]
					O.px = save["pixelx"]
					O.py = save["pixely"]
					tf.objects.Add(O)
				bp.roominfo.Add(tf)
				bp.name = "Blueprint '[roomname]'"

/verb/adminDeleteBlueprint()
	set name = "Delete Blueprint"
	set desc = "Allows deletion of blueprints of any user."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)

	var/list/bps = new/list()
	var/savefile/save = new/savefile("data/blueprints.dat")
	save.cd = "/"

	for(var/currckey in save.dir)
		save.cd = "/[currckey]"
		for(var/currroom in save.dir)
			save.cd = "/[currckey]/[currroom]"
			bps.Add("[currckey]/[currroom]")

	save.cd = "/"

	if(!length(bps))
		boutput(usr, "<span class='alert'>No blueprints found.</span>")
		return
	var/input = tgui_input_list(usr, "Select a blueprint to create.", "Blueprints", bps)
	if(!input) return
	var/list/split = splittext(input, "/")
	if(save.dir.Find("[split[1]]"))
		save.cd = "/[split[1]]"
		if(save.dir.Find("[split[2]]"))
			save.dir.Remove("[split[2]]")
			boutput(usr, "<span class='alert'>Blueprint [split[2]] deleted..</span>")

/obj/item/blueprint
	name = "Blueprint"
	desc = "A blueprint used to quickly construct rooms."
	icon = 'icons/obj/writing.dmi'

	icon_state = "blueprint"
	item_state = "sheet"

	var/req_metal = 0
	var/req_glass = 0

	var/size_x = 0
	var/size_y = 0

	var/list/roominfo = new/list()
/*
	attack_self(mob/user as mob)
		for(var/datum/tileinfo/T in roominfo)
			var/turf/pos = locate(text2num(T.posx) + user.x,text2num(T.posy) + user.y, user.z) //Change
			//boutput(world, "[pos.x]-[pos.y]-[pos.z] # [pos]")
			for(var/datum/objectinfo/O in T.objects)
				//boutput(world, newObjType + " - " + O.objecttype)
				if(O.objecttype == null) continue
				var/atom/A = new O.objecttype(pos)
				A.set_dir(O.direction)
				A.layer = O.layer
				A.pixel_x = O.px
				A.pixel_y = O.py

			//boutput(world, newTilePath + " - " + T.tiletype)
			if(T.tiletype != null)
				var/turf/newTile = new T.tiletype(pos)
				newTile.icon_state = T.state

			//rebuild powernets etc.
*/

#define SELECT_SKIP 0
#define SELECT_FIRST_CORNER 1
#define DESELECT_FIRST_CORNER 2
#define SELECT_SECOND_CORNER 3
#define DESELECT_SECOND_CORNER 4

/obj/item/blueprint_marker
	name = "Blueprint Marker"
	desc = "A tool used to map rooms for the creation of blueprints."
	icon = 'icons/obj/items/device.dmi'

	icon_state = "blueprintmarker"
	item_state = "gun"

	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL

	var/prints_left = 5

	var/mob/using = null
	var/selecting = 0
	var/turf/selectcorner1
	var/image/corner1img

	var/roomname = "NewRoom"
	var/list/turf/roomList = new/list()

	var/list/permittedObjectTypes = list(\
	"/obj/stool", \
	"/obj/grille", \
	"/obj/window", \
	"/obj/machinery/door", \
	"/obj/cable", \
	"/obj/table", \
	"/obj/rack", \
	"/obj/structure",
	"/obj/disposalpipe", \
//	"/obj/machinery/vending", \ //No cheap buckshot/oddcigs/chemdepots. Use a mechscanner
	"/obj/machinery/light", \
	"/obj/machinery/door_control", \
	"/obj/machinery/light_switch", \
	"/obj/machinery/camera", \
	"/obj/item/device/radio/intercom", \
	"/obj/machinery/firealarm", \
	"/obj/machinery/power/apc", \
	"/obj/machinery/alarm", \
	"/obj/machinery/power/terminal", \
	"/obj/machinery/disposal", \
	"/obj/machinery/gibber",
	"/obj/machinery/floorflusher",
	"/obj/machinery/activation_button/driver_button", \
	"/obj/machinery/door_control",
	"/obj/machinery/disposal",
	"/obj/submachine/chef_oven",
	"/obj/submachine/chef_sink",
	"/obj/machinery/launcher_loader",
	"/obj/machinery/optable",
	"/obj/machinery/mass_driver", \
//	"/obj/reagent_dispensers", \ //No free helium/fuel/omni/raj/etc from abcu
	"/obj/machinery/sleeper", \
	"/obj/machinery/sleep_console", \
	"/obj/submachine/slot_machine", \
	"/obj/machinery/deep_fryer",
	"/obj/submachine/ATM", \
	"/obj/submachine/ice_cream_dispenser",
	"/obj/machinery/portable_atmospherics", \
	"/obj/machinery/ai_status_display",
	"/obj/securearea",
	"/obj/submachine/mixer",
	"/obj/submachine/foodprocessor"
	)

	var/list/blacklistedObjectTypes = list(\
	"/obj/disposalpipe/loafer",
	"/obj/submachine/slot_machine/item",
	"/obj/machinery/portable_atmospherics/canister")
	var/list/permittedTileTypes = list("/turf/simulated")

	var/static/savefile/save = new/savefile("data/blueprints.dat")

	pixelaction(atom/target, params, mob/user)
		if(GET_DIST(src,target) > 10) return

		if(!isturf(target)) target = get_turf(target)

		var/minx = 100000000
		var/miny = 100000000

		var/maxx = 0
		var/maxy = 0

		var/maxSize = 20

		var/permitted = 0
		for(var/p in permittedTileTypes)
			var/type = text2path(p)
			if(istype(target, type))
				permitted = 1
				break

		if(!permitted)
			boutput(user, "<span class='alert'>Unsupported Tile type detected.</span>")
			return

		for(var/turf/t as anything in roomList) // is this better than storing min/max permanently?
			if(t.x < minx) minx = t.x
			if(t.y < miny) miny = t.y

			if(t.x > maxx) maxx = t.x
			if(t.y > maxy) maxy = t.y

		//Do stuff

		if(target.x < minx) minx = target.x
		if(target.y < miny) miny = target.y

		if(target.x > maxx) maxx = target.x
		if(target.y > maxy) maxy = target.y

		if(abs(minx - maxx) >= maxSize || abs(miny - maxy) >= maxSize)
			boutput(user, "<span class='alert'>Tile exceeds maximum size of blueprint.</span>")
			playsound(src.loc, 'sound/machines/button.ogg', 25)
			return

		switch (selecting)
			if (SELECT_SKIP)

			if (SELECT_FIRST_CORNER, DESELECT_FIRST_CORNER) // set to 1 or 2 by use-in-hand option list
				qdel(corner1img)
				selectcorner1 = target
				selecting += 2 // if 3 then select second corner, if 4 then deselect second corner
				corner1img = image('icons/misc/old_or_unused.dmi', selectcorner1, "marker", layer = HUD_LAYER)
				user << corner1img
				playsound(src.loc, 'sound/machines/tone_beep.ogg', 15)
				return

			if (SELECT_SECOND_CORNER, DESELECT_SECOND_CORNER)
				var/diffx = abs(target.x - selectcorner1.x)
				var/diffy = abs(target.y - selectcorner1.y)
				if(diffx >= maxSize || diffy >= maxSize)
					boutput(user, "<span class='alert'>Tile exceeds maximum size of blueprint.</span>")
					playsound(src.loc, 'sound/machines/button.ogg', 25)
					return

				var/selectedz = selectcorner1.z
				var/currx = min(target.x, selectcorner1.x)
				var/curry = min(target.y, selectcorner1.y)
				var/startx = currx
				var/endx = currx + diffx

				var/ix
				for (ix=0, ix < (diffx + 1) * (diffy + 1), ix++) // add 1 to diffs or a whole row/column of tiles are left out by math
					var/turf/t = locate(currx, curry, selectedz)

					currx++
					if (currx > endx)
						currx = startx
						curry++

					var/perm = 0
					for(var/p in permittedTileTypes)
						var/ttype = text2path(p)
						if(istype(t, ttype))
							perm = 1
							break
					if(!perm) continue

					if (selecting == SELECT_SECOND_CORNER)
						if (!roomList.Find(t))
							roomList.Add(t)
							roomList[t] = image('icons/misc/old_or_unused.dmi', t, "tiletag", layer = HUD_LAYER)
					else
						if (using?.client)
							using.client.images -= roomList[t]
						roomList.Remove(t)


				selecting = SELECT_SKIP
				qdel(corner1img)
				playsound(src.loc, 'sound/machines/tone_beep.ogg', 15)
				updateOverlays()
				return

			else selecting = SELECT_SKIP

		if(roomList.Find(target))
			if (using?.client)
				using.client.images -= roomList[target]
			roomList.Remove(target)
			playsound(src.loc, 'sound/machines/button.ogg', 25, 0.1)
		else
			roomList.Add(target)
			roomList[target] = image('icons/misc/old_or_unused.dmi',target,"tiletag", layer = HUD_LAYER)
			updateOverlays()
			playsound(src.loc, 'sound/machines/tone_beep.ogg', 15, 0.1)

		return

	New()
		..()

	proc/removeOverlays()
		if (using?.client)
			for(var/a in roomList)
				var/image/i = roomList[a]
				using.client.images -= i
		return

	proc/updateOverlays()
		if (using?.client)
			removeOverlays()
			for(var/a in roomList)
				var/image/i = roomList[a]
				using.client.images += i
		return

	proc/saveMarked(var/name = "", var/applyWhitelist = 1)
		save.cd = "/"
		if(!save.dir.Find("[usr.client.ckey]"))
			save.dir.Add("[usr.client.ckey]")
		save.cd = "/[usr.client.ckey]"

		if(save.dir.Find(name))
			if (alert(usr, "A blueprint of this name already exists. Really overwrite?", "Overwrite Blueprint", "Yes", "No") == "No")
				return
			save.dir.Remove(name)
			save.dir.Add(name)
			save.cd = "/[usr.client.ckey]/" + name
		else
			save.dir.Add(name)
			save.cd = "/[usr.client.ckey]/" + name

		var/minx = 100000000
		var/miny = 100000000

		var/maxx = 0
		var/maxy = 0

		for(var/turf/t as anything in roomList)
			if(t.x < minx) minx = t.x
			if(t.y < miny) miny = t.y

			if(t.x > maxx) maxx = t.x
			if(t.y > maxy) maxy = t.y

		var/sizex = (maxx - minx) + 1
		var/sizey = (maxy - miny) + 1

		save["sizex"] << sizex
		save["sizey"] << sizey
		save["roomname"] << roomname

		for(var/atom/curr in roomList)
			var/posx = (curr.x - minx)
			var/posy = (curr.y - miny)

			save.cd = "/[usr.client.ckey]/" + name
			save.dir.Add("[posx],[posy]")
			save.cd = "/[usr.client.ckey]/[name]/[posx],[posy]"
			save["type"] << curr.type
			save["dir"] << curr.dir
			save["state"] << curr.icon_state

			for(var/obj/o in curr)
				var/permitted = 0
				for(var/p in permittedObjectTypes)
					var/type = text2path(p)
					if(istype(o, type))
						permitted = 1
						break

				for(var/p in blacklistedObjectTypes)
					var/type = text2path(p)
					if(istype(o, type))
						permitted = 0
						break//no

				if(permitted || !applyWhitelist)
					var/id = "\ref[o]"
					save.cd = "/[usr.client.ckey]/[name]/[posx],[posy]"
					while(save.dir.Find(id))
						id = id + "I"
					save.dir.Add("[id]")
					save.cd = "/[usr.client.ckey]/[name]/[posx],[posy]/[id]"
					save["dir"] << o.dir
					save["type"] << o.type
					save["layer"] << o.layer
					save["pixelx"] << o.pixel_x
					save["pixely"] << o.pixel_y

		boutput(usr, "<span class='notice'>Saved blueprint as '[name]'. </span>")
		return

	proc/printSaved(var/name = "")
		save.cd = "/"
		if(save.dir.Find("[usr.client.ckey]"))
			save.cd = "/[usr.client.ckey]/"
			if(save.dir.Find(name))
				var/obj/item/blueprint/bp = new/obj/item/blueprint(get_turf(src))
				prints_left--

				save.cd = "/[usr.client.ckey]/" + name
				boutput(usr, "<span class='notice'>Printed Blueprint for '[save["roomname"]]'</span>")
				var/roomname = save["roomname"]
				bp.size_x = save["sizex"]
				bp.size_y = save["sizey"]

				for (var/A in save.dir)
					if(A == "sizex" || A == "sizey" || A == "roomname") continue
					save.cd = "/[usr.client.ckey]/[name]/[A]"
					var/list/coords = splittext(A, ",")
					var/datum/tileinfo/tf = new/datum/tileinfo()
					tf.posx = coords[1]
					tf.posy = coords[2]
					tf.tiletype = save["type"]
					tf.state = save["state"]
					tf.direction = save["dir"]
					bp.req_metal += 1
					bp.req_glass += 0.5
					for (var/B in save.dir)
						if(B == "type" || B == "state") continue
						save.cd = "/[usr.client.ckey]/[name]/[A]/[B]"
						var/datum/objectinfo/O = new/datum/objectinfo()
						O.objecttype = save["type"]
						O.direction = save["dir"]
						O.layer = save["layer"]
						O.px = save["pixelx"]
						O.py = save["pixely"]
						bp.req_metal += 0.9
						bp.req_glass += 1.5
						tf.objects.Add(O)
					bp.roominfo.Add(tf)
					bp.name = "Blueprint '[roomname]'"
					bp.req_metal = round(bp.req_metal)
					bp.req_glass = round(bp.req_glass)
				return
			else
				boutput(usr, "<span class='alert'>Blueprint [name] not found.</span>")

		else
			boutput(usr, "<span class='alert'>No blueprints found for user.</span>")
			return
	proc/delSaved(var/name = "")
		save.cd = "/"
		if(save.dir.Find("[usr.client.ckey]"))
			save.cd = "/[usr.client.ckey]/"
			if(save.dir.Find(name))
				if (strip_html(input(usr,"Really delete this blueprint? Input blueprint name to confirm.","Blueprint Deletion","") as text) != name)
					boutput(usr, "<span class='alert'>Failed to delete blueprint '[name]': input did not match blueprint name.</span>")
					return
				save.dir.Remove(name)
				boutput(usr, "<span class='alert'>Blueprint [name] deleted..</span>")
			else
				boutput(usr, "<span class='alert'>Blueprint [name] not found.</span>")
		else
			boutput(usr, "<span class='alert'>No blueprints found for user.</span>")


	attack_self(mob/user as mob)
		if(!user.client)
			return

		if (selecting)
			selecting = SELECT_SKIP
			qdel(corner1img)
			boutput(user, "<span class='notice'>Cancelled rectangle select.</span>")
			playsound(src.loc, 'sound/machines/button.ogg', 25)
			return

		var/list/options = list("Select Rectangle", "Deselect Rectangle", "Reset", "Set Blueprint Name", "Print Saved Blueprint",
			"Save Blueprint", "Delete Blueprint" , "Information",)
		var/input = input(user,"Select option:","Option") in options

		switch(input)
			if("Select Rectangle")
				selecting = SELECT_FIRST_CORNER

			if("Deselect Rectangle")
				selecting = DESELECT_FIRST_CORNER

			if("Reset")
				boutput(user, "<span class='notice'>Resetting ...</span>")
				removeOverlays()
				roomList.Cut()

			if("Set Blueprint Name")
				roomname = copytext(strip_html(input(user,"Set Blueprint Name:","Setup",roomname) as text), 1, 257)
				boutput(user, "<span class='notice'>Name set to '[roomname]'</span>")

			//if("Create Clone Blueprint")
			//	saveMarked("_temp", 1)
			//	printSaved("_temp")
			//	return

			if("Print Saved Blueprint")
				if(prints_left <= 0)
					boutput(user, "<span class='alert'>Out of energy.</span>")
					return
				printSaved(roomname)
				return

			if("Save Blueprint")
				saveMarked(roomname)
				return

			if("Delete Blueprint")
				delSaved(roomname)
				return

			if("Information")
				var/message = "<span class='notice'>This tool is used for making, saving and loading room blueprints on the server.</span><br>"
				message += "<span class='notice'>Saved blueprints persist between rounds, but are limited to a size of 20 tiles on each axis, making 20x20 the largest blueprint.</span><br><br>"
				message += "<span class='notice'>(De)Select Rectangle: Mass-selects or deselects tiles in a filled rectangle shape, defined by 2 corners.</span><br>"
				message += "<span class='notice'>Reset: Resets the tools and clears all marked areas.</span><br>"
				message += "<span class='notice'>Set Blueprint Name: Sets the active blueprint that print/save/delete functions will access.</span><br>"
				message += "<span class='notice'>Print Saved Blueprint: Prints the active blueprint for usage in the ABCU builder device.</span><br>"
				message += "<span class='notice'>Save Blueprint: Saves a blueprint of the marked area to the server. Most structures will be saved, but it can not save all types of objects.</span><br>"
				message += "<span class='notice'>Your saved blueprints are accessed solely by its Blueprint Name, so note it down.</span><br>"
				message += "<span class='notice'>Delete Blueprint: Permanently deletes the active blueprint from the server.</span><br>"
				boutput(user, message)
				return

		return

	dropped(mob/user as mob)
		removeOverlays()
		selecting = 0
		qdel(corner1img)
		using = null
		return

	pickup(mob/user)
		using = user
		updateOverlays()
		return

	equipped(var/mob/user, var/slot)
		..()
		using = user
		updateOverlays()
		return

#undef SELECT_SKIP
#undef SELECT_FIRST_CORNER
#undef DESELECT_FIRST_CORNER
#undef SELECT_SECOND_CORNER
#undef DESELECT_SECOND_CORNER
