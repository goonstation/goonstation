/datum/loot_crate_table
	// list of obj or lists
	// if an element is a list, the result is picked randomly
	var/items = list()
	// list of nums or lists
	// if an element is a list, it's treated as bounds [lower, upper]
	// for the amount of items
	var/amounts = list()

	// actual items and amounts
	var/collapsed_items = list()
	var/collapsed_amounts = list()

	New()
		..()
		for (var/i in 1 to length(items))
			var/item = items[i]
			var/amount = amounts[i]
			if (islist(amount))
				amount = rand(amount[1], amount[2])
				if (islist(item))
					for(var/_ in 1 to amount)
						collapsed_items += pick(item)
						collapsed_amounts += 1
				else
					collapsed_items += item
					collapsed_amounts += amount
			else
				if (islist(item))
					collapsed_items += pick(item)
				else
					collapsed_items += item
				collapsed_amounts += amount

/datum/loot_crate_table/research
	// Tier 3
	psylink
		items = list(/obj/item/clothing/gloves/psylink_bracelet)
		amounts = list(1)

	artifact
		// All of these are pretty useful and it heavily reduces chances of telewand.
		items = list(
			list(
				/obj/item/artifact/teleport_wand,
				/obj/item/artifact/activator_key,
				/obj/item/gun/energy/artifact,
				/obj/item/artifact/melee_weapon,
				/obj/item/artifact/forcewall_wand
				)
			)
		amounts = list(1)

	voltron
		items = list(/obj/item/device/voltron)
		amounts = list(1)

	// Tier 2
	critter
		// 1/2 chance for scary thing that has cool arms you can use, 1/2 chance for cute thing!!
		items = list(
			list(
				/obj/critter/bear,
				/obj/critter/domestic_bee,
				/obj/critter/brullbar,
				/obj/critter/nicespider
				)
			)
		amounts = list(1)

	injector
		items = list(
			list(
				/obj/item/injector_belt,
				/obj/item/clothing/mask/gas/injector_mask
				)
			)
		amounts = list(1)

	robo
		items = list(
			/obj/item/roboupgrade/efficiency,
			/obj/item/roboupgrade/jetpack,
			list(
				/obj/item/roboupgrade/physshield,
				/obj/item/roboupgrade/teleport,
				/obj/item/roboupgrade/speed
			)
		)
		amounts = list(1, 1, 1)

	medicine
		items = list(
			/obj/item/reagent_containers/glass/beaker/large/antitox,
			/obj/item/reagent_containers/glass/beaker/large/brute,
			/obj/item/reagent_containers/glass/beaker/large/burn,
			/obj/item/reagent_containers/glass/beaker/large/epinephrine,
			/obj/item/reagent_containers/hypospray
		)

		amounts = list(1, 1, 1, 1, 1)

	spore
		items = list(/obj/critter/spore)
		amounts = list(3)

	hydroponics
		items = list(
			/obj/item/reagent_containers/glass/happyplant,
			/obj/item/seed/alien
		)
		amounts = list(2, 3)

/datum/loot_crate_table/military
	// Tier 3
	voltron
		items = list(/obj/item/device/voltron)
		amounts = list(1)

	power
		items = list(
			/obj/item/ammo/power_cell/self_charging/pod_wars_standard,
			// 400 pu charge, designed to be able to be a trade off of higher capacity at the cost of no self recharging, or vice versa.
			/obj/item/ammo/power_cell/higherish_power
		)
		amounts = list(1,1)

	titanium
		items = list(/obj/item/clothing/gloves/ring/titanium)
		amounts = list(1)

	// Tier 2
	plasma
		items = list(/obj/item/gun/energy/plasma_gun)
		amounts = list(1)
	phaser
		items = list(/obj/item/gun/energy/phaser_gun, /obj/item/storage/firstaid/crit)
		amounts = list(1, 1)
	grenades
		New()
			..()
			for (var/i = 1, i < rand(4,10), i++)
				collapsed_items += pick(/obj/item/chem_grenade/incendiary, /obj/item/chem_grenade/cryo, /obj/item/chem_grenade/shock, /obj/item/chem_grenade/pepper, prob(10); /obj/item/chem_grenade/sarin)
				collapsed_amounts += 1

	// Tier 1
	medicine
		items = list(
			/obj/item/reagent_containers/glass/beaker/large/antitox,
			/obj/item/reagent_containers/glass/beaker/large/brute,
			/obj/item/reagent_containers/glass/beaker/large/burn,
			/obj/item/reagent_containers/glass/beaker/large/epinephrine,
			/obj/item/reagent_containers/hypospray
		)
		amounts = list(1,1,1,1,1)

