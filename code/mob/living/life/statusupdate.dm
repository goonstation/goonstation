
/datum/lifeprocess/statusupdate
	//april fools stuff
	var/blinktimer = 0
	var/blinktimerstage = 0
	var/blinktimernotifredundant = 0
	var/blinkstate = 0

	process(var/datum/gas_mixture/environment)
		//proc/handle_regular_status_updates(datum/controller/process/mobs/parent,var/mult = 1)
		if (owner.bioHolder && owner.bioHolder.HasEffect("revenant") || isdead(owner)) //You also don't need to do a whole lot of this if the dude's dead.
			return ..()

		var/mult = get_multiplier()

		//maximum stamina modifiers.
		owner.stamina_max = max((STAMINA_MAX + owner.get_stam_mod_max()), 0)
		owner.stamina = min(owner.stamina, owner.stamina_max)

		if (owner.sleeping)
			if (owner.hasStatus("resting"))
				owner.sleeping = 2
			else
				owner.sleeping = max(owner.sleeping - mult, 0)
			owner.changeStatus("paralysis", 3 SECONDS * mult)
			if (prob(10) && (owner.health > 0))
				owner.emote("snore")
			if (!owner.last_sleep) // we are asleep but weren't previously
				owner.last_sleep = 1
				owner.UpdateOverlays(owner.sleep_bubble, "sleep_bubble")
				if (critter_owner)
					critter_owner.on_sleep()
		else
			if (owner.last_sleep) // we were previously asleep but aren't anymore
				owner.last_sleep = 0
				owner.UpdateOverlays(null, "sleep_bubble")

				if (critter_owner)
					critter_owner.on_wake()

		if (prob(50) && owner.hasStatus("disorient"))
			//src.drop_item()
			owner.emote("twitch")

		//todo : clothing blindles flags for less istypeing
		if (owner.getStatusDuration("blinded"))
			owner.blinded = 1
		else
			for (var/thing in owner.get_equipped_items())
				if (!thing) continue
				var/obj/item/I = thing
				if (I.block_vision)
					owner.blinded = 1
					break

		if (manualblinking && human_owner)
			var/showmessages = 1
			var/tempblind = owner.get_eye_damage(1)

			if (owner.find_ailment_by_type(/datum/ailment/disability/blind))
				showmessages = 0

			src.blinktimer += mult
			switch(src.blinktimer)
				if (0 to 20)
					src.blinktimerstage = 0
					src.blinktimernotifredundant = 0
				if (20 to 30)
					if (!src.blinktimernotifredundant)
						src.blinktimerstage = 1
				if (30 to 40)
					if (src.blinktimernotifredundant < 2)
						src.blinktimerstage = 2
				if (40 to 60)
					owner.change_eye_blurry(3, 3)
					if (src.blinktimernotifredundant < 3)
						src.blinktimerstage = 3
				if (60 to 100)
					owner.take_eye_damage(clamp(3 - tempblind, 0, 3), 1)
					if (src.blinktimernotifredundant < 4)
						src.blinktimerstage = 4
				if (100 to INFINITY)
					owner.contract_disease(/datum/ailment/disability/blind,null,null,1)
					if (src.blinktimernotifredundant < 5)
						src.blinktimerstage = 5
			switch(src.blinktimerstage)
				if (0)
					; // this statement is intentionally left blank
				if (1)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel slightly uncomfortable!</span>")
					src.blinktimernotifredundant = 1
				if (2)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel quite dry!</span>")
					src.blinktimernotifredundant = 2
				if (3)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel very dry and uncomfortable, it's getting difficult to see!</span>")
					src.blinktimernotifredundant = 3
				if (4)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes are so dry that you can't see a thing!</span>")
					src.blinktimernotifredundant = 4
				if (5) //blinking won't save you now, buddy
					if (showmessages) boutput(owner, "<span class='alert'>You feel a horrible pain in your eyes. That can't be good.</span>")
					src.blinktimernotifredundant = 5
			src.blinktimerstage = 0

			if (src.blinkstate) owner.take_eye_damage(clamp(1 - tempblind, 0, 1), 1)

		if (owner.get_eye_damage(1)) // Temporary blindness.
			owner.take_eye_damage(-mult, 1)
			owner.blinded = 1

		if (owner.stuttering)
			owner.stuttering = max(owner.stuttering - mult, 0)

		if (owner.get_ear_damage(1)) // Temporary deafness.
			owner.take_ear_damage(-mult, 1)

		if (owner.get_ear_damage() && (owner.get_ear_damage() <= owner.get_ear_damage_natural_healing_threshold()))
			owner.take_ear_damage(-0.05*mult)

		if (owner.get_eye_blurry())
			owner.change_eye_blurry(-mult)

		if (owner.druggy)
			owner.druggy = max(owner.druggy-mult, 0)

		if (owner.nodamage)
			owner.HealDamage("All", 10000, 10000)
			owner.take_toxin_damage(-5000)
			owner.take_oxygen_deprivation(-5000)
			owner.take_brain_damage(-120)
			owner.stuttering = 0
			owner.take_ear_damage(-INFINITY)
			owner.take_ear_damage(-INFINITY, 1)
			owner.change_eye_blurry(-INFINITY)
			owner.druggy = 0
			owner.blinded = null

		..()

