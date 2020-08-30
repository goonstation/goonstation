/datum/component/consume
/datum/component/consume/Initialize()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

/datum/component/consume/organpoints
	var/list/organ2points = list(/obj/item/organ/head=2,/obj/item/skull=0,/obj/item/organ/brain=3,/obj/item/organ/chest=5,/obj/item/organ/heart=2,/obj/item/organ/appendix=0,/obj/item/clothing/head/butt=0)

/datum/component/consume/organpoints/Initialize()
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED), .proc/eat_organ_get_points)

/datum/component/consume/organpoints/proc/eat_organ_get_points(var/mob/M, var/mob/user, var/obj/item/I)
	if (!I || !M || !ishuman(M) || !user)
		return 0

	var/mob/living/carbon/human/L = M

	var/add_these_points = 0
	if (istype(I) && (I.type in src.organ2points))
		add_these_points = src.organ2points[I.type]
		switch(I.type)
			if (/obj/item/organ/head)
				boutput(L, "<span class='notice'>Tasty! While the hair on [I] was absolutely </span><span class='alert'><i>revolting</i></span><span class='notice'>, the headmeat within wasn't half bad.</span>")
			if (/obj/item/skull)
				boutput(L, "<span class='alert'>Ugh. Nothing but bone.</span>")
			if (/obj/item/organ/brain)
				boutput(L, "<span class='notice'>Delicious! The creamy, savory taste of [I] leaves you with a big dumb grin.</span>")
			if (/obj/item/organ/chest)
				boutput(L, "<span class='notice'>Bland, but there was a lot of it.</span>")
			if (/obj/item/organ/heart)
				boutput(L, "<span class='notice'>Full of iron!</span>")
			if (/obj/item/organ/appendix)
				boutput(L, "<span class='alert'>Urgh, that tasted like a thumb made out of Discount Dan's.</span>")
			if (/obj/item/clothing/head/butt)
				boutput(L, "<span class='alert'><i>Eugh</i>, you know <i>exactly</i> where that's been.</span>")
				L.vomit()

	else if (istype(I, /obj/item/organ))
		var/obj/item/organ/O = I
		if(O.robotic)
			L.abilityHolder.deductPoints(2)
			boutput(L, "<span class='alert'><i>Agh!</i> That [I] was made of metal! <i>Metal!</i> Your entire body hates you for this.</span>")
			return
		else
			add_these_points = 1
			boutput(L, "<span class='notice'>That [I] wasn't half bad.</span>")

	if (!L?.abilityHolder)
		return

	if (add_these_points)
		L.abilityHolder.addPoints(add_these_points, /datum/abilityHolder/lizard)

/datum/component/consume/organpoints/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_CONSUMED)
	. = ..()


/datum/component/consume/organheal
	var/static/list/organ2hp = list(/obj/item/organ/head=20,/obj/item/skull=0,/obj/item/organ/brain=30,/obj/item/organ/chest=30,/obj/item/organ/heart=20,/obj/item/organ/appendix=0,/obj/item/clothing/head/butt=6)
	var/base_HPup = 5

/datum/component/consume/organheal/Initialize()
	RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED), .proc/eat_organ_get_heal)

/datum/component/consume/organheal/proc/eat_organ_get_heal(var/mob/M, var/mob/user, var/obj/item/I)
	if (!I || !M || !user)
		return 0

	if (istype(I) && (I.type in src.organ2hp))
		M.HealDamage("All", src.organ2hp[I.type] * 0.5, src.organ2hp[I.type] * 0.5)
		switch(I.type)
			if (/obj/item/organ/head)
				boutput(M, "<span class='notice'>Tasty! While the hair on [I] was absolutely </span><span class='alert'><i>revolting</i></span><span class='notice'>, the headmeat within wasn't half bad.</span>")
			if (/obj/item/skull)
				boutput(M, "<span class='alert'>Ugh. Nothing but bone.</span>")
			if (/obj/item/organ/brain)
				boutput(M, "<span class='notice'>Delicious! The creamy, savory taste of [I] leaves you with a big dumb grin.</span>")
			if (/obj/item/organ/chest)
				boutput(M, "<span class='notice'>Bland, but there was a lot of it.</span>")
			if (/obj/item/organ/heart)
				boutput(M, "<span class='notice'>Full of iron!</span>")
			if (/obj/item/organ/appendix)
				boutput(M, "<span class='alert'>Urgh, that tasted like a thumb made out of Discount Dan's.</span>")
			if (/obj/item/clothing/head/butt)
				boutput(M, "<span class='alert'><i>Eugh</i>, you can </span><span class='alert'><i>taste</i></span><span class='notice'> where that's been. At least it's kind of meaty...</span>")

	else if (istype(I, /obj/item/organ))
		var/obj/item/organ/O = I
		if(O.robotic)
			M.TakeDamage("All", base_HPup, 0, base_HPup)
			boutput(M, "<span class='alert'><i>Augh!</i> That chewed-up [I] turned to shrapnel in your stomach!</span>")
		else
			M.HealDamage("All", base_HPup, base_HPup)
			boutput(M, "<span class='notice'>Mmmmm, tasty organs. How refreshing</span>")
	else
		return


/datum/component/consume/organheal/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_CONSUMED)
	. = ..()
