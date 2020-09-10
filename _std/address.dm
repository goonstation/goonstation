//for memory address stuff - pure witchery

var/global/list/addr_padding = list("00000", "0000", "000", "00", "0", "")
#define BUILD_ADDR(TYPE_ID, NUM) "\[0x[TYPE_ID][addr_padding[length(num2text(NUM, 0, 16))]][num2text(NUM, 0, 16)]\]"
