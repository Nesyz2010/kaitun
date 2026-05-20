repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait() until game:GetService("Players").LocalPlayer.Character

--// AUTO MINK V1 V2 V3 - FIXED + GUI LOG
--// Sea 2 required for V2/V3
--// Need fragments for reroll/V3

getgenv().AUTO_MINK = true

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser    = game:GetService("VirtualUser")
local TweenService   = game:GetService("TweenService")
local CoreGui        = game:GetService("CoreGui")

local plr  = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local TARGET_RACE  = "Mink"
local TWEEN_SPEED  = 280
local SEA2_PLACE   = 4442272183
local MAX_LOG_LINES = 12

-- ══════════════════════════════════════════
--  GUI LOG
-- ══════════════════════════════════════════
local logLines = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoMinkGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = plr.PlayerGui end

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(0, 300, 0, 34)
header.Position = UDim2.new(0, 14, 0, 14)
header.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
header.BorderSizePixel = 0
header.Parent = screenGui

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ AUTO MINK"
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Status badge
local statusBadge = Instance.new("Frame")
statusBadge.Size = UDim2.new(0, 300, 0, 26)
statusBadge.Position = UDim2.new(0, 14, 0, 52)
statusBadge.BackgroundColor3 = Color3.fromRGB(10, 30, 15)
statusBadge.BorderSizePixel = 0
statusBadge.Parent = screenGui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusBadge

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 10, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Starting..."
statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusBadge

-- Log box
local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(0, 300, 0, MAX_LOG_LINES * 17 + 10)
logFrame.Position = UDim2.new(0, 14, 0, 84)
logFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
logFrame.BorderSizePixel = 0
logFrame.Parent = screenGui

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 8)
logCorner.Parent = logFrame

local logInner = Instance.new("Frame")
logInner.Size = UDim2.new(1, -12, 1, -8)
logInner.Position = UDim2.new(0, 6, 0, 4)
logInner.BackgroundTransparency = 1
logInner.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 1)
logLayout.Parent = logInner

-- Pre-create label pool
local labelPool = {}
for i = 1, MAX_LOG_LINES do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = ""
    lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = i
    lbl.Parent = logInner
    labelPool[i] = lbl
end

local function refreshLogUI()
    for i = 1, MAX_LOG_LINES do
        local line = logLines[i] or ""
        local lbl = labelPool[i]
        lbl.Text = line
        -- color code
        if line:find("DONE") or line:find("✓") or line:find("V2") or line:find("V3") then
            lbl.TextColor3 = Color3.fromRGB(80, 255, 150)
        elseif line:find("Reroll") or line:find("reroll") then
            lbl.TextColor3 = Color3.fromRGB(255, 200, 60)
        elseif line:find("Error") or line:find("error") or line:find("lỗi") then
            lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif line:find("Flower") or line:find("flower") or line:find("Chest") then
            lbl.TextColor3 = Color3.fromRGB(160, 220, 255)
        else
            lbl.TextColor3 = Color3.fromRGB(170, 170, 180)
        end
    end
end

local function setStatus(txt)
    statusLabel.Text = "Status: " .. txt
end

local function log(...)
    local parts = {...}
    local msg = table.concat(parts, " ")
    print("[AUTO MINK]", msg)
    table.insert(logLines, msg)
    while #logLines > MAX_LOG_LINES do
        table.remove(logLines, 1)
    end
    refreshLogUI()
end

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local function getChar()
    return plr.Character or plr.CharacterAdded:Wait()
end

local function getHRP()
    local char = getChar()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        -- wait for respawn
        plr.CharacterAdded:Wait()
        task.wait(1)
        hrp = getChar():WaitForChild("HumanoidRootPart", 10)
    end
    return hrp
end

local function getHum()
    return getChar():WaitForChild("Humanoid")
end

local function race()
    local ok, val = pcall(function()
        return tostring(plr.Data.Race.Value)
    end)
    return ok and val or "Unknown"
end

plr.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if not getChar():FindFirstChild("HasBuso") then
                CommF:InvokeServer("Buso")
            end
        end)
    end
end)

local function safeInvoke(...)
    local args = {...}
    local ok, res = pcall(function()
        return CommF:InvokeServer(table.unpack(args))
    end)
    if ok then return res end
    warn("[AUTO MINK] Invoke error:", res)
    return nil
end

