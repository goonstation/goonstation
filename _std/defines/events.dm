
/// arginfo handling TODO: document
#define EVENT_INFO(name, type, desc)\
	list(name, type, desc)

#define EVENT_INFO_EXT(name, type, desc...)\
	list(name, type, ##desc)

#define EVENT_INFO_NAME 1
#define EVENT_INFO_TYPE 2
#define EVENT_INFO_DESC 3
#define EVENT_INFO_VAL_A 4
#define EVENT_INFO_VAL_B 5
