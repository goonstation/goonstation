//Place for the new chaplain books to live since they function differently from the bible

/obj/item/scripture
	name = "blank scripture"
	icon = 'icons/obj/writing.dmi'
	icon_state = "blankhb"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "blankhb"
	desc = "An interpretive holy scripture touting… just about whatever you want, really."
	var/item_state_base = "blankhb"
	var/is_open = FALSE

	attack_self(mob/user)
		if (user.find_in_hand(src))
			if (!src.is_open)
				src.open(user)
			else
				src.close(user)
			user.update_inhands()

	proc/open (mob/user as mob)
		src.is_open = TRUE
		icon_state = "[icon_state]open"
		item_state = "[item_state]open"

	proc/close (mob/user as mob)
		src.is_open = FALSE
		icon_state = "[src.item_state_base]"
		item_state = "[src.item_state_base]"

/obj/item/scripture/eyehb
	name = "guide to the skies"
	icon_state = "eyehb"
	item_state = "eyehb"
	desc = "A book covered in depictions of staring eyes and cosmic forces. You feel watched holding it."
	item_state_base = "eyehb"

/obj/item/scripture/eyedarkhb
	name = "guide to the stars"
	icon_state = "eyedarkhb"
	item_state = "eyedarkhb"
	desc = "A dark book covered in depictions of staring eyes and cosmic forces. You feel watched holding it."
	item_state_base = "eyedarkhb"

/obj/item/scripture/greenhb
	name = "handbook to the Other world"
	icon_state = "greenhb"
	item_state = "greenhb"
	desc = "This old tome is full of curious rituals. It has mold between the pages."
	item_state_base = "greenhb"

/obj/item/scripture/clownhb
	name = "the great prophecy of hilarity"
	icon_state = "clownhb"
	item_state = "clownhb"
	desc = "This is actually a novel taken from a library written over with crayon drawings of bananas and clown faces."
	item_state_base = "clownhb"

/obj/item/scripture/purplehb
	name = "Tome of the Cosmic Gods"
	icon_state = "purplehb"
	item_state = "purplehb"
	desc = "A deep purple tome telling of the eldritch lore and its many gods."
	item_state_base = "purplehb"

/obj/item/scripture/burnedhb
	name = "scripture of conflagration"
	icon_state = "burnedhb"
	item_state = "burnedhb"
	desc = "A cooked scripture composed of passionate ravings of fire and brimstone."
	item_state_base = "burnedhb"

/obj/item/scripture/bluehb
	name = "last words of the outlander"
	icon_state = "bluehb"
	item_state = "bluehb"
	desc = "A text in a spacefaring language lost to the galaxy. It contains diagrams of its history that are difficult to parse."
	item_state_base = "bluehb"

/obj/item/scripture/skeletonhb
	name = "bone tome"
	icon_state = "skeletonhb"
	item_state = "skeletonhb"
	desc = "A dusty leather text displaying images of skeletons. Its bookmark is actually a spine!"
	item_state_base = "skeletonhb"

/obj/item/scripture/xhb
	name = "the word of the light"
	icon_state = "xhb"
	item_state = "xhb"
	desc = "A scripture touting the strength of light and the power it provides to all life"
	item_state_base = "xhb"

/obj/item/scripture/bluewhitehb
	name = "resplendent azure tome"
	icon_state = "bluewhitehb"
	item_state = "bluewhitehb"
	desc = "a resplendent blue and white book with gold lettering."
	item_state_base = "bluewhitehb"

/obj/item/scripture/redwhitehb
	name = "resplendent crimson tome"
	icon_state = "redwhitehb"
	item_state = "redwhitehb"
	desc = "a resplendent red and white book with gold lettering"
	item_state_base = "redwhitehb"

/obj/item/scripture/reddarkhb
	name = "grand tome"
	icon_state = "reddarkhb"
	item_state = "reddarkhb"
	desc = "a grand red and black book with gold lettering"
	item_state_base = "reddarkhb"

/obj/item/scripture/cluwnehb
	name = "cursed prophecy of the fatal laughter"
	icon_state = "cluwnehb"
	item_state = "cluwnehb"
	desc = "Every word inside makes you want to retch."
	item_state_base = "cluwnehb"

/obj/item/scripture/tidehb
	name = "disarmanomicon"
	icon_state = "tidehb"
	item_state = "tidehb"
	desc = "A picture book teaching assistants right from wrong."
	item_state_base = "tidehb"