local function tweenTo(cf)
    local hrp = getHRP()
    if not hrp then return false end

    local dist = (hrp.Position - cf.Position).Magnitude

    pcall(function()
        for _, v in ipairs(getChar():GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)

    if dist < 12 then
        hrp.CFrame = cf
        return true
    end

    local tw = TweenService:Create(
        hrp,
        TweenInfo.new(dist / TWEEN_SPEED, Enum.EasingStyle.Linear),
        {CFrame = cf}
    )
    tw:Play()
    tw.Completed:Wait()
    return true
end

local function pressE()
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
    end)
end

local function ensureSea2()
    if game.PlaceId ~= SEA2_PLACE then
        log("Di chuyển tới Sea 2...")
        setStatus("Traveling to Sea 2")
        safeInvoke("TravelDressrosa")
        task.wait(6)
    end
end

-- ══════════════════════════════════════════
--  V2 / V3 CHECK  (cached per session)
-- ══════════════════════════════════════════
local _v2, _v3 = false, false

local function hasV2()
    if _v2 then return true end
    _v2 = (safeInvoke("Alchemist", "1") == -2)
    return _v2
end

local function hasV3()
    if _v3 then return true end
    _v3 = (safeInvoke("Wenlocktoad", "1") == -2)
    return _v3
end

-- ══════════════════════════════════════════
--  REROLL
-- ══════════════════════════════════════════
local function rerollToMink()
    local attempts = 0
    while getgenv().AUTO_MINK and race() ~= TARGET_RACE do
        attempts += 1
        log("Reroll #" .. attempts .. " | Race:", race())
        setStatus("Rerolling → Mink (#" .. attempts .. ")")
        local res = safeInvoke("BlackbeardReward", "Reroll", "2")
        log("  Result:", tostring(res), "| Race:", race())
        task.wait(2)
    end
    log("✓ Mink V1 xong!")
    setStatus("Got Mink V1")
end

