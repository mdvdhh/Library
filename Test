-- PrefUI.lua -- Lightweight, modern-looking UI Library for Roblox -- Features: draggable window, UICorner (Radius 5), Tabs, Button, Toggle, Dropdown, Textbox, Slider, -- Toggle Open/Close (collapse), auto-scaling for different devices -- Usage: local PrefUI = require(path_to_this_module) --        local win = PrefUI:CreateWindow({Title = "My UI", Size = UDim2.fromOffset(600, 420)}) --        local tab = win:AddTab("Main") --        tab:Button({Text = "Click me", Callback = function() print("Clicked") end})

local TweenService = game:GetService("TweenService") local UserInputService = game:GetService("UserInputService") local RunService = game:GetService("RunService")

local PrefUI = {} PrefUI.__index = PrefUI

local function newInstance(class, props) local obj = Instance.new(class) if props then for k,v in pairs(props) do if k == "Parent" then obj.Parent = v else pcall(function() obj[k] = v end) end end end return obj end

-- Utility: make rounded corner local function addCorner(inst, radius) local uc = newInstance("UICorner", {Parent = inst}) uc.CornerRadius = UDim.new(0, radius or 5) return uc end

-- Draggable behaviour for a frame local function makeDraggable(frame, dragHandle) dragHandle = dragHandle or frame local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

end

-- Auto scale helper: adds UIScale and ensures min/max sizes via constraints local function applyAutoScale(guiObject) local uiScale = newInstance("UIScale", {Parent = guiObject}) -- scale based on screen diagonal (heuristic) local function refresh() local sizeX = workspace.CurrentCamera.ViewportSize.X local sizeY = workspace.CurrentCamera.ViewportSize.Y local diag = math.sqrt(sizeXsizeX + sizeYsizeY) -- base diagonal 900 ~= scale 1 local scale = math.clamp(diag/900, 0.8, 1.6) uiScale.Scale = scale end refresh() RunService:GetPropertyChangedSignal("RenderStepped"):Connect(function() end) UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function() refresh() end) workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh) end

-- Create Window function PrefUI:CreateWindow(opts) opts = opts or {} local title = opts.Title or "Pref UI" local size = opts.Size or UDim2.fromOffset(580, 420) local minSize = opts.MinSize or Vector2.new(380, 240) local maxSize = opts.MaxSize or Vector2.new(1400, 900)

local screenGui = newInstance("ScreenGui", {Parent = game:GetService("CoreGui"), Name = title .. "_PrefUI"})
screenGui.ResetOnSpawn = false

local main = newInstance("Frame", {
    Parent = screenGui,
    Name = "Window",
    Size = size,
    Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(30, 30, 35),
})
addCorner(main, 5)

-- UI constraint (min/max)
local constraint = newInstance("UISizeConstraint", {Parent = main})
constraint.MinSize = minSize
constraint.MaxSize = maxSize

applyAutoScale(main)

