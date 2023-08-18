local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TheBadGuy = {}
TheBadGuy.__index = TheBadGuy

local Defaults: AntiCheatOptions = {
	Debug = false, --> Used for AntiCheat bug corrections, testing and a lot more.

	BanEnabled = true, --> If enabled, the AntiCheat will ban the player.
	BanStringKey = "NMC-BANS", --> The key that will be used to store the bans, Changing this will reset the bans.

	Properties = {
		Workspace = {
			-- * Currently working to better compatibility and no longer issues with server conflict.
			AntiDestroy = true, --> Can cause issues with server destroying instances
			AntiPropertyChange = true, --> Can cause issues with server changing properties
		},
		Server = {
			-- * Properties about how the server should work.
			ServerChangesAreReplicated = false, --[[
                --> This sends a message to client communicating that a Instance has been changed,
                This allows the client to be in the same state as server, It is a good way to fix issues with server changing properties.
                Can leak information to some exploiter, can be potential dangerous.

                -- ? You can make your own replicated changes with encrypted tokens, fixing the leaks.
            ]]
			SuspiciousActivities = {
				["INSTANCE_CHANGED"] = "KICK",
				["INSTANCE_DESTROY"] = "KICK",
				["RANDOM_FLY"] = "KICK",
				["NOCLIP_SUSPICIOUS"] = "KICK",
				["TELEPORT"] = "KICK",
				["FORGED_EVENT"] = "BAN",
			},
		},
		Client = {
			ReportSuspiciousActivityToServer = true, --[[
                --> Every time the client activity is suspicious, it will send a message to server.
                If disabled, the client will just kick itself from the server.
            ]]
			ReportKeys = {
				["Instance Change"] = "INSTANCE_CHANGED",
				["Instance Destroy"] = "INSTANCE_DESTROY",
				["Random Fly"] = "RANDOM_FLY",
				["Possible NoClip"] = "NOCLIP_SUSPICIOUS",
				["Teleport"] = "TELEPORT",
				["Forged Event"] = "FORGED_EVENT",
			},
		},
		Tokens = {
			-- * A good way to encrypt your client-server communication.
			TokenByteSize = 16, --> 1 byte = 1 character
			EncryptMode = "HTTP-BASED", --> Note that this will be randomized if HTTPService is disabled.
		},
	},

	-- * Recommended to not change anything bellow this line.
	-- ! Changing anything bellow this line can cause issues with the AntiCheat.
	GameProperties = {
		GameHasHTTP = HttpService.HttpEnabled, --> You can manual change it, only if you know what you are doing.
	},
}
TheBadGuy.AntiCheatDefaultOptions = Defaults

function TheBadGuy.CreateInstance(Options: AntiCheatOptions)
	local self = setmetatable({
		State = "Loading",
		Version = "1.0.0",
		Creator = "@sincevoid",
	}, TheBadGuy)

	self.Settings = Options or Defaults
	self.Database = require(script:WaitForChild("Database"))
	self.Running = false

	function self:Warn(text: string)
		return warn(`[NoMoreCheat]: {text}`)
	end

	function self:GetSetting(name: string): any | nil
		local Separator = "/"
		local Settings = self.Settings.Properties

		local Steps = name:split(Separator)

		local StepValue = nil
		for _, IndexName: string in ipairs(Steps) do
			StepValue = Settings[IndexName]
		end
		return StepValue
	end

	function self:GenerateNewToken(): string
		local EncryptMode = self:GetSetting("Tokens/EncryptMode")
		local TokenByteSize = self:GetSetting("Tokens/TokenByteSize")

		local Encryption = {
			["HTTP-BASED"] = function()
				return (HttpService:GenerateGUID(false):sub(1, TokenByteSize))
			end,
			["RANDOMIZED"] = function()
				local Alphabet = self.Database.GetAlphabet()
				local Token = ""
				for _ = 1, TokenByteSize do
					local RandomIndex = math.random(1, #Alphabet)
					local RandomChar = Alphabet[RandomIndex] .. tostring(math.random(1, 9))
					Token = Token .. RandomChar
				end
				Token:sub(1, TokenByteSize)
				return Token
			end,
		}

		if self.Settings.GameProperties.GameHasHTTP == false then
			EncryptMode = "RANDOMIZED" --> Force randomized token generation
			self:Warn("HTTP is disabled, using randomized token generation.")
		end

		local Token = Encryption[EncryptMode]()
		return Token
	end

	self.Token = self:GenerateNewToken()

	function self:ConnectBySetting(context: string, callback: () -> nil, Event: RBXScriptSignal)
		local ShouldConnect = self:GetSetting(context)
		if ShouldConnect == true then
			return Event:Connect(callback)
		end
	end

	function self:WatchWorkspace()
		local Children = Workspace:GetChildren()

		local function OnDestroying(instance: Instance)
			instance:Clone().Parent = instance.Parent
		end
		self:ConnectBySetting("Workspace/AntiDestroy", OnDestroying, Workspace.DescendantRemoving)
	end

	function self:Start()
		--> Starting the AntiCheat Instance
		self:Warn(`Running on {self.Version} by {self.Creator}`)
		self.Running = true
		self.State = "Running"
	end

	return self
end

export type AntiCheatOptions = {
	Debug: true | false,
	Properties: {
		Workspace: {
			AntiDestroy: true | false,
			AntiPropertyChange: true | false,
		},
		Tokens: {
			TokenByteSize: number,
			EncryptMode: "HTTP-BASED" | "RANDOMIZED",
		},
		Server: {
			ServerChangesAreReplicated: true | false,
			SuspiciousActivities: {
				[string]: "KICK" | "BAN" | "MUTE" | "WARN",
				["INSTANCE_CHANGED"]: "KICK" | "BAN",
				["INSTANCE_DESTROY"]: "KICK" | "BAN",
				["RANDOM_FLY"]: "KICK" | "BAN",
				["NOCLIP_SUSPICIOUS"]: "KICK" | "BAN",
				["TELEPORT"]: "KICK" | "BAN",
				["FORGED_EVENT"]: "KICK" | "BAN",
			},
		},
		Client: {
			ReportSuspiciousActivityToServer: true | false,
			ReportKeys: {
				["Instance Change"]: "INSTANCE_CHANGED" | string,
				["Instance Destroy"]: "INSTANCE_DESTROY" | string,
				["Random Fly"]: "RANDOM_FLY" | string,
				["Possible NoClip"]: "NOCLIP_SUSPICIOUS" | string,
				["Teleport"]: "TELEPORT" | string,
				["Forged Event"]: "FORGED_EVENT" | string,
			},
		},
	},
	GameProperties: {
		GameHasHTTP: true | false,
	},
}
return TheBadGuy
