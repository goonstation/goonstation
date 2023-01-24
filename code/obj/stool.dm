// CONTENTS:
// - Stools
// - Benches
// - Beds
// - Chairs
// - Syndicate Chairs (will trip you up)
// - Folded Chairs
// - Comfy Chairs
// - Shuttle Chairs
// - Wheelchairs
// - Wooden Chairs
// - Pews
// - Office Chairs
// - Electric Chairs

/* ================================================ */
/* -------------------- Stools -------------------- */
/* ================================================ */

/obj/stool
	name = "stool"
	desc = "A four-legged padded stool for crewmembers to relax on."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "stool"
	flags = FPRINT | FLUID_SUBMERGE
	throwforce = 10
	pressure_resistance = 3*ONE_ATMOSPHERE
	layer = STORAGE_LAYER //dumb
	var/allow_unbuckle = 1
	var/mob/living/buckled_guy = null
	var/deconstructable = 1
	var/securable = 0
	var/list/scoot_sounds = null
	var/parts_type = /obj/item/furniture_parts/stool
	material_amt = 0.1

	New()
		if (!src.anchored && src.securable) // we're able to toggle between being secured to the floor or not, and we started unsecured
			src.p_class = 2 // so make us easy to move
		..()

	ex_act(severity)
		switch(severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					if (src.deconstructable)
						src.deconstruct()
					else
						qdel(src)
					return
			if (3)
				if (prob(5))
					if (src.deconstructable)
						src.deconstruct()
					else
						qdel(src)
					return
			else
		return

	blob_act(var/power)
		if (prob(power * 2.5))
			var/obj/item/I = new /obj/item/raw_material/scrap_metal
			I.set_loc(get_turf(src))

			if (src.material)
				I.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				I.setMaterial(M)
			qdel(src)

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W) && src.deconstructable)
			actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 30), user)
			return
		else if (isscrewingtool(W) && src.securable)
			src.toggle_secure(user)
			return
		else if (istype(W, /obj/item/cloth/towel))
			user.visible_message("<span class='notice'>[user] wipes down [src] with [W].</span>")
		else
			return ..()

	proc/can_buckle(var/mob/living/to_buckle, var/mob/user)
		if (!istype(to_buckle) || isintangible(to_buckle) || isflockmob(to_buckle)) //no buckling AI-eyes
			return FALSE
		if (!ticker)
			boutput(user, "You can't buckle anyone in before the game starts.")
			return FALSE
		if (to_buckle.buckled)
			boutput(user, "They're already buckled into something!", "red")
			return FALSE
		if (BOUNDS_DIST(src, user) > 0 || to_buckle.loc != src.loc || user.restrained() || is_incapacitated(user) || !isalive(user))
			return FALSE
		if (user.hasStatus("weakened"))
			return FALSE
		if (src.buckled_guy && src.buckled_guy.buckled == src && to_buckle != src.buckled_guy)
			user.show_text("There's already someone buckled in [src]!", "red")
			return FALSE
		return TRUE

	proc/buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0) //Handles the actual buckling in
		if (!can_buckle(to_buckle,user))
			return FALSE

		if (to_buckle == user)
			user.visible_message("<span class='notice'><b>[to_buckle]</b> buckles in!</span>", "<span class='notice'>You buckle yourself in.</span>")
		else
			user.visible_message("<span class='notice'><b>[to_buckle]</b> is buckled in by [user].</span>", "<span class='notice'>You buckle in [to_buckle].</span>")

		to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
		return TRUE

	proc/unbuckle() //Ditto but for unbuckling
		if (src.buckled_guy)
			src.buckled_guy.end_chair_flip_targeting()

	proc/toggle_secure(mob/user as mob)
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the castors of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
		src.anchored = !(src.anchored)
		src.p_class = src.anchored ? initial(src.p_class) : 2
		return

	proc/deconstruct()
		if (!src.deconstructable)
			return
		if (ispath(src.parts_type))
			var/obj/item/furniture_parts/P = new src.parts_type(src.loc)
			if (P && src.material)
				P.setMaterial(src.material)
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			var/obj/item/sheet/S = new (src.loc)
			if (src.material)
				S.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				S.setMaterial(M)
		qdel(src)
		return

	Move(atom/target)
		. = ..()
		if (. && islist(scoot_sounds) && scoot_sounds.len && prob(75))
			playsound( get_turf(src), pick( scoot_sounds ), 50, 1 )

/obj/stool/bee_bed
	// idk. Not a bed proper since humans can't lay in it. Weirdos.
	// would also be cool to make these work with bees.
	// it's hip to tuck bees!
	name = "bee bed"
	icon = 'icons/misc/critter.dmi'
	icon_state = "beebed"
	desc = "A soft little bed the general size and shape of a space bee."
	parts_type = /obj/item/furniture_parts/stool/bee_bed

/obj/stool/bee_bed/double // Prefab variant
	name = "double bee bed"
	icon_state = "beebed_double"
	desc = "A bee bed shaped to accomodate two sleeping bees while also gently smushing them together, creating one of the most adorable sights in the universe."
	parts_type = /obj/item/furniture_parts/stool/bee_bed/double

/obj/stool/bar
	name = "bar stool"
	icon_state = "bar-stool"
	desc = "Like a stool, but in a bar."
	parts_type = /obj/item/furniture_parts/stool/bar

/obj/stool/neon
	name = "neon bar stool"
	icon_state = "neonstool"
	desc = "Like a bar stool, but in electric blue."
	parts_type = /obj/item/furniture_parts/stool/neon

/obj/stool/wooden
	name = "wooden stool"
	icon_state = "wstool"
	desc = "Like a stool, but just made out of wood."
	parts_type = /obj/item/furniture_parts/woodenstool
/* ================================================= */
/* -------------------- Benches -------------------- */
/* ================================================= */

/obj/stool/bench
	name = "bench"
	desc = "It's a bench! You can sit on it!"
	icon = 'icons/obj/furniture/bench.dmi'
	icon_state = "0"
	anchored = 1
	var/auto = 0
	var/auto_path = null
	parts_type = /obj/item/furniture_parts/bench

	New()
		..()
		SPAWN(0)
			if (src.auto && ispath(src.auto_path))
				src.set_up(1)

	proc/set_up(var/setup_others = 0)
		if (!src.auto || !ispath(src.auto_path))
			return
		var/dirs = 0
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (locate(src.auto_path) in T)
				dirs |= dir
		icon_state = num2text(dirs)
		if (setup_others)
			for (var/obj/stool/bench/B in orange(1,src))
				if (istype(B, src.auto_path))
					B.set_up()

	deconstruct()
		if (!src.deconstructable)
			return
		var/oldloc = src.loc
		..()
		for (var/obj/stool/bench/B in orange(1,oldloc))
			if (B.auto)
				B.set_up()
		return

