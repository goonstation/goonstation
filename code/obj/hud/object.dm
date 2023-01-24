/atom/movable/screen/release
	name = "Release object"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	screen_loc = "NORTH,EAST"
	layer = HUD_LAYER
	var/mob/living/object/owner = null

	New()
		..()
		underlays += image('icons/mob/screen1.dmi', "block")

	clicked(params)
		..()
		if (owner)
			owner.death(FALSE)

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = src.name,
				"content" = (src.desc ? src.desc : null)
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

/obj/hud/proc/object_hud()
	mymob.zone_sel = new(mymob, "SOUTH,EAST")
	mymob.attach_hud(mymob.zone_sel)

	mymob.i_select = new /atom/movable/screen/intent_sel( src )
	mymob.i_select.name = "intent"
	mymob.i_select.icon_state = (mymob.a_intent == "harm" ? "harm" : mymob.a_intent)
	mymob.i_select.screen_loc = "SOUTH,EAST-1"
	mymob.i_select.layer = HUD_LAYER

	if (mymob.client)
		mymob.client.screen = null

		mymob.i_select.add_to_client(mymob.client)
		//mymob.zone_sel.add_to_client(mymob.client)
		var/mob/living/object/O = mymob
		mymob.client.screen += O.release
