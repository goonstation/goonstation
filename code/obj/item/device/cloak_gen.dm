//Contents
//Cloak field generator
//Remote for said generator

TYPEINFO(/obj/item/cloak_gen)
	mats = 12

/obj/item/cloak_gen
	name = "cloaking field generator"
	desc = "It's humming softly."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "cloakgen_off"
	var/range = 3
	var/maxrange = 5
	var/active = 0
	var/icon_to_use = "noise2"
	var/list/fields = new/list()
	is_syndicate = 1
	contraband = 2

	New()
		..()
		var/obj/item/remote/cloak_gen/remote = new /obj/item/remote/cloak_gen(src.loc)
		SPAWN(0)
			remote.my_gen = src

	disposing()
		//DEBUG_MESSAGE("Disposing() was called for [src] at [log_loc(src)].")
		if (src.active)
			src.turn_off()
		..()
		return

	attack_self()
		boutput(usr, "<span class='alert'>I need to place it on the ground to use it.</span>")

	// Shouldn't be required, but there have been surplus crate-related bugs in the past (Convair880).
	attackby(obj/item/W, mob/user)
		if (!W || !istype(W, /obj/item/remote/cloak_gen/))
			..()
			return
		if (istype(W, /obj/item/remote/cloak_gen/))
			var/obj/item/remote/cloak_gen/R = W
			if (!R.my_gen)
				user.show_text("Connection to [src.name] established", "blue")
				R.my_gen = src
			else
				var/choice = tgui_alert(user, "Remote is already linked to a generator. Reset and establish new connection?", "Connection override", list("Yes", "No"))
				if (choice == "Yes")
					R.my_gen = src
					user.show_text("Connection to [src.name] established", "blue")
		return

	pickup(var/mob/living/M)
		if(active) turn_off()

	proc/get_cloaked_icon(turf/T)
		var/icon/turf = icon(T.icon, T.icon_state, T.dir)
		var/icon/noise = icon('icons/misc/old_or_unused.dmi', icon_to_use, dir=pick(cardinal))
		turf.Blend(noise,ICON_MULTIPLY)
		return turf

	proc/turn_on()
		if (active) return

		if (!isturf(loc))
			if (usr && ismob(usr))
				boutput(usr, "<span class='alert'>The field generator must be on the floor to be activated.</span>")
			return

		active = 1
		anchored = ANCHORED

		if (usr && ismob(usr))
			boutput(usr, "<span class='notice'>You activate the cloak field generator.</span>")

		for(var/turf/T in range(range,src))
			if(!isturf(T)) continue
			var/obj/overlay/O = new/obj/overlay(T)
			fields += O
			O.icon = get_cloaked_icon(T)
			O.layer = EFFECTS_LAYER_4
			O.anchored = ANCHORED
			O.set_density(0)
			O.name = T.name
			O.mouse_opacity = FALSE // let people click through the field

	proc/turn_off()
		if (!active) return

		active = 0
		anchored = UNANCHORED
		if (usr && ismob(usr))
			boutput(usr, "<span class='notice'>You deactivate the cloak field generator.</span>")
		for(var/A in fields)
			qdel(A)

/obj/item/remote/cloak_gen
	name = "cloaking field generator remote"
	desc = "A remote control for a cloaking field generator."
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	is_syndicate = 1
	w_class = W_CLASS_SMALL
	var/obj/item/cloak_gen/my_gen = null
	var/anti_spam = 0 // Creating and deleting overlays en masse can cause noticeable lag (Convair880).
	contraband = 2

	attack_self()
		if (isliving(usr))
			if (my_gen)
				if (my_gen.active)
					src.anti_spam = world.time
					my_gen.turn_off()
				else
					if (src.anti_spam && world.time < src.anti_spam + 100)
						usr.show_text("The cloaking field generator is recharging!", "red")
						return
					src.anti_spam = world.time
					my_gen.turn_on()
			else
				boutput(usr, "<span class='alert'>No signal detected. Swipe remote on a cloaking generator to establish a connection.</span>")
		return

	verb/set_pattern()
		set src in view(1)
		if (!isliving(usr) || !my_gen) return
		var/input = input(usr,"Select cloaking pattern:","Set pattern","Noise") in list("Noise","Linear","Chaos","Cubic","Interference","Rotating")
		switch(input)
			if("Linear")
				my_gen.icon_to_use = "noise1"
			if("Noise")
				my_gen.icon_to_use = "noise2"
			if("Chaos")
				my_gen.icon_to_use = "noise3"
			if("Cubic")
				my_gen.icon_to_use = "noise4"
			if("Interference")
				my_gen.icon_to_use = "noise5"
			if("Rotating")
				my_gen.icon_to_use = "noise6"
		if(my_gen.active)
			my_gen.turn_off()
			my_gen.turn_on()
		boutput(usr, "<span class='notice'>You set the pattern to '[input]'.</span>")

	verb/set_range()
		set src in view(1)
		if (!isliving(usr) || !my_gen) return
		var/input = input(usr,"Range 0-[my_gen.maxrange]:","Set range",my_gen.range) as num
		if(input > my_gen.maxrange || input < 0 || !isnum_safe(input))
			boutput(usr, "<span class='alert'>Invalid setting.</span>")
			return
		my_gen.range = input
		if(my_gen.active)
			my_gen.turn_off()
			my_gen.turn_on()
		boutput(usr, "<span class='notice'>You set the range to [my_gen.range].</span>")

	verb/increase_range()
		set src in view(1)
		if (!isliving(usr) || !my_gen) return
		if (my_gen.range + 1 > my_gen.maxrange)
			boutput(usr, "<span class='alert'>Maximum range reached ([my_gen.maxrange]).</span>")
			return
		my_gen.range++
		if(my_gen.active)
			my_gen.turn_off()
			my_gen.turn_on()
		boutput(usr, "<span class='notice'>You set the range to [my_gen.range].</span>")

	verb/decrease_range()
		set src in view(1)
		if (!isliving(usr) || !my_gen) return
		if (my_gen.range - 1 < 0)
			boutput(usr, "<span class='alert'>Minimum range reached (0).</span>")
			return
		my_gen.range--
		if(my_gen.active)
			my_gen.turn_off()
			my_gen.turn_on()
		boutput(usr, "<span class='notice'>You set the range to [my_gen.range].</span>")

	verb/turn_on()
		set src in view(1)
		if (!isliving(usr) || !my_gen || my_gen.active) return
		my_gen.turn_on()
		boutput(usr, "<span class='notice'>You turn the cloaking field generator on.</span>")

	verb/turn_off()
		set src in view(1)
		if (!isliving(usr) || !my_gen || !my_gen.active) return
		my_gen.turn_off()
		boutput(usr, "<span class='notice'>You turn the cloaking field generator off.</span>")
