/*
CONTAINS:
RODS
METAL
REINFORCED METAL
MATERIAL

*/

/proc/window_reinforce_callback(var/datum/action/bar/icon/build/B, var/obj/window/reinforced/W)
	W.ini_dir = 2
	if (!istype(W) || !usr) //Wire: Fix for Cannot read null.loc (|| !usr)
		return
	if (B.sheet.reinforcement)
		W.set_reinforcement(B.sheet.reinforcement)
		if (map_settings)
			W = new map_settings.rwindows_thin (usr.loc)
		else
			W = new /obj/window/reinforced(usr.loc)

/proc/window_reinforce_full_callback(var/datum/action/bar/icon/build/B, var/obj/window/reinforced/W)
	W.set_dir(SOUTHWEST)
	W.ini_dir = SOUTHWEST
	if (!istype(W))
		return
	if (!usr) //Wire: Fix for Cannot read null.loc
		return
	if (B.sheet.reinforcement)
		W.set_reinforcement(B.sheet.reinforcement)
		if (map_settings)
			W = new map_settings.rwindows (usr.loc)
		else
			W = new /obj/window/reinforced(usr.loc)

/obj/item/sheet
	name = "sheet"
	icon = 'icons/obj/metal.dmi'
	icon_state = "sheet-m_5"
	//Used to determine the right icon_state: combined with suffixes for material/reinforcement in update_appearance and one for amount in change_stack_appearance
	var/icon_state_base = "sheet"
	desc = "Thin sheets of building material. Can be used to build many things."
	flags = FPRINT | TABLEPASS
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_NORMAL
	max_stack = 50
	stamina_damage = 42
	stamina_cost = 23
	stamina_crit_chance = 10
	var/datum/material/reinforcement = null
	rand_pos = 1
	inventory_counter_enabled = 1

	New()
		..()
		SPAWN_DBG(0)
			update_appearance()
		create_inventory_counter()
		BLOCK_SETUP(BLOCK_ALL)

	proc/amount_check(var/use_amount,var/mob/user)
		if (src.amount < use_amount)
			if (user)
				boutput(user, "<span class='alert'>You need at least [use_amount] sheets to do that.</span>")
			return 0
		else
			return 1

	change_stack_amount(diff)
		. = ..()
		if (amount < 1)
			if (isliving(src.loc))
				var/mob/living/L = src.loc
				L.Browse(null, "window=met_sheet")
				onclose(L, "met_sheet")

	proc/set_reinforcement(var/datum/material/M)
		if (!istype(M))
			return
		src.reinforcement = M
		update_appearance()

	onMaterialChanged()
		..()
		update_appearance()

	proc/update_appearance()
		src.name = initial(name)
		src.icon_state_base = initial(icon_state_base)
		if (istype(material))
			if (src.material.material_flags & MATERIAL_CRYSTAL)
				src.icon_state_base += "-g"
			else
				src.icon_state_base += "-m"
			src.name = "[material.name] " + src.name
			if (istype(reinforcement))
				src.name = "[reinforcement.name]-reinforced " + src.name
				src.icon_state_base += "-r"
			src.color = src.material.color
			src.alpha = src.material.alpha
		inventory_counter?.update_number(amount)
		update_stack_appearance()

	update_stack_appearance()
		if (amount <= 10)
			icon_state = "[icon_state_base]_1"
		else if (amount <= 20)
			icon_state = "[icon_state_base]_2"
		else if (amount <= 30)
			icon_state = "[icon_state_base]_3"
		else if (amount <= 40)
			icon_state = "[icon_state_base]_4"
		else
			icon_state = "[icon_state_base]_5"



	attack_hand(mob/user as mob)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = round(input("How many sheets do you want to take from the stack?","Stack of [src.amount]",1) as num)
			if(src.loc != user)
				return
			splitnum = round(clamp(splitnum, 0, src.amount))
			if(amount == 0)
				return
			var/obj/item/sheet/new_stack = split_stack(splitnum)
			if (!istype(new_stack))
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
			boutput(user, "<span class='notice'>You take [splitnum] sheets from the stack, leaving [src.amount] sheets behind.</span>")
		else
			..(user)

	attackby(obj/item/W, mob/user as mob)
		if (istype(W, /obj/item/sheet))
			var/obj/item/sheet/S = W
			if (S.material && src.material && !isSameMaterial(S.material, src.material))
				// build glass tables
				if (src.material.material_flags & MATERIAL_METAL && S.material.material_flags & MATERIAL_CRYSTAL) // we're a metal and they're a glass
					if (src.amount_check(1,user) && S.amount_check(2,user))
						var/reinf = S.reinforcement ? 1 : 0
						var/a_type = reinf ? /obj/item/furniture_parts/table/glass/reinforced : /obj/item/furniture_parts/table/glass
						var/a_icon_state = "[reinf ? "r_" : null]table_parts"
						var/a_name = "[reinf ? "reinforced " : null]glass table parts"
						actions.start(new /datum/action/bar/icon/build(S, a_type, 2, S.material, 1, 'icons/obj/furniture/table_glass.dmi', a_icon_state, a_name, null, src, 1), user)
					return
				else if (src.material.material_flags & MATERIAL_CRYSTAL && S.material.material_flags & MATERIAL_METAL) // we're a glass and they're a metal
					if (src.amount_check(2,user) && S.amount_check(1,user))
						var/reinf = src.reinforcement ? 1 : 0
						var/a_type = reinf ? /obj/item/furniture_parts/table/glass/reinforced : /obj/item/furniture_parts/table/glass
						var/a_icon_state = "[reinf ? "r_" : null]table_parts"
						var/a_name = "[reinf ? "reinforced " : null]glass table parts"
						actions.start(new /datum/action/bar/icon/build(src, a_type, 2, src.material, 1, 'icons/obj/furniture/table_glass.dmi', a_icon_state, a_name, null, S, 1), user)
					return

				else
					boutput(user, "<span class='alert'>You can't mix different materials!</span>")
					return
			if (!isSameMaterial(S.reinforcement, src.reinforcement))
				boutput(user, "<span class='alert'>You can't mix different reinforcements!</span>")
				return
			var/success = stack_item(W)
			if (!success)
				boutput(user, "<span class='alert'>You can't put any more sheets in this stack!</span>")
			else
				if(!user.is_in_hands(src))
					user.put_in_hand(src)
				if(isrobot(user))
					boutput(user, "<span class='notice'>You add [success] sheets to the stack. It now has [S.amount] sheets.</span>")
				else
					boutput(user, "<span class='notice'>You add [success] sheets to the stack. It now has [src.amount] sheets.</span>")
			return

		else if (istype(W,/obj/item/rods))
			var/obj/item/rods/R = W
			if (src.reinforcement)
				boutput(user, "<span class='alert'>That's already reinforced!</span>")
				return
			if (!R.material)
				boutput(user, "<span class='alert'>These rods won't work for reinforcing.</span>")
				return

			if (src.material && (src.material.material_flags & MATERIAL_METAL || src.material.material_flags & MATERIAL_CRYSTAL))
				var/makesheets = min(min(R.amount,src.amount),50)
				var/sheetsinput = input("Reinforce how many sheets?","Min: 1, Max: [makesheets]",1) as num
				if (sheetsinput < 1)
					return
				sheetsinput = min(sheetsinput,makesheets)

				if (!R) //Wire note: Fix for Cannot read null.material (the rods are getting destroyed during the input())
					return

				var/obj/item/sheet/S = new /obj/item/sheet(get_turf(user))
				S.setMaterial(src.material)
				S.set_reinforcement(R.material)
				S.amount = sheetsinput
				S.inventory_counter.update_number(S.amount)
				R.change_stack_amount(-sheetsinput)
				src.change_stack_amount(-sheetsinput)
			else
				boutput(user, "<span class='alert'>You may only reinforce metal or crystal sheets.</span>")
				return
		else
			..()
		return

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins gathering up [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish gathering sheets.</span>")

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/sheet/))
			//boutput(world, "check valid stack check 1 failed")
			return 0
		var/obj/item/sheet/S = O
		if (!S.material || !src.material)
			return 0
		if (S.material.type != src.material.type)
			//boutput(world, "check valid stack check 2 failed")
			return 0
		if (S.material && src.material && !isSameMaterial(S.material, src.material))
			//boutput(world, "check valid stack check 3 failed")
			return 0
		if ((src.reinforcement && !S.reinforcement) || (S.reinforcement && !src.reinforcement))
			//boutput(world, "check valid stack check 4 failed")
			return 0
		if (src.reinforcement && S.reinforcement)
			if (src.reinforcement.type != S.reinforcement.type)
				//boutput(world, "check valid stack check 5 failed")
				return 0
			if (!isSameMaterial(S.reinforcement, src.reinforcement))
				//boutput(world, "check valid stack check 6 failed")
				return 0
		return 1

	examine()
		. = ..()
		. += "There [src.amount > 1 ? "are" : "is"] [src.amount] sheet\s on the stack."

	attack_self(mob/user as mob)
		var/t1 = text("<HTML><HEAD></HEAD><TT>Amount Left: [] <BR>", src.amount)
		var/counter = 1
		var/list/L = list(  )
		if (src?.material.material_flags & MATERIAL_METAL)
			if (istype(src.reinforcement))
				L["retable"] = "Reinforced Table Parts (2 Sheets)"
				L["industrialtable"] = "Industrial Table Parts (2 Sheets)"
				L["remetal"] = "Remove Reinforcement"
			else
				L["fl_tiles"] = "x4 Floor Tile"
				L["rods"] = "x2 Rods"
				L["rack"] = "Rack Parts"
				L["railing"] = "Railing"
				L["stool"] = "stool"
				L["chair"] = "chair"
				L["table"] = "Table Parts (2 Sheets)"
				L["light"] = "Light Fixture Parts, Tube (2 Sheets)"
				L["light2"] = "Light Fixture Parts, Bulb (2 Sheets)"
				L["light3"] = "Light Fixture Parts, floor (2 Sheets)"
				L["bed"] = "Bed (2 Sheets)"
				L["closet"] = "Closet (2 Sheets)"
				L["construct"] = "Wall Girders (2 Sheets)"
				L["pipef"] = "Pipe Frame (3 Sheets)"
				L["tcomputer"] = "Computer Terminal Frame (3 Sheets)"
				L["computer"] = "Console Frame (5 Sheets)"
				L["hcomputer"] = "Computer Frame (5 Sheets)"
				L["vending"] = "Vending Machine Frame (3 Sheets)"
		if (src?.material.material_flags & MATERIAL_CRYSTAL)
			L["smallwindow"] = "Thin Window"
			L["bigwindow"] = "Large Window (2 Sheets)"
			L["displaycase"] = "Display Case (3 Sheets)"
			if (istype(src.reinforcement))
				L["remetal"] = "Remove Reinforcement"
		if (src?.material.mat_id == "cardboard")
			L["c_box"] = "Cardboard Box (2 Sheets)"

		for(var/t in L)
			counter++
			t1 += text("<A href='?src=\ref[];make=[]'>[]</A>  ", src, t, L[t])
			if (counter > 2)
				counter = 1
			t1 += "<BR>"

		t1 += "</TT></HTML>"
		user.Browse(t1, "window=met_sheet")
		onclose(user, "met_sheet")
		return

	Topic(href, href_list)
		..()
		if (usr.restrained() || usr.stat)
			if(!isrobot(usr))
				return

		//Magtractor holding metal check
		var/atom/equipped = usr.equipped()
		if (equipped != src)
			if (istype(equipped, /obj/item/magtractor) && equipped:holding)
				if (equipped:holding != src)
					return
			else
				return
