
/* -------------------- Backpacks  -------------------- */

/obj/item/storage/backpack
	name = "backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "backpack"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "backpack"
	flags = ONBACK | FPRINT | TABLEPASS | NOSPLASH
	w_class = 4.0
	max_wclass = 3
	wear_image_icon = 'icons/mob/back.dmi'
	does_not_open_in_pocket = 0
	spawn_contents = list(/obj/item/storage/box/starter)

	New()
		..()
		BLOCK_LARGE
		AddComponent(/datum/component/itemblock/backpackblock)

/obj/item/storage/backpack/withO2
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/NT
	name = "\improper NT backpack"
	desc = "A stylish blue, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "NTbackpack"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/syndie
	name = "\improper Syndicate backpack"
	desc = "A stylish red, evil, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on an operative's back."
	icon_state = "Syndiebackpack"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/medic
	name = "medic's backpack"
	icon_state = "bp_medic" //im doing inhands, im not getting baited into refactoring every icon state to use hyphens instead of underscores right now
	item_state = "bp-medic"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/satchel
	name = "satchel"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's shoulder."
	icon_state = "satchel"

/obj/item/storage/backpack/satchel/syndie
	name = "\improper Syndicate Satchel"
	desc = "A stylish red, evil, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on an operative's back."
	icon_state = "Syndiesatchel"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/satchel/medic
	name = "medic's satchel"
	icon_state = "satchel_medic"

/obj/item/storage/backpack/satchel/randoseru
	name = "randoseru"
	icon_state = "bp_randoseru"
	item_state = "bp_randoseru"

/obj/item/storage/backpack/satchel/fjallraven
	name = "rucksack"
	icon_state = "bp_fjallraven_red"
	item_state = "bp_fjallraven_red"

	New()
		if (prob(50))
			icon_state = "bp_fjallraven_yellow"
			item_state = "bp_fjallraven_yellow"


/obj/item/storage/backpack/satchel/anello
	name = "travel pack"
	icon_state = "bp_anello"
	item_state = "bp_anello"

/* -------------------- Fanny Packs -------------------- */

/obj/item/storage/fanny
	name = "fanny pack"
	desc = "No, 'fanny' as in 'butt.' Not the other thing."
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "fanny"
	item_state = "fanny"
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	w_class = 4.0
	max_wclass = 3
	does_not_open_in_pocket = 0
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5
	spawn_contents = list(/obj/item/storage/box/starter)

	New()
		..()
		BLOCK_ROPE

/obj/item/storage/fanny/funny
	name = "funny pack"
	desc = "Haha, get it? Get it? 'Funny'!"
	icon_state = "funny"
	item_state = "funny"
	spawn_contents = list(/obj/item/storage/box/starter,\
	/obj/item/storage/box/balloonbox)

/obj/item/storage/fanny/syndie
	name = "syndicate tactical espionage belt pack"
	desc = "It's different than a fanny pack. It's tactical and action-packed!"
	icon_state = "syndie"
	item_state = "syndie"

/* -------------------- Belts -------------------- */

/obj/item/storage/belt
	name = "belt"
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "belt"
	item_state = "belt"
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	max_wclass = 2
	does_not_open_in_pocket = 0
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5

	New()
		..()
		BLOCK_ROPE

	proc/can_use()
		.= 1
		if (!ismob(loc))
			return 0

	MouseDrop(obj/over_object as obj, src_location, over_location)
		var/mob/M = usr
		if (!istype(over_object, /obj/screen))
			if(!can_use())
				boutput(M, "<span class='alert'>I need to wear [src] for that.</span>")
				return
		return ..()

	attack_hand(mob/user as mob)
		if (src.loc == user && !can_use())
			boutput(user, "<span class='alert'>I need to wear [src] for that.</span>")
			return
		return ..()

	attackby(obj/item/W as obj, mob/user as mob)
		if(!can_use())
			boutput(user, "<span class='alert'>I need to wear [src] for that.</span>")
			return
		if (istype(W, /obj/item/storage/toolbox) || istype(W, /obj/item/storage/box) || istype(W, /obj/item/storage/belt))
			var/obj/item/storage/S = W
			for (var/obj/item/I in S.get_contents())
				if (..(I, user, null, S) == 0)
					break
			return
		else
			return ..()

/obj/item/storage/belt/utility
	name = "utility belt"
	desc = "Can hold various small objects."
	icon_state = "utilitybelt"
	item_state = "utility"

