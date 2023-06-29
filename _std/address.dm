//for memory address stuff - pure witchery

// for a more complete list see https://gn32.uk/f/byond-typeids.txt
var/global/list/type_ids = list(
	/turf = "01",
	/obj = "02",
	/mob = "03",
	/area = "04",
	/client = "05",
	// strings are "06"
	/image = "0d",
	/datum = "21"
)

#define PROC_TYPEID "26"

var/global/list/addr_padding = list("00000", "0000", "000", "00", "0", "")
#define BUILD_ADDR(TYPE_ID, NUM) "\[0x[TYPE_ID][addr_padding[length(num2text(NUM, 0, 16))]][num2text(NUM, 0, 16)]\]"

#define TYPE_ID_OF_ADDR(ADDR) copytext(ADDR, 4, length(ADDR) - 6)

#define ADDR_TO_NUM(ADDR) text2num(copytext(ADDR, 4, length(ADDR)), 16)

#define NUM_TO_ADDR(NUM) "\[0x[num2text(NUM, 0, 16)]\]"

#define isproc(P) (TYPE_ID_OF_ADDR(ref(P)) == PROC_TYPEID)