-- Top bar (title + open/close)
local top = newInstance("Frame", {Parent = main, Name = "TopBar", Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
local titleLbl = newInstance("TextLabel", {Parent = top, Text = title, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -80, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Color3.fromRGB(240,240,240)})

local toggleBtn = newInstance("TextButton", {Parent = top, Name = "ToggleBtn", Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(1, -72, 0, 4), BackgroundTransparency = 0, Text = "Close", AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 14})
toggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
addCorner(toggleBtn, 5)

-- Main container: left tabs, right content
local container = newInstance("Frame", {Parent = main, Name = "Container", Position = UDim2.new(0, 10, 0, 46), Size = UDim2.new(1, -20, 1, -56), BackgroundTransparency = 1})

local left = newInstance("Frame", {Parent = container, Name = "Left", Size = UDim2.new(0, 160, 1, 0), BackgroundTransparency = 1})
local leftLayout = newInstance("UIListLayout", {Parent = left, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
local leftPadding = newInstance("UIPadding", {Parent = left, PaddingLeft = UDim.new(0,8), PaddingTop = UDim.new(0,6), PaddingRight = UDim.new(0,8)})

local right = newInstance("Frame", {Parent = container, Name = "Right", Position = UDim2.new(0, 170, 0, 0), Size = UDim2.new(1, -170, 1, 0), BackgroundTransparency = 1})

local tabsFolder = {}

-- Tab selection
local function selectTab(key)
    for k,v in pairs(tabsFolder) do
        v.Panel.Visible = false
        v.Button.BackgroundColor3 = Color3.fromRGB(45,45,50)
        v.Button.TextColor3 = Color3.fromRGB(200,200,200)
    end
    if tabsFolder[key] then
        tabsFolder[key].Panel.Visible = true
        tabsFolder[key].Button.BackgroundColor3 = Color3.fromRGB(70,70,75)
        tabsFolder[key].Button.TextColor3 = Color3.fromRGB(250,250,250)
    end
end

-- AddTab method
local window = {}
function window:AddTab(name)
    local key = name
    -- button
    local btn = newInstance("TextButton", {Parent = left, Text = name, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 0, Font = Enum.Font.Gotham, TextSize = 15, AutoButtonColor = false})
    addCorner(btn, 5)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
    btn.TextColor3 = Color3.fromRGB(200,200,200)

    -- content panel
    local panel = newInstance("ScrollingFrame", {Parent = right, Name = name .. "Panel", Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(0,0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 6})
    local layout = newInstance("UIListLayout", {Parent = panel, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
    local pad = newInstance("UIPadding", {Parent = panel, PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,10)})

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        panel.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
    end)

    btn.MouseButton1Click:Connect(function()
        selectTab(key)
    end)

    tabsFolder[key] = {Button = btn, Panel = panel}

    -- API for elements
    local tabApi = {}

    function tabApi:Button(opts)
        opts = opts or {}
        local text = opts.Text or "Button"
        local callback = opts.Callback or function() end
        local frame = newInstance("Frame", {Parent = panel, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
        local btn = newInstance("TextButton", {Parent = frame, Size = UDim2.new(1,0,1,0), Text = text, BackgroundTransparency = 0, AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 15})
        btn.BackgroundColor3 = Color3.fromRGB(60,60,66)
        btn.TextColor3 = Color3.fromRGB(240,240,240)
        addCorner(btn, 5)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    function tabApi:Toggle(opts)
        opts = opts or {}
        local text = opts.Text or "Toggle"
        local default = opts.Default or false
        local callback = opts.Callback or function() end
        local frame = newInstance("Frame", {Parent = panel, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
        local label = newInstance("TextLabel", {Parent = frame, Text = text, Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 15, TextColor3 = Color3.fromRGB(230,230,230)})
        local toggle = newInstance("Frame", {Parent = frame, Size = UDim2.new(0,46,0,24), Position = UDim2.new(1, -46, 0.5, -12), BackgroundColor3 = Color3.fromRGB(70,70,75)})
        addCorner(toggle, 12)
        local knob = newInstance("Frame", {Parent = toggle, Size = UDim2.new(0,20,0,20), Position = UDim2.new(default and 1 or 0, default and -22 or 4,0.5,-10), BackgroundColor3 = Color3.fromRGB(240,240,240)})
        addCorner(knob, 10)

        local state = default
        local function setState(s)
            state = s
            if state then
                TweenService:Create(toggle, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(90, 170, 255)}):Play()
                TweenService:Create(knob, TweenInfo.new(0.18), {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
            else
                TweenService:Create(toggle, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(70,70,75)}):Play()
                TweenService:Create(knob, TweenInfo.new(0.18), {Position = UDim2.new(0, 4, 0.5, -10)}):Play()
            end
            pcall(callback, state)
        end

        toggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setState(not state)
            end
        end)

        setState(default)
        return {Get = function() return state end, Set = setState}
    end

    function tabApi:Dropdown(opts)
        opts = opts or {}
        local text = opts.Text or "Select"
        local items = opts.Items or {}
        local callback = opts.Callback or function() end

        local frame = newInstance("Frame", {Parent = panel, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
        local label = newInstance("TextLabel", {Parent = frame, Text = text, Size = UDim2.new(1, -36, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 15, TextColor3 = Color3.fromRGB(230,230,230)})
        local arrow = newInstance("TextButton", {Parent = frame, Text = "v", Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-34,0.5,-14), BackgroundTransparency = 0, AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 14})
        arrow.BackgroundColor3 = Color3.fromRGB(60,60,66)
        addCorner(arrow, 6)

        local dropdown = newInstance("Frame", {Parent = right, Size = UDim2.new(0,200,0,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(40,40,45), Visible = false})
        addCorner(dropdown, 6)
        local list = newInstance("UIListLayout", {Parent = dropdown, SortOrder = Enum.SortOrder.LayoutOrder})

        local function refreshItems()
            for i,v in ipairs(dropdown:GetChildren()) do
                if v:IsA("TextButton") and v.Name == "Item" then v:Destroy() end
            end
            for i,item in ipairs(items) do
                local it = newInstance("TextButton", {Parent = dropdown, Name = "Item", Text = item, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0, AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 14})
                it.BackgroundTransparency = 0
                it.TextColor3 = Color3.fromRGB(230,230,230)
                it.MouseButton1Click:Connect(function()
                    label.Text = item
                    dropdown.Visible = false
                    pcall(callback,item)
                end)
            end
            dropdown.Size = UDim2.new(0,200,0, math.clamp(#items*30, 0, 240))
        end
        refreshItems()

        arrow.MouseButton1Click:Connect(function()
            dropdown.Position = UDim2.new(0, (main.AbsolutePosition.X + main.AbsoluteSize.X) > (workspace.CurrentCamera.ViewportSize.X - 220) and main.AbsolutePosition.X - 210 or main.AbsolutePosition.X + 170, 0, main.AbsolutePosition.Y + 70)
            dropdown.Visible = not dropdown.Visible
        end)

        return {SetItems = function(t) items = t; refreshItems() end, GetValue = function() return label.Text end}
    end

    function tabApi:Textbox(opts)
        opts = opts or {}
        local placeholder = opts.Placeholder or "Enter text..."
        local callback = opts.Callback or function() end
        local frame = newInstance("Frame", {Parent = panel, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
        local box = newInstance("TextBox", {Parent = frame, Text = "", PlaceholderText = placeholder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 0, Font = Enum.Font.Gotham, TextSize = 15, ClearTextOnFocus = false})
        box.BackgroundColor3 = Color3.fromRGB(50,50,56)
        box.TextColor3 = Color3.fromRGB(240,240,240)
        addCorner(box, 6)
        box.FocusLost:Connect(function(enter)
            pcall(callback, box.Text, enter)
        end)
        return box
    end

    function tabApi:Slider(opts)
        opts = opts or {}
        local text = opts.Text or "Slider"
        local min = opts.Min or 0
        local max = opts.Max or 100
        local step = opts.Step or 1
        local default = opts.Default or min
        local callback = opts.Callback or function() end

        local frame = newInstance("Frame", {Parent = panel, Size = UDim2.new(1,0,0,56), BackgroundTransparency = 1})
        local label = newInstance("TextLabel", {Parent = frame, Text = text .. " - " .. tostring(default), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(230,230,230)})
        local bar = newInstance("Frame", {Parent = frame, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,28), BackgroundColor3 = Color3.fromRGB(60,60,66)})
        addCorner(bar, 6)
        local fill = newInstance("Frame", {Parent = bar, Size = UDim2.new( (default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(90,170,255)})
        addCorner(fill, 6)
        local knob = newInstance("ImageButton", {Parent = bar, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(fill.Size.X.Scale, -9, 0.5, -9), BackgroundTransparency = 1, Image = "rbxasset://textures/space.png"})
        addCorner(knob, 9)

        local dragging = false
        local function setValueFromPos(x)
            local relative = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local raw = min + (max-min) * relative
            local stepped = math.floor((raw/step)+0.5) * step
            local value = math.clamp(stepped, min, max)
            local proportion = (value-min)/(max-min)
            fill:TweenSize(UDim2.new(proportion,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
            knob:TweenPosition(UDim2.new(proportion, -9, 0.5, -9), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
            label.Text = text .. " - " .. tostring(value)
            pcall(callback, value)
        end

        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setValueFromPos(input.Position.X)
            end
        end)

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setValueFromPos(input.Position.X)
            end
        end)

        -- set initial
        setValueFromPos(bar.AbsolutePosition.X + bar.AbsoluteSize.X * ((default-min)/(max-min)))

        return {Get = function() return tonumber(string.match(label.Text, "%-%s(.+)$")) or default end, Set = function(v) setValueFromPos(bar.AbsolutePosition.X + bar.AbsoluteSize.X * ((v-min)/(max-min))) end}
    end

    return tabApi
end

-- Toggle Open/Close
local opened = true
local function setOpen(o)
    opened = o
    if opened then
        toggleBtn.Text = "Close"
        TweenService:Create(main, TweenInfo.new(0.22), {Size = size}):Play()
    else
        toggleBtn.Text = "Open"
        TweenService:Create(main, TweenInfo.new(0.22), {Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 36)}):Play()
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setOpen(not opened)
end)

-- Make draggable via top bar
makeDraggable(main, top)

-- Return window API
local api = {
    _ScreenGui = screenGui,
    _Main = main,
    AddTab = window.AddTab,
    SetOpen = setOpen,
    GetTabs = function() return tabsFolder end
}
setmetatable(api, {__index = PrefUI})

return api

end

return PrefUI
