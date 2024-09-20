
/* ================================================== */
/* -------------------- Balloons -------------------- */
/* ================================================== */

/obj/item/reagent_containers/balloon
	name = "balloon"
	desc = "Water balloon fights are a classic way to have fun in the summer. I don't know that chlorine trifluoride balloon fights hold the same appeal for most people."
	icon = 'icons/obj/items/balloon.dmi'
	icon_state = "balloon_white"
	inhand_image_icon = 'icons/mob/inhand/hand_balloon.dmi'
	flags = TABLEPASS | OPENCONTAINER
	rc_flags = 0
	initial_volume = 40
	pass_unstable = TRUE
	var/list/available_colors = list("white","black","red","rheart","green","blue","orange","pink","pheart","yellow","purple","bee","clown")
	var/list/rare_colors = list("cluwne","bclown")
	var/balloon_color = "white"
	var/last_reag_total = 0
	var/tied = FALSE
	/// how many breaths should this balloon fill with at a canister
	var/breaths = 5
	var/datum/gas_mixture/air = new

	New()
		..()
		src.air.volume = 14 //source: I made it the fuck up
		if (prob(1) && islist(rare_colors) && length(rare_colors))
			balloon_color = pick(rare_colors)
			UpdateIcon()
		else if (islist(available_colors) && length(available_colors))
			balloon_color = pick(available_colors)
			UpdateIcon()

	on_reagent_change()
		..()
		src.UpdateIcon()
		src.last_reag_total = src.reagents.total_volume
		src.burst_chance()

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		src.reagents.maximum_volume = src.reagents.maximum_volume + passed_genes?.get_effective_value("endurance") // more endurance = larger and more sturdy balloons!
		HYPadd_harvest_reagents(src,origin_plant,passed_genes,quality_status)
		return src

	update_icon()
		if (TOTAL_MOLES(src.air) >= BREATH_VOLUME)
			src.icon_state = "balloon_[src.balloon_color]_inflated"
			src.item_state = src.icon_state
			return
		if (src.reagents)
			if (src.reagents.total_volume)
				src.icon_state = "balloon_[src.balloon_color]_[src.reagents.has_reagent("helium") || src.reagents.has_reagent("hydrogen") ? "inflated" : "full"]"
				src.item_state = src.icon_state
			else
				src.icon_state = "balloon_[src.balloon_color]"
				src.item_state = src.icon_state
			if (((src.reagents.total_volume && src.last_reag_total <= 0) || (!src.reagents.total_volume && src.last_reag_total > 0)) && ismob(src.loc))
				var/mob/M = src.loc
				M.update_inhands()
		else
			src.icon_state = "balloon_[src.balloon_color]"
			src.item_state = src.icon_state

	proc/burst_chance(mob/user as mob, var/ohshit)
		var/curse = pick("Fuck","Shit","Hell","Damn","Darn","Crap","Hellfarts","Pissdamn","Son of a-")
		if (!src.reagents)
			return
		if (!user && usr)
			user = usr
		else if (!user && ismob(src.loc))
			user = src.loc
		if (!ohshit)
			ohshit = (src.reagents.total_volume /  (src.reagents.maximum_volume - 10)) * 33
		if (prob(ohshit))
			src.smash(user)
			if (user)
				user.visible_message(SPAN_ALERT("[src] bursts in [user]'s hands!"), \
				SPAN_ALERT("[src] bursts in your hands! <b>[curse]!</b>"))
				user.update_inhands()
			else
				var/turf/T = get_turf(src)
				if (T)
					T.visible_message(SPAN_ALERT("[src] bursts!"))
			return

	is_open_container()
		return !src.tied

	throw_begin(atom/target, turf/thrown_from, mob/thrown_by)
		. = ..()
		var/curse = pick("Fuck","Shit","Hell","Damn","Darn","Crap","Hellfarts","Pissdamn","Son of a-")
		if (!src.reagents)
			return
		if (!tied)
			if(isliving(thrown_by))
				thrown_by.visible_message(SPAN_ALERT("[src] spills all over [thrown_by]!"), \
				SPAN_ALERT("You forgot to tie off [src] and it spills all over you! <b>[curse]!</b>"))
			src.reagents.reaction(get_turf(src))
			src.reagents.clear_reagents()

	attack_self(var/mob/user as mob)
		if (!ishuman(user))
			boutput(user, SPAN_NOTICE("You don't know what to do with the balloon."))
			return
		var/mob/living/carbon/human/H = user

		var/list/actions = list()
		if (user.mind && user.mind.assigned_role == "Clown")
			actions += "Make balloon animal"
		if (src.reagents.total_volume > 0 || TOTAL_MOLES(src.air) >= BREATH_VOLUME)
			actions += "Inhale"
		if (!src.tied)
			actions += "Tie off"
		if (!actions.len)
			user.show_text("You can't think of anything to do with [src].", "red")
			return

		var/action
		if (length(actions) == 1 && actions[1] == "Inhale")
			action = "Inhale"
		else
			action = input(user, "What do you want to do with the balloon?") as null|anything in actions

		switch (action)
			if ("Make balloon animal")
				if (src.reagents.total_volume > 0)
					user.visible_message("<b>[user]</b> fumbles with [src]!", \
					SPAN_ALERT("You fumble with [src]!"))
					src.burst_chance(user, 100)
				else
					if (user.losebreath)
						boutput(user, SPAN_ALERT("You need to catch your breath first!"))
						return
					var/list/animal_types = list("bee", "dog", "spider", "pie", "owl", "rockworm", "martian", "fermid", "fish")
					if (!animal_types || length(animal_types) <= 0)
						user.show_text("You can't think of anything to make with [src].", "red")
						return
					var/animal = input(user, "What do you want to make?") as null|anything in animal_types
					if (isnull(animal))
						user.show_text("You change your mind.")
						return
					var/fluff = pick("", "quickly ", "expertly ", "clumsily ", "somehow ", "slowly ", "carefully ")
					user.visible_message("<b>[user]</b> blows up [src] and [fluff]twists it into a[animal == "owl" ? "n" : ""] [animal]!", \
					"You blow up [src] and [fluff]twist it into a[animal == "owl" ? "n" : ""] [animal]!")
					var/obj/item/balloon_animal/A = new /obj/item/balloon_animal(get_turf(src.loc))
					A.name = "[animal]-shaped balloon"
					A.desc = "A little [animal], made out of a balloon! How spiffy!"
					A.icon_state = "animal-[animal]"
					switch (src.balloon_color)
						if ("white")
							A.color = "#FFFFFF"
						if ("clown","cluwne","bclown")
							A.color = "#FFEDED"
						if ("black")
							A.color = "#333333"
						if ("red","rheart")
							A.color = "#FF0000"
						if ("green")
							A.color = "#00FF00"
						if ("blue")
							A.color = "#0000FF"
						if ("orange")
							A.color = "#FF6600"
						if ("pink","pheart")
							A.color = "#FF6EBB"
						if ("purple")
							A.color = "#AA00FF"
						if ("yellow")
							A.color = "#FFDD00"
						if ("bee")
							A.color = "#FFDD00"
					H.losebreath ++
					qdel(src)

			if ("Inhale")
				H.visible_message(SPAN_ALERT("<B>[H] inhales the contents of [src]!</B>"),\
				SPAN_ALERT("<b>You inhale the contents of [src]!</b>"))
				logTheThing(LOG_CHEMISTRY, H, "inhales from [src] [log_reagents(src)] at [log_loc(H)].")
				src.reagents.trans_to(H, 40)
				var/datum/lifeprocess/breath/breathing = H.lifeprocesses?[/datum/lifeprocess/breath]
				if (breathing && TOTAL_MOLES(src.air) >= BREATH_VOLUME)
					var/datum/gas_mixture/breath = src.air.remove(BREATH_VOLUME)
					breath.volume = BREATH_VOLUME
					if (breathing.handle_breath(breath))
						//some extra O2 healing on top of the normal breath so this is even somewhat practical
						user.take_oxygen_deprivation(-15)
					src.UpdateIcon()
				return

			if ("Tie off")
				H.visible_message(SPAN_ALERT("<B>[H] ties off [src]!</B>"),\
				SPAN_ALERT("<b>You tie off the opening of [src]!</b>"))
				src.tied = TRUE

	afterattack(obj/target, mob/user)
		if (is_reagent_dispenser(target) || (target.is_open_container() == -1 && target.reagents)) //A dispenser. Transfer FROM it TO us.
			if (!target.reagents.total_volume && target.reagents)
				user.show_text("[target] is empty.", "red")
				return
			if (reagents && reagents.total_volume >= reagents.maximum_volume)
				user.show_text("[src] is full.", "red")
				return
			var/transferamt = src.reagents.maximum_volume - src.reagents.total_volume
			var/trans = target.reagents.trans_to(src, transferamt)
			user.show_text("You fill [src] with [trans] units of the contents of [target].", "blue")
			user.update_inhands()
		else
			return ..()

	ex_act(severity)
		src.smash()

	proc/smash(var/atom/A)
		if (!A)
			A = src.loc
		var/turf/T = get_turf(A)
		if (src.reagents)
			src.reagents.reaction(T)
		if (T)
			T.visible_message(SPAN_ALERT("[src] bursts!"))
		playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, TRUE)
		var/obj/decal/cleanable/balloon/decal = make_cleanable(/obj/decal/cleanable/balloon,T)
		decal.icon_state = "balloon_[src.balloon_color]_pop"

		var/mob/M = src.loc
		if (istype(M))
			M.u_equip(src)
			M.update_inhands()

		qdel(src)

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		..()
		src.smash(T)

	Cross(atom/movable/mover)
		if (istype(mover, /obj/item/implant/projectile/body_visible/dart/bardart))
			return FALSE
		return ..()

/obj/item/balloon_animal
	name = "balloon animal"
	desc = "A little animal, made out of a balloon! How spiffy!"
	icon = 'icons/obj/items/balloon.dmi'
	icon_state = "animal-bee"
	inhand_image_icon = 'icons/mob/inhand/hand_balloon.dmi'
	item_state = "balloon"
	w_class = W_CLASS_SMALL

/obj/item/balloon_animal/random

/obj/item/balloon_animal/random/New()
	..()
	var/animal = pick("bee", "dog", "spider", "pie", "owl", "rockworm", "martian", "fermid", "fish")
	src.name = "[animal]-shaped balloon"
	src.desc = "A little [animal], made out of a balloon! How spiffy!"
	src.icon_state = "animal-[animal]"
	src.color = random_saturated_hex_color()

/obj/item/reagent_containers/balloon/naturally_grown
	desc = "Water balloon fights are a classic way to have fun in the summer. I don't know that chlorine trifluoride balloon fights hold the same appeal for most people. These balloons appear to have been grown naturally."