/obj/stool/bench/auto
	auto = 1
	auto_path = /obj/stool/bench/auto

/* ---------- Red ---------- */

/obj/stool/bench/red
	icon = 'icons/obj/furniture/bench_red.dmi'
	parts_type = /obj/item/furniture_parts/bench/red

/obj/stool/bench/red/auto
	auto = 1
	auto_path = /obj/stool/bench/red/auto

/* ---------- Blue ---------- */

/obj/stool/bench/blue
	icon = 'icons/obj/furniture/bench_blue.dmi'
	parts_type = /obj/item/furniture_parts/bench/blue

/obj/stool/bench/blue/auto
	auto = 1
	auto_path = /obj/stool/bench/blue/auto

/* ---------- Green ---------- */

/obj/stool/bench/green
	icon = 'icons/obj/furniture/bench_green.dmi'
	parts_type = /obj/item/furniture_parts/bench/green

/obj/stool/bench/green/auto
	auto = 1
	auto_path = /obj/stool/bench/green/auto

/* ---------- Yellow ---------- */

/obj/stool/bench/yellow
	icon = 'icons/obj/furniture/bench_yellow.dmi'
	parts_type = /obj/item/furniture_parts/bench/yellow

/obj/stool/bench/yellow/auto
	auto = 1
	auto_path = /obj/stool/bench/yellow/auto

/* ---------- Wooden ---------- */

/obj/stool/bench/wooden
	icon = 'icons/obj/furniture/bench_wood.dmi'
	parts_type = /obj/item/furniture_parts/bench/wooden

/obj/stool/bench/wooden/auto
	auto = 1
	auto_path = /obj/stool/bench/wooden/auto

/* ---------- Sauna ---------- */

/obj/stool/bench/sauna
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "saunabench"

/* ============================================== */
/* -------------------- beds -------------------- */
/* ============================================== */

