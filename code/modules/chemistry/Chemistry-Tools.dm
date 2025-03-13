/* ================================================================== */
/* -------------------- Reagent Container Parent -------------------- */
/* ================================================================== */

// for some reason this very important parent item of a fucking thousand other things was planted down on line 700
// I AM SCREAMING A LOT IN REAL LIFE ABOUT THIS CURRENTLY
ABSTRACT_TYPE(/obj/item/reagent_containers)
/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = W_CLASS_TINY
	flags = TABLEPASS | SUPPRESSATTACK
	var/rc_flags = RC_VISIBLE | RC_FULLNESS | RC_SPECTRO
	tooltip_flags = REBUILD_SPECTRO | REBUILD_DIST
	var/amount_per_transfer_from_this = 5
	var/initial_volume = 50
	var/list/initial_reagents = null // can be a list, an associative list (reagent=amt), or a string.  list will add an equal chunk of each reagent, associative list will add amt of reagent, string will add initial_volume of reagent
	var/incompatible_with_chem_dispensers = 0
	var/can_recycle = FALSE //can this be put in a glass recycler?
	move_triggered = 1
	var/last_new_initial_reagents = 0 //fuck

	var/accepts_lid = FALSE //!if true, container will accept beaker lids. lids should not go onto containers that aren't open
	var/obj/item/beaker_lid/current_lid = null //!the lid applied to the container
	var/image/lid_image = null
	var/original_icon_state = null

	New(loc, new_initial_reagents)
		..()
		last_new_initial_reagents = new_initial_reagents
		ensure_reagent_holder()
		create_initial_reagents(new_initial_reagents)
		original_icon_state = icon_state

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		HYPadd_harvest_reagents(src,origin_plant,passed_genes,quality_status)
		return src

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
		if ((islist(new_reagents) && length(new_reagents)) || istext(new_reagents))
			src.initial_reagents = new_reagents
		if (islist(src.initial_reagents) && length(src.initial_reagents))
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

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		return
	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/beaker_lid))
			try_to_apply_lid(I, user)
		if (reagents)
			reagents.physical_shock(I.force)
		return ..()
	afterattack(obj/target, mob/user , flag)
		return

	get_desc(dist, mob/user)
		if (dist > 2)
			return
		if (!reagents)
			return
		. = "<br>[SPAN_NOTICE("[reagents.get_description(user,rc_flags)]")]"

	mouse_drop(atom/over_object as obj)
		if (isintangible(usr))
			return
		if(usr.restrained())
			return
		if(over_object == src)
			return
		if (!src.is_open_container(FALSE))
			return ..()
		if(!istype(usr.loc, /turf))
			var/atom/target_loc = usr.loc
			var/ok = 1
			var/atom/L = src
			while(!istype(L, /turf) && L != target_loc && L.loc)
				L = L.loc
				if(istype(L, /turf))
					ok = 0
			L = over_object
			while(!istype(L, /turf) && L != target_loc && L.loc)
				L = L.loc
				if(istype(L, /turf))
					ok = 0
			if(!ok)
				return

		if (!(over_object.flags & ACCEPTS_MOUSEDROP_REAGENTS))
			return ..()

		if (!istype(src, /obj/item/reagent_containers/glass) && !istype(src, /obj/item/reagent_containers/food/drinks))
			return ..()

		if (usr.stat || usr.getStatusDuration("knockdown") || BOUNDS_DIST(usr, src) > 0 || BOUNDS_DIST(usr, over_object) > 0)  //why has this bug been in since i joined goonstation and nobody even looked here yet wtf -ZeWaka
			boutput(usr, SPAN_ALERT("That's too far!"))
			return

		src.transfer_all_reagents(over_object, usr)

	proc/try_to_apply_lid(obj/item/beaker_lid/lid, mob/user)
		if(!src.accepts_lid)
			boutput(user, SPAN_ALERT("The [lid] won't fit on the [src]!"))
			return
		else if(src.current_lid)
			boutput(user, SPAN_ALERT("You could never, ever, fit a second lid on the [src]!"))
			return
		else
			boutput(user, SPAN_NOTICE("You click the [lid] onto the [src]."))
			apply_lid(lid, user)

	proc/apply_lid(obj/item/beaker_lid/lid, mob/user) //todo: add a sound?
		src.set_open_container(FALSE)
		REMOVE_FLAG(src.flags, ACCEPTS_MOUSEDROP_REAGENTS)
		current_lid = lid
		user.u_equip(lid)
		lid.set_loc(src)
		if (!src.lid_image)
			src.lid_image = image(src.icon)
			src.lid_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
			src.lid_image.icon_state = "[src.original_icon_state]-lid"
		src.UpdateOverlays(src.lid_image, "lid")

	proc/remove_current_lid(mob/user)
		src.set_open_container(TRUE)
		ADD_FLAG(src.flags, ACCEPTS_MOUSEDROP_REAGENTS)
		user.put_in_hand_or_drop(src.current_lid)
		current_lid = null
		src.UpdateOverlays(null, "lid")

///Returns a serialized representation of the reagents of an atom for use with the ReagentInfo TGUI components
///Note that this is not a built in TGUI proc
proc/ui_describe_reagents(atom/A)
	if (!istype(A))
		return null
	var/datum/reagents/R = A.reagents
	var/list/thisContainerData = list(
		name = A.name,
		maxVolume = R.maximum_volume,
		totalVolume = R.total_volume,
		contents = list(),
		finalColor = "#000000",
		temperature = R.total_temperature
	)

	var/list/contents = thisContainerData["contents"]
	if(istype(R) && R.reagent_list.len>0)
		thisContainerData["finalColor"] = R.get_average_rgb()
		// Reagent data
		for(var/reagent_id in R.reagent_list)
			var/datum/reagent/current_reagent = R.reagent_list[reagent_id]

			contents.Add(list(list(
				name = current_reagent.name,
				id = reagent_id,
				colorR = current_reagent.fluid_r,
				colorG = current_reagent.fluid_g,
				colorB = current_reagent.fluid_b,
				volume = current_reagent.volume,
				state = current_reagent.reagent_state,
			)))
	return thisContainerData

/* ====================================================== */
/* -------------------- Glass Parent -------------------- */
/* ====================================================== */

