
/obj/item/paint // this seems to be a completely different paint can than the standard one, uhh. w/e it gets to live in here too
	name = "paint can"
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "paint_neutral"
	uses_multiple_icon_states = 1
	var/paintcolor = "neutral"
	item_state = "paintcan"
	w_class = 3.0
	desc = "A can of impossible to remove paint."

/obj/item/paint/attack_self(mob/user as mob)

	var/t1 = input(user, "Please select a color:", "Locking Computer", null) in list( "red", "blue", "green", "yellow", "black", "white", "neutral" )
	if ((user.equipped() != src || user.stat || user.restrained()))
		return
	src.paintcolor = t1
	src.icon_state = text("paint_[]", t1)
	add_fingerprint(user)
	return

/obj/machinery/vending/paint
	name = "paint dispenser"
	desc = "Dispenses paint. Derp."
	icon = 'icons/obj/vending.dmi'
	icon_state = "paint-vend"
	var/paint_color = "#ff0000"

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(user)
			boutput(user, "<span class='notice'>You swipe the card along a crack in the machine.</span>")

		if (prob(5))
			var/obj/item/paint_can/rainbow/plaid/P = new/obj/item/paint_can/rainbow/plaid(src.loc)
			if (user)
				boutput(user, "<span class='notice'>You hear a faint droning sound. Like a tiny set of bagpipes.</span>")
			P.uses = (15 * 7)
			P.generate_icon()
		else
			var/obj/item/paint_can/rainbow/P = new/obj/item/paint_can/rainbow(src.loc)
			P.uses = (15 * 7)
			P.generate_icon()

		return 1

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/paint_can))
			boutput(user, "<span class='notice'>You refill the paint can.</span>")
			W:uses = 15
			W:generate_icon()

			return

	attack_hand(mob/user as mob)
		var/col_new = input(user) as color
		if(col_new)
			var/obj/item/paint_can/P = new/obj/item/paint_can(src.loc)
			P.paint_color = col_new
			paint_color = col_new
			P.generate_icon()
		return

//////////////////// broken paint vending machine

