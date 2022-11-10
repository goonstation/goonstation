/*
CONTAINS:
RODS
METAL
REINFORCED METAL
MATERIAL

*/

// RODS
/obj/item/rods
	name = "rods"
	desc = "A set of metal rods, useful for constructing grilles and other objects, and decent for hitting people."
	icon = 'icons/obj/metal.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rods"
	flags = FPRINT | TABLEPASS| CONDUCT
	health = 3
	w_class = W_CLASS_NORMAL
	force = 9
	throwforce = 15
	throw_speed = 5
	throw_range = 20
	m_amt = 1875
	max_stack = 50
	stamina_damage = 10
	stamina_cost = 15
	stamina_crit_chance = 25

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins gathering up metal rods!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish gathering rods.</span>")

	examine()
		. = ..()
		. += "There are [amount] rod\s in this stack."

	attack_hand(mob/user)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = round(input("How many rods do you want to take from the stack?","Stack of [src.amount]",1) as num)
			var/diff = src.amount - splitnum
			if (splitnum >= amount || splitnum < 1 || !isnum_safe(splitnum))
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			boutput(user, "<span class='notice'>You take [splitnum] rods from the stack, leaving [diff] rods behind.</span>")
			src.amount = diff
			var/obj/item/rods/new_stack = new src.type(user.loc, diff)
			if(src.material) new_stack.setMaterial(src.material)
			new_stack.amount = splitnum
			new_stack.Attackhand(user)
			new_stack.add_fingerprint(user)
		else
			..(user)

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			if(src.amount < 2)
				boutput(user, "<span class='alert'>You need at least two rods to make a metal sheet.</span>")
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
				weldinput = input("How many sheets of metal do you want to make?","Welding",1) as num
				if (weldinput < 1 || !isnum_safe(weldinput)) return
				if (weldinput > makemetal) weldinput = makemetal
			var/obj/item/sheet/metal/M = new /obj/item/sheet/metal(user.loc)
			if(src.material) M.setMaterial(src.material)
			M.amount = weldinput
			src.consume_rods(weldinput * 2)

			user.visible_message("<span class='alert'><B>[user]</B> welds the rods together into metal.</span>")
			return
		if (istype(W, /obj/item/rods))
			var/obj/item/rods/R = W
			if (R.amount == src.max_stack)
				boutput(user, "<span class='alert'>You can't put any more rods in this stack!</span>")
				return
			if (W.material && src.material && !isSameMaterial(W.material, src.material))
				boutput(user, "<span class='alert'>You can't mix 2 stacks of different metals!</span>")
				return
			if (R.amount + src.amount > src.max_stack)
				src.amount = R.amount + src.amount - src.max_stack
				R.amount = src.max_stack
				boutput(user, "<span class='notice'>You add the rods to the stack. It now has [R.amount] rods.</span>")
			else
				R.amount += src.amount
				boutput(user, "<span class='notice'>You add [R.amount] rods to the stack. It now has [R.amount] rods.</span>")
				qdel(src)
				return
		return

	attack_self(mob/user as mob)
		if (user.weakened | user.getStatusDuration("stunned"))
			return
		if (locate(/obj/grille, user.loc))
			for(var/obj/grille/G in user.loc)
				if (G.destroyed)
					G.health = G.health_max
					G.set_density(1)
					G.destroyed = 0
					G.UpdateIcon()
					if(src.material)
						G.setMaterial(src.material)
					boutput(user, "<span class='notice'>You repair the broken grille.</span>")
					src.amount--
				else
					boutput(user, "<span class='alert'>There is already a grille here.</span>")
				break
		else
			if (src.amount < 2)
				boutput(user, "<span class='alert'>You need at least two rods to build a grille.</span>")
				return
			user.visible_message("<span class='notice'><b>[user]</b> begins building a grille.</span>")
			var/turf/T = user.loc
			SPAWN(1.5 SECONDS)
				if (T == user.loc && !user.weakened && !user.getStatusDuration("stunned"))
					src.amount -= 2
					var/atom/G = new /obj/grille(user.loc)
					G.setMaterial(src.material)
					logTheThing(LOG_STATION, user, "builds a Grille in [user.loc.loc] ([log_loc(user)])")
					G.add_fingerprint(user)
		if (src.amount < 1)
			qdel(src)
			return
		src.add_fingerprint(user)
		return

/obj/item/rods/five
	amount = 5

/obj/item/rods/fifty
	amount = 50

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
			var/splitnum = round(input("How many sheets do you want to take from the stack?","Stack of [src.amount]",1) as num)
			var/diff = src.amount - splitnum
			if (splitnum >= amount || splitnum < 1 || !isnum_safe(splitnum))
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			boutput(user, "<span class='notice'>You take [splitnum] sheets from the stack, leaving [diff] sheets behind.</span>")
			src.amount = diff
			var/obj/item/sheet/metal/new_stack = new src.type(user.loc, diff)
			if(src.material) new_stack.setMaterial(src.material)
			new_stack.amount = splitnum
			new_stack.Attackhand(user)
			new_stack.add_fingerprint(user)
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
					var/makerods = round(src.amount * 2)
					if (makerods > 50) makerods = 50
					boutput(usr, "<span class='notice'>You could make up to [makerods] rods with the amount of metal you have.</span>")
					var/rodsinput = input("How many rods do you want to make? (Minimum of 2)","Metal Crafting",1) as num
					if (rodsinput < 2 || !isnum_safe(rodsinput)) return
					if (rodsinput > makerods) rodsinput = makerods

					var/obj/item/rods/R = new /obj/item/rods(usr.loc)
					R.setMaterial(src.material)
					R.amount = rodsinput
					src.amount -= round(rodsinput / 2)
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
					var/maketiles = round(src.amount * 4)
					if (maketiles > 80) maketiles = 80
					boutput(usr, "<span class='notice'>You could make up to [maketiles] tiles with the amount of metal you have.</span>")
					var/tileinput = input("How many tiles do you want to make? (Minimum of 4)","Metal Crafting",1) as num
					if (tileinput < 4 || !isnum_safe(tileinput)) return
					if (tileinput > maketiles) tileinput = maketiles

					var/obj/item/tile/R = new /obj/item/tile( usr.loc )
					R.setMaterial(src.material)
					R.amount = tileinput
					src.amount -= round(tileinput / 4)
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
			var/splitnum = round(input("How many sheets do you want to take from the stack?","Stack of [src.amount]",1) as num)
			var/diff = src.amount - splitnum
			if (splitnum >= amount || splitnum < 1 || !isnum_safe(splitnum))
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			boutput(user, "<span class='notice'>You take [splitnum] sheets from the stack, leaving [diff] sheets behind.</span>")
			src.amount = diff
			var/obj/item/sheet/r_metal/new_stack = new src.type(user.loc, diff)
			if(src.material) new_stack.setMaterial(src.material)
			new_stack.amount = splitnum
			new_stack.Attackhand(user)
			new_stack.add_fingerprint(user)
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
