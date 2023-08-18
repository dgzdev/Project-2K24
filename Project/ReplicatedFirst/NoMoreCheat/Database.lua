local Data = {}

Data.General = {}
Data.States = {
	["Loading"] = 0,
	["Running"] = 1,
	["Stopped"] = 2,
	["Error"] = 3,
}
Data.StateNumbers = {
	[0] = nil,
	[1] = "ON",
	[2] = "OFF",
	[3] = "ERROR",
}
Data.Conversions = {
	["ON"] = true,
	["OFF"] = false,
	["ERROR"] = false,
}
Data.Alphabet = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"

function Data.GetConversion(string: string): any
	return Data.Conversions[string]
end
function Data.GetStateString(number: number): string
	return Data.StateNumbers[number]
end
function Data.GetAlphabet(): { string }
	return Data.Alphabet:split(",")
end

return Data