/obj/item/reagent_containers/glass
	name = " "
	desc = " "
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	can_recycle = TRUE //can this be put in a glass recycler?
	var/splash_all_contents = 1
	///For internal tanks and other things that definitely should not shatter
	var/shatter_immune = FALSE
	flags = TABLEPASS | OPENCONTAINER | SUPPRESSATTACK | ACCEPTS_MOUSEDROP_REAGENTS
	item_function_flags = OBVIOUS_INTERACTION_BAR //no hidden splashing of acid on stuff

	/// The icon file that this container should for fluid overlays.
	var/container_icon = 'icons/obj/items/chemistry_glassware.dmi'
	/// The icon state that this container should for fluid overlays.
	var/container_style = null
	/// The number of fluid overlay states that this container has.
	var/fluid_overlay_states = 0
	/// The scaling that this container's fluid overlays should use.
	var/fluid_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_LINEAR

	New()
		. = ..()
		src.container_style ||= src.icon_state
		if (src.fluid_overlay_states > 0)
			src.AddComponent( \
				/datum/component/reagent_overlay, \
				reagent_overlay_icon = src.container_icon, \
				reagent_overlay_icon_state = src.container_style, \
				reagent_overlay_states = src.fluid_overlay_states, \
				reagent_overlay_scaling = src.fluid_overlay_scaling, \
			)

	// this proc is a mess ow
	afterattack(obj/target, mob/user , flag)
		user.lastattacked = get_weakref(target)

		// this shit sucks but this is an if-else so there's no space to fit a cast in there
		var/turf/target_turf = CHECK_LIQUID_CLICK(target) ? get_turf(target) : null
		if (ismob(target) && !target.is_open_container() && src.is_open_container()) // pour reagents down their neck (if possible)
			if (!src.reagents.total_volume)
				boutput(user, SPAN_ALERT("Your [src.name] is empty!"))
				return
			var/mob/living/T = target
			var/obj/item/reagent_containers/glass/G = null

			if (ishuman(T))
				var/mob/living/carbon/human/H = T
				if (H.hand == LEFT_HAND)
					if (istype(H.l_hand, /obj/item/reagent_containers/glass/)) G = H.l_hand
				else
					if (istype(H.r_hand, /obj/item/reagent_containers/glass/)) G = H.r_hand

			else if (isrobot(T))
				var/mob/living/silicon/robot/R = T
				if (istype(R.module_active, /obj/item/reagent_containers/glass/))
					G = R.module_active

			if (G && user.a_intent == "help" && T.a_intent == "help" && user != T)
				if (G.reagents.total_volume >= G.reagents.maximum_volume)
					boutput(user, SPAN_ALERT("[T.name]'s [G.name] is already full!"))
					boutput(T, SPAN_ALERT("<B>[user.name]</B> offers you [src.name], but your [G.name] is already full."))
					return
				src.reagents.trans_to(G, src.amount_per_transfer_from_this)
				user.visible_message("<b>[user.name]</b> pours some of the [src.name] into [T.name]'s [G.name].")

			else
				if (reagents)
					reagents.physical_shock(14)
				if (src.splash_all_contents)
					boutput(user, SPAN_NOTICE("You splash all of the solution onto [target]."))
					target.visible_message(SPAN_ALERT("<b>[user.name]</b> splashes the [src.name]'s contents onto [target.name]!"))
				else
					boutput(user, SPAN_NOTICE("You apply [min(src.amount_per_transfer_from_this,src.reagents.total_volume)] units of the solution to [target]."))
					target.visible_message(SPAN_ALERT("<b>[user.name]</b> applies some of the [src.name]'s contents to [target.name]."))
				var/mob/living/MOB = target
				logTheThing(LOG_COMBAT, user, "splashes [src] onto [constructTarget(MOB,"combat")] [log_reagents(src)] at [log_loc(MOB)].") // Added location (Convair880).
				if (src.splash_all_contents)
					src.reagents.reaction(target,TOUCH)
					src.reagents.clear_reagents()
				else
					src.reagents.reaction(target, TOUCH, min(src.amount_per_transfer_from_this, src.reagents.total_volume))
					src.reagents.remove_any(src.amount_per_transfer_from_this)

		else if (target_turf?.active_liquid && src.is_open_container()) // fluid handling : If src is empty, fill from fluid. otherwise add to the fluid.
			var/obj/fluid/F = target_turf.active_liquid
			if (!src.reagents.total_volume)
				if (reagents.total_volume >= reagents.maximum_volume)
					boutput(user, SPAN_ALERT("[src] is full."))
					return

				F.group.reagents.skip_next_update = TRUE
				F.group.update_amt_per_tile()
				var/amt = min(F.group.amt_per_tile, reagents.maximum_volume - reagents.total_volume)
				boutput(user, SPAN_NOTICE("You fill [src] with [amt] units of [F]."))
				F.group.drain(F, amt / F.group.amt_per_tile, src) // drain uses weird units
			else //trans_to to the FLOOR of the liquid, not the liquid itself. will call trans_to() for turf which has a little bit that handles turf application -> fluids
				logTheThing(LOG_CHEMISTRY, user, "transfers chemicals from [src] [log_reagents(src)] to [F] at [log_loc(user)].") // Added reagents (Convair880).
				var/trans = src.reagents.trans_to(target_turf, src.splash_all_contents ? src.reagents.total_volume : src.amount_per_transfer_from_this)
				boutput(user, SPAN_NOTICE("You transfer [trans] units of the solution to [target_turf]."))

			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1, 0.3)

		else if ((is_reagent_dispenser(target) || (target.is_open_container() == -1 && target.reagents)) && src.is_open_container(TRUE) && !(istype(target, /obj/reagent_dispensers/chemicalbarrel) && target:funnel_active)) //A dispenser. Transfer FROM it TO us.
			if (target.reagents && !target.reagents.total_volume)
				boutput(user, SPAN_ALERT("[target] is empty."))
				return

			if (reagents.total_volume >= reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			var/transferamt = src.reagents.maximum_volume - src.reagents.total_volume
			var/trans = target.reagents.trans_to(src, transferamt)
			boutput(user, SPAN_NOTICE("You fill [src] with [trans] units of the contents of [target]."))

			playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)

		else if (target.is_open_container(TRUE) && target.reagents && !isturf(target) && src.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if(istype(target, /obj/item/reagent_containers))
				var/obj/item/reagent_containers/t = target
				if(t.current_lid)
					boutput(user, SPAN_ALERT("You cannot transfer liquids to the [target.name] while it has a lid on it!"))
					return
			if (!reagents.total_volume)
				boutput(user, SPAN_ALERT("[src] is empty."))
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[target] is full."))
				return

			logTheThing(LOG_CHEMISTRY, user, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].") // Added reagents (Convair880).
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, SPAN_NOTICE("You transfer [trans] units of the solution to [target]."))

			playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)

		else if (istype(target, /obj/item/sponge) && src.is_open_container()) // dump contents onto it
			if (!reagents.total_volume)
				boutput(user, SPAN_ALERT("[src] is empty."))
				return

			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[target] is full."))
				return

			logTheThing(LOG_CHEMISTRY, user, "transfers chemicals from [src] [log_reagents(src)] to [target] at [log_loc(user)].")
			var/trans = src.reagents.trans_to(target, 10)
			boutput(user, SPAN_NOTICE("You dump [trans] units of the solution to [target]."))

		else if (istype(target, /turf/space/fluid) && src.is_open_container()) //specific exception for seafloor rn, since theres no others
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return
			else
				src.reagents.add_reagent("silicon_dioxide", src.reagents.maximum_volume - src.reagents.total_volume) //should add like, 100 - 85 sand or something
			boutput(user, SPAN_NOTICE("You scoop some of the sand into [src]."))

		else if (reagents.total_volume && src.is_open_container())
			if (isobj(target) && (target:flags & NOSPLASH))
				return

			boutput(user, SPAN_NOTICE("You [src.splash_all_contents ? "splash all of" : "apply [amount_per_transfer_from_this] units of"] the solution onto [target]."))
			logTheThing(LOG_COMBAT, user, "splashes [src] onto [constructTarget(target,"combat")] [log_reagents(src)] at [log_loc(user)].") // Added location (Convair880).
			if (reagents)
				reagents.physical_shock(14)

			var/splash_volume
			if (src.splash_all_contents)
				splash_volume = src.reagents.maximum_volume
			else
				splash_volume = src.amount_per_transfer_from_this
			splash_volume = min(splash_volume, src.reagents.total_volume) // cap the reaction at the amount of reagents we have

			var/datum/reagents/splash = new(splash_volume) // temp reagents of the splash so we can make changes between the first and second splashes
			src.reagents.trans_to_direct(splash, splash_volume) // this removes reagents from this container so we don't need to do that below

			var/reacted_reagents = splash.reaction(target, TOUCH, splash_volume)

			var/turf/T
			if (!isturf(target) && !target.density) // if we splashed on something other than a turf or a dense obj, it goes on the floor as well
				T = get_turf(target)
			else if (target.density)
				// if we splashed on a wall or a dense obj, we still want to flow out onto the floor we're pouring from (avoid pouring under windows and on walls)
				T = get_turf(user)

			if (T && !T.density) // if the user AND the target are on dense turfs or the user is on a dense turf and the target is a dense obj then just give up. otherwise pour on the floor
				// first remove everything that reacted in the first reaction
				for(var/id in reacted_reagents)
					splash.del_reagent(id)
				splash.reaction(T, TOUCH, splash.total_volume)


	attackby(obj/item/I, mob/user)

		if (istype(I, /obj/item/reagent_containers/food/snacks/ingredient/egg))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			boutput(user, SPAN_NOTICE("You crack [I] into [src]."))

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		if (istype(I, /obj/item/reagent_containers/synthflesh_pustule))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			boutput(user, SPAN_NOTICE("You squeeze the [I] into the [src]. Gross."))
			playsound(src.loc, pick('sound/effects/splort.ogg'), 100, 1)

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		else if (istype(I, /obj/item/paper))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			boutput(user, SPAN_NOTICE("You rip up the [I] into tiny pieces and sprinkle it into [src]."))

			I.reagents.trans_to(src, I.reagents.total_volume)
			qdel(I)

		else if (istype(I, /obj/item/reagent_containers/food/snacks/breadloaf))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			boutput(user, SPAN_NOTICE("You shove the [I] into [src]."))

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		else if (istype(I, /obj/item/reagent_containers/food/snacks/breadslice))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			boutput(user, SPAN_NOTICE("You shove the [I] into [src]."))

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		else if (istype(I,/obj/item/material_piece/rubber))
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			boutput(user, SPAN_NOTICE("You shove the [I] into [src]."))

			I.reagents.trans_to(src, I.reagents.total_volume)
			user.u_equip(I)
			qdel(I)

		else if (istype(I, /obj/item/scalpel) || istype(I, /obj/item/circular_saw) || istype(I, /obj/item/surgical_spoon) || istype(I, /obj/item/scissors/surgical_scissors))
			if (src.reagents && I.reagents)
				if (src.reagents.trans_to(I, 5))
					logTheThing(LOG_CHEMISTRY, user, "poisoned [I] [log_reagents(I)] with reagents from [src] [log_reagents(src)] at [log_loc(user)].") // Added location (Convair880).
					user.visible_message(SPAN_ALERT("<b>[user]</b> dips the blade of [I] into [src]!"))
				else
					boutput(user, SPAN_NOTICE("[I] is already fully coated, more won't do any good."))
				return

		//Hacky thing to make silver bullets (maybe todo later : all items can be dipped in any solution?)
		else if (istype(I, /obj/item/ammo/bullets/bullet_22HP) ||istype(I, /obj/item/ammo/bullets/bullet_22) || istype(I, /obj/item/ammo/bullets/a38) || istype(I, /obj/item/ammo/bullets/custom) || (I.type == /obj/item/handcuffs) || istype(I,/datum/projectile/bullet/revolver_38))
			if ("silver" in src.reagents.reaction(I, react_volume = src.reagents.total_volume))
				user.visible_message(SPAN_ALERT("<b>[user]</b> dips [I] into [src] coating it in silver. Watch out, evil creatures!"))
				I.tooltip_rebuild = 1
			else
				if(istype(I, /obj/item/ammo/bullets))
					var/obj/item/ammo/A = I
					I = A.ammo_type
				if (I.material && I.material.getID() == "silver")
					boutput(user, SPAN_NOTICE("[I] is already coated, more silver won't do any good."))
				else
					boutput(user, SPAN_NOTICE("[src] doesn't have enough silver in it to coat [I]."))

		else if (istype(I, /obj/item/reagent_containers/iv_drip))
			var/obj/item/reagent_containers/iv_drip/W = I
			if (W.slashed == 1)
				if (W.reagents.total_volume)
					if (src.reagents.maximum_volume > src.reagents.total_volume)
						var/transferred = W.reagents.trans_to(src, 10)
						boutput(user, "You pour [transferred] units of the [W.name]'s contents into the [src.name].")
					else
						boutput(user, SPAN_ALERT("The [src.name] is full."))
				else
					boutput(user, "The [W.name] is empty.")
			else
				boutput(user, "You need to slice open the [W.name] first!")

			return
		else
			..()
		return

	attack_self(mob/user as mob)
		if(current_lid)
			boutput(user, SPAN_NOTICE("You pop the lid off of the [src]."))
			remove_current_lid(user)
		else if (src.splash_all_contents)
			boutput(user, SPAN_NOTICE("You tighten your grip on the [src]. You will now splash in [src.amount_per_transfer_from_this] unit increments."))
			src.splash_all_contents = 0
		else
			boutput(user, SPAN_NOTICE("You loosen your grip on the [src]. You will now splash all of the [src]'s contents."))
			src.splash_all_contents = 1
		return

	on_spin_emote(var/mob/living/carbon/human/user as mob)
		. = ..()
		if (src.is_open_container() && src.reagents && src.reagents.total_volume > 0)
			if(user.mind.assigned_role == "Bartender")
				. = ("You deftly [pick("spin", "twirl")] [src] managing to keep all the contents inside.")
			else
				user.visible_message(SPAN_ALERT("<b>[user] spills the contents of [src] all over [him_or_her(user)]self!</b>"))
				src.reagents.reaction(get_turf(user), TOUCH)
				src.reagents.clear_reagents()

	shatter_chemically(var/projectiles = FALSE)
		if (src.shatter_immune)
			return FALSE
		for(var/mob/M in AIviewers(src))
			boutput(M, SPAN_ALERT("The <B>[src.name]</B> shatters!"))
		if(projectiles)
			var/datum/projectile/special/spreader/uniform_burst/circle/circle = new /datum/projectile/special/spreader/uniform_burst/circle/(get_turf(src))
			circle.shot_sound = null //no grenade sound ty
			circle.spread_projectile_type = /datum/projectile/bullet/glass_shard
			circle.pellet_shot_volume = 0
			circle.pellets_to_fire = 10
			shoot_projectile_ST_pixel_spread(get_turf(src), circle, get_step(src, NORTH))
		playsound(src.loc, pick('sound/impact_sounds/Glass_Shatter_1.ogg','sound/impact_sounds/Glass_Shatter_2.ogg','sound/impact_sounds/Glass_Shatter_3.ogg'), 100, 1)
		src.reagents.reaction(get_turf(src), TOUCH, src.reagents.total_volume)
		var/obj/item/raw_material/shard/glass/shard = new /obj/item/raw_material/shard/glass
		shard.set_loc(get_turf(src))
		qdel(src)
		return TRUE

	is_open_container()
		if(..() && !GET_ATOM_PROPERTY(src, PROP_ITEM_IN_CHEM_DISPENSER))
			return 1

	get_chemical_effect_position()
		switch(src.container_style)
			if("beaker")
				return 4
			if("large_beaker")
				return 9
			if("conical_flask")
				return 9
			if("round_flask")
				return 9
			if("large_flask")
				return 10
			if("dropper_funnel")
				return 10

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
	initial_volume = 120
	flags = OPENCONTAINER | SUPPRESSATTACK
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	can_recycle = FALSE
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
				user.show_text("You wet the mop.", "blue")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			else
				user.show_text("Out of water!", "blue")
		else if (issnippingtool(D))
			if (src.reagents.total_volume)
				user.show_text("<b>You start cutting [src], causing it to spill!</b>", "red")
				src.reagents.reaction(get_turf(src))
				src.reagents.clear_reagents()
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
			boutput(user, SPAN_ALERT("Why would you wanna flip over your precious bucket? Silly."))
			return
		if (src.cant_drop || src.cant_self_remove)
			boutput(user, SPAN_ALERT("You can't flip that, it's stuck on."))
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

	afterattack(obj/target, mob/user, flag)
		if(!istype(target, /obj/machinery/door/unpowered/wood))
			return ..()
		if(locate(/obj/item/reagent_containers/glass/bucket) in target)
			boutput(user,"<b>There's already a bucket prank set up!</b>")
			return ..()
		boutput(user, "You start propping \the [src] above \the [target]...")
		SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(setup_bucket_prank), list(target, user), src.icon, src.icon_state, \
					src.visible_message(SPAN_ALERT("<B>[user] props a [src] above \the [target]</B>")), \
					INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

	proc/setup_bucket_prank(obj/machinery/door/targetDoor, mob/user)
		if(locate(/obj/item/reagent_containers/glass/bucket) in targetDoor) //check again, just in case callback triggers after someone else did it
			boutput(user,"<b>There's already a bucket prank set up!</b>")
			return
		logTheThing(LOG_COMBAT, user, "Set up a bucket-door-prank with reagents: [log_reagents(src)] on [targetDoor]")
		RegisterSignal(targetDoor, COMSIG_DOOR_OPENED, PROC_REF(bucket_prank))
		user.u_equip(src)
		src.set_loc(targetDoor)
		user.visible_message(SPAN_ALERT("Props \the [src] above \the [targetDoor]!"),SPAN_ALERT("You prop \the [src] above \the [targetDoor]. The next person to come through will get splashed!"))
		var/image/I = image(src.icon, src, src.icon_state, targetDoor.layer+0.1, ,  )
		I.transform = matrix(I.transform, 0.5, 0.5, MATRIX_SCALE)
		I.transform = matrix(I.transform, (targetDoor.dir & (WEST | EAST) ? 0 : -16), (targetDoor.dir & (NORTH | SOUTH) ? 0 : -16), MATRIX_TRANSLATE)
		targetDoor.UpdateOverlays(I, "bucketprank")

	proc/bucket_prank(obj/machinery/door/targetDoor, atom/movable/AM)
		//fall off the door, splash the user, land on their head if you can
		//note that AM can be null, and this is caught by !IN_RANGE
		UnregisterSignal(targetDoor, COMSIG_DOOR_OPENED)
		targetDoor.UpdateOverlays(null, "bucketprank")
		var/splash = (src.reagents.total_volume > 1)
		if(!IN_RANGE(AM, targetDoor, 1)) //not in range or AM is null
			src.set_loc(get_turf(targetDoor))
			src.reagents.reaction(get_turf(targetDoor))
			src.reagents.clear_reagents()
			src.visible_message(SPAN_ALERT("[src] falls from \the [targetDoor][splash? ", splashing its contents on the floor" : ""]."))
		else //we're in range, splash the AM, splash the floor
			logTheThing(LOG_COMBAT, AM, "Victim of bucket-door-prank with reagents: [log_reagents(src)] on [targetDoor]")
			src.reagents.reaction(AM, TOUCH, src.reagents.total_volume/2) //half on the mover
			src.reagents.reaction(get_turf(targetDoor)) //half on the floor
			src.reagents.clear_reagents()
			if(ishuman(AM))
				//the bucket lands on your head for maximum comedy
				var/mob/living/carbon/human/H = AM
				var/obj/item/clothing/head/helmet/bucket/hat/bucket_hat = new src.hat_bucket_type(src.loc)
				if(isnull(H.head))
					H.equip_if_possible(bucket_hat, SLOT_HEAD)
					H.set_clothing_icon_dirty()
					H.visible_message(SPAN_ALERT("[src] falls from \the [targetDoor], landing on [H] like a hat[splash? ", and splashing [him_or_her(H)] with its contents" : ""]! [pick("Peak comedy!","Hilarious!","What a tool!")]"), \
										SPAN_ALERT("[src] falls from \the [targetDoor], landing on your head like a hat[splash? ", and splashing you with its contents" : ""]!"))
				else
					bucket_hat.set_loc(get_turf(H))
					H.visible_message(SPAN_ALERT("[src] falls from \the [targetDoor], [splash? "splashing" : "bouncing off"] [H] and falling to the floor."), \
										SPAN_ALERT("[src] falls from \the [targetDoor], [splash? "splashing you and " : ""]bouncing off your hat."))
				qdel(src) //it's a hat now
			else
				//aw, fine, it just falls on the floor
				src.set_loc(get_turf(targetDoor))
				targetDoor.visible_message(SPAN_ALERT("[src] falls from \the [targetDoor], [splash? "splashing" : "bouncing off"] [AM]!"))



	custom_suicide = 1
	suicide(var/mob/user as mob)
		user.u_equip(src)
		src.set_loc(get_turf(user))
		step_rand(src)
		user.visible_message(SPAN_ALERT("<b>[user] kicks the bucket!</b>"))
		user.death(FALSE)

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
	icon_state = "beaker"
	initial_volume = 50
	amount_per_transfer_from_this = 10
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	flags = TABLEPASS | OPENCONTAINER | SUPPRESSATTACK