/datum/loot_crate_table/industrial
	// Tier 3
	jetpack
		items = list(/obj/item/clothing/shoes/jetpack)
		amounts = list(1)

	wizard
		New()
			items += concrete_typesof(/obj/item/wizard_crystal)
			amounts += 3
			..()

	ship
		items = list(/obj/item/shipcomponent/mainweapon/rockdrills)
		amounts = list(1)

	// Tier 2
	material
		items = list(
			list(
				/obj/item/raw_material/telecrystal,
				/obj/item/raw_material/gemstone,
				/obj/item/raw_material/miracle,
				/obj/item/raw_material/uqill
			)
		)
		amounts = list(30)

	fermid
		items = list(/obj/critter/fermid)
		amounts = list(1)

	// Tier 1
	explosives
		items = list(/obj/item/breaching_charge/mining)
		amounts = list(25)

	gear
		items = list(
			/obj/item/clothing/gloves/concussive,
			/obj/item/clothing/shoes/industrial
		)
		amounts = list(1, 1)

	armor
		items = list(
			/obj/item/clothing/head/helmet/space/industrial,
			/obj/item/clothing/suit/space/industrial
		)
		amounts = list(1, 1)

	less_material
		items = list(
			list(
				/obj/item/raw_material/telecrystal,
				/obj/item/raw_material/gemstone,
				/obj/item/raw_material/miracle,
				/obj/item/raw_material/uqill
				)
			)
		amounts = list(10)

	worse_material
		items = list(
			list(
				/obj/item/raw_material/syreline,
				/obj/item/raw_material/bohrum,
				/obj/item/raw_material/claretine,
				/obj/item/raw_material/cerenkite
				)
			)
		amounts = list(40)

	cargo
		items = list(
			list(
				/obj/item/radio_tape/advertisement/cargonia,
				/obj/item/clothing/under/rank/cargo,
				/obj/decal/fakeobjects/skeleton
				)
			)
		amounts = list(1, 1, 1)

	rockworm
		items = list(/obj/critter/rockworm)
		amounts = list(3)

/datum/loot_crate_table/criminal
	// Tier 3
	bling
		items = list(/obj/item/gun/bling_blaster)
		amounts = list(1)

	loadsofmoney
		items = list(/obj/item/spacecash/hundredthousand)
		amounts = list(3)

	// Tier 2
	money
		items = list(/obj/item/spacecash/thousand)
		amounts = list(20)

	gold
		items = list(/obj/item/material_piece/gold)
		amounts = list(5)

	omega
		items = list(/obj/item/plant/herb/cannabis/omega/spawnable)
		amounts = list(10)

	cyberpunk
		items = list(/obj/item/storage/pill_bottle/cyberpunk)
		amounts = list(3)

	// Tier 1
	money/less
		amounts = list(5)

	wine
		items = list(/obj/item/reagent_containers/food/drinks/bottle/hobo_wine)
		amounts = list(5)

	gold/less
		amounts = list(1)

	cannabis
		items = list(
			list(
				/obj/item/plant/herb/cannabis/spawnable,
				/obj/item/plant/herb/cannabis/white/spawnable,
				/obj/item/plant/herb/cannabis/mega/spawnable
				)
			)
		amounts = list(10)


