local WertUi = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local CoreGui = gethui and gethui() or game:GetService("CoreGui")

local ScreenGui = CoreGui:FindFirstChild("WertUi_Notifications") or Instance.new("ScreenGui")
ScreenGui.Name = "WertUi_Notifications"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local HolderFrame = ScreenGui:FindFirstChild("NotificationHolder") or Instance.new("Frame")
HolderFrame.Name = "NotificationHolder"
HolderFrame.BackgroundTransparency = 1
HolderFrame.AnchorPoint = Vector2.new(1, 1)
HolderFrame.Parent = ScreenGui

local HolderLayout = HolderFrame:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
HolderLayout.Padding = UDim.new(0, 10)
HolderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
HolderLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
HolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
HolderLayout.Parent = HolderFrame

local function updateHolderPosition()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local screenSize = camera.ViewportSize
	local width = math.clamp(screenSize.X * 0.35, 280, 400)
	local padding = math.clamp(screenSize.X * 0.02, 10, 25)
	HolderFrame.Size = UDim2.new(0, width, 1, -40)
	HolderFrame.Position = UDim2.new(1, -padding, 1, -padding)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateHolderPosition)
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateHolderPosition)
end
task.defer(updateHolderPosition)

function WertUi:Notify(settings)
	local Title = settings.Title or "Notification"
	local Description = settings.Description or ""
	local Duration = settings.Duration or 5
	local CornerRadius = UDim.new(0, settings.Corner or 8)
	local Transparent = settings.Transparent or 0.2
	local Icon = settings.Icon or "rbxassetid://6034509993"

	local Frame = Instance.new("Frame")
	Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Frame.BackgroundTransparency = Transparent
	Frame.Size = UDim2.new(1, 0, 0, 60)
	Frame.AutomaticSize = Enum.AutomaticSize.Y
	Frame.ClipsDescendants = true
	Frame.Parent = HolderFrame

	local Corner = Instance.new("UICorner", Frame)
	Corner.CornerRadius = CornerRadius

	local Padding = Instance.new("UIPadding", Frame)
	Padding.PaddingTop = UDim.new(0, 10)
	Padding.PaddingBottom = UDim.new(0, 10)
	Padding.PaddingLeft = UDim.new(0, 10)
	Padding.PaddingRight = UDim.new(0, 10)

	local IconLabel = Instance.new("ImageLabel")
	IconLabel.Image = Icon
	IconLabel.BackgroundTransparency = 1
	IconLabel.Size = UDim2.new(0, 24, 0, 24)
	IconLabel.Position = UDim2.new(0, 0, 0, 0)
	IconLabel.Parent = Frame

	local CloseButton = Instance.new("TextButton")
	CloseButton.Text = "×"
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.TextSize = 14
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Size = UDim2.new(0, 20, 0, 20)
	CloseButton.Position = UDim2.new(1, -25, 0, 5)
	CloseButton.Parent = Frame

	local TextHolder = Instance.new("Frame")
	TextHolder.BackgroundTransparency = 1
	TextHolder.Size = UDim2.new(1, -70, 1, 0)
	TextHolder.Position = UDim2.new(0, 35, 0, 0)
	TextHolder.AutomaticSize = Enum.AutomaticSize.Y
	TextHolder.Parent = Frame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = Title
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 16
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.TextScaled = true
	TitleLabel.AutomaticSize = Enum.AutomaticSize.Y
	TitleLabel.Size = UDim2.new(1, 0, 0, 20)
	TitleLabel.Parent = TextHolder

	local DescriptionLabel = Instance.new("TextLabel")
	DescriptionLabel.Text = Description
	DescriptionLabel.Font = Enum.Font.Gotham
	DescriptionLabel.TextSize = 14
	DescriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	DescriptionLabel.BackgroundTransparency = 1
	DescriptionLabel.TextWrapped = true
	DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
	DescriptionLabel.AutomaticSize = Enum.AutomaticSize.Y
	DescriptionLabel.Size = UDim2.new(1, 0, 0, 20)
	DescriptionLabel.Position = UDim2.new(0, 0, 0, 22)
	DescriptionLabel.Parent = TextHolder

	Frame.BackgroundTransparency = 1
	Frame.Position = UDim2.new(1, 500, 0, 0)
	local tweenIn = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = Transparent
	})
	tweenIn:Play()

	local function removeNotification()
		local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 500, 0, 0),
			BackgroundTransparency = 1
		})
		tweenOut:Play()
		tweenOut.Completed:Connect(function()
			Frame:Destroy()
		end)
	end

	CloseButton.MouseButton1Click:Connect(removeNotification)
	task.delay(Duration, removeNotification)
end

return WertUi