//You can't build! The if is to stop compiler warnings
#if defined(MAP_OVERRIDE_POD_WARS)
		if (src)
			boutput(usr, "<span class='alert'>What are you gonna do with this? You have a very particular set of skills, and building is not one of them...</span>")
			return
#endif

		if (href_list["make"])
			if (src.amount < 1)
				src.change_stack_amount(0) //Basically "clean up and pool"
				return

			var/a_type = null
			var/a_amount = 1
			var/a_cost = 1
			var/a_icon = null
			var/a_icon_state = null
			var/a_name = null
			var/a_callback = null

			switch(href_list["make"])
				if("rods")
					var/makerods = min(src.amount,25)
					var/rodsinput = input("Use how many sheets? (Get 2 rods for each sheet used)","Min: 1, Max: [makerods]",1) as num
					if (rodsinput < 1) return
					rodsinput = min(rodsinput,makerods)

					a_type = /obj/item/rods
					a_amount = rodsinput * 2
					a_cost = rodsinput
					a_icon = 'icons/obj/metal.dmi'
					a_icon_state = "rods"
					a_name = "rods"

				if("fl_tiles")
					var/maketiles = min(src.amount,20)
					var/tileinput = input("Use how many sheets? (Get 4 tiles for each sheet used)","Max: [maketiles]",1) as num
					if (tileinput < 1) return
					tileinput = min(tileinput,maketiles)

					a_type = /obj/item/tile
					a_amount = tileinput * 4
					a_cost = tileinput
					a_icon = 'icons/obj/metal.dmi'
					a_icon_state = "tile"
					a_name = "floor tiles"

				if("table")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/furniture_parts/table
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/furniture/table.dmi'
					a_icon_state = "table_parts"
					a_name = "table parts"

				if("light")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/light_parts
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/lighting.dmi'
					a_icon_state = "tube-fixture"
					a_name = "a light tube fixture"

				// Added (Convair880).
				if("light2")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/light_parts/bulb
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/lighting.dmi'
					a_icon_state = "bulb-fixture"
					a_name = "a light bulb fixture"

				// Added (Kyle).
				if("light3")
					if (!amount_check(2,usr)) return
					/obj/machinery/light/small/floor
					a_type = /obj/item/light_parts/floor
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/lighting.dmi'
					a_icon_state = "floor-fixture"
					a_name = "a floor light fixture"


				if("stool")
					a_type = /obj/stool
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/objects.dmi'
					a_icon_state = "stool"
					a_name = "a stool"

				if("railing")
					a_type = /obj/railing
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/objects.dmi'
					a_icon_state = "railing"
					a_name = "a railing"

				if("chair")
					a_type = /obj/stool/chair
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/objects.dmi'
					a_icon_state = "chair"
					a_name = "a chair"

				if("rack")
					a_type = /obj/item/furniture_parts/rack
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/metal.dmi'
					a_icon_state = "rack_parts"
					a_name = "rack parts"

				if("closet")
					if (!amount_check(2,usr)) return
					a_type = /obj/storage/closet
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/large_storage.dmi'
					a_icon_state = "closed"
					a_name = "a closet"

				if("c_box")
					if (!amount_check(2,usr)) return
					a_type = /obj/item/clothing/suit/cardboard_box
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/clothing/overcoats/item_suit_cardboard.dmi'
					a_icon_state = "c_box"
					a_name = "a cardboard box"

				if("pipef")
					if (!amount_check(3,usr)) return
					a_type = /obj/item/pipebomb/frame
					a_amount = 1
					a_cost = 3
					a_icon = 'icons/obj/items/assemblies.dmi'
					a_icon_state = "Pipe_Frame"
					a_name = "a pipe frame"

				if("bed")
					if (!amount_check(2,usr)) return
					a_type = /obj/stool/bed
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/objects.dmi'
					a_icon_state = "bed"
					a_name = "a bed"

				if("computer")
					if (!amount_check(5,usr)) return
					a_type = /obj/computerframe
					a_amount = 1
					a_cost = 5
					a_icon = 'icons/obj/computer_frame.dmi'
					a_icon_state = "0"
					a_name = "a console frame"

				if("hcomputer")
					if (!amount_check(5,usr)) return
					a_type = /obj/computer3frame
					a_amount = 1
					a_cost = 5
					a_icon = 'icons/obj/computer_frame.dmi'
					a_icon_state = "0"
					a_name = "a computer frame"

				if("tcomputer")
					if (!amount_check(3,usr)) return
					a_type = /obj/computer3frame/terminal
					a_amount = 1
					a_cost = 3
					a_icon = 'icons/obj/terminal_frame.dmi'
					a_icon_state = "0"
					a_name = "a terminal frame"

				if("vending")
					if (!amount_check(3,usr)) return
					a_type = /obj/machinery/vendingframe
					a_amount = 1
					a_cost = 3
					a_icon = 'icons/obj/vending.dmi'
					a_icon_state = "standard-frame"
					a_name = "a vending machine frame"
				if("construct")
					var/turf/T = get_turf(usr)
					var/area/A = get_area (usr)

					if (!istype(T, /turf/simulated/floor))
						boutput(usr, "<span class='alert'>You can't build girders here.</span>")
						return
					if (istype(A, /area/supply/spawn_point || /area/supply/delivery_point || /area/supply/sell_point))
						boutput(usr, "<span class='alert'>You can't build girders here.</span>")
						return
					if (!amount_check(2,usr)) return
					a_type = /obj/structure/girder
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/structures.dmi'
					a_icon_state = "girder"
					a_name = "a girder"

				if("smallwindow")
					if (src.reinforcement)
						a_type = map_settings ? map_settings.rwindows_thin : /obj/window/reinforced
					else
						a_type = map_settings ? map_settings.windows_thin : /obj/window
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/window.dmi'
					a_icon_state = "window"
					a_name = "a one-directional window"
					a_callback = /proc/window_reinforce_callback

				if("bigwindow")
					if (!amount_check(2,usr)) return
					if (src.reinforcement)
						a_type = map_settings ? map_settings.rwindows : /obj/window/reinforced

					else
						a_type = map_settings ? map_settings.windows : /obj/window
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/window.dmi'
					a_icon_state = "window"
					a_name = "a full window"
					a_callback = /proc/window_reinforce_full_callback

				if("displaycase")
					if (!amount_check(3,usr)) return
					a_type = /obj/displaycase
					a_amount = 1
					a_cost = 3
					a_icon = 'icons/obj/stationobjs.dmi'
					a_icon_state = "glassbox0"
					a_name = "a display case"

				if("retable")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/furniture_parts/table/reinforced
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/furniture/table_reinforced.dmi'
					a_icon_state = "table_parts"
					a_name = "reinforced table parts"

				if("industrialtable")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/furniture_parts/table/reinforced/industrial
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/furniture/table_industrial.dmi'
					a_icon_state = "table_parts"
					a_name = "industrial table parts"

				if("remetal")
					// what the fuck is this
					var/input = input("Use how many sheets?","Max: [src.amount]",1) as num
					if (input < 1) return
					input = min(input,src.amount)
					var/obj/item/sheet/C = new /obj/item/sheet(usr.loc)
					var/obj/item/rods/R = new /obj/item/rods(usr.loc)
					if(src.material)
						C.setMaterial(src.material)
					if(src.reinforcement)
						R.setMaterial(src.reinforcement)
					C.amount = input
					R.amount = input
					src.change_stack_amount(-input)
			if (a_type)
				actions.start(new /datum/action/bar/icon/build(src, a_type, a_cost, src.material, a_amount, a_icon, a_icon_state, a_name, a_callback), usr)


		return

