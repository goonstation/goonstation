/datum/abilityHolder/carnival
    usesPoints = 0
    regenRate = 0
    tabName = "Carnival"

ABSTRACT_TYPE(/datum/targetable/carnival)
/datum/targetable/carnival
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/carnival

/datum/targetable/carnival/cant //defaults to clown version
    name = "Carnival Cant"
    desc = "A secret language that only entertainers know! This one in particular is a form of sign language!"
    icon_state = "cant-clown"
    targeted = 0


    cast()
        if(!holder)
            return TRUE
        if(!ishuman(holder.owner))
            return
        var/mob/living/carbon/human/human_owner = holder.owner
        if(!human_owner.limbs.l_arm && !human_owner.limbs.r_arm)
            human_owner.show_text("You can't speak Carnival Cant without arms!","red")
        var/message = input(human_owner, "What would you like to say?", "Carnival Cant") as null|text
        message = strip_html(message)
        if(!length(message) || (copytext(message,1,2) == " "))
            message = null
        if(!message)
            return
        human_owner.emote("carnivalcant")
        for(var/mob/LISTENER in viewers(human_owner,10))
            if(LISTENER.blinded)
                continue
            if((LISTENER.job == "Clown") || (LISTENER.job == "Mime") || isAI(LISTENER) || isobserver(LISTENER))
                LISTENER.show_text("<b>[human_owner.name]</b> signs, \"[message]\"","pink")
        logTheThing("say", human_owner, human_owner.name, "[message]")

/datum/targetable/carnival/cant/mime
    icon_state = "cant-mime"