/obj/storage/crate/loot
	name = "crate"
	desc = "A crate of unknown contents, probably accidentally lost from some bygone freighter shipment or the like."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
	locked = 1
	var/tier = 1
	var/image/light = null
	var/datum/loot_crate_lock/lock = null
	var/datum/loot_crate_trap/trap = null

	New()
		..()
		src.light = image('icons/obj/large_storage.dmi',"lootcratelocklight")

		tier = RarityClassRoll(100,0,list(95,70))
		var/kind = rand(1,5)
		// kinds: (1) Civilian (2) Scientific (3) Industrial (4) Military (5) Criminal

		var/list/items = list()
		var/list/item_amounts = list()
		var/picker = 0

		switch(kind)
			if(2)
				name = "research shipment crate"
				desc = "There are laboratory and research company logos on the crate."
				icon_state = "lootsci"
				icon_opened = "lootsciopen"
				icon_closed = "lootsci"

				// SCIENCE GOODS LOOT TABLE
				var/datum/loot_crate_table/t
				if (tier == 3)
					picker = rand(1,3)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/research/psylink
						if(2)
							t = new /datum/loot_crate_table/research/artifact
						else
							t = new /datum/loot_crate_table/research/voltron
				else if (tier == 2)
					picker = rand(1,2)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/research/critter
						if(2)
							t = new /datum/loot_crate_table/research/injector
				else
					picker = rand(1,4)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/research/robo
						if(2)
							t = new /datum/loot_crate_table/research/medicine
						if(3)
							t = new /datum/loot_crate_table/research/spore
						else
							t = new /datum/loot_crate_table/research/hydroponics
				items = t.collapsed_items
				item_amounts = t.collapsed_amounts

			if(3)
				name = "industrial shipment crate"
				desc = "There are industrial company logos on the crate."
				icon_state = "lootind"
				icon_opened = "lootindopen"
				icon_closed = "lootind"

				// INDUSTRIAL GOODS LOOT TABLE
				var/datum/loot_crate_table/t
				if (tier == 3)
					picker = rand(1,3)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/industrial/jetpack
						if(2)
							t = new /datum/loot_crate_table/industrial/wizard
						else
							t = new /datum/loot_crate_table/industrial/ship

				else if (tier == 2)
					picker = rand(1,4)
					switch(picker)
						if(1 to 3)
							t = new /datum/loot_crate_table/industrial/material
						else
							t = new /datum/loot_crate_table/industrial/fermid
				else
					picker = rand(1,7)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/industrial/explosives
						if(2)
							t = new /datum/loot_crate_table/industrial/gear
						if(3)
							t = new /datum/loot_crate_table/industrial/armor
						if(4)
							t = new /datum/loot_crate_table/industrial/less_material
						if(5)
							t = new /datum/loot_crate_table/industrial/worse_material
						if(6)
							t = new /datum/loot_crate_table/industrial/cargo
						else
							t = new /datum/loot_crate_table/industrial/rockworm
				items = t.collapsed_items
				item_amounts = t.collapsed_amounts

			if(4)
				name = "military shipment crate"
				desc = "The crate is covered in military insignia."
				icon_state = "lootmil"
				icon_opened = "lootmilopen"
				icon_closed = "lootmil"

				// MILITARY GOODS LOOT TABLE
				var/datum/loot_crate_table/t
				if (tier == 3)
					picker = rand(1,3)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/military/voltron
						if(2)
							t = new /datum/loot_crate_table/military/power
						else
							t = new /datum/loot_crate_table/military/titanium

				else if (tier == 2)
					picker = rand(1,10)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/military/plasma
						if(2 to 6)
							t = new /datum/loot_crate_table/military/phaser
						if(7 to 10)
							t = new /datum/loot_crate_table/military/grenades
				else
					t = new /datum/loot_crate_table/military/medicine
				items = t.collapsed_items
				item_amounts = t.collapsed_amounts

			if(5)
				name = "unmarked shipment crate"
				desc = "This crate seems to have all identifications scratched off."
				icon_state = "lootcrime"
				icon_opened = "lootcrimeopen"
				icon_closed = "lootcrime"

				// CRIMINAL GOODS LOOT TABLE
				var/datum/loot_crate_table/t
				if (tier == 3)
					picker = rand(1,6)
					switch(picker)
						if(1 to 2)
							t = new /datum/loot_crate_table/military/voltron
						if(3 to 5)
							t = new /datum/loot_crate_table/criminal/bling
						else
							t = new /datum/loot_crate_table/criminal/loadsofmoney
				else if (tier == 2)
					picker = rand(1,4)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/criminal/money
						if(2)
							t = new /datum/loot_crate_table/criminal/gold
						if(3)
							t = new /datum/loot_crate_table/criminal/omega
						if(4)
							t = new /datum/loot_crate_table/criminal/cyberpunk
				else
					picker = rand(1,4)
					switch(picker)
						if(1)
							t = new /datum/loot_crate_table/criminal/money/less
						if(2)
							t = new /datum/loot_crate_table/criminal/wine
						if(3)
							t = new /datum/loot_crate_table/criminal/gold/less
						if(4)
							t = new /datum/loot_crate_table/criminal/cannabis
				items = t.collapsed_items
				item_amounts = t.collapsed_amounts

			else
				name = "goods shipment crate"
				desc = "There are consumer goods company logos on the crate."

				// CIVILIAN GOODS LOOT TABLE
				if (tier == 3)
					picker = rand(1,3)
					switch(picker)
						if(1)
							items += /obj/item/clothing/under/gimmick/frog
							item_amounts += 1
						if(2)
							items += /obj/item/clothing/shoes/sandal
							item_amounts += 1
						else
							items += /obj/vehicle/skateboard
							item_amounts += 1
				else if (tier == 2)
					picker = rand(1,3)
					switch(picker)
						if(1)
							items += /obj/item/reagent_containers/food/snacks/plant/tomato/incendiary
							item_amounts += 5
						if(2)
							items += /obj/item/clothing/ears/earmuffs/yeti
							item_amounts += 1
						if(3)
							items += /obj/item/device/light/zippo/gold
							item_amounts += 1
							items += /obj/item/cigpacket/random
							item_amounts += rand(2,4)
				else
					picker = rand(1,5)
					switch(picker)
						if(1)
							items += /obj/item/clothing/shoes/moon
							item_amounts += 1
						if(2)
							items += /obj/item/reagent_containers/food/drinks/bottle/hobo_wine
							item_amounts += 5
						if(3)
							items += pick(/obj/item/reagent_containers/food/snacks/burrito,
							/obj/item/reagent_containers/food/snacks/snack_cake,
							/obj/item/reagent_containers/food/snacks/snack_cake/golden,
							/obj/item/reagent_containers/food/snacks/plant/lashberry,
							/obj/item/reagent_containers/food/snacks/plant/tomato)
							item_amounts += 5
						if(4)
							items += /obj/critter/cat
							item_amounts += 1
						if(5)
							items += /obj/item/device/flyswatter
							item_amounts += 1
							items += /obj/item/storage/box/mousetraps
							item_amounts += 1

		var/trap_prob = 100
		var/newlock = null
		var/newtrap = null
		switch(tier)
			if(2)
				newlock = pick(/datum/loot_crate_lock/decacode,/datum/loot_crate_lock/hangman/seven, /datum/loot_crate_lock/hangman/nine)
				newtrap = pick(/datum/loot_crate_trap/crusher,/datum/loot_crate_trap/spikes,/datum/loot_crate_trap/zap, /datum/loot_crate_trap/bomb)
			if(3)
				newlock = pick(/datum/loot_crate_lock/hangman/nine, /datum/loot_crate_lock/hangman/seven)
				newtrap = pick(/datum/loot_crate_trap/bomb,/datum/loot_crate_trap/zap, /datum/loot_crate_trap/crusher)
			else
				trap_prob = 33
				newlock = pick(/datum/loot_crate_lock/decacode,/datum/loot_crate_lock/hangman)
				newtrap = /datum/loot_crate_trap/spikes

		if (ispath(newlock))
			var/datum/loot_crate_lock/L = new newlock
			L.holder = src
			src.lock = L
		if (ispath(newtrap) && prob(trap_prob))
			var/datum/loot_crate_trap/T = new newtrap
			T.holder = src
			src.trap = T

		var/list_counter = 1
		var/temp_counter = 0
		for (var/X in items)
			temp_counter = item_amounts[list_counter]
			while (temp_counter > 0)
				temp_counter--
				new X(src)
			list_counter++

		SPAWN(0)
			UpdateIcon()

		return

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
				src.locked = 0
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

	update_icon()

		if(open) icon_state = icon_opened
		else icon_state = icon_closed

		if (src.locked)
			light.color = "#FF0000"
		else
			light.color = "#00FF00"
		src.UpdateOverlays(src.light, "light")

// LOCKS

/datum/loot_crate_lock
	var/obj/storage/crate/loot/holder = null
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
		if (get_dist(holder.loc,opener.loc) > 2 && !opener.bioHolder.HasEffect("telekinesis"))
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
	var/obj/storage/crate/loot/holder = null
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
			playsound(opener.loc, "sound/impact_sounds/Flesh_Stab_1.ogg", 60, 1)
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
		playsound(holder.loc, "sound/machines/engine_grump1.ogg", 60, 1)

		for (var/obj/I in holder.contents)
			if (istype(I,/obj/critter/cat/))
				continue // absolutely fucking not >=I
			new /obj/item/scrap(holder)
			qdel(I)

		holder.locked = 0
		holder.lock = null
		holder.trap = null
		holder.UpdateIcon()
		return

// Items specific to loot crates

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