//This is me being mean to the players.
/obj/machinery/vending/paint/broken
	name = "Broken Paint Dispenser"
	desc = "Would dispense paint, if it were not broken."
	icon = 'icons/obj/vending.dmi'
	icon_state = "paint-vend"
	anchored = 1
	density = 1
	var/repair_stage = 0
	var/paint_needed = 20

	attack_hand(mob/user as mob)
		boutput(user, "<span class='alert'>This must be repaired before it can be used!</span>")
		add_fingerprint(user)
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (!W || !user)
			return

		if(istype(W,/obj/item/paint_can))
			if (repair_stage == 4)
				var/obj/item/paint_can/can = W
				if (!can.uses)
					boutput(user, "The can is empty.")
					return

				can.uses--
				paint_needed--
				if (!paint_needed)
					user.visible_message("[user] pours some paint into [src]. The \"check paint cartridge\" light goes out.", "You pour some paint into [src], filling it up!")
					src.repair_stage = 5
					src.name = "Very-Nearly-Functional Paint Dispenser"
					desc = "Would dispense paint, if only the service module was resecured and the panel was replaced."
					return

				user.visible_message("[user] pours some paint into [src].", "You pour some paint into [src]. ([paint_needed] units still needed)")
			else
				boutput(user, "<span class='alert'>You need to repair the machine first!</span>")
			return

		else
			switch(repair_stage)
				if (0)
					if (isscrewingtool(W))
						user.visible_message("[user] begins to unscrew the maintenance panel.","You begin to unscrew the maintenance panel.")
						playsound(user, "sound/items/Screwdriver2.ogg", 65, 1)
						if (!do_after(user, 2 SECONDS) || repair_stage)
							return
						repair_stage = 1
						user.visible_message("[user] finishes unscrewing the maintenance panel.")
						src.desc = "Would dispense paint, if it were not broken. The maintenance panel has been unscrewed."
					else
						boutput(user, "<span class='alert'>The maintenance panel needs to be unscrewed first!</span>")
						return

				if (1)
					if (ispryingtool(W))
						user.visible_message("[user] begins to pry off the maintenance panel.","You begin to pry off the maintenance panel.")
						playsound(user, "sound/items/Crowbar.ogg", 65, 1)
						if (!do_after(user, 2 SECONDS) || (repair_stage != 1))
							return
						repair_stage = 2
						user.visible_message("[user] pries open the maintenance panel, exposing the service module!")
						var/obj/item/tile/steel/panel = new /obj/item/tile/steel(src.loc)
						panel.name = "maintenance panel"
						panel.desc = "A panel that is clearly from a paint dispenser. Obviously."

						src.desc = "Would dispense paint, if it were not broken. The maintenance panel has been removed."
					else
						boutput(user, "<span class='alert'>The maintenance panel needs to be pried open first!</span>")
						return

				if (2)
					if (iswrenchingtool(W))
						user.visible_message("[user] begins to loosen the service module bolts.","You begin to loosen the service module bolts.")
						playsound(user, "sound/items/Ratchet.ogg", 65, 1)
						if (!do_after(user, 3 SECONDS) || (repair_stage != 2))
							return
						repair_stage = 3
						user.visible_message("[user] looses the service module bolts, exposing the burnt wiring within.")

						src.desc = "Would dispense paint, if it were not broken. The maintenance panel has been removed and the service module has been loosened."
					else
						boutput(user, "<span class='alert'>The bolts on the service module must be loosened first!</span>")
						return

				if (3)
					if (istype(W, /obj/item/cable_coil))
						var/obj/item/cable_coil/coil = W
						if (W.amount < 20)
							boutput(user, "<span class='alert'>You do not have enough cable to replace all of the burnt wires! (20 units required)</span>")
							return
						user.visible_message("[user] begins to replace the burnt wires.","You begin to replace the burnt wires.")
						playsound(user, "sound/items/Deconstruct.ogg", 65, 1)
						if (!do_after(user, 100) || (repair_stage != 3))
							return

						coil.use(20)
						repair_stage = 4
						user.visible_message("[user] replaces the burnt wiring in [src]. A \"check paint cartridge\" light begins to blink.")

						src.name = "Partially-Repaired Paint Dispenser"
						src.desc = "Would dispense paint, if it were not broken. The maintenance panel has been removed and the wiring has been replaced. A \"check paint cartridge\" light is blinking."
					else
						boutput(user, "<span class='alert'>The wiring on the service module must be replaced first!</span>")
						return

				if (5)
					if (iswrenchingtool(W))
						user.visible_message("[user] begins to tighten the service module bolts.","You begin to tighten the service module bolts.")
						playsound(user, "sound/items/Ratchet.ogg", 65, 1)
						if (!do_after(user, 3 SECONDS) || (repair_stage != 5))
							return
						repair_stage = 6
						user.visible_message("[user] tightens the service module bolts.")

						src.name = "Almost Fully Repaired and Properly Serviced Paint Dispenser"
						src.desc = "Would dispense paint, if only the maintenance panel was replaced."
					else
						boutput(user, "<span class='alert'>The bolts on the service module must be secured first!</span>")
						return

				if (6)
					if (istype(W, /obj/item/tile))
						if (W.name != "maintenance panel")
							user.visible_message("[user] tries to use a common floor tile in place of the maintenance panel! How silly!", "<span class='alert'>That is a floor tile, not a maintenance panel! It doesn't even fit!</span>")
							return
						user.visible_message("[user] begins to replace the maintenance panel.","You begin to replace the maintenance panel.")
						playsound(user, "sound/items/Deconstruct.ogg", 65, 1)
						if (!do_after(user, 5 SECONDS) || (repair_stage != 6))
							return
						repair_stage = 7
						qdel(W)
						user.visible_message("[user] replaces the maintenace panel.")

						src.name = "One-Step-Away-from-Being-Fully-Repaired Paint Dispenser"
						src.desc = "Would dispense paint, if only the maintenance panel was secured so as to allow operation."
					else
						boutput(user, "<span class='alert'>The service panel must be replaced first!</span>")
						return

				if (7)
					if (isscrewingtool(W))
						user.visible_message("[user] begins to secure the maintenance panel..","You begin to secure the maintenance panel.")
						playsound(user, "sound/items/Screwdriver2.ogg", 65, 1)
						if (!do_after(user, 100) || (repair_stage != 7))
							return
						repair_stage = 8
						if (prob(33))//5)) upped from 5 because eh
							user.visible_message("[user] secures the maintenance panel!", "You secure the maintenance panel.")
							new /obj/machinery/vending/paint(src.loc)
							qdel(src)
							return
						user.visible_message("<span class='alert'><b>[user] slips, knocking the paint dispenser over!.</b></span>")
						boutput(user, "<b><font color=red>OH FUCK</font></b>")

						src.name = "Irreparably Destroyed Paint Dispenser"
						src.desc = "Damaged beyond all repair, this will never dispense paint ever again."

						flick("vendbreak", src)
						SPAWN_DBG(0.8 SECONDS)
							src.icon_state = "fallen"
							sleep(7 SECONDS)
							playsound(src.loc, "sound/effects/Explosion2.ogg", 100, 1)

							var/obj/effects/explosion/delme = new /obj/effects/explosion(src.loc)
							delme.fingerprintslast = src.fingerprintslast

							invisibility = 100
							set_density(0)
							sleep(15 SECONDS)
							qdel(delme)
							qdel(src)
							return

					else
						boutput(user, "<span class='alert'>The service panel must be secured first!</span>")
						return

////////////// paint cans

var/list/cached_colors = new/list()

