
/obj/item/paint // this seems to be a completely different paint can than the standard one, uhh. w/e it gets to live in here too
	name = "paint can"
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "paint_neutral"
	var/paintcolor = "neutral"
	item_state = "paintcan"
	w_class = W_CLASS_NORMAL
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
	icon_fallen = "paint-fallen"
	var/paint_color = "#ff0000"
	var/add_orig = 0.2
	var/paint_intensity = 0.6

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(user)
			boutput(user, SPAN_NOTICE("You swipe the card along a crack in the machine."))

		if (prob(5))
			var/obj/item/paint_can/rainbow/plaid/P = new/obj/item/paint_can/rainbow/plaid(src.loc)
			if (user)
				boutput(user, SPAN_NOTICE("You hear a faint droning sound. Like a tiny set of bagpipes."))
			P.uses = (15 * 7)
			P.generate_icon()
		else
			var/obj/item/paint_can/rainbow/P = new/obj/item/paint_can/rainbow(src.loc)
			P.uses = (15 * 7)
			P.generate_icon()

		return 1

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/paint_can) && !(status & (BROKEN|NOPOWER)))
			var/obj/item/paint_can/can = W
			boutput(user, SPAN_NOTICE("You refill the paint can."))
			can.uses = 15
			can.generate_icon()
		else
			..()

	attack_hand(mob/user)
		if (status & (BROKEN|NOPOWER))
			return
		var/col_new = input(user, "Pick paint color", "Pick paint color", src.paint_color) as color
		if(col_new)
			var/obj/item/paint_can/P = new/obj/item/paint_can(src.loc, col_new)
			paint_color = col_new
			P.paint_intensity = src.paint_intensity
			P.add_orig = src.add_orig
			P.generate_icon()
			user.put_in_hand_or_drop(P)
		return

//////////////////// broken paint vending machine

