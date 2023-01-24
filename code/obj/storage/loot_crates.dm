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
		/obj/item/clothing/suit/fakebeewings = 10,
	// station
	)
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
		/obj/item/clothing/mask/gas/injector_mask = 10,\
		/obj/item/ammo/power_cell/self_charging/pod_wars_standard = 20,\
		/obj/item/clothing/gloves/ring/titanium = 20,\
		/obj/item/gun/energy/phaser_gun = 20,\
		/obj/item/gun/energy/phaser_small = 20,\
		/obj/item/gun/energy/phaser_huge = 10,\
		/obj/item/clothing/ears/earmuffs/yeti = 20,\
	// fun
		/obj/item/gun/bling_blaster = 20,\
		/obj/item/clothing/under/gimmick/frog = 20,\
		/obj/vehicle/skateboard = 20,\
		/obj/item/device/flyswatter = 20,\
		/obj/critter/bear = 20,\
		/obj/item/clothing/shoes/jetpack = 20,\
		/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/nicespider = 20,
	)

var/global/datum/loot_crate_manager/loot_crate_manager = new /datum/loot_crate_manager

/obj/storage/crate/loot
	name = "crate"
	desc = "A crate of unknown contents, probably accidentally lost from some bygone freighter shipment or the like."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
	locked = TRUE
	anchored = TRUE
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
		if (open)
			icon_state = icon_opened
		else
			icon_state = icon_closed

		if (src.locked)
			light.color = "#FF0000"
		else
			light.color = "#00FF00"
		src.UpdateOverlays(src.light, "light")

/obj/storage/crate/loot/puzzle
	var/datum/loot_crate_lock/lock = null
	var/datum/loot_crate_trap/trap = null

	New()
		..()

		var/newlock = pick(/datum/loot_crate_lock/decacode,/datum/loot_crate_lock/hangman/seven, /datum/loot_crate_lock/hangman/nine)
		var/newtrap = pick(/datum/loot_crate_trap/crusher,/datum/loot_crate_trap/spikes,/datum/loot_crate_trap/zap, /datum/loot_crate_trap/bomb)

		if (ispath(newlock))
			var/datum/loot_crate_lock/L = new newlock
			L.holder = src
			src.lock = L
		if (ispath(newtrap))
			var/datum/loot_crate_trap/T = new newtrap
			T.holder = src
			src.trap = T

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (istype(trap))
			if (E)
				boutput(user, "<span class='alert'>The crate's anti-tamper system immediately activates in response to [E]! Fuck!</span>")
			else
				src.visible_message("<span class='alert'>Something sets off [src]'s anti-tamper system!</span>")
			trap.trigger_trap(user)
		else
			..()
		return

	attack_hand(mob/user)
		if(istype(lock) && locked)
			var/success_state = lock.attempt_to_open(user)
			if (success_state == 1) // Succeeded
				boutput(user, "<span class='notice'>The crate unlocks!</span>")
				src.locked = FALSE
				src.lock = null
				src.trap = null
				src.UpdateIcon()
			else if (success_state == 0) // Failed
				lock.fail_attempt(user)
			// Call -1 or something for cancelled attempts
		else
			return ..()

	attackby(obj/item/W, mob/user)
		if (ispulsingtool(W) && locked)
			if (istype(lock))
				lock.read_device(user)
			if (istype(trap))
				trap.read_device(user)
		else if (isweldingtool(W))
			if (W:try_weld(user,0,-1,0,0))
				boutput(user, "<span class='alert'>The crate seems to be resistant to welding.</span>")
				return
			else
				..()
		else
			..()
		return

// LOCKS

