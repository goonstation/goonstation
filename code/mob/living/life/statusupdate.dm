
/datum/lifeprocess/statusupdate
	//april fools stuff
	var/blinktimer = 0
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
				owner.sleeping--
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

			src.blinktimer++
			switch(src.blinktimer)
				if (20)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel slightly uncomfortable!</span>")
				if (30)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel quite dry!</span>")
				if (40)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes feel very dry and uncomfortable, it's getting difficult to see!</span>")
					owner.change_eye_blurry(3, 3)
				if (41 to 59)
					owner.change_eye_blurry(3, 3)
				if (60)
					if (showmessages) boutput(owner, "<span class='alert'>Your eyes are so dry that you can't see a thing!</span>")
					owner.take_eye_damage(max(0, min(3, 3 - tempblind)), 1)
				if (61 to 99)
					owner.take_eye_damage(max(0, min(3, 3 - tempblind)), 1)
				if (100) //blinking won't save you now, buddy
					if (showmessages) boutput(owner, "<span class='alert'>You feel a horrible pain in your eyes. That can't be good.</span>")
					owner.contract_disease(/datum/ailment/disability/blind,null,null,1)

			if (src.blinkstate) owner.take_eye_damage(max(0, min(1, 1 - tempblind)), 1)

		if (owner.get_eye_damage(1)) // Temporary blindness.
			owner.take_eye_damage(-1, 1)
			owner.blinded = 1

		if (owner.stuttering)
			owner.stuttering--

		if (owner.get_ear_damage(1)) // Temporary deafness.
			owner.take_ear_damage(-1, 1)

		if (owner.get_ear_damage() && (owner.get_ear_damage() <= owner.get_ear_damage_natural_healing_threshold()))
			owner.take_ear_damage(-0.05)

		if (owner.get_eye_blurry())
			owner.change_eye_blurry(-1)

		if (owner.druggy)
			owner.druggy = max(owner.druggy-1, 0)

		if (owner.nodamage)
			owner.HealDamage("All", 10000, 10000)
			owner.take_toxin_damage(-5000)
			owner.take_oxygen_deprivation(-5000)
			owner.take_brain_damage(-120)
			owner.delStatus("radiation")
			owner.delStatus("paralysis")
			owner.delStatus("weakened")
			owner.delStatus("stunned")
			owner.stuttering = 0
			owner.take_ear_damage(-INFINITY)
			owner.take_ear_damage(-INFINITY, 1)
			owner.change_eye_blurry(-INFINITY)
			owner.druggy = 0
			owner.blinded = null

		if (hivebot_owner)
			hivebot_owner.hud.update_charge()
			hivebot_owner.health = hivebot_owner.max_health - (hivebot_owner.fireloss + hivebot_owner.bruteloss)
			return ..()

		if (robot_owner)
			if(!robot_owner.part_chest)
				// this doesn't even make any sense unless you're rayman or some shit

				if (robot_owner.mind && robot_owner.mind.special_role)
					robot_owner.handle_robot_antagonist_status("death", 1) // Mindslave or rogue (Convair880).

				robot_owner.visible_message("<b>[owner]</b> falls apart with no chest to keep it together!")
				logTheThing("combat", robot_owner, null, "was destroyed at [log_loc(robot_owner)].") // Brought in line with carbon mobs (Convair880).

				if (robot_owner.part_arm_l)
					if (robot_owner.part_arm_l.slot == "arm_both")
						robot_owner.part_arm_l.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
						robot_owner.part_arm_r = null
					else
						robot_owner.part_arm_l.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
				if (robot_owner.part_arm_r)
					if (robot_owner.part_arm_r.slot == "arm_both")
						robot_owner.part_arm_r.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
						robot_owner.part_arm_r = null
					else
						robot_owner.part_arm_r.set_loc(robot_owner.loc)
						robot_owner.part_arm_r = null

				if (robot_owner.part_leg_l)
					if (robot_owner.part_leg_l.slot == "leg_both")
						robot_owner.part_leg_l.set_loc(robot_owner.loc)
						robot_owner.part_leg_l = null
						robot_owner.part_leg_r = null
					else
						robot_owner.part_leg_l.set_loc(robot_owner.loc)
						robot_owner.part_leg_l = null
				if (robot_owner.part_leg_r)
					if (robot_owner.part_leg_r.slot == "leg_both")
						robot_owner.part_leg_r.set_loc(robot_owner.loc)
						robot_owner.part_leg_r = null
						robot_owner.part_leg_l = null
					else
						robot_owner.part_leg_r.set_loc(robot_owner.loc)
						robot_owner.part_leg_r = null

				if (robot_owner.part_head)
					robot_owner.part_head.set_loc(robot_owner.loc)
					robot_owner.part_head = null
					//no chest means you are dead. Placed here to avoid duplicate alert in event that head was already destroyed and you then destroy torso
					robot_owner.borg_death_alert()

				if (robot_owner.client)
					var/mob/dead/observer/newmob = robot_owner.ghostize()
					if (newmob)
						newmob.corpse = null

				new /obj/item/parts/robot_parts/robot_frame(get_turf(robot_owner))

				qdel(robot_owner)

			else if (!robot_owner.part_head && robot_owner.client)
				// no head means no brain!!

				if (robot_owner.mind && robot_owner.mind.special_role)
					robot_owner.handle_robot_antagonist_status("death", 1) // Mindslave or rogue (Convair880).

				robot_owner.visible_message("<b>[owner]</b> completely stops moving and shuts down...")
				robot_owner.borg_death_alert()
				logTheThing("combat", owner, null, "was destroyed at [log_loc(robot_owner)].") // Ditto (Convair880).

				var/mob/dead/observer/newmob = robot_owner.ghostize()
				if (newmob)
					newmob.corpse = null

		..()