/obj/item/sheet/steel

	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "sheet-metal"

	New()
		..()
		var/datum/material/M = getMaterial("steel")
		src.setMaterial(M)

	reinforced
		icon_state = "sheet-m-r_5"
		New()
			..()
			var/datum/material/M = getMaterial("steel")
			src.set_reinforcement(M)

/obj/item/sheet/glass

	icon_state = "sheet-g_5" //overriden in-game but shows up in map editors
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "sheet-glass"

	New()
		..()
		var/datum/material/M = getMaterial("glass")
		src.setMaterial(M)

	reinforced
		icon_state = "sheet-g-r_5"
		New()
			..()
			var/datum/material/M = getMaterial("steel")
			src.set_reinforcement(M)

	crystal

		New()
			..()
			var/datum/material/M = getMaterial("plasmaglass")
			src.setMaterial(M)

		reinforced
			icon_state = "sheet-g-r_5"
			New()
				..()
				var/datum/material/M = getMaterial("steel")
				src.set_reinforcement(M)

// RODS
/obj/item/rods
	name = "rods"
	desc = "A set of metal rods, useful for constructing grilles and other objects, and decent for hitting people."
	icon = 'icons/obj/metal.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rods_5"
	item_state = "rods"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = W_CLASS_NORMAL
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	m_amt = 1875
	max_stack = 50
	stamina_damage = 20
	stamina_cost = 16
	stamina_crit_chance = 30
	rand_pos = 1
	inventory_counter_enabled = 1

	New()
		..()
		SPAWN_DBG(0)
			update_stack_appearance()
		BLOCK_SETUP(BLOCK_ROD)

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/rods/))
			return 0
		var/obj/item/rods/S = O
		if (!S.material || !src.material)
			return 0
		if (S.material.type != src.material.type)
			return 0
		if (!isSameMaterial(S.material, src.material))
			return 0
		return 1

	update_stack_appearance()
		if (amount <= 10)
			icon_state = "rods_1"
		else if (amount <= 20)
			icon_state = "rods_2"
		else if (amount <= 30)
			icon_state = "rods_3"
		else if (amount <= 40)
			icon_state = "rods_4"
		else
			icon_state = "rods_5"
		src.inventory_counter.update_number(amount)

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins gathering up [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		update_stack_appearance()
		boutput(user, "<span class='notice'>You finish gathering rods.</span>")

	examine()
		. = ..()
		. += "There are [src.amount] rod\s on this stack."

	attack_hand(mob/user as mob)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = round(input("How many rods do you want to take from the stack?","Stack of [src.amount]",1) as num)
			var/obj/item/rods/new_stack = split_stack(splitnum)
			if (!istype(new_stack))
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
			boutput(user, "<span class='notice'>You take [splitnum] rods from the stack, leaving [src.amount] rods behind.</span>")
		else
			..(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (isweldingtool(W))
			if(src.amount < 2)
				boutput(user, "<span class='alert'>You need at least two rods to make a material sheet.</span>")
				return
			if (!istype(src.loc,/turf/))
				if (issilicon(user))
					boutput(user, "<span class='alert'>Hardcore as it sounds, smelting parts of yourself off isn't big or clever.</span>")
				else
					boutput(user, "<span class='alert'>You should probably put the rods down first.</span>")
				return
			if(!W:try_weld(user, 1))
				return

			var/weldinput = 1
			if (src.amount > 3)
				var/makemetal = round(src.amount / 2)
				boutput(user, "<span class='notice'>You could make up to [makemetal] sheets by welding this stack.</span>")
				weldinput = input("How many sheets do you want to make?","Welding",1) as num
				makemetal = round(src.amount / 2) // could have changed during input()
				if (weldinput < 1) return
				if (weldinput > makemetal) weldinput = makemetal
			var/obj/item/sheet/M = new /obj/item/sheet/steel(user.loc)
			if(src.material) M.setMaterial(src.material)
			M.amount = weldinput
			src.change_stack_amount(-(weldinput * 2))

			user.visible_message("<span class='alert'><B>[user]</B> welds the rods together into sheets.</span>")
			update_stack_appearance()
			if(src.amount < 1)	qdel(src)
			return

		if (istype(W, /obj/item/rods))
			// stack_item won't succeed if the materials differ but we want a specific error message
			if (W.material && src.material && !isSameMaterial(W.material, src.material))
				boutput(user, "<span class='alert'>You can't mix 2 stacks of different metals!</span>")
				return
			var/success = stack_item(W)
			if (!success)
				boutput(user, "<span class='alert'>You can't put any more rods in this stack!</span>")
			else
				if(!user.is_in_hands(src))
					user.put_in_hand(src)
				if(isrobot(user))
					boutput(user, "<span class='notice'>You add [success] rods to the stack. It now has [W.amount] rods.</span>")
				else
					boutput(user, "<span class='notice'>You add [success] rods to the stack. It now has [src.amount] rods.</span>")
			return

		if (istype(W, /obj/item/organ/head))
			user.visible_message("<span class='alert'><B>[user] impales [W.name] on a spike!</B></span>")
			var/obj/head_on_spike/HS = new /obj/head_on_spike(get_turf(src))
			HS.heads += W
			user.u_equip(W)
			W.set_loc(HS)
			/*	Can't do this because it colours the heads as well as the spike itself.
			if(src.material) HS.setMaterial(src.material)*/
			change_stack_amount(-1)
		return

	attack_self(mob/user as mob)
		if (user.getStatusDuration("weakened") | user.getStatusDuration("stunned"))
			return
		if (istype(user.loc, /obj/vehicle/segway))
			var/obj/vehicle/segway/S = user.loc
			if (S.joustingTool == src) // already raised as a lance, lower it
				user.visible_message("[user] lowers the rod lance.", "You lower the rod. Everybody lets out a sigh of relief.")
				S.joustingTool = null
			else // Lances up!
				user.visible_message("[user] raises a rod as a lance!", "You raise the rod into jousting position.")
				S.joustingTool = src
		else if (locate(/obj/grille, user.loc))
			for(var/obj/grille/G in user.loc)
				if (G.ruined)
					G.health = G.health_max
					G.set_density(1)
					G.ruined = 0
					G.update_icon()
					if(src.material)
						G.setMaterial(src.material)
					boutput(user, "<span class='notice'>You repair the broken grille.</span>")
					src.change_stack_amount(-1)
				else
					boutput(user, "<span class='alert'>There is already a grille here.</span>")
				break
		else
			if (src.amount < 2)
				boutput(user, "<span class='alert'>You need at least two rods to build a grille.</span>")
				return
			user.visible_message("<span class='notice'><b>[user]</b> begins building a grille.</span>")
			var/turf/T = user.loc
			SPAWN_DBG(1.5 SECONDS)
				if (T == user.loc && !user.getStatusDuration("weakened") && !user.getStatusDuration("stunned") && src.amount >= 2)
					var/atom/G = new /obj/grille(user.loc)
					G.setMaterial(src.material)
					src.change_stack_amount(-2)
					logTheThing("station", user, null, "builds a grille (<b>Material:</b> [G.material && G.material.mat_id ? "[G.material.mat_id]" : "*UNKNOWN*"]) at [log_loc(user)].")
		src.add_fingerprint(user)
		return

/obj/head_on_spike
	name = "head on a spike"
	desc = "A human head impaled on a spike, dim-eyed, grinning faintly, blood blackening between the teeth."
	icon = 'icons/obj/metal.dmi'
	icon_state = "head_spike"
	anchored = 0
	density = 1
	var/list/heads = list()
	var/head_offset = 0 //so the ones at the botton don't teleport upwards when a head is removed
	var/bloodiness = 0 //

	New()
		..()
		SPAWN_DBG(0) //wait for the head to be added
			update()

	attack_hand(mob/user as mob)
		if(heads.len)
			var/obj/item/organ/head/head = heads[heads.len]

			user.visible_message("<span class='alert'><B>[user.name] pulls [head.name] off of the spike!</B></span>")
			head.set_loc(user.loc)
			head.Attackhand(user)
			head.add_fingerprint(user)
			head.pixel_x = rand(-8,8)
			head.pixel_y = rand(-8,8)
			heads -= head

			if(!heads.len)
				head_offset = 0
			else
				head_offset++

			src.update()
		else
			..(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (isweldingtool(W))
			if(!src.anchored && !istype(src.loc,/turf/simulated/floor) && !istype(src.loc,/turf/unsimulated/floor))
				boutput(user, "<span class='alert'>There's nothing to weld that to.</span>")
				return

			if(!W:try_weld(user, 1))
				return

			if(!src.anchored) user.visible_message("<span class='alert'><B>[user.name] welds the [src.name] to the floor.</B></span>")
			else user.visible_message("<span class='alert'><B>[user.name] cuts the [src.name] free from the floor.</B></span>")
			src.anchored = !(src.anchored)

			update()

		else if (istype(W,/obj/item/organ/head))
			if(!has_space())
				boutput(user, "<span class='alert'>There isn't room on that spike for another head.</span>")
				return

			if(!heads.len) user.visible_message("<span class='alert'><B>[user.name] impales a [W.name] on the [src.name]!</B></span>")
			else user.visible_message("<span class='alert'><B>[user.name] adds a [W.name] to the spike!</B></span>")

			if(head_offset > 0) head_offset--

			heads += W
			user.u_equip(W)
			W.set_loc(src)

			src.update()

		return

	proc/update()
		src.overlays = null

		if((heads.len < 3 && head_offset > 0) || heads.len == 0)
			src.overlays += image('icons/obj/metal.dmi',"head_spike_blood")

		switch(heads.len) //fuck it
			if(0)
				src.name = "bloody spike"
				src.desc = "A bloody spike."
			if(1)
				/*	This shit doesn't work ugh
				src.name = "[heads[1]:donor] on a spike"*/
				var/obj/item/organ/head/head1 = heads[1]
				src.name = "[head1.name] on a spike"
				src.desc = "A human head impaled on a spike, dim-eyed, grinning faintly, blood blackening between the teeth."
			if(2)
				src.name = "heads on a spike"
				var/obj/item/organ/head/head1 = heads[1]
				var/obj/item/organ/head/head2 = heads[2]
				src.desc = "The heads of [head1.donor] and [head2.donor] impaled on a spike."
				/*	This shit doesn't work ugh
				src.desc = "The heads of [heads[1]:donor] and [heads[2]:donor] impaled on a spike."*/
			if(3)
				src.name = "heads on a spike"
				var/obj/item/organ/head/head1 = heads[1]
				var/obj/item/organ/head/head2 = heads[2]
				var/obj/item/organ/head/head3 = heads[3]
				src.desc = "The heads of [head1.donor], [head2.donor] and [head3.donor] impaled on a spike."
				/*	This shit doesn't work ugh
				src.desc = "The heads of [heads[1]:donor], [heads[2]:donor] and [heads[3]:donor] impaled on a spike."*/


		if(heads.len > 0)
			var/pixely = 8 - 8*head_offset - length(8*heads)
			for(var/obj/item/organ/head/H in heads)
				H.pixel_x = 0
				H.pixel_y = pixely
				pixely += 8
				H.set_dir(SOUTH)
				src.overlays += H

			src.overlays += image('icons/obj/metal.dmi',"head_spike_flies")

		if(anchored)
			src.overlays += image('icons/obj/metal.dmi',"head_spike_weld")

		return


	proc/has_space()
		if(heads.len < 3) return 1

		return 0

	custom_suicide = 1
	suicide(var/mob/living/carbon/human/user as mob)
		if (!istype(user) || !src.user_can_suicide(user))
			return 0
		if (!src.has_space() || !user.organHolder)//!hasvar(user,"organHolder")) STOP USING HASVAR YOU UTTER FUCKWITS
			return 0

		user.visible_message("<span class='alert'><b>[user] headbutts the spike, impaling [his_or_her(user)] head on it!</b></span>")
		user.TakeDamage("head", 50, 0)
		user.changeStatus("stunned", 50 SECONDS)
		playsound(src.loc, "sound/impact_sounds/Flesh_Stab_1.ogg", 50, 1)
		if(prob(40)) user.emote("scream")

		SPAWN_DBG(1 SECOND)
			user.visible_message("<span class='alert'><b>[user] tears [his_or_her(user)] body away from the spike, leaving [his_or_her(user)] head behind!</b></span>")
			var/obj/head = user.organHolder.drop_organ("head")
			head.set_loc(src)
			heads += head
			src.update()
			make_cleanable( /obj/decal/cleanable/blood,user.loc)
			playsound(src.loc, "sound/impact_sounds/Flesh_Break_2.ogg", 50, 1)

		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0

		return 1


/obj/item/rods/steel

	New()
		..()
		var/datum/material/M = getMaterial("steel")
		src.setMaterial(M)

// TILES

/obj/item/tile
	name = "floor tile"
	desc = "They keep the floor in a good and walkable condition."
	icon = 'icons/obj/metal.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "tile_5"
	item_state = "tile"
	w_class = W_CLASS_NORMAL
	m_amt = 937.5
	throw_speed = 3
	throw_range = 20
	force = 6.0
	throwforce = 5.0
	max_stack = 80
	stamina_damage = 25
	stamina_cost = 15
	stamina_crit_chance = 15
	tooltip_flags = REBUILD_DIST
	inventory_counter_enabled = 1

	New(make_amount = 0)
		..()
		src.pixel_x = rand(0, 14)
		src.pixel_y = rand(0, 14)
		SPAWN_DBG(0)
			update_stack_appearance()
			src.inventory_counter?.update_number(amount)
		return

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/tile/))
			return 0
		var/obj/item/tile/S = O
		if (!S.material || !src.material)
			return 0
		if (!isSameMaterial(S.material, src.material))
			return 0
		return 1

	update_stack_appearance()
		if (amount <= 10)
			icon_state = "tile_1"
		else if (amount <= 20)
			icon_state = "tile_2"
		else if (amount <= 30)
			icon_state = "tile_3"
		else if (amount <= 40)
			icon_state = "tile_4"
		else if (amount <= 50)
			icon_state = "tile_5"
		else if (amount <= 60)
			icon_state = "tile_6"
		else if (amount <= 70)
			icon_state = "tile_7"
		else
			icon_state = "tile_8"

	get_desc(dist)
		if (dist <= 3)
			. += "<br>There are [src.amount] tile[s_es(src.amount)] left on the stack."

	attack_hand(mob/user as mob)

		if ((user.r_hand == src || user.l_hand == src))
			src.add_fingerprint(user)
			var/obj/item/tile/F = split_stack(1)
			if (!istype(F))
				return
			tooltip_rebuild = 1
			user.put_in_hand_or_drop(F)
		else
			..()
		return

	attack_self(mob/user as mob)

		if (user.stat)
			return
		var/T = user.loc
		if (!( istype(T, /turf) ))
			boutput(user, "<span class='notice'>You must be on the ground!</span>")
			return
		else
			var/S = T
			if (!( istype(S, /turf/space) || istype(S, /turf/simulated/floor/metalfoam)))
				boutput(user, "You cannot build on or repair this turf!")
				return
			else
				src.build(S)
				tooltip_rebuild = 1
		src.add_fingerprint(user)
		return

	attackby(obj/item/tile/W as obj, mob/user as mob)

		if (!( istype(W, /obj/item/tile) ))
			return
		if (W.material && src.material && !isSameMaterial(W.material, src.material))
			boutput(user, "<span class='alert'>You can't mix 2 stacks of different materials!</span>")
			return
		var/success = stack_item(W)
		if (!success)
			boutput(user, "<span class='alert'>You can't put any more tiles in this stack!</span>")
			return
		if(!user.is_in_hands(src))
			user.put_in_hand(src)
		if(isrobot(user))
			boutput(user, "<span class='notice'>You add [success] tiles to the stack. It now has [W.amount] tiles.</span>")
		else
			boutput(user, "<span class='notice'>You add [success] tiles to the stack. It now has [src.amount] tiles.</span>")
		tooltip_rebuild = 1
		if (!W.disposed)
			W.add_fingerprint(user)
			W.tooltip_rebuild = 1
		return

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins stacking [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking tiles.</span>")

	proc/build(turf/S as turf)
//for now, any turf can't be built on.
#if defined(MAP_OVERRIDE_POD_WARS)
		boutput(usr, "you can't build in this mode, you don't know how or something...")
		return
#else
		if (src.amount < 1)
			return FALSE
		var/turf/simulated/floor/W = S.ReplaceWithFloor()
		if (W) //Wire: Fix for: Cannot read null.icon_old
			W.inherit_area()
			if (!W.icon_old)
				W.icon_old = "floor"
			W.to_plating()

		if(ismob(usr) && !istype(src.material, /datum/material/metal/steel))
			logTheThing("station", usr, null, "constructs a floor (<b>Material:</b>: [src.material && src.material.name ? "[src.material.name]" : "*UNKNOWN*"]) at [log_loc(S)].")
		if(src.material)
			W.setMaterial(src.material)
		src.change_stack_amount(-1)
		return TRUE
#endif

/obj/item/tile/steel

	New()
		..()
		var/datum/material/M = getMaterial("steel")
		src.setMaterial(M)

/obj/item/sheet/electrum
	New()
		..()
		setMaterial(getMaterial("electrum"))

	change_stack_amount(var/use_amount)
		if (!isnum(use_amount))
			return
		if (isrobot(usr))
			var/mob/living/silicon/robot/R = usr
			R.cell.use(use_amount * 200)

// kinda needed for some stuff I'm making - haine
/obj/item/sheet/steel/fullstack
	amount = 50
/obj/item/sheet/steel/reinforced/fullstack
	amount = 50
/obj/item/sheet/glass/fullstack
	amount = 50
/obj/item/sheet/glass/reinforced/fullstack
	amount = 50
/obj/item/sheet/glass/crystal/fullstack
	amount = 50
/obj/item/sheet/glass/crystal/reinforced/fullstack
	amount = 50
/obj/item/rods/steel/fullstack
	amount = 50
/obj/item/tile/steel/fullstack
	amount = 80
