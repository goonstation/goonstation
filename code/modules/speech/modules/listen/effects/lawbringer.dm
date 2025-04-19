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

	if (!ishuman(message.original_speaker))
		lawbringer.are_you_the_law(message.original_speaker, message.content)
		return

	var/mob/living/carbon/human/H = message.original_speaker
	if (lawbringer.owner_prints && (H.bioHolder.Uid != lawbringer.owner_prints))
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
	if (!lawbringer.fingerprints_can_shoot(H))
		if (src.valid_modes[text])
			global.random_burn_damage(H, 50)
			H.changeStatus("knockdown", 4 SECONDS)
			global.elecflash(lawbringer, power = 2)
			H.visible_message(SPAN_ALERT("[H] tries to fire [lawbringer]! The gun initiates its failsafe mode."))

		return

	lawbringer.change_mode(H, text)
	H.update_inhands()
	lawbringer.UpdateIcon()
