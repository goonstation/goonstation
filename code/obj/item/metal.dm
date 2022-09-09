/*
CONTAINS:
METAL
REINFORCED METAL
MATERIAL

*/

// METAL SHEET
/obj/item/sheet/metal
	name = "metal"
	icon = 'icons/obj/metal.dmi'
	icon_state = "sheet"
	desc = "A heavy sheet of metal."
	m_amt = 3750
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | CONDUCT
	desc = "A collection of thick metal, from which one can construct a multitude of objects."
		//cogwerks - burn vars
	burn_point = 8000
	burn_output = 8000
	burn_possible = 1
	health = 8
	burn_type = 1

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins stacking metal sheets!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking metal.</span>")

	metal/examine()
		. = ..()
		. += "There are [src.amount] metal sheet\s on the stack."

	attack_hand(mob/user)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = tgui_input_number(user, "How many sheets do you want to take from the stack?", "Stack of [src.amount]", 1, src.max_stack - 1, 1)
			splitnum = min(splitnum, src?.amount - 1)
			var/obj/item/sheet/metal/new_stack = src.split_stack(splitnum)
			if (!new_stack)
				return
			new_stack.set_loc(user.loc)
			user.put_in_hand_or_drop(new_stack)
		else
			..(user)

	attackby(obj/item/sheet/metal/W, mob/user)
		if (!( istype(W, /obj/item/sheet/metal) ))
			return
		if (W.material && src.material && !isSameMaterial(W.material, src.material))
			boutput(user, "<span class='alert'>You can't mix 2 stacks of different metals!</span>")
			return
		if (W.amount >= src.max_stack)
			boutput(user, "<span class='alert'>You can't put any more sheets in this stack!</span>")
			return
		if (W.amount + src.amount > src.max_stack)
			src.amount = W.amount + src.amount - src.max_stack
			W.amount = src.max_stack
			boutput(user, "<span class='notice'>You add the metal to the stack. It now has [W.amount] sheets.</span>")
		else
			W.amount += src.amount
			boutput(user, "<span class='notice'>You add the metal to the stack. It now has [W.amount] sheets.</span>")
			qdel(src)
			return
		return

	attack_self(mob/user as mob)
		var/t1 = text("<HTML><HEAD></HEAD><TT>Amount Left: [] <BR>", src.amount)
		var/counter = 1
		var/list/L = list(  )
		L["fl_tiles"] = "Floor Tiles (4 per Sheet)"
		L["rods"] = "Metal Rods (2 per Sheet)"
		L["rack"] = "Rack Parts"
		L["reinforced"] = "Reinforced Metal (Needs 2 Sheets)"
		L["table"] = "Table Parts (Needs 2 Sheets)<BR>"
		L["light"] = "Light Fixture Parts (Needs 2 Sheets)<BR>"
		L["stool"] = "stool"
		L["chair"] = "chair"
		L["railing"] = "railing"
		L["bed"] = "Bed (Needs 2 Sheets)"
		L["closet"] = "Closet (Needs 2 Sheets)<BR>"
		L["construct"] = "Wall Girders (Needs 2 Sheets)"
		L["pipef"] = "Pipe Frame (Needs 3 Sheets)"
		L["tcomputer"] = "Computer Terminal Frame (Needs 3 Sheets)"
		L["computer"] = "Console Frame (Needs 5 Sheets)"
		L["hcomputer"] = "Computer Frame (Needs 5 Sheets)"

		for(var/t in L)
			counter++
			t1 += text("<A href='?src=\ref[];make=[]'>[]</A>  ", src, t, L[t])
			if (counter > 2)
				counter = 1
			t1 += "<BR>"
		t1 += "</TT></HTML>"
		user << browse(t1, "window=met_sheet")
		onclose(user, "met_sheet")
		return

	Topic(href, href_list)
		..()
		if ((usr.restrained() || usr.stat || usr.equipped() != src))
			if(!isrobot(usr))
				return
		if (href_list["make"])
			if (src.amount < 1)
				qdel(src)
				return
			switch(href_list["make"])
				if("rods")
					var/amt = tgui_input_number(usr, "How many sheets do you want to use? (2 rods per sheet)", "Metal Crafting", 1, 25, 1) // rods have max stack of 50
					amt = min(amt, src?.amount)
					if (!amt)
						return

					var/obj/item/rods/R = new /obj/item/rods(usr.loc)
					R.setMaterial(src.material)
					R.amount = amt * 2
					src.amount -= amt
				if("table")
					if (src.amount < 2)
						boutput(usr, text("<span class='alert'>You need at least two metal to build table parts.</span>"))
						return
					src.amount -= 2
					var/atom/A = new /obj/item/furniture_parts/table( usr.loc )
					A.setMaterial(src.material)
				if("light")
					if (src.amount < 2)
						boutput(usr, text("<span class='alert'>You need at least two metal to build a light fixture.</span>"))
						return
					src.amount -= 2
					var/atom/A = new /obj/item/light_parts( usr.loc )
					A.setMaterial(src.material)
				if("stool")
					src.amount--
					var/atom/A = new /obj/stool( usr.loc )
					A.setMaterial(src.material)
				if("chair")
					src.amount--
					var/obj/stool/chair/C = new /obj/stool/chair( usr.loc )
					C.setMaterial(src.material)
					C.set_dir(usr.dir)
					if (C.dir == NORTH)
						C.layer = 5 // TODO layer
				if("railing")
					src.amount--
					var/obj/railing/R = new /obj/railing( usr.loc )
					C.setMaterial(src.material)
					C.set_dir(usr.dir)
				if("rack")
					src.amount--
					var/atom/A = new /obj/item/furniture_parts/rack_parts( usr.loc )
					A.setMaterial(src.material)
				if("reinforced")
					if (src.amount < 2)
						boutput(usr, text("<span class='alert'>You need at least two metal to make a reinforced metal sheet.</span>"))
						return
					src.amount -= 2
					var/obj/item/sheet/r_metal/C = new /obj/item/sheet/r_metal( usr.loc )
					C.setMaterial(src.material)
					C.amount = 1
				if("closet")
					if (src.amount < 2)
						boutput(usr, text("<span class='alert'>You need at least two metal to build a closet.</span>"))
						return
					src.amount -= 2
					var/atom/A = new /obj/storage/closet( usr.loc )
					A.setMaterial(src.material)
					logTheThing(LOG_STATION, usr, "builds a Closet in [usr.loc.loc] ([log_loc(usr)])")
				if("fl_tiles")
					var/amt = tgui_input_number(usr, "How many sheets do you want to use? (4 tiles per sheet)", "Metal Crafting", 1, 20, 1) // sheets have max stack of 80
					amt = min(amt, src?.amount)
					if (!amt)
						return

					var/obj/item/tile/R = new /obj/item/tile( usr.loc )
					R.setMaterial(src.material)
					R.amount = amt * 4
					src.amount -= amt
				if("pipef")
					if (src.amount < 3)
						boutput(usr, text("<span class='alert'>You need at least three metal to build pipe frames.</span>"))
						return
					src.amount -= 3
					var/atom/A = new /obj/item/pipebomb/frame( usr.loc )
					A.setMaterial(src.material)
				if("bed")
					if (src.amount < 2)
						boutput(usr, text("<span class='alert'>You need at least two metal to build a bed.</span>"))
						return
					src.amount -= 2
					var/atom/A = new /obj/stool/bed( usr.loc )
					A.setMaterial(src.material)
				if("computer")
					if(src.amount < 5)
						boutput(usr, text("<span class='alert'>You need at least five metal to make a console frame.!</span>"))
						return
					src.amount -= 5
					var/atom/A = new /obj/computerframe( usr.loc )
					A.setMaterial(src.material)
					logTheThing(LOG_STATION, usr, "builds a Console Frame in [usr.loc.loc] ([log_loc(usr)])")
				if("hcomputer")
					if(src.amount < 5)
						boutput(usr, text("<span class='alert'>You need at least five metal to make a computer frame.</span>"))
						return
					src.amount -= 5
					var/atom/A = new /obj/computer3frame( usr.loc )
					A.setMaterial(src.material)
					logTheThing(LOG_STATION, usr, "builds a Computer Frame in [usr.loc.loc] ([log_loc(usr)])")
				if("tcomputer")
					if(src.amount < 3)
						boutput(usr, text("<span class='alert'>You need at least three metal to make a terminal computer frame.</span>"))
						return
					src.amount -= 3
					var/atom/A = new /obj/computer3frame/terminal( usr.loc )
					A.setMaterial(src.material)
					logTheThing(LOG_STATION, usr, "builds a Terminal Frame in [usr.loc.loc] ([log_loc(usr)])")
				if("construct")
					if (src.amount < 2)
						boutput(usr, text("<span class='alert'>You need at least two metal to build wall girders.</span>"))
						return
					boutput(usr, "<span class='notice'>Building wall girders ...</span>")
					var/turf/location = usr.loc
					sleep(2 SECONDS)
					if ((usr.loc == location))
						if (!istype(location, /turf/simulated/floor))
							return

						src.amount -= 2
						var/atom/A = new /obj/structure/girder(location)
						A.setMaterial(src.material)
						logTheThing(LOG_STATION, usr, "builds Wall Girders in [usr.loc.loc] ([log_loc(usr)])")

			if (src.amount <= 0)
				usr << browse(null, "window=met_sheet")
				onclose(usr, "met_sheet")
				usr.u_equip(src)
				boutput(usr, "<span class='alert'>You use up the last of your metal.</span>")
				qdel(src)


				return
		SPAWN( 0 )
			src.attack_self(usr)
			return
		return

