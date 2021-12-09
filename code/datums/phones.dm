
// lets see if this makes ends up any sense wheeeeeee
// god help my newbie coder soul

/datum/phone
	var/atom/holder = null // set type in child datum so you can call necessary procs
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

	/// Call as New(src)
	New(var/atom/creator)
		..()
		holder = creator
		if (!phoneName)
			phoneName = creator.name
		phoneID = format_net_id("\ref[src]")
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	/// Starts and automatically joins a phone call
	proc/startPhoneCall(var/call_list, var/forceStart) // does not have to be a list, can be just a ref to a phone datum
		if(currentPhoneCall) // forceStart will boot us from any active call
			if(forceStart)
				disconnectFromCall() // TODO: MAKE PROC FOR DENYING PHONE CALL AND ONDENY() OR WHATEVER
			else return
		if(!call_list && !forceStart)
			return
		currentPhoneCall = new phoneCallType(src, maxConnected, prioritizeOurMax)
		if(!islist(call_list))
			return inviteToCall(call_list)
		for(var/datum/phone/contact in call_list)
			. += inviteToCall(contact) // we let our proc caller know if we're successfully ringing them or not, and how many people we were able to start ringing
			// (since true returns as 1, we can just add the return to . and if even just one return is true, the final return can be read as true or for the target count)

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

	/// Signals to a datum/phonecall that we'd like to leave our current phonecall
	proc/disconnectFromCall()
		if(!currentPhoneCall)
			return
		currentPhoneCall.disconnect(src)

	/// Procs whenever we're disconnected
	proc/onDisconnect(var/datum/phonecall/leftPhoneCall)
		currentPhoneCall = null

	// Ripped straight from obj/item/proc/talk_into(), hopefully contains enough information for a wide variety of override cases
	proc/sendSpeech(mob/M as mob, text, secure, real_name, lang_id)
		if(!currentPhoneCall)
			return
		currentPhoneCall.relay_speech(src, M, text, secure, real_name, lang_id)


	/// Does nothing by itself, make a child of datum/phone which can call your atom with this
	proc/speechReceived(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)


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


	/// Returns a list of phone addresses that we can contact. By default will just display all phones that aren't Unlisted
	proc/getContacts()
		var/contacts = list()
		for (var/datum/phone/P in by_type[/datum/phone])
			if (P.canContact() && (P != src))
				contacts += P
		return contacts


	/// Used by getContacts() to determine whether or not it should include this phone address in its return statement
	proc/canContact()
		. = !unlisted
		return

	proc/inviteToCall(var/datum/phone/target)
		if(target.receiveInvite(src, currentPhoneCall))
			currentPhoneCall.pendingMembers += target
			return TRUE // we let the proc that called us know if they were successfully added
		return FALSE

	proc/receiveInvite(var/datum/phone/caller, var/datum/phonecall/incomingCall)
		if(incomingCall || incomingCall)
			return FALSE
		incomingCall = incomingCall // we wanna let the other phone know if we're now ringing for them!
		return TRUE

	/// Default UI, override/copy+paste at your leisure
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
			var/name = contactList[id] // we give js this list of associative lists so it knows how to break up the info given
			contacts += list(list("id" = id, "name" = name)) //todo: write a better comment
		. = list( // if you're reading this, please god yell at nex, thank you
			"contactList" = contacts,
			"phoneCallMembers" = currentPhoneCall?.members,
			"pendingCallMembers" = currentPhoneCall?.pendingMembers,
			"callHost" = currentPhoneCall?.host,
			"phonecallID" = currentPhoneCall?.phonecallID
		)
	ui_host()
		return holder
/*
contact[1], idk what else
be sure to have it return id
*/
	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if("makeCall")
				var/datum/phone/contact = getRefFromID(params[1])
				if(!(contact in getContacts()))
					return // double-checking that the contact should actually be visible to our phone
				startPhoneCall(contact)
			if("leaveCall")
				disconnectFromCall()

// Be careful overriding this, make sure you account for other phone datums that may try to connect to this!
/// Handles routing all the speech and data in a phone call
/datum/phonecall
	var/phonecallID = null // in case someone needs to refer to a specific call, we'll have a unique ID for it

	var/members = list() // Support for 3+ contact PhoneCalls! Number of connected phones capped by maxMembers
	var/pendingMembers = list() // sometimes it's useful to know who's being rung up but hasn't connected yet
	var/datum/phone/host = null // who's hosting this party?!

	var/maxMembers = null // how many people can be in this PhoneCall?
	var/overrideMax = FALSE // if true, phones will ignore their maxMembers value

	New(creator, max, priority)
		..()
		phonecallID = format_net_id("\ref[src]")
		host = creator
		maxMembers = max
		overrideMax = priority

	disposing()
		for(var/datum/phone/contact in members)
			disconnect(contact)
		disconnect(host)
		..()

	proc/tryConnect(var/datum/phone/target)
		if(length(members) >= maxMembers)
			return FALSE
		if((length(members) >= target.maxConnected) && !overrideMax)
			return FALSE
		if(target in members)
			return FALSE
		if((src != target.currentPhoneCall) && !isnull(target.currentPhoneCall))
			return FALSE
		members += target
		target.onJoin(src)
		return TRUE

	proc/disconnect(var/datum/phone/target)
		if(isnull(target) || (!(target in members) && target != host))
			return
		target.onDisconnect(src) // we let them know what /phonecall datum is calling this proc, just in case
		if(host == target)
			host = null // we set this now so that when we call dispose() it immediately returns when it re-calls disconnect(host)
			dispose() // the phonecall can't exist if we stop hosting!
		else
			members -= target

	proc/relay_speech(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)
		var/recipients = members + host
		recipients -= source
		for(var/datum/phone/target in recipients)
			target.speechReceived(source, M, text, secure, real_name, lang_id)

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
		if(phoneDatum.incomingCall)
			phoneDatum.incomingCall.tryConnect(phoneDatum)
			return
		ui = phoneDatum.ui_interact(user, ui)
		/*var/formattedContacts
		for(var/datum/phone/contact in phoneDatum.getContacts())
			formattedContacts += "<br><a href='byond://?src=\ref[src];CALL-PHONE=\ref[contact]'>[contact.phoneName]</a>"
		usr.Browse("<head><title>PLACEHOLDER PHONE UI</title></head><body><tt><b>Contact list:</b><hr>[formattedContacts]</tt></body>", "window=placeholder_phone_ui")*/

	Topic(href, href_list)
		if("CALL-PHONE" in href_list)
			var/datum/phone/target = locate(href_list["CALL-PHONE"])
			phoneDatum.startPhoneCall(target)
			return

	talk_into(mob/M as mob, text, secure, real_name, lang_id)
		phoneDatum.sendSpeech(M, text, secure, real_name, lang_id)

	proc/outputSpeech(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)
		var/mob/user
		if(istype(src.loc, /mob))
			user = src.loc
		else return
		var/processed = "<span class='game say'><span class='bold'>[M.name]</span> says, <span class='message'>\"[text[1]]\"</span></span>"
		user.show_message(processed, 2)

/obj/item/testPhone/testPhone2
	name = "TEST PHONE 2"

/obj/item/testPhone/testPhone3
	name = "TEST PHONE 3"
