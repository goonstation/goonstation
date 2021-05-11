/datum/targetable/spell/mutate
	name = "Empower"
	desc = "Temporarily superpowers your body and mind."
	icon_state = "mutate"
	targeted = 0
	cooldown = 400
	requires_robes = 1
	offensive = 1
	voice_grim = "sound/voice/wizard/MutateGrim.ogg"
	voice_fem = "sound/voice/wizard/MutateFem.ogg"
	voice_other = "sound/voice/wizard/MutateLoud.ogg"

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("BIRUZ BENNAR")
		..()

		boutput(holder.owner, "<span class='notice'>Your mind and muscles are magically empowered!</span>")
		holder.owner.visible_message("<span class='alert'>[holder.owner] glows with a POWERFUL aura!</span>")

		if (!holder.owner.bioHolder.HasEffect("hulk"))
			holder.owner.bioHolder.AddEffect("hulk", 0, 0, 0, 1)
		if (!holder.owner.bioHolder.HasEffect("telekinesis") && holder.owner.wizard_spellpower(src))
			holder.owner.bioHolder.AddEffect("telekinesis", 0, 0, 0, 1)
		var/SPtime = 150
		if (holder.owner.wizard_spellpower(src))
			SPtime = 300
		else
			boutput(holder.owner, "<span class='alert'>Your spell doesn't last as long without a staff to focus it!</span>")
		SPAWN_DBG (SPtime)
			if (holder.owner.bioHolder.HasEffect("telekinesis"))
				holder.owner.bioHolder.RemoveEffect("telekinesis")
			if (holder.owner.bioHolder.HasEffect("hulk"))
				holder.owner.bioHolder.RemoveEffect("hulk")