// REINFORCED METAL SHEET
/obj/item/sheet/r_metal
	name = "reinforced metal"
	desc = "A very heavy sheet of metal."
	icon = 'icons/obj/metal.dmi'
	icon_state = "sheet-r"
	force = 5
	item_state = "sheet-metal"
	m_amt = 7500
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | CONDUCT
	desc = "A collection of reinforced metal, used for making thicker walls and stronger metal objects."
		//cogwerks - burn vars
	burn_point = 10000
	burn_output = 10000
	burn_possible = 1
	health = 8
	burn_type = 1

	attack_self(mob/user as mob)
		var/t1 = text("<HTML><HEAD></HEAD><TT>Amount Left: [] <BR>", src.amount)
		var/counter = 1
		var/list/L = list(  )
		L["table"] = "table parts (2 metal)"
		L["metal"] = "2x metal sheet (1 metal)<BR>"
		for(var/t in L)
			counter++
			t1 += text("<A href='?src=\ref[];make=[]'>[]</A>  ", src, t, L[t])
			if (counter > 2)
				counter = 1
			t1 += "<BR>"
		t1 += "</TT></HTML>"
		user << browse(t1, "window=met_sheet")
		onclose(user, "met_sheet")
		return

	attack_hand(mob/user)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = tgui_input_number(user, "How many sheets do you want to take from the stack?", "Stack of [src.amount]", 1, src.max_stack - 1, 1)
			splitnum = min(splitnum, src?.amount - 1)
			var/obj/item/sheet/r_metal/new_stack = src.split_stack(splitnum)
			if (!new_stack)
				return
			new_stack.set_loc(user.loc)
			user.put_in_hand_or_drop(new_stack)
		else
			..(user)

	attackby(obj/item/sheet/r_metal/W, mob/user)
		if (!( istype(W, /obj/item/sheet/r_metal) ))
			return
		if (W.material && src.material && !isSameMaterial(W.material, src.material))
			boutput(user, "<span class='alert'>You can't mix 2 stacks of different metals!</span>")
			return
		if (W.amount >= src.max_stack)
			return
		if (W.amount + src.amount > src.max_stack)
			src.amount = W.amount + src.amount - src.max_stack
			W.amount = src.max_stack
		else
			W.amount += src.amount
			qdel(src)
			return
		return


	Topic(href, href_list)
		..()
		if ((usr.restrained() || usr.stat || usr.equipped() != src))
			return
		if (href_list["make"])
			if (src.amount < 1)
				qdel(src)
				return
			switch(href_list["make"])
				if("table")
					if (src.amount < 2)
						boutput(usr, text("<span class='alert'>You haven't got enough metal to build the reinforced table parts!</span>"))
						return
					src.amount -= 2
					var/atom/A = new /obj/item/furniture_parts/table/reinforced( usr.loc )
					if(src.material) A.setMaterial(src.material)
				if("metal")
					if (src.amount < 1)
						boutput(usr, text("<span class='alert'>You haven't got enough metal to build the metal sheets!</span>"))
						return
					src.amount -= 1
					var/obj/item/sheet/metal/C = new /obj/item/sheet/metal( usr.loc )
					if(src.material) C.setMaterial(src.material)
					C.amount = 2

			if (src.amount <= 0)
				usr << browse(null, "window=met_sheet")
				onclose(usr, "met_sheet")
				usr.u_equip(src)
				qdel(src)


				return
		SPAWN( 0 )
			src.attack_self(usr)
			return
		return
