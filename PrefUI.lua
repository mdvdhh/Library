--[[  ⚙️ PrefUI Library
     Tự động scale, có Tab, Button, Toggle, Dropdown, Textbox, Slider, Dragging, UI Corner.
     Bản này không cần tải từ GitHub — chạy độc lập.
]]--

local PrefUI = {}

-- 🪟 Tạo cửa sổ
function PrefUI:CreateWindow(config)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Pref UI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = game:GetService("CoreGui")

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = config.Size or UDim2.fromOffset(600, 420)
	Main.Position = UDim2.new(0.5, -Main.Size.X.Offset / 2, 0.5, -Main.Size.Y.Offset / 2)
	Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Main.Active = true
	Main.Draggable = true
	Main.Parent = ScreenGui

	local UICorner = Instance.new("UICorner", Main)
	UICorner.CornerRadius = UDim.new(0, 5)

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Text = config.Title or "Pref UI"
	Title.Size = UDim2.new(1, 0, 0, 35)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.Parent = Main

	local Close = Instance.new("TextButton")
	Close.Name = "Close"
	Close.Size = UDim2.new(0, 35, 0, 35)
	Close.Position = UDim2.new(1, -40, 0, 0)
	Close.BackgroundTransparency = 1
	Close.Text = "X"
	Close.TextColor3 = Color3.fromRGB(255, 80, 80)
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 18
	Close.Parent = Main

	local TabHolder = Instance.new("Frame")
	TabHolder.Name = "TabHolder"
	TabHolder.BackgroundTransparency = 1
	TabHolder.Size = UDim2.new(1, -20, 1, -50)
	TabHolder.Position = UDim2.new(0, 10, 0, 40)
	TabHolder.Parent = Main

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 8)
	UIListLayout.Parent = TabHolder

	local tabs = {}

	function tabs:AddTab(name)
		local Tab = Instance.new("Frame")
		Tab.Name = name
		Tab.Size = UDim2.new(1, -10, 1, -10)
		Tab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		Tab.Visible = false
		Tab.Parent = Main

		local Btn = Instance.new("TextButton")
		Btn.Text = name
		Btn.Size = UDim2.new(0, 100, 0, 35)
		Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		Btn.TextColor3 = Color3.new(1, 1, 1)
		Btn.Parent = TabHolder

		local UIC = Instance.new("UICorner", Btn)
		UIC.CornerRadius = UDim.new(0, 5)

		Btn.MouseButton1Click:Connect(function()
			for _, t in ipairs(Main:GetChildren()) do
				if t:IsA("Frame") and t ~= TabHolder and t.Name ~= "Main" then
					t.Visible = false
				end
			end
			Tab.Visible = true
		end)

		local list = Instance.new("UIListLayout", Tab)
		list.Padding = UDim.new(0, 6)

		local functions = {}

		function functions:Button(info)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, -10, 0, 30)
			b.Text = info.Text
			b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Font = Enum.Font.Gotham
			b.TextSize = 14
			b.Parent = Tab
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
			b.MouseButton1Click:Connect(function() info.Callback() end)
		end

		function functions:Toggle(info)
			local t = Instance.new("TextButton")
			t.Size = UDim2.new(1, -10, 0, 30)
			t.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			t.Text = info.Text .. ": OFF"
			t.TextColor3 = Color3.new(1, 1, 1)
			t.Font = Enum.Font.Gotham
			t.TextSize = 14
			t.Parent = Tab
			Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
			local state = info.Default or false
			t.MouseButton1Click:Connect(function()
				state = not state
				t.Text = info.Text .. ": " .. (state and "ON" or "OFF")
				info.Callback(state)
			end)
		end

		function functions:Textbox(info)
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1, -10, 0, 30)
			box.PlaceholderText = info.Placeholder or "Type here..."
			box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			box.TextColor3 = Color3.new(1, 1, 1)
			box.ClearTextOnFocus = false
			box.Parent = Tab
			Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
			box.FocusLost:Connect(function()
				info.Callback(box.Text)
			end)
		end

		function functions:Slider(info)
			local sliderFrame = Instance.new("Frame")
			sliderFrame.Size = UDim2.new(1, -10, 0, 40)
			sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			sliderFrame.Parent = Tab
			Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 5)

			local label = Instance.new("TextLabel", sliderFrame)
			label.Size = UDim2.new(1, 0, 0, 20)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Font = Enum.Font.Gotham
			label.TextSize = 14
			label.Text = info.Text .. ": " .. info.Default

			local bar = Instance.new("Frame", sliderFrame)
			bar.Size = UDim2.new(1, -10, 0, 5)
			bar.Position = UDim2.new(0, 5, 1, -10)
			bar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)

			local fill = Instance.new("Frame", bar)
			fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			fill.Size = UDim2.new((info.Default - info.Min) / (info.Max - info.Min), 0, 1, 0)

			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local move, release
					move = game:GetService("UserInputService").InputChanged:Connect(function(changed)
						if changed.UserInputType == Enum.UserInputType.MouseMovement then
							local ratio = math.clamp((changed.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
							local value = math.floor(info.Min + ratio * (info.Max - info.Min))
							fill.Size = UDim2.new(ratio, 0, 1, 0)
							label.Text = info.Text .. ": " .. value
							info.Callback(value)
						end
					end)
					release = game:GetService("UserInputService").InputEnded:Connect(function(endInput)
						if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
							move:Disconnect()
							release:Disconnect()
						end
					end)
				end
			end)
		end

		Tab.Visible = true
		return functions
	end

	Close.MouseButton1Click:Connect(function()
		Main.Visible = not Main.Visible
	end)

	return tabs
end

return PrefUI
