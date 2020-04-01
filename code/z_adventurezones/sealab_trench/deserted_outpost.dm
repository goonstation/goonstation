/*
Stuff for the Deserted Outpost for Oshan
Contents:
Audio Log for Outpost
4 Audio Tapes
*/
/obj/item/device/audio_log/outpost
	New()
		..()
		src.tape = new /obj/item/audio_tape/outpost_01(src)

/obj/item/audio_tape/outpost_01
	New()
		..()
		speakers = list("Daniel","???","Low voice","Daniel","Daniel","???","Daniel","???",
		"Daniel","Low voice","???","Low voice","???","Daniel","???","Low voice","???","???","Daniel",
		"Low voice","???","Low voice","Daniel","???","Daniel","Low voice","???","Daniel","???")
		messages = list("This is Daniel speaking. Today is June 30th, 20--",
		"*static*",
		"Hurry up, will you?",
		"Just give me a sec, okay?",
		"I'm back at the outpost now, after spending three months tailing Nanotrasen Space Station--",
		"*static*",
		"--unable to find",
		"*static*",
		"--or the green disk as specified. However, we--",
		"You mean your idiot friend couldn't--",
		"*static*",
		"--some scratched up junk record.",
		"*static*",
		"--off you asshole. What have you done for the--",
		"*static*",
		"--a lot more than you. Don't get ahead of yourself and start thinking that you're invaluable. You're not.",
		"*silence*",
		"*muffled yelps*",
		"Seriously fuck off!",
		"And why should I? I told her to send me, but she didn't listen, and now we have nothing to--",
		"*static*",
		"--full of yourself?!",
		"How the hell is it my fault that--",
		"*loud buzz*",
		"--fucking solar storm?",
		"Impeccable timing. Wonderful.",
		"*static*",
		"Goddamnit.",
		"*click*")

/obj/item/audio_tape/outpost_02
	New()
		..()
		speakers = list("Female voice","Daniel","???","???","Female voice","???","Daniel","Daniel","???",
		"Daniel","Female voice","Daniel","???","Daniel","Daniel","Daniel","Daniel","Female voice","Daniel",
		"???","Daniel","Daniel","???","Daniel","Female voice","Daniel","Female voice","???","Daniel",
		"Female voice","Daniel","???","Daniel","???","Daniel","Daniel","Daniel","Daniel","???","Daniel",
		"Daniel","Female voice","Daniel","Female voice","Daniel","???")
		messages = list("Tell me about yourself, Daniel.",
		"Well, uh, okay.",
		"*silence*",
		"*sigh*",
		"How about your background? Where did you grow up?",
		"*pause*",
		"I grew up on Earth. Uh, it was a pretty normal childhood. I had, or, have, a little sister and a dog. Marbles. My parents are divorced and they get joint custody.",
		"Sorry, can I get a drink of water?",
		"*clink*",
		"Thanks.",
		"Mhm.",
		"And, uh, growing up, I was never told that I was gifted or talented or anything.",
		"*nervous laughter*",
		"So I just sorta coasted along, y'know?",
		"But, even though I was totally average and all that, I kept feeling like I was wasting my potential.",
		"Despite no one ever telling me that I had potential...",
		"I dunno.",
		"What compelled you to leave Earth? To join Nanotrasen?",
		"Well, uh. One of my friends was applying to be a scientist.",
		"*pause*",
		"She was one of those gifted ones.",
		"And, uh, y'know. I thought, maybe, if I took a similar path...",
		"*silence*",
		"Yeah.",
		"Why did you decide to leave them?",
		"Uh, Nanotrasen?",
		"Yes.",
		"*pause*",
		"Well, at the time, it seemed kinda, uh, sketchy. Well, not it. Them. The higher ups.",
		"Can you tell me more?",
		"Like, it didn't seem like they cared. Which, yeah, uh, is probably typical. But it was more than your usual greedy corporation bullshit, y'know?",
		"*sigh*",
		"There were accidents. Lots of them. And when I tried to get in contact with my sister, or just, like, anyone from outside...",
		"*silence*",
		"The mail servers... There were always these cryptic emails that ended up in my inbox.",
		"I thought they were pranks or something, at first.",
		"I, uh, deleted them.",
		"But they kept coming.",
		"*pause*",
		"Like, there's something going on.",
		"And I couldn't figure it out, no matter how hard I tried. I thought I was going crazy.",
		"And that's why you decided to leave them?",
		"Yeah, uh.",
		"But why seek us out?",
		"Uh.",
		"*silence*")

