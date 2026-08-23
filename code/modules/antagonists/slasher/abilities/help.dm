/datum/targetable/slasher/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "help"
	targeted = FALSE
	cooldown = 5 SECONDS
	helpable = FALSE
	special_screen_loc = "SOUTH,EAST"
	tooltip_options = list("align" = TOOLTIP_TOP | TOOLTIP_RIGHT)

	cast(atom/target)
		if (..())
			return TRUE
		if (holder.help_mode)
			holder.help_mode = FALSE
			boutput(holder.owner, SPAN_NOTICE("<strong>Help Mode has been deactivated.</strong>"))
		else
			holder.help_mode = TRUE
			boutput(holder.owner, SPAN_NOTICE("<strong>Help Mode has been activated. To disable it, click on this button again.</strong>"))
			boutput(holder.owner, SPAN_NOTICE("Hold down Shift, Ctrl or Alt while clicking the button to set it to that key."))
			boutput(holder.owner, SPAN_NOTICE("You will then be able to use it freely by holding that button and left-clicking a tile."))
			boutput(holder.owner, SPAN_NOTICE("Alternatively, you can click with your middle mouse button to use the ability on your current tile."))
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()
