/*
//reagent_container bit flags
#define RC_SCALE 	1		// has a graduated scale, so total reagent volume can be read directly
#define RC_VISIBLE	2		// reagent is visible inside, so color can be described
#define RC_FULLNESS 4		// can estimate fullness of container
#define RC_SPECTRO	8		// spectroscopic glasses can analyse contents
*/
/* ================================================================== */
/* -------------------- Reagent Container Parent -------------------- */
/* ================================================================== */

// for some reason this very important parent item of a fucking thousand other things was planted down on line 700
// I AM SCREAMING A LOT IN REAL LIFE ABOUT THIS CURRENTLY
/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = 1
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	var/rc_flags = RC_VISIBLE | RC_FULLNESS | RC_SPECTRO
	tooltip_flags = REBUILD_SPECTRO | REBUILD_DIST
	var/amount_per_transfer_from_this = 5
	var/initial_volume = 50
	var/list/initial_reagents = null // can be a list, an associative list (reagent=amt), or a string.  list will add an equal chunk of each reagent, associative list will add amt of reagent, string will add initial_volume of reagent
	var/incompatible_with_chem_dispensers = 0
	var/can_mousedrop = 1
	move_triggered = 1

	var/last_new_initial_reagents = 0 //fuck

	New(loc, new_initial_reagents)
		..()
		last_new_initial_reagents = new_initial_reagents
		ensure_reagent_holder()
		create_initial_reagents(new_initial_reagents)

	proc/setup_reagents(new_initial_reagents) //proccall overhead idk man dont put this in new just copy paste :)
		ensure_reagent_holder()
		create_initial_reagents(new_initial_reagents)

	pooled()
		if (src.reagents)
			src.reagents.clear_reagents()
		..()

	unpooled()
		if (src.reagents)
			src.reagents.clear_reagents()
		..()
		setup_reagents(last_new_initial_reagents)


	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	proc/ensure_reagent_holder()
		if (!src.reagents)
			var/datum/reagents/R = new /datum/reagents(initial_volume)
			src.reagents = R
			R.my_atom = src

	proc/create_initial_reagents(var/list/new_reagents = null)
		if (!src.reagents)
			src.initial_reagents = null // don't need you no mo
			return
		if ((islist(new_reagents) && new_reagents.len) || istext(new_reagents))
			src.initial_reagents = new_reagents
		if (islist(src.initial_reagents) && src.initial_reagents.len)
			for (var/current_id in src.initial_reagents)
				if (!istext(current_id)) // we can't do shit hereeee
					continue
				var/amt = src.initial_reagents[current_id]
				if (!isnum(amt))
					amt = (src.initial_volume / src.initial_reagents.len) // should put an even amount of each?
				if (isnum(amt))
					src.reagents.add_reagent(current_id, amt)
		else if (istext(src.initial_reagents))
			src.reagents.add_reagent(src.initial_reagents, initial_volume)
		src.initial_reagents = null // no mo, no mooooo

	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		return
	attackby(obj/item/I as obj, mob/user as mob)
		if (reagents)
			reagents.physical_shock(I.force)
		return
	afterattack(obj/target, mob/user , flag)
		return

	get_desc(dist, mob/user)
		if (dist > 2)
			return
		if (!reagents)
			return
		. = "<br><span class='notice'>[reagents.get_description(user,rc_flags)]</span>"
		return

	MouseDrop(atom/over_object as obj)
		if (!can_mousedrop)
			boutput(usr, "<span class='alert'>Nope.</span>")
			return
		if(usr.restrained())
			return
		if(!istype(usr.loc, /turf))
			var/atom/target_loc = usr.loc
			var/ok = 1
			var/atom/L = src
			while(!istype(L, /turf) && L != target_loc)
				L = L.loc
				if(istype(L, /turf))
					ok = 0
			L = over_object
			while(!istype(L, /turf) && L != target_loc)
				L = L.loc
				if(istype(L, /turf))
					ok = 0
			if(!ok)
				return
		// First filter out everything we don't want to refill or empty quickly.
		if (!istype(over_object, /obj/item/reagent_containers/glass) && !istype(over_object, /obj/item/reagent_containers/food/drinks) && !istype(over_object, /obj/reagent_dispensers) && !istype(over_object, /obj/item/spraybottle) && !istype(over_object, /obj/machinery/plantpot) && !istype(over_object, /obj/mopbucket) && !istype(over_object, /obj/item/reagent_containers/mender) && !istype(over_object, /obj/item/tank/jetpack/backtank))
			return ..()

		if (!istype(src, /obj/item/reagent_containers/glass) && !istype(src, /obj/item/reagent_containers/food/drinks))
			return ..()

		if (usr.stat || usr.getStatusDuration("weakened") || get_dist(usr, src) > 1 || get_dist(usr, over_object) > 1)  //why has this bug been in since i joined goonstation and nobody even looked here yet wtf -ZeWaka
			boutput(usr, "<span class='alert'>That's too far!</span>")
			return

		src.transfer_all_reagents(over_object, usr)