/obj/item/audio_tape/outpost_03
	New()
		..()
		speakers = list("Female voice","Daniel","Daniel","Female voice","Daniel","Female","???","Daniel","???",
		"Daniel","???","Daniel","Female voice","???","Female voice", "Female voice", "Female voice",
		"Female voice", "???", "Female voice", "Daniel", "???", "Female voice", "Daniel", "Female voice", "Daniel",
		"Female voice", "???", "Female voice", "???", "Daniel", "Female voice", "???", "Female voice", "???",
		"Female voice", "Female voice", "???", "Female voice")
		messages = list("You seem quite unsure of yourself.",
		"Well, uh.",
		"Yeah, maybe.",
		"You'll have to think very carefully about this, Daniel. It's a tremendous decision, and you really don't want to make the wrong one.",
		"... I know.",
		"Before I let you continue with us, we have to be certain about your beliefs. Doubt clouds the mind, and we really only want those who truly, clearly, believe in the cause. Those who will do whatever it takes.",
		"*nervous laughter*",
		"You make it sound like a cult.",
		"*silence*",
		"Like, y'know, that unwavering loyalty and total belief shit.",
		"*clink*",
		"Right, sorry.",
		"No, it's fine. Recognizing these things and pointing them out is fine. It's good to have awareness.",
		"*pause*",
		"Maybe we are like a cult, in terms of requiring utter conviction. Really, it's necessary.",
		"We can't have any weaknesses, any doubt, any hesitation. We just have to believe.",
		"If we don't, we lose. We die. We fail.",
		"That's what it takes, Daniel.",
		"*silence*",
		"In folklore, Robin Hood remains a contentious character. You've heard of him, I presume?",
		"... Yeah. There was a collection of fairy tale stories... I think it was a banned book? And, uh, it had him in it.",
		"*pause*",
		"Think of us like that.",
		"Sorry?",
		"Robin Hood. We're Robin Hood. Maybe good, maybe bad. But most definitely a sort of resistance to the norm, to the status quo.",
		"Man, this sounds kinda, uh, cheesy.",
		"That's what helps us get through every day, Daniel.",
		"*pause*",
		"Think on it. Think about what you truly believe in. Think about who you want to be.",
		"*silence*",
		"What if I--",
		"No, no. Don't ask me. Ask yourself.",
		"*pause*",
		"I can guarantee that if you join us, you'll gain wonderful allies and a developed sense of self-confidence and self-assurance.",
		"*soft laughter*",
		"But, I cannot guarantee much more beyond that.",
		"I cannot guarantee epiphanies, validation, or success.",
		"*pause*",
		"Take your time. Think.")

/obj/item/audio_tape/outpost_04
	New()
		..()
		speakers = list("Male voice","Female voice","Male voice","Female voice","Male voice","Female voice",
		"???","???","Male voice","???","Female voice","Male voice","Female voice","Male voice","Female voice",
		"Male voice","Female voice","Male voice","Female voice","Male voice","Female voice","Male voice",
		"???","Female voice","Male voice","Female voice","Male voice","Female voice","Male voice","Female voice",
		"Male voice","???","Female voice","???")
		messages = list("I listened to your talk with Daniel.",
		"What did you think?",
		"He's fine. You on the other hand...",
		"Hm?",
		"You sounded like a teenager straining to appear worldly and self-possessed.",
		"Ouch.",
		"*laughter*",
		"*silence*",
		"You kept telling him to think, but have you?",
		"*pause*",
		"Yes, I have.",
		"How are you certain that he'll be a good fit?",
		"It's just a feeling. What else can I go off of?",
		"His records are clean.",
		"Yes.",
		"Daniel Oaks, age nineteen. Joined Nanotrasen as a chemist, defected in a year and two days.",
		"Defected. That's a dramatic word.",
		"Dramatic things might happen.",
		"You think?",
		"No ties to the Syndicate or to the Soviets.",
		"Naturally.",
		"You think he's got what it takes?",
		"*pause*",
		"He's a nice boy. Wants to make a difference. Wants to change the world.",
		"Don't you think it's cruel to put him through this, then?",
		"No, I don't. We need him. We can't have everyone going around being disillusioned and apathetic.",
		"Yes, but--",
		"He's a good person. We won't change that.",
		"How can you be certain? What he'll go through... What we've gone through. We're outlaws. Constantly living in fear and in the dark.",
		"We are.",
		"Fear and darkness change people.",
		"*pause*",
		"Here, now you're the one trying too hard to be profound.",
		"*soft laughter*")





