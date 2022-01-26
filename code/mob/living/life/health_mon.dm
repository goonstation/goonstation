
/datum/lifeprocess/health_mon
	process(var/datum/gas_mixture/environment)
		if (!human_owner) //humans only, fix this later to work on critters!!!
			return ..()

		// Update Prodoc overlay heart
		var/mob/living/carbon/human/H = owner
		if (H.health_mon)
			// Originally the isdead() check was only done in the other check if <0, which meant
			// if you were dead but had > 0 HP (e.g. eaten by blob) you would still show
			// a not-dead heart. So, now you don't.
			if ((owner.bioHolder && owner.bioHolder.HasEffect("dead_scan")) || isdead(owner))
				H.health_mon.icon_state = "-1"
			else
				// Handle possible division by zero
				var/health_prc = (owner.health / (owner.max_health != 0 ? owner.max_health : 1)) * 100
				switch (health_prc)
					// There's 5 "regular" health states (ignoring 100% and < 0)
					// but the health icons were set up as if there were 4
					// (25, 50, 75, 100) / (20, 40, 60, 80, 100)
					// The "75" state was only used for 75-80!
					// Spread these out to make it more represenative
					if (98 to INFINITY) //100
						H.health_mon.icon_state = "100"
					if (80 to 98) //80
						H.health_mon.icon_state = "80"
					if (60 to 80) //75
						H.health_mon.icon_state = "75"
					if (40 to 60) //50
						H.health_mon.icon_state = "50"
					if (20 to 40) //25
						H.health_mon.icon_state = "25"
					if ( 0 to 20) //10
						H.health_mon.icon_state = "10"
					if (-INFINITY to 0) //0
						H.health_mon.icon_state = "0"
		if (H.health_implant)
			var/has_health = locate(/obj/item/implant/health) in H.implant
			var/has_cloner = locate(/obj/item/implant/cloner) in H.implant
			if(has_health && has_cloner)
				H.health_implant.icon_state = "implant-both"
			else if(has_health)
				H.health_implant.icon_state = "implant-health"
			else if(has_cloner)
				H.health_implant.icon_state = "implant-cloner"
			else
				H.health_implant.icon_state = null

		..()
