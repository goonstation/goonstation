/obj/item/implant/emote_triggered
	var/activation_emote = "wink"
	var/list/compatible_emotes = list()

	implanted(mob/M, mob/I)
		. = ..()
		//try not to conflict with other emote triggers
		src.activation_emote = pick(src.compatible_emotes - M.trigger_emotes) || pick(src.compatible_emotes)
		LAZYLISTADD(M.trigger_emotes, src.activation_emote)
		src.RegisterSignal(M, COMSIG_MOB_EMOTE, PROC_REF(trigger))
		M.mind.store_memory("[src] can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
		boutput(M, "The implanted [src.name] can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")

	on_remove(mob/M)
		. = ..()
		M.trigger_emotes -= src.activation_emote
		src.UnregisterSignal(M, COMSIG_MOB_EMOTE)

	proc/trigger(mob/source, emote, voluntary, atom/target)
		return
/obj/item/implant/emote_triggered/freedom
	name = "freedom implant"
	icon_state = "implant-r"
	var/uses = 1
	impcolor = "r"
	scan_category = IMPLANT_SCAN_CATEGORY_SYNDICATE
	activation_emote = "shrug"
	compatible_emotes = list("eyebrow", "nod", "shrug", "smile", "yawn", "flex", "snap")

	New()
		src.uses = rand(3, 5)
		..()
		return

	trigger(mob/source, emote)
		if (src.uses < 1)
			return 0

		if (emote == src.activation_emote)
			var/activated = FALSE

			if (source.hasStatus("handcuffed"))
				source.handcuffs.drop_handcuffs(source)
				activated = TRUE

			// Added shackles here (Convair880).
			if (ishuman(source))
				var/mob/living/carbon/human/H = source
				if (H.shoes && H.shoes.chained)
					activated = TRUE
					var/obj/item/clothing/shoes/SH = H.shoes
					H.u_equip(SH)
					SH.set_loc(H.loc)
					H.update_clothing()
					if (SH)
						SH.layer = initial(SH.layer)

			if (activated)
				src.uses--
				boutput(source, "You feel a faint click.")

/obj/item/implant/emote_triggered/signaler
	name = "signaler implant"
	icon_state = "implant-r"
	impcolor = "r"
	scan_category = IMPLANT_SCAN_CATEGORY_SYNDICATE
	activation_emote = "wink"
	compatible_emotes = list("eyebrow", "nod", "shrug", "smile", "yawn", "flex", "snap")
	var/obj/item/device/radio/signaler/signaler = null

	New()
		..()
		src.signaler = new(src)

	implanted(mob/M, mob/I)
		. = ..()
		tgui_process.close_uis(src.signaler)

	attack_self(mob/user)
		return src.signaler.AttackSelf(user)

	trigger(mob/source, emote)
		if (emote == src.activation_emote)
			boutput(source, "You hear a faint beep.")
			signaler.send_signal()
