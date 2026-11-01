
/datum/lifeprocess/statusupdate

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
			owner.changeStatus("unconscious", 3 SECONDS * mult)
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
		if (owner.getStatusDuration("blinded") || owner.getStatusDuration("teleporting") || src.owner.loc?.getStatusDuration("teleporting"))
			owner.blinded = 1
		else
			if(!(HAS_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION)))
				for (var/thing in owner.get_equipped_items())
					if (!thing) continue
					var/obj/item/I = thing
					if (I.block_vision)
						owner.blinded = 1
						break

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

