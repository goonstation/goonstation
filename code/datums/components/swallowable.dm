/datum/component/swallowable
	var/required_role = null

/datum/component/swallowable/Initialize(required_role = null)
	. = ..()
	src.required_role = required_role
	RegisterSignal(src.parent, COMSIG_ITEM_ATTACK_PRE, PROC_REF(swallow))

/datum/component/swallowable/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_ITEM_ATTACK_PRE)

/datum/component/swallowable/proc/swallow(obj/item/parent, mob/living/target, mob/living/user)
	if (target != user)
		return FALSE
	if (src.required_role && user.mind?.assigned_role != src.required_role)
		return FALSE
	if (!user.organHolder?.stomach)
		user.show_message(SPAN_ALERT("You can't seem to swallow!"))
		return
	user.visible_message(SPAN_ALERT("[user] stuffs [src.parent] into [his_or_her(user)] mouth and swallows it!"))
	playsound(user, 'sound/misc/gulp.ogg', 30, TRUE)
	eat_twitch(user)
	user.drop_item(src.parent)
	user.organHolder.stomach.consume(src.parent)
	if (prob(50))
		SPAWN(1 SECOND)
			user.emote("burp")
	return ATTACK_PRE_DONT_ATTACK
