/datum/targetable/slasher/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "help"
	targeted = FALSE
	cooldown = 5 SECONDS
	helpable = FALSE
	special_screen_loc = "SOUTH,EAST"

	cast(atom/target)
		if (..())
			return TRUE
		if (holder.help_mode)
			holder.help_mode = FALSE
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been deactivated.</strong></span>")
		else
			holder.help_mode = TRUE
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been activated. To disable it, click on this button again.</strong></span>")
			boutput(holder.owner, "<span class='notice'>Hold down Shift, Ctrl or Alt while clicking the button to set it to that key.</span>")
			boutput(holder.owner, "<span class='notice'>You will then be able to use it freely by holding that button and left-clicking a tile.</span>")
			boutput(holder.owner, "<span class='notice'>Alternatively, you can click with your middle mouse button to use the ability on your current tile.</span>")
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()