/obj/stool/bed
	name = "bed"
	desc = "A solid metal frame with some padding on it, useful for sleeping on."
	icon_state = "bed"
	anchored = 1
	var/security = 0
	var/obj/item/clothing/suit/bedsheet/sheet = null
	parts_type = /obj/item/furniture_parts/bed
	material_amt = 0.2

	brig
		name = "brig cell bed"
		desc = "It doesn't look very comfortable. Fortunately there's no way to be buckled to it."
		security = 1
		parts_type = null

	moveable
		name = "roller bed"
		desc = "A solid metal frame with some padding on it, useful for sleeping on. This one has little wheels on it, neat!"
		anchored = 0
		securable = 1
		icon_state = "rollerbed"
		parts_type = /obj/item/furniture_parts/bed/roller
		scoot_sounds = list( 'sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg' )

	New()
		..()
		START_TRACKING

	Move()
		if(src.buckled_guy?.loc != src.loc)
			src.unbuckle()
		. = ..()
		if (. && src.buckled_guy)
			var/mob/living/carbon/C = src.buckled_guy
			C.buckled = null
			C.Move(src.loc)
			C.buckled = src

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/clothing/suit/bedsheet))
			src.tuck_sheet(W, user)
			return
		if (iswrenchingtool(W) && !src.deconstructable)
			boutput(user, "<span class='alert'>You briefly ponder how to go about disassembling a featureless slab using a wrench. You quickly give up.</span>")
			return
		else
			return ..()

	attack_hand(mob/user)
		..()
		if (src.sheet)
			src.untuck_sheet(user)
		for (var/mob/M in src.loc)
			src.unbuckle_mob(M, user)
		return

	can_buckle(var/mob/living/C, var/mob/user)
		if (!..())
			return FALSE
		if (src.security)
			user.show_text("There's nothing you can buckle them to!", "red")
			return FALSE
		return TRUE

	proc/unbuckle_mob(var/mob/M as mob, var/mob/user as mob)
		if (M.buckled && !user.restrained())
			if (allow_unbuckle)
				if (M != user)
					user.visible_message("<span class='notice'><b>[M]</b> is unbuckled by [user].</span>", "<span class='notice'>You unbuckle [M].</span>")
				else
					user.visible_message("<span class='notice'><b>[M]</b> unbuckles.</span>", "<span class='notice'>You unbuckle.</span>")
				unbuckle()
			else
				user.show_text("Seems like the buckle is firmly locked into place.", "red")

			src.add_fingerprint(user)

	buckle_in(mob/living/to_buckle, mob/living/user)
		if(src.buckled_guy && src.buckled_guy.buckled == src)
			return FALSE
		if (!can_buckle(to_buckle,user))
			return FALSE

		if (to_buckle == user)
			user.visible_message("<span class='notice'><b>[to_buckle]</b> lies down on [src], fastening the buckles!</span>", "<span class='notice'>You lie down and buckle yourself in.</span>")
		else
			user.visible_message("<span class='notice'><b>[to_buckle]</b> is buckled in by [user].</span>", "<span class='notice'>You buckle in [to_buckle].</span>")

		to_buckle.lying = 1
		if (src.anchored)
			to_buckle.anchored = 1
		to_buckle.buckled = src
		src.buckled_guy = to_buckle
		to_buckle.set_loc(src.loc)

		to_buckle.set_clothing_icon_dirty()
		playsound(src, 'sound/misc/belt_click.ogg', 50, 1)
		to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
		return TRUE

	unbuckle()
		..()
		if(src.buckled_guy && src.buckled_guy.buckled == src)
			reset_anchored(buckled_guy)
			buckled_guy.buckled = null
			buckled_guy.force_laydown_standup()
			src.buckled_guy = null
			playsound(src, 'sound/misc/belt_click.ogg', 50, 1)

	proc/tuck_sheet(var/obj/item/clothing/suit/bedsheet/newsheet as obj, var/mob/user as mob)
		if (!newsheet || newsheet.cape || (src.sheet == newsheet && newsheet.loc == src.loc)) // if we weren't provided a new bedsheet, the new bedsheet we got is tied into a cape, or the new bedsheet is actually the one we already have and is still in the same place as us...
			return // nevermind

		if (src.sheet && src.sheet.loc != src.loc) // a safety check: do we have a sheet and is it not where we are?
			if (src.sheet.bed && src.sheet.bed == src) // does our sheet have us listed as its bed?
				src.sheet.bed = null // set its bed to null
			src.sheet = null // then set our sheet to null: it's not where we are!

		if (src.sheet && src.sheet != newsheet) // do we have a sheet, and is the new sheet we've been given not our sheet?
			user.show_text("You try to kinda cram [newsheet] into the edges of [src], but there's not enough room with [src.sheet] tucked in already!", "red")
			return // they're crappy beds, okay?  there's not enough space!

		if (!src.sheet && (newsheet.loc == src.loc || user.find_in_hand(newsheet))) // finally, do we have room for the new sheet, and is the sheet where we are or in the hand of the user?
			src.sheet = newsheet // let's get this shit DONE!
			newsheet.bed = src
			user.u_equip(newsheet)
			newsheet.set_loc(src.loc)
			LAZYLISTADDUNIQUE(src.attached_objs, newsheet)

			var/mob/somebody
			if (src.buckled_guy)
				somebody = src.buckled_guy
			else
				somebody = locate(/mob/living/carbon) in get_turf(src)
			if (somebody?.lying)
				user.tri_message(somebody, "<span class='notice'><b>[user]</b> tucks [somebody == user ? "[him_or_her(user)]self" : "[somebody]"] into bed.</span>",\
					"<span class='notice'>You tuck [somebody == user ? "yourself" : "[somebody]"] into bed.</span>",\
					"<span class='notice'>[somebody == user ? "You tuck yourself" : "<b>[user]</b> tucks you"] into bed.</span>")
				newsheet.layer = EFFECTS_LAYER_BASE-1
			else
				user.visible_message("<span class='notice'><b>[user]</b> tucks [newsheet] into [src].</span>",\
				"<span class='notice'>You tuck [newsheet] into [src].</span>")

	proc/untuck_sheet(var/mob/user as mob)
		if (!src.sheet) // vOv
			return // there's nothing to do here, everyone go home

		var/obj/item/clothing/suit/bedsheet/oldsheet = src.sheet

		if (user)
			var/mob/somebody
			if (src.buckled_guy)
				somebody = src.buckled_guy
			else
				somebody = locate(/mob/living/carbon) in get_turf(src)
			if (somebody?.lying)
				user.tri_message(somebody, "<span class='notice'><b>[user]</b> untucks [somebody == user ? "[him_or_her(user)]self" : "[somebody]"] from bed.</span>",\
					"<span class='notice'>You untuck [somebody == user ? "yourself" : "[somebody]"] from bed.</span>",\
					"<span class='notice'>[somebody == user ? "You untuck yourself" : "<b>[user]</b> untucks you"] from bed.</span>")
				oldsheet.layer = initial(oldsheet.layer)
			else
				user.visible_message("<span class='notice'><b>[user]</b> untucks [oldsheet] from [src].</span>",\
				"<span class='notice'>You untuck [oldsheet] from [src].</span>")

		if (oldsheet.bed == src) // just in case it's somehow not us
			oldsheet.bed = null
		mutual_detach(src, oldsheet)
		src.sheet = null

	MouseDrop_T(atom/A as mob|obj, mob/user as mob)
		if (BOUNDS_DIST(src, user) > 0 || A.loc != src.loc || user.restrained() || !isalive(user))
			..()
		else if (istype(A, /obj/item/clothing/suit/bedsheet))
			if ((!src.sheet || (src.sheet && src.sheet.loc != src.loc)) && A.loc == src.loc)
				src.tuck_sheet(A, user)
				return
			if (src.sheet && A == src.sheet)
				src.untuck_sheet(user)
				return

		else if (ismob(A))
			src.buckle_in(A, user)
			var/mob/M = A
			if (isdead(M) && M != user && emergency_shuttle?.location == SHUTTLE_LOC_STATION) // 1 should be SHUTTLE_LOC_STATION
				var/area/shuttle/escape/station/area = get_area(M)
				if (istype(area))
					user.unlock_medal("Leave no man behind!", 1)
			src.add_fingerprint(user)
		else
			return ..()

	disposing()
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.buckled_guy = null
				M.lying = 0
				reset_anchored(M)
		if (src.sheet && src.sheet.bed == src)
			src.sheet.bed = null
			src.sheet = null
		STOP_TRACKING
		..()

	proc/sleep_in(var/mob/M)
		if (!ishuman(M))
			return

		var/mob/living/carbon/user = M

		if (isdead(user))
			boutput(user, "<span class='alert'>Some would say that death is already the big sleep.</span>")
			return

		if ((get_turf(user) != src.loc) || (!user.lying))
			boutput(user, "<span class='alert'>You must be lying down on [src] to sleep on it.</span>")
			return

		user.setStatus("resting", INFINITE_STATUS)
		user.sleeping = 4
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			H.hud.update_resting()

/* ================================================ */
/* -------------------- Chairs -------------------- */
/* ================================================ */

