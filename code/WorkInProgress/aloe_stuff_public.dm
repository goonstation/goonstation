/obj/item/clothing/suit/bio_suit/paramedic/armored/prenerf
	name = "pre-nerf armored paramedic suit"
	desc = "<i style='color:pink'>My beloved...</i>"

	setupProperties()
		..()
		setProperty("rangedprot", 1.5)

/obj/critter/domestic_bee/aloe_bee
	name = "weird bee"
	desc = "Thrives in wet climates."
	icon_state = "aloebee-wings"
	sleeping_icon_state = "aloebee-sleep"
	icon_body = "aloebee"
	honey_color = "#0F0F0F"
	is_pet = 1
	generic = FALSE

	do_reagentStuff(mob/M)
		if (M.reagents.get_reagent_amount("histamine") < 30)
			M.reagents.add_reagent("histamine", 10)
		M.reagents.add_reagent(pick(all_functional_reagent_ids), rand(1, 10))

/mob/living/critter/small_animal/bee/aloe_bee
	name = "weird bee"
	desc = "Thrives in wet climates."
	icon_state = "aloebee-wings"
	icon_body = "aloebee"
	icon_state_dead = "aloebee-dead"
	icon_state_sleep = "aloebee-sleep"
	honey_color = "#0F0F0F"
	add_abilities = list(/datum/targetable/critter/bite/bee,
		/datum/targetable/critter/bee_sting/random)

/datum/targetable/critter/bee_sting/random

	cast(atom/target)
		if (..())
			return TRUE
		src.venom2 = pick(all_functional_reagent_ids)
		src.amt2 = rand(1, 10)

/mob/living/critter/small_animal/cat/brixley
	name = "Brixley"
	desc = "Very fuzzy, likes to roll over."
	death_text = "%src% rolls over!"
	icon_state = "catbrix"
	butcherable = FALSE
	health = 30
	randomize_name = 0
	randomize_look = 0
	health_brute = 30
	health_burn = 30

/obj/item/clothing/mask/gas/swat/blue
	name = "SWAT Mask?"
	color = list(0.157562,0.163186,0.844535,0.390637,0.414067,-0.58031,-0.0243897,-0.0534431,0.259584)
	desc = "Looks kinda familiar."

/obj/item/clothing/mask/gas/swat/rainbow
	name = "SWAG Mask"
	color_r = 1
	color_g = 1
	color_b = 1

	New()
		..()
		animate_rainbow_glow(src)

	equipped(mob/user, slot)
		. = ..()
		animate_rainbow_glow(user.client)

	unequipped(mob/user)
		. = ..()
		animate(user.client, color=null)

/obj/machinery/recharge_station/cat

	New()
		..()
		src.occupant = new /mob/living/critter/small_animal/cat/brixley(src)
		src.build_icon()
/obj/item/storage/desk_drawer/aloe
	spawn_contents = list(/obj/item/reagent_containers/patch/LSD,
						  /obj/item/reagent_containers/patch/lsd_bee,
						  /obj/item/cloth/handkerchief/nt,
						  /obj/item/aiModule/hologram_expansion/elden
	)

/obj/table/wood/auto/desk/aloe
	New()
		..()
		var/obj/item/storage/desk_drawer/aloe/drawer = new(src)
		src.desk_drawer = drawer

/area/centcom/offices/aloe
	name = "\proper office of aloe"
	ckey = "asche"

/// Button 4 bill office
/obj/machinery/shipalert/bill
	name = "\improper Emergency Plot Generation Button"
	desc = "<b style='color:red'>IN CASE OF BOREDOM<br>BREAK GLASS</b>"
	var/list/eventbank

	New()
		..()
		src.eventbank = childrentypesof(/datum/random_event) // yes, this includes broken or unused events. the plot stops for nothing

	toggleActivate(mob/user)
		if (src.working)
			boutput(user, "<span class='alert'><b>There's already enough plot! Don't overcomplicate the story!</b></span>")
		src.working = TRUE
		var/num_events = rand(1, 5)
		if (current_state < GAME_STATE_FINISHED && !isadmin(user))
			num_events = 1
			boutput(user, "<span class='alert'><b>You just don't have the creativity for all this plot. You add a little, though.</b></span>")
		for (var/i in 1 to num_events)
			var/event_type = pick(eventbank)
			var/datum/random_event/picked_event = new event_type
			picked_event.event_effect("that stupid fucking button in Bill's office. [user] ([user.key]) pressed it.")


/// Stamina monitor for target dummies.
/obj/machinery/maptext_monitor/stamina
	maptext_prefix = "<span class='c pixel sh' style='color: #FBE801; font-size: 14px'>"
	require_var_or_list = FALSE
	update_delay = 2 // very fast but this is for testing so w/e
	maptext_y = -8
	var/mob/living/mob_loc

	New()
		. = ..()
		if (!istype(src.loc, /mob/living))
			qdel(src) //bye!
			return
		src.mob_loc = src.loc
		src.monitored = src.mob_loc
		src.mob_loc.vis_contents += src

	validate_monitored()
		. = ..()
		var/mob/living/M = src.loc
		if (!istype(M) || !M.use_stamina) // uh oh
			qdel(src)
			return FALSE

	get_value() // this should return a number but I am being malicious
		return "[src.mob_loc.stamina] / [src.mob_loc.stamina_max]"

	disposing()
		src.mob_loc = null
		. = ..()




