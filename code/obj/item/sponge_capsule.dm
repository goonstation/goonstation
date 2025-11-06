/obj/item/toy/sponge_capsule
	desc = "Just add water!"
	icon = 'icons/obj/items/sponge_capsule.dmi'
	icon_state = "sponge"
	w_class = W_CLASS_TINY
	throwforce = 1
	flags = TABLEPASS | SUPPRESSATTACK
	throw_speed = 4
	throw_range = 7
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	rand_pos = 1
	color = "#FF0000"
	edible = TRUE
	eat_sound = 'sound/misc/gulp.ogg'
	var/colors = list("#FF0000", "#0000FF", "#00FF00", "#FFFF00")
	var/obj/critter/animal_to_spawn = null
	var/animals = list(/mob/living/critter/small_animal/cat,
						/obj/critter/bat,
						/obj/critter/domestic_bee,
						/mob/living/critter/small_animal/mouse,
						/mob/living/critter/small_animal/opossum,
						/obj/critter/parrot/eclectus,
						/mob/living/critter/small_animal/pig,
						/mob/living/critter/small_animal/walrus)

/obj/item/toy/sponge_capsule/syndicate
	colors = list("#FF0000", "#7F0000", "#FF6A00", "#FFD800", "#7F3300", "#7F6A00")
	animals = list(/mob/living/critter/microman,
					/mob/living/critter/bear,
					/mob/living/critter/spider,
					/mob/living/critter/brullbar,
					/obj/critter/bat/buff,
					/mob/living/critter/spider/ice,
					/mob/living/critter/townguard,
					/mob/living/critter/lion,
					/mob/living/critter/fermid)

	add_water()
		if (ismob(src.loc))
			var/mob/M = src.loc
			M.setStatus("unconscious", 10 SECONDS)
			M.TakeDamage("all", 60)
			take_bleeding_damage(M, M, 50, DAMAGE_CUT)
			SPAWN(1)
				boutput(M, SPAN_ALERT("Something horrible forces its way out of your stomach! HOLY SHIT!!!"))
		. = ..()


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

/obj/item/toy/sponge_capsule/eat_msg(mob/M)
	M.visible_message(SPAN_NOTICE("[M] stuffs [src] into [his_or_her(M)] mouth and and eats it."))

/obj/item/toy/sponge_capsule/proc/add_water()
	var/turf/T = get_turf(src)
	if (!T)
		return
	if (ismob(src.loc))
		var/mob/idiot = src.loc
		idiot.emote("scream")
		if (ishuman(idiot))
			var/mob/living/carbon/human/human_idiot = idiot
			if (src in human_idiot.organHolder?.stomach?.stomach_contents)
				boutput(human_idiot, SPAN_ALERT("You feel your stomach suddenly bloat horribly!"))
				human_idiot.organHolder.stomach.eject(src)
				human_idiot.organHolder.stomach.take_damage(30)
				human_idiot.TakeDamage("all", 10)
				human_idiot.changeStatus("knockdown", 3 SECONDS)
				hit_twitch(human_idiot)
	playsound(src.loc, 'sound/effects/cheridan_pop.ogg', 100, 1)
	if(isnull(animal_to_spawn)) // can probably happen if spawned directly in water
		animal_to_spawn = pick(animals)
	var/atom/C = new animal_to_spawn(T)
	if (ismobcritter(C))
		var/mob/living/critter/M = C
		LAZYLISTADDUNIQUE(M.faction, FACTION_SPONGE)
	T.visible_message(SPAN_NOTICE("What was once [src] has become [C.name]!"))
	qdel(src)

/obj/item/toy/sponge_capsule/EnteredFluid(obj/fluid/F as obj, atom/oldloc)
	if(F.group.reagents && F.group.reagents.reagent_list["water"])
		src.add_water()

/obj/item/toy/sponge_capsule/custom_suicide = TRUE
/obj/item/toy/sponge_capsule/suicide(var/mob/user)
	user.visible_message(SPAN_ALERT("<b>[user] eats [src]!</b>"))
	var/atom/C = new animal_to_spawn(user.loc)
	C.name = user.real_name
	C.desc = "Holy shit! That used to be [user.real_name]!"
	user.gib()
	return 1

/obj/item/toy/sponge_capsule/afterattack(atom/target, mob/user as mob)
	if(istype(target, /obj/item/spongecaps))
		boutput(user, SPAN_ALERT("You awkwardly [pick("cram", "stuff", "jam", "pack")] [src] into [target], but it won't stay!"))
		return
	return ..()

/obj/item/spongecaps
	name = "\improper BioToys Sponge Capsules"
	desc = "What was once a toy to be enjoyed by children across the galaxy is now a work of biological engineering brilliance! Patent pending."
	icon = 'icons/obj/items/sponge_capsule.dmi'
	icon_state = "spongecaps"
	w_class = W_CLASS_TINY
	throwforce = 2
	flags = TABLEPASS | SUPPRESSATTACK
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
			boutput(user, SPAN_ALERT("There aren't any capsules left, you ignoramus!"))
			return
		else
			var/obj/item/toy/sponge_capsule/S = new caps_type(user)
			user.put_in_hand_or_drop(S)
			if(caps_amt != -1)
				caps_amt--
				tooltip_rebuild = TRUE
		UpdateIcon()
	else
		return ..()