/datum/loot_crate_lock
	var/obj/storage/crate/loot/puzzle/holder = null
	var/attempts_allowed = 0
	var/attempts_remaining = 0

	New()
		..()
		scramble_code()

	proc/attempt_to_open(var/mob/living/opener)
		// Return 1 for success, 0 for failiure, anything else for cancelled attempt
		// Otherwise the trap will go off if you reconsider too many times and that'd be Very Rude
		return -1

	proc/fail_attempt(var/mob/living/opener)
		boutput(opener, "<span class='alert'>A red light flashes.</span>")
		attempts_remaining--
		if (attempts_remaining <= 0)
			boutput(opener, "<span class='alert'>The crate's anti-tamper system activates!</span>")
			if (holder?.trap)
				holder.trap.trigger_trap(opener)
				if (!holder.trap.destroys_crate)
					src.scramble_code()
					boutput(opener, "<span class='alert'>Looks like the code changed, too. You'll have to start again.</span>")
			else
				src.scramble_code()
				boutput(opener, "<span class='alert'>Looks like the code changed. You'll have to start again.</span>")
			return

	proc/inputter_check(var/mob/living/opener)
		if (GET_DIST(holder.loc,opener.loc) > 2 && !opener.bioHolder.HasEffect("telekinesis"))
			boutput(opener, "You try really hard to press the button all the way over there. Using your mind. Way to go, champ!")
			return 0

		if (!istype(opener.loc,/turf/) && !opener.bioHolder.HasEffect("telekinesis"))
			boutput(opener, "You can't press the button from inside there, you doofus!")
			return 0

		return 1

	proc/read_device(var/mob/living/reader)
		return

	proc/scramble_code()
		return

/datum/loot_crate_lock/decacode
	attempts_allowed = 3
	var/code = null
	var/lastattempt = null

	attempt_to_open(var/mob/living/opener)
		boutput(opener, "<span class='notice'>The crate is locked with a deca-code lock.</span>")
		var/input = input(usr, "Enter digit from 1 to 10.", "Deca-Code Lock") as null|num
		if (input < 1 || input > 10)
			boutput(opener, "You leave the crate alone.")
			return -1

		if (!inputter_check(opener))
			return

		src.lastattempt = input

		if (input == code)
			return 1
		else
			return 0

	read_device(var/mob/living/reader)
		boutput(reader, "<b>DECA-CODE LOCK REPORT:</b>")
		if (attempts_allowed == 1)
			boutput(reader, "<span class='alert'>* Anti-tamper system will activate on next failed access attempt.</span>")
		else
			boutput(reader, "* Anti-tamper system will activate after [attempts_remaining] failed access attempts.")

		if (lastattempt == null)
			boutput(reader, "* No attempt has been made to open the crate thus far.")
			return

		if (code > src.lastattempt)
			boutput(reader, "* Last access attempt lower than expected code.")
		else
			boutput(reader, "* Last access attempt higher than expected code.")

	scramble_code()
		code = rand(1,10)
		attempts_remaining = attempts_allowed
		lastattempt = null

/datum/loot_crate_lock/hangman
	attempts_allowed = 8
	var/code = null
	var/revealed_code = "*****"
	var/code_pool = "five"

	seven
		attempts_allowed = 8
		revealed_code = "*******"
		code_pool = "seven"

	nine
		attempts_allowed = 8
		revealed_code = "*********"
		code_pool = "nine"

	attempt_to_open(var/mob/living/opener)
		boutput(opener, "<span class='notice'>The crate is locked with a password lock. You'll need a multitool or similar to get very far here.</span>")
		var/input = input(usr, "Enter one letter to reveal part of the password, or attempt to guess the password.", "Password Lock") as null|text
		input = lowertext(input)

		if (!istext(input) || length(input) < 1)
			boutput(opener, "You leave the crate alone.")
			return -1

		if (!inputter_check(opener))
			return

		if (length(input) == 1)
			if (attempts_remaining <= 1)
				boutput(opener, "<span class='alert'>Trying to reveal any more of the password would set off the anti-tamper system. You'll have to make a guess.</span>")
				return -1

			var/chars_found = 0
			var/loops = length(code)

			for (var/i = 1, i <= loops, i++)
				if (chs(code, i) == input)
					chars_found++
					revealed_code = copytext(revealed_code,1,i) + input + copytext(revealed_code,i+1)

			if (chars_found)
				boutput(opener, "Found [input] in password.")
			else
				boutput(opener, "Did not find [input] in password.")
				attempts_remaining--

			return -1
		else
			if (input == code)
				return 1
			else
				return 0

	read_device(var/mob/living/reader)
		boutput(reader, "<b>PASSWORD LOCK REPORT:</b>")
		boutput(reader, "All passwords are fully lower-case and feature no non-alphabetical characters.")
		if (attempts_allowed == 1)
			boutput(reader, "<span class='alert'>* Anti-tamper system will activate on next failed access attempt.</span>")
		else
			boutput(reader, "* Anti-tamper system will activate after [attempts_remaining] failed access attempts.")

		boutput(reader, "* Characters known: [revealed_code]")
		return

	scramble_code()
		code = pick(strings("password_pool.txt", code_pool))
		attempts_remaining = attempts_allowed
		revealed_code = initial(revealed_code)

