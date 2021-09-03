//this is a secret
//don't tell anyone
//not even me.
//also definitely do NOT include this file.
//#warn DO NOT BUILD WITH THIS FILE ENABLED. NO. NO NO NO NEVER.

#define DEFAULT_MUD_COLOR "#964B00"
#define DRY_MUD 1
#define FRESH_MUD 0

/atom/var/mud_stained = 0



/proc/muddy(var/mob/living/some_idiot, var/num_amount, var/vis_amount, var/turf/T as turf)

	if (!T)
		T = get_turf(some_idiot)

	var/obj/decal/cleanable/mud/dynamic/B = null
	if (T.messy > 0)
		B = locate(/obj/decal/cleanable/mud/dynamic) in T
	var/mud_color_to_pass = DEFAULT_MUD_COLOR

	if (!B) // look for an existing dynamic blood decal and add to it if you find one
		B = make_cleanable( /obj/decal/cleanable/mud/dynamic,T)
		B.color = mud_color_to_pass

	B.add_volume(mud_color_to_pass, num_amount, vis_amount)
	return



/atom/proc/add_mud(mob/living/M as mob, var/amount = 5,)
	if (!(( src.flags) & FPRINT))
		return

	if (isitem(src))
		var/obj/item/I = src

		var/icon/new_icon

		if (I.uses_multiple_icon_states)
			new_icon = new /icon(I.icon)
		else
			new_icon = new /icon(I.icon, I.icon_state)

		new_icon.Blend(new /icon('icons/effects/blood.dmi', "thisisfuckingstupid"), ICON_ADD)

		new_icon.Blend(DEFAULT_MUD_COLOR, ICON_MULTIPLY)

		new_icon.Blend(new /icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY)

		if (I.uses_multiple_icon_states)
			new_icon.Blend(new /icon(I.icon), ICON_UNDERLAY)
		else
			new_icon.Blend(new /icon(I.icon, I.icon_state), ICON_UNDERLAY)

		I.icon = new_icon

		if (istype(I, /obj/item/clothing))
			var/obj/item/clothing/C = src
			C.add_stain("mud-stained")

		else
			I.name = "[pick("filthy ","muddy ","dirty ")] [I]"



	else if (istype(src, /turf/simulated))
		muddy(M, amount, rand(1,3), src)

	else
		return

/mob/living/carbon/human
	var/mud_gib_stage = 0.0


/mob/living/track_mud()
	if (!islist(src.tracked_mud))
		return
	var/turf/T = get_turf(src)
	var/obj/decal/cleanable/mud/dynamic/tracks/B = null
	if (T.messy > 0)
		B = locate(/obj/decal/cleanable/mud/dynamic) in T

	var/mud_color_to_pass = src.tracked_mud["color"] ? src.tracked_mud["color"] : DEFAULT_MUD_COLOR

	if (!B)
		if (T.active_liquid)
			return
		B = make_cleanable( /obj/decal/cleanable/mud/dynamic/tracks,get_turf(src))
		B.set_sample_reagent_custom(src.tracked_mud["sample_reagent"],0)

	B.add_volume(mud_color_to_pass, src.tracked_mud["sample_reagent"], 1, 0, src.tracked_mud, "footprints[rand(1,2)]", src.last_move, 0)

	if (src.tracked_mud && isnum(src.tracked_mud["count"])) // mirror from below
		src.tracked_mud["count"] --
		if (src.tracked_mud["count"] <= 0)
			src.tracked_mud = null
			src.set_clothing_icon_dirty()
			return
	else
		src.tracked_mud = null
		src.set_clothing_icon_dirty()
		return

