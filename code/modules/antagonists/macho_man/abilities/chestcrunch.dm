/datum/targetable/macho/macho_chestcrunch
	name = "Grapple - Ribcracker"
	desc = "Pulverize the ribcage of a dude you grabbed"
	icon_state = "pet"
	targeted = 0
	cast(atom/target)
		. = ..()
		if (isalive(holder.owner) && !holder.owner.transforming)
			for (var/obj/item/grab/G in holder.owner)
				if (ishuman(G.affecting))
					var/mob/living/carbon/human/H = G.affecting
					playsound(holder.owner.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
					holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] crushes [H]'s ribcage open like a bag of chips!</B>"))
					H.TakeDamage("chest", 500, 0, 0, DAMAGE_CRUSH)
					H.changeStatus("stunned", 8 SECONDS)
					H.changeStatus("knockdown", 5 SECONDS)
					H.UpdateDamageIcon()
					qdel(G)
				else
					playsound(holder.owner.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 75, 1)
					holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] crushes [G.affecting]'s body into bits!</B>"))
					G.affecting.gib()
					qdel(G)
				SPAWN(2 SECONDS)
					playsound(holder.owner.loc, pick(snd_macho_rage), 50, 0, 0, holder.owner.get_age_pitch())
					holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner]</b> lets out an angry warcry!"))
				break
