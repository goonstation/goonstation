/datum/listen_module/effect/lawbringer
	id = LISTEN_EFFECT_LAWBRINGER
	var/list/valid_modes = list(
		"detain" = TRUE,
		"execute" = TRUE,
		"exterminate" = TRUE,
		"cluwneshot" = TRUE,
		"smokeshot" = TRUE,
		"fog" = TRUE,
		"knockout" = TRUE,
		"sleepshot" = TRUE,
		"hotshot" = TRUE,
		"incendiary" = TRUE,
		"fired" = TRUE,
		"assault" = TRUE,
		"highpower" = TRUE,
		"bigshot" = TRUE,
		"clownshot" = TRUE,
		"clown" = TRUE,
		"pulse" = TRUE,
		"push" = TRUE,
		"throw" = TRUE,
	)

/datum/listen_module/effect/lawbringer/process(datum/say_message/message)
	var/obj/item/gun/energy/lawbringer/lawbringer = src.parent_tree.listener_parent
	if (!istype(lawbringer) || !ismob(message.original_speaker))
		return
	if (lawbringer.loc != message.original_speaker)
		return

	if (!ishuman(message.original_speaker))
		lawbringer.are_you_the_law(message.original_speaker, message.content)
		return

	var/mob/living/carbon/human/H = message.original_speaker
	if (!lawbringer.fingerprints_can_shoot(H))
		lawbringer.are_you_the_law(H, message.content)
		return

	if (!length(lawbringer.projectiles))
		boutput(H, SPAN_NOTICE("Gun broke. Call 1-800-CODER."))
		lawbringer.set_current_projectile(new /datum/projectile/energy_bolt/aoe)
		lawbringer.item_state = "lawg-detain"
		H.update_inhands()
		lawbringer.UpdateIcon()
		return

	var/text = lawbringer.sanitize_talk(message.content)
	var/list/words = splittext(text, " ")

	for(var/word in words)
		if(!src.valid_modes[word])
			continue
		lawbringer.change_mode(H, word)
		H.update_inhands()
		lawbringer.UpdateIcon()
		return
