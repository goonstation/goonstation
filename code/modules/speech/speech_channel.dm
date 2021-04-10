/datum/speech_channel
	var/local = FALSE
	var/range = 1
	var/css_classes = null
	var/uses_accents = TRUE
	var/ic = TRUE
	var/admin_hearing = TRUE

/datum/speech_channel/proc/render_message(message, atom/author)
	"<span class='game ghoulsay'><span class='prefix'>GHOULSPEAK:</span> <span class='name' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> <span class='message'>[message]</span></span>"
	"<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> <span class='message'>[message]</span></span>"
	"<span class='game hivesay'><span class='prefix'>HIVEMIND:</span> <span class='name' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> <span class='message'>[message]</span></span>"
	"<span class='game kudzusay'><span class='prefix'><small>KUDZUSPEAK:</small></span> <span class='name' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> <span class='message'>[message]</span></span>"
	"<span class='game [class]'><span class='bold'></span><span class='name'>ADMIN([show_other_key ? C.fakekey : C.key])</span> informs, <span class='message'>\"[message]\"</span></span>"

/mob/proc/say_ghoul(var/message, var/datum/abilityHolder/vampire/owner)
	var/name = src.real_name
	var/alt_name = ""

	if (!owner)
		return

	if (!message)
		return

	if (istype(src, /mob/living/critter/changeling/handspider))
		name = src.real_name
		alt_name = " (VAMPIRE)"
	else if (istype(src, /mob/living/critter/changeling/eyespider))
		name = src.real_name
		alt_name = " (GHOUL)"

#ifdef DATALOGGER
	game_stats.ScanText(message)
#endif

	message = src.say_quote(message)
	//logTheThing("say", src, null, "SAY: [message]")

	var/rendered = "<span class='game ghoulsay'><span class='prefix'>GHOULSPEAK:</span> <span class='name' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> <span class='message'>[message]</span></span>"


	//show message to admins (Follow rules of their deadchat toggle)
	for (var/client/C)
		if (!C.mob) continue
		var/mob/M = C.mob
		if (M.client && M.client.holder && M.client.deadchat && !M.client.player_mode)
			var/thisR = rendered
			if (M.client && (istype(M, /mob/dead/observer)||M.client.holder) && src.mind)
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[rendered]</span>"
			boutput(M, thisR)
	//show to ghouls
	for (var/mob/M in owner.ghouls)
		var/thisR = rendered
		if (M.client && (istype(M, /mob/dead/observer)||M.client.holder) && src.mind)
			thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[rendered]</span>"
		boutput(M, thisR)
	//show to ghoul owner
	if (!(owner.owner.client && owner.owner.client.holder && owner.owner.client.deadchat && !owner.owner.client.player_mode))
		var/thisR = rendered
		if (owner.owner.client && src.mind)
			thisR = "<span class='adminHearing' data-ctx='[owner.owner.client.chatOutput.getContextFlags()]'>[rendered]</span>"
		boutput(owner.owner, thisR)
