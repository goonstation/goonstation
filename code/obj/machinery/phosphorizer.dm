/obj/machinery/phosphorizer
	name = "Phosphorizer"
	desc = "A device capable of baking a phosphor onto light tubes or bulbs, changing the color of light they emit."
	icon = 'icons/obj/machines/phosphorizer.dmi'
	icon_state = "baseunit"
	anchored = 1
	density = 1
	mats = 20

/obj/machinery/phosphorizer/power_change()
	var/image/I_panel = SafeGetOverlayImage("statuspanel", 'icons/obj/machines/phosphorizer.dmi', "powerpanel")
	I_panel.plane = PLANE_OVERLAY_EFFECTS
	I_panel.alpha = 128
	if (status & BROKEN)
		UpdateOverlays(null, "statuspanel", 0, 1)
		//light.disable()
	else
		if ( powered() )
			UpdateOverlays(I_panel, "statuspanel", 0, 1)
			status &= ~NOPOWER
			//light.enable()
		else
			SPAWN_DBG(rand(0, 15))
				UpdateOverlays(null, "statuspanel", 0, 1)
				status |= NOPOWER
				//light.disable()
