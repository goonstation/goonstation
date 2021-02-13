
/obj/item/plant/flower
	name = "flower"
	desc = "Somebody messed up while coding a pretty flower."
	burn_point = 330
	burn_output = 800
	burn_possible = 2
	wear_image_icon = 'icons/mob/head.dmi'
	var/thorned = 0
	var/seal_hair = 0 //gotta have this to prevent runtimes
	var/use_bloodoverlay = 0 //this too

/obj/item/plant/flower/rose
	name = "rose"
	desc = "By any other name, would smell just as sweet. This one likes to be called "
	icon_state = "rose"
	thorned = 1
	var/list/names = list("Emma", "Olivia", "Ava", "Isabella", "Sophia", "Charlotte", "Mia", "Amelia",
	"Harper", "Evelyn", "Abigail", "Emily", "Elizabeth", "Mila", "Dakota", "Avery",
	"Sofia", "Camila", "Aria", "Scarlett", "Liam", "Noah", "William", "James",
	"Oliver", "Benjamin", "Elijah", "Lucas", "Mason", "Logan", "Alexander", "Ethan",
	"Jacob", "Michael", "Daniel", "Henry", "Jackson", "Sebastian", "Aiden", "Matthew", "Tommy",)

	New()
		..()
		desc = desc + pick(names) + "."

	attack_hand(mob/user as mob)
		var/mob/living/carbon/human/H = user
		if(src.thorned)
			if(istype(H))
				if(H.gloves)
					..()
					return
			boutput(user, "<span class='alert'>You prick yourself on [src]'s thorns trying to pick it up!</span>")
			random_brute_damage(user, 3)
			take_bleeding_damage(user,null,3,DAMAGE_STAB)
		else
			..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/wirecutters/) && src.thorned)
			boutput(user, "<span class='notice'>You snip off [src]'s thorns.</span>")
			src.thorned = 0
			src.desc += " Its thorns have been snipped off."
			return
		..()
		return

/obj/item/plant/flower/hibiscus
	name = "hibiscus"
	desc = "A flower that makes up for it's lack of scent with it's beauty."
	icon_state = "hibiscus"

/obj/item/plant/flower/poppy
	name = "poppy"
	desc = "A distinctive red flower."
	icon_state = "poppy"
//	module_research = list("vice" = 4)
//	module_research_type = /obj/item/plant/herb/cannabis

/obj/item/plant/flower/bluebonnet //research the flower
	name = "blue bonnet"
	desc = "to-do" //NOTE THIS
	icon_state = "bbonnet"

/obj/item/plant/flower/daffodil //researchresearch
	name = "daffodil"
	desc = "to-do" //NOTE THIS
	icon_state = "daffodil"

/obj/item/plant/flower/daisy //research it
	name = "daisy"
	desc = "Daisy, Daisy..." //give me your answer do...
	icon_state = "daisy"

/obj/item/plant/flower/morningglory //rereresearch
	name = "morning glory"
	desc = "to-do" //NOTE THIS
	icon_state = "mglory"
