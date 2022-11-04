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
		if( object.spookTypes )
			//var/list/otypes = object.spookTypes
			activeSpook = input( "Select a Spook" ) as null|anything in object.spook_getspooks()
			activeType = object.type
			spookData = object.spook_data( activeSpook )
			update_button_text("[activeType]: [activeSpook]")

	click_left(atom/object)
		if(activeSpook && activeType && (istype( object, activeType ) || (object.spookTypes && (activeSpook in object.spook_getspooks()))))
			object.spook_act( activeSpook, spookData )

/obj/machinery/light/spookTypes = "Break;Set Color;Toggle"
/obj/machinery/light/spook_data(what)
	switch(what)
		if("Set Color")
			var/ret = input("What color?") as color
			return list( hex2num(copytext(ret, 2, 4)) / 255.0, hex2num(copytext(ret, 4, 6)) / 255.0, hex2num(copytext(ret, 6, 8)) / 255.0 )
		else
			.=..()
/obj/machinery/light/spook_act(what,data)
	switch(what)
		if("Break")
			broken()
		if("Set Color")
			light.set_color( arglist(data || list(1,1,1)) )
		if("Toggle")
			src.seton(!src.on)
		else
			..()

/obj/machinery/door/spookTypes = "Open;Close;Toggle"
/obj/machinery/door/spook_act(what, data)
	switch(what)
		if("Open")
			open()
		if("Close")
			close()
		if("Toggle")
			if (src.density)
				open()
			else
				close()
		else
			.=..()
/obj/machinery/door/airlock/spook_getspooks()
	return ..() + "Deny Sound"
/obj/machinery/door/airlock/spook_act(what, data)
	switch(what)
		if("Deny Sound")
			play_deny()
		else
			.=..()

/obj/item/reagent_containers/food/drinks/drinkingglass/spookTypes = "Break"
/obj/item/reagent_containers/food/drinks/drinkingglass/spook_act(what)
	switch(what)
		if("Break")
			smash()
		else
			.=..()
/obj/item/device/light/flashlight/spookTypes = "Set Color;Toggle"
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
		if("Toggle")
			attack_self()
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
/*/obj/storage/secure
	spookTypes = "Toggle;Secure"//just because i'm lazy, don't do this please
	spook_act(what)
		switch(what)
			if("Toggle Lock")
				toggle()
			else .=..()
*/
/obj/machinery/vending/spookTypes = "Throw Item"
/obj/machinery/vending/spook_act(what)
	switch(what)
		if("Throw Item")
			throw_item()
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

/obj/critter/domestic_bee/spookTypes = "Dance;Honey;Zombify"
/obj/critter/domestic_bee/spook_act(what, data)
	switch(what)
		if("Zombify")
			name = "zombee"
			desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types.<br>This one seems kinda sick, poor thing."
			icon_state = "zombee-wings"
			icon_body = "zombee"
			sleeping_icon_state = "zombee-sleep"
			honey_color = rgb(0, 255, 0)
		if("Dance")
			src.dance()
		if("Honey")
			src.puke_honey()
		else
			. = ..()

/obj/machinery/light_switch/spookTypes = "Toggle"
/obj/machinery/light_switch/spook_act(what, data)
	switch(what)
		if("Toggle")
			src.attack_hand(usr)
		else
			. = ..()

/obj/machinery/power/apc/spookTypes = "Toggle"
/obj/machinery/power/apc/spook_act(what, data)
	switch(what)
		if("Toggle")
			src.operating = !src.operating
			src.update()
			UpdateIcon()
		else
			. = ..()
