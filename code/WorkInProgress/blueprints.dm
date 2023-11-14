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
	event_handler_flags = NO_MOUSEDROP_QOL

	var/invalid_count = 0
	var/building = FALSE
	var/build_index = 1
	var/build_end = 0
	var/list/markers = list()
	var/list/apc_list = list()
	var/metal_owed = 0
	var/crystal_owed = 0
	var/tile_cost_processed = FALSE

	var/obj/item/blueprint/current_bp = null
	var/locked = FALSE
	var/paused = FALSE
	var/off_x = 0
	var/off_y = 0



	New()
		..()
		UnsubscribeProcess()

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/blueprint))
			if(src.current_bp)
				boutput(user, SPAN_ALERT("Theres already a blueprint in the machine."))
				return
			else
				boutput(user, SPAN_NOTICE("You insert the blueprint into the machine."))
				user.drop_item()
				W.set_loc(src)
				src.current_bp = W
				return
		else if (istype(W, /obj/item/sheet) || istype(W, /obj/item/material_piece))
			boutput(user, SPAN_NOTICE("You insert the material into the machine."))
			user.drop_item()
			W.set_loc(src)
			return
		return

	MouseDrop_T(obj/item/W, mob/user)
		if (!in_interact_range(src, user)  || BOUNDS_DIST(W, user) > 0 || !can_act(user))
			return
		else
			if(istype(W, /obj/item/blueprint))
				if(src.current_bp)
					boutput(user, SPAN_ALERT("Theres already a blueprint in the machine."))
					return
				else
					boutput(user, SPAN_NOTICE("You insert the blueprint into the machine."))
					W.set_loc(src)
					src.current_bp = W
					return
			else if (istype(W, /obj/item/sheet) || istype(W, /obj/item/material_piece))
				boutput(user, SPAN_NOTICE("You insert [W] into the machine."))
				W.set_loc(src)
				return
			return


	attack_hand(mob/user)
		if(src.building && !src.paused)
			if (tgui_alert(user, "Pause the construction?", "ABCU", list("Yes", "No")) == "Yes")
				src.pause_build()
			return

		var/list/option_list = list(
			"Check Materials",
			"Resume Construction",
			src.locked ? "Unlock" : "Lock",
			"Begin Building",
			"Dump Materials",
			"Eject Blueprint",
			"Cancel Build",
		)
		var/user_input = tgui_input_list(user, src.building ? "The build job is currently paused. Choose:" : "Select an action.", "ABCU", option_list)
		if (!user_input) return

		switch(user_input)
			if("Unlock")
				if (src.building)
					boutput(user, SPAN_ALERT("Lock status can't be changed with a build in progress."))
					return
				if(!src.locked) return
				src.deactivate()

			if("Lock")
				if (src.building)
					boutput(user, SPAN_ALERT("Lock status can't be changed with a build in progress."))
					return
				if(src.locked) return
				if(!src.current_bp)
					boutput(user, SPAN_ALERT("The machine requires a blueprint before it can be locked."))
					return
				src.activate(user)

			if("Begin Building")
				if(src.building)
					boutput(user, SPAN_ALERT("A build job is already in progress."))
					return
				if(!src.locked)
					boutput(user, SPAN_ALERT("The machine must be locked into place before activating it."))
					return
				if(!src.current_bp)
					boutput(user, SPAN_ALERT("The machine requires a blueprint before it can build anything."))
					return
				src.prepare_build(user)

			if("Eject Blueprint")
				if(src.locked || src.building)
					boutput(user, SPAN_ALERT("Can not eject blueprint while machine is locked or building."))
					return
				if (!src.current_bp)
					boutput(user, SPAN_ALERT("No blueprint to eject."))
					return
				src.current_bp.set_loc(src.loc)
				src.current_bp = null

			if("Dump Materials")
				for(var/obj/o in src)
					if(o == src.current_bp) continue
					o.set_loc(src.loc)

			if("Check Materials")
				src.audit_inventory(user)

			if ("Resume Construction")
				if (!src.building)
					boutput(user, SPAN_ALERT("There's no build in progress."))
					return
				if (!src.paused)
					boutput(user, SPAN_ALERT("[src] is already unpaused."))
					return
				src.unpause_build()

			if ("Cancel Build")
				if (!src.building)
					boutput(user, SPAN_ALERT("There's no build in progress."))
					return
				src.end_build()
		return

	process()
		..()
		if (!src.building) return
		if (src.build_index > src.build_end)
			src.end_build()
			return

		var/datum/tileinfo/tile = src.current_bp.roominfo[src.build_index]
		if (isnull(tile.tiletype))
			src.build_index++
			return

		// try to consume materials for this tile
		if (!src.tile_cost_processed)
			var/obj_count = length(tile.objects)
			src.metal_owed += REBUILD_COST_TURF_METAL + REBUILD_COST_OBJECT_METAL * obj_count
			src.crystal_owed += REBUILD_COST_TURF_CRYSTAL + REBUILD_COST_OBJECT_CRYSTAL * obj_count
			src.tile_cost_processed = TRUE
		for (var/obj/item in src)
			if (src.metal_owed <= 0 && src.crystal_owed <= 0) break
			if (item == src.current_bp) continue

			if (istype(item, /obj/item/sheet))
				var/obj/item/sheet/sheets = item
				if (!sheets.material) continue
				if (src.metal_owed && sheets.material.getMaterialFlags() & MATERIAL_METAL)
					var/sheets_consumed = ceil(min(sheets.amount, src.metal_owed))
					sheets.change_stack_amount(-sheets_consumed)
					src.metal_owed -= sheets_consumed
					continue
				if (src.crystal_owed && sheets.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					var/sheets_consumed = ceil(min(sheets.amount, src.crystal_owed))
					sheets.change_stack_amount(-sheets_consumed)
					src.crystal_owed -= sheets_consumed
					continue

			else if (istype(item, /obj/item/material_piece))
				var/obj/item/material_piece/bars = item
				if (!bars.material) continue
				if (src.metal_owed && bars.material.getMaterialFlags() & MATERIAL_METAL)
					var/bars_consumed = ceil(min(bars.amount, src.metal_owed / BAR_SHEET_VALUE))
					bars.change_stack_amount(-bars_consumed)
					src.metal_owed -= bars_consumed * BAR_SHEET_VALUE
					continue
				if (src.crystal_owed && bars.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					var/bars_consumed = ceil(min(bars.amount, src.crystal_owed / BAR_SHEET_VALUE))
					bars.change_stack_amount(-bars_consumed)
					src.crystal_owed -= bars_consumed * BAR_SHEET_VALUE
					continue

		if (src.metal_owed > 0 || src.crystal_owed > 0)
			src.pause_build()
			src.visible_message(SPAN_ALERT("[src] does not have enough materials to continue construction."))
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 20)
			return
		// now build the tile if we paid for it
		var/turf/pos = locate(text2num(tile.posx) + src.x,text2num(tile.posy) + src.y, src.z)
		for(var/obj/O in src.markers)
			if(O.loc == pos)
				qdel(O)
				break

		src.make_tile(tile, pos)
		src.tile_cost_processed = FALSE
		src.build_index++

	proc/make_tile(var/datum/tileinfo/tile, var/turf/pos)
		set waitfor = 0
		SPAWN(0)
			var/obj/overlay/V = new/obj/overlay(pos)
			V.icon = 'icons/obj/objects.dmi'
			V.icon_state = "buildeffect"
			V.name = "energy"
			V.anchored = ANCHORED
			V.set_density(0)
			V.layer = EFFECTS_LAYER_BASE

			sleep(1.5 SECONDS)

			qdel(V)

			if(tile.tiletype != null)
				var/turf/new_tile = pos
				new_tile.ReplaceWith(tile.tiletype)
				new_tile.icon_state = tile.state
				new_tile.set_dir(tile.direction)
				new_tile.inherit_area()

			for(var/datum/objectinfo/O in tile.objects)
				if (O.objecttype == null) continue
				if (ispath(O.objecttype, /obj/machinery/power/apc))
					src.apc_list[O] = pos
					continue
				var/list/properties = list(
					"layer" = O.layer,
					"pixel_x" = O.px,
					"pixel_y" = O.py,
					"dir" = O.direction)
				if (!isnull(O.icon_state)) properties["icon_state"] = O.icon_state // required for old blueprint support
				new/dmm_suite/preloader(pos, properties) // this doesn't spawn the objects, only presets their properties
				new O.objecttype(pos) // need this part to also spawn the objects

	proc/prepare_build(mob/user)
		if(src.invalid_count)
			boutput(usr, SPAN_ALERT("The machine can not build on anything but empty space. Check for red markers."))
			return

		src.build_end = length(src.current_bp.roominfo)
		if (src.build_end <= 0)
			return

		src.building = TRUE
		src.paused = FALSE
		src.build_index = 1
		src.icon_state = "builder1"
		SubscribeToProcess()
		src.visible_message(SPAN_NOTICE("[src] starts to buzz and vibrate. The operation light blinks on."))
		logTheThing(LOG_STATION, src, "[user] started ABCU build at [log_loc(src)], with blueprint [src.current_bp.name], authored by [src.current_bp.author]")

	proc/end_build()
		SPAWN(2 SECONDS) // gotta wait for make_tile() to finish
			for (var/datum/objectinfo/N in src.apc_list)
				var/obj/machinery/power/apc/new_obj = new N.objecttype(src.apc_list[N])
				new_obj.dir = N.direction
				new_obj.pixel_x = N.px
				new_obj.pixel_y = N.py
				new_obj.deconstruct_flags = DECON_BUILT
			src.apc_list = new/list

		src.building = FALSE
		UnsubscribeProcess()
		src.deactivate()

		src.icon_state = "builder"
		makepowernets()
		src.visible_message(SPAN_NOTICE("[src] whirrs to a stop. The operation light flashes twice and turns off."))

	proc/audit_inventory(mob/user)
		var/metal_count = 0
		var/crystal_count = 0
		for(var/obj/O in src)
			if(O == src.current_bp) continue
			if (istype(O, /obj/item/sheet))
				var/obj/item/sheet/sheets = O
				if (!sheets.material) continue
				if (sheets.material.getMaterialFlags() & MATERIAL_METAL)
					metal_count += sheets.amount
				if (sheets.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					crystal_count += sheets.amount
			else if (istype(O, /obj/item/material_piece))
				var/obj/item/material_piece/bars = O
				if (!bars.material) continue
				if (bars.material.getMaterialFlags() & MATERIAL_METAL)
					metal_count += bars.amount * BAR_SHEET_VALUE
				if (bars.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					crystal_count += bars.amount * BAR_SHEET_VALUE
		if (user)
			var/message = SPAN_NOTICE("The machine is holding [metal_count] metal, and [crystal_count] crystal, measured in sheets.")
			if (src.current_bp)
				message += "<br><span class='notice'>Its current blueprint requires [src.current_bp.req_metal] metal,"
				message += " and [src.current_bp.req_glass] crystal, measured in sheets.</span>"
			boutput(user, message)
		return list(metal_count, crystal_count)

	proc/unpause_build()
		src.paused = FALSE
		src.icon_state = "builder1"
		SubscribeToProcess()
		src.visible_message(SPAN_NOTICE("[src] starts to buzz and vibrate."))

	proc/pause_build()
		src.paused = TRUE
		src.icon_state = "builder"
		UnsubscribeProcess()
		src.visible_message(SPAN_NOTICE("[src] releases a small puff of steam, then quiets down."))

	proc/deactivate()
		for(var/obj/O in src.markers)
			qdel(O)
		src.locked = FALSE
		src.anchored = UNANCHORED
		src.visible_message("[src] disengages its anchors.")

	proc/activate(mob/user)
		src.locked = TRUE
		src.anchored = ANCHORED
		src.invalid_count = 0
		for(var/datum/tileinfo/T in src.current_bp.roominfo)
			var/turf/pos = locate(text2num(T.posx) + src.x,text2num(T.posy) + src.y, src.z)
			var/obj/abcuMarker/O = null

			if(istype(pos, /turf/space))
				O = new/obj/abcuMarker(pos)
			else
				O = new/obj/abcuMarker/red(pos)
				src.invalid_count++

			src.markers.Add(O)
		boutput(user, SPAN_NOTICE("Building this will require [src.current_bp.req_metal] metal and [src.current_bp.req_glass] glass sheets."))
		src.visible_message("[src] locks into place and begins humming softly.")

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

	boutput(usr, SPAN_NOTICE("Printed blueprint for '[roomname]'."))
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
	boutput(usr, SPAN_NOTICE("Deleted [inputuser]'s [inputbp]."))

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

	boutput(usr, SPAN_NOTICE("Dumped blueprint to BYOND user data folder."))

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
			boutput(user, SPAN_ALERT("Unsupported Tile type detected."))
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
			boutput(user, SPAN_ALERT("Tile exceeds maximum size of blueprint."))
			playsound(src.loc, 'sound/machines/button.ogg', 25)
			return

		switch (selecting)
			if (SELECT_SKIP)
				;
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
					boutput(user, SPAN_ALERT("Tile exceeds maximum size of blueprint."))
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

			save.cd = "/tiles/[posx],[posy]"
			save["type"] << curr.type
			save["dir"] << curr.dir
			save["state"] << curr.icon_state
			if (curr.icon != initial(curr.icon))
				save["icon"] << "[curr.icon]" // string this or it saves the entire .dmi file

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
					save.cd = "[id]"
					save["dir"] << o.dir
					save["type"] << o.type
					save["layer"] << o.layer
					save["pixelx"] << o.pixel_x
					save["pixely"] << o.pixel_y
					save["icon_state"] << o.icon_state

		boutput(usr, SPAN_NOTICE("Saved blueprint as '[name]'. "))
		return

	proc/printSaved(var/name = "")
		var/savepath = "data/blueprints/[usr.client.ckey]/[name].dat"
		var/savefile/save = new/savefile("[savepath]") // if it's not an existing file, this makes an empty new one
		if (isnull(save["roomname"]) && isnull(save["sizex"])) // double check
			boutput(usr, SPAN_ALERT("Blueprint [name] not found."))
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

		boutput(usr, SPAN_NOTICE("Printed blueprint for '[roomname]'."))
		return

	proc/delSaved(var/name = "")
		var/savepath = "data/blueprints/[usr.client.ckey]/[name].dat"
		if (fexists("[savepath]"))
			if (strip_html(input(usr,"Really delete this blueprint? Input blueprint name to confirm.","Blueprint Deletion","") as text) != name)
				boutput(usr, SPAN_ALERT("Failed to delete blueprint '[name]': input did not match blueprint name."))
				return
			fdel("[savepath]")
			boutput(usr, SPAN_ALERT("Blueprint [name] deleted."))
		else
			boutput(usr, SPAN_ALERT("Blueprint [name] not found."))

	attack_self(mob/user as mob)
		if(!user.client)
			return

		if (selecting)
			selecting = SELECT_SKIP
			qdel(corner1img)
			boutput(user, SPAN_NOTICE("Cancelled rectangle select."))
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
				boutput(user, SPAN_NOTICE("Resetting ..."))
				removeOverlays()
				roomList.Cut()

			if("Set Blueprint Name")
				roomname = copytext(strip_html(input(user,"Set Blueprint Name:","Setup",roomname) as text), 1, 257)
				boutput(user, SPAN_NOTICE("Name set to '[roomname]'"))

			//if("Create Clone Blueprint")
			//	saveMarked("_temp", 1)
			//	printSaved("_temp")
			//	return

			if("Print Saved Blueprint")
				if(prints_left <= 0)
					boutput(user, SPAN_ALERT("Out of energy."))
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
				var/message = "[SPAN_NOTICE("This tool is used for making, saving and loading room blueprints on the server.")]<br>"
				message += "[SPAN_NOTICE("Saved blueprints persist between rounds, but are limited to a size of 20 tiles on each axis, making 20x20 the largest blueprint.")]<br><br>"
				message += "[SPAN_NOTICE("(De)Select Rectangle: Mass-selects or deselects tiles in a filled rectangle shape, defined by 2 corners.")]<br>"
				message += "[SPAN_NOTICE("Reset: Resets the tools and clears all marked areas.")]<br>"
				message += "[SPAN_NOTICE("Set Blueprint Name: Sets the active blueprint that print/save/delete functions will access.")]<br>"
				message += "[SPAN_NOTICE("Print Saved Blueprint: Prints the active blueprint for usage in the ABCU builder device.")]<br>"
				message += "[SPAN_NOTICE("Save Blueprint: Saves a blueprint of the marked area to the server. Most structures will be saved, but it can not save all types of objects.")]<br>"
				message += "[SPAN_NOTICE("Your saved blueprints are accessed solely by its Blueprint Name, so note it down.")]<br>"
				message += "[SPAN_NOTICE("Delete Blueprint: Permanently deletes the active blueprint from the server.")]<br>"
				message += "[SPAN_NOTICE("Outdated blueprints can be migrated using the 'Migrate blueprint' local verb.")]<br>"
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

/obj/item/blueprint_marker/verb/migrate_bigfile_blueprint()
	// this is a tucked-away verb because it's niche and for old stuff, don't want it on the tool's main menu
	set name = "Migrate blueprint"
	set desc = "Attempt to convert an older blueprint to the latest save system."
	set category = "Local"
	set src in usr
	var/mob/user = usr
	if (!user.client) return
	boutput(user, SPAN_NOTICE("Looking for older blueprints to convert. If this process doesn't work, sorry, I tried my best."))

	var/savefile/save = new/savefile("data/blueprints.dat")
	save.cd = "/"
	if (!save.dir.Find("[user.client.ckey]"))
		boutput(user, SPAN_ALERT("Your user wasn't found in the blueprints file. Stopping."))
		return
	save.cd = "/[user.client.ckey]"
	var/list/bplist = save.dir

	if (!length(bplist))
		boutput(user, SPAN_ALERT("No blueprints found. Stopping."))
		return
	var/input = tgui_input_list(user, "Select a blueprint to migrate.", "Blueprints", bplist)
	if (!input) return
	var/old_save_path = "/[user.client.ckey]/[input]"
	save.cd = old_save_path

	// ckeyEx to sanitize filename: no spaces/special chars, only '_', '-', and '@' allowed. 54 char limit in tgui_input
	var/new_save_name = strip_html(tgui_input_text(user, "Set a name for your migrated blueprint. \
		Filename conversion preserves only alphanumeric characters, and - and _.",
		"Blueprint Name", save["roomname"], 54))
	if (!new_save_name) return
	// raw input goes into savefile's roomname, sanitized goes into filename
	var/new_save_name_sanitized = ckeyEx(new_save_name)
	var/savepath = "data/blueprints/[user.client.ckey]/[new_save_name_sanitized].dat"

	var/savefile/new_save = new/savefile(savepath) // creates a save, or loads an existing one
	new_save.cd = "/"
	if (new_save["sizex"] || new_save["sizey"]) // if it exists, and has data in it, ALERT!
		if (tgui_alert(user, "A blueprint file named [new_save_name_sanitized] already exists. Really overwrite?",
			"Overwrite Blueprint", list("Yes", "No")) == "Yes")
			fdel(savepath)
			new_save = new/savefile(savepath)
		else return

	new_save.cd = "/"
	new_save["sizex"] << save["sizex"]
	new_save["sizey"] << save["sizey"]
	new_save["roomname"] << new_save_name
	new_save["author"] << user.client.ckey
	var/turf_count = 0
	var/obj_count = 0

	for (var/A in save.dir)
		if(A == "sizex" || A == "sizey" || A == "roomname") continue
		save.cd = "[old_save_path]/[A]"
		new_save.cd = "/tiles/[A]"

		new_save["type"] << save["type"]
		new_save["dir"] << save["dir"]
		new_save["state"] << save["state"]
		turf_count++
		for (var/B in save.dir)
			if(B == "type" || B == "state" || B == "dir") continue
			save.cd = "[old_save_path]/[A]/[B]"
			new_save.cd = "/tiles/[A]/objects/[B]"

			new_save["dir"] << save["dir"]
			new_save["type"] << save["type"]
			new_save["layer"] << save["layer"]
			new_save["pixelx"] << save["pixelx"]
			new_save["pixely"] << save["pixely"]
			obj_count++
	boutput(user, SPAN_NOTICE("Created blueprint file [new_save_name]. Copied [turf_count] tiles and [obj_count] objects."))

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
