--[[

        2 Buttons

--]] 

local NotificationModule = loadstring(game:HttpGet('https://raw.githubusercontent.com/ZLens/ryza.us/refs/heads/main/public/notifications.lua'))()

NotificationModule.fire({
	title = 'Join our discord!',
	desc = 'Ensure you join our discord server, all of our updates are located here.',
	config = {
		autoClose = false,
		autoCloseTime = 5,
		buttons = {
			{
				buttonText = 'Cancel',
				buttonFunction = function()
					print("cancel")
				end,
			},
			{
				buttonText = 'Continue',
				buttonFunction = function()
					print("continue")
					if setclipboard then
						setclipboard("https://discord.gg/ryzaus")
					end
				end,
			},
		}
	}
})

--[[

        1 Button

--]] 

local NotificationModule = loadstring(game:HttpGet('https://raw.githubusercontent.com/ZLens/ryza.us/refs/heads/main/public/notifications.lua'))()

NotificationModule.fire({
	title = 'Join our discord!',
	desc = 'Ensure you join our discord server, all of our updates are located here.',
	config = {
		autoClose = false,
		autoCloseTime = 5,
		buttons = {
			{
				buttonText = 'Continue',
				buttonFunction = function()
					print("continue")
					if setclipboard then
						setclipboard("https://discord.gg/ryzaus")
					end
				end,
			},
		}
	}
})
