/datum/loot_crate_manager
	/// three types of loot - aesthetic motivated, department motivated, and player motivated
	var/list/aesthetic = list(
	// character
		/obj/item/clothing/head/bear = 20,\
		list(/obj/item/clothing/head/rugged, /obj/item/clothing/suit/rugged_jacket) = 10,\
		list(/obj/item/clothing/head/star_tophat, /obj/item/clothing/suit/star_cloak) = 10,\
		list(/obj/item/clothing/head/cow, /obj/item/clothing/suit/cow_jacket) = 10,\
		/obj/item/clothing/head/torch = 20,\
		list(/obj/item/clothing/head/helmet/space/replica, /obj/item/clothing/suit/space/replica) = 10,\
		/obj/item/clothing/suit/lined_jacket = 20,\
		/obj/item/clothing/suit/warm_jacket = 20,\
		/obj/item/clothing/suit/cool_jacket = 20,\
		/obj/item/clothing/suit/billow_cape = 10,\
		/obj/item/clothing/under/misc/tiedye = 20,\
		/obj/item/clothing/under/misc/neapolitan = 20,\
		/obj/item/clothing/under/misc/mint_chip = 20,\
		/obj/item/clothing/under/misc/mimefancy = 10,\
		/obj/item/clothing/under/misc/mimedress = 10,\
		/obj/item/clothing/suit/torncloak/random = 20,\
		/obj/item/clothing/suit/scarfcape/random = 20,\
		/obj/item/clothing/suit/fakebeewings = 10,\
		/obj/item/clothing/head/giraffehat = 10, \
		/obj/item/clothing/head/axehat = 20, \
		/obj/item/clothing/head/mushroomcap/inky = 10, \
		/obj/item/clothing/head/rhinobeetle = 20, \
		/obj/item/clothing/head/stagbeetle = 20, \
	)
	// station
	var/list/department = list(
	// medbay
		/obj/item/roboupgrade/efficiency = 20,\
		/obj/item/roboupgrade/jetpack = 20,\
		/obj/item/roboupgrade/physshield = 10,\
		/obj/item/roboupgrade/teleport = 10,\
		/obj/item/cloner_upgrade = 10,\
		/obj/item/grinder_upgrade = 20,\
		/obj/item/reagent_containers/mender/both = 10,\
		/obj/item/plant/herb/cannabis/white/spawnable = 20,\
		list(/obj/item/parts/robot_parts/leg/right/thruster, /obj/item/parts/robot_parts/leg/left/thruster) = 10,
	// botany
		/obj/item/reagent_containers/glass/happyplant = 20,\
	// ranch
		/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/purple = 20,\
		/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/dream = 10,\
		/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/plant = 20,\
		/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/ixworth = 30,\
		/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/wizard = 20,\
		/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/knight = 20,\
	// mining
		/obj/item/clothing/shoes/industrial = 10,\
	// qm
		/obj/item/stamped_bullion = 20,\
		/obj/item/plant/herb/cannabis/omega/spawnable = 20,\
		list(/obj/item/antitamper, /obj/item/antitamper, /obj/item/antitamper) = 20,
	)
	var/list/player = list(
	// useful
		/obj/item/clothing/gloves/psylink_bracelet = 10,\
		/obj/item/device/voltron = 5,\
		/obj/item/injector_belt = 20,\
		/obj/item/clothing/mask/injector_mask = 10,\
		/obj/item/ammo/power_cell/self_charging/pod_wars_standard = 20,\
		/obj/item/clothing/gloves/ring/titanium = 20,\
		/obj/item/gun/energy/phaser_gun = 20,\
		/obj/item/gun/energy/phaser_small = 20,\
		/obj/item/gun/energy/phaser_huge = 10,\
		/obj/item/clothing/ears/earmuffs/yeti = 20,\
		/obj/item/clothing/lanyard = 20,\
		/obj/item/kitchen/utensil/knife/tracker = 10,\
		/obj/item/disk/data/floppy/manudrive/pocketoxyex/singleuse = 25,\
		/obj/item/disk/data/floppy/manudrive/pocketoxyex/threeuse = 5,
	// fun
		/obj/item/gun/bling_blaster = 20,\
		/obj/item/clothing/under/gimmick/frog = 20,\
		/obj/vehicle/skateboard = 20,\
		/obj/item/device/flyswatter = 20,\
		/mob/living/critter/bear = 20,\
		/obj/item/clothing/shoes/jetpack = 20,\
		/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/nicespider = 20, \
		/obj/item/gun/kinetic/foamdartshotgun = 20, \
		/obj/item/device/speech_pro = 20, \
		/obj/item/shipcomponent/secondary_system/trailblazer = 20
	)

