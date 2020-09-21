/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-DYNAMIC ASSEMBLY SYSTEM BY ZEWAKA-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/*
Contains:
DynAssembly Parent
Instrument DynAssemblies
For fruit DynAssemblies see: fruithat.dm
For hairball DynAssemblies see: jonescity.dm
*/

//okay this might be shit but it works okay, feel free to un-shit it

//Let's start with the basics.
//To create a dynamic assembly, you create the dynassembly object by calling an attackby on your starting item, then running newpart with 1st arg being src
//Then, the 2nd arg is the part you are attacking with or adding. Finally, you set firstrun to true because well its the 1st run.
//For an example of the above, see /obj/item/musicpart/attackby
//To add stuff to a dynamic assembly, you hit it with another obj in validparts. See: attackby
//If you are not happy with your in progress assembly, wrench it.
//If you are happy and you have a valid combo, screwdriver it to create your product.


/obj/item/dynassembly/
	name = "assembly"
	w_class = 4
	var/list/partnames = list() //the names of the parts we have, individually
	var/parts = "" //the string version of the parts we have, all together and w/ "ands", probably some way to generate from partnames
	var/validate = 1 //Do you want to be able to add any kind of part? Turn off if so.
	var/list/validparts = list() //type that is valid to add to the assembly, see above
	var/multipart = null //Do you want to be able to add more than one copy of objects?
	var/multitypes = null //Specify what types can be multiparts (multiple copies of one type in the assembly)
	var/usematerial = null //set to non-null if you want to use color and alpha of the materials not just iconstates (material science / workbench intergration)
	var/oldmat = null //If you are using materials, you can material-ize(?) your product with this in afterproduct().
	var/product = 0 //When secured, what do you want it to produce? Set in switch statement in createproduct().
	var/secure_duration = 50 //How long it takes to secure / unsecure

	attackby(obj/item/W as obj, mob/user as mob) //This is adding parts after the first run, creating is done on base objs attackby
		if (!W)
			return
		if ((validate && (W.type in validparts)) || (validate && (W.parent_type in validparts)) || (!validate && !isscrewingtool(W)))
			var/obj/item/P = W
			if ((!multipart && (P.type in src.contents) || (multipart && multitypes && !(P.type in src.multitypes) ) && contents.len >= 15)) //who really needs more than 15 parts
				boutput(user, "You can't add any more of this type of part!")
			else
				boutput(user, "<span class='notice'>You begin adding \the [P.name] to \the [src.name].</span>")
				if (!do_after(user, 50))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return ..()
				else
					user.drop_item()
					newpart(src,P) //returns the existing assembly and part we are adding

		else if (isscrewingtool(W)) // You always secure a dynassembly with a screwdriver.
			if (!product)
				boutput(user, "You can't secure \the [src] yet!")
			else
				playsound(src.loc, "sound/items/Screwdriver.ogg", 30, 1, -2)
				actions.start(new/datum/action/bar/icon/dynassemblySecure(src, user, secure_duration), user)
		else if (iswrenchingtool(W)) //use a wrench to deconstruct
			if (contents)
				playsound(src.loc, "sound/items/Wrench.ogg", 30, 1, -2)
				actions.start(new/datum/action/bar/icon/dynassemblyUnsecure(src, user, secure_duration), user)

	proc/newpart(var/obj/item/M, var/obj/item/P, firstrun = 0) //1st arg is the source object (norm. the assembly), 2nd arg is the thing you are adding
		src.partnames += P.name
		src.contents += P

		if (firstrun)
			src.icon_state = null
			src.contents += M
			src.partnames += M.name
			var/image/I = image(M.icon, M.icon_state)
			I.pixel_x = rand(-6,6)
			I.pixel_y = rand(-6,6)
			I.layer += rand(0.25,0.75)
			if (usematerial)
				if (M.material)
					src.oldmat = M.material
				I.color = M.color
				I.alpha = M.alpha
			src.overlays += I
			M.set_loc(src)

		var/image/I = image(P.icon, P.icon_state)
		I.pixel_x = rand(-6,6)
		I.pixel_y = rand(-6,6)
		I.layer += rand(0.25,0.75)
		if (usematerial)
			I.color = P.color
			I.alpha = P.alpha
		src.overlays += I
		src.color = null //So it's not all one color.
		P.set_loc(src)

		src.parts = ""
		for (var/i in 1 to src.partnames.len)
			src.parts += src.partnames[i]
			if (partnames.len != i)
				src.parts += " and "
		src.name = "[src.parts] assembly"
		src.desc = "This is \a [src.parts] assembly."
		src.checkifdone()


	proc/checkifdone() //Checks to see if you have fuffiled any conditions to secure. Override in subtype.
		return

	proc/createproduct() //Creates yo stuff. Override in subtype.
		return

	proc/afterproduct(var/obj/item/I, mob/user) //You can do stuff with the product after you create it.
		if (usematerial && oldmat)
			I.setMaterial(oldmat)
		boutput(user, "You have successfully created \a [I]!")
		return


