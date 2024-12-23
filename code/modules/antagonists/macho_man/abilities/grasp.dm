/datum/targetable/macho/macho_grasp
	name = "Macho Grasp"
	desc = "Instantly grab someone in a headlock"
	icon_state = "badtouch"
	targeted = 1

	cast(atom/target)
		var/mob/M = target
		. = ..()
		if (!(BOUNDS_DIST(M, holder.owner) == 0))
			return
		if (istype(M) && isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (G.affecting == M)
					return
			playsound(holder.owner.loc, pick(snd_macho_rage), 50, 0, 0, holder.owner.get_age_pitch())
			holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] aggressively grabs [M]!</B>"))
			var/obj/item/grab/G = new /obj/item/grab(holder.owner, holder.owner, M)
			holder.owner.put_in_hand(G, holder.owner.hand)
			M.changeStatus("stunned", 10 SECONDS)
			G.state = GRAB_AGGRESSIVE
			G.UpdateIcon()
			holder.owner.set_dir(get_dir(holder.owner, M))
			playsound(holder.owner.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 65, 1)
