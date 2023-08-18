-- ===============================================
-- Created for connecting the server to the client
-- ===============================================

local Build = script.Parent.Build
local Server = require(Build.Server).new({
	Debug = true,
	Connection_Timeout = 5,
	StorePlayers = true,
})