/* ===================================================== */
/* ------------ DynAssembly Action Controls ------------ */
/* ===================================================== */

/datum/action/bar/icon/dynassemblySecure //This is used when you are securing a dynassembly.
	duration = 150
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "dynassSecure"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "screwdriver"
	var/obj/item/dynassembly/assembly
	var/mob/user

	New(Assembly, User, Duration=150)
		assembly = Assembly
		user = User
		duration = Duration
		..()

	onStart()
		..()
		for(var/mob/O in AIviewers(owner))
			O.show_message(text("<span class='notice'>[] begins securing \the [assembly].</span>", owner), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, "<span class='alert'>You were interrupted!</span>")

	onEnd()
		..()
		user.visible_message("<span class='notice'><b>[user.name]</b> drops the materials in their hands to secure the assembly.</span>")
		if(assembly.loc == user)
			user.drop_item(assembly)
		assembly.createproduct(user)
		assembly.dispose()

/datum/action/bar/icon/dynassemblyUnsecure //This is used when you are unsecuring a dynassembly.
	duration = 150
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "dynassUnsecure"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "wrench"
	var/obj/item/dynassembly/assembly
	var/mob/user

	New(Assembly, User, Duration=150)
		assembly = Assembly
		user = User
		duration = Duration
		..()

	onStart()
		..()
		for(var/mob/O in AIviewers(owner))
			O.show_message(text("<span class='notice'>[] begins unsecuring \the [assembly].</span>", owner), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, "<span class='alert'>You were interrupted!</span>")

	onEnd()
		..()
		for (var/obj/O in assembly.contents)
			O.set_loc(get_turf(assembly))
		user.u_equip(assembly)
		boutput(user, "<span class='alert'>You have unsecured \the [assembly]!</span>")
		qdel(assembly)



/* ===================================================== */
/* --------------- Instrument Assemblies --------------- */
/* ===================================================== */

