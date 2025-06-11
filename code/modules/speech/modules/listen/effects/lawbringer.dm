/datum/listen_module/effect/lawbringer
	id = LISTEN_EFFECT_LAWBRINGER
	var/list/valid_modes = list(
		"detain",
		"execute",
		"exterminate",
		"cluwneshot",
		"smokeshot",
		"fog",
		"knockout",
		"sleepshot",
		"hotshot",
		"incendiary",
		"fired",
		"assault",
		"high power",
		"bigshot",
		"clownshot",
		"clown",
		"pulse",
		"push",
		"throw",
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

	for(var/valid_mode in valid_modes)
		if(!findtext(text, valid_mode))
			continue
		lawbringer.change_mode(H, valid_mode)
		H.update_inhands()
		lawbringer.UpdateIcon()
		return
