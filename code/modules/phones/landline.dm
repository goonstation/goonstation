/datum/phone/landline
	var/obj/machinery/phone/ourHolder = null /// we can't override holder, so we make our own for when we need to refer to a handset or something

	canVape = TRUE
	canVoltron = TRUE

	New(var/atom/creator)
		..()
		ourHolder = creator

	startPhoneCall(var/toCall, var/forceStart, var/doGroupCall = FALSE, var/manuallyDialled = FALSE)
		if(!ourHolder.handset)
			return FALSE // just in case some bozo tries to dial after putting down the handset
		ourHolder.lastRing = 0 // we don't want it to make the ring noise when it's making other noises
		. = ..()
		if(.)
			ourHolder.doRing(callStart = TRUE)

	receiveInvite()
		. = ..()
		if(.)
			ourHolder.doRing(callStart = TRUE)


	isBusy()
		. = ..()
		if(ourHolder.handset)
			. = FALSE // the line gets busy when we pick up the handset!
		if(!ourHolder.connected)
			. = FALSE


	canSee()
		if(!ourHolder.connected)
			return FALSE
		if(ourHolder.unlisted)
			return FALSE
		. = ..()

	getContacts()
		if(!ourHolder.connected)
			return
		. = ..()

	speechReceived(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id, initialText)
		ourHolder.handset?.outputSpeech(source, M, text, secure, real_name, lang_id, initialText)

	onDisconnect(datum/phonecall/leftPhoneCall)
		..()
		if(ourHolder.handset)
			return
		ourHolder.icon_state = ourHolder.phoneIcon
		ourHolder.lastRing = 0

	onRemoteDisconnect()
		handleSound("sound/machines/phones/remote_hangup.ogg",50,0)

	onRemoteJoin()
		handleSound("sound/machines/phones/remote_answer.ogg",50,0)


	handleDialPad(key)
		if(startingCall) // stop touching the keypad when you're starting a call, asshole
			return
		. = ..()

	handleSound(soundin, vol as num, vary, extrarange as num, pitch, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
		ourHolder.handset?.outputSound(soundin, vol, vary, extrarange, pitch, ignore_flag, channel, flags)

	onVape(var/datum/reagents/_buffer, var/obj/item/reagent_containers/vape/vape, var/mob/living/sourceMob, var/datum/phone/sourcePhone)
		if(ourHolder.handset)
			_buffer.my_atom = ourHolder.handset // we do this so the actual smoke reaction occurs on the handset and not the person who vaped
			if(ismob(ourHolder.handset.loc))
				var/mob/user = ourHolder.handset.loc
				boutput(user,"<span class='alert'><B>[sourceMob] blows a cloud of smoke right through the phone! What a total [pick("dork","loser","dweeb","nerd","useless piece of shit","dumbass")]!</B></span>")
		..()

	onVoltron(var/mob/living/sourceMob, var/obj/item/device/voltron/voltron, var/datum/phone/sourcePhone, var/isOrgan = FALSE, var/override)
		override = ourHolder.handset
		. = ..(sourceMob, voltron, sourcePhone, isOrgan, override)