/obj/item/paint_can
	name = "paint can"
	desc = "A Paint Can and a brush."
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "paint"
	item_state = "bucket"
	var/paint_color = rgb(1,1,1)
	var/image/paint_overlay
	var/uses = 15
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = 2.0

	attack_hand(mob/user as mob)
		..()

		generate_icon()

	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		if(target == loc || get_dist(src,target) > 1 || istype(target,/obj/machinery/vending/paint) ) return

		if(!uses)
			boutput(user, "It's empty.")
			return

		boutput(user, "You paint \the [target].")
		for(var/mob/O in oviewers(world.view, user))
			O.show_message("<span class='notice'>[user] paints \the [target].</span>", 1)

		playsound(src, "sound/impact_sounds/Slimy_Splat_1.ogg", 40, 1)

		uses--
		if(!uses) overlays = null

		/*
		if( (paint_color+"[initial(target.icon)]") in cached_colors )
			target.icon = cached_colors[(paint_color+"[initial(target.icon)]")]
		else
			var/icon/new_icon = icon(target.icon)
			new_icon.ColorTone(paint_color)
			cached_colors += (paint_color+"[initial(target.icon)]")
			cached_colors[(paint_color+"[initial(target.icon)]")] = new_icon
			target.icon = new_icon
		*/
		var/oldVal = target.color
		target.color = paint_color
		target.onVarChanged("color", oldVal, paint_color) // to force redraws on worn items if needed

		//var/icon/new_icon = icon(initial(target.icon))
		//new_icon.ColorTone(color)
		//target.icon = new_icon

		return

	proc/generate_icon()
		if (!paint_overlay)
			paint_overlay = image('icons/misc/old_or_unused.dmi',"paint_overlay")
		paint_overlay.color = paint_color
		overlays = null
		overlays += paint_overlay

/obj/item/paint_can/random
	name = "random paint can"
	uses = 5
	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			var/colorname = "Weird"
			switch(rand(1,6))
				if(1)
					paint_color = rgb(255,10,10)
					colorname = "red"
				if(2)
					paint_color = rgb(10,255,10)
					colorname = "green"
				if(3)
					paint_color = rgb(10,10,255)
					colorname = "blue"
				if(4)
					paint_color = rgb(255,255,10)
					colorname = "yellow"
				if(5)
					paint_color = rgb(255,10,255)
					colorname = "purple"
				if(6)
					paint_color = rgb(150,150,150)
					colorname = "gray"

			name = "[colorname] paint can"
			desc = "[colorname] paint. In a can. Whoa!"
			src.generate_icon()

/obj/item/paint_can/rainbow
	name = "rainbow paint can"
	desc = "This Paint Can contains rich, thick, rainbow paint. No, we don't know how it works either."
	var/colorlist[]
	var/currentcolor
	New()
		..()

		//A rainbow of colours! Joy!
		src.colorlist = list(rgb(255,0,0),rgb(255,165,0), rgb(255,255,0), rgb(0,128,0), rgb(0,0,255), rgb(075,0,128), rgb(238,128,238))
		src.currentcolor = 1
		src.paint_color = colorlist[currentcolor]


	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		..()
		src.currentcolor += 1
		if (src.currentcolor == 8)
			src.currentcolor = 1

		src.paint_color = colorlist[currentcolor]

		src.generate_icon()

		return

/obj/item/paint_can/rainbow/plaid
	name = "pattern paint can"
	desc = "A perfectly ordinary can of paint. Oh, except that it paints patterns."
	var/patternlist[]
	var/currentpattern

	New()
		..()

		src.patternlist = list("tartan", "strongplaid", "polka", "hearts")
		currentpattern = 1

	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		if(target == loc || get_dist(src,target) > 1 || istype(target,/obj/machinery/vending/paint) ) return

		if(!uses)
			boutput(user, "It's empty.")
			return

		boutput(user, "You paint \the [target].")
		for(var/mob/O in oviewers(world.view, user))
			O.show_message("<span class='notice'>[user] paints \the [target].</span>", 1)

		playsound(src, "sound/impact_sounds/Slimy_Splat_1.ogg", 40, 1)

		uses--
		if(!uses) overlays = null

		if( (paint_color+"[initial(target.icon)]") in cached_colors )
			target.icon = cached_colors[(paint_color+"[initial(target.icon)]")]
		else
			var/icon/new_icon = icon(target.icon)

			//Add pattern here.
			var/icon/pattern = new('icons/obj/paint.dmi', patternlist[currentpattern])
			new_icon.Blend(pattern,ICON_MULTIPLY)

			new_icon.ColorTone(paint_color)
			cached_colors += (paint_color+"[initial(target.icon)]")
			cached_colors[(paint_color+"[initial(target.icon)]")] = new_icon
			target.icon = new_icon


		src.currentcolor += 1
		if (src.currentcolor == 8)
			src.currentcolor = 1

		src.paint_color = colorlist[currentcolor]

		src.currentpattern += 1
		if (src.currentpattern == 4)
			src.currentpattern = 1

		src.generate_icon()