-- ══════════════════════════════════════════
--  TOOL CHECKS
-- ══════════════════════════════════════════
local function hasToolContains(txt)
    txt = txt:lower()
    local bp = plr:FindFirstChildOfClass("Backpack")
    if bp then
        for _, v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find(txt) then return true end
        end
    end
    for _, v in ipairs(getChar():GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find(txt) then return true end
    end
    return false
end

local function haveAllFlowers()
    local count = 0
    if hasToolContains("flower 1") or hasToolContains("blue flower")   then count += 1 end
    if hasToolContains("flower 2") or hasToolContains("red flower")    then count += 1 end
    if hasToolContains("flower 3") or hasToolContains("yellow flower") then count += 1 end
    return count >= 3
end

local function flowerCount()
    local count = 0
    if hasToolContains("flower 1") or hasToolContains("blue flower")   then count += 1 end
    if hasToolContains("flower 2") or hasToolContains("red flower")    then count += 1 end
    if hasToolContains("flower 3") or hasToolContains("yellow flower") then count += 1 end
    return count
end

-- ══════════════════════════════════════════
--  FLOWER PICKUP
-- ══════════════════════════════════════════
local FlowerNames = {
    "Flower 1", "Flower 2", "Flower 3",
    "Blue Flower", "Red Flower", "Yellow Flower"
}

local function findFlowerInWorkspace()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if table.find(FlowerNames, obj.Name) then
            if obj:IsA("Tool") then
                return obj:FindFirstChild("Handle") or obj
            elseif obj:IsA("BasePart") then
                return obj
            elseif obj:IsA("Model") then
                return obj:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
    return nil
end

local function pickupFlower()
    local found = findFlowerInWorkspace()
    if found then
        log("Nhặt flower:", found.Name)
        tweenTo(found.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.5)
        pressE()
        task.wait(1)
        return true
    end
    return false
end

local FlowerSpots = {
    CFrame.new(-961.736,  74.477,  -1074.745),
    CFrame.new(-506.224,  72.477,  -1745.184),
    CFrame.new(-1576.716, 198.592,  13.724),
    CFrame.new(-5412.145,  48.823, -721.537),
    CFrame.new(-5332.766,  48.823, -858.024),
    CFrame.new(-3976.421, 331.565, -537.239),
    CFrame.new(-4857.772, 717.669, -2622.354),
    CFrame.new(-1988.475, 125.507,  -67.984),
    CFrame.new(-1366.914,  74.419, -122.626),
    CFrame.new(-933.705,   13.761, -1097.963),
    CFrame.new(-1919.928,  39.496,  520.123),
    CFrame.new(-3052.889,  22.028,  -90.272),
    CFrame.new(-2146.043,  72.992, -3102.231),
    CFrame.new(-793.390,   72.991, -3428.879),
}

-- ══════════════════════════════════════════
--  YELLOW FLOWER FARM
-- ══════════════════════════════════════════
local YellowFlowerMobs = {
    "Swan Pirate", "Factory Staff", "Marine Lieutenant", "Marine Captain",
    "Zombie", "Vampire", "Snow Trooper", "Winter Warrior"
}

local function equipMelee()
    local bp = plr:FindFirstChildOfClass("Backpack")
    if not bp then return end
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == "Melee" then
            getHum():EquipTool(tool)
            return
        end
    end
end

local function getEnemiesFolder()
    return workspace:FindFirstChild("Enemies")
end

local function findMob(names)
    local folder = getEnemiesFolder()
    if not folder then return nil end
    for _, mob in ipairs(folder:GetChildren()) do
        if mob:IsA("Model")
            and mob:FindFirstChild("Humanoid")
            and mob:FindFirstChild("HumanoidRootPart")
            and mob.Humanoid.Health > 0
        then
            for _, n in ipairs(names) do
                if mob.Name:find(n) then return mob end
            end
        end
    end
    return nil
end

local function attackNearby()
    pcall(function()
        local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
        local folder = getEnemiesFolder()
        if not folder then return end

        local targets = {}
        local hrpPos = getHRP().Position

        for _, mob in ipairs(folder:GetChildren()) do
            if mob:FindFirstChild("HumanoidRootPart")
                and mob:FindFirstChild("Head")
                and mob:FindFirstChild("Humanoid")
                and mob.Humanoid.Health > 0
                and (mob.HumanoidRootPart.Position - hrpPos).Magnitude <= 65
            then
                table.insert(targets, mob)
            end
        end

        if #targets == 0 then return end

        net:WaitForChild("RE/RegisterAttack"):FireServer(0)

        local args = {nil, {}}
        for i, v in ipairs(targets) do
            if not args[1] then args[1] = v.Head end
            args[2][i] = {v, v.HumanoidRootPart}
        end
        net:WaitForChild("RE/RegisterHit"):FireServer(table.unpack(args))
    end)
end

local function farmYellowFlower()
    log("Farm Yellow Flower...")
    setStatus("Farming Yellow Flower")
    equipMelee()

    local mob = findMob(YellowFlowerMobs)
    if not mob then
        tweenTo(CFrame.new(-877.905, 77.247, -10953.135))
        task.wait(2)
        mob = findMob(YellowFlowerMobs)
    end

    if not mob then
        log("Không tìm thấy mob yellow flower")
        return
    end

    local timeout = tick() + 120  -- 2 phút timeout
    while mob.Parent
        and mob:FindFirstChild("Humanoid")
        and mob.Humanoid.Health > 0
        and not hasToolContains("yellow")
        and not hasToolContains("flower 3")
        and tick() < timeout
    do
        tweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 8))
        attackNearby()
        task.wait(0.15)
    end

    if tick() >= timeout then
        log("Timeout farm yellow flower!")
    end
end

-- ══════════════════════════════════════════
--  V2
-- ══════════════════════════════════════════
local AlchemistPos = CFrame.new(-2777.6001, 72.9661, -3574.7363)

local function doV2()
    if hasV2() then
        log("✓ Mink đã có V2")
        return true
    end

    ensureSea2()
    log("Bắt đầu V2 — Alchemist Quest")
    setStatus("V2 | Getting quest")
    tweenTo(AlchemistPos)
    task.wait(1)

    safeInvoke("Alchemist", "1")
    task.wait(1)
    safeInvoke("Alchemist", "2")
    task.wait(1)

    while getgenv().AUTO_MINK and not haveAllFlowers() do
        setStatus("V2 | Flowers: " .. flowerCount() .. "/3")

        if not pickupFlower() then
            for _, cf in ipairs(FlowerSpots) do
                if haveAllFlowers() then break end
                tweenTo(cf + Vector3.new(0, 3, 0))
                task.wait(0.25)
                pickupFlower()
                setStatus("V2 | Flowers: " .. flowerCount() .. "/3")
            end
        end

        if not hasToolContains("yellow") and not hasToolContains("flower 3") then
            farmYellowFlower()
        end

        task.wait(1)
    end

    log("Đủ 3 flower, trả Alchemist")
    setStatus("V2 | Submitting flowers")
    tweenTo(AlchemistPos)
    task.wait(1)
    safeInvoke("Alchemist", "3")
    task.wait(2)

    _v2 = (safeInvoke("Alchemist", "1") == -2)
    if _v2 then
        log("✓ Mink V2 xong!")
        setStatus("Got Mink V2 ✓")
    else
        log("Alchemist chưa nhận — thử lại sau")
    end
    return _v2