/obj/stool/chair
	name = "chair"
	desc = "A four-legged metal chair, rigid and slightly uncomfortable. Helpful when you don't want to use your legs at the moment."
	icon_state = "chair"
	var/comfort_value = 3
	var/buckledIn = 0
	var/status = 0
	var/rotatable = 1
	var/foldable = 1
	var/climbable = 1
	var/buckle_move_delay = 6 // this should have been a var somepotato WHY WASN'T IT A VAR
	var/obj/item/clothing/head/butt/has_butt = null // time for mature humour
	var/image/butt_img
	securable = 1
	anchored = 1
	scoot_sounds = list( 'sound/misc/chair/normal/scoot1.ogg', 'sound/misc/chair/normal/scoot2.ogg', 'sound/misc/chair/normal/scoot3.ogg', 'sound/misc/chair/normal/scoot4.ogg', 'sound/misc/chair/normal/scoot5.ogg' )
	parts_type = null
	material_amt = 0.1

	moveable
		anchored = 0

	New()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		butt_img = image('icons/obj/furniture/chairs.dmi')
		butt_img.layer = OBJ_LAYER + 0.5 //In between OBJ_LAYER and MOB_LAYER
		..()
		return

	Move()
		if(src.buckled_guy?.loc != src.loc)
			src.unbuckle()

		. = ..()
		if (.)
			if (src.dir == NORTH)
				src.layer = FLY_LAYER+1
			else
				src.layer = OBJ_LAYER

			if (src.buckled_guy)
				var/mob/living/carbon/C = src.buckled_guy
				C.buckled = null
				C.Move(src.loc)
				C.buckled = src

		if(src.buckled_guy?.loc != src.loc)
			src.unbuckle()

	toggle_secure(mob/user as mob)
		if (istype(get_turf(src), /turf/space))
			if (user)
				user.show_text("What exactly are you gunna secure [src] to?", "red")
			return
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "unscrews [src] from" : "secures [src] to"] the floor.")
		playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
		src.anchored = !(src.anchored)
		src.p_class = src.anchored ? initial(src.p_class) : 2
		return

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W) && has_butt)
			user.put_in_hand_or_drop(has_butt)
			boutput(user, "<span class='notice'>You pry [has_butt.name] from [name].</span>")
			has_butt = null
			UpdateOverlays(null, "chairbutt")
			return
		if (istype(W, /obj/item/clothing/head/butt) && !has_butt)
			has_butt = W
			user.u_equip(has_butt)
			has_butt.set_loc(src)
			boutput(user, "<span class='notice'>You place [has_butt.name] on [name].</span>")
			butt_img.icon_state = "chair_[has_butt.icon_state]"
			UpdateOverlays(butt_img, "chairbutt")
			return
		if (istype(W, /obj/item/assembly/shock_kit))
			var/obj/stool/chair/e_chair/E = new /obj/stool/chair/e_chair(src.loc)
			if (src.material)
				E.setMaterial(src.material)
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			E.set_dir(src.dir)
			E.part1 = W
			W.set_loc(E)
			W.master = E
			user.u_equip(W)
			W.layer = initial(W.layer)
			qdel(src)
			return
		else
			return ..()

	attack_hand(mob/user)
		if (!isliving(user)) return
		var/mob/living/L = user
		var/mob/living/carbon/human/chair_chump = null
		for (var/mob/living/M in src.loc)

			if (ishuman(M))
				chair_chump = M
			if (!chair_chump || !chair_chump.on_chair)
				chair_chump = null
			if (chair_chump)// == 1)
				if (chair_chump == L)
					user.visible_message("<span class='notice'><b>[chair_chump]</b> steps off [chair_chump.on_chair].</span>", "<span class='notice'>You step off [src].</span>")
					src.add_fingerprint(user)
					unbuckle()
					return

			if (M.buckled && M != chair_chump)
				if (allow_unbuckle)
					if(user.restrained())
						return
					if (M != user)
						user.visible_message("<span class='notice'><b>[M]</b> is unbuckled by [user].</span>", "<span class='notice'>You unbuckle [M].</span>")
					else
						user.visible_message("<span class='notice'><b>[M]</b> unbuckles.</span>", "<span class='notice'>You unbuckle.</span>")
					src.add_fingerprint(user)
					unbuckle()
					return
				else
					user.show_text("Seems like the buckle is firmly locked into place.", "red")
					return

		if (src.foldable)
			user.visible_message("<b>[user.name] folds [src].</b>")
			if ((chair_chump) && (chair_chump != user))
				chair_chump.visible_message("<span class='alert'><b>[chair_chump.name] falls off of [src]!</b></span>")
				chair_chump.on_chair = null
				chair_chump.pixel_y = 0
				chair_chump.changeStatus("weakened", 1 SECOND)
				chair_chump.changeStatus("stunned", 2 SECONDS)
				random_brute_damage(chair_chump, 15)
				playsound(chair_chump.loc, "swing_hit", 50, 1)
				chair_chump.end_chair_flip_targeting()

			var/obj/item/chair/folded/C = null
			if(istype(src, /obj/stool/chair/syndicate))
				C = new/obj/item/chair/folded/syndicate(src.loc)
			else
				C = new/obj/item/chair/folded(src.loc)
			if (src.material)
				C.setMaterial(src.material)
			if (src.icon_state)
				C.c_color = src.icon_state
				C.icon_state = "folded_[src.icon_state]"
				C.item_state = C.icon_state

			qdel(src)
		else
			src.rotate()

		return

	MouseDrop_T(mob/M as mob, mob/user as mob)
		..()
		if (M == user)
			if (user.a_intent == INTENT_GRAB)
				if(climbable)
					buckle_in(M, user, 1)
				else
					boutput(user, "<span class='alert'>[src] isn't climbable.</span>")
			else
				buckle_in(M,user)
		else
			buckle_in(M,user)
			if (isdead(M) && M != user && emergency_shuttle?.location == SHUTTLE_LOC_STATION) // 1 should be SHUTTLE_LOC_STATION
				var/area/shuttle/escape/station/A = get_area(M)
				if (istype(A))
					user.unlock_medal("Leave no man behind!", 1)
		return

	mouse_drop(atom/over_object as mob|obj)
		if(BOUNDS_DIST(src,usr) == 0)
			src.rotate(get_dir(get_turf(src),get_turf(over_object)))
		..()

	buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0)
		if (!can_buckle(to_buckle,user))
			return FALSE

		if(stand && ishuman(to_buckle))
			if(ON_COOLDOWN(to_buckle, "chair_stand", 1 SECOND))
				return
			user.visible_message("<span class='notice'><b>[to_buckle]</b> climbs up on [src]!</span>", "<span class='notice'>You climb up on [src].</span>")

			var/mob/living/carbon/human/H = to_buckle
			to_buckle.set_loc(src.loc)
			to_buckle.pixel_y = 10
			if (src.anchored)
				to_buckle.anchored = 1
			H.on_chair = src
			to_buckle.buckled = src
			src.buckled_guy = to_buckle
			src.buckledIn = 1
			to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
			H.start_chair_flip_targeting()
		else
			if (to_buckle == user)
				user.visible_message("<span class='notice'><b>[to_buckle]</b> buckles in!</span>", "<span class='notice'>You buckle yourself in.</span>")
			else
				user.visible_message("<span class='notice'><b>[to_buckle]</b> is buckled in by [user].</span>", "<span class='notice'>You buckle in [to_buckle].</span>")

			if (src.anchored)
				to_buckle.anchored = 1
			to_buckle.buckled = src
			src.buckled_guy = to_buckle
			to_buckle.set_loc(src.loc)
			src.buckledIn = 1
			to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
		if (has_butt)
			playsound(src, (has_butt.sound_fart ? has_butt.sound_fart : 'sound/voice/farts/fart1.ogg'), 50, 1)
		else
			playsound(src, 'sound/misc/belt_click.ogg', 50, 1)
		return TRUE


	unbuckle()
		..()
		if(!src.buckled_guy) return

		var/mob/living/M = src.buckled_guy
		var/mob/living/carbon/human/H = src.buckled_guy

		M.end_chair_flip_targeting()

		if (istype(H) && H.on_chair)
			M.pixel_y = 0
			reset_anchored(M)
			M.buckled = null
			buckled_guy.force_laydown_standup()
			SPAWN(0.5 SECONDS)
				H.on_chair = null
				src.buckledIn = 0
		else if ((M.buckled))
			reset_anchored(M)
			M.buckled = null
			buckled_guy.force_laydown_standup()
			SPAWN(0.5 SECONDS)
				src.buckledIn = 0

		src.buckled_guy = null

		playsound(src, 'sound/misc/belt_click.ogg', 50, 1)

	ex_act(severity)
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.buckled_guy = null
		switch (severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					qdel(src)
					return
			if (3)
				if (prob(5))
					qdel(src)
					return
		return

	blob_act(var/power)
		if (prob(power * 2.5))
			for (var/mob/M in src.loc)
				if (M.buckled == src)
					M.buckled = null
					src.buckled_guy = null
			qdel(src)

	disposing()
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.buckled_guy = null
		if (has_butt)
			has_butt.set_loc(loc)
		has_butt = null
		..()
		return

	Click(location,control,params)
		var/lpm = params2list(params)
		if(istype(usr, /mob/dead/observer) && !lpm["ctrl"] && !lpm["shift"] && !lpm["alt"])
			rotate()

#ifdef HALLOWEEN
			if (istype(usr.abilityHolder, /datum/abilityHolder/ghost_observer))
				var/datum/abilityHolder/ghost_observer/GH = usr.abilityHolder
				GH.change_points(3)
#endif
		else return ..()

	proc/rotate(var/face_dir = 0)
		if (rotatable)
			if (!face_dir)
				src.set_dir(turn(src.dir, 90))
			else
				src.set_dir(face_dir)

			if (src.dir == NORTH)
				src.layer = FLY_LAYER+1
			else
				src.layer = OBJ_LAYER
			if (buckled_guy)
				var/mob/living/carbon/C = src.buckled_guy
				C.set_dir(dir)
		return

	blue
		icon_state = "chair-b"

	yellow
		icon_state = "chair-y"

	red
		icon_state = "chair-r"

	green
		icon_state = "chair-g"

/* ========================================================== */
/* -------------------- Syndicate Chairs -------------------- */
/* ========================================================== */

/obj/stool/chair/syndicate
	desc = "That chair is giving off some bad vibes."
	comfort_value = -5
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER

	HasProximity(atom/movable/AM as mob|obj)
		if (isliving(AM) && !isintangible(AM) && prob(40) && !AM.hasStatus("weakened"))
			src.visible_message("<span class='alert'>[src] trips [AM]!</span>", "<span class='alert'>You hear someone fall.</span>")
			AM.changeStatus("weakened", 2 SECONDS)
		return

/* ======================================================= */
/* -------------------- Folded Chairs -------------------- */
/* ======================================================= */

/obj/item/chair/folded
	name = "chair"
	desc = "A folded chair. Good for smashing noggin-shaped things."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "folded_chair"
	item_state = "folded_chair"
	w_class = W_CLASS_BULKY
	throwforce = 10
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 5
	stamina_damage = 45
	stamina_cost = 21
	stamina_crit_chance = 10
	material_amt = 0.1
	var/c_color = null

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_LARGE)

	syndicate
		desc = "That chair is giving off some bad vibes."

