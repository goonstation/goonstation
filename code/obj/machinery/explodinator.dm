/obj/machinery/explodinator
	name = "\improper Explodinator 3007"
	desc = "A complicated and dynamic multi-phasic device capable of producing a sudden, uncontrolled release of energy."
	icon = 'icons/obj/networked.dmi'
	icon_state = "explodinator"
	density = 1
	anchored = ANCHORED
	var/boom_size = 15

	attack_hand(mob/user)
		. = ..()
		var/choice = tgui_alert(user, "Please select", "Explodinator 3007", list("Explode", "Print report", "Cancel"))
		if (QDELETED(src))
			return
		switch(choice)
			if ("Explode")
				src.visible_message(SPAN_ALERT("[src] explodes!"))
				explosion_new(src, get_turf(src), src.boom_size)
				qdel(src)
			if ("Print report")
				if (ON_COOLDOWN(src, "printing", 8 SECONDS))
					return
				playsound(src, 'sound/machines/printer_dotmatrix.ogg', 50, FALSE)
				SPAWN(8 SECONDS)
					if (QDELETED(src))
						return
					var/obj/item/paper/printout = new(get_turf(src))
					printout.icon_state = "paper"
					printout.name = "Explodinator 3007 report"
					printout.info = {"
					<h1>Explodinator 3007 status report</h1>
					<b>Explodinator 3007 status: Unexploded</b><br><br>
					Thank you for purchasing the Thinktronics™ Explodinator 3007!<br>
					<i>By reading this document you agree to indemnify, defend, and hold harmless Thinktronics llc from any claims, losses, sudden cessation of existence,
					liabilities, damages, strange smells, costs or expenses related to standard or nonstandard operation of the Explodinator 3007, including those
					resulting from the Indemintee's gross negligence, intentional misconduct, or really mean pranks.</i>
					"}
