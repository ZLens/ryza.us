local NotificationModule = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local PADDING = 18
local MIN_WIDTH = 260
local MIN_HEIGHT = 140
local CORNER_RADIUS = 16
local BUTTON_HEIGHT = 48
local TITLE_FONT = Enum.Font.MontserratBold
local DESC_FONT = Enum.Font.Montserrat
local BUTTON_FONT = Enum.Font.MontserratMedium
local TITLE_SIZE = 17
local DESC_SIZE = 15
local BUTTON_TEXT_SIZE = 15
local HAPTIC_FEEDBACK = false

local SPRING_ANIMATION = {
	APPEAR = TweenInfo.new(
		0.45,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out,
		0,
		false,
		0,
		0.85
	),
	DISAPPEAR = TweenInfo.new(
		0.25,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.In,
		0,
		false,
		0
	),
	BUTTON_PRESS = TweenInfo.new(
		0.08,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	)
}

local function addButtonAnimation(button)
	local originalColor = button.TextColor3
	local pressedColor = Color3.fromRGB(26, 93, 204)
	local originalScale = 1
	local pressedScale = 0.97

	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, SPRING_ANIMATION.BUTTON_PRESS, {
			TextColor3 = pressedColor,
			TextTransparency = 0.2,
			Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset * pressedScale)
		}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, SPRING_ANIMATION.BUTTON_PRESS, {
			TextColor3 = originalColor,
			TextTransparency = 0,
			Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset / pressedScale)
		}):Play()
	end)
end