/obj/item/chair/folded/attack_self(mob/user as mob)
	if(cant_drop == 1)
		boutput(user, "You can't unfold the [src] when its attached to your arm!")
		return
	var/obj/stool/chair/C = null
	if(istype(src, /obj/item/chair/folded/syndicate))
		C = new/obj/stool/chair/syndicate(user.loc)
	else
		C = new/obj/stool/chair(user.loc)
	if (src.material)
		C.setMaterial(src.material)
	if (src.c_color)
		C.icon_state = src.c_color
	C.set_dir(user.dir)
	ON_COOLDOWN(user, "chair_stand", 1 SECOND)
	boutput(user, "You unfold [C].")
	user.drop_item()
	qdel(src)
	return

/obj/item/chair/folded/attack(atom/target as mob, mob/user as mob, params)
	var/oldcrit = src.stamina_crit_chance
	if(iswrestler(user))
		src.stamina_crit_chance = 100
	if (ishuman(target))
		playsound(src.loc, pick(sounds_punch), 100, 1)
	..()
	src.stamina_crit_chance = oldcrit

/* ====================================================== */
/* -------------------- Comfy Chairs -------------------- */
/* ====================================================== */

/obj/stool/chair/comfy
	name = "comfy brown chair"
	desc = "This advanced seat commands authority and respect. Everyone is super envious of whoever sits in this chair."
	icon_state = "chair_comfy"
	comfort_value = 7
	foldable = 0
	deconstructable = 1
//	var/atom/movable/overlay/overl = null
	var/image/arm_image = null
	var/arm_icon_state = "arm"
	parts_type = /obj/item/furniture_parts/comfy_chair

	New()
		..()
		UpdateIcon()
/* what in the unholy mother of god was this about
		src.overl = new /atom/movable/overlay( src.loc )
		src.overl.icon = 'icons/obj/objects.dmi'
		src.overl.icon_state = "arm"
		src.overl.layer = 6// TODO Layer wtf
		src.overl.name = "chair arm"
		src.overl.master = src
		src.overl.set_dir(src.dir)
*/
	rotate()
		set src in oview(1)
		set category = "Local"

		src.set_dir(turn(src.dir, 90))
