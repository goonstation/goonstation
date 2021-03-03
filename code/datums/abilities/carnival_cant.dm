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
        var/mob/living/carbon/human/OWNER = holder.owner
        if(!OWNER.limbs.l_arm && !OWNER.limbs.r_arm)
            OWNER.show_text("You can't speak Carnival Cant without arms!","red")
        var/message = input(OWNER, "What would you like to say?", "Carnival Cant") as null|text
        message = strip_html(message)
        if(!length(message) || (copytext(message,1,2) == " "))
            message = null
        if(!message)
            return
        OWNER.emote("carnivalcant")
        for(var/mob/LISTENER in viewers(OWNER,10))
            if(LISTENER.blinded)
                continue
            if((LISTENER.job == "Clown") || (LISTENER.job == "Mime") || isAI(LISTENER) || isobserver(LISTENER))
                LISTENER.show_text("<b>[OWNER.name]</b> signs, \"[message]\"","pink")
        logTheThing("say", OWNER, OWNER.name, "[message]")

/datum/targetable/carnival/cant/mime
    icon_state = "cant-mime"
