
/* ================================================== */
/* -------------------- Balloons -------------------- */
/* ================================================== */

/obj/item/reagent_containers/balloon
	name = "balloon"
	desc = "Water balloon fights are a classic way to have fun in the summer. I don't know that chlorine trifluoride balloon fights hold the same appeal for most people."
	icon = 'icons/obj/items/balloon.dmi'
	icon_state = "balloon_white"
	inhand_image_icon = 'icons/mob/inhand/hand_balloon.dmi'
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	rc_flags = 0
	initial_volume = 40
	var/list/available_colors = list("white","black","red","rheart","green","blue","orange","pink","pheart","yellow","purple","bee","clown")
	var/list/rare_colors = list("cluwne","bclown")
	var/balloon_color = "white"
	var/last_reag_total = 0
	var/tied = FALSE

	New()
		..()
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

	update_icon()
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
		else if (!user && !user && ismob(src.loc))
			user = src.loc
		if (!ohshit)
			ohshit = (src.reagents.total_volume /  (src.reagents.maximum_volume - 10)) * 33
		if (prob(ohshit))
			smash()
			if (user)
				user.visible_message("<span class='alert'>[src] bursts in [user]'s hands!</span>", \
				"<span class='alert'>[src] bursts in your hands! <b>[curse]!</b></span>")
				user.update_inhands()
			else
				var/turf/T = get_turf(src)
				if (T)
					T.visible_message("<span class='alert'>[src] bursts!</span>")
			return
/*		if (src.reagents.total_volume > 30)
			if (prob(50))
				user.visible_message("<span class='alert'>[src] is overfilled and bursts! <b>[curse]</b></span>")
				smash()
				return
*/
	is_open_container()
		return !src.tied

	throw_begin(atom/target, turf/thrown_from, mob/thrown_by)
		. = ..()
		var/curse = pick("Fuck","Shit","Hell","Damn","Darn","Crap","Hellfarts","Pissdamn","Son of a-")
		if (!src.reagents)
			return
		if (!tied)
			if(isliving(thrown_by))
				thrown_by.visible_message("<span class='alert'>[src] spills all over [thrown_by]!</span>", \
				"<span class='alert'>You forgot to tie off [src] and it spills all over you! <b>[curse]!</b></span>")
			src.reagents.reaction(get_turf(src))
			src.reagents.clear_reagents()

	attack_self(var/mob/user as mob)
		if (!ishuman(user))
			boutput(user, "<span class='notice'>You don't know what to do with the balloon.</span>")
			return
		var/mob/living/carbon/human/H = user

		var/list/actions = list()
		if (user.mind && user.mind.assigned_role == "Clown")
			actions += "Make balloon animal"
		if (src.reagents.total_volume > 0 && !src.tied)
			actions += "Inhale"
			actions += "Tie off"
		if (H.urine >= 2 && !src.tied)
			actions += "Pee in it"
		if (!actions.len)
			user.show_text("You can't think of anything to do with [src].", "red")
			return

		var/action = input(user, "What do you want to do with the balloon?") as null|anything in actions

		switch (action)
			if ("Make balloon animal")
				if (src.reagents.total_volume > 0)
					user.visible_message("<b>[user]</b> fumbles with [src]!", \
					"<span class='alert'>You fumble with [src]!</span>")
					src.burst_chance(user, 100)
//					user.update_inhands()
				else
					if (user.losebreath)
						boutput(user, "<span class='alert'>You need to catch your breath first!</span>")
						return
					var/list/animal_types = list("bee", "dog", "spider", "pie", "owl", "rockworm", "martian", "fermid", "fish")
					if (!animal_types || animal_types.len <= 0)
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
					//SPAWN(4 SECONDS)
						//H.losebreath --
					qdel(src)

			if ("Inhale")
				H.visible_message("<span class='alert'><B>[H] inhales the contents of [src]!</B></span>",\
				"<span class='alert'><b>You inhale the contents of [src]!</b></span>")
				src.reagents.trans_to(H, 40)
				return

			if ("Pee in it")
				H.visible_message("<span class='alert'><B>[H] pees in [src]!</B></span>",\
				"<span class='alert'><b>You pee in [src]!</b></span>")
				playsound(H.loc, 'sound/misc/pourdrink.ogg', 50, 1)
				H.urine -= 2
				src.reagents.add_reagent("urine", 8)
				return

			if ("Tie off")
				H.visible_message("<span class='alert'><B>[H] ties off [src]!</B></span>",\
				"<span class='alert'><b>You tie off the opening of [src]!</b></span>")
				src.tied = TRUE

	afterattack(obj/target, mob/user)
		if (istype(target, /obj/reagent_dispensers) || (target.is_open_container() == -1 && target.reagents)) //A dispenser. Transfer FROM it TO us.
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

	proc/smash(var/turf/T)
		if (src.reagents && src.reagents.total_volume < 10)
			return
		if (!T)
			T = src.loc
		if (src.reagents)
			src.reagents.reaction(T)
		if (ismob(T))
			T = get_turf(T)
		if (T)
			T.visible_message("<span class='alert'>[src] bursts!</span>")
		playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
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

/obj/item/balloon_animal
	name = "balloon animal"
	desc = "A little animal, made out of a balloon! How spiffy!"
	icon = 'icons/obj/items/balloon.dmi'
	icon_state = "animal-bee"
	inhand_image_icon = 'icons/mob/inhand/hand_balloon.dmi'
	item_state = "balloon"
	w_class = W_CLASS_SMALL

/obj/item/balloon_animal/random
	New()
		..()
		var/animal = pick("bee", "dog", "spider", "pie", "owl", "rockworm", "martian", "fermid", "fish")
		src.name = "[animal]-shaped balloon"
		src.desc = "A little [animal], made out of a balloon! How spiffy!"
		src.icon_state = "animal-[animal]"
		src.color = random_saturated_hex_color()

/obj/item/reagent_containers/balloon/naturally_grown
	desc = "Water balloon fights are a classic way to have fun in the summer. I don't know that chlorine trifluoride balloon fights hold the same appeal for most people. These balloons appear to have been grown naturally."