//		src.overl.set_dir(src.dir)
		src.UpdateIcon()
		if (buckled_guy)
			var/mob/living/carbon/C = src.buckled_guy
			C.set_dir(dir)
		return


	update_icon()

		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		else
			src.layer = OBJ_LAYER
			if ((src.dir == WEST || src.dir == EAST) && !src.arm_image)
				src.arm_image = image(src.icon, src.arm_icon_state)
				src.arm_image.layer = FLY_LAYER+1
				src.UpdateOverlays(src.arm_image, "arm")

	blue
		name = "comfy blue chair"
		icon_state = "chair_comfy-blue"
		arm_icon_state = "arm-blue"
		parts_type = /obj/item/furniture_parts/comfy_chair/blue

	red
		name = "comfy red chair"
		icon_state = "chair_comfy-red"
		arm_icon_state = "arm-red"
		parts_type = /obj/item/furniture_parts/comfy_chair/red

	green
		name = "comfy green chair"
		icon_state = "chair_comfy-green"
		arm_icon_state = "arm-green"
		parts_type = /obj/item/furniture_parts/comfy_chair/green

	yellow
		name = "comfy yellow chair"
		icon_state = "chair_comfy-yellow"
		arm_icon_state = "arm-yellow"
		parts_type = /obj/item/furniture_parts/comfy_chair/yellow

	purple
		name = "comfy purple chair"
		icon_state = "chair_comfy-purple"
		arm_icon_state = "arm-purple"
		parts_type = /obj/item/furniture_parts/comfy_chair/purple

/obj/stool/chair/comfy/throne_gold
	name = "golden throne"
	desc = "This throne commands authority and respect. Everyone is super envious of whoever sits in this chair."
	icon_state = "thronegold"
	arm_icon_state = "thronegold-arm"
	comfort_value = 7
	anchored = 0
	deconstructable = 1
	parts_type = /obj/item/furniture_parts/throne_gold

/* ======================================================== */
/* -------------------- Shuttle Chairs -------------------- */
/* ======================================================== */

/obj/stool/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "Equipped with a safety buckle and a tray on the back for the person behind you to use!"
	icon_state = "shuttle_chair"
	arm_icon_state = "shuttle_chair-arm"
	comfort_value = 5
	deconstructable = 0
	parts_type = null

	red
		icon_state = "shuttle_chair-red"
	brown
		icon_state = "shuttle_chair-brown"
	green
		icon_state = "shuttle_chair-green"

/obj/stool/chair/comfy/shuttle/pilot
	name = "pilot's seat"
	desc = "Only the most important crew member gets to sit here. Everyone is super envious of whoever sits in this chair."
	icon_state = "shuttle_chair-pilot"
	arm_icon_state = "shuttle_chair-pilot-arm"
	comfort_value = 7

/* ===================================================== */
/* -------------------- Wheelchairs -------------------- */
/* ===================================================== */

TYPEINFO(/obj/stool/chair/comfy/wheelchair)
	mats = 15

/obj/stool/chair/comfy/wheelchair
	name = "wheelchair"
	desc = "It's a chair that has wheels attached to it. Do I really have to explain this to you? Can you not figure this out on your own? Wheelchair. Wheel, chair. Chair that has wheels."
	icon_state = "wheelchair"
	arm_icon_state = "arm-wheelchair"
	anchored = 0
	comfort_value = 3
	buckle_move_delay = 1
	p_class = 2
	scoot_sounds = list('sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg')
	var/lying = 0 // didja get knocked over? fall down some stairs?
	parts_type = /obj/item/furniture_parts/wheelchair
	mat_appearances_to_ignore = list("steel")

	New()
		..()
		if (src.lying)
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying

	update_icon()

		ENSURE_IMAGE(src.arm_image, src.icon, src.arm_icon_state)
		src.arm_image.layer = FLY_LAYER+1
		src.UpdateOverlays(src.arm_image, "arm")

	proc/fall_over(var/turf/T)
		if (src.lying)
			return
		if (src.buckled_guy)
			var/mob/living/M = src.buckled_guy
			src.unbuckle()
			if (M && !src.buckled_guy)
				M.visible_message("<span class='alert'>[M] is tossed out of [src] as it tips [T ? "while rolling over [T]" : "over"]!</span>",\
				"<span class='alert'>You're tossed out of [src] as it tips [T ? "while rolling over [T]" : "over"]!</span>")
				var/turf/target = get_edge_target_turf(src, src.dir)
				M.throw_at(target, 3, 1)
				M.changeStatus("stunned", 5 SECONDS)
				M.changeStatus("weakened", 3 SECONDS)
			else
				src.visible_message("<span class='alert'>[src] tips [T ? "as it rolls over [T]" : "over"]!</span>")
		else
			src.visible_message("<span class='alert'>[src] tips [T ? "as it rolls over [T]" : "over"]!</span>")
		src.lying = 1
		animate_rest(src, !src.lying)
		src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying
		src.scoot_sounds = list('sound/misc/chair/normal/scoot1.ogg', 'sound/misc/chair/normal/scoot2.ogg', 'sound/misc/chair/normal/scoot3.ogg', 'sound/misc/chair/normal/scoot4.ogg', 'sound/misc/chair/normal/scoot5.ogg')

	attack_hand(mob/user)
		if (src.lying)
			user.visible_message("[user] sets [src] back on its wheels.",\
			"You set [src] back on its wheels.")
			src.lying = 0
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying
			src.scoot_sounds = scoot_sounds = list('sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg')
			return
		else
			return ..()

	buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0)
		if (src.lying)
			return FALSE
		. = ..()
		if (.)
			APPLY_MOVEMENT_MODIFIER(to_buckle, /datum/movement_modifier/wheelchair, src.type)
			return TRUE

	unbuckle()
		if(src.buckled_guy)
			REMOVE_MOVEMENT_MODIFIER(src.buckled_guy, /datum/movement_modifier/wheelchair, src.type)
		return ..()

	set_loc(newloc)
		. = ..()
		unbuckle()

/* ======================================================= */
/* -------------------- Wooden Chairs -------------------- */
/* ======================================================= */

/obj/stool/chair/wooden
	name = "wooden chair"
	icon_state = "chair_wooden" // this sprite is bad I will fix it at some point
	comfort_value = 3
	foldable = 0
	anchored = 0
	//deconstructable = 0
	parts_type = /obj/item/furniture_parts/wood_chair

	regal
		name = "regal chair"
		desc = "Much more comfortable than the average dining chair, and much more expensive."
		icon_state = "regalchair"
		comfort_value = 7
		parts_type = /obj/item/furniture_parts/wood_chair/regal

	scrap
		name = "scrap chair"
		desc = "Hopefully you didn't pay actual money for this."
		icon_state = "scrapchair"
		comfort_value = 7
		parts_type = /obj/item/furniture_parts/wood_chair/scrap

