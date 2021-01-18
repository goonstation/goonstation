
/obj/item/plant/flower
	name = "flower"
	desc = "Somebody messed up while coding a pretty flower."
	burn_point = 330
	burn_output = 800
	burn_possible = 2
	wear_image_icon = 'icons/mob/head.dmi'
	var/thorned = 0
	var/seal_hair = 0
	var/use_bloodoverlay = 0
	var/bites = 1

	attack(mob/M as mob, mob/user as mob) //shamlessly yoinking fruit hat code
		if (M == user)
			if (!src.bites)
				boutput(user, "<span class='alert'>No more bites of \the [src] left, oh no!</span>")
				user.u_equip(src)
				qdel(src)
			else
				M.visible_message("<span class='notice'>[M] takes a bite of [src]!</span>",\
				"<span class='notice'>You take a bite of [src]!</span>")
				src.bites--
				M.nutrition += 20
				playsound(M.loc,"sound/items/eatfood.ogg", 1)
				if (!src.bites)
					M.visible_message("<span class='alert'>[M] finishes eating [src].</span>",\
					"<span class='alert'>You finish eating [src].</span>")
					user.u_equip(src)
					qdel(src)
		else if(check_target_immunity(M))
			user.visible_message("<span class='alert'>You try to feed [M] [src], but fail!</span>")
		else
			user.tri_message("<span class='alert'><b>[user]</b> tries to feed [M] [src]!</span>",\
			user, "<span class='alert'>You try to feed [M] [src]!</span>",\
			M, "<span class='alert'><b>[user]</b> tries to feed you [src]!</span>")
			if (!do_after(user, 1 SECONDS))
				boutput(user, "<span class='alert'>You were interrupted!</span>")
				return ..()
			else
				user.tri_message("<span class='alert'><b>[user]</b> feeds [M] [src]!</span>",\
				user, "<span class='alert'>You feed [M] [src]!</span>",\
				M, "<span class='alert'><b>[user]</b> feeds you [src]!</span>")
				src.bites--
				M.nutrition += 20
				playsound(M.loc, "sound/items/eatfood.ogg", 1)
				if (!src.amount)
					M.visible_message("<span class='alert'>[M] finishes eating [src].</span>",\
					"<span class='alert'>You finish eating [src].</span>")
					user.u_equip(src)
					qdel(src)


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
	name = "Hibiscus"
	desc = "A flower that makes up for it's lack of scent with it's beauty."
	icon_state = "hibiscus"


/obj/item/plant/flower/poppy
	name = "poppy"
	crop_suffix	= ""
	desc = "A distinctive red flower."
	icon_state = "poppy"
//	module_research = list("vice" = 4)
//	module_research_type = /obj/item/plant/herb/cannabis