/obj/item/dynassembly/instrument
	name = "instrument assembly"
	icon = 'icons/obj/instruments.dmi'
	validparts = list(/obj/item/cable_coil, /obj/item/musicpart/)
	multipart = 1
	multitypes = /obj/item/musicpart/h_rod
	usematerial = 1

	checkifdone()
		var/body = 0
		var/neck = 0
		var/mouth = 0
		var/bell = 0
		var/bag = 0
		var/hrod = 0
		var/cable = 0

		for (var/obj/item/i in src.contents)
			if (istype(i, /obj/item/musicpart/body))
				body++
			if (istype(i, /obj/item/musicpart/neck))
				neck++
			if (istype(i, /obj/item/musicpart/mouth))
				mouth++
			if (istype(i, /obj/item/musicpart/bell))
				bell++
			if (istype(i, /obj/item/musicpart/bag))
				bag++
			if (istype(i, /obj/item/musicpart/h_rod))
				hrod++
			if (istype(i, /obj/item/cable_coil))
				cable++

		if ((body == 1 && neck == 1 && mouth == 1 && bell == 1)) //sax
			product = 1
		else if ((bag == 1 && mouth == 1 && hrod == 4)) //bagpipe
			product = 2
		else if ((bell == 1 && bag == 1)) //bikehorn
			product = 3
		else if ((mouth == 2 && cable == 1)) //harmonica
			product = 4
		else if ((neck == 1 && hrod == 2 && bell == 1 && mouth == 1)) //trumpet
			product = 5
		else if ((neck == 1&& bell == 1 && mouth == 1)) //vuvuzuela
			product = 6
		else if ((neck == 1 && cable == 2 && body == 1)) //fiddle
			product = 7
		else if ((mouth == 1 && cable == 1)) //whistle
			product = 8

	createproduct(mob/user)
		switch(product)
			if (1)
				var/obj/item/instrument/saxophone/N = new /obj/item/instrument/saxophone(get_turf(src))
				afterproduct(N, user)
			if (2)
				var/obj/item/instrument/bagpipe/N = new /obj/item/instrument/bagpipe(get_turf(src))
				afterproduct(N, user)
			if (3)
				var/obj/item/instrument/bikehorn/N = new /obj/item/instrument/bikehorn(get_turf(src))
				afterproduct(N, user)
			if (4)
				var/obj/item/instrument/harmonica/N = new /obj/item/instrument/harmonica(get_turf(src))
				afterproduct(N, user)
			if (5)
				var/obj/item/instrument/trumpet/N = new /obj/item/instrument/trumpet(get_turf(src))
				afterproduct(N, user)
			if (6)
				var/obj/item/instrument/vuvuzela/N = new /obj/item/instrument/vuvuzela(get_turf(src))
				afterproduct(N, user)
			if (7)
				var/obj/item/instrument/fiddle/N = new /obj/item/instrument/fiddle(get_turf(src))
				afterproduct(N, user)
			if (8)
				var/obj/item/instrument/whistle/N = new /obj/item/instrument/whistle(get_turf(src))
				afterproduct(N, user)
		return

/obj/item/musicpart
	name = "instrument part"
	desc = "An interesting product of shoddy coding somewhere. How silly."
	icon = 'icons/obj/instruments.dmi'
	icon_state = "trumpet"
	rand_pos = 1

	body
		name = "instrument body"
		desc = "This is the metallic body of an instrument."
		icon_state = "part_body"

	neck
		name = "instrument neck"
		desc = "This is the so called 'neck' of an instrument."
		icon_state = "part_neck"

	mouth
		name = "instrument mouthpiece"
		desc = "This is the piece you put your mouth on. What did you expect?"
		icon_state = "part_mouth"

	bell
		name = "instrument bell"
		desc = "Not actually a bell, it's just shaped like one."
		icon_state = "part_bell"

	bag
		name = "instrument bag"
		desc = "Your breath goes into this so it can leave and go somewhere else."
		icon_state = "part_bag"

	h_rod
		name = "instrument rod"
		desc = "This tube can serve as a way to move your breath."
		icon_state = "part_hrod"


	New()
		..()
		SPAWN_DBG(0)
			update_appearance()

	proc/update_appearance()
		if (material)
			src.color = src.material.color
			src.alpha = src.material.alpha

/obj/item/musicpart/attackby(obj/item/W as obj, mob/user as mob) //init the assembly
	if (istype(W, /obj/item/musicpart))
		var/obj/item/musicpart/P = W
		boutput(user, "<span class='notice'>You begin adding \the [P.name] to \the [src.name].</span>")
		if (!do_after(user, 50))
			boutput(user, "<span class='alert'>You were interrupted!</span>")
			return ..()
		else
			if (!user) return
			user.visible_message("<span class='notice'><b>[user.name]</b> drops the objects in their hands to create an assembly.</span>", "<span class='notice'>You drop the objects in your hands to create an assembly.</span>")
			user.u_equip(P)
			user.u_equip(src)
			var/obj/item/dynassembly/instrument/A = new /obj/item/dynassembly/instrument(get_turf(src))
			A.newpart(src,P,1) //returns the attacked part as source for the assembly, the attacking part as addition, and firstrun
	return ..()
