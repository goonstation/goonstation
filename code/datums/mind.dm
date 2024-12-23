datum/mind
	var/key
	var/ckey
	var/displayed_key
	var/mob/current
	var/mob/virtual

	/// stores valuable things about the mind's memory
	var/memory
	/// stores custom notes set by the player
	var/cust_notes
	var/list/datum/dynamic_player_memory/dynamic_memories = list()
	var/remembered_pin = null
	var/last_memory_time = 0 //Give a small delay when adding memories to prevent spam. It could happen!
	var/miranda // sec's miranda rights thingy.

	var/violated_hippocratic_oath = 0
	var/soul = 100 // how much soul we have left
	var/diabolical = 0 //are we some sort of demon or other spirit baddie?

	var/completed_objs = 0 // completed crew objectives
	var/all_objs = 0 // for sbux calcs

	var/assigned_role
	var/special_role
	var/late_special_role = 0
	var/random_event_special_role = 0

	/// A list of every antagonist datum that we have.
	var/list/datum/antagonist/antagonists = list()
	/// A list of every antagonist datum subordinate to this mind.
	var/list/datum/antagonist/subordinate/subordinate_antagonists = list()

	//Gang variables
	var/obj/item/device/pda2/originalPDA //! The PDA that this crewmember started with - for gang PDA messages

	// This used for dead/released/etc mindhacks and rogue robots we still want them to show up
	// in the game over stats. It's a list because former mindhacks could also end up as an emagged
	// cyborg or something. Use strings here, just like special_role (Convair880).
	var/list/former_antagonist_roles = list()

	var/list/datum/objective/objectives = list()
	var/is_target = 0

	var/list/intrinsic_verbs = list()

	var/handwriting = null
	var/color = null

	var/obj/item/organ/brain/brain

	var/datum/bank_purchaseable/purchased_bank_item = 0 //set when player readies up
	var/join_time = 0

	var/karma = 0 //fuck
	var/const/karma_min = -420
	var/const/karma_max = 69
	var/damned = 0 //! If 1, they go to hell when are die

	var/datum/personal_summary/personal_summary

	var/show_respawn_prompts = TRUE

	New(mob/M)
		..()
		if (M)
			current = M
			key = M.key
			ckey = M.ckey
			displayed_key = M.key
			src.handwriting = pick(handwriting_styles)
			src.color = pick_string("colors.txt", "colors")
			SEND_SIGNAL(src, COMSIG_MIND_ATTACH_TO_MOB, M)

	proc/transfer_to(mob/new_character)
		Z_LOG_DEBUG("Mind/TransferTo", "Transferring \ref[src] (\ref[current], [current]) ...")
		if (!new_character)
			Z_LOG_DEBUG("Mind/TransferTo", "No new_character given, transfer aborted")
			return

		if (new_character == src.current)
			CRASH("Tried to transfer mind of [identify_object(src.current)] to itself.")

		Z_LOG_DEBUG("Mind/TransferTo", "New mob: \ref[new_character] ([new_character])")
		if (new_character.disposed)
			boutput(current, "<h3 class='alert'>You were about to be transferred into another body, but that body was pending deletion! You're a ghost now instead! Adminhelp if this is a problem.</h3>")
			message_admins("Tried to transfer mind of mob [identify_object(current)] to qdel'd mob [identify_object(new_character)] God damnit.")
			var/mob/dead/observer/obs = new(src.current)
			src.transfer_to(obs)

			Z_LOG_ERROR("Mind/TransferTo", "Tried to transfer mind [(current ? "of mob " + key_name(current) : src)] to qdel'd mob [new_character].")
			CRASH("Tried to transfer mind [identify_object(src)] to qdel'd mob [identify_object(new_character)].")

		if (new_character.client)
			if (current)
				boutput(current, "<h3 class='alert'>You were about to be transferred into another body, but that body was occupied!</h3>")
				var/errmsg = "Tried to transfer mind of mob [identify_object(current)] to mob with an existing client [identify_object(new_character)]"
				message_admins(errmsg)
				CRASH(errmsg)
			else
				message_admins("Tried to transfer mind [src] to mob with an existing client [new_character] (\ref[new_character]).")
			Z_LOG_ERROR("Mind/TransferTo", "Tried to transfer mind [(current ? "of mob " + key_name(current) : src)] to mob with an existing client [new_character] [key_name(new_character)])")
			return
		var/mob/old_mob = null
		if (current)
			old_mob = current
			if(current.client)
				current.removeOverlaysClient(current.client)
				tgui_process.on_transfer(current, new_character)
				new_character.lastKnownIP = current.client.address
			current.oldmind = src
			current.mind = null
			SEND_SIGNAL(src, COMSIG_MIND_DETACH_FROM_MOB, current, new_character)

		new_character.oldmind = new_character.mind
		new_character.mind = src
		current = new_character

		new_character.key = key

		if(current.client)
			current.addOverlaysClient(current.client)

		Z_LOG_DEBUG("Mind/TransferTo", "Mind swapped, moving verbs")

		for (var/intrinsic_verb in intrinsic_verbs)
			Z_LOG_DEBUG("Mind/TransferTo", "Adding [intrinsic_verb]")
			new_character.verbs += intrinsic_verb


		//transfer abilholder to me self
		if (new_character.abilityHolder)
			Z_LOG_DEBUG("Mind/TransferTo", "Transferring abilityHolder")
			new_character.abilityHolder.transferOwnership(new_character)

		if (global.current_state == GAME_STATE_FINISHED)
			if (!new_character.abilityHolder)
				new_character.add_ability_holder(/datum/abilityHolder/generic)
			new_character.addAbility(/datum/targetable/crew_credits)
		Z_LOG_DEBUG("Mind/TransferTo", "Complete")

		SEND_SIGNAL(src, COMSIG_MIND_ATTACH_TO_MOB, current, old_mob)


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

	proc/get_player()
		RETURN_TYPE(/datum/player)
		if(ckey)
			. = make_player(ckey)

	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/remove_dynamic_memories_by_type(dynamic_memory_type)
		for (var/datum/dynamic_player_memory/dynamic_memory in src.dynamic_memories)
			if (dynamic_memory.type == dynamic_memory_type)
				src.dynamic_memories -= dynamic_memory

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><br>"
		output += memory

		if (src.cust_notes)
			output += "<HR><B>Notes:</B><br>"
			output += replacetext(src.cust_notes, "\n", "<br>")

		for (var/datum/dynamic_player_memory/dynamic_memory in src.dynamic_memories)
			output += dynamic_memory.memory_text

		if (objectives.len>0)
			output += "<HR><B>Objectives:</B><br>"

			var/obj_count = 1
			for (var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]<br>"
				obj_count++

		// Added (Convair880).
		var/datum/mind/master = recipient.mind.get_master()
		if (master?.current)
			output += "<br><b>Your master:</b> [master.current.real_name]"

		tgui_message(recipient, output, "Notes")

	proc/set_miranda(new_text)
		miranda = new_text

	proc/get_miranda()
		if (islist(src.miranda)) //isproc machine broke, so uh just wrap your procs in a list when you pass them here to distinguish them from strings :)
			return call(src.miranda[1])()
		return src.miranda

	proc/show_miranda(mob/recipient)
		var/output = "<B>[current.real_name]'s Miranda Rights</B><HR>[src.get_miranda()]"

		recipient.Browse(output,"window=miranda;title=Miranda Rights")

	proc/register_death()
		var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
		src.store_memory("Time of death: [tod]", 0)
		// stuff for critter respawns
		src.get_player()?.last_death_time = world.timeofday

	/// Returns whether this mind is a non-pseudo antagonist.
	proc/is_antagonist()
		// Handles pre-round antagonist assignments utilising `special_role`.
		if (global.current_state < GAME_STATE_PLAYING)
			return !!src.special_role

		for (var/datum/antagonist/A as anything in src.antagonists)
			if (!A.pseudo)
				return TRUE

		return FALSE

	/// Gets an existing antagonist datum of the provided ID role_id.
	proc/get_antagonist(role_id)
		RETURN_TYPE(/datum/antagonist)
		for (var/datum/antagonist/A as anything in src.antagonists)
			if (A.id == role_id)
				return A
		return null

	///Returns a human readable english list of all antagonsit roles this person has
	proc/list_antagonist_roles(include_pseudo = FALSE)
		var/list/valid_antags = list()
		for (var/datum/antagonist/antag as anything in src.antagonists)
			if (!include_pseudo && antag.pseudo)
				continue
			valid_antags += antag.display_name
		if (!length(valid_antags))
			return null
		return english_list(valid_antags)

	/// Attempts to add the antagonist datum of ID role_id to this mind.
	proc/add_antagonist(role_id, do_equip = TRUE, do_objectives = TRUE, do_relocate = TRUE, silent = FALSE, source = ANTAGONIST_SOURCE_OTHER, respect_mutual_exclusives = TRUE, do_pseudo = FALSE, do_vr = FALSE, late_setup = FALSE)
		// Check for mutual exclusivity for real antagonists
		if (respect_mutual_exclusives && !do_pseudo && !do_vr && length(src.antagonists))
			for (var/datum/antagonist/A as anything in src.antagonists)
				if (A.mutually_exclusive)
					return FALSE
		// To avoid wacky shenanigans, refuse to add multiple types of the same antagonist
		if (!isnull(src.get_antagonist(role_id)) && !do_vr)
			return FALSE
		for (var/V in concrete_typesof(/datum/antagonist))
			var/datum/antagonist/A = V
			if (initial(A.id) == role_id)
				var/datum/antagonist/new_datum = new A(src, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup)
				if (!new_datum || QDELETED(new_datum))
					return FALSE
				return TRUE
		return FALSE

	/// Attempts to add the subordinate antagonist datum of ID role_id to this mind.
	proc/add_subordinate_antagonist(role_id, do_equip = TRUE, do_objectives = TRUE, do_relocate = TRUE, silent = FALSE, source = ANTAGONIST_SOURCE_CONVERTED, do_pseudo = FALSE, do_vr = FALSE, late_setup = FALSE, master)
		if (!master)
			return FALSE
		// To avoid wacky shenanigans
		if (!isnull(src.get_antagonist(role_id)) && !do_vr)
			src.remove_antagonist(role_id, ANTAGONIST_REMOVAL_SOURCE_OVERRIDE)
		for (var/V in concrete_typesof(/datum/antagonist/subordinate))
			var/datum/antagonist/subordinate/A = V
			if (initial(A.id) == role_id)
				var/datum/antagonist/subordinate/new_datum = new A(src, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
				if (!new_datum || QDELETED(new_datum))
					return FALSE
				return TRUE
		return FALSE

	proc/add_generic_antagonist(role_id, display_name, do_equip = TRUE, do_objectives = TRUE, do_relocate = TRUE, silent = FALSE, source = ANTAGONIST_SOURCE_OTHER, respect_mutual_exclusives = TRUE, do_pseudo = FALSE, do_vr = FALSE, late_setup = FALSE)
		if (!role_id || !display_name)
			return FALSE
		// Check for mutual exclusivity for real antagonists.
		if (respect_mutual_exclusives && !do_pseudo && !do_vr && length(src.antagonists))
			for (var/datum/antagonist/A as anything in src.antagonists)
				if (A.mutually_exclusive)
					return FALSE
		// Refuse to add multiple types of the same antagonist.
		if (!isnull(src.get_antagonist(role_id)) && !do_vr)
			return FALSE
		for (var/V in concrete_typesof(/datum/antagonist/generic))
			var/datum/antagonist/generic/A = V
			if (initial(A.id) == role_id)
				var/datum/antagonist/generic/new_datum = new A(src, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, role_id, display_name)
				if (!new_datum || QDELETED(new_datum))
					return FALSE
				return TRUE
		var/datum/antagonist/generic/new_datum = new /datum/antagonist/generic(src, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, role_id, display_name)
		if (!QDELETED(new_datum))
			return TRUE
		return FALSE

	/// Attempts to remove existing antagonist datums of ID `role` from this mind, or if provided, a specific instance of an antagonist datum.
	proc/remove_antagonist(role, source = null, take_gear = TRUE)
		var/datum/antagonist/antagonist_role
		if (istype(role, /datum/antagonist))
			antagonist_role = role

		else if (istext(role))
			for (var/datum/antagonist/A as anything in src.antagonists)
				if (A.id == role)
					antagonist_role = A
					break

		if (!antagonist_role)
			return FALSE
		if (antagonist_role.faction)
			LAZYLISTREMOVE(antagonist_role.owner.current.faction, antagonist_role.faction)
		antagonist_role.remove_self(take_gear, source)
		src.antagonists.Remove(antagonist_role)
		var/mob/living/carbon/human/H = src.current
		if (istype(H))
			H.update_arrest_icon() // for derevving
		if (!length(src.antagonists) && src.special_role == antagonist_role.id)
			src.special_role = null
			ticker.mode.traitors.Remove(src)
			ticker.mode.Agimmicks.Remove(src)
		qdel(antagonist_role)

		return TRUE

	/// Removes ALL antagonists from this mind. Use with caution!
	proc/wipe_antagonists()
		for (var/datum/antagonist/A as anything in src.antagonists)
			A.remove_self(TRUE)
			src.antagonists.Remove(A)
			qdel(A)
		src.special_role = null
		ticker.mode.traitors.Remove(src)
		ticker.mode.Agimmicks.Remove(src)
		return length(src.antagonists) <= 0

	disposing()
		logTheThing(LOG_DEBUG, null, "<b>Mind</b> Mind for \[[src.key ? src.key : "NO KEY"]] deleted!")
		Z_LOG_DEBUG("Mind/Disposing", "Mind \ref[src] [src.key ? "([src.key])" : ""] deleted")
		src.brain?.owner = null
		if(src.current)
			SEND_SIGNAL(src, COMSIG_MIND_DETACH_FROM_MOB, current)
		..()

	/// Output of this gets logged when the mind is added to the game ticker
	proc/on_ticker_add_log()
		var/list/traits = list()
		for(var/trait_id in src.current.traitHolder.traits)
			var/datum/trait/trait = src.current.traitHolder.traits[trait_id]
			traits += trait.name
		. = "<br>Traits: [jointext(traits, ", ")]"

/datum/mind/proc/add_karma(how_much)
	src.karma += how_much
	src.karma = clamp(src.karma, karma_min, karma_max)