/obj/item/reagent_containers/glass/large
	name = "large reagent glass"
	desc = "A large reagent glass."
	icon_state = "large_beaker"
	item_state = "beaker"
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	amount_per_transfer_from_this = 10
	flags = TABLEPASS | OPENCONTAINER | SUPPRESSATTACK

/obj/item/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "liquid"
	initial_reagents = list("fluorosurfactant"=20)

/obj/item/storage/box/beaker_lids
	name = "box of beaker lids"
	desc = "A box full of beaker lids, for putting lids on your beakers. For when you need something that's open... closed."
	spawn_contents = list(/obj/item/beaker_lid = 7)

/obj/item/beaker_lid
	name = "beaker lid"
	desc = "A one-size fits all beaker lid, capable of an airtight seal on any compatible beaker."
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	icon_state = "lid"
	w_class = W_CLASS_TINY

	attackby(obj/item/reagent_containers/container, mob/user)
		if (istype(container))
			container.try_to_apply_lid(src, user)

/obj/item/reagent_containers/glass/plumbing
	name = "abstract glass plumbing object"
	desc = "A set of glass tubes mysteriously spelling 'Call 1-800-CODER'."
	amount_per_transfer_from_this = 10
	incompatible_with_chem_dispensers = TRUE //could maybe be ok? idk
	can_recycle = FALSE //made of glass, but would be a waste and almost certainly accidental so no
	var/list/connected_containers = list() //! the containers currently connected to the condenser
	var/max_amount_of_containers = 4

	mouse_drop(atom/over_object, src_location, over_location)
		if(over_object == src)
			return
		if (istype(over_object, /obj/item/reagent_containers) && (over_object.is_open_container()))
			try_adding_container(over_object, usr)
		if (istype(over_object, /obj/reagent_dispensers/chemicalbarrel)) //barrels don't need to be open for condensers because it would be annoying I think
			try_adding_container(over_object, usr)

	set_loc(newloc, storage_check)
		if (src.loc != newloc && length(src.connected_containers))
			src.remove_all_containers()
		. = ..()
	Move()
		if(length(src.connected_containers))
			src.remove_all_containers()
		..()


	attack_hand(var/mob/user)
		if(length(src.connected_containers))
			src.remove_all_containers()
			boutput(user, SPAN_ALERT("You remove all connections to the [src.name]."))
		..()
	proc/try_adding_container(var/obj/container, var/mob/user)
		if (!istype(src.loc, /turf/) || !istype(container.loc, /turf/)) //if the condenser or container isn't on the floor you cannot hook it up
			return
		if (BOUNDS_DIST(src, user) > 0)
			boutput(user, SPAN_ALERT("The [src.name] is too for away for you to mess with it!"))
			return
		if (GET_DIST(container, src) > 1)
			usr.show_text("The [src.name] is too far away from the [container.name]!", "red")
			return
		if(length(src.connected_containers) >= src.max_amount_of_containers)
			boutput(user, SPAN_ALERT("The [src.name] can only be connected to [max_amount_of_containers] containers!"))
		else
			boutput(user, "<span class='notice'>You hook the [container.name] up to the [src.name].</span>")
		add_container(container)
	proc/add_line(var/obj/container)
		var/datum/lineResult/result = drawLineImg(src, container, "condenser", "condenser_end", src.pixel_x + 10, src.pixel_y, container.pixel_x, container.pixel_y + container.get_chemical_effect_position())
		result.lineImage.pixel_x = -src.pixel_x
		result.lineImage.pixel_y = -src.pixel_y
		result.lineImage.layer = src.layer+0.01
		src.UpdateOverlays(result.lineImage, "tube\ref[container]")

	proc/add_container(var/obj/container)
		//this is a mess but we need it to disconnect if ANYTHING happens
		if (!(container in src.connected_containers))
			RegisterSignal(container, COMSIG_ATTACKHAND, PROC_REF(remove_container)) //empty hand on either condenser or its connected container should disconnect
			RegisterSignal(container, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(remove_container_xsig))
			RegisterSignal(container, COMSIG_MOVABLE_MOVED, PROC_REF(remove_container))
		add_line(container)
		src.connected_containers.Add(container)

	proc/remove_container(var/obj/container)
		while (container in src.connected_containers)
			src.connected_containers.Remove(container)
		src.UpdateOverlays(null, "tube\ref[container]")
		UnregisterSignal(container, COMSIG_ATTACKHAND)
		UnregisterSignal(container, XSIG_OUTERMOST_MOVABLE_CHANGED)
		UnregisterSignal(container, COMSIG_MOVABLE_MOVED)

	proc/remove_container_xsig(datum/component/complexsignal, old_movable, new_movable)
		src.remove_container(complexsignal.parent)

	proc/try_adding_reagents_to_container(reagent, amount, sdata, temp_new, donotreact, donotupdate, priority) //called when a reaction occurs inside the condenser flagged with "chemical_reaction = TRUE"
		src.reagents.add_reagent(reagent, amount, sdata, temp_new, donotreact, donotupdate)
	proc/remove_all_containers()
		for(var/obj/container in src.connected_containers)
			remove_container(container)

