/datum/targetable/spell/forcewall
	name = "Forcewall"
	desc = "Create a forcewall which extends out to your sides."
	icon_state = "forcewall"
	targeted = 0
	cooldown = 20 SECONDS
	requires_robes = 1
	voice_grim = "sound/voice/wizard/ForcewallGrim.ogg"
	voice_fem = "sound/voice/wizard/ForcewallFem.ogg"
	voice_other = "sound/voice/wizard/ForcewallLoud.ogg"

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("BRIXHUN MOHTYR")
		..()
		if(!holder.owner.wizard_spellpower(src))
			boutput(holder.owner, "<span class='alert'>Your spell is weak without a staff to focus it!</span>")

		playsound(holder.owner.loc, "sound/effects/mag_forcewall.ogg", 25, 1, -1)
		var/forcefield1
		var/forcefield2
		var/forcefield3
		var/forcefield4
		var/forcefield5

		if (holder.owner.dir == NORTH || holder.owner.dir == SOUTH)
			forcefield1 =  new /obj/forcefield(locate(holder.owner.x, holder.owner.y, holder.owner.z))
			forcefield2 =  new /obj/forcefield(locate(holder.owner.x + 1, holder.owner.y, holder.owner.z))
			forcefield3 =  new /obj/forcefield(locate(holder.owner.x - 1, holder.owner.y, holder.owner.z))
			if (holder.owner.wizard_spellpower(src)) forcefield4 =  new /obj/forcefield(locate(holder.owner.x + 2, holder.owner.y, holder.owner.z))
			if (holder.owner.wizard_spellpower(src)) forcefield5 =  new /obj/forcefield(locate(holder.owner.x - 2, holder.owner.y, holder.owner.z))
		else
			forcefield1 =  new /obj/forcefield(locate(holder.owner.x, holder.owner.y, holder.owner.z))
			forcefield2 =  new /obj/forcefield(locate(holder.owner.x, holder.owner.y + 1, holder.owner.z))
			forcefield3 =  new /obj/forcefield(locate(holder.owner.x, holder.owner.y - 1, holder.owner.z))
			if (holder.owner.wizard_spellpower(src)) forcefield4 =  new /obj/forcefield(locate(holder.owner.x,holder.owner.y + 2,holder.owner.z))
			if (holder.owner.wizard_spellpower(src)) forcefield5 =  new /obj/forcefield(locate(holder.owner.x,holder.owner.y - 2,holder.owner.z))

		SPAWN_DBG(30 SECONDS)
			qdel(forcefield1)
			qdel(forcefield2)
			qdel(forcefield3)
			if (forcefield4)
				qdel(forcefield4)
			if (forcefield5)
				qdel(forcefield5)

/obj/forcefield
	desc = "A space wizard's magic wall."
	name = "Forcewall"
	desc = "An impenetrable magic barrier. Its only flaw is that it cannot last long."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "forcewall"
	anchored = 1.0
	opacity = 0
	density = 1
	luminosity = 3

/obj/forcefield/artifact
	var/obj/artifact/forcefield_generator/source = null

	New(var/obj/artifact/forcefield_generator/S)
		. = ..()
		source = S

	Bumped(AM)
		. = ..()
		if(source && ismob(AM))
			source.ArtifactFaultUsed(AM)

