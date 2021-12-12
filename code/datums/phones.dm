
// lets see if this makes ends up any sense wheeeeeee
// god help my newbie coder soul


/datum/phone
	var/atom/holder = null // the atom we belong to; set type in child datum so you can call necessary procs
	var/phoneName = null // This is the name the user will see when we're displayed in a contact list
	var/phoneID = null // unique identifier based on netIDs, and can be used as a net ID if necessary, or overidden to share with its holder
	var/phoneCallType = /datum/phonecall // override var for your phone datum to generate a different phonecall datum

	var/unlisted = FALSE
	var/maxConnected = 1 // limit of how many contacts can be in a phonecall with us, not including us
	var/prioritizeOurMax = FALSE // if TRUE other phones will ignore their maxConnected when they try to join a phonecall we're hosting

	var/datum/phonecall/incomingCall // who's calling us???
	var/datum/phonecall/currentPhoneCall = null

	var/canVoltron = FALSE
	var/canVape = FALSE // you better make this true when possible, dweeb
	var/canTalkAcrossZLevels = FALSE

	// These vars are for enabling or disabling certain elements of the UI, such as hangup buttons
	var/elementSettings = list(
		"hangupButton" = TRUE,
		"groupCallControl" = FALSE
	)

	var/sound/dialtone = "sound/machines/phones/phone_busy.ogg"

	/// Call as New(src)
	New(var/atom/creator)
		..()
		holder = creator // phoneName should be assigned elsewhere or by just overriding the var
		phoneID = format_net_id("\ref[src]")
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()



	/// Starts and automatically joins a phone call
	proc/startPhoneCall(var/call_list, var/forceStart, var/doGroupCall = FALSE) // call_list does not have to be a list, can be just a ref to a phone datum
		if(currentPhoneCall)
			if(forceStart)
				disconnectFromCall()
			else return
		if(!call_list && !forceStart)
			return
		currentPhoneCall = new phoneCallType(src, maxConnected, prioritizeOurMax, doGroupCall)
		if(!islist(call_list))
			. += inviteToCall(call_list)
		else
			for(var/datum/phone/contact in call_list) // we let our proc caller know if we're successfully ringing them or not, and how many people we were able to start ringing
				. += inviteToCall(contact) // (we can just add the returned 1 or 0 from inviteToCall() to . and if even just one return is true, the final return can be read as true or for the target count)
		if(!.)
			callFailed()



	/// Rejects an incoming phone call and alerts the phonecall datum of this
	proc/denyPhoneCall(var/datum/phonecall/targetPhoneCall)
		incomingCall.callDenied(src)


	/// Called when we're hosting a phone call and someone denies our invitation (very rude). Or maybe their line was just busy.
	proc/callFailed(var/datum/phone/denyingPhone) // no need to reference the phonecall when we're hosting it, but it might be helpful to know who denied the call, if applicable
		if(currentPhoneCall.isGroupCall) // Note: denyingPhone *can* be null
			return
		handleSound(dialtone,50,0)


	/// Signals to a datum/phonecall that we'd like to join the phonecall
	proc/joinPhoneCall(var/datum/phonecall/targetPhoneCall)
		if(currentPhoneCall)
			return
		targetPhoneCall.tryConnect(src)


	/// Procs whenever we successfully join a call
	proc/onJoin(var/datum/phonecall/joinedPhoneCall)
		currentPhoneCall = joinedPhoneCall
		incomingCall = null
		return


	/// Procs whenever a phone joins a call we're in
	proc/onRemoteJoin(var/datum/phone/connectedPhone)


	/// Signals to a datum/phonecall that we'd like to leave our current phonecall; aka we're hanging up
	proc/disconnectFromCall()
		currentPhoneCall?.disconnect(src)


	/// Procs whenever we're disconnected from our current call or an incoming one
	proc/onDisconnect(var/datum/phonecall/leftPhoneCall)
		currentPhoneCall = null
		incomingCall = null


	/// Procs whenever someone leaves a call we're in; NOT when they deny the call, but when they hang up
	proc/onRemoteDisconnect(var/datum/phone/disconnectedPhone)


	// Ripped straight from obj/item/proc/talk_into(), hopefully contains enough information for a wide variety of override cases
	proc/sendSpeech(mob/M as mob, text, secure, real_name, lang_id)
		if(!currentPhoneCall)
			return
		currentPhoneCall.relaySpeech(src, M, text, secure, real_name, lang_id)


	/// Called by currentPhoneCall whenever it's relaying speech to us. Override in child proc to make this actually do something
	proc/speechReceived(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)


	/// You need to override this in your child phone datum to actually play sound. All attempts by this datum to play sound will route through here.
	proc/handleSound(soundin, vol as num, vary, extrarange as num, pitch, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
		return // Functions identically to playsound(), save for lack of source



	/// Returns a list of phone addresses that we can contact. By default will just display all phones that aren't Unlisted
	proc/getContacts()
		var/contacts = list()
		for (var/datum/phone/P in by_type[/datum/phone])
			if (P.canContact(src) && (P != src))
				contacts += P // we ask P if we can contact it
		return contacts


	/// Used by getContacts() to determine whether or not it should include this phone address in its return statement. queryingPhone for potential override usage
	proc/canContact(var/datum/phone/queryingPhone)
		. = !unlisted && !qdeled && !holder.qdeled
		return // basic checks to make sure we exist, the thing holding us exists, and whether or not we want to show up on contact lists


	/// Returns the phone associated with the provided ID, or null if it can't find it.
	proc/getRefFromID(var/id)
		for(var/datum/phone/contact in by_type[/datum/phone])
			if(contact.phoneID == id)
				return contact


	/// Returns the same list as getContacts() except instead of refs its the phones' phoneName associated with phoneID. Yes it's a lengthy proc name fuck you.
	proc/getContactIDToNameList()
		var/list/L = new()
		for(var/datum/phone/contact in getContacts())
			L += contact.phoneID
			L[contact.phoneID] = contact.phoneName
		return L


	/// Handles logic needed for inviting a target phone to a call, whether it be a group call or not
	proc/inviteToCall(var/datum/phone/target)
		if(target.receiveInvite(src, currentPhoneCall))
			currentPhoneCall.pendingMembers += target
			return TRUE // we let the proc that called us know if they were successfully added
		return FALSE


	/// Handles logic needed for when we receive an invitation to a call. If you override, make sure it will return TRUE or FALSE if the invitation was successful or not.
	proc/receiveInvite(var/datum/phone/caller, var/datum/phonecall/pendingCall)
		if(incomingCall || currentPhoneCall)
			return FALSE
		incomingCall = pendingCall
		return TRUE





	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "PhoneDefault")
			ui.open()

	ui_data(mob/user)
		var/contactList = getContactIDToNameList()
		var/list/contacts = list()
		for(var/contact in contactList)
			var/id = contact
			var/name = contactList[id] // we build a list of associative lists so js can keep track of which id goes with which name
			contacts += list(list("id" = id, "name" = name))
		. = list(
			"contactList" = contacts,
			"phoneCallMembers" = currentPhoneCall?.members,
			"pendingCallMembers" = currentPhoneCall?.pendingMembers,
			"callHost" = currentPhoneCall?.host,
			"phonecallID" = currentPhoneCall?.phonecallID,
			"elementSettings" = elementSettings)

	ui_host()
		return holder

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if("makeCall")
				var/datum/phone/contact = getRefFromID(params["target"])
				if(!(contact in getContacts()))
					return // double-checking that the contact should actually be visible to our phone and the user didn't somehow exploit another phone's ID in
				startPhoneCall(contact)
			if("leaveCall")
				disconnectFromCall()

	/// Handles what should happen when someone vapes through us. You might need to override this to change *where* the vape comes from, if holder is something like a pda module
	proc/onVape(var/datum/reagents/_buffer, var/obj/item/reagent_containers/vape/vape, var/mob/living/sourceMob, var/datum/phone/sourcePhone)
		smoke_reaction(_buffer, vape.range, get_turf(holder))
		particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(holder.loc, NORTH))
		particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(holder.loc, SOUTH))
		particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(holder.loc, EAST))
		particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(holder.loc, WEST))
		SPAWN_DBG(0) //vape is just the best for not annoying crowds I swear
			vape.smoke.start()
			sleep(1 SECOND)
		//Sample text for what you might wanna use for your proc override
		//boutput(user,"<span class='alert'><B>[sourceMob] blows a cloud of smoke right through the phone! What a total [pick("dork","loser","dweeb","nerd","useless piece of shit","dumbass")]!</B></span>")


	proc/onVoltron(var/mob/living/sourceMob, var/datum/phone/sourcePhone)

