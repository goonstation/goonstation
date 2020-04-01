print( "Chui init" )
local environment = {
	BYOND = BYOND,
	sleep = sleep,
	os = {
		time = os.time,
		clock = clock,
		date = date,
	},
	math = math,
	string = string,
	table = table,
	readfile = function(path)
		local f,err = io.open(path,'rb')
		if not f then error(err) end
		local ret = f:read('*a')
		f:close()
		return ret
	end,
	HookReceive = HookReceive,
	loadstring = loadstring,
	print=print,
	assert=assert,
	tostring=tostring,
	tonumber = tonumber,
	input = input,
	pairs = pairs
}

local function newenv(parent, done, environ)
	parent = parent or environment
	done = done or {}
	
	local ret = {}
	environ = environ or ret
	for k,v in pairs( parent ) do 
		if not done[v] then
			if( type(v) == 'table' ) then
				ret[k] = newenv(v, done, ret)
			else
				ret[k] = v
			end
		end
	end
	return ret
end
local windows = {}
local datastores = {}
local ACTIVE_WINDOW
local templateCache = {}
function view(path, data)--ergo, view("telesci/main.htm")(client[, data])
	if PRODUCTION and templateCache[f] then return templateCache[f](data, ACTIVE_WINDOW.USR, ACTIVE_WINDOW.USR.mob, ACTIVE_WINDOW.atom) end
	--print(_G)
	local luas = environment.readfile( 'popups/' .. path )--[[io.open( 'popups/' .. path, 'rb' )
	local luas = f:read( '*a' )
	f:close()]]
	
	luas = 'local data, client, usr, src= ...; local buffer = ""; buffer = buffer..[[' .. luas:gsub( '<%%=(.-)%%>', ']] buffer = buffer..(%1) buffer = buffer .. [[' ):gsub( '<%%(.-)%%>', ']] %1 buffer = buffer..[[' ) .. ']]; return buffer'
	local func = assert(loadstring( luas, path ))
	
	setfenv(func, ACTIVE_WINDOW)
	templateCache[path] = func
	return func(data, ACTIVE_WINDOW.USR, ACTIVE_WINDOW.USR.mob, ACTIVE_WINDOW.atom)
end
--dofile'lua/init.lua'dofile'lua/chui.lua'

function SendFile( file )
	BYOND.CallProc( "RSCTransfer", file )
end
function CDN(url)
	if PRODUCTION then
		return "http://cdn.goonhub.com/" .. path
	else
		SendFile("browserassets/" .. path)
		return path:match(".-([^\\/]-[^%.]+)$")--return filename
	end
end
environment.CDN = CDN
environment.view = view
environment.SendFile= SendFile

HookReceive("ChuiNewWindow", function(data)
	local env = newenv()
	
	local WIN = {}
	WIN.name = "This is a name"
	WIN.atom = data.atom
	WIN.wind = data.window
	WIN.ref = data.window._ref
	function WIN:GetBody()
		return "No body defined"
	end

	function WIN:Topic(client, href, params)
	end
	function WIN:OnData(data)
	end

	function WIN:OnRequest(client, path, data)
		return false
	end
	
	function WIN:CallJS( func, exclude, ... )
		local args = {...}
		if type(exclude) ~= 'table' then
			table.insert( args, 1, exclude )
		end
		BYOND.CallProc( "CallJS", self.wind._ref, func, args, exclude)
		return
	end
	
	function WIN:Cleanup() end
	
	env.WIN = WIN
	datastores[data.window._ref] = datastores[data.window._ref] or {}
	env.DATA = datastores[data.window._ref]
	
	--print("Attempting to load " .. data.luafile)
	local fnc, err = loadfile( data.luafile )
	if not fnc then error( err ) end
	setfenv( fnc, env )
	fnc()
	--print("P   A   IR S S", env.pairs)
	windows[ data.window._ref ] = env
	
	return WIN.name
end)
--[[
HookReceive("ChuiInit", function(data)
	WIN.atom = data.atom
	WIN.wind = data.window
	PRODUCTION= data.production
end)]]
HookReceive("ChuiRender", function(data)
	local window = windows[ data.ref ]
	if not window then return end
	ACTIVE_WINDOW = window
	window.USR = data.client
	window = window.WIN
	return window:GetBody(data.client)
end)
HookReceive("ChuiRequest", function(data)
	local window = windows[ data.ref ]
	if not window then return end
	ACTIVE_WINDOW = window
	window.USR = data.client
	window = window.WIN
	return window:OnRequest(data.client, data.method, data.data)
end)
HookReceive("ChuiData", function(data)
	local window = windows[ data.ref ]
	if not window then return end
	ACTIVE_WINDOW = window
	window = window.WIN
	return window:OnData(data.data)
end)
HookReceive("ChuiCleanup", function(data)
	local window = windows[ data.ref ]
	if not window then return end
	ACTIVE_WINDOW = window
	window = window.WIN
	window:Cleanup()
	windows[ data.ref ] = nil
end)

