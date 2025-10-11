local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Notification = {}
Notification.__index = Notification

local function makeCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
end

local function getScaledWidth()
	local screenWidth = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1920
	return math.clamp(screenWidth * 0.18, 240, 380)
end

function Notification:GetContainer()
	local gui = playerGui:FindFirstChild("NotificationUI")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "NotificationUI"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.Parent = playerGui
	end

	local container = gui:FindFirstChild("Container")
	if not container then
		container = Instance.new("Frame")
		container.Name = "Container"
		container.BackgroundTransparency = 1
		container.AnchorPoint = Vector2.new(1, 1)
		container.Position = UDim2.new(1, -20, 1, -20)
		container.Size = UDim2.new(0, getScaledWidth(), 1, -40)
		container.Parent = gui

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.Parent = container

		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			container.Size = UDim2.new(0, getScaledWidth(), 1, -40)
		end)
	end

	return container
end

function Notification:Show(data)
	local container = self:GetContainer()
	local title = data.Title or "Notification"
	local text = data.Text or ""
	local icon = data.Icon or ""
	local iconColor = data.IconColor or Color3.fromRGB(255, 255, 255)
	local duration = data.Duration or 4
	local bgColor = data.Background or Color3.fromRGB(25, 25, 25)
	local textColor = data.TextColor or Color3.fromRGB(255, 255, 255)
	local transparency = data.Transparency or false
	local frameTransparency = transparency and 0.4 or 0

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, math.clamp(workspace.CurrentCamera.ViewportSize.Y * 0.08, 60, 100))
	frame.BackgroundColor3 = bgColor
	frame.BackgroundTransparency = frameTransparency
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = container
	makeCorner(frame, 10)

	-- Icon
	if icon and icon ~= "" then
		local iconLabel = Instance.new("ImageLabel")
		iconLabel.Image = icon
		iconLabel.Size = UDim2.new(0, 40, 0, 40)
		iconLabel.Position = UDim2.new(0, 10, 0, 10)
		iconLabel.BackgroundTransparency = 1
		iconLabel.ImageColor3 = iconColor
		iconLabel.Parent = frame
	end

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 60, 0, 8)
	titleLabel.Size = UDim2.new(1, -90, 0, 20)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = textColor
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = title
	titleLabel.Parent = frame

	-- Message
	local messageLabel = Instance.new("TextLabel")
	messageLabel.BackgroundTransparency = 1
	messageLabel.Position = UDim2.new(0, 60, 0, 30)
	messageLabel.Size = UDim2.new(1, -70, 1, -40)
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.TextSize = 14
	messageLabel.TextWrapped = true
	messageLabel.TextScaled = true
	messageLabel.TextColor3 = textColor
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextYAlignment = Enum.TextYAlignment.Top
	messageLabel.Text = text
	messageLabel.Parent = frame

	-- Close button (TextButton)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "×"
	closeBtn.TextScaled = true
	closeBtn.BackgroundTransparency = 1
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -30, 0, 6)
	closeBtn.Parent = frame

	closeBtn.MouseButton1Click:Connect(function()
		local tween = TweenService:Create(frame, TweenInfo.new(0.25), {
			BackgroundTransparency = 1,
			Position = UDim2.new(1, getScaledWidth() + 10, 0, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		frame:Destroy()
	end)

	-- Animation vào
	frame.Position = UDim2.new(1, getScaledWidth() + 10, 0, 0)
	TweenService:Create(frame, TweenInfo.new(0.25), {
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = frameTransparency
	}):Play()

	-- Click frame callback
	if data.OnClicked then
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				pcall(data.OnClicked)
			end
		end)
	end

	-- Auto destroy sau duration
	task.spawn(function()
		task.wait(duration)
		if frame and frame.Parent then
			local tween = TweenService:Create(frame, TweenInfo.new(0.25), {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, getScaledWidth() + 10, 0, 0)
			})
			tween:Play()
			tween.Completed:Wait()
			frame:Destroy()
		end
	end)
end


return setmetatable({}, Notification)
