local Players = game:GetService("Players")
local ServerModel = {}
ServerModel.__index = ServerModel

-- ================================
-- Default Settings
-- ================================
local DefaultOptions: ServerOptions = {
	Connection_Timeout = 5,
	Debug = false,
}

function ServerModel.new(Options: ServerOptions)
	local self = setmetatable({
		Options = Options or DefaultOptions,
	}, ServerModel)

	self.Players = {}
	self.Connections = {}
	self.Errors = {}

	self.PlayerAdded = Players.PlayerAdded
	self.PlayerRemoving = Players.PlayerRemoving

	return self
end

export type ServerOptions = {
	Connection_Timeout: number,
	Debug: true | false,
	StorePlayers: true | false,
}
return ServerModel
