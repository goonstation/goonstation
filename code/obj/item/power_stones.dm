/obj/item/power_stones
	name = "stone"
	desc = "A powerful stone"
	icon_state = "dimensionrock"
	item_state = null
	icon = 'icons/obj/ouroborousrocks.dmi'
	var/stonetype = "basestone"
	var/ability = /obj/ability_button/stone_teleport //no runtime errors pls

	//Teleports you places yo
	Space
		name = "Telecrystal Stone"
		stonetype = "Telecrystal Stone"
		icon_state = "potentialstone"
		ability = /obj/ability_button/stone_teleport

	//Will probably shoot stuff idk getting back to this
	Power
		name = "Erebite Stone"
		stonetype = "Power Stone"
		icon_state = "potentialrock"
	//	ability = /obj/ability_button/stonefireball

	//Animate all objects in view you nutter!
	Soul
		name = "SoulSteel Stone"
		desc = "You feel an intense power emanating from this stone. You feel as if it is watching you, and judging your soul."
		stonetype = "Soul Stone"
		icon_state = "spiritrock"
		ability = /obj/ability_button/stone_animate

		//The stone requires a price
		attack_hand(mob/user as mob)
			if(user.mind.karma <= 49)
				boutput(user,"<span class='alert'><B>You are not a Just enough being. The stone finds you unworthy.</B></span>")
				user.gib()
			else
				return ..(user)

	//Time rewind nonsense
	Time
		name = "Spacelag Stone"
		desc = "Looking at this stone makes you feel both old and young at the same time. You feel intense Déjà vu as you relive every moment of your life at once. Then the feeling fades again."
		stonetype = "Time Stone"
		icon_state = "intervalrock"
		ability = /obj/ability_button/stone_time

	Reality
		name = "Miracle-Matter Stone"
		stonetype = "Reality Stone"
		icon_state = "actualityrock"
		ability = /obj/ability_button/stone_reality

//////////////////////////////////////////
//////////////Gimmick Stones//////////////
/////////////////////////////////////////

	//owl
	Owl
		stonetype = "Owl Stone"
		icon_state = "owlstone"
		ability = /obj/ability_button/stone_owl

		attack_hand(mob/user as mob)
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (istype(H.w_uniform, /obj/item/clothing/under/gimmick/owl) && istype(H.wear_mask, /obj/item/clothing/mask/owl_mask))
					return ..(user)
				else
					boutput(user,"<span class='alert'><B>The stone finds you unworthy.</B></span>")
					playsound(user.loc, "sound/voice/animal/hoot.ogg", 100, 1)
					user.owlgib()

	//Gall
	Gall //Fucking what am I doing
		name = "GallStone"
		desc = "Looking at this thing really makes you want to puke."
		stonetype = "GallStone"
		icon_state = "gallstone"
		ability = /obj/ability_button/stone_gall

		attack_hand(mob/user as mob)
			if(!istype(user, /mob/living/carbon/human)) return
			boutput(user,"<span class='alert'><B>God, holding it makes you feel sick.</B></span>")
			playsound(user, pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
			make_cleanable( /obj/decal/cleanable/vomit, user.loc)
			random_brute_damage(user, rand(5,30))
			if(prob(50)) //The stone has a price to pay
				var/mob/living/carbon/human/M = user
				var/list/organ_list = list("left_eye", "right_eye", "chest", "heart", "left_lung", "right_lung") //This is gunna hurt
				var/obj/item/organ/O = pick(organ_list)
				M.organHolder.drop_organ(O, M.loc)

				if(O == "left_eye" || O == "right_eye")
					O = "eye"
				else if(O == "left_lung" || O == "right_lung")
					O = "lung"

				M.visible_message("<span class='alert'><B>[M] vomits out their [O]. [pick("Holy shit!", "Holy fuck!", "What the hell!", "What the fuck!", "Jesus Christ!", "Yikes!", "Oof...")]</B></span>")

			return ..(user)
