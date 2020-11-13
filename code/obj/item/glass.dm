/*
CONTAINS:
GLASS SHEET
REINFORCED GLASS SHEET
SHARDS

*/
/obj/item/sheet/glass
	name = "glass"
	icon = 'icons/obj/glass.dmi'
	icon_state = "sheet"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	var/crystal = 0
	var/reinforced = 0
	throw_speed = 3
	throw_range = 3
	desc = "A collection of chemically treated and strengthened sheets of glass. Useful for construction, especially for windows."
		//cogwerks - burn vars
	burn_point = 7000
	burn_output = 7500
	burn_possible = 1
	health = 5
	burn_type = 1

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins stacking glass sheets!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking glass.</span>")

	attack_hand(mob/user as mob)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = round(input("How many sheets do you want to take from the stack?","Stack of [src.amount]",1) as num)
			var/diff = src.amount - splitnum
			if (splitnum >= amount || splitnum < 1)
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			boutput(usr, "<span class='notice'>You take [splitnum] sheets from the stack, leaving [diff] sheets behind.</span>")
			src.amount = diff
			var/obj/item/sheet/glass/new_stack = new src.type(usr.loc, diff)
			new_stack.amount = splitnum
			new_stack.attack_hand(user)
			new_stack.add_fingerprint(user)
		else
			..(user)

	attackby(obj/item/W, mob/user)
		//if ( istype(W, /obj/item/sheet/glass) )
		if ( W.type == src.type )
			var/obj/item/sheet/glass/G = W
			if (G.amount >= src.max_stack)
				boutput(user, "<span class='alert'>You can't put any more sheets in this stack!</span>")
				return
			if (G.amount + src.amount > src.max_stack)
				src.amount = min(G.amount + src.amount, src.max_stack)
				G.amount = 5
				boutput(user, "<span class='notice'>You add the glass sheets to the stack. It now has [G.amount] sheets.</span>")
			else
				G.amount += src.amount
				boutput(user, "<span class='notice'>You add the glass sheet to the stack. It now has [G.amount] sheets.</span>")
				//SN src = null
				qdel(src)
				return
			return
		else if( istype(W, /obj/item/rods) && !reinforced)

			var/obj/item/rods/V  = W
			var/obj/item/sheet/glass/R

			if(crystal)
				R = new /obj/item/sheet/glass/crystal/reinforced(user.loc)
			else
				R = new /obj/item/sheet/glass/reinforced(user.loc)

			R.set_loc(user.loc)
			R.add_fingerprint(user)

			if(V.amount == 1)
				user.u_equip(W)
				qdel(W)
			else
				V.amount--


			if(src.amount == 1)
				user.u_equip(src)
				qdel(src)
			else
				src.amount--
				return

	examine()
		. = ..()
		. += "There are [src.amount] glass sheet\s on the stack."

	attack_self(mob/user as mob)

		if (!( istype(usr.loc, /turf/simulated) ))
			return
		switch(alert("Sheet-Glass", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
			if("one direct")
				var/obj/window/W

				if(!crystal && !reinforced)
					W = new /obj/window( usr.loc )
					if(src.material) W.setMaterial(src.material)
					logTheThing("station", usr, null, "builds a Window in [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")
				else if(!crystal && reinforced)
					W = new /obj/window/reinforced( usr.loc )
					if(src.material) W.setMaterial(src.material)
					logTheThing("station", usr, null, "builds a Reinforced Window in [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")
				else if(crystal && !reinforced)
					W = new /obj/window/crystal( usr.loc )
					if(src.material) W.setMaterial(src.material)
					logTheThing("station", usr, null, "builds a Crystal Window in [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")
				else if(crystal && reinforced)
					W = new /obj/window/crystal/reinforced( usr.loc )
					if(src.material) W.setMaterial(src.material)
					logTheThing("station", usr, null, "builds a Reinforced Crystal Window in [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")

				W.anchored = 0
				W.state = 0
				W.set_dir(2)
				W.ini_dir = 2
				if (src.amount < 1)
					return
				src.amount--
			if("full (2 sheets)")
				if (src.amount < 2)
					return
				src.amount -= 2

				var/obj/window/W

				if(!crystal && !reinforced)
					W = new /obj/window( usr.loc )
					if(src.material) W.setMaterial(src.material)
					logTheThing("station", usr, null, "builds a Full Window in [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")
				else if(!crystal && reinforced)
					W = new /obj/window/reinforced( usr.loc )
					if(src.material) W.setMaterial(src.material)
					logTheThing("station", usr, null, "builds a Full Reinforced Window in [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")
				else if(crystal && !reinforced)
					W = new /obj/window/crystal( usr.loc )
					if(src.material) W.setMaterial(src.material)
					logTheThing("station", usr, null, "builds a Full Crystal Window in [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")
				else if(crystal && reinforced)
					W = new /obj/window/crystal/reinforced( usr.loc )
					if(src.material) W.setMaterial(src.material)
					logTheThing("station", usr, null, "builds a Full Reinforced Crystal Window in [usr.loc.loc] ([showCoords(usr.x, usr.y, usr.z)])")

				W.set_dir(SOUTHWEST)
				W.ini_dir = SOUTHWEST
				W.anchored = 0
				W.state = 0
			else
		if (src.amount <= 0)
			user.u_equip(src)
			qdel(src)
			return
		return

// REINFORCED GLASS

/obj/item/sheet/glass/reinforced
	name = "reinforced glass"
	icon = 'icons/obj/glass.dmi'
	icon_state = "sheet-r"
	item_state = "sheet-rglass"
	force = 6.0
	g_amt = 3750
	m_amt = 1875
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	reinforced = 1
	desc = "A collection of strong glass reinforced with metal rods. Used to make tough windows."

/obj/item/sheet/glass/crystal/reinforced
	name = "reinforced crystal glass"
	icon = 'icons/obj/glass.dmi'
	icon_state = "sheet-cr"
	item_state = "sheet-crglass"
	force = 6.0
	g_amt = 4750
	m_amt = 2875
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	reinforced = 1
	crystal = 1
	desc = "A collection of plasma crystal glass, reinforced with metal rods. Used to make extremely tough windows."

/obj/item/sheet/glass/crystal
	name = "crystal glass"
	icon = 'icons/obj/glass.dmi'
	icon_state = "sheet-c"
	item_state = "sheet-cglass"
	force = 6.0
	g_amt = 4750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	crystal = 1
	desc = "A collection of plasma crystal glass. Used to make very tough windows."

// SHARDS

/obj/item/shard
	name = "shard"
	icon = 'shards.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "large"
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = 3.0
	force = 5.0
	throwforce = 15.0
	item_state = "shard-glass"
	g_amt = 3750
	burn_type = 1
	stamina_damage = 5
	stamina_cost = 15
	stamina_crit_chance = 35

/obj/item/shard/Bump()

	SPAWN_DBG( 0 )
		if (prob(20))
			src.force = 15
		else
			src.force = 4
		..()
		return
	return

/obj/item/shard/New()

	//****RM
	//boutput(world, "New shard at [x],[y],[z]")

	src.icon_state = pick("large", "medium", "small")
	switch(src.icon_state)
		if("small")
			src.pixel_x = rand(1, 18)
			src.pixel_y = rand(1, 18)
		if("medium")
			src.pixel_x = rand(1, 16)
			src.pixel_y = rand(1, 16)
		if("large")
			src.pixel_x = rand(1, 10)
			src.pixel_y = rand(1, 5)
		else
	return

/obj/item/shard/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (!(isweldingtool(W) && try_weld(user,0,-1,1,0)))
		return
	var/atom/A = new /obj/item/sheet/glass( user.loc )
	if(src.material) A.setMaterial(src.material)
	//SN src = null
	qdel(src)
	return

/obj/item/shard/HasEntered(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(isabomination(H))
				return
			if(!H.shoes)
				boutput(H, "<span class='alert'><B>You step in the broken glass!</B></span>")
				playsound(src.loc, "sound/impact_sounds/Glass_Shards_Hit_1.ogg", 50, 1)
				var/obj/item/affecting = H.organs[pick("l_leg", "r_leg")]
				H.weakened = max(3, H.weakened)
				affecting.take_damage(5, 0)
				H.UpdateDamageIcon()
	..()

// CRYSTAL

/obj/item/shard/crystal
	name = "crystal shard"
	icon = 'shards.dmi'
	icon_state = "clarge"
	desc = "A shard of Plasma Crystal. Very hard and sharp."
	w_class = 3.0
	force = 10.0
	throwforce = 20.0
	item_state = "shard-glass"
	g_amt = 0
	New()
		src.icon_state = pick("clarge", "cmedium", "csmall")
		switch(src.icon_state)
			if("csmall")
				src.pixel_x = rand(1, 18)
				src.pixel_y = rand(1, 18)
			if("cmedium")
				src.pixel_x = rand(1, 16)
				src.pixel_y = rand(1, 16)
			if("clarge")
				src.pixel_x = rand(1, 10)
				src.pixel_y = rand(1, 5)
			else
		return
	attackby(obj/item/W as obj, mob/user as mob)
		if (!(isweldingtool(W) && W:try_weld(user,0,-1,1,0)))
			return
		var/atom/A = new /obj/item/sheet/glass/crystal( user.loc )
		if(src.material) A.setMaterial(src.material)
		qdel(src)
		return
	HasEntered(AM as mob|obj)
		if(ismob(AM))
			var/mob/M = AM
			boutput(M, "<span class='alert'><B>You step on the crystal shard!</B></span>")
			playsound(src.loc, "sound/impact_sounds/Glass_Shards_Hit_1.ogg", 50, 1)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/obj/item/affecting = H.organs[pick("l_leg", "r_leg")]
				H.weakened = max(3, H.weakened)
				affecting.take_damage(10, 0)
				H.UpdateDamageIcon()