// TRAPS

/datum/loot_crate_trap
	var/obj/storage/crate/loot/puzzle/holder = null
	var/destroys_crate = 0
	var/desc = null

	proc/trigger_trap(var/mob/living/opener)
		return 1

	proc/read_device(var/mob/living/reader)
		if (istext(desc))
			boutput(reader, "[desc]")
		return

/datum/loot_crate_trap/bomb
	destroys_crate = 1
	desc = "Security Measure Installed: Officer Dan's Anti-Tamper Bomb System Mk 1.4"
	var/list/bomb_yields = list(-1,-1,1,1)

	trigger_trap(var/mob/living/opener)
		var/turf/T = get_turf(holder)
		holder.visible_message("<b>[holder] beeps, \"Thank you for triggering Officer Dan's Anti-Tamper Bomb system. Have a nice day.\"")
		playsound(T, "explosion", 50, 1)
		explosion(holder, T,bomb_yields[1],bomb_yields[2],bomb_yields[3],bomb_yields[4])
		qdel(holder)
		return

/datum/loot_crate_trap/spikes
	desc = "Security Measure Installed: Robust Solutions Inc. Anti-Thief Sublethal Skewer System"
	var/damage = 20

	trigger_trap(var/mob/living/opener)
		holder.visible_message("<span class='alert'><b>Spikes shoot out of [holder]!</b></span>")
		if (opener)
			random_brute_damage(opener,damage,1)
			playsound(opener.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, 1)
		return

/datum/loot_crate_trap/zap
	desc = "Security Measure Installed: Robust Solutions Inc. Anti-Thief Electric Shock System"
	var/wattage = 17500

	trigger_trap(var/mob/living/opener)
		if (opener)
			opener.shock(holder,wattage,1,1)
		return

/datum/loot_crate_trap/crusher
	desc = "Security Measure Installed: Dyna*Corp Contingency Crate Grinder System"
	destroys_crate = 1

	trigger_trap(var/mob/living/opener)
		holder.visible_message("<span class='alert'>A loud grinding sound comes from inside [holder] as it unlocks!</span>")
		playsound(holder.loc, 'sound/machines/engine_grump1.ogg', 60, 1)

		for (var/obj/I in holder.contents)
			if (istype(I,/mob/living/critter/small_animal/cat))
				continue // absolutely fucking not >=I
			new /obj/item/scrap(holder)
			qdel(I)

		holder.locked = FALSE
		holder.lock = null
		holder.trap = null
		holder.UpdateIcon()
		return

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
			boutput(user, "<span class='alert'>You're going to have to use a heftier object if you want to break the crate's anti-tampering system.</span>")
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
		attached.anchored = TRUE
		attached.update_icon()
		icon_state = "antitamper-on"
		playsound(src, 'sound/impact_sounds/Wood_Snap.ogg', 40, 1)

	proc/detach_from()
		if (!attached)
			return
		icon_state = ""
		flick("antitamper-break", src)
		var/obj/storage/crate/C = attached
		attached = null
		SPAWN(1 SECOND)
			C.vis_contents -= src
			C.locked = FALSE
			C.anchored = FALSE
			C.update_icon()
			qdel(src)
		playsound(src, 'sound/impact_sounds/plate_break.ogg', 30, 1)

/obj/item/clothing/gloves/psylink_bracelet
	name = "jewelled bracelet"
	desc = "Some pretty jewellery."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bracelet"
	material_prints = "patterned scratches"
	w_class = W_CLASS_TINY
	var/primary = TRUE
	var/image/gemstone = null
	var/obj/item/clothing/gloves/psylink_bracelet/twin
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
				boutput(user, "<span class='alert'>You suddenly begin hearing and seeing things. What the hell?</span>")
				boutput(psy, "<span class='alert'>You suddenly begin hearing and seeing things. What the hell?</span>")

	unequipped(var/mob/user)
		..()
		if (!user)
			return
		if (src.twin && ishuman(src.twin.loc))
			var/mob/living/carbon/human/psy = src.twin.loc
			if (psy.bioHolder && psy.bioHolder.HasEffect("psy_resist"))
				return
			if (psy.gloves == src.twin)
				boutput(user, "<span class='notice'>The strange hallcuinations suddenly stop. That was weird.</span>")
				boutput(psy, "<span class='notice'>The strange hallcuinations suddenly stop. That was weird.</span>")

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