/* ====================================================== */
/* -------------------- Glass Parent -------------------- */
/* ====================================================== */

/obj/item/reagent_containers/glass
	name = " "
	desc = " "
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	var/splash_all_contents = 1
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK

	afterattack(obj/target, mob/user , flag)
		user.lastattacked = target
		if (ismob(target))
			if (!src.reagents.total_volume)
				boutput(user, "<span class='alert'>Your [src.name] is empty!</span>")
				return
			var/mob/living/T = target
			var/obj/item/reagent_containers/glass/G = null

			if (ishuman(T))
				var/mob/living/carbon/human/H = T
				if (H.hand == 1)
					if (istype(H.l_hand,/obj/item/reagent_containers/glass/)) G = H.l_hand
				else
					if (istype(H.r_hand,/obj/item/reagent_containers/glass/)) G = H.r_hand
			else if (isrobot(T))
				var/mob/living/silicon/robot/R = T
				if (istype(R.module_active,/obj/item/reagent_containers/glass/)) G = R.module_active

			if (G && user.a_intent == "help" && T.a_intent == "help" && user != T)
				if (G.reagents.total_volume >= G.reagents.maximum_volume)
					boutput(user, "<span class='alert'>[T.name]'s [G.name] is already full!</span>")
					boutput(T, "<span class='alert'><B>[user.name]</B> offers you [src.name], but your [G.name] is already full.</span>")
					return
				src.reagents.trans_to(G, src.amount_per_transfer_from_this)
				user.visible_message("<b>[user.name]</b> pours some of the [src.name] into [T.name]'s [G.name].")
				return
			else
				if (reagents)
					reagents.physical_shock(14)
				if (src.splash_all_contents)
					boutput(user, "<span class='notice'>You splash all of the solution onto [target].</span>")
					target.visible_message("<span class='alert'><b>[user.name]</b> splashes the [src.name]'s contents onto [target.name]!</span>")
				else
					boutput(user, "<span class='notice'>You apply [src.amount_per_transfer_from_this] units of the solution to [target].</span>")
					target.visible_message("<span class='alert'><b>[user.name]</b> applies some of the [src.name]'s contents to [target.name].</span>")
				var/mob/living/MOB = target
				logTheThing("combat", user, MOB, "splashes [src] onto [constructTarget(MOB,"combat")] [log_reagents(src)] at [log_loc(MOB)].") // Added location (Convair880).
				can_mousedrop = 0
				if (src.splash_all_contents)
					src.reagents.reaction(target,TOUCH)
				else
					src.reagents.reaction(target, TOUCH, min(src.amount_per_transfer_from_this,src.reagents.total_volume))
				SPAWN_DBG(0.5 SECONDS)
					if (src.splash_all_contents) src.reagents.clear_reagents()
					else src.reagents.remove_any(src.amount_per_transfer_from_this)
					can_mousedrop = 1
				return
		else if (istype(target, /obj/fluid) && !istype(target, /obj/fluid/airborne)) // fluid handling : If src is empty, fill from fluid. otherwise add to the fluid.
			var/obj/fluid/F = target
			if (!src.reagents.total_volume)
				if (!F.group || !F.group.reagents.total_volume)
					boutput(user, "<span class='alert'>[target] is empty. (this is a bug, whooops!)</span>")
					F.removed()
					return

				if (reagents.total_volume >= reagents.maximum_volume)
					boutput(user, "<span class='alert'>[src] is full.</span>")
					return
				//var/transferamt = min(src.reagents.maximum_volume - src.reagents.total_volume, F.amt)

				F.group.reagents.skip_next_update = 1
				F.group.update_amt_per_tile()
				var/amt = min(F.group.amt_per_tile, reagents.maximum_volume - reagents.total_volume)
				boutput(user, "<span class='notice'>You fill [src] with [amt] units of [target].</span>")
				F.group.drain(F, amt / F.group.amt_per_tile, src) // drain uses weird units
			else //trans_to to the FLOOR of the liquid, not the liquid itself. will call trans_to() for turf which has a little bit that handles turf application -> fluids
				var/turf/T = get_turf(F)
				logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [F] at [log_loc(user)].") // Added reagents (Convair880).
				var/trans = src.reagents.trans_to(T, src.splash_all_contents ? src.reagents.total_volume : src.amount_per_transfer_from_this)
				boutput(user, "<span class='notice'>You transfer [trans] units of the solution to [T].</span>")

			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1, 0.3)

		else if (istype(target, /obj/reagent_dispensers) || (target.is_open_container() == -1 && target.reagents) || ((istype(target, /obj/fluid) && !istype(target, /obj/fluid/airborne)) && !src.reagents.total_volume)) //A dispenser. Transfer FROM it TO us.
			if (!target.reagents.total_volume && target.reagents)
				boutput(user, "<span class='alert'>[target] is empty.</span>")
				return

			if (reagents.total_volume >= reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			var/transferamt = src.reagents.maximum_volume - src.reagents.total_volume
			var/trans = target.reagents.trans_to(src, transferamt)
			boutput(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

			playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)

		else if (target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if (!reagents.total_volume)
				boutput(user, "<span class='alert'>[src] is empty.</span>")
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[target] is full.</span>")
				return

			logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].") // Added reagents (Convair880).
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

			playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)

		else if (istype(target, /obj/item/sponge)) // dump contents onto it
			if (!reagents.total_volume)
				boutput(user, "<span class='alert'>[src] is empty.</span>")
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[target] is full.</span>")
				return

			logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].")
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, "<span class='notice'>You dump [trans] units of the solution to [target].</span>")

		else if (istype(target, /turf/space/fluid)) //specific exception for seafloor rn, since theres no others
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return
			else
				src.reagents.add_reagent("silicon_dioxide", src.reagents.maximum_volume - src.reagents.total_volume) //should add like, 100 - 85 sand or something
			boutput(user, "<span class='notice'>You scoop some of the sand into [src].</span>")
			return

		else if (reagents.total_volume)

			if (isobj(target)) //Have to do this in 2 lines because byond is shit.
				if (target:flags & NOSPLASH) return
			can_mousedrop = 0
			boutput(user, "<span class='notice'>You [src.splash_all_contents ? "splash all of" : "apply [amount_per_transfer_from_this] units of"] the solution onto [target].</span>")
			logTheThing("combat", user, target, "splashes [src] onto [constructTarget(target,"combat")] [log_reagents(src)] at [log_loc(user)].") // Added location (Convair880).
			if (reagents)
				reagents.physical_shock(14)

			if (src.splash_all_contents) src.reagents.reaction(target,TOUCH)
			else src.reagents.reaction(target, TOUCH, min(src.amount_per_transfer_from_this,src.reagents.total_volume))
			SPAWN_DBG(0.5 SECONDS)
				if (src.splash_all_contents) src.reagents.clear_reagents()
				else src.reagents.remove_any(src.amount_per_transfer_from_this)
				can_mousedrop = 1
			return

	attackby(obj/item/I as obj, mob/user as mob)
		/*if (istype(I, /obj/item/reagent_containers/pill))

			if (!I.reagents || !I.reagents.total_volume)
				boutput(user, "<span class='alert'>[src] is empty.</span>")
				return

			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			boutput(user, "<span class='notice'>You dissolve the [I] in [src].</span>")

			I.reagents.trans_to(src, I.reagents.total_volume)
			qdel(I)

		else */if (istype(I, /obj/item/reagent_containers/food/snacks/ingredient/egg))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			boutput(user, "<span class='notice'>You crack [I] into [src].</span>")

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		else if (istype(I, /obj/item/paper))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			boutput(user, "<span class='notice'>You rip up the [I] into tiny pieces and sprinkle it into [src].</span>")

			I.reagents.trans_to(src, I.reagents.total_volume)
			pool(I)

		else if (istype(I, /obj/item/reagent_containers/food/snacks/breadloaf))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			boutput(user, "<span class='notice'>You shove the [I] into [src].</span>")

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		else if (istype(I, /obj/item/reagent_containers/food/snacks/breadslice))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			boutput(user, "<span class='notice'>You shove the [I] into [src].</span>")

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		else if (istype(I,/obj/item/material_piece/rubber))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, "<span class='alert'>[src] is full.</span>")
				return

			boutput(user, "<span class='notice'>You shove the [I] into [src].</span>")

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		else if (istype(I, /obj/item/scalpel) || istype(I, /obj/item/circular_saw) || istype(I, /obj/item/surgical_spoon) || istype(I, /obj/item/scissors/surgical_scissors))
			if (src.reagents && I.reagents)
				I:Poisoner = user
				src.reagents.trans_to(I, 5)
				logTheThing("combat", user, null, "poisoned [I] [log_reagents(I)] with reagents from [src] [log_reagents(src)] at [log_loc(user)].") // Added location (Convair880).
				user.visible_message("<span class='alert'><b>[user]</b> dips the blade of [I] into [src]!</span>")
				return

		//Hacky thing to make silver bullets (maybe todo later : all items can be dipped in any solution?)
		else if (istype(I, /obj/item/ammo/bullets/bullet_22) || istype(I, /obj/item/ammo/bullets/a38) || istype(I, /obj/item/ammo/bullets/custom) || (I.type == /obj/item/handcuffs) || istype(I,/datum/projectile/bullet/revolver_38))
			if ("silver" in src.reagents.reaction(I, react_volume = src.reagents.total_volume))
				user.visible_message("<span class='alert'><b>[user]</b> dips [I] into [src] coating it in silver. Watch out, evil creatures!</span>")
			else
				if (I.material && I.material.mat_id == "silver")
					boutput(user, "<span class='notice'>[I] is already coated, more silver won't do any good.</span>")
				else
					boutput(user, "<span class='notice'>[src] doesn't have enough silver in it to coat [I].</span>")

		else if (istype(I, /obj/item/reagent_containers/iv_drip))
			var/obj/item/reagent_containers/iv_drip/W = I
			if (W.slashed == 1)
				if (W.reagents.total_volume)
					if (src.reagents.maximum_volume > src.reagents.total_volume)
						var/transferred = W.reagents.trans_to(src, 10)
						boutput(user, "You pour [transferred] units of the [W.name]'s contents into the [src.name].")
					else
						boutput(user, "<span class='alert'>The [src.name] is full.</span>")
				else
					boutput(user, "The [W.name] is empty.")

			return
		else
			..()
		return

	attack_self(mob/user as mob)
		if (src.splash_all_contents)
			boutput(user, "<span class='notice'>You tighten your grip on the [src].</span>")
			src.splash_all_contents = 0
		else
			boutput(user, "<span class='notice'>You loosen your grip on the [src].</span>")
			src.splash_all_contents = 1
		return

	proc/smash()
		playsound(src.loc, pick('sound/impact_sounds/Glass_Shatter_1.ogg','sound/impact_sounds/Glass_Shatter_2.ogg','sound/impact_sounds/Glass_Shatter_3.ogg'), 100, 1)
		var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
		G.set_loc(src.loc)
		var/turf/U = src.loc
		src.reagents.reaction(U)
		qdel(src)

	on_spin_emote(var/mob/living/carbon/human/user as mob)
		. = ..()
		if (src.is_open_container() && src.reagents && src.reagents.total_volume > 0)
			user.visible_message("<span class='alert'><b>[user] spills the contents of [src] all over [him_or_her(user)]self!</b></span>")
			src.reagents.reaction(get_turf(user), TOUCH)
			src.reagents.clear_reagents()

	is_open_container()
		return 1

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/glass/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	amount_per_transfer_from_this = 10
	initial_volume = 50
	flags = FPRINT | OPENCONTAINER | SUPPRESSATTACK
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	var/helmet_bucket_type = /obj/item/clothing/head/helmet/bucket
	var/hat_bucket_type = /obj/item/clothing/head/helmet/bucket/hat
	var/bucket_sensor_type = /obj/item/bucket_sensor

	attackby(var/obj/item/D, mob/user as mob)
		if (istype(D, /obj/item/device/prox_sensor))
			var/obj/item/bucket_sensor/B = new bucket_sensor_type
			user.u_equip(D)
			user.put_in_hand_or_drop(B)
			user.show_text("You add the sensor to the bucket")
			qdel(D)
			qdel(src)

		else if (istype(D, /obj/item/mop))
			if (src.reagents.total_volume >= 2)
				src.reagents.trans_to(D, 2)
				user.show_text("You wet the mop", "blue")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			else
				user.show_text("Out of water!", "blue")
		else if (issnippingtool(D))
			if (src.reagents.total_volume)
				user.show_text("<b>You start cutting [src], causing it to spill!</b>", "red")
				src.reagents.reaction(get_turf(src))
			else
				user.show_text("You start cutting [src].")
			if (!do_mob(user, src))
				user.show_text("<b>You were interrupted!</b>", "red")
				return
			user.show_text("You cut eyeholes into [src].")
			var/obj/item/clothing/head/helmet/bucket/B = new helmet_bucket_type(src.loc)
			user.put_in_hand_or_drop(B)
			qdel(src)
		else
			return ..()

	attack_self(mob/user as mob)
		if (isrobot(user))
			boutput(user, "<span class='alert'>Why would you wanna flip over your precious bucket? Silly.</span>")
			return
		if (src.reagents.total_volume)
			user.show_text("<b>You turn the bucket upside down, causing it to spill!</b>", "red")
			src.reagents.reaction(get_turf(src))
		else
			user.show_text("You turn the bucket upside down.", "red")
		var/obj/item/clothing/head/helmet/bucket/hat/B = new hat_bucket_type(src.loc)
		user.u_equip(src)
		user.put_in_hand_or_drop(B)
		qdel(src)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		user.u_equip(src)
		src.set_loc(get_turf(user))
		step_rand(src)
		user.visible_message("<span class='alert'><b>[user] kicks the bucket!</b></span>")
		user.death(0)

	red
		name = "red bucket"
		desc = "It's a fabled red bucket. It is said to once have been blue."
		icon_state = "bucket-r"
		item_state = "bucket-r"
		helmet_bucket_type = /obj/item/clothing/head/helmet/bucket/red
		hat_bucket_type = /obj/item/clothing/head/helmet/bucket/hat/red
		bucket_sensor_type = /obj/item/bucket_sensor/red

/obj/item/reagent_containers/glass/dispenser
	name = "reagent glass"
	desc = "A reagent glass."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	initial_volume = 50
	amount_per_transfer_from_this = 10
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK

/obj/item/reagent_containers/glass/large
	name = "large reagent glass"
	desc = "A large reagent glass."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beakerlarge"
	item_state = "beaker"
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK

/obj/item/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon_state = "liquid"
	initial_reagents = list("fluorosurfactant"=20)