/* ============================================== */
/* -------------------- Pews -------------------- */
/* ============================================== */

/obj/stool/chair/pew // pew pew
	name = "pew"
	desc = "It's like a bench, but more holy. No, not <i>holey</i>, <b>holy</b>. Like, godly, divine. That kinda thing.<br>Okay, it's actually kind of holey, too, now that you look at it closer."
	icon_state = "pew"
	anchored = 1
	rotatable = 0
	foldable = 0
	comfort_value = 2
	deconstructable = TRUE
	securable = 0
	parts_type = /obj/item/furniture_parts/bench/pew
	var/image/arm_image = null
	var/arm_icon_state = null

	New()
		..()
		if (arm_icon_state)
			src.UpdateIcon()

	update_icon()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		else
			src.layer = OBJ_LAYER
			if ((src.dir == WEST || src.dir == EAST) && !src.arm_image)
				src.arm_image = image(src.icon, src.arm_icon_state)
				src.arm_image.layer = FLY_LAYER+1
				src.UpdateOverlays(src.arm_image, "arm")

	left
		icon_state = "pewL"
	center
		icon_state = "pewC"
	right
		icon_state = "pewR"

/obj/stool/chair/pew/fancy
	icon_state = "fpew"
	arm_icon_state = "arm-fpew"

	left
		icon_state = "fpewL"
		arm_icon_state = "arm-fpewL"
	center
		icon_state = "fpewC"
		arm_icon_state = null
	right
		icon_state = "fpewR"
		arm_icon_state = "arm-fpewR"

/* ================================================= */
/* -------------------- Couches -------------------- */
/* ================================================= */

/obj/stool/chair/couch
	name = "comfy brown couch"
	desc = "You've probably lost some space credits in these things before."
	icon_state = "chair_couch-brown"
	rotatable = 0
	foldable = 0
	var/damaged = 0
	comfort_value = 5
	deconstructable = 0
	securable = 0
	var/max_uses = 0 // The maximum amount of time one can try to look under the cushions for items.
	var/spawn_chance = 0 // How likely is this couch to spawn something?
	var/last_use = 0 // To prevent spam.
	var/time_between_uses = 400 // The default time between uses.
	var/list/items = list (/obj/item/device/light/zippo,
	/obj/item/wrench,
	/obj/item/device/multitool,
	/obj/item/toy/plush/small/buddy,
	/obj/item/toy/plush/small/stress_ball,
	/obj/item/paper/lunchbox_note,
	/obj/item/plant/herb/cannabis/spawnable,
	/obj/item/reagent_containers/food/snacks/candy/candyheart,
	/obj/item/bananapeel,
	/obj/item/reagent_containers/food/snacks/lollipop/random_medical,
	/obj/item/spacecash/random/small,
	/obj/item/spacecash/random/tourist,
	/obj/item/spacecash/buttcoin)

	New()
		..()
		if (src.dir in ordinal)
			src.layer = FLY_LAYER+1
		max_uses = rand(0, 2) // Losing things in a couch is hard.
		spawn_chance = rand(1, 20)

		if (prob(10)) //time to flail
			items.Add(/obj/critter/meatslinky)

		if (prob(1))
			desc = "A vague feeling of loss emanates from this couch, as if it is missing a part of itself. A global list of couches, perhaps."

	disposing()
		..()

	proc/damage(severity)
		if(severity > 1 && damaged < 2)
			damaged += 2
			overlays += image('icons/obj/objects.dmi', "couch-tear")
		else if(damaged < 1)
			damaged += 1
			overlays += image('icons/obj/objects.dmi', "couch-rip")

	attack_hand(mob/user)
		if (!user) return
		if (damaged || buckled_guy) return ..()

		user.lastattacked = src

		playsound(src.loc, "rustle", 66, 1, -5) // todo: find a better sound.

		if (max_uses > 0 && ((last_use + time_between_uses) < world.time) && prob(spawn_chance))

			var/something = pick(items)

			if (ispath(something))
				var/thing = new something(src.loc)
				user.put_in_hand_or_drop(thing)
				if (istype(thing, /obj/critter/meatslinky)) //slink slink
					user.emote("scream")
					random_brute_damage(user, 10)
					user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls [his_or_her(user)] hand out in pain! \An [thing] slithers out of \the [src]!</span>",\
					"<span class='notice'>You rummage through the seams and behind the cushions of [src] and your hand gets bit by \an [thing]!</span>")
				else
					user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls \an [thing] out of it!</span>",\
					"<span class='notice'>You rummage through the seams and behind the cushions of [src] and you find \an [thing]!</span>")
				last_use = world.time
				max_uses--

		else if (max_uses <= 0)
			user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls out absolutely nothing!</span>",\
			"<span class='notice'>You rummage through the seams and behind the cushions of [src] and pull out absolutely nothing!</span>")
		else
			user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src]!</span>",\
			"<span class='notice'>You rummage through the seams and behind the cushions of [src]!</span>")

	blue
		name = "comfy blue couch"
		icon_state = "chair_couch-blue"

	red
		name = "comfy red couch"
		icon_state = "chair_couch-red"

	green
		name = "comfy green couch"
		icon_state = "chair_couch-green"

	yellow
		name = "comfy yellow couch"
		icon_state = "chair_couch-yellow"

	purple
		name = "comfy purple couch"
		icon_state = "chair_couch-purple"

/* ======================================================= */
/* -------------------- Office Chairs -------------------- */
/* ======================================================= */

/obj/stool/chair/office
	name = "office chair"
	desc = "Hey, you remember spinning around on one of these things as a kid!"
	icon_state = "office_chair"
	comfort_value = 4
	foldable = 0
	anchored = 0
	buckle_move_delay = 3
	//deconstructable = 0
	parts_type = /obj/item/furniture_parts/office_chair
	scoot_sounds = list( 'sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg' )

	red
		icon_state = "office_chair_red"
		parts_type = /obj/item/furniture_parts/office_chair/red

	green
		icon_state = "office_chair_green"
		parts_type = /obj/item/furniture_parts/office_chair/green

	blue
		icon_state = "office_chair_blue"
		parts_type = /obj/item/furniture_parts/office_chair/blue

	yellow
		icon_state = "office_chair_yellow"
		parts_type = /obj/item/furniture_parts/office_chair/yellow

	purple
		icon_state = "office_chair_purple"
		parts_type = /obj/item/furniture_parts/office_chair/purple

	syndie
		icon_state = "syndiechair"
		parts_type = null

	toggle_secure(mob/user as mob)
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the castors of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
		src.anchored = !(src.anchored)
		return

