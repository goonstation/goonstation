/datum/targetable/changeling/handspider
	name = "Handspider"
	desc = "Detach one of your arms and bring it to life using one of the members of your hivemind."
	icon_state = "handspider"
	cooldown = 600
	targeted = 0
	target_anything = 0
	human_only = 0
	pointCost = 4
	can_use_in_container = 1
	dont_lock_holder = 0

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, __red("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, __red("A slave cannot release a sub-form!."))
			return 1

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			if (O.client)
				eligible[O.real_name] = O

		if (eligible.len < 1)
			boutput(holder.owner, __red("There are no minds eligible for this ability. We need to absorb another."))
			return 1

		var/use_mob_name = input("Select the mind to transfer into the handspider: ", "Select Mind", null) as null|anything in eligible
		if (!use_mob_name)
			boutput(holder.owner, __blue("We change our mind."))
			return 1
		var/mob/dead/target_observer/hivemind_observer/use_mob = eligible[use_mob_name]

		var/mob/living/carbon/human/owner = holder.owner
		if (!(owner.limbs.l_arm || owner.limbs.r_arm) || !ishuman(holder.owner))
			boutput(holder.owner, __blue("We have no arms to detach!"))
			return 1

		var/arm_type = 0

		if (owner.limbs.l_arm && owner.limbs.r_arm) //if both arms are available, remove the inactive one
			if (owner.hand)
				arm_type = owner.limbs.r_arm.type
				owner.limbs.r_arm.delete()
			else
				arm_type = owner.limbs.l_arm.type
				owner.limbs.l_arm.delete()
		else if (owner.limbs.l_arm)
			arm_type = owner.limbs.l_arm.type
			owner.limbs.l_arm.delete()
		else
			arm_type = owner.limbs.r_arm.type
			owner.limbs.r_arm.delete()

		holder.owner.visible_message(text("<span class='alert'><B>[holder.owner]'s arm falls off and starts moving!</B></span>"))
		logTheThing("combat", holder.owner, use_mob, "drops a handspider [use_mob] as a changeling [log_loc(holder.owner)].")

		var/mob/living/critter/changeling/handspider/spider = new /mob/living/critter/changeling/handspider(get_turf(owner.loc))

		if (use_mob.mind)
			use_mob.mind.transfer_to(spider)
		else if (use_mob.client)
			use_mob.client.mob = spider
		H.hivemind -= use_mob
		H.hivemind += spider
		spider.real_name = use_mob.real_name
		spider.hivemind_owner = H

		if (arm_type && istype(arm_type, /obj/item/parts/robot_parts))
			spider.icon_prefix = "robo"
			spider.update_icon()

		spider.Browse(grabResource("html/mindslave/handspider.html"),"window=antagTips;size=600x400;title=Antagonist Tips")
		boutput(spider, "<h2><font color=red>You have reawakened to serve your host [holder.owner]! You must follow their commands!</font></h2>")
		boutput(spider, "<font color=red>You are a very small and weak creature that can fit into tight spaces. You are still connected to the hivemind.</font>")

		if (spider.mind && ticker.mode)
			if (!spider.mind.special_role)
				spider.mind.special_role = "handspider"
			if (!(spider.mind in ticker.mode.Agimmicks))
				ticker.mode.Agimmicks += spider.mind
			spider.mind.master = owner.ckey

		if (owner.mind && owner.mind.current && spider.client)
			var/I = image(antag_changeling, loc = owner.mind.current)
			spider.client.images += I

		qdel(use_mob)
		return 0

// feels bad copy-pasting this, maybe refactor this in future - cirr
/datum/targetable/changeling/eyespider
	name = "Eyespider"
	desc = "Eject one of your eyes as a non-combatant utility form and bring it to life using one of the members of your hivemind."
	icon_state = "eyespider"
	cooldown = 600
	targeted = 0
	target_anything = 0
	human_only = 0
	pointCost = 0 // free for now, given you have to lose a fuckin' EYE
	can_use_in_container = 1
	dont_lock_holder = 0

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, __red("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, __red("A slave cannot release a sub-form!."))
			return 1

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			if (O.client)
				eligible[O.real_name] = O

		if (eligible.len < 1)
			boutput(holder.owner, __red("There are no minds eligible for this ability. We need to absorb another."))
			return 1

		var/use_mob_name = input("Select the mind to transfer into the eyespider: ", "Select Mind", null) as null|anything in eligible
		if (!use_mob_name)
			boutput(holder.owner, __blue("We change our mind."))
			return 1
		var/mob/dead/target_observer/hivemind_observer/use_mob = eligible[use_mob_name]

		var/mob/living/carbon/human/owner = holder.owner
		if (!(owner.organHolder.left_eye || owner.organHolder.right_eye) || !ishuman(holder.owner))
			boutput(holder.owner, __blue("We have no eyes to eject!")) // what a terrifying fate you've given yourself
			return 1

		if (owner.organHolder.left_eye && owner.organHolder.right_eye) // if both eyes are available, pick one at random
			if (prob(50))
				qdel(owner.drop_organ("left_eye"))
			else
				qdel(owner.drop_organ("right_eye"))
		else if (owner.organHolder.left_eye)
			qdel(owner.drop_organ("left_eye"))
		else
			qdel(owner.drop_organ("right_eye"))

		holder.owner.visible_message(text("<span class='alert'><B>[holder.owner]'s eye shoots out and starts moving!</B></span>"))
		logTheThing("combat", holder.owner, use_mob, "drops an eyespider [use_mob] as a changeling [log_loc(holder.owner)].")

		var/mob/living/critter/changeling/eyespider/spider = new /mob/living/critter/changeling/eyespider(get_turf(owner.loc))

		if (use_mob.mind)
			use_mob.mind.transfer_to(spider)
		else if (use_mob.client)
			use_mob.client.mob = spider
		H.hivemind -= use_mob
		H.hivemind += spider
		spider.real_name = use_mob.real_name
		spider.hivemind_owner = H

		spider.Browse(grabResource("html/mindslave/eyespider.html"),"window=antagTips;size=600x400;title=Antagonist Tips")
		boutput(spider, "<h2><font color=red>You have reawakened to serve your host [holder.owner]! You must follow their commands!</font></h2>")
		boutput(spider, "<font color=red>You are a very small and weak creature that can fit into tight spaces, and see through walls. You are still connected to the hivemind.</font>")

		if (spider.mind && ticker.mode)
			if (!spider.mind.special_role)
				spider.mind.special_role = "eyespider"
			if (!(spider.mind in ticker.mode.Agimmicks))
				ticker.mode.Agimmicks += spider.mind
			spider.mind.master = owner.ckey

		if (owner.mind && owner.mind.current && spider.client)
			var/I = image(antag_changeling, loc = owner.mind.current)
			spider.client.images += I

		qdel(use_mob)
		return 0


// oh what's this? I copypasted it again, ooopsy! maybe refactor this in future  - mbc
/datum/targetable/changeling/legworm
	name = "Legworm"
	desc = "Detach one of your legs and bring it to life using one of the members of your hivemind."
	icon_state = "legworm"
	cooldown = 1200
	targeted = 0
	target_anything = 0
	human_only = 0
	pointCost = 6
	can_use_in_container = 1
	dont_lock_holder = 0

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, __red("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, __red("A slave cannot release a sub-form!."))
			return 1

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			if (O.client)
				eligible[O.real_name] = O

		if (eligible.len < 1)
			boutput(holder.owner, __red("There are no minds eligible for this ability. We need to absorb another."))
			return 1

		var/use_mob_name = input("Select the mind to transfer into the legworm: ", "Select Mind", null) as null|anything in eligible
		if (!use_mob_name)
			boutput(holder.owner, __blue("We change our mind."))
			return 1
		var/mob/dead/target_observer/hivemind_observer/use_mob = eligible[use_mob_name]

		var/mob/living/carbon/human/owner = holder.owner
		if (!(owner.limbs.l_leg || owner.limbs.r_leg) || !ishuman(holder.owner))
			boutput(holder.owner, __blue("We have no legs to detach!"))
			return 1

		if (owner.limbs.l_leg && owner.limbs.r_leg) //remove leg opposite of active hand
			if (owner.hand)
				owner.limbs.r_leg.delete()
			else
				owner.limbs.l_leg.delete()
		else if (owner.limbs.l_leg)
			owner.limbs.l_leg.delete()
		else
			owner.limbs.r_leg.delete()

		holder.owner.visible_message(text("<span class='alert'><B>[holder.owner]'s leg falls off and starts moving!</B></span>"))
		logTheThing("combat", holder.owner, use_mob, "drops a legworm [use_mob] as a changeling [log_loc(holder.owner)].")

		var/mob/living/critter/changeling/legworm/spider = new /mob/living/critter/changeling/legworm(get_turf(owner.loc))

		if (use_mob.mind)
			use_mob.mind.transfer_to(spider)
		else if (use_mob.client)
			use_mob.client.mob = spider
		H.hivemind -= use_mob
		H.hivemind += spider
		spider.real_name = use_mob.real_name
		spider.hivemind_owner = H

		spider.Browse(grabResource("html/mindslave/legworm.html"),"window=antagTips;size=600x400;title=Antagonist Tips")
		boutput(spider, "<h2><font color=red>You have reawakened to serve your host [holder.owner]! You must follow their commands!</font></h2>")
		boutput(spider, "<font color=red>You are a small creature that can deliver powerful kicks and fit into tight spaces. You are still connected to the hivemind.</font>")

		if (spider.mind && ticker.mode)
			if (!spider.mind.special_role)
				spider.mind.special_role = "legworm"
			if (!(spider.mind in ticker.mode.Agimmicks))
				ticker.mode.Agimmicks += spider.mind
			spider.mind.master = owner.ckey

		if (owner.mind && owner.mind.current && spider.client)
			var/I = image(antag_changeling, loc = owner.mind.current)
			spider.client.images += I

		qdel(use_mob)
		return 0

// Oh fuck. Did I copy paste this yet again? Damn. Maybe one day we'll get around to refactoring this. -fire
/datum/targetable/changeling/buttcrab
	name = "Buttcrab"
	desc = "You butt fall off and hivemind person become butt"
	icon_state = "buttcrab"
	cooldown = 600
	targeted = 0
	target_anything = 0
	human_only = 0
	pointCost = 1
	can_use_in_container = 1
	dont_lock_holder = 0

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, __red("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, __red("A slave cannot release a sub-form!."))
			return 1

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			if (O.client)
				eligible[O.real_name] = O

		if (eligible.len < 1)
			boutput(holder.owner, __red("There are no minds eligible for this ability. We need to absorb another."))
			return 1

		var/use_mob_name = input("Select the mind to transfer into the eyespider: ", "Select Mind", null) as null|anything in eligible
		if (!use_mob_name)
			boutput(holder.owner, __blue("We change our mind."))
			return 1
		var/mob/dead/target_observer/hivemind_observer/use_mob = eligible[use_mob_name]

		var/mob/living/carbon/human/owner = holder.owner
		if (!(owner.organHolder.butt) || !ishuman(holder.owner))
			boutput(holder.owner, __blue("We have no ass!")) // what a terrifying fate you've given yourself
			return 1

		qdel(owner.drop_organ("butt"))

		holder.owner.visible_message(text("<span class='alert'><B>[holder.owner]'s butt falls off and starts moving!</B></span>"))
		logTheThing("combat", holder.owner, use_mob, "drops a buttcrab [use_mob] as a changeling [log_loc(holder.owner)].")

		var/mob/living/critter/changeling/buttcrab/crab = new /mob/living/critter/changeling/buttcrab(get_turf(owner.loc))

		if (use_mob.mind)
			use_mob.mind.transfer_to(crab)
		else if (use_mob.client)
			use_mob.client.mob = crab
		H.hivemind -= use_mob
		H.hivemind += crab
		crab.real_name = use_mob.real_name
		crab.hivemind_owner = H

		crab.Browse(grabResource("html/mindslave/eyespider.html"),"window=antagTips;size=600x400;title=Antagonist Tips")
		boutput(crab, "<h2><font color=red>You have reawakened to serve your host [holder.owner]! You must follow their commands!</font></h2>")
		boutput(crab, "<font color=red>You are a very small, very smelly, and weak creature. You are still connected to the hivemind.</font>")

		if (crab.mind && ticker.mode)
			if (!crab.mind.special_role)
				crab.mind.special_role = "buttcrab"
			if (!(crab.mind in ticker.mode.Agimmicks))
				ticker.mode.Agimmicks += crab.mind
			crab.mind.master = owner.ckey

		if (owner.mind && owner.mind.current && crab.client)
			var/I = image(antag_changeling, loc = owner.mind.current)
			crab.client.images += I

		qdel(use_mob)
		return 0


/datum/targetable/changeling/hivesay
	name = "Speak Hivemind"
	desc = "Speak to your own collected minds telepathically."
	icon_state = "hivesay"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 0
	can_use_in_container = 1
	interrupt_action_bars = 0
	dont_lock_holder = 1
	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1

		var/message = html_encode(input("Choose something to say:","Enter Message.","") as null|text)
		if (!message)
			return
		logTheThing("say", holder.owner, holder.owner.name, "[message]")
		//logTheThing("diary", holder.owner, null, "(HIVEMIND): [message]", "hivesay")
		.= holder.owner.say_hive(message, holder)

		return 0

/datum/targetable/changeling/boot
	name = "Silence Hivemind Member"
	desc = "Remove a member of your hivemind at no penalty."
	icon_state = "silence"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 0
	pointCost = 0
	can_use_in_container = 1
	dont_lock_holder = 1
	interrupt_action_bars = 0

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1
		var/datum/abilityHolder/changeling/H = holder
		//Sanity check
		if (!istype(H))
			boutput(holder.owner, __red("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, __red("A slave cannot boot other members of the hivemind!."))
			return 1

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			eligible[O.real_name] = O

		if (eligible.len < 1)
			boutput(holder.owner, __red("There are no minds eligible for this ability."))
			return 1

		var/use_mob_name = input("Select the mind to silence: ", "Select Mind", null) as null|anything in eligible
		if (!use_mob_name)
			boutput(holder.owner, __blue("We change our mind."))
			return 1

		//RIP
		var/mob/dead/target_observer/hivemind_observer/use_mob = eligible[use_mob_name]
		H.hivemind -= use_mob
		boutput(use_mob, __red("You have been cut off from the hivemind by [holder.owner.real_name]!"))
		use_mob.boot()
		boutput(holder.owner, __red("You have silenced [use_mob_name]'s consciousness from your hivemind."))
		return 0


/datum/targetable/changeling/give_control
	name = "Grant Control to Hivemind Member"
	desc = "Allow one of the members of the hive mind to control our form."
	icon_state = "hivesay"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 0
	pointCost = 0
	can_use_in_container = 1
	dont_lock_holder = 1
	interrupt_action_bars = 0

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1
		var/datum/abilityHolder/changeling/H = holder
		//Sanity check
		if (!istype(H))
			boutput(holder.owner, __red("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, __red("A slave cannot relinquish control of the shared form!."))
			return 1

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			if(O.client)
				eligible += O

		if (eligible.len < 1)
			boutput(holder.owner, __red("There are no minds eligible for this ability."))
			return 1

		//Get a dirty HO. HA HA HA haaaa...
		var/mob/dead/target_observer/hivemind_observer/HO = input("Select the mind to grant control: ", "Select Mind", null) as null|mob in eligible
		if(!HO)
			boutput(holder.owner, __blue("We change our mind."))
			return 1

		//Do the actual control-granting here.
		logTheThing("combat", holder.owner, HO, "granted control of their body to [constructTarget(HO,"combat")] as a changeling!")
		//Transfer the owner's mind into a hivemind observer and grant it the recovery verb
		var/mob/dead/target_observer/hivemind_observer/master = H.insert_into_hivemind(H.owner)
		master.verbs += /mob/dead/target_observer/hivemind_observer/proc/regain_control
		H.master = master //Make it the controller of the mob
		boutput(master, __blue("We relinquish control of our form to [HO]!"))

		//Transfer the hivemind member's mind into the body.
		H.original_controller_name = HO.name
		H.original_controller_real_name = HO.real_name
		HO.mind.transfer_to(H.owner)
		H.transferOwnership(H.owner)
		H.temp_controller = HO

		boutput(H.owner, "<h1><font color=red>You have reawakened to serve your host [H.master]! You must follow their commands and protect our form!</font></h1>")
