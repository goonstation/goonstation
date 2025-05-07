/datum/targetable/spell/mutate
	name = "Empower"
	desc = "Temporarily superpowers your body and grants a burst of strength."
	icon_state = "mutate"
	targeted = 0
	cooldown = 30 SECONDS
	requires_robes = 1
	offensive = 1
	voice_grim = 'sound/voice/wizard/MutateGrim.ogg'
	voice_fem = 'sound/voice/wizard/MutateFem.ogg'
	voice_other = 'sound/voice/wizard/MutateLoud.ogg'
	maptext_colors = list("#d73715", "#d73715", "#fcf574")

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("BIRUZ BENNAR", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		boutput(holder.owner, SPAN_NOTICE("Your muscles are magically empowered and you feel very athletic!"))
		holder.owner.visible_message(SPAN_ALERT("[holder.owner] glows with a POWERFUL aura!"))

		if (!holder.owner.bioHolder.HasEffect("hulk"))
			holder.owner.bioHolder.AddEffect("hulk", 0, 0, 0, 1)
		APPLY_ATOM_PROPERTY(holder.owner, PROP_MOB_PASSIVE_WRESTLE, "empower")
		APPLY_ATOM_PROPERTY(holder.owner, PROP_MOB_STAMINA_REGEN_BONUS, "empower", 5)
		src.holder.owner.deStatus("knockdown")
		var/SPtime = 9 SECONDS
		if (holder.owner.wizard_spellpower(src))
			SPtime = 15 SECONDS
		else
			boutput(holder.owner, SPAN_ALERT("Your spell doesn't last as long without a staff to focus it!"))
		SPAWN(SPtime)
			if (!QDELETED(holder.owner))
				if (holder.owner.bioHolder.HasEffect("hulk"))
					holder.owner.bioHolder.RemoveEffect("hulk")
				REMOVE_ATOM_PROPERTY(holder.owner, PROP_MOB_PASSIVE_WRESTLE, "empower")
				REMOVE_ATOM_PROPERTY(holder.owner, PROP_MOB_STAMINA_REGEN_BONUS, "empower")
