/obj/mapping_helper/free_vendor
	name = "free vendor helper"
	desc = "Forces vending machines on the same turf as it to sell their contents for free, then destroys itself."
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "free_vendor"

/obj/mapping_helper/free_vendor/setup()
	for (var/obj/machinery/vending/vendor in src.loc)
		vendor.pay = FALSE
		vendor.acceptcard = FALSE
