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

/obj/critter/cat/brixley
	name = "Brixley"
	desc = "Very fuzzy, likes to roll over."
	death_text = "%src% rolls over!"
	icon_state = "catbrix"
	cattype = "brix"
	health = 30
	randomize_cat = 0
	generic = FALSE
	butcherable = FALSE
	is_pet = 1

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
		src.occupant = new /obj/critter/cat/brixley(src)
		src.build_icon()
/obj/item/storage/desk_drawer/aloe
	spawn_contents = list(/obj/item/reagent_containers/patch/LSD,
						  /obj/item/reagent_containers/patch/lsd_bee,
						  /obj/item/cloth/handkerchief/nt
	)

/obj/table/wood/auto/desk/aloe
	New()
		..()
		var/obj/item/storage/desk_drawer/aloe/drawer = new(src)
		src.desk_drawer = drawer

/area/centcom/offices/aloe
	name = "\proper office of aloe"
	ckey = "asche"