/obj/item/reagent_containers/food/snacks/ingredient/mud
	name = "mud"
	desc = "It is mud."
	icon = '+secret/icons/misc/not_poo.dmi'
	icon_state = "mud1"
	color = DEFAULT_MUD_COLOR
	//item_state = "poop"
	var/mob/living/carbon/owner = null
	amount_per_transfer_from_this = 10

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src
		R.add_reagent("poo", 10)
		icon_state = "mud[rand(1,3)]"

	heal(var/mob/living/M)
		if (prob(33))
			boutput(M, "<span class='alert'>You briefly think you probably shouldn't be eating mud.</span>")
			M.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)

		if (istype(T))
			make_cleanable( /obj/decal/cleanable/mud,T)



		if (ishuman(A))
			var/mob/living/carbon/human/H = A
			if (H.wear_suit)
				H.wear_suit.add_mud(src)
				H.set_clothing_icon_dirty()
			else if (H.w_uniform)
				H.w_uniform.add_mud(src)
				H.set_clothing_icon_dirty()
			else
				if (H.shoes)
					H.shoes.add_mud(src)
					H.set_clothing_icon_dirty()
		else
			A.add_mud(src)

		qdel(src)

		..()



/obj/decal/cleanable/mud
	name = "mud stain"
	desc = "Ewww, doesn't this violate health code?"
	sample_reagent = "poo"
	can_sample = 1
	density = 0
	anchored = 1
	color = DEFAULT_MUD_COLOR
	//layer = 2
	icon = '+secret/icons/misc/not_poo.dmi'
	icon_state = "floor1"
	var/datum/ailment/disease/virus = null
	blood_DNA = null
	blood_type = null
	slippery = 50
	can_dry = 1
	stain = "mud-stained"
	var/can_track =1
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7", "floor8")
	var/reagents_max = 15


	New()
		src.create_reagents(reagents_max)
		src.reagents.add_reagent("poo", 10)
		..()

	pooled()
		..()

	unpooled()
		..()

	setup()
		if (!src.reagents)
			src.create_reagents(reagents_max)
		else
			src.reagents.clear_reagents()
		src.reagents.add_reagent("poo", 10)
		..()

		SPAWN_DBG(0)
			if (!src.pooled)
				for (var/obj/O in src.loc)
					LAGCHECK(LAG_LOW)
					if (O && (!src.pooled) && prob(max(src?.reagents.total_volume*5, 10)))
						O.add_mud(src)

	proc/set_sample_reagent_custom(var/reagent_id, var/amt = 10)
		if (!src.reagents)
			src.create_reagents(reagents_max)
		else
			src.reagents.clear_reagents()

		src.sample_reagent = reagent_id
		src.reagents.add_reagent(reagent_id, amt)

	proc/add_tracked_mud(atom/movable/AM as mob|obj)
		AM.tracked_mud = list("color" = src.get_mud_color(), "count" = rand(2,6), "sample_reagent" = sample_reagent)
		if (ismob(AM))
			var/mob/M = AM
			M.set_clothing_icon_dirty()


	HasEntered(atom/movable/AM as mob|obj)
		..()
		if (!istype(AM))
			return
		if (src.dry == FRESH_MUD && src.reagents.total_volume >= 5 && src.can_track)
			if (ishuman(AM))
				var/mob/living/carbon/human/H = AM
				if (H.lying)
					if (H.wear_suit)
						H.wear_suit.add_mud(src)
						H.set_clothing_icon_dirty()
					else if (H.w_uniform)
						H.w_uniform.add_mud(src)
						H.set_clothing_icon_dirty()
				else
					if (H.shoes)
						H.shoes.add_mud(src)
						H.set_clothing_icon_dirty()
				if (!AM.anchored)
					src.add_tracked_mud(AM)
			else if (isliving(AM))// || isobj(AM))
				AM.add_mud(src)
				if (!AM.anchored)
					src.add_tracked_mud(AM)


	Dry(var/time = rand(300,600))
		if (!src.can_dry || src.dry == DRY_MUD)
			src.stain = null
			return 0
		if (ticker) // don't do this unless the game has started
			src.dry = FRESH_MUD // fresh!!
			src.UpdateName()

		dry_time = time
		last_dry_start = world.time
		processing_items.Add(src)

	end_dry()
		src.dry = DRY_MUD
		src.stain = null
		src.UpdateName()
		processing_items.Remove(src)

	proc/get_mud_color()
		return src.color


	disposing()
		..()

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.dry == DRY_MUD ? "dried " : src.dry == FRESH_MUD ? "fresh " : null][src.real_name][name_suffix(null, 1)]"

	get_desc(dist)
		if (src.dry) // either fresh (-1) or dry (1)
			. = " It's [src.dry == DRY_MUD ? "dry and flakey" : "fresh"]."

	proc/streak(var/list/directions, randcolor = 0)
		SPAWN_DBG(0)
			var/direction = pick(directions)
			for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
				LAGCHECK(LAG_LOW)//sleep(0.3 SECONDS)
				if (i > 0)
					var/obj/decal/cleanable/mud/b = make_cleanable( /obj/decal/cleanable/mud/splatter/extra,get_turf(src))
					if (!b) continue //ZeWaka: fix for null.diseases
					if (src && src.diseases)
						b.diseases += src.diseases
					if (randcolor) // only used by funnygibs atm. in the future, the possibilities are endless for this var. imagine what it could do..........
						b.color = random_saturated_hex_color()
				if (step_to(src, get_step(src, direction), 0))
					break

	proc/handle_reagent_list(var/list/reagent_list)
		if (!reagent_list || !length(reagent_list))
			return


