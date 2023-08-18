repeat
	task.wait()
until game:IsLoaded() == true

local NoMoreCheat = require(script.Parent:WaitForChild("NoMoreCheat"))
NoMoreCheat.CreateInstance():Start()

script.Parent = nil -- ! IMPORTANT ! --