end

-- ══════════════════════════════════════════
--  V3
-- ══════════════════════════════════════════
local ArowePos = CFrame.new(-1984.542, 124.288, -72.107)

local ChestSpots = {
    CFrame.new(-1204,  7, -5089),
    CFrame.new(-1121, 14, -5077),
    CFrame.new(-1068, 14, -5172),
    CFrame.new(-941,  14, -5154),
    CFrame.new(-879,  13, -5089),
    CFrame.new(-1927, 10, -11682),
    CFrame.new(-1858, 15, -11702),
    CFrame.new(-1698, 14, -11964),
    CFrame.new(-1621, 15, -12111),
    CFrame.new(-2790, 73, -3571),
    CFrame.new(-2885, 73, -3460),
    CFrame.new(-3030, 73, -3375),
    CFrame.new(-5420, 15, -524),
    CFrame.new(-5533, 15, -712),
    CFrame.new(-5402, 15, -841),
    CFrame.new(574,   70, -2870),
    CFrame.new(646,   70, -2962),
    CFrame.new(505,   70, -3085),
}

local function collectChests()
    log("V3: Đi nhặt chest...")
    local total = #ChestSpots
    local chestCount = 0

    for loop = 1, 6 do
        if hasV3() then return true end

        for idx, cf in ipairs(ChestSpots) do
            if hasV3() then return true end

            tweenTo(cf + Vector3.new(0, 3, 0))
            task.wait(0.25)
            pressE()
            chestCount += 1
            setStatus("V3 | Chest " .. chestCount .. " (loop " .. loop .. "/6)")

            if chestCount % 5 == 0 then
                log("Chest:", chestCount, "/ loop", loop)
            end
        end

        log("Loop " .. loop .. " xong, trả Arowe")
        tweenTo(ArowePos)
        task.wait(1)
        safeInvoke("Wenlocktoad", "2")
        task.wait(1)
        safeInvoke("Wenlocktoad", "3")
        task.wait(1)

        _v3 = (safeInvoke("Wenlocktoad", "1") == -2)
        if _v3 then return true end
    end

    return hasV3()
end

local function doV3()
    if hasV3() then
        log("✓ Mink đã có V3")
        return true
    end

    if not hasV2() then
        doV2()
    end

    ensureSea2()
    log("Bắt đầu V3 — Arowe Quest")
    setStatus("V3 | Getting quest")
    tweenTo(ArowePos)
    task.wait(1)

    safeInvoke("Wenlocktoad", "1")
    task.wait(1)
    safeInvoke("Wenlocktoad", "2")
    task.wait(1)

    collectChests()

    tweenTo(ArowePos)
    task.wait(1)
    safeInvoke("Wenlocktoad", "3")
    task.wait(1)
    safeInvoke("Wenlocktoad", "2")
    task.wait(1)

    _v3 = (safeInvoke("Wenlocktoad", "1") == -2)
    if _v3 then
        log("✓ Mink V3 xong!")
        setStatus("Got Mink V3 ✓")
    end
    return _v3
end

-- ══════════════════════════════════════════
--  MAIN LOOP
-- ══════════════════════════════════════════
log("Script khởi động...")
setStatus("Initializing")

task.spawn(function()
    while getgenv().AUTO_MINK do
        pcall(function()
            ensureSea2()

            if race() ~= TARGET_RACE then
                rerollToMink()
            end

            if not hasV2() then
                doV2()
            end

            if not hasV3() then
                doV3()
            end

            if race() == TARGET_RACE and hasV2() and hasV3() then
                log("✓ DONE: Mink V3 hoàn tất!")
                setStatus("✓ DONE — Mink V3 Complete!")
                header.BackgroundColor3 = Color3.fromRGB(10, 40, 20)
                titleLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
                getgenv().AUTO_MINK = false
            end
        end)

        task.wait(3)
    end
end)