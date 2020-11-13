// fart cloud for toxic farts

/obj/effects/fart_cloud
	name = "fart cloud"
	icon_state = "mustard"
	opacity = 1
	anchored = 0
	mouse_opacity = 0
	event_handler_flags = USE_HASENTERED
	var/amount = 6
	var/mob/living/fartowner = null

	proc/Life()
		amount--
		for(var/mob/living/carbon/human/H in range(get_turf(src),1))
			if (H == src.fartowner)
				continue
			if (prob(20))
				boutput(H, "<span class='alert'>Oh god! The <i>smell</i>!!!</span>")
			H.reagents.add_reagent("jenkem",0.1)
		sleep(1.5 SECONDS)
		if(amount < 1)
			dispose()
			return
		else
			src.Life()

/obj/effects/fart_cloud/New(loc,var/mob/living/owner)
	..()
	if (owner)
		fartowner = owner
	amount = rand(3,8)
	SPAWN_DBG(0)
		src.Life()
	return

/obj/effects/fart_cloud/Move()
	. = ..()
	for(var/mob/living/carbon/human/R in get_turf(src))
		if (R.internal != null && R.wear_mask && (R.wear_mask.c_flags & MASKINTERNALS))
			continue
		if (R == src.fartowner)
			continue
		R.reagents.add_reagent("jenkem",1)
	return

/obj/effects/fart_cloud/HasEntered(mob/living/carbon/human/R as mob )
	..()
	if (ishuman(R))
		if (R.internal != null && R.wear_mask && (R.wear_mask.c_flags & MASKINTERNALS))
			return
		if (R == src.fartowner)
			return
		R.reagents.add_reagent("jenkem",1)
	return
