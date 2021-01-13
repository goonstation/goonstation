datum/mind
	var/key
	var/ckey
	var/mob/current
	var/mob/virtual

	var/memory
	var/last_memory_time = 0 //Give a small delay when adding memories to prevent spam. It could happen!
	var/miranda // sec's miranda rights thingy.
	var/last_miranda_time = 0 // this is different than last_memory_time, this is when the rights were last SAID, not last CHANGED

	var/violated_hippocratic_oath = 0
	var/soul = 100 // how much soul we have left
	var/diabolical = 0 //are we some sort of demon or other spirit baddie?

	var/completed_objs = 0 // completed crew objectives
	var/all_objs = 0 // for sbux calcs

	var/assigned_role
	var/special_role
	var/late_special_role = 0
	var/random_event_special_role = 0

	// This used for dead/released/etc mindslaves and rogue robots we still want them to show up
	// in the game over stats. It's a list because former mindslaves could also end up as an emagged
	// cyborg or something. Use strings here, just like special_role (Convair880).
	var/list/former_antagonist_roles = list()

	var/list/datum/objective/objectives = list()
	var/is_target = 0
	var/list/purchased_traitor_items = list()
	var/list/traitor_crate_items = list()
	var/list/blob_absorb_victims = list()
	var/list/spy_stolen_items = list()

	var/datum/gang/gang = null //Associate a leader with their gang.

	//Ability holders.
	var/datum/abilityHolder/changeling/is_changeling = 0

	var/list/intrinsic_verbs = list()

	// For mindslave/vampthrall/spyslave master references, which are now tracked by ckey.
	// Mob references are not very reliable and did cause trouble with automated mindslave status removal
	// The relevant code snippets call a ckey -> mob reference lookup proc where necessary,
	// namely whois_ckey_to_mob_reference(mob.mind.master) (Convair880).
	var/master = null

	var/dnr = 0
	var/joined_observer = 0 //keep track of whether this player joined round as an observer (blocks them from bank payouts)

	var/luck = 50 // todo:
	var/sanity = 100 // implement dis

	var/handwriting = null

	var/obj/item/organ/brain/brain

	var/datum/bank_purchaseable/purchased_bank_item = 0 //set when player readies up
	var/join_time = 0
	var/last_death_time = 0 // look, you can live a dozen lives in one round if you're (un)lucky enough

	var/karma = 0 //fuck
	var/const/karma_min = -420
	var/const/karma_max = 69
	var/damned = 0 // If 1, they go to hell when are die

	// Capture when they die. Used in the round-end credits
	//var/icon/death_icon = null

	//avoid some otherwise frequent istype checks
	var/stealth_objective = 0

	New(mob/M)
		..()
		if (M)
			current = M
			key = M.key
			ckey = M.ckey
			src.handwriting = pick(handwriting_styles)
		src.last_death_time = world.timeofday // I DON'T KNOW SHUT UP YOU'RE NOT MY REAL DAD

	proc/transfer_to(mob/new_character)
		Z_LOG_DEBUG("Mind/TransferTo", "Transferring \ref[src] (\ref[current], [current]) ...")
		if (!new_character)
			Z_LOG_DEBUG("Mind/TransferTo", "No new_character given, transfer aborted")
			return

		Z_LOG_DEBUG("Mind/TransferTo", "New mob: \ref[new_character] ([new_character])")
		if (new_character.disposed)
			if (current)
				boutput(current, "You were about to be transferred into another body, but that body was pending deletion! This may fuck everything up so if it does dial 1-800-CODER.")
				message_admins("Tried to transfer mind of mob [current] (\ref[current], [key_name(current)]) to qdel'd mob [new_character] (\ref[new_character]) God damnit. Un-qdeling the mob and praying (this will probably fuck up).")
				new_character.disposed = 0
			else
				message_admins("Tried to transfer mind [src] (\ref[src]) to qdel'd mob [new_character] (\ref[new_character]) FIX THIS SHIT")

			Z_LOG_ERROR("Mind/TransferTo", "Trying to transfer to a mob that's in the delete queue! Jesus fucking christ.")
			//CRASH("Trying to transfer to a mob that's in the delete queue!")

		if (current)
			if(current.client)
				current.removeOverlaysClient(current.client)
				tgui_process.on_transfer(current, new_character)
				new_character.lastKnownIP = current.client.address
			current.mind = null

		new_character.mind = src
		current = new_character

		new_character.key = key

		if(current.client)
			current.addOverlaysClient(current.client)

		Z_LOG_DEBUG("Mind/TransferTo", "Mind swapped, moving verbs")


		//if (is_changeling)
		//	new_character.make_changeling()

		for (var/intrinsic_verb in intrinsic_verbs)
			Z_LOG_DEBUG("Mind/TransferTo", "Adding [intrinsic_verb]")
			new_character.verbs += intrinsic_verb


		//transfer abilholder to me self
		if (new_character.abilityHolder)
			Z_LOG_DEBUG("Mind/TransferTo", "Transferring abilityHolder")
			new_character.abilityHolder.transferOwnership(new_character)


		if (isrobot(new_character))
			var/mob/living/silicon/robot/R = new_character
			R.show_laws()
		Z_LOG_DEBUG("Mind/TransferTo", "Complete")


	proc/swap_with(mob/target)
		var/datum/mind/other_mind = target.mind
		var/mob/my_old_mob = current

		if (other_mind)	//They have a mind so we can do this nicely
			if (isobserver(current))
				current:delete_on_logout = 0
			if (isobserver(target))
				target:delete_on_logout = 0

			var/mob/temp = new/mob(src.current.loc) //We need to put whoever we're swapping with somewhere
			other_mind.transfer_to(temp)			//So now we put them there
			src.transfer_to(target)					//Then I go into their head
			other_mind.transfer_to(my_old_mob)		//And they go into my old one
			qdel(temp)								//Not needed any more

		else if (!target.client && !target.key) 	//They didn't have a mind and didn't have an associated player, AKA up for grabs
			src.transfer_to(target)

		else	//The Ugly Way
			if (isobserver(current))
				current:delete_on_logout = 0
			if (isobserver(target))
				target:delete_on_logout = 0

			var/mob/temp = new/mob(src.current.loc) //We need to put whoever we're swapping with somewhere
			temp.key = target.key					//So now we put them there
			src.transfer_to(target)					//Then I go into their head
			my_old_mob.key = temp.key
			qdel(temp)								//Not needed any more

		if (isobserver(current))
			current:delete_on_logout = 1
		if (isobserver(target))
			target:delete_on_logout = 1

	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><HR>"
		output += memory

		if (objectives.len>0)
			output += "<HR><B>Objectives:</B>"

			var/obj_count = 1
			for (var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]<br>"
				obj_count++

		// Added (Convair880).
		if (recipient.mind.master)
			var/mob/mymaster = whois_ckey_to_mob_reference(recipient.mind.master)
			if (mymaster)
				output+= "<br><b>Your master:</b> [mymaster.real_name]"

		recipient.Browse(output,"window=memory;title=Memory")

	proc/set_miranda(new_text)
		miranda = new_text

	proc/show_miranda(mob/recipient)
		var/output = "<B>[current.real_name]'s Miranda Rights</B><HR>[miranda]"

		recipient.Browse(output,"window=miranda;title=Miranda Rights")

	proc/register_death()
		var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
		src.store_memory("Time of death: [tod]", 0)
		// stuff for critter respawns
		src.last_death_time = world.timeofday

	disposing()
		logTheThing("debug", null, null, "<b>Mind</b> Mind for \[[src.key ? src.key : "NO KEY"]] deleted!")
		Z_LOG_DEBUG("Mind/Disposing", "Mind \ref[src] [src.key ? "([src.key])" : ""] deleted")
		src.brain?.owner = null
		..()

/datum/mind/proc/add_karma(how_much)
	src.karma += how_much
