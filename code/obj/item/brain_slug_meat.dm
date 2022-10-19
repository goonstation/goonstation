/// Mob drop for brain slugs. Gives food buffs + heals brain and can be "eaten" on a cooldown
/obj/item/brain_slug_meat
	name = "brain slug meat"
	desc = "Some pulsating meat of unknown origin. It emits an oddly sweet scent."
	icon = 'icons/obj/sec_tape.dmi'
	icon_state = "sec_tape_roll"
	w_class = W_CLASS_TINY
	var/consumption_ready = TRUE
	eat_effects = list("food_brute", "food_all")

/obj/item/brain_slug_meat/get_desc()
	if(src.consumption_ready)
		return "Some pulsating meat of unknown origin. It emits an oddly sweet scent."
	else
		return "A crooked shell with a bit of meat attached to it. The meat is slowly shifting around and reassembling itself."

/obj/item/brain_slug_meat/attack_self(mob/user as mob)
	if(!src.consumption_ready)
		..()
	else
		playsound(user, 'sound/items/eatfood.ogg', rand(10,50), 1)
		eat_twitch(user)
		if (src.status_effects.len && isliving(user) && user.bioHolder)
			var/mob/living/L = M
			for (var/bonus in src.status_effects)
				L.add_food_bonus(effect, eat_parent)
		src.consumption_ready = FALSE
		//src.icon_state = something else
