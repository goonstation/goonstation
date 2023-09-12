// balance defines
#define REBUILD_COST_OBJECT_METAL 0.9 // each of these measured in sheets.
#define REBUILD_COST_OBJECT_CRYSTAL 1.5
#define REBUILD_COST_TURF_METAL 1
#define REBUILD_COST_TURF_CRYSTAL 0.5
#define BAR_SHEET_VALUE 10
// code defines
#define SELECT_SKIP 0
#define SELECT_FIRST_CORNER 1
#define DESELECT_FIRST_CORNER 2
#define SELECT_SECOND_CORNER 3
#define DESELECT_SECOND_CORNER 4

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
	name = "\improper ABC Unit"
	desc = "An Automated Blueprint Construction Unit. \
		This fine piece of machinery can construct entire rooms from blueprints."
	density = 1
	opacity = 0
	anchored = UNANCHORED
	processing_tier = PROCESSING_FULL

	var/invalidCount = 0
	var/building = FALSE
	var/BuildIndex = 1
	var/BuildEnd = 0
	var/list/markers = list()
	var/list/apclist = list()
	var/MetalOwed = 0
	var/CrystalOwed = 0
	var/TileCostProcessed = FALSE

	var/obj/item/blueprint/currentBp = null
	var/locked = FALSE
	var/Paused = FALSE
	var/off_x = 0
	var/off_y = 0



	New()
		..()
		UnsubscribeProcess()

	attack_ai(mob/user)
		boutput(user, "<span class='alert'>This machine is not linked to your network.</span>")
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/blueprint))
			if(src.currentBp)
				boutput(user, "<span class='alert'>Theres already a blueprint in the machine.</span>")
				return
			else
				boutput(user, "<span class='notice'>You insert the blueprint into the machine.</span>")
				user.drop_item()
				W.set_loc(src)
				src.currentBp = W
				return
		else if (istype(W, /obj/item/sheet) || istype(W, /obj/item/material_piece))
			boutput(user, "<span class='notice'>You insert the material into the machine.</span>")
			user.drop_item()
			W.set_loc(src)
			return
		return

	attack_hand(mob/user)
		if(src.building && !src.Paused)
			if (tgui_alert(user, "Pause the construction?", "ABCU", list("Yes", "No")) == "Yes")
				src.pauseBuild()
				return
			return

		var/list/OptionList = list(
			"Check Materials",
			"Resume Construction",
			src.locked ? "Unlock" : "Lock",
			"Begin Building",
			"Dump Materials",
			"Eject Blueprint",
			"Cancel Build",
		)
		var/UserInput = tgui_input_list(user, src.building ? "The build job is currently paused. Choose:" : "Select an action.", "ABCU", OptionList)
		if (!UserInput) return

		switch(UserInput)
			if("Unlock")
				if (src.building)
					boutput(user, "<span class='alert'>Lock status can't be changed with a build in progress.</span>")
					return
				if(!src.locked) return
				src.deactivate()

			if("Lock")
				if (src.building)
					boutput(user, "<span class='alert'>Lock status can't be changed with a build in progress.</span>")
					return
				if(src.locked) return
				if(!src.currentBp)
					boutput(user, "<span class='alert'>The machine requires a blueprint before it can be locked.</span>")
					return
				src.activate(user)

			if("Begin Building")
				if(src.building)
					boutput(user, "<span class='alert'>A build job is already in progress.</span>")
					return
				if(!src.locked)
					boutput(user, "<span class='alert'>The machine must be locked into place before activating it.</span>")
					return
				if(!src.currentBp)
					boutput(user, "<span class='alert'>The machine requires a blueprint before it can build anything.</span>")
					return
				src.prepareBuild(user)

			if("Eject Blueprint")
				if(src.locked || src.building)
					boutput(user, "<span class='alert'>Can not eject blueprint while machine is locked or building.</span>")
					return
				if (!src.currentBp)
					boutput(user, "<span class='alert'>No blueprint to eject.</span>")
					return
				src.currentBp.set_loc(src.loc)
				src.currentBp = null

			if("Dump Materials")
				for(var/obj/o in src)
					if(o == src.currentBp) continue
					o.set_loc(src.loc)

			if("Check Materials")
				src.auditInventory(user)

			if ("Resume Construction")
				if (!src.building)
					boutput(user, "<span class='alert'>There's no build in progress.</span>")
					return
				if (!src.Paused)
					boutput(user, "<span class='alert'>[src] is already unpaused.</span>")
					return
				src.unpauseBuild()

			if ("Cancel Build")
				if (!src.building)
					boutput(user, "<span class='alert'>There's no build in progress.</span>")
					return
				src.endBuild()
		return

	process()
		..()
		if (!src.building) return
		if (src.BuildIndex > src.BuildEnd)
			src.endBuild()
			return

		var/datum/tileinfo/Tile = src.currentBp.roominfo[src.BuildIndex]
		if (isnull(Tile.tiletype))
			src.BuildIndex++
			return

		// try to consume materials for this tile
		if (!src.TileCostProcessed)
			var/ObjCount = length(Tile.objects)
			src.MetalOwed += REBUILD_COST_TURF_METAL + REBUILD_COST_OBJECT_METAL * ObjCount
			src.CrystalOwed += REBUILD_COST_TURF_CRYSTAL + REBUILD_COST_OBJECT_CRYSTAL * ObjCount
			src.TileCostProcessed = TRUE
		for (var/obj/Item in src)
			if (src.MetalOwed <= 0 && src.CrystalOwed <= 0) break
			if (Item == src.currentBp) continue

			if (istype(Item, /obj/item/sheet))
				var/obj/item/sheet/Sheets = Item
				if (!Sheets.material) continue
				if (src.MetalOwed && Sheets.material.getMaterialFlags() & MATERIAL_METAL)
					var/SheetsConsumed = ceil(min(Sheets.amount, src.MetalOwed))
					Sheets.change_stack_amount(-SheetsConsumed)
					src.MetalOwed -= SheetsConsumed
					continue
				if (src.CrystalOwed && Sheets.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					var/SheetsConsumed = ceil(min(Sheets.amount, src.CrystalOwed))
					Sheets.change_stack_amount(-SheetsConsumed)
					src.CrystalOwed -= SheetsConsumed
					continue

			else if (istype(Item, /obj/item/material_piece))
				var/obj/item/material_piece/Bars = Item
				if (!Bars.material) continue
				if (src.MetalOwed && Bars.material.getMaterialFlags() & MATERIAL_METAL)
					var/BarsConsumed = ceil(min(Bars.amount, src.MetalOwed / BAR_SHEET_VALUE))
					Bars.change_stack_amount(-BarsConsumed)
					src.MetalOwed -= BarsConsumed * BAR_SHEET_VALUE
					continue
				if (src.CrystalOwed && Bars.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					var/BarsConsumed = ceil(min(Bars.amount, src.CrystalOwed / BAR_SHEET_VALUE))
					Bars.change_stack_amount(-BarsConsumed)
					src.CrystalOwed -= BarsConsumed * BAR_SHEET_VALUE
					continue

		if (src.MetalOwed > 0 || src.CrystalOwed > 0)
			src.pauseBuild()
			src.visible_message("<span class='alert'>[src] does not have enough materials to continue construction.</span>")
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 20)
			return
		// now build the tile if we paid for it
		var/turf/Pos = locate(text2num(Tile.posx) + src.x,text2num(Tile.posy) + src.y, src.z)
		for(var/obj/O in src.markers)
			if(O.loc == Pos)
				qdel(O)
				break

		src.makeTile(Tile, Pos)
		src.TileCostProcessed = FALSE
		src.BuildIndex++

	proc/makeTile(var/datum/tileinfo/Info, var/turf/Pos)
		set waitfor = 0
		SPAWN(0)
			var/obj/overlay/V = new/obj/overlay(Pos)
			V.icon = 'icons/obj/objects.dmi'
			V.icon_state = "buildeffect"
			V.name = "energy"
			V.anchored = ANCHORED
			V.set_density(0)
			V.layer = EFFECTS_LAYER_BASE

			sleep(1.5 SECONDS)

			qdel(V)

			if(Info.tiletype != null)
				var/turf/newTile = Pos
				newTile.ReplaceWith(Info.tiletype)
				newTile.icon_state = Info.state
				newTile.set_dir(Info.direction)
				newTile.inherit_area()

			for(var/datum/objectinfo/O in Info.objects)
				if (O.objecttype == null) continue
				if (ispath(O.objecttype, /obj/machinery/power/apc))
					src.apclist[O] = Pos
					continue
				new/dmm_suite/preloader(Pos, list( // this doesn't spawn the objects, only presets their properties
					"layer" = O.layer,
					"pixel_x" = O.px,
					"pixel_y" = O.py,
					"dir" = O.direction,
					"icon_state" = O.icon_state,
				))
				new O.objecttype(Pos) // need this part to also spawn the objects

	proc/prepareBuild(mob/user)
		if(src.invalidCount)
			boutput(usr, "<span class='alert'>The machine can not build on anything but empty space. Check for red markers.</span>")
			return

		src.BuildEnd = length(src.currentBp.roominfo)
		if (src.BuildEnd <= 0)
			return

		src.building = TRUE
		src.Paused = FALSE
		src.BuildIndex = 1
		src.icon_state = "builder1"
		SubscribeToProcess()
		src.visible_message("<span class='notice'>[src] starts to buzz and vibrate. The operation light blinks on.</span>")
		logTheThing(LOG_STATION, src, "[user] started ABCU build at [log_loc(src)], with blueprint [src.currentBp.name], authored by [src.currentBp.author]")

	proc/endBuild()
		for (var/datum/objectinfo/N in src.apclist)
			new N.objecttype(src.apclist[N])
		src.apclist = new/list

		src.building = FALSE
		UnsubscribeProcess()
		src.deactivate()

		src.icon_state = "builder"
		makepowernets()
		src.visible_message("<span class='notice'>[src] whirrs to a stop. The operation light flashes twice and turns off.</span>")

	proc/auditInventory(mob/user)
		var/MetalCount = 0
		var/CrystalCount = 0
		for(var/obj/O in src)
			if(O == src.currentBp) continue
			if (istype(O, /obj/item/sheet))
				var/obj/item/sheet/Sheets = O
				if (!Sheets.material) continue
				if (Sheets.material.getMaterialFlags() & MATERIAL_METAL)
					MetalCount += Sheets.amount
				if (Sheets.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					CrystalCount += Sheets.amount
			else if (istype(O, /obj/item/material_piece))
				var/obj/item/material_piece/Bars = O
				if (!Bars.material) continue
				if (Bars.material.getMaterialFlags() & MATERIAL_METAL)
					MetalCount += Bars.amount * BAR_SHEET_VALUE
				if (Bars.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					CrystalCount += Bars.amount * BAR_SHEET_VALUE
		if (user)
			var/Message = "<span class='notice'>The machine is holding [MetalCount] metal, and [CrystalCount] crystal, measured in sheets.</span>"
			if (src.currentBp)
				Message += "<br><span class='notice'>Its current blueprint requires [src.currentBp.req_metal] metal,"
				Message += " and [src.currentBp.req_glass] crystal, measured in sheets.</span>"
			boutput(user, Message)
		return list(MetalCount, CrystalCount)

	proc/unpauseBuild()
		src.Paused = FALSE
		src.icon_state = "builder1"
		SubscribeToProcess()
		src.visible_message("<span class='notice'>[src] starts to buzz and vibrate.</span>")

	proc/pauseBuild()
		src.Paused = TRUE
		src.icon_state = "builder"
		UnsubscribeProcess()
		src.visible_message("<span class='notice'>[src] releases a small puff of steam, then quiets down.</span>")

	proc/deactivate()
		for(var/obj/O in src.markers)
			qdel(O)
		src.locked = FALSE
		src.anchored = UNANCHORED
		src.visible_message("[src] disengages its anchors.")
		return

	proc/activate(mob/user)
		src.locked = TRUE
		src.anchored = ANCHORED
		src.invalidCount = 0
		for(var/datum/tileinfo/T in src.currentBp.roominfo)
			var/turf/pos = locate(text2num(T.posx) + src.x,text2num(T.posy) + src.y, src.z)
			var/obj/abcuMarker/O = null

			if(istype(pos, /turf/space))
				O = new/obj/abcuMarker(pos)
			else
				O = new/obj/abcuMarker/red(pos)
				src.invalidCount++

			src.markers.Add(O)
		boutput(user, "<span class='notice'>Building this will require [src.currentBp.req_metal] metal and [src.currentBp.req_glass] glass sheets.</span>")
		src.visible_message("[src] locks into place and begins humming softly.")
		return

/datum/objectinfo
	var/objecttype = null
	var/direction = 0
	var/layer = 0
	var/px = 0
	var/py = 0
	var/icon_state = ""

/datum/tileinfo
	var/list/objects = new/list()
	var/state = ""
	var/direction = 0
	var/tiletype = null
	var/posx = 0
	var/posy = 0
	var/icon = ""

/verb/adminCreateBlueprint()
	set name = "Blueprint Create"
	set desc = "Allows creation of blueprints of any user."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)

	var/list/userlist = flist("data/blueprints/")
	var/inputuser = tgui_input_list(usr, "Select a user by ckey.", "Users", userlist)
	if(!inputuser) return
	var/list/bplist = flist("data/blueprints/[inputuser]")
	var/inputbp = tgui_input_list(usr, "Pick a blueprint belonging to this user.", "Blueprints", bplist)
	if(!inputbp) return

	var/savefile/selectedbp = new/savefile("data/blueprints/[inputuser]/[inputbp]")
	var/obj/item/blueprint/bp = new/obj/item/blueprint(get_turf(usr))

	selectedbp.cd = "/"
	var/roomname = selectedbp["roomname"]
	bp.size_x = selectedbp["sizex"]
	bp.size_y = selectedbp["sizey"]
	bp.author = selectedbp["author"]

	selectedbp.cd = "/tiles" // cd to tiles
	for (var/A in selectedbp.dir) // and now loop on every listing in tiles
		selectedbp.cd = "/tiles/[A]"
		var/list/coords = splittext(A, ",")
		var/datum/tileinfo/tf = new/datum/tileinfo()
		tf.posx = coords[1]
		tf.posy = coords[2]
		tf.tiletype = selectedbp["type"]
		tf.state = selectedbp["state"]
		tf.direction = selectedbp["dir"]
		tf.icon = selectedbp["icon"]
		bp.req_metal += 1
		bp.req_glass += 0.5
		selectedbp.cd = "/tiles/[A]/objects"
		for (var/B in selectedbp.dir)
			selectedbp.cd = "/tiles/[A]/objects/[B]"
			var/datum/objectinfo/O = new/datum/objectinfo()
			O.objecttype = selectedbp["type"]
			O.direction = selectedbp["dir"]
			O.layer = selectedbp["layer"]
			O.px = selectedbp["pixelx"]
			O.py = selectedbp["pixely"]
			O.icon_state = selectedbp["icon_state"]
			bp.req_metal += 0.9
			bp.req_glass += 1.5
			tf.objects.Add(O)
		bp.roominfo.Add(tf)
	bp.name = "Blueprint '[roomname]'"
	bp.req_metal = round(bp.req_metal)
	bp.req_glass = round(bp.req_glass)

	boutput(usr, "<span class='notice'>Printed blueprint for '[roomname]'.</span>")
	return

/verb/adminDeleteBlueprint()
	set name = "Blueprint Delete"
	set desc = "Allows deletion of blueprints of any user."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)

	var/list/userlist = flist("data/blueprints/")
	var/inputuser = tgui_input_list(usr, "Select a user by ckey.", "Users", userlist)
	if(!inputuser) return
	var/list/bplist = flist("data/blueprints/[inputuser]")
	var/inputbp = tgui_input_list(usr, "Pick a blueprint belonging to this user.", "Blueprints", bplist)
	if(!inputbp) return
	fdel("data/blueprints/[inputuser]/[inputbp]")
	boutput(usr, "<span class='notice'>Deleted [inputuser]'s [inputbp].</span>")

/verb/adminDumpBlueprint()
	set name = "Blueprint Dump"
	set desc = "Dumps readable HTML blueprint, of any user, to your client folder."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

	var/list/userlist = flist("data/blueprints/")
	var/inputuser = tgui_input_list(usr, "Select a user by ckey.", "Users", userlist)
	if(!inputuser) return
	var/list/bplist = flist("data/blueprints/[inputuser]")
	var/inputbp = tgui_input_list(usr, "Pick a blueprint belonging to this user.", "Blueprints", bplist)
	if(!inputbp) return

	var/savefile/selectedbp = new/savefile("data/blueprints/[inputuser]/[inputbp]")
	selectedbp.ExportText("/","data/blueprints/[inputuser]/[inputbp].txt")
	usr.client.Export("data/blueprints/[inputuser]/[inputbp].txt")
	fdel("data/blueprints/[inputuser]/[inputbp].txt")

	boutput(usr, "<span class='notice'>Dumped blueprint to BYOND user data folder.</span>")

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

	var/author = ""

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

/obj/item/blueprint_marker
	name = "blueprint marker"
	desc = "A tool used to map rooms for the creation of blueprints. \
		Blueprints can be used in an ABC Unit to reconstruct a saved room."
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
//	"/obj/machinery/power/terminal", \ // APC spawns its own connected terminal
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

	//var/static/savefile/save = new/savefile("data/blueprints.dat")

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
		var/savepath = "data/blueprints/[usr.client.ckey]/[name].dat"
		if (fexists("[savepath]"))
			if (alert(usr, "A blueprint of this name already exists. Really overwrite?", "Overwrite Blueprint", "Yes", "No") == "No")
				return
			fdel("[savepath]")
		var/savefile/save = new/savefile("[savepath]")

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

		save.cd = "/"
		save["sizex"] << sizex
		save["sizey"] << sizey
		save["roomname"] << roomname
		save["author"] << usr.client.ckey
		save.dir.Add("tiles")

		for(var/atom/curr in roomList)
			var/posx = (curr.x - minx)
			var/posy = (curr.y - miny)

			//save.cd = "/tiles"
			//save.dir.Add("[posx],[posy]")
			save.cd = "/tiles/[posx],[posy]"
			save["type"] << curr.type
			save["dir"] << curr.dir
			save["state"] << curr.icon_state
			if (curr.icon != initial(curr.icon))
				save["icon"] << "[curr.icon]" // string this or it saves the entire .dmi file
			//save.dir.Add("objects")

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
					save.cd = "/tiles/[posx],[posy]/objects"
					while(save.dir.Find(id))
						id = id + "I"
					//save.dir.Add("[id]")
					save.cd = "[id]"
					save["dir"] << o.dir
					save["type"] << o.type
					save["layer"] << o.layer
					save["pixelx"] << o.pixel_x
					save["pixely"] << o.pixel_y
					save["icon_state"] << o.icon_state
					//save["icon"] << "[o.icon]"

		boutput(usr, "<span class='notice'>Saved blueprint as '[name]'. </span>")
		return

	proc/printSaved(var/name = "")
		var/savepath = "data/blueprints/[usr.client.ckey]/[name].dat"
		var/savefile/save = new/savefile("[savepath]") // if it's not an existing file, this makes an empty new one
		if (isnull(save["roomname"]) && isnull(save["sizex"])) // double check
			boutput(usr, "<span class='alert'>Blueprint [name] not found.</span>")
			fdel("[savepath]") // so we kill it
			return

		var/obj/item/blueprint/bp = new/obj/item/blueprint(get_turf(src))
		prints_left--

		save.cd = "/"
		var/roomname = save["roomname"]
		bp.size_x = save["sizex"]
		bp.size_y = save["sizey"]
		bp.author = save["author"]

		save.cd = "/tiles" // cd to tiles
		for (var/A in save.dir) // and now loop on every listing in tiles
			//if(A == "sizex" || A == "sizey" || A == "roomname") continue
			//save.cd = "/[usr.client.ckey]/[name]/[A]"
			save.cd = "/tiles/[A]"
			var/list/coords = splittext(A, ",")
			var/datum/tileinfo/tf = new/datum/tileinfo()
			tf.posx = coords[1]
			tf.posy = coords[2]
			tf.tiletype = save["type"]
			tf.state = save["state"]
			tf.direction = save["dir"]
			tf.icon = save["icon"]
			bp.req_metal += 1
			bp.req_glass += 0.5
			save.cd = "/tiles/[A]/objects"
			for (var/B in save.dir)
				//if(B == "type" || B == "state") continue
				save.cd = "/tiles/[A]/objects/[B]"
				var/datum/objectinfo/O = new/datum/objectinfo()
				O.objecttype = save["type"]
				O.direction = save["dir"]
				O.layer = save["layer"]
				O.px = save["pixelx"]
				O.py = save["pixely"]
				O.icon_state = save["icon_state"]
				bp.req_metal += 0.9
				bp.req_glass += 1.5
				tf.objects.Add(O)
			bp.roominfo.Add(tf)
			bp.name = "Blueprint '[roomname]'"
			bp.req_metal = round(bp.req_metal)
			bp.req_glass = round(bp.req_glass)

		boutput(usr, "<span class='notice'>Printed blueprint for '[roomname]'.</span>")
		return

	proc/delSaved(var/name = "")
		var/savepath = "data/blueprints/[usr.client.ckey]/[name].dat"
		if (fexists("[savepath]"))
			if (strip_html(input(usr,"Really delete this blueprint? Input blueprint name to confirm.","Blueprint Deletion","") as text) != name)
				boutput(usr, "<span class='alert'>Failed to delete blueprint '[name]': input did not match blueprint name.</span>")
				return
			fdel("[savepath]")
			boutput(usr, "<span class='alert'>Blueprint [name] deleted.</span>")
			return
		else
			boutput(usr, "<span class='alert'>Blueprint [name] not found.</span>")
			return

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

#undef REBUILD_COST_OBJECT_METAL
#undef REBUILD_COST_OBJECT_CRYSTAL
#undef REBUILD_COST_TURF_METAL
#undef REBUILD_COST_TURF_CRYSTAL
#undef BAR_SHEET_VALUE
#undef SELECT_SKIP
#undef SELECT_FIRST_CORNER
#undef DESELECT_FIRST_CORNER
#undef SELECT_SECOND_CORNER
#undef DESELECT_SECOND_CORNER