/* ========================================================= */
/* -------------------- Electric Chairs -------------------- */
/* ========================================================= */

/obj/stool/chair/e_chair
	name = "electrified chair"
	desc = "A chair that has been modified to conduct current with over 2000 volts, enough to kill a human nearly instantly."
	icon_state = "e_chair0"
	foldable = 0
	var/on = 0
	var/obj/item/assembly/shock_kit/part1 = null
	var/last_time = 1
	var/lethal = 0
	var/image/image_belt = null
	comfort_value = -3
	securable = 0

	New()
		..()
		SPAWN(2 SECONDS)
			if (src)
				if (!(src.part1 && istype(src.part1)))
					src.part1 = new /obj/item/assembly/shock_kit(src)
					src.part1.master = src
				src.UpdateIcon()
		return

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			var/obj/stool/chair/C = new /obj/stool/chair(get_turf(src))
			if (src.material)
				C.setMaterial(src.material)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			C.set_dir(src.dir)
			if (src.part1)
				src.part1.set_loc(get_turf(src))
				src.part1.master = null
				src.part1 = null
			qdel(src)
			return

	verb/controls()
		set src in oview(1)
		set category = "Local"

		src.control_interface(usr)

	// Seems to be the only way to get this stuff to auto-refresh properly, sigh (Convair880).
	proc/control_interface(mob/user as mob)
		if (!user.hasStatus("handcuffed") && isalive(user))
			src.add_dialog(user)

			var/dat = ""

			var/area/A = get_area(src)
			if (!isarea(A) || !A.powered(EQUIP))
				dat += "\n<font color='red'>ERROR:</font> No power source detected!</b>"
			else
				dat += {"<A href='?src=\ref[src];on=1'>[on ? "Switch Off" : "Switch On"]</A><BR>
				<A href='?src=\ref[src];lethal=1'>[lethal ? "<font color='red'>Lethal</font>" : "Nonlethal"]</A><BR><BR>
				<A href='?src=\ref[src];shock=1'>Shock</A><BR>"}

			user.Browse("<TITLE>Electric Chair</TITLE><b>Electric Chair</b><BR>[dat]", "window=e_chair;size=180x180")

			onclose(user, "e_chair")
		return

	Topic(href, href_list)
		if (usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat || usr.restrained()) return
		if (!in_interact_range(src, usr)) return

		if (href_list["on"])
			toggle_active()
		else if (href_list["lethal"])
			toggle_lethal()
		else if (href_list["shock"])
			if (src.buckled_guy)
				// The log entry for remote signallers can be found in item/assembly/shock_kit.dm (Convair880).
				logTheThing(LOG_COMBAT, usr, "activated an electric chair (setting: [src.lethal ? "lethal" : "non-lethal"]), shocking [constructTarget(src.buckled_guy,"combat")] at [log_loc(src)].")
			shock(lethal)

		src.control_interface(usr)
		src.add_fingerprint(usr)
		return

	proc/toggle_active()
		src.on = !(src.on)
		src.UpdateIcon()
		return src.on

	proc/toggle_lethal()
		src.lethal = !(src.lethal)
		src.UpdateIcon()
		return

	update_icon()
		src.icon_state = "e_chair[src.on]"
		if (!src.image_belt)
			src.image_belt = image(src.icon, "e_chairo[src.on][src.lethal]", layer = FLY_LAYER + 1)
			src.UpdateOverlays(src.image_belt, "belts")
			return
		src.image_belt.icon_state = "e_chairo[src.on][src.lethal]"
		src.UpdateOverlays(src.image_belt, "belts")

	// Options:      1) place the chair anywhere in a powered area (fixed shock values),
	// (Convair880)  2) on top of a powered wire (scales with engine output).
	proc/get_connection()
		var/turf/T = get_turf(src)
		if (!istype(T, /turf/simulated/floor))
			return 0

		for (var/obj/cable/C in T)
			return C.netnum

		return 0

	proc/get_gridpower()
		var/netnum = src.get_connection()

		if (netnum)
			var/datum/powernet/PN
			if (powernets && powernets.len >= netnum)
				PN = powernets[netnum]
				return PN.avail

		return 0

	proc/shock(lethal)
		if (!src.on)
			return
		if ((src.last_time + 50) > world.time)
			return
		src.last_time = world.time

		// special power handling
		var/area/A = get_area(src)
		if (!isarea(A))
			return
		if (!A.powered(EQUIP))
			return
		A.use_power(EQUIP, 5000)
		A.UpdateIcon()

		for (var/mob/M in AIviewers(src, null))
			M.show_message("<span class='alert'>The electric chair went off!</span>", 3)
			if (lethal)
				playsound(src.loc, 'sound/effects/electric_shock.ogg', 50, 0)
			else
				playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 0)

		if (src.buckled_guy && isliving(src.buckled_guy))
			var/mob/living/L = src.buckled_guy

			if (src.lethal)
				var/net = src.get_connection() // Are we wired-powered (Convair880)?
				var/power = src.get_gridpower()
				if (!net || (net && (power < 2000000)))
					L.shock(src, 2000000, "chest", 0.3, 1) // Nope or not enough juice, use fixed values instead (around 80 BURN per shock).
				else
					//DEBUG_MESSAGE("Shocked [L] with [power]")
					src.electrocute(L, 100, net, 1) // We are, great. Let that global proc calculate the damage.
			else
				L.shock(src, 2500, "chest", 1, 1)
				L.changeStatus("stunned", 10 SECONDS)

			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
				if ((L.mind in ticker.mode:revolutionaries) && !(L.mind in ticker.mode:head_revolutionaries) && prob(66))
					ticker.mode:remove_revolutionary(L.mind)

		A.UpdateIcon()
		return

/* ========================================================= */
/* ---------------------- Pool Chairs ---------------------- */
/* ========================================================= */
/obj/stool/chair/pool
	name = "pool chair"
	desc = "This chair is perfect for lounging at the side of a pool."
	icon_state = "chair_pool"
	rotatable = FALSE
	foldable = FALSE