// Be careful overriding this too much, make sure you account for other phone datums that may try to connect to this!
/// Handles routing all the speech, data, and members in a phone call
/datum/phonecall
	var/doCustomNew = FALSE // if you wanna override New() then set this to true; ..() will only call the parent ..() in this case
	var/disposing = FALSE

	var/phonecallID = null // in case someone needs to refer to a specific call in a UI, we'll have a unique ID for it

	var/members = list() // Support for 3+ contact calls! Number of connected phones is capped by maxMembers
	var/pendingMembers = list() // sometimes it's useful to know who's being rung up but hasn't connected yet
	var/datum/phone/host = null // who's hosting this party?!

	var/maxMembers = null // how many people can be in this call?
	var/overrideMax = FALSE // if true, phones will ignore their maxMembers value
	var/isGroupCall = null // we can see our host's call max but what if they don't want to do a group call?



	New(creator, max, priority, groupCall)
		..()
		initializeVars(creator, max, priority, groupCall)


	/// Override this instead of New()
	proc/initializeVars(creator, max, priority, groupCall)
		host = creator
		maxMembers = max
		overrideMax = priority
		isGroupCall = groupCall
		phonecallID = format_net_id("\ref[src]")


	disposing()
		disposing = TRUE
		var/allMembers = members + pendingMembers
		for(var/datum/phone/contact in allMembers)
			disconnect(contact)
		disconnect(host)
		..()



	/// Handles logic for when a phone agrees to an invitation to this call
	proc/tryConnect(var/datum/phone/target)
		if(length(members) > maxMembers)
			return FALSE
		if((length(members) > target.maxConnected) && !overrideMax)
			return FALSE
		if(target in members)
			return FALSE
		if((src != target.currentPhoneCall) && !isnull(target.currentPhoneCall))
			return FALSE
		members += target
		pendingMembers -= target
		target.onJoin(src)
		for(var/datum/phone/member in members)
			member.onRemoteJoin(target)
		host.onRemoteJoin(target)
		return TRUE


	/// Handles logic for when a phone in pendingMembers denies our call
	proc/callDenied(var/datum/phone/denyingPhone)
		host.callFailed(denyingPhone)
		disconnect(denyingPhone)


	/// Handles logic for what we should do when a phone wants to disconnect from the call
	proc/disconnect(var/datum/phone/target)
		if(isnull(target) || (!(target in members) && !(target in pendingMembers) && target != host))
			return
		target.onDisconnect(src) // we let them know what /phonecall datum is calling this proc, just in case an override wants to use it
		if(host == target)
			host = null // we set this now so that when we call dispose() it won't try to disconnect the host again in a loop
			for(var/datum/phone/member in members)
				member.onRemoteDisconnect(host) // we only wanna play this once per person
			dispose() // the phonecall can't exist if we stop hosting!
		else
			pendingMembers -= target
			members -= target
			if(!disposing)
				for(var/datum/phone/member in members)
					member.onRemoteDisconnect(target)
				host.onRemoteDisconnect(target)



	/// Relays incoming speech from call members to the rest of the members in the call
	proc/relaySpeech(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)
		var/recipients = members + host
		recipients -= source
		for(var/datum/phone/target in recipients)
			target.speechReceived(source, M, text, secure, real_name, lang_id)


	/// The coolest proc, responsible for routing the reagents to the various onVape() procs for phone members where canVape is true. Returns the # of phones successfully vaped into
	proc/relayVape(var/obj/item/reagent_containers/vape/vape, var/mob/living/sourceMob, var/datum/phone/sourcePhone) // doing this to group calls is a terrible idea :)
		. = 0 // how many people did we prank with our sick vape??
		if((sourcePhone != host) && !(sourcePhone in members))
			return
		var/recipients = members + host
		recipients -= sourcePhone
		for(var/datum/phone/target in recipients)
			if(!target.canVape)
				recipients -= target

		if(!length(recipients))
			return

		vape.reagents.trans_to(sourceMob, 5)

		var/amountToTransfer = 5 / length(recipients)

		for(var/datum/phone/target in recipients)
			var/datum/reagents/buffer = new /datum/reagents(5)
			buffer.my_atom = vape // honestly just copy/pasted this since im not too familiar with reagent code oops
			vape.reagents.trans_to_direct(buffer, amountToTransfer)
			target.onVape(buffer, vape, sourceMob, sourcePhone)
			.++



/datum/phone/test

	speechReceived(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)
		var/obj/item/testPhone/ourHolder = holder
		ourHolder.outputSpeech(source, M, text, secure, real_name, lang_id)

/obj/item/testPhone
	name = "TEST PHONE"
	desc = "PHONE!!"
	icon = 'icons/obj/cellphone.dmi'
	icon_state = "cellphone-on"
	flags = TALK_INTO_HAND
	var/datum/phone/test/phoneDatum = null
	var/datum/tgui/ui = null

	New()
		..()
		phoneDatum = new(src)

	attack_self(mob/user)
		. = ..()
		ui = phoneDatum.ui_interact(user, ui)

	talk_into(mob/M as mob, text, secure, real_name, lang_id)
		phoneDatum.sendSpeech(M, text, secure, real_name, lang_id)

	proc/outputSpeech(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)
		var/mob/user
		if(!istype(src.loc, /mob))
			return
		user = src.loc
		//var/processed = "<span class='game say'><span class='bold'>[M.name]</span> says, <span class='message'>\"[text[1]]\"</span></span>"
		user.show_message(text, 2)

/obj/item/testPhone/testPhone2
	name = "TEST PHONE 2"

/obj/item/testPhone/testPhone3
	name = "TEST PHONE 3"
