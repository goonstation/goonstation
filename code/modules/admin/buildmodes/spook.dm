/atom/var/list/spookTypes = null
/atom/proc/spook_act(type)
	//do spooky things
/atom/proc/spook_data(type)
	//o no
/atom/proc/spook_getspooks()
	if(istext(spookTypes))
		spookTypes = splittext( spookTypes, ";" )
	return spookTypes
/datum/buildmode/spook
	name = "Spook"
	desc = {"***********************************************************<br>
Left Mouse Button on turf/mob/obj      = Spook it<br>
Right Mouse Button on turf/mob/obj     = Select spook<br>
***********************************************************"}

	var/activeType
	var/activeSpook
	var/spookData

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		var/list/choices = list()
		if(object.spookTypes)
			choices += object.spook_getspooks()

		var/typeinfo/atom/typeinfo = object.get_typeinfo()
		if (typeinfo.admin_procs)
			for (var/procpath/proc_path as anything in typeinfo.admin_procs)
				var/proc_name = proc_path.name
				if (!proc_name)
					var/split_list = splittext("[proc_path]", "/")
					proc_name = split_list[length(split_list)]
				choices["[proc_name] *"] = proc_path

		if(!choices.len)
			return

		var/choice = tgui_input_list(usr, "What spook?", "Spook", choices)
		activeSpook = choice

		if(!activeSpook)
			return

		activeType = object.type
		update_button_text("[activeType]: [choice]")

		if(choices[activeSpook])
			activeSpook = choices[activeSpook]

		if(istext(activeSpook))
			spookData = object.spook_data( activeSpook )
		else if(isproc(activeSpook))
			spookData = null

	click_left(atom/object)
		if(istext(activeSpook) && activeType && (istype( object, activeType ) || (object.spookTypes && (activeSpook in object.spook_getspooks()))))
			object.spook_act( activeSpook, spookData )
		else if(isproc(activeSpook))
			var/typeinfo/atom/typeinfo = object.get_typeinfo()
			if (typeinfo.admin_procs && (activeSpook in typeinfo.admin_procs))
				call(object, activeSpook)()

/obj/machinery/light/spookTypes = "Set Color"
/obj/machinery/light/spook_data(what)
	switch(what)
		if("Set Color")
			var/ret = input("What color?") as color
			return list( hex2num(copytext(ret, 2, 4)) / 255.0, hex2num(copytext(ret, 4, 6)) / 255.0, hex2num(copytext(ret, 6, 8)) / 255.0 )
		else
			.=..()

/obj/machinery/light/spook_act(what,data)
	switch(what)
		if("Set Color")
			light.set_color( arglist(data || list(1,1,1)) )
		else
			..()

/obj/machinery/door/spookTypes = "Toggle"
/obj/machinery/door/spook_act(what, data)
	switch(what)
		if("Toggle")
			if (src.density)
				open()
			else
				close()
		else
			.=..()

/obj/item/device/light/flashlight/spookTypes = "Set Color"
/obj/item/device/light/flashlight/spook_data(what)
	switch(what)
		if("Set Color")
			var/ret = input("What color?") as color
			return list( hex2num(copytext(ret, 2, 4)) / 255.0, hex2num(copytext(ret, 4, 6)) / 255.0, hex2num(copytext(ret, 6, 8)) / 255.0 )
		else
			.=..()
/obj/item/device/light/flashlight/spook_act(what,data)
	switch(what)
		if("Set Color")
			light.set_color(arglist( data ))
		else
			.=..()

/obj/storage/spookTypes = "Toggle;Thump"
/obj/storage/spook_act(what)
	switch(what)
		if("Toggle")
			toggle()
		if("Thump")
			animate_storage_thump(src)
		else .=..()

/obj/item/spookTypes = "Spook;Come Alive"
/obj/item/spook_act(what)
	switch(what)
		if("Spook")
			var/rdeg = rand(15,30)
			animate(src, pixel_y = 32, transform = matrix(rdeg, MATRIX_ROTATE), time = 10, loop = -1, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(rdeg * -1, MATRIX_ROTATE), time = 10, loop = -1, easing = SINE_EASING)
		if("Come Alive")
			new/mob/living/object/ai_controlled(src.loc, src)
		else
			.	=	..()

/obj/critter/domestic_bee/spookTypes = "Zombify"
/obj/critter/domestic_bee/spook_act(what, data)
	switch(what)
		if("Zombify")
			name = "zombee"
			desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types.<br>This one seems kinda sick, poor thing."
			icon_state = "zombee-wings"
			icon_body = "zombee"
			sleeping_icon_state = "zombee-sleep"
			honey_color = rgb(0, 255, 0)
		else
			. = ..()