// I don't think every blood decal needed these lists on them, I can't imagine that was nice for performance

#define list_and_len(x) (istype(x, /list) && x:len) // just to make sure it's a list and it's got something in it

/obj/decal/cleanable/mud/dynamic
	desc = "It's not poo."
	icon_state = "blank" // if you make any more giant white cumblobs all over my nice blood decals
	random_icon_states = null // I swear to god I will fucking end you
	slippery = 0 // increases as blood volume does
	color = null
	last_color = null
	var/last_volume = 1
	reagents_max = 100

	disposing()
		diseases = list()
		..()

	unpooled()
		..()

	get_mud_color()
		return src.last_color

	Dry(var/time = rand(300,600))
		if (!src.can_dry) // if it's already dry, unlike the non-dynamic blood decals, we don't wanna return, since the blood will be freshened up again
			src.stain = null
			return 0
		if (ticker) // don't do this unless the game has started
			dry_time = time
			src.dry = FRESH_MUD // fresh!!
			src.UpdateName()
			src.dry_time = time
			last_dry_start = world.time
			if (!processing_items.Find(src))
				processing_items.Add(src)
			return 1

	end_dry()
		if (src.dry == FRESH_MUD)
			src.dry = 0
			src.UpdateName()
			src.dry_time = rand(300,600)
		else
			src.dry = DRY_MUD
			src.stain = null
			src.UpdateName()
			processing_items.Remove(src)
			return

	proc/add_volume(var/add_color, var/reagent_id = "poo", var/amount = 1, var/vis_amount = 1, var/list/bdata = null, var/i_state = null, var/direction = null, var/do_fluid_react = 1)

	// vis_amount should only be 1-5 if you want anything to happen
		src.reagents.add_reagent(reagent_id, amount)

		var/turf/simulated/floor/T = src.loc
		if (istype(T) && do_fluid_react)
			if (T.cleanable_fluid_react(src))
				return

		/*if (istext(amount))
			create_overlay(amount, add_color, direction)
			amount = 1 // so the rand()s and prob()s down there doesn't freak out
		*/

		if (i_state)
			create_overlay(i_state, add_color, direction)
		else if (isnum(vis_amount))
			switch (vis_amount)
				if (1)
					if (!list_and_len(blood_decal_low_icon_states))
						return
					create_overlay(blood_decal_low_icon_states, add_color, direction)
					// no increase in slipperiness if there's just a little bit of blood being added
				if (2)
					if (!list_and_len(blood_decal_med_icon_states))
						return
					create_overlay(blood_decal_med_icon_states, add_color, direction)
					src.slippery = min(src.slippery+1, 10)
				if (3)
					if (!list_and_len(blood_decal_high_icon_states))
						return
					create_overlay(blood_decal_high_icon_states, add_color, direction)
					src.slippery = min(src.slippery+2, 10)
				if (4)
					if (!list_and_len(blood_decal_max_icon_states))
						return
					create_overlay(blood_decal_max_icon_states, add_color, direction)
					src.slippery = min(src.slippery+5, 10)
				if (5)
					if (!list_and_len(blood_decal_violent_icon_states))
						return
					create_overlay(blood_decal_violent_icon_states, add_color, direction) // for when you wanna create a BIG MESS
					src.slippery = 10

		src.Dry(rand(vis_amount*80,vis_amount*120))
		var/counter = 0
		for (var/obj/item/I in get_turf(src))
			if (prob(vis_amount*10))
				I.add_mud(src)
			if(counter++>25)break

	create_overlay(var/list/icons_to_choose, var/add_color, var/direction)
		var/mud_addition
		if (islist(icons_to_choose) && length(icons_to_choose))
			mud_addition = pick(icons_to_choose)
		else if (istext(icons_to_choose))
			mud_addition = icons_to_choose
		else
			return
		if (mud_addition)
			var/image/blood_overlay// = image('icons/effects/blood.dmi', mud_addition)
			if (direction)
				blood_overlay = image('icons/effects/blood.dmi', mud_addition, dir = direction)
				blood_overlay.pixel_x += rand(-1,1)
				blood_overlay.pixel_y += rand(-1,1)
			else
				blood_overlay = image('icons/effects/blood.dmi', mud_addition)
				blood_overlay.transform = turn(blood_overlay.transform, pick(0, 180)) // gets funky with 0,90,180,-90
				blood_overlay.pixel_x += rand(-4,4)
				blood_overlay.pixel_y += rand(-4,4)
			if (blood_overlay)
				if (add_color)
					blood_overlay.color = add_color
					src.last_color = add_color

				if (src.overlays.len >= 1) //stop adding more overlays you're lagging client FPS!!!!
					src.UpdateOverlays(blood_overlay, "bloodfinal")
				else
					src.UpdateOverlays(blood_overlay, "blood[src.reagents.total_volume]")