//This is me being mean to the players.
/obj/machinery/vending/paint/broken
	name = "Broken Paint Dispenser"
	desc = "Would dispense paint, if it were not broken."
	icon = 'icons/obj/vending.dmi'
	icon_state = "paint-vend"
	anchored = ANCHORED
	density = 1
	var/repair_stage = 0
	var/paint_needed = 20

	attack_hand(mob/user)
		boutput(user, SPAN_ALERT("This must be repaired before it can be used!"))
		add_fingerprint(user)
		return

	attackby(obj/item/W, mob/user)
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
				boutput(user, SPAN_ALERT("You need to repair the machine first!"))
			return

		else
			switch(repair_stage)
				if (0)
					if (isscrewingtool(W))
						user.visible_message("[user] begins to unscrew the maintenance panel.","You begin to unscrew the maintenance panel.")
						playsound(user, 'sound/items/Screwdriver2.ogg', 65, TRUE)
						if (!do_after(user, 2 SECONDS) || repair_stage)
							return
						repair_stage = 1
						user.visible_message("[user] finishes unscrewing the maintenance panel.")
						src.desc = "Would dispense paint, if it were not broken. The maintenance panel has been unscrewed."
					else
						boutput(user, SPAN_ALERT("The maintenance panel needs to be unscrewed first!"))
						return

				if (1)
					if (ispryingtool(W))
						user.visible_message("[user] begins to pry off the maintenance panel.","You begin to pry off the maintenance panel.")
						playsound(user, 'sound/items/Crowbar.ogg', 65, TRUE)
						if (!do_after(user, 2 SECONDS) || (repair_stage != 1))
							return
						repair_stage = 2
						user.visible_message("[user] pries open the maintenance panel, exposing the service module!")
						var/obj/item/tile/steel/panel = new /obj/item/tile/steel(src.loc)
						panel.name = "maintenance panel"
						panel.desc = "A panel that is clearly from a paint dispenser. Obviously."

						src.desc = "Would dispense paint, if it were not broken. The maintenance panel has been removed."
					else
						boutput(user, SPAN_ALERT("The maintenance panel needs to be pried open first!"))
						return

				if (2)
					if (iswrenchingtool(W))
						user.visible_message("[user] begins to loosen the service module bolts.","You begin to loosen the service module bolts.")
						playsound(user, 'sound/items/Ratchet.ogg', 65, TRUE)
						if (!do_after(user, 3 SECONDS) || (repair_stage != 2))
							return
						repair_stage = 3
						user.visible_message("[user] looses the service module bolts, exposing the burnt wiring within.")

						src.desc = "Would dispense paint, if it were not broken. The maintenance panel has been removed and the service module has been loosened."
					else
						boutput(user, SPAN_ALERT("The bolts on the service module must be loosened first!"))
						return

				if (3)
					if (istype(W, /obj/item/cable_coil))
						var/obj/item/cable_coil/coil = W
						if (W.amount < 20)
							boutput(user, SPAN_ALERT("You do not have enough cable to replace all of the burnt wires! (20 units required)"))
							return
						user.visible_message("[user] begins to replace the burnt wires.","You begin to replace the burnt wires.")
						playsound(user, 'sound/items/Deconstruct.ogg', 65, TRUE)
						if (!do_after(user, 100) || (repair_stage != 3))
							return

						coil.use(20)
						repair_stage = 4
						user.visible_message("[user] replaces the burnt wiring in [src]. A \"check paint cartridge\" light begins to blink.")

						src.name = "Partially-Repaired Paint Dispenser"
						src.desc = "Would dispense paint, if it were not broken. The maintenance panel has been removed and the wiring has been replaced. A \"check paint cartridge\" light is blinking."
					else
						boutput(user, SPAN_ALERT("The wiring on the service module must be replaced first!"))
						return

				if (5)
					if (iswrenchingtool(W))
						user.visible_message("[user] begins to tighten the service module bolts.","You begin to tighten the service module bolts.")
						playsound(user, 'sound/items/Ratchet.ogg', 65, TRUE)
						if (!do_after(user, 3 SECONDS) || (repair_stage != 5))
							return
						repair_stage = 6
						user.visible_message("[user] tightens the service module bolts.")

						src.name = "Almost Fully Repaired and Properly Serviced Paint Dispenser"
						src.desc = "Would dispense paint, if only the maintenance panel was replaced."
					else
						boutput(user, SPAN_ALERT("The bolts on the service module must be secured first!"))
						return

				if (6)
					if (istype(W, /obj/item/tile))
						user.visible_message("[user] begins to replace the maintenance panel.","You begin to replace the maintenance panel.")
						playsound(user, 'sound/items/Deconstruct.ogg', 65, TRUE)
						if (!do_after(user, 5 SECONDS) || (repair_stage != 6))
							return
						repair_stage = 7
						qdel(W)
						user.visible_message("[user] replaces the maintenace panel.")

						src.name = "One-Step-Away-from-Being-Fully-Repaired Paint Dispenser"
						src.desc = "Would dispense paint, if only the maintenance panel was secured so as to allow operation."
					else
						boutput(user, SPAN_ALERT("The service panel must be replaced first!"))
						return

				if (7)
					if (isscrewingtool(W))
						user.visible_message("[user] begins to secure the maintenance panel..","You begin to secure the maintenance panel.")
						playsound(user, 'sound/items/Screwdriver2.ogg', 65, TRUE)
						if (!do_after(user, 100) || (repair_stage != 7))
							return
						repair_stage = 8
						if(prob(100))
							user.visible_message("[user] secures the maintenance panel!", "You secure the maintenance panel.")
							new /obj/machinery/vending/paint(src.loc)
							qdel(src)
							return
						user.visible_message(SPAN_ALERT("<b>[user] slips, knocking the paint dispenser over!.</b>"), SPAN_ALERT("<b>OH FUCK</b>"))

						src.name = "Irreparably Destroyed Paint Dispenser"
						src.desc = "Damaged beyond all repair, this will never dispense paint ever again."

						flick("vendbreak", src)
						SPAWN(0.8 SECONDS)
							src.icon_state = "fallen"
							sleep(7 SECONDS)
							playsound(src.loc, 'sound/effects/Explosion2.ogg', 100, 1)

							var/obj/effects/explosion/delme = new /obj/effects/explosion(src.loc)
							delme.fingerprintslast = src.fingerprintslast

							invisibility = INVIS_ALWAYS_ISH
							set_density(0)
							sleep(15 SECONDS)
							qdel(delme)
							qdel(src)
							return

					else
						boutput(user, SPAN_ALERT("The service panel must be secured first!"))
						return

////////////// paint cans

var/list/cached_colors = new/list()