/obj/item/storage/belt/utility/ceshielded
	name = "aurora MKII utility belt"
	desc = "An utility belt for usage in high-risk salvage operations. Contains a personal shield generator. Can be activated to overcharge the shields temporarily."
	icon_state = "cebelt"
	item_state = "utility"
	rarity = 4
	abilities = list(/obj/ability_button/cebelt_toggle)
	var/active = 0
	var/charge = 8
	var/maxCharge = 8
	var/obj/decal/ceshield/overlay
	var/lastTick = 0
	var/chargeTime = 50 //world.time Ticks per charge increase. 50 works out to be roughly 45 seconds from 0 -> 10 under normal conditions.
	can_hold = list(/obj/item/rcd,
	/obj/item/rcd_ammo)
	in_list_or_max = 1

	New()
		..()
		processing_items.Add(src)

	proc/toggle()
		if(active)
			deactivate()
		else
			activate()
		return

	proc/activate()
		if (!(src in processing_items))
			processing_items.Add(src)

		if(charge > 0)
			charge -= 1

			active = 1
			setProperty("block", 80)
			setProperty("rangedprot", 1.5)
			setProperty("coldprot", 100)
			setProperty("heatprot", 100)

			if(ishuman(src.loc))
				var/mob/living/carbon/human/H = src.loc
				overlay = new(get_turf(src))

				if(H.attached_objs == null)
					H.attached_objs = list()

				H.attached_objs.Add(overlay)


			playsound(src.loc, "sound/machines/shieldup.ogg", 60, 1)
		return

	dropped(mob/user as mob)
		if(active)
			deactivate()
		..()

	proc/deactivate()
		lastTick = (world.time + 20) //Tacking on a little delay before charging starts. Discourage toggling it too often.
		active = 0
		setProperty("block", 25)
		delProperty("rangedprot")
		delProperty("coldprot")
		delProperty("heatprot")

		if(overlay)
			qdel(overlay)
			overlay = null

		playsound(src.loc, "sound/machines/shielddown.ogg", 60, 1)
		return

	process()
		if(active)
			if(--charge <= 0)
				deactivate()
		else
			var/multiplier = 0
			var/remainder = 0

			if(world.time >= (lastTick + chargeTime))
				var/diff = round(world.time - lastTick)
				remainder = (diff % chargeTime)
				multiplier = round((diff - remainder) / chargeTime) //Round shouldnt be needed but eh.

			if(multiplier)
				charge = min(charge+(1*multiplier), maxCharge)
				lastTick = (world.time - remainder) //Plop in the remainder so we don't just swallow ticks.
		return

	setupProperties()
		..()
		setProperty("block", 25)

	equipped(var/mob/user, var/slot)
		return ..()

	unequipped(var/mob/user)
		if(active)
			deactivate()
		return ..()

	examine()
		. = ..()
		. += "There are [src.charge]/[src.maxCharge] PU left."

	buildTooltipContent()
		var/content = ..()
		content += "<br>There are [src.charge]/[src.maxCharge] PU left."
		return content

/obj/item/storage/belt/utility/prepared
	spawn_contents = list(/obj/item/crowbar,
	/obj/item/weldingtool,
	/obj/item/wirecutters,
	/obj/item/screwdriver,
	/obj/item/wrench,
	/obj/item/device/multitool,
	/obj/item/cable_coil)

/obj/item/storage/belt/medical
	name = "medical belt"
	icon_state = "injectorbelt"
	item_state = "injector"
	can_hold = list(
		/obj/item/robodefibrillator
	)
	in_list_or_max = 1

/obj/item/storage/belt/mining
	name = "miner's belt"
	desc = "Can hold various mining tools."
	icon_state = "minerbelt"
	item_state = "utility"
	can_hold = list(
		/obj/item/mining_tool,
		/obj/item/mining_tools
	)
	in_list_or_max = 1

/obj/item/storage/belt/hunter
	name = "trophy belt"
	desc = "Holds normal-sized items, such as skulls."
	icon_state = "minerbelt"
	item_state = "utility"
	max_wclass = 3

/obj/item/storage/belt/security
	name = "security toolbelt"
	desc = "For the trend-setting officer on the go. Has a place on it to clip a baton and a holster for a small gun."
	icon_state = "secbelt"
	item_state = "secbelt"
	can_hold = list(/obj/item/baton, // not included in this list are guns that are already small enough to fit (like the detective's gun)
	/obj/item/gun/energy/taser_gun,
	/obj/item/gun/energy/phaser_gun,
	/obj/item/gun/energy/laser_gun,
	/obj/item/gun/energy/egun,
	/obj/item/gun/energy/lawbringer,
	/obj/item/gun/energy/lawbringer/old,
	/obj/item/gun/energy/wavegun,
	/obj/item/gun/kinetic/revolver,
	/obj/item/gun/kinetic/zipgun)
	in_list_or_max = 1