var/global/datum/loot_crate_manager/loot_crate_manager = new /datum/loot_crate_manager

/obj/storage/crate/loot
	name = "crate"
	desc = "A crate of unknown contents, probably accidentally lost from some bygone freighter shipment or the like."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
	locked = TRUE
	anchored = ANCHORED
	var/image/light = null

	New()
		..()
		src.light = image('icons/obj/large_storage.dmi',"lootcratelocklight")
		new /obj/item/antitamper(
			src,
			TRUE, // Attach it to crate being spawned
		)

		var/list/loot = list()
		loot.Add(weighted_pick(loot_crate_manager.aesthetic), weighted_pick(loot_crate_manager.department), weighted_pick(loot_crate_manager.player))

		for (var/l in loot)
			if (islist(l))
				for (var/l2 in l)
					new l2(src)
			else
				new l(src)

		switch (rand(1, 4))
			if (1)
				icon_state = "lootsci"
				icon_opened = "lootsciopen"
				icon_closed = "lootsci"
			if (2)
				icon_state = "lootind"
				icon_opened = "lootindopen"
				icon_closed = "lootind"
			if (3)
				icon_state = "lootmil"
				icon_opened = "lootmilopen"
				icon_closed = "lootmil"
			if (4)
				icon_state = "lootcrime"
				icon_opened = "lootcrimeopen"
				icon_closed = "lootcrime"

	update_icon()
		..()
		if (src.locked)
			light.color = "#FF0000"
		else
			light.color = "#00FF00"
		src.UpdateOverlays(src.light, "light")

// Items specific to loot crates

/obj/item/antitamper
	name = "anti-tamper device"
	desc = "Space pirates hate these!"
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "antitamper-off"
	w_class = W_CLASS_SMALL
	force = 4
	throwforce = 2
	var/obj/storage/crate/attached = null

	New(var/obj/storage/crate/C, var/attach_to_crate = FALSE)
		..()
		if (attach_to_crate)
			attach_to(C)

	disposing()
		. = ..()
		attached = null

	attack_hand(mob/user)
		if (attached)
			return
		..()

	attackby(obj/item/W, mob/user)
		if (!attached)
			return ..()
		if (W.w_class < W_CLASS_NORMAL || W.force < 10)
			boutput(user, SPAN_ALERT("You're going to have to use a heftier object if you want to break the crate's anti-tampering system."))
			return
		add_fingerprint(user)
		detach_from()

	proc/attach_to(var/obj/storage/crate/C, var/mob/user)
		if (!C || !istype(C))
			return
		if (user != null)
			user.u_equip(src)
		set_loc(C)
		attached = C
		attached.vis_contents += src
		attached.locked = TRUE
		attached.anchored = ANCHORED
		attached.UpdateIcon()
		icon_state = "antitamper-on"
		playsound(src, 'sound/impact_sounds/Wood_Snap.ogg', 40, TRUE)

	proc/detach_from()
		if (!attached)
			return
		icon_state = ""
		FLICK("antitamper-break", src)
		var/obj/storage/crate/C = attached
		attached = null
		SPAWN(1 SECOND)
			C.vis_contents -= src
			C.locked = FALSE
			C.anchored = UNANCHORED
			C.UpdateIcon()
			qdel(src)
		playsound(src, 'sound/impact_sounds/plate_break.ogg', 30, TRUE)

