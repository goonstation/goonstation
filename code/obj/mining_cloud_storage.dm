/datum/ore_cloud_data
	var/amount = 0
	var/price = 0
	var/for_sale = FALSE
	var/type_path = /obj/item/raw_material
	var/list/stats = list()

/obj/machinery/ore_cloud_storage_container
	name = "Rockbox™ Ore Cloud Storage Container"
	desc = "This thing stores ore in \"the cloud\" for the station to use. Best not to think about it too hard."
	icon = 'icons/obj/mining_cloud_storage.dmi'
	icon_state = "ore_storage_unit"
	density = TRUE
	anchored = TRUE
	event_handler_flags = USE_FLUID_ENTER | NO_MOUSEDROP_QOL

	var/list/datum/ore_cloud_data/ores = list()
	var/default_price = 20
	var/autosell = TRUE

	var/health = 100
	var/broken = FALSE
	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')

	var/output_target = null

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr) || isintangible(usr))
			boutput(usr, "<span class='alert'>Only tangible, living mobs are able to set the output target for [src].</span>")
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, "<span class='alert'>[src] is too far away from the target!</span>")
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable cart as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, "<span class='notice'>You set [src] to output on top of [O]!</span>")

		else if (istype(over_object,/turf) && !over_object:density)
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	MouseDrop_T(atom/movable/dropped, mob/user)
		if (!dropped || !user)
			return

		if(!isliving(user) || isintangible(user))
			boutput(user, "<span class='alert'>Only tangible, living mobs are able to use the storage container's quick-load feature.</span>")
			return

		if (!isobj(dropped))
			boutput(user, "<span class='alert'>You can't quick-load that.</span>")
			return

		if(BOUNDS_DIST(dropped, user) > 0)
			boutput(user, "<span class='alert'>You are too far away!</span>")
			return

		if(!src.accept_loading(user, TRUE))
			boutput(user,"<span class='alert'>The storage container's quick-load system rejects you!</span>")
			return

		else if (istype(dropped, /obj/storage/crate/)  || istype(dropped, /obj/storage/cart/))
			var/obj/storage/store = dropped
			if(istype(store) && (store.welded || store.locked))
				boutput(user, "<span class='alert'>You cannot load from a [store] that cannot open!</span>")
				return

			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [dropped]!</span>", "<span class='notice'>You use [src]'s automatic loader on [dropped].</span>")
			var/amtload = 0
			var/rejected = 0
			for (var/obj/item/raw_material/M in dropped.contents)
				if(M.material?.name != M.initial_material_name)
					rejected += M.amount
					continue
				amtload += M.amount
				src.load_item(M)

			if(rejected)
				boutput(user, "<span class='alert'>[src] rejects [rejected] anomalous ore[rejected > 1 ? "s" :""].</span>")
			if (amtload)
				boutput(user, "<span class='notice'>[amtload] ore[amtload > 1 ? "s" : ""] loaded from [dropped]!</span>")
			else boutput(user, "<span class='alert'>No ore loaded!</span>")

		else if (isitem(dropped))
			quickload(user,dropped)
		else
			..()

		src.updateUsrDialog()

	proc/quickload(var/mob/living/user,var/obj/item/O)
		if (!user || !O)
			return
		if(istype(O,/obj/item/raw_material/))
			var/obj/item/raw_material/R = O
			if(R.material?.name != R.initial_material_name)
				boutput(user, "<span class='alert'>[src] rejects the anomalous ore.</span>")
				return
		else
			boutput(user, "<span class='alert'>[O] doesn't fit into [src]!</span>")
			return
		user.visible_message("<span class='notice'>[user] begins quickly stuffing [O] into [src]!</span>")
		var/staystill = user.loc
		for(var/obj/item/raw_material/M in view(1,user))
			if (!M)
				continue
			if (M.type != O.type)
				continue
			if(!isSameMaterial(O.material,M.material))
				continue
			if(M.material?.name != M.initial_material_name)
				continue
			if (O.loc == user)
				continue
			if (O in user.contents)
				continue
			src.load_item(M)
			playsound(src, sound_load, 40, 1)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/scoop = W
			if (!scoop?.satchel)
				boutput(user, "<span class='alert'>No ore satchel to unload from [W].</span>")
				return
			W = scoop.satchel

		if (istype(W, /obj/item/raw_material/) && src.accept_loading(user))
			var/obj/item/raw_material/R = W
			if(R.material?.name != R.initial_material_name)
				boutput(user, "<span class='alert'>[src] rejects the anomalous ore.</span>")
				return
			user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>", "<span class='notice'>You load [W] into the [src].</span>")
			src.load_item(W,user)
		else if (istype(W, /obj/item/satchel/mining))
			var/obj/item/satchel/mining/satchel = W
			user.visible_message("<span class='notice'>[user] starts dumping [satchel] into [src].</span>", "<span class='notice'>You start dumping [satchel] into [src].</span>")
			var/amtload = 0
			for (var/obj/item/loading in W.contents)
				var/obj/item/raw_material/R = loading
				if (R.material?.name != R.initial_material_name)
					continue
				src.load_item(R, user)
				amtload++
			satchel.UpdateIcon()
			if (amtload)
				boutput(user, "<span class='notice'>[amtload] materials loaded from [satchel]!</span>")
			else
				boutput(user, "<span class='alert'>[satchel] is empty!</span>")
		else
			src.health = max(src.health-W.force,0)
			src.check_health()
			..()

	proc/check_health()
		if(!src.health && !broken)
			src.broken = TRUE
			src.visible_message("<span class='alert'>[src] breaks!</span>")
			src.icon_state = "ore_storage_unit-broken"

	proc/load_item(var/obj/item/raw_material/R,var/mob/living/user)
		if (!R)
			return
		if (user)
			user.u_equip(R)
			R.dropped(user)
		add_ore_amount(R.material_name,R.amount,R)
		qdel(R)
		tgui_process.update_uis(src)


	proc/accept_loading(var/mob/user,var/allow_silicon = FALSE)
		if (!user)
			return 0
		if (src.status & BROKEN || src.status & NOPOWER)
			return 0
		if (!istype(user, /mob/living/))
			return 0
		if (istype(user, /mob/living/silicon) && !allow_silicon)
			return 0
		var/mob/living/L = user
		if (!isalive(L) || L.transforming)
			return 0
		return 1

	proc/add_ore_amount(var/material_name,var/delta,var/obj/item/raw_material/ore)
		var/datum/ore_cloud_data/OCD = ores[material_name]
		if(isnull(OCD))
			OCD = new /datum/ore_cloud_data()
			OCD.price = src.default_price
			OCD.for_sale = src.autosell
			OCD.type_path = ore.type
		OCD.amount += max(delta,0)
		if(ore.material)
			for(var/i in 1 to delta) //make some copies of the material if this is a stack
				var/datum/material/matCopy = copyMaterial(ore.material)
				matCopy.owner = null
				OCD.stats += matCopy
		OCD.amount = round(max(OCD.amount,0)) //floor values to avoid float imprecision
		ores[material_name] = OCD

	proc/human_readable_ore_properties(var/datum/material/mat)
		if (!mat)
			return "no properties"
		if (istype(mat, /datum/material/crystal/gemstone)) return "varied levels of hardness and density"
		var/list/stat_list = list()
		for(var/datum/material_property/stat in mat.properties)
			stat_list += stat.getAdjective(mat)
		if (!stat_list.len) return "no properties"
		return stat_list.Join(", ")

	proc/update_ore_for_sale(var/material_name,var/new_for_sale)
		if(ores[material_name])
			var/datum/ore_cloud_data/OCD = ores[material_name]
			if(isnull(new_for_sale))
				OCD.for_sale = !OCD.for_sale
			else
				OCD.for_sale = new_for_sale
		return

	proc/update_ore_price(var/material_name,var/new_price)
		if(ores[material_name])
			var/datum/ore_cloud_data/OCD = ores[material_name]
			OCD.price = max(0,new_price)
		return

	proc/eject_ores(var/material_name, var/eject_location, var/ejectamt, var/transmit = FALSE, var/mob/user)
		if(ejectamt < 1)
			return
		var/amount_ejected = 0
		if(!eject_location)
			eject_location = get_output_location()

		var/datum/ore_cloud_data/OCD = ores[material_name]
		if(OCD)
			amount_ejected = min(ejectamt, OCD.amount)
			for(var/i in 1 to amount_ejected)
				var/obj/item/raw_material/ore = new OCD.type_path(src)
				ore.removeMaterial()
				ore.setMaterial(OCD.stats[length(OCD.stats)], (lowertext(ore.initial_material_name) != lowertext(ore.material_name)), (lowertext(ore.initial_material_name) != lowertext(ore.material_name)), FALSE) //for the most part, this will only affect gemstones by preserving their type, but also quality
				ore.initial_material_name = ore.material.name
				OCD.stats.Cut(length(OCD.stats))
				ore.set_loc(eject_location)
				OCD.amount--

		if(transmit)
			flick("ore_storage_unit-transmit",src)
			showswirl(eject_location)
			leaveresidual(eject_location)

	proc/get_output_location()
		if (!src.output_target)
			return src.loc

		if (BOUNDS_DIST(src.output_target, src) > 0)
			src.output_target = null
			return src.loc

		if (istype(src.output_target,/obj/storage/crate/))
			var/obj/storage/crate/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C
		if (istype(src.output_target,/obj/storage/cart/))
			var/obj/storage/cart/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C

		if (istype(src.output_target,/turf/))
			return src.output_target

		return src.loc

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Rockbox")
			ui.open()

	ui_data(mob/user)
		var/ore_list = list()
		for(var/O as anything in ores)
			var/datum/ore_cloud_data/OCD = ores[O]

			ore_list += list(list(
				"name" = O,
				"amount" = OCD.amount,
				"price" = OCD.price,
				"forSale" = OCD.for_sale,
				"stats" = length(OCD.stats) ? src.human_readable_ore_properties(OCD.stats[length(OCD.stats)]) : ""
			))

		. = list(
			"ores" = ore_list,
			"default_price" = src.default_price,
			"autosell" = src.autosell
		)
	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return
		switch(action)
			if("dispense-ore")
				eject_ores(params["ore"], null, params["take"])
				. = TRUE
			if("toggle-ore-sell-status")
				var/ore = params["ore"]
				update_ore_for_sale(ore)
				. = TRUE
			if("set-default-price")
				var/price = params["newPrice"]
				default_price = max(price, 0)
				. = TRUE
			if("toggle-auto-sell")
				autosell = !autosell
				. = TRUE
			if("set-ore-price")
				var/ore = params["ore"]
				var/price = params["newPrice"]
				update_ore_price(ore, price)
				. = TRUE