function NotificationModule.fire(options)
	options = options or {}
	options.title = options.title or "Notification"
	options.desc = options.desc or "Description"
	options.config = options.config or {}

	local config = options.config
	config.autoClose = config.autoClose ~= nil and config.autoClose or false
	config.autoCloseTime = config.autoCloseTime or 5
	config.buttons = config.buttons or {
		{
			buttonText = "Close",
			buttonFunction = function() end
		}
	}
	config.blurBackground = config.blurBackground ~= nil and config.blurBackground or true

	local existingNotification = PlayerGui:FindFirstChild("NotificationGui")
	if existingNotification then
		existingNotification:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "NotificationGui"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 0.5
	background.Size = UDim2.fromScale(1, 1)
	background.ZIndex = 10
	background.Parent = gui

	if config.blurBackground then
		local blur = Instance.new("BlurEffect")
		blur.Name = "BackgroundBlur"
		blur.Size = 0
		blur.Parent = game:GetService("Lighting")

		game:GetService("TweenService"):Create(
			blur, 
			TweenInfo.new(0.25),
			{Size = 12}
		):Play()

		gui.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				game:GetService("TweenService"):Create(
					blur, 
					TweenInfo.new(0.25),
					{Size = 0}
				):Play()
				game:GetService("Debris"):AddItem(blur, 0.25)
			end
		end)
	end

	local titleDimensions = TextService:GetTextSize(
		options.title,
		TITLE_SIZE,
		TITLE_FONT,
		Vector2.new(MIN_WIDTH - (PADDING * 2), math.huge)
	)

	local descDimensions = TextService:GetTextSize(
		options.desc,
		DESC_SIZE,
		DESC_FONT,
		Vector2.new(MIN_WIDTH - (PADDING * 2), math.huge)
	)

	local contentHeight = titleDimensions.Y + 10 + descDimensions.Y
	local totalWidth = math.max(MIN_WIDTH, math.max(titleDimensions.X, descDimensions.X) + (PADDING * 2))
	local totalHeight = PADDING * 2 + contentHeight

	totalHeight = totalHeight + BUTTON_HEIGHT

	local notification = Instance.new("Frame")
	notification.Name = "Notification"
	notification.AnchorPoint = Vector2.new(0.5, 0.5)
	notification.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
	notification.Position = UDim2.fromScale(0.5, 0.5)
	notification.Size = UDim2.fromOffset(totalWidth, totalHeight)
	notification.ZIndex = 11
	notification.Parent = gui

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.fromScale(0.5, 0.5)
	shadow.Size = UDim2.new(1, 12, 1, 12)
	shadow.ZIndex = 10
	shadow.Image = "rbxassetid://131742137"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(16, 16, 16, 16)
	shadow.Parent = notification

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, CORNER_RADIUS)
	corner.Parent = notification

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Font = TITLE_FONT
	title.Text = options.title
	title.TextColor3 = Color3.fromRGB(0, 0, 0)
	title.TextSize = TITLE_SIZE
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(PADDING, PADDING)
	title.Size = UDim2.new(1, -PADDING * 2, 0, titleDimensions.Y)
	title.ZIndex = 12
	title.Parent = notification

	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.Font = DESC_FONT
	description.Text = options.desc
	description.TextColor3 = Color3.fromRGB(40, 40, 40)
	description.TextSize = DESC_SIZE
	description.TextXAlignment = Enum.TextXAlignment.Center
	description.TextWrapped = true
	description.BackgroundTransparency = 1
	description.Position = UDim2.new(0, PADDING, 0, PADDING + titleDimensions.Y + 10)
	description.Size = UDim2.new(1, -PADDING * 2, 0, descDimensions.Y)
	description.AutomaticSize = Enum.AutomaticSize.Y
	description.ZIndex = 12
	description.Parent = notification

	local separator = Instance.new("Frame")
	separator.Name = "Separator"
	separator.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	separator.BorderSizePixel = 0
	separator.Position = UDim2.new(0, 0, 1, -BUTTON_HEIGHT)
	separator.Size = UDim2.new(1, 0, 0, 1)
	separator.ZIndex = 12
	separator.Parent = notification

	local buttonCount = #config.buttons
	local buttonWidth = totalWidth / buttonCount

	for i, buttonData in ipairs(config.buttons) do
		local button = Instance.new("TextButton")
		button.Name = "Button" .. i
		button.Font = BUTTON_FONT
		button.Text = buttonData.buttonText
		button.TextColor3 = Color3.fromRGB(0, 122, 255)
		button.TextSize = BUTTON_TEXT_SIZE
		button.BackgroundTransparency = 1
		button.Position = UDim2.new(0, (i-1) * buttonWidth, 1, -BUTTON_HEIGHT)
		button.Size = UDim2.new(0, buttonWidth, 0, BUTTON_HEIGHT)
		button.ZIndex = 12
		button.Parent = notification

		addButtonAnimation(button)

		button.MouseButton1Click:Connect(function()
			if HAPTIC_FEEDBACK then
			end

			local fadeOutInfo = SPRING_ANIMATION.DISAPPEAR
			local fadeOut = TweenService:Create(notification, fadeOutInfo, {
				Position = UDim2.new(0.5, 0, 0.5, 10),
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(totalWidth * 0.92, totalHeight * 0.92)
			})

			local shadowFadeOut = TweenService:Create(shadow, fadeOutInfo, {
				ImageTransparency = 1
			})

			local bgFadeOut = TweenService:Create(background, fadeOutInfo, {
				BackgroundTransparency = 1
			})

			fadeOut:Play()
			shadowFadeOut:Play()
			bgFadeOut:Play()

			if buttonData.buttonFunction then
				task.spawn(buttonData.buttonFunction)
			end

			task.delay(fadeOutInfo.Time, function()
				if gui and gui.Parent then
					gui:Destroy()
				end
			end)
		end)

		if i < buttonCount then
			local buttonSeparator = Instance.new("Frame")
			buttonSeparator.Name = "ButtonSeparator" .. i
			buttonSeparator.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
			buttonSeparator.BorderSizePixel = 0
			buttonSeparator.Position = UDim2.new(0, i * buttonWidth, 1, -BUTTON_HEIGHT)
			buttonSeparator.Size = UDim2.new(0, 1, 0, BUTTON_HEIGHT)
			buttonSeparator.ZIndex = 12
			buttonSeparator.Parent = notification
		end
	end

	notification.Position = UDim2.new(0.5, 0, 0.5, -10)
	notification.BackgroundTransparency = 1
	notification.Size = UDim2.fromOffset(totalWidth * 0.92, totalHeight * 0.92)
	shadow.ImageTransparency = 1
	title.TextTransparency = 1
	description.TextTransparency = 1
	background.BackgroundTransparency = 1

	local fadeInInfo = SPRING_ANIMATION.APPEAR

	local fadeIn = TweenService:Create(notification, fadeInInfo, {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(totalWidth, totalHeight)
	})

	local shadowFadeIn = TweenService:Create(shadow, TweenInfo.new(
		fadeInInfo.Time * 1.1, 
		fadeInInfo.EasingStyle, 
		fadeInInfo.EasingDirection, 
		0, false, 
		0.02
		), {
			ImageTransparency = 0.6
		})

	local textFadeIn = TweenService:Create(title, TweenInfo.new(
		fadeInInfo.Time, 
		fadeInInfo.EasingStyle, 
		fadeInInfo.EasingDirection, 
		0, false, 
		0.05
		), {
			TextTransparency = 0
		})

	local descFadeIn = TweenService:Create(description, TweenInfo.new(
		fadeInInfo.Time, 
		fadeInInfo.EasingStyle, 
		fadeInInfo.EasingDirection, 
		0, false, 
		0.1
		), {
			TextTransparency = 0
		})

	local bgFadeIn = TweenService:Create(background, fadeInInfo, {
		BackgroundTransparency = 0.5
	})

	fadeIn:Play()
	shadowFadeIn:Play()
	textFadeIn:Play()
	descFadeIn:Play()
	bgFadeIn:Play()

	if config.autoClose then
		task.delay(config.autoCloseTime, function()
			if gui and gui.Parent then
				local fadeOutInfo = SPRING_ANIMATION.DISAPPEAR
				local fadeOut = TweenService:Create(notification, fadeOutInfo, {
					Position = UDim2.new(0.5, 0, 0.5, 10),
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(totalWidth * 0.92, totalHeight * 0.92)
				})

				local shadowFadeOut = TweenService:Create(shadow, fadeOutInfo, {
					ImageTransparency = 1
				})

				local bgFadeOut = TweenService:Create(background, fadeOutInfo, {
					BackgroundTransparency = 1
				})

				fadeOut:Play()
				shadowFadeOut:Play()
				bgFadeOut:Play()

				task.delay(fadeOutInfo.Time, function()
					if gui and gui.Parent then
						gui:Destroy()
					end
				end)
			end
		end)
	end

	return notification
end

return NotificationModule