/obj/item/clothing/gloves/psylink_bracelet
	name = "jewelled bracelet"
	desc = "Some pretty jewellery."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bracelet"
	item_state = "blank"
	material_prints = "patterned scratches"
	w_class = W_CLASS_TINY
	var/primary = TRUE
	var/image/gemstone = null
	var/obj/item/clothing/gloves/psylink_bracelet/twin
	which_hands = null

	setupProperties()
		..()
		setProperty("conductivity", 1)

	New()
		..()
		if(!primary)
			return
		src.gemstone = image('icons/obj/items/items.dmi',"bracelet-gem")
		var/obj/item/clothing/gloves/psylink_bracelet/two = new /obj/item/clothing/gloves/psylink_bracelet/secondary(src.loc)
		two.gemstone = image('icons/obj/items/items.dmi',"bracelet-gem")
		src.twin = two
		two.twin = src
		var/picker = rand(1,3)
		switch(picker)
			if(2)
				src.gemstone.color = "#00FF00"
				two.gemstone.color = "#FF00FF"
			if(3)
				src.gemstone.color = "#FFFF00"
				two.gemstone.color = "#00FFFF"
			else
				src.gemstone.color = "#FF0000"
				two.gemstone.color = "#0000FF"

		src.overlays += src.gemstone
		two.overlays += two.gemstone

	equipped(var/mob/user, var/slot)
		..()
		if (!user)
			return
		if (src.twin && ishuman(src.twin.loc))
			var/mob/living/carbon/human/psy = src.twin.loc
			if (psy.bioHolder && psy.bioHolder.HasEffect("psy_resist"))
				return
			if (psy.gloves == src.twin)
				boutput(user, SPAN_ALERT("You suddenly begin hearing and seeing things. What the hell?"))
				boutput(psy, SPAN_ALERT("You suddenly begin hearing and seeing things. What the hell?"))

	unequipped(var/mob/user)
		..()
		if (!user)
			return
		if (src.twin && ishuman(src.twin.loc))
			var/mob/living/carbon/human/psy = src.twin.loc
			if (psy.bioHolder && psy.bioHolder.HasEffect("psy_resist"))
				return
			if (psy.gloves == src.twin)
				boutput(user, SPAN_NOTICE("The strange hallcuinations suddenly stop. That was weird."))
				boutput(psy, SPAN_NOTICE("The strange hallcuinations suddenly stop. That was weird."))

/obj/item/clothing/gloves/psylink_bracelet/secondary
	primary = FALSE

/mob/proc/get_psychic_link()
	return null

/mob/living/carbon/human/get_psychic_link()
	if (!src)
		return null

	if (istype(src.gloves,/obj/item/clothing/gloves/psylink_bracelet/))
		var/obj/item/clothing/gloves/psylink_bracelet/PB = src.gloves
		if (PB.twin && ishuman(PB.twin.loc))
			var/mob/living/carbon/human/psy = PB.twin.loc
			if (psy.bioHolder && psy.bioHolder.HasEffect("psy_resist"))
				return null
			if (psy.gloves == PB.twin)
				return psy

	return null

// Letters, documents, etc

/obj/item/paper/loot_crate_letters
	name = "letter"
	desc = "Some old fashioned paper correspondence."
	var/text_file = null
	var/list/pick_from_these_files = list()

	New()
		if (text_file)
			info = file2text(text_file)
		else
			if (pick_from_these_files.len)
				info = file2text(pick(pick_from_these_files))
		..()

/obj/item/paper/loot_crate_letters/generic_science
	name = "scientific document"
	desc = "You recognise a prominent research company's logo on the letterhead."
	pick_from_these_files = list("strings/fluff/cat_planet.txt","strings/fluff/giant_ruby.txt")

/obj/item/paper/loot_crate_letters/generic_crime
	name = "sketchy memo"
	desc = "There's just something really shady about this correspondence."
	pick_from_these_files = list("strings/fluff/fuck_you_pianzi.txt")
