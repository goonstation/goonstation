/obj/item/toy/sponge_capsule
	desc = "Just add water!"
	icon = 'icons/obj/items/sponge_capsule.dmi'
	icon_state = "sponge"
	w_class = W_CLASS_TINY
	throwforce = 1
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	throw_speed = 4
	throw_range = 7
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	rand_pos = 1
	color = "#FF0000"
	var/colors = list("#FF0000", "#0000FF", "#00FF00", "#FFFF00")
	var/obj/critter/animal_to_spawn = null
	var/animals = list(/mob/living/critter/small_animal/cat,
						/obj/critter/bat,
						/obj/critter/domestic_bee,
						/mob/living/critter/small_animal/mouse,
						/obj/critter/opossum,
						/obj/critter/parrot/eclectus,
						/obj/critter/pig,
						/obj/critter/walrus)

/obj/item/toy/sponge_capsule/syndicate
	colors = list("#FF0000", "#7F0000", "#FF6A00", "#FFD800", "#7F3300", "#7F6A00")
	animals = list(/obj/critter/microman,
					/mob/living/critter/bear,
					/mob/living/critter/spider,
					/mob/living/critter/brullbar,
					/obj/critter/bat/buff,
					/mob/living/critter/spider/ice,
					/obj/critter/townguard/passive,
					/mob/living/critter/lion,
					/mob/living/critter/fermid)

/obj/item/toy/sponge_capsule/New()
	..()
	color = pick(colors)
	animal_to_spawn = pick(animals)
	name = "[initial(animal_to_spawn.name)] capsule"


/obj/item/toy/sponge_capsule/get_desc()
	if(animal_to_spawn)
		. += "It contains \an [initial(animal_to_spawn.name)]."
	else
		return

/obj/item/toy/sponge_capsule/attack(mob/M, mob/user)
	if (iscarbon(M) && M == user)
		M.visible_message("<span class='notice'>[M] stuffs [src] into [his_or_her(M)] mouth and and eats it.</span>")
		playsound(M, 'sound/misc/gulp.ogg', 30, 1)
		eat_twitch(M)
		user.u_equip(src)
		qdel(src)
	else
		return

/obj/item/toy/sponge_capsule/proc/add_water()
	var/turf/T = get_turf(src)
	if (!T)
		return
	playsound(src.loc, 'sound/effects/cheridan_pop.ogg', 100, 1)
	if(isnull(animal_to_spawn)) // can probably happen if spawned directly in water
		animal_to_spawn = pick(animals)
	var/atom/C = new animal_to_spawn(T)
	T.visible_message("<span class='notice'>What was once [src] has become [C.name]!</span>")
	qdel(src)

/obj/item/toy/sponge_capsule/EnteredFluid(obj/fluid/F as obj, atom/oldloc)
	if(F.group.reagents && F.group.reagents.reagent_list["water"])
		src.add_water()

/obj/item/toy/sponge_capsule/custom_suicide = TRUE
/obj/item/toy/sponge_capsule/suicide(var/mob/user)
	user.visible_message("<span class='alert'><b>[user] eats [src]!</b></span>")
	var/atom/C = new animal_to_spawn(user.loc)
	C.name = user.real_name
	C.desc = "Holy shit! That used to be [user.real_name]!"
	user.gib()
	return 1

/obj/item/toy/sponge_capsule/afterattack(atom/target, mob/user as mob)
	if(istype(target, /obj/item/spongecaps))
		boutput(user, "<span class='alert'>You awkwardly [pick("cram", "stuff", "jam", "pack")] [src] into [target], but it won't stay!</span>")
		return
	return ..()

/obj/item/spongecaps
	name = "\improper BioToys Sponge Capsules"
	desc = "What was once a toy to be enjoyed by children across the galaxy is now a work of biological engineering brilliance! Patent pending."
	icon = 'icons/obj/items/sponge_capsule.dmi'
	icon_state = "spongecaps"
	w_class = W_CLASS_TINY
	throwforce = 2
	flags = TABLEPASS | FPRINT | SUPPRESSATTACK
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	rand_pos = 1
	var/caps_type = /obj/item/toy/sponge_capsule
	var/caps_amt = 12 //Number of capsules left in the packet.

/obj/item/spongecaps/syndicate
	name = "BioWeapons Sponge Capsules"
	desc = "What was once a work of biological engineering brilliance is now an even more brilliant work of biological engineering brilliance! No patent necessary."
	icon_state = "spongecaps-s"
	caps_type = /obj/item/toy/sponge_capsule/syndicate
	caps_amt = 6

/obj/item/spongecaps/New()
	..()
	UpdateIcon()

/obj/item/spongecaps/get_desc()
	if(caps_amt >= 1)
		. += "<br>There [caps_amt == 1 ? "is" : "are"] [caps_amt] capsule\s left."
	else
		. += "<br>It's empty."

/obj/item/spongecaps/update_icon()
	overlays = null
	if(caps_amt <= 0)
		icon_state = initial(icon_state)
	else
		overlays += "caps[icon_state == "spongecaps" ? "" : "-s"][caps_amt]"

/obj/item/spongecaps/attack_hand(mob/user)
	if(user.find_in_hand(src))
		if(caps_amt == 0)
			boutput(user, "<span class='alert'>There aren't any capsules left, you ignoramus!</span>")
			return
		else
			var/obj/item/toy/sponge_capsule/S = new caps_type(user)
			user.put_in_hand_or_drop(S)
			if(caps_amt != -1)
				caps_amt--
				tooltip_rebuild = 1
		UpdateIcon()
	else
		return ..()