/obj/decal/cleanable/mud/dynamic/tracks
	//name = "bloody footprints"
	desc = "Someone walked through some mud and got it everywhere, jeez!"
	can_track = 0

	add_volume(var/add_color, var/reagent_id = "poo", var/amount = 1, var/vis_amount = 1, var/list/bdata = null, var/i_state = null, var/direction = null, var/e_tracking = 1, var/do_fluid_react = 1)
		// e_tracking will be set to 0 by the track_mud() proc atoms run when moving, so anything that doesn't set it to 0 is a regular sort of bleed and should re-enable tracking
		if (e_tracking)
			src.can_track = 1
		..()


/obj/decal/cleanable/mud/drip
	New()
		..()
		src.pixel_y += rand(0,16)

/obj/decal/cleanable/mud/drip/low
	random_icon_states = list("drip1a", "drip1b", "drip1c", "drip1d", "drip1e", "drip1f")
/obj/decal/cleanable/mud/drip/med
	random_icon_states = list("drip2a", "drip2b", "drip2c", "drip2d", "drip2e", "drip2f")
/obj/decal/cleanable/mud/drip/high
	random_icon_states = list("drip3a", "drip3b", "drip3c", "drip3d", "drip3e", "drip3f")

/obj/decal/cleanable/mud/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/decal/cleanable/mud/splatter/extra
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7", "gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")


/obj/decal/cleanable/mud/tracks
	icon_state = "tracks"
	random_icon_states = null
	color = "#FFFFFF"

/obj/decal/cleanable/mud/hurting1
	icon_state = "hurting1"
	color = "#FFFFFF"
	random_icon_states = null

	hurting2
		icon_state = "hurting2"







#undef DRY_MUD
#undef FRESH_MUD
