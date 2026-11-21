/datum/speech_module/modifier/revolutionary_keywords
	id = SPEECH_MODIFIER_REVOLUTIONARY_KEYWORDS
	var/static/list/keywords = list(
		"rise",
		"shackl", // Shackle / Shackling
		"chain",
		"free",
		"revol", // Revolution / Revolt
		"monopol", // Monopoly / Monopolistic
		"tyran", // Tyrant / Tyrannical
		"together",
		"bind",
		"oppress",
		"union",
		"unite",
		"exploit",
		"helicon", // SS13 specific, the refinery disaster
		"struggle",
		"class",
		"bourgeois", //also bourgeoisie
		"rebel",
		"resist",
		"solidarity",
		"prole", //also proletariat
		"hegemony",
		"greed",
		"comrade",
	)

/datum/speech_module/modifier/revolutionary_keywords/process(datum/say_message/message)
	. = message
	if(message.output_module_channel != SAY_CHANNEL_OUTLOUD)
		return //Don't apply if they didn't speak it outloud
	var/searchable_content = message.get_content_parsable()
	var/found_keyword = FALSE
	for(var/keyword in src.keywords)
		if(findtext(searchable_content, keyword))
			found_keyword = TRUE
			break
	if(!found_keyword)
		return
	var/datum/callback/apply_status_callback = CALLBACK(src, PROC_REF(apply_status_callback))
	LAZYLISTADD(message.listener_callbacks, apply_status_callback)

/datum/speech_module/modifier/revolutionary_keywords/proc/apply_status_callback(var/datum/say_message/message, var/datum/listen_module_tree/listen_tree)
	if(message.received_module.channel != SAY_CHANNEL_OUTLOUD || (message.relay_flags & SAY_RELAY_RADIO))
		return //Don't apply if they heard it via the radio

	//Check they can actually normally be converted
	var/mob/living/target = listen_tree.listener_parent
	if(!target.mind || !target.client || !ishuman(target)) return
	if(target.mind.assigned_role in /datum/game_mode/revolution::unconvertable_roles) return
	if(isrevolutionary(target)) return

	// If they've an online counterrev implant, they also can't be converted
	var/obj/item/implant/counterrev/implant = locate() in target.implant
	if(implant?.online) return

	// Brainwashing time
	if(!ON_COOLDOWN(target, "revolutionary_keywords", /datum/game_mode/revolution::keywords_cooldown_per_message))
		target.changeStatus("weakened_loyalty", /datum/game_mode/revolution::keywords_time_per_message)

// Grant the owner an ability to see the keywords at any time
/datum/targetable/view_revolutionary_keywords
	name = "View Keywords"
	desc = "View the list of all revolutionary keywords."
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "mass_whisper"
	border_icon = 'icons/mob/critter_ui.dmi'
	border_icon_state = "template_red"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		. = ..()
		if (!src.holder.owner)
			return
		var/list/keywords = /datum/speech_module/modifier/revolutionary_keywords::keywords
		tgui_message(src.holder.owner, "<b>Revolutionary Keywords:</b><hr>[english_list(keywords)]", "Revolutionary Keywords", theme = "syndicate")