/obj/item/paint_can
	name = "paint can"
	desc = "A brush."
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "paint"
	item_state = "bucket"
	var/colorname = null
	var/paint_color = rgb(1,1,1)
	var/actual_paint_color
	var/image/paint_overlay
	var/uses = 15
	var/paint_intensity = 0.5
	var/add_orig = 0
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL
	inventory_counter_enabled = TRUE

	New(loc, col_new = null)
		..()
		if (col_new)
			src.paint_color = col_new
			src.colorname = null
		if (!src.colorname)
			var/datum/color/C = new
			C.from_hex(paint_color)
			src.colorname = get_nearest_color(C)
			src.name = "[colorname] paint can"
		generate_icon()


	examine()
		. = ..()
		if (src.uses > 0)
			. += "It has <span style='display: inline-block; height: 1em; width: 1em; border: 1px solid black; background-color: [src.paint_color];'>&nbsp;</span> [colorname] paint. It has [src.uses] use\s left."
		else
			. += "It is empty. It used to have <span style='display: inline-block; height: 1em; width: 1em; border: 1px solid black; background-color: [src.paint_color];'>&nbsp;</span> [colorname] paint, though."



	attack_hand(mob/user)
		..()
		generate_icon()

	proc/paint_thing(atom/target as mob|obj|turf, force = FALSE, quiet = FALSE)
		if (uses <= 0 && !force)
			// if we have no uses and we are not forcing it, abort
			return FALSE
		else if (!force)
			// otherwise, if we aren't forcing it (but we have uses), reduce by one
			uses--

		if (uses <= 0) src.overlays = null
		src.inventory_counter?.update_number(src.uses)

		if (!quiet) playsound(target, 'sound/impact_sounds/Slimy_Splat_1.ogg', 40, TRUE)
		target.add_filter("paint_color", 1, color_matrix_filter(normalize_color_to_matrix(src.actual_paint_color)))
		if (ismob(target.loc))
			var/mob/M = target.loc
			M.update_clothing() //trigger an update if this is worn clothing

		return TRUE

	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		if (target == loc || BOUNDS_DIST(src, target) > 0 || istype(target,/obj/machinery/vending/paint)) return FALSE

		if (uses <= 0)
			boutput(user, "\The [src] is empty.")
			return FALSE

		if (src.paint_thing(target))
			user.visible_message(SPAN_NOTICE("[user] paints \the [target] with \the [src]."), "You paint \the [target] with \the [src].", SPAN_NOTICE("You hear a wet splat."))

		return TRUE

	attackby(obj/item/W, mob/user, params)
		if (istype(W, /obj/item/gun/paintball))
			W.Attackby(src, user)
			return

		. = ..()

	proc/generate_icon()
		overlays = null
		src.inventory_counter?.update_number(src.uses)
		if (uses <= 0) return
		if (!paint_overlay)
			paint_overlay = image('icons/misc/old_or_unused.dmi',"paint_overlay")
		paint_overlay.color = paint_color
		overlays += paint_overlay
		var/list/color_list = hex_to_rgb_list(src.paint_color)
		src.actual_paint_color = list(
			1 - paint_intensity + add_orig, 0, 0,
			0, 1 - paint_intensity + add_orig, 0,
			0, 0, 1 - paint_intensity + add_orig,
			paint_intensity * color_list[1]/255, paint_intensity * color_list[2]/255, paint_intensity * color_list[3]/255)

/obj/item/paint_can/random
	name = "random paint can"
	uses = 5
	New()
		colorname = "weird"
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
		..()

/obj/item/paint_can/totally_random
	New()
		src.paint_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		..()

/obj/item/paint_can/rainbow
	name = "rainbow paint can"
	desc = "This paint can contains rich, thick, rainbow paint. No, we don't know how it works either."
	colorname = "shimmering rainbow"
	var/colorlist = list()
	var/currentcolor = 1
	New()
		//A rainbow of colours! Joy!
		src.colorlist = list(rgb(255,0,0),rgb(255,165,0), rgb(255,255,0), rgb(0,128,0), rgb(0,0,255), rgb(075,0,128), rgb(238,128,238))
		src.currentcolor = rand(1, length(src.colorlist))
		src.paint_color = colorlist[currentcolor]
		..()

	paint_thing(atom/target as mob|obj|turf, force = FALSE, change_color = TRUE)
		if (!..())
			return FALSE

		if (change_color)
			src.currentcolor = (src.currentcolor % length(src.colorlist)) + 1
			src.paint_color = colorlist[currentcolor]
			src.generate_icon()

		return TRUE

/obj/item/paint_can/rainbow/plaid
	name = "pattern paint can"
	desc = "A perfectly ordinary can of rainbow paint. Oh, except that it paints patterns."
	colorname = "mysterious pattern"
	var/patternlist = list()
	var/currentpattern = 1

	New()
		..()
		src.patternlist = list("tartan", "strongplaid", "polka", "hearts")
		for(var/i=1 to length(src.patternlist))
			src.patternlist[i] =  new /icon('icons/obj/paint.dmi', patternlist[i])

		currentpattern = rand(1, length(src.patternlist))

	paint_thing(atom/target as mob|obj|turf, force = FALSE, change_color = TRUE)
		if (!..(target, force, FALSE))
			// advance
			return FALSE

		var/matrix/scale_transform = matrix()
		var/icon/I = new(target.icon) //isn't DM great?
		scale_transform.Scale(I.Width()/32, I.Height()/32)
		target.add_filter("paint_pattern", 1, layering_filter(icon=src.patternlist[src.currentpattern], color=src.actual_paint_color, transform=scale_transform, blend_mode=BLEND_MULTIPLY))

		if(ismob(target.loc))
			var/mob/M = target.loc
			M.update_clothing() //trigger an update if this is worn clothing

		if(change_color)
			src.currentcolor = (src.currentcolor % length(src.colorlist)) + 1
			src.currentpattern = (src.currentpattern % length(src.patternlist)) + 1
			src.paint_color = colorlist[currentcolor]
			src.generate_icon()

		return TRUE