// kiki's detective shoulder (holster)
// get it? like kiki's delivery service? ah, i'll show myself out.

	shoulder_holster
		name = "shoulder holster"
		icon_state = "shoulder_holster"
		item_state = "shoulder_holster"

		inspector
			icon_state = "inspector_holster"
			item_state = "inspector_holster"

//////////////////////////////
// ~Nuke Ops Class Storage~ //
//////////////////////////////

// belt for storing clips + magazines only

/obj/item/storage/belt/ammo
	name = "ammunition belt"
	desc = "A rugged belt fitted with ammo pouches."
	icon_state = "minerbelt"
	item_state = "utility"
	can_hold = list(/obj/item/ammo/bullets)
	in_list_or_max = 0

// fancy shoulder sling for grenades

/obj/item/storage/backpack/grenade_bandolier
	name = "grenade bandolier"
	desc = "A sturdy shoulder-sling for storing various grenades."
	icon_state = "grenade_bandolier"
	item_state = "grenade_bandolier"
	can_hold = list(/obj/item/old_grenade,
	/obj/item/chem_grenade,
	/obj/item/storage/grenade_pouch,
	/obj/item/ammo/bullets/grenade_round)
	in_list_or_max = 0

// combat medic storage 7 slot

/obj/item/storage/belt/syndicate_medic_belt
	name = "medical lifesaver bag"
	icon = 'icons/obj/items/belts.dmi'
	desc = "A canvas duffel bag full of medicines."
	icon_state = "medic_belt"
	item_state = "medic_belt"
	spawn_contents = list(/obj/item/reagent_containers/emergency_injector/high_capacity/epinephrine,
	/obj/item/reagent_containers/emergency_injector/high_capacity/salbutamol,
	/obj/item/reagent_containers/emergency_injector/high_capacity/salicylic_acid,
	/obj/item/reagent_containers/emergency_injector/high_capacity/saline,
	/obj/item/reagent_containers/emergency_injector/high_capacity/atropine,
	/obj/item/reagent_containers/emergency_injector/high_capacity/pentetic,
	/obj/item/reagent_containers/emergency_injector/high_capacity/mannitol)

/obj/item/storage/backpack/satchel/syndie/syndicate_medic_satchel
	name = "medical shoulder pack"
	desc = "A satchel containing larger medical supplies and instruments."
	icon_state = "Syndiesatchel"
	item_state = "backpack"
	spawn_contents = list(/obj/item/robodefibrillator,
	/obj/item/extinguisher,
	/obj/item/reagent_containers/iv_drip/blood,
	/obj/item/reagent_containers/mender/brute,
	/obj/item/reagent_containers/mender/burn,
	/obj/item/reagent_containers/hypospray)


/* -------------------- Wrestling Belt -------------------- */

/obj/item/storage/belt/wrestling
	name = "championship wrestling belt"
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past."
	icon_state = "machobelt"
	item_state = "machobelt"
	contraband = 8
	is_syndicate = 1
	mats = 18 //SPACE IS THE PLACE FOR WRESTLESTATION 13
	var/fake = 0		//So the moves are all fake.

	equipped(var/mob/user)
		..()
		user.make_wrestler(0, 1, 0, fake)

	unequipped(var/mob/user)
		..()
		user.make_wrestler(0, 1, 1, fake)

/obj/item/storage/belt/wrestling/fake
	name = "fake wrestling belt"
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past."
	contraband = 0
	is_syndicate = 0
	fake = 1

// I dunno where else to put these vOv
/obj/item/inner_tube
	name = "inner tube"
	desc = "An inflatable torus for your waist!"
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "pool_ring"
	item_state = "pool_ring"
	flags = FPRINT | TABLEPASS | ONBELT
	w_class = 3.0
	mats = 5 // I dunno???

	New()
		..()
		setProperty("negate_fluid_speed_penalty", 0.2)

/obj/item/inner_tube/duck
	icon_state = "pool_ring-duck"
	item_state = "pool_ring-duck"

/obj/item/inner_tube/giraffe
	icon_state = "pool_ring-giraffe"
	item_state = "pool_ring-giraffe"

/obj/item/inner_tube/flamingo
	icon_state = "pool_ring-flamingo"
	item_state = "pool_ring-flamingo"

/obj/item/inner_tube/random
	New()
		..()
		if (prob(40))
			src.icon_state = "pool_ring-[pick("duck","giraffe","flamingo")]"
			src.item_state = src.icon_state