/obj/item/reagent_containers/glass/plumbing/condenser
	name = "chemical condenser"
	desc = "A set of glass tubes useful for seperating reactants from products. Can be hooked up to many types of containers."
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	icon_state = "condenser"
	splash_all_contents = FALSE
	object_flags = OPENCONTAINER | SUPPRESSATTACK
	initial_volume = 100
	accepts_lid = TRUE
	fluid_overlay_states = 5
	container_style = "condenser"
	HELP_MESSAGE_OVERRIDE({"Click and drag this onto other glassware to connect it.
	Reaction products will flow equally to all connected glassware."})


	try_adding_reagents_to_container(reagent, amount, sdata, temp_new, donotreact, donotupdate, priority) //called when a reaction occurs inside the condenser flagged with "chemical_reaction = TRUE"
		if(length(src.connected_containers) <= 0) //if we have no beaker, dump the reagents into condenser
			src.reagents.add_reagent(reagent, amount, sdata, temp_new, donotreact, donotupdate)
		else
			add_reagents_to_containers(reagent, amount, sdata, temp_new, donotreact, donotupdate, priority)

	proc/add_reagents_to_containers(reagent, amount, sdata, temp_new, donotreact, donotupdate, priority)
		var/list/non_full_containers = list()
		for(var/obj/container in connected_containers)
			if(container.reagents.maximum_volume > container.reagents.total_volume) //don't bother with this if it's already full, move onto other containers
				non_full_containers.Add(container)
		if(!length(non_full_containers))	//all full? backflow!!
			src.reagents.add_reagent(reagent, amount, sdata, temp_new, donotreact, donotupdate)
			return
		var/divided_amount = (amount / length(non_full_containers)) //cut the reagents needed into chunks
		for(var/obj/container in non_full_containers)
			var/remaining_container_space = container.reagents.maximum_volume - container.reagents.total_volume
			if(remaining_container_space < divided_amount) 																			//if there's more reagent to add than the beaker can hold...
				container.reagents.add_reagent(reagent, remaining_container_space, sdata, temp_new, donotreact, donotupdate) //...add what we can to the beaker...
				src.add_reagents_to_containers(reagent, divided_amount - remaining_container_space, sdata, temp_new, donotreact, donotupdate)  //...then run the whole proc again with the remaining reagent, evenly distributing to remaining containers
			else
				container.reagents.add_reagent(reagent, divided_amount, sdata, temp_new, donotreact, donotupdate)
	disposing()
		src.remove_container()
		. = ..()

	fractional
		name = "fractional condenser"
		desc = "A set of glass tubes, conveniently capable of splitting the outputs of more advanced reactions. Can be hooked up to many types of containers."
		icon_state = "condenser_fractional"
		container_style = "condenser_fractional"
		max_amount_of_containers = 4
		/// orders the output containers, so key 1 = condenser output 1
		var/container_order[4]
		HELP_MESSAGE_OVERRIDE({"Click and drag this onto other glassware to connect it.
		If a reaction creates multiple products, this condenser separates them in the order YELLOW->RED->GREEN->BLUE."})

		add_reagents_to_containers(reagent, amount, sdata, temp_new, donotreact, donotupdate, priority)
			var/obj/chosen_container
			if (priority <= max_amount_of_containers)
				chosen_container = container_order[priority]

			if(!chosen_container || chosen_container.reagents.maximum_volume <= chosen_container.reagents.total_volume)	//all full? backflow!!
				src.reagents.add_reagent(reagent, amount, sdata, temp_new, donotreact, donotupdate)
				return

			var/remaining_container_space = chosen_container.reagents.maximum_volume - chosen_container.reagents.total_volume
			if(remaining_container_space < amount) 																			//if there's more reagent to add than the beaker can hold...
				chosen_container.reagents.add_reagent(reagent, remaining_container_space, sdata, temp_new, donotreact, donotupdate) //...add what we can to the beaker...
				src.reagents.add_reagent(reagent, amount, sdata, temp_new, donotreact, donotupdate)
			else
				chosen_container.reagents.add_reagent(reagent, amount, sdata, temp_new, donotreact, donotupdate)

		add_line(var/obj/container, var/containerNo)
			var/x_off = 5*((containerNo+1)%2)  //alternate between 0/+5
			var/y_off = (4*round((containerNo-1)/2)) //go up by 4 pixels for every 2nd connection
			var/datum/lineResult/result = drawLineImg(src, container, "condenser_[containerNo]", "condenser_end_[containerNo]", src.pixel_x-4+x_off, src.pixel_y+5+y_off, container.pixel_x, container.pixel_y + container.get_chemical_effect_position(), mode=LINEMODE_STRETCH_NO_CLIP)
			result.lineImage.layer = src.layer+0.01
			result.lineImage.pixel_x = -src.pixel_x
			result.lineImage.pixel_y = -src.pixel_y
			src.UpdateOverlays(result.lineImage, "tube\ref[containerNo]")
		remove_container(var/obj/container)
			for(var/i= 1 to max_amount_of_containers)
				if (container_order[i] == container)
					src.connected_containers.Remove(container)
					src.UpdateOverlays(null, "tube\ref[i]")
					container_order[i] = FALSE
					if (!(container in src.connected_containers))
						UnregisterSignal(container, COMSIG_ATTACKHAND)
						UnregisterSignal(container, XSIG_OUTERMOST_MOVABLE_CHANGED)
						UnregisterSignal(container, COMSIG_MOVABLE_MOVED)

		remove_container_xsig(datum/component/complexsignal, old_movable, new_movable)
			src.remove_container(complexsignal.parent)

		add_container(var/obj/container)
			if (!(container in src.connected_containers))
				RegisterSignal(container, COMSIG_ATTACKHAND, PROC_REF(remove_container)) //empty hand on either condenser or its connected container should disconnect
				RegisterSignal(container, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(remove_container_xsig))
				RegisterSignal(container, COMSIG_MOVABLE_MOVED, PROC_REF(remove_container))
			var/id = 1
			for(var/i= 1 to max_amount_of_containers)
				if (!container_order[i])
					id = i
					break
			add_line(container, id)
			src.container_order[id] = container
			src.connected_containers.Add(container)


/obj/item/reagent_containers/glass/plumbing/dropper
	name = "dropper funnel"
	desc = "A glass tube for adding reagents to containers at a customisable rate. Can be hooked up to many types of containers."
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	icon_state = "dropper_funnel_off"
	splash_all_contents = FALSE
	object_flags = OPENCONTAINER | SUPPRESSATTACK
	initial_volume = 100
	accepts_lid = TRUE
	rc_flags = RC_VISIBLE | RC_SCALE | RC_SPECTRO
	fluid_overlay_states = 8
	container_style = "dropper_funnel"
	var/open = FALSE
	var/flow_rate = 1
	HELP_MESSAGE_OVERRIDE({"Click and drag this onto other glassware to connect it.
	Flow rate can be adjusted either in your hand, or with a <b>screwdriver</b>.
	To pick this up, click and drag it onto your person."})

	get_desc()
		. = " The flow rate is set to [flow_rate]."

	disposing()
		src.remove_container()
		. = ..()

	mouse_drop(atom/over_object, src_location, over_location)
		if (ismob(over_object))
			var/mob/user = over_object
			if (user == usr && !user.restrained() && !is_incapacitated(user) && in_interact_range(src, user))
				if (!user.put_in_hand(src))
					return ..()
		else
			..()

	add_line(var/obj/container)
		var/datum/lineResult/result = drawLineImg(src, container, "condenser", "condenser_end", src.pixel_x-1, src.pixel_y-13, container.pixel_x, container.pixel_y + container.get_chemical_effect_position())
		result.lineImage.pixel_x = -src.pixel_x
		result.lineImage.pixel_y = -src.pixel_y
		result.lineImage.layer = src.layer+0.01
		src.UpdateOverlays(result.lineImage, "tube\ref[container]")
	attack_self(mob/user as mob)
		if(current_lid)
			boutput(user, SPAN_NOTICE("You pop the lid off of the [src]."))
			remove_current_lid(user)
		else
			adjust_flow_rate(user)
		return

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/screwdriver))
			adjust_flow_rate(user)
			user.visible_message(SPAN_NOTICE("[user.name] adjusts the flow rate of \the [src.name]."))
			return
		..()
	process()
		if (open)
			for(var/obj/container in connected_containers)
				src.reagents.trans_to(container, flow_rate)
	set_loc(newloc, storage_check)
		set_flow(FALSE)
		. = ..()
	Move()
		set_flow(FALSE)
		. = ..()
	attack_hand(mob/user)
		if (length(src.connected_containers) <= 0)
			..()
		else
			src.add_fingerprint(user)
			set_flow(!open)

	proc/adjust_flow_rate(mob/user)
		var/number = tgui_input_number(user,"Set flow rate, per beaker", "Set flow rate (1-10)",flow_rate,10,1,FALSE,TRUE)
		if (number && flow_rate != number)
			flow_rate = number
		src.tooltip_rebuild = 1
	proc/set_flow(var/desired_state)
		if (!desired_state && open)
			processing_items -= src
			open = FALSE
			flick("dropper_funnel_swoff",src)
			icon_state = "dropper_funnel_off"
		else if(desired_state && !open)
			processing_items |= src
			open = TRUE
			flick("dropper_funnel_swon",src)
			icon_state = "dropper_funnel_on"



/obj/item/reagent_containers/glass/plumbing/dispenser
	name = "portable chemical dispenser"
	desc = "A synthesizer, ripped from a Chem Dispenser, capable of placing reagents in glassware at a fixed rate."
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	icon_state = "producer"
	splash_all_contents = FALSE
	object_flags = SUPPRESSATTACK
	initial_volume = 0
	accepts_lid = TRUE
	rc_flags = FALSE
	fluid_overlay_states = 0
	container_style = "condenser"
	var/running = FALSE
	var/flow_rate = 1
	var/reagent_to_fabricate = ""
	var/fabrication_tick = 0
	var/ticks_to_fabricate = 4
	var/image/fabricating_overlay = null
	var/image/fabrication_tick_lights = null
	HELP_MESSAGE_OVERRIDE({"Click and drag this onto other glassware to connect it.
	Flow rate and chemical fabricated can be adjusted either in your hand, or with a <b>screwdriver</b>.
	To pick this up, click and drag it onto your person."})


	get_desc()
		. = " It is set to dispense [flow_rate] units of [reagent_to_fabricate]."

	New()
		. = ..()

	disposing()
		src.remove_container()
		. = ..()

	mouse_drop(atom/over_object, src_location, over_location)
		if (ismob(over_object))
			var/mob/user = over_object
			if (user == usr && !user.restrained() && !is_incapacitated(user) && in_interact_range(src, user))
				if (!user.put_in_hand(src))
					return ..()
		else
			..()

	add_line(var/obj/container)
		var/datum/lineResult/result = drawLineImg(src, container, "condenser", "condenser_end", src.pixel_x + 10, src.pixel_y, container.pixel_x, container.pixel_y + container.get_chemical_effect_position())
		result.lineImage.pixel_x = -src.pixel_x
		result.lineImage.pixel_y = -src.pixel_y
		result.lineImage.layer = src.layer+0.01
		src.UpdateOverlays(result.lineImage, "tube\ref[container]")
	attack_self(mob/user as mob)
		adjust_flow_rate(user)
		return

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/screwdriver))
			adjust_flow_rate(user)
			user.visible_message(SPAN_NOTICE("[user.name] adjusts \the [src.name]."))
			return
		..()
	process()
		if (running)
			fabrication_tick += 1
			if (fabrication_tick >= ticks_to_fabricate)
				fabrication_tick = 0
				var/reagents_per_container = flow_rate / length(connected_containers)
				for(var/obj/container in connected_containers)
					container.reagents.add_reagent(reagent_to_fabricate, reagents_per_container)
			update_visuals()


	set_loc(newloc, storage_check)
		set_flow(FALSE)
		. = ..()
	Move()
		set_flow(FALSE)
		. = ..()
	attack_hand(mob/user)
		if (length(src.connected_containers) <= 0)
			..()
		else
			src.add_fingerprint(user)
			set_flow(!running)

	proc/update_visuals()
		if (running && fabrication_tick > 0)
			fabrication_tick_lights = image('icons/obj/items/chemistry_glassware.dmi',"producer_lights_[fabrication_tick]")
		else
			fabrication_tick_lights = null

		if (reagent_to_fabricate)
			if (running)
				fabricating_overlay = image('icons/obj/items/chemistry_glassware.dmi',"producer_chem_active")
			else
				fabricating_overlay = image('icons/obj/items/chemistry_glassware.dmi',"producer_chem")

			var/datum/reagent/reagent_instance = reagents_cache[reagent_to_fabricate]
			var/list/hsl = rgb2hsl(reagent_instance.fluid_r,reagent_instance.fluid_g,reagent_instance.fluid_b)
			fabricating_overlay.color =  hsl2rgb(hsl[1], hsl[2], clamp(hsl[3],255,20))

		else
			fabricating_overlay = null
		src.UpdateOverlays(src.fabrication_tick_lights, "light")
		src.UpdateOverlays(src.fabricating_overlay, "overlay")

	proc/adjust_flow_rate(mob/user)
		var/reagent = tgui_input_list(user,"Set desired reagent", "Set reagent", basic_elements, reagent_to_fabricate)
		if (reagent == null)
			return
		var/number = tgui_input_number(user,"Set fabrication volume, in units", "Set fabrication rate (1-5)",flow_rate,5,1,FALSE,TRUE)
		if (reagent && (reagent in basic_elements) && reagent_to_fabricate != reagent)
			reagent_to_fabricate = reagent
		if (number && flow_rate != number)
			flow_rate = number
		src.tooltip_rebuild = 1
		update_visuals()

	proc/set_flow(var/desired_state)
		if (!desired_state && running)
			processing_items -= src
			running = FALSE
			fabrication_tick = 0
		else if(desired_state && !running && reagent_to_fabricate)
			processing_items |= src
			running = TRUE
		update_visuals()



/obj/item/reagent_containers/synthflesh_pustule
	name = "synthetic pustule"
	desc = "A disgusting beating mass of synthetic meat. Could probably be plopped into a beaker..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pustule-medium"
	w_class = W_CLASS_NORMAL
	initial_volume = 100
	incompatible_with_chem_dispensers = TRUE
	can_recycle = FALSE
	var/amount_of_reagent_to_use = 30 //!how much blood to remove per process tick, medium pustule is very fast
	var/chemical_efficiency = 1 //!how much chemical you get per unit of chemical in
	var/organ_efficiency = 0.5 //!synthflesh organ multiplier
	var/makes_noise_when_full = TRUE //here so the tiny ones don't burp on creation lol
	var/angry = FALSE
	var/angry_timer = 15
	var/list/convertible_reagents = list("blood","bloodc","bloody_mary","bloody_scary","hemolymph", "viscerite_viscera")

	New()
		START_TRACKING
		processing_items.Add(src)
		original_icon_state = icon_state
		flick("[icon_state]-plop", src)
		..()

	disposing()
		STOP_TRACKING
		..()

	proc/convert_reagent(reagent_id, volume)
		var/reagent_to_add
		switch(reagent_id)
			if("blood", "hemolypmh")
				reagent_to_add = "synthflesh"
			if("bloodc")
				reagent_to_add = "meat_slurry"
			if("bloody_mary", "bloody_scary")
				reagent_to_add = "ethanol"
			if("viscerite_viscera")
				reagent_to_add = null
		if(reagent_to_add)
			src.reagents.add_reagent(reagent_to_add, volume * chemical_efficiency)

		if(reagent_id == "viscerite_viscera") // Special processing is needed for this chem because its my birthday and I get to have feature bloat
			src.reagents.add_reagent("martian_flesh", ((volume / chemical_efficiency) * 0.35)) // Large pustules produce half the amount of martian flesh. Apologies for the magic number here, it's avoiding digestion producing net amounts of chems which leads to bugs.
			src.reagents.add_reagent("synthflesh", ((volume * chemical_efficiency)  * 0.35)) // Large pustules also produce twice the amount of synthflesh
			if(prob(20 / chemical_efficiency)) // 20% chance of offgassing for medium/small, 10% for large pustules
				var/datum/reagents/smokeContents = new/datum/reagents()
				smokeContents.add_reagent("acid", volume / chemical_efficiency)
				smoke_reaction(smokeContents, 2, get_turf(src), do_sfx = TRUE)
		src.reagents.remove_reagent(reagent_id, volume)

	proc/become_angry() //become dangerous to pick up
		if (reagents.total_volume >= reagents.maximum_volume) //can't be angry on a full stomach
			return
		icon_state = "[original_icon_state]-irregular"
		angry = TRUE

	proc/become_unangry()
		icon_state = original_icon_state
		angry = FALSE
		angry_timer = rand(10,20)

	proc/eat_arm(var/mob/living/carbon/human/H, var/which_arm = "left")
		H.visible_message("<span class = 'alert'>The [src.name] rips off [H.name]'s arm! Shit!</span>")
		playsound(src.loc, 'sound/items/eatfoodshort.ogg', 100, 1)
		playsound(src.loc, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 50, 1)
		animate_shake(src, 2 , 0, 3, 0, 0)
		reagents.add_reagent("synthflesh", 40 * organ_efficiency)
		H.emote("scream")
		become_unangry()
		if(which_arm == "right")
			H.limbs.r_arm?.delete()
		else if(which_arm == "left")
			H.limbs.l_arm?.delete()

	process()
		if(angry && istype(src.loc, /mob/living/carbon/human/))
			var/mob/living/carbon/human/H = src.loc
			if(H.find_in_hand(src, "left"))
				H.put_in_hand_or_drop(src)
				eat_arm(H, "left")
			if(H.find_in_hand(src, "right"))
				H.put_in_hand_or_drop(src)
				eat_arm(H, "right")
		if(angry_timer > 0 && !angry)
			angry_timer--
		else
			if(prob(10))
				become_angry()
		for(var/reagent_id in convertible_reagents)
			var/reagent_present = src.reagents.get_reagent_amount(reagent_id)
			if(reagent_present > 0)
				if(reagent_present < amount_of_reagent_to_use)
					convert_reagent(reagent_id, reagent_present)
				else
					convert_reagent(reagent_id, amount_of_reagent_to_use)
		..()

	attackby(var/obj/item/W, mob/user)
		if(istype(W, /obj/item/reagent_containers/iv_drip))
			var/obj/item/reagent_containers/iv_drip/iv = W
			if(!iv.slashed)
				boutput(user, SPAN_ALERT("The [iv.name] needs to be cut open first!"))
				return
			else if (reagents.total_volume >= reagents.maximum_volume)
				boutput(user, SPAN_ALERT("The [src] is too full!"))
				return
			else if (!iv.reagents.total_volume)
				boutput(user, SPAN_ALERT("The [iv.name] is empty!"))
				return
			else
				user.visible_message("<span class = 'alert'>[user.name] splashes all the reagent in the [iv.name] onto the [src.name].</span>")
				iv.reagents.reaction(src,TOUCH)
				iv.reagents.clear_reagents()

		if(istype(W, /obj/item/organ))
			var/obj/item/organ/organ = W
			if(!(organ.material.getMaterialFlags() & MATERIAL_ORGANIC))
				boutput(user, SPAN_ALERT("The [src] rejects the non-organic organ!"))
			else if (reagents.total_volume >= reagents.maximum_volume)
				boutput(user, SPAN_ALERT("The [src] is too full!"))
			else
				user.visible_message("<span class = 'alert'>[user.name] stuffs the [organ.name] into the [src.name].</span>")
				playsound(src.loc, 'sound/items/eatfoodshort.ogg', 50, 1)
				animate_shake(src, 2 , 0, 3, 0, 0)
				qdel(organ)
				reagents.add_reagent("synthflesh", 40 * organ_efficiency)
				become_unangry()

		if(W.material?.isSameMaterial(getMaterial("viscerite")))
			var/obj/item/visc = W
			if (reagents.total_volume >= reagents.maximum_volume)
				boutput(user, SPAN_ALERT("The [src] is too full!"))
			else
				if(visc.amount == 1)
					reagents.add_reagent("viscerite_viscera", 20 * visc.amount * visc.material_amt) // Gets converted into synthflesh (and some other stuff). Small/medium pustules produce 7 synthflesh and 7 martian flesh per visc, large produce 14 synthflesh and 3.5 martian flesh per visc
					qdel(visc)
				else // Oh boy oh boy are you ready for somewhat messy code to deal with stacks
					var/leftover_space = (reagents.maximum_volume - reagents.total_volume)
					var/max_amt_removal = round(leftover_space / (20 * visc.material_amt))
					var/amt_to_remove = 0
					if(max_amt_removal == 0)
						return
					else if (visc.amount > max_amt_removal)
						amt_to_remove = max_amt_removal
					else
						amt_to_remove = visc.amount
					reagents.add_reagent("viscerite_viscera", 20 * amt_to_remove * visc.material_amt)
					visc.change_stack_amount(-amt_to_remove)
				user.visible_message("<span class = 'alert'>[user.name] stuffs the [visc.name] into the [src.name].</span>")
				playsound(src.loc, 'sound/items/eatfoodshort.ogg', 50, 1)
				animate_shake(src, 2 , 0, 3, 0, 0)
				become_unangry()

		else
			if (W.force >= 5) //gotta smack it with something a little hefty at least
				user.lastattacked = get_weakref(src)
				attack_particle(user,src)
				hit_twitch(src)
				playsound(src, 'sound/impact_sounds/Generic_Slap_1.ogg', 50,TRUE)
				user.visible_message(SPAN_ALERT("<b>[user.name] smacks the [src.name] with the [W.name]!</b>"))
				if(angry)
					become_unangry()
				else
					angry_timer = rand(5,20)

	reagent_act(id, volume, var/datum/reagents/holder_reagents)
		if(reagents.total_volume >= reagents.maximum_volume)
			return
		if (!convertible_reagents.Find(id))
			// boutput(world, "no [id] found")
			return
		holder_reagents.remove_reagent(id, volume)
		playsound(src.loc, 'sound/items/drink.ogg', 50, 1)
		animate_shake(src, 2 , 0, 3, 0, 0)
		reagents.add_reagent(id, volume)
		become_unangry()

	on_reagent_change(add) //it burps once it's full of reagents it cannot convert aka product
		if(reagents.total_volume >= reagents.maximum_volume && makes_noise_when_full)
			for(var/id in convertible_reagents)
				if (reagents.reagent_list.Find(id))
					return
			playsound(src.loc, 'sound/voice/burp.ogg', 50, 1)
		..()

	attack_hand(var/mob/user)
		if(angry && ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.hand == 0)
				eat_arm(H, "right")
			else
				eat_arm(H, "left")
			return
		..()

	throw_impact(atom/A, datum/thrown_thing/thr)
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
		var/turf/T = get_turf(A)
		if(src.reagents.get_reagent_amount("blood") >= 10)
			src.reagents.remove_reagent("blood", 10) //blood decals give you 10 blood in a beaker. so you remain blood neutral here
			make_cleanable(/obj/decal/cleanable/blood,T)

	small
		desc = "An icky, tiny, beating blop of synthetic meat. Could probably be plipped into a beaker..."
		icon_state = "pustule-small"
		w_class = W_CLASS_TINY
		initial_volume = 10
		initial_reagents = list("synthflesh"=10) //these things won't be efficient at all for making synthflesh anyways so they come pre-loaded.
		makes_noise_when_full = FALSE

		throw_impact(atom/A, datum/thrown_thing/thr)
			playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_1.ogg', 100, 1)
			src.reagents.reaction(A,TOUCH) //you can use small ones to throw synthflesh at people, gross but fun maybe
			qdel(src)

	large
		desc = "A vile, large, beating globule of synthetic meat. Could probably be kerplopped into a beaker... or better, a barrel."
		icon_state = "pustule-large"
		w_class = W_CLASS_BULKY
		initial_volume = 800
		amount_of_reagent_to_use = 5 //slow but...
		chemical_efficiency = 2 //...lots of synthflesh per unit of blood
		organ_efficiency = 2

#define BUNSEN_OFF "off"
#define BUNSEN_LOW "low"
#define BUNSEN_MEDIUM "medium"
#define BUNSEN_HIGH "high"
/obj/item/bunsen_burner
	name = "Bunsen burner"
	desc = "A Bunsen burner capable of holding up chemical containers and heating them at three different heat levels."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bunsen"
	w_class = W_CLASS_NORMAL
	var/temperature_setting = BUNSEN_LOW
	var/is_currently_burning = FALSE //keep seperate from temp setting so it stays on the same setting if you turn it off and on
	var/obj/item/reagent_containers/current_container = null
	var/list/datum/contextAction/contexts = list()
	var/image/light_image = null
	var/current_temp_to_heat = 20 //!how much the bunsen burner heats per processing tick
	var/current_temp_cap = 110 //!how hot the container will have to be before it stops heating
	var/datum/component/loctargeting/simple_light/burning_light
	contextLayout = new /datum/contextLayout/experimentalcircle

	New()
		contexts += new /datum/contextAction/bunsen/heat_low
		contexts += new /datum/contextAction/bunsen/heat_medium
		contexts += new /datum/contextAction/bunsen/heat_high
		contexts += new /datum/contextAction/bunsen/heat_off
		burning_light = src.AddComponent(/datum/component/loctargeting/simple_light, 255, 255, 255, 150)
		burning_light.update(FALSE)
		..()

	get_desc()
		if(!is_currently_burning)
			. = " It's presently off."
		else
			. = " Its flame is set to [temperature_setting]."

	process()
		if (QDELETED(src.current_container))
			src.current_container = null
		if(is_currently_burning && current_container)
			heat_container()
		..()

	update_icon()
		if(!is_currently_burning)
			icon_state = "bunsen"
		else switch(temperature_setting)
			if(BUNSEN_LOW)
				icon_state = "bunsen_low"
			if(BUNSEN_MEDIUM)
				icon_state = "bunsen_medium"
			if(BUNSEN_HIGH)
				icon_state = "bunsen_high"
		if(current_container)
			if (!src.light_image)
				src.light_image = image(src.icon)
				src.light_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
				src.light_image.icon_state = "bunsen_light"
				src.light_image.plane = PLANE_ABOVE_LIGHTING
			src.UpdateOverlays(light_image, "light")
		else
			src.UpdateOverlays(null, "light")

	proc/change_status(var/status)
		burning_light.update(FALSE)
		if(status != "off")
			switch(status)
				if(BUNSEN_LOW)
					burning_light.set_color(245, 181, 61)
					current_temp_to_heat = 35
					current_temp_cap = 400
				if(BUNSEN_MEDIUM)
					burning_light.set_color(235, 54, 245)
					current_temp_to_heat = 50
					current_temp_cap = 700
				if(BUNSEN_HIGH)
					burning_light.set_color(53, 196, 240)
					current_temp_to_heat = 65
					current_temp_cap = 900
			temperature_setting = status
			burning_light.update(TRUE)
			if(!is_currently_burning)
				playsound(src.loc, pick('sound/effects/flame.ogg'), 75, 1) //only play the 'turning on burner' sound when turning on... the burner
				is_currently_burning = TRUE
				processing_items.Add(src)
		if(is_currently_burning && status == BUNSEN_OFF)
			processing_items.Remove(src)
			playsound(src.loc, pick('sound/effects/poff.ogg'), 25, 1)
			is_currently_burning = FALSE
		src.UpdateIcon()

	proc/heat_container()
		current_container.reagents.temperature_reagents(current_temp_cap, change_cap = current_temp_to_heat, change_min = current_temp_to_heat, cannot_be_cooled = TRUE)

	attack_hand(var/mob/user)
		if(current_container) //if it has a container loaded you fiddle with the controls instead of picking it up
			user.showContextActions(src.contexts, src, contextLayout)
		else
			..()

	attack_ai(mob/user as mob)
		if (BOUNDS_DIST(src, user) > 0) return
		src.Attackhand(user)

	attack_self(var/mob/user)
		user.showContextActions(src.contexts, src, contextLayout)

	attackby(I, mob/user)
		if (istype(I, /obj/item/reagent_containers))
			try_to_put_on_bunsen_burner(I, user)

	MouseDrop_T(atom/O as obj, mob/user as mob)
		if (!istype(O,/obj/)) return
		if (BOUNDS_DIST(user, src) > 0 || !in_interact_range(user, O)) return
		src.Attackby(O, user)

	mouse_drop(atom/over_object, src_location, over_location)
		if (!current_container) return
		if (!istype(over_location, /turf/)) return
		if (BOUNDS_DIST(src, over_location) > 0) return
		if (!in_interact_range(usr, src)) return
		remove_container()

	proc/try_to_put_on_bunsen_burner(var/obj/item/reagent_containers/container, var/mob/user)
		if (!istype(src.loc, /turf/)) //can't use bunsen burners if not on a turf
			return
		if(current_container)
			return
		user.drop_item(container)
		container.set_loc(get_turf(src))
		container.layer = src.layer+0.1
		container.pixel_x = src.pixel_x
		container.pixel_y = src.pixel_y + 12
		current_container = container
		src.UpdateIcon()
		RegisterSignal(container, COMSIG_ATTACKHAND, PROC_REF(remove_container)) //only register this on the container since attackhand opens menu
		for(var/item in list(src, container))
			RegisterSignal(item, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(remove_container_xsig))
			RegisterSignal(item, COMSIG_MOVABLE_MOVED, PROC_REF(remove_container))

	proc/remove_container_xsig(datum/component/complexsignal, old_movable, new_movable)
		src.remove_container(complexsignal.parent)

	proc/remove_container()
		UnregisterSignal(current_container, COMSIG_ATTACKHAND, PROC_REF(remove_container))
		for(var/item in list(src, current_container))
			UnregisterSignal(item, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(remove_container))
			UnregisterSignal(item, COMSIG_MOVABLE_MOVED, PROC_REF(remove_container))
		current_container.pixel_y -= 12 //this isn't vital, but adds a visual cue if it gets disconnected by dragging or something
		current_container = null
		src.UpdateIcon()

#undef BUNSEN_OFF
#undef BUNSEN_LOW
#undef BUNSEN_MEDIUM
#undef BUNSEN_HIGH

/obj/item/reagent_containers/glass/vial
	name = "vial"
	desc = "A vial. Can hold up to 5 units."
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	icon_state = "phial"
	item_state = "vial"
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	accepts_lid = TRUE
	fluid_overlay_states = 5
	container_style = "phial"

	New()
		var/datum/reagents/R = new /datum/reagents(5)
		R.my_atom = src
		src.reagents = R
		..()

/obj/item/reagent_containers/glass/vial/plastic
	name = "plastic vial"
	desc = "A 3D-printed vial. Can hold up to 5 units. Barely."
	can_recycle = FALSE

	New()
		. = ..()
		AddComponent(/datum/component/biodegradable)

/obj/item/reagent_containers/glass/petridish
	name = "Petri Dish"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "petri0"
	desc = "A dish tailored hold pathogen cultures."
	initial_volume = 40
	rc_flags = 0
	flags = TABLEPASS | CONDUCT | OPENCONTAINER

/obj/item/bloodslide
	name = "Blood Slide"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "slide0"
	desc = "An item used by scientists and serial killers operating in the Miami area to store blood samples."

	var/datum/reagent/blood/blood = null

	flags = TABLEPASS | CONDUCT | NOSPLASH

	New()
		..()
		var/datum/reagents/R = new /datum/reagents(5)
		src.reagents = R

	attackby(obj/item/I, mob/user)
		return

	on_reagent_change()
		..()
		reagents.maximum_volume = reagents.total_volume // This should make the blood slide... permanent.
		if (reagents.has_reagent("blood") || reagents.has_reagent("bloodc"))
			icon_state = "slide1"
			desc = "The blood slide contains a drop of blood."
			if (reagents.has_reagent("blood"))
				blood = reagents.get_reagent("blood")
			else if (reagents.has_reagent("bloodc"))
				blood = reagents.get_reagent("bloodc")
			if (blood == null)
				boutput(usr, SPAN_ALERT("Blood slides are not working. This is an error message, please page 1-800-555-MARQUESAS."))
				return
		else
			desc = "This blood slide is contaminated and useless."
