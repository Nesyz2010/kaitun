repeat task.wait() until game:IsLoaded()
getgenv().Config = {
    TEAM = "Pirates"
}
local Config = getgenv().Config

repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")

-- ===== AUTO CHOOSE TEAM =====
if game.Players.LocalPlayer.Team == nil then
    repeat task.wait()
        for _, v in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
            if string.find(v.Name, "Main") then
                local btn = v.ChooseTeam.Container[Config.TEAM].Frame.TextButton
                btn.Size = UDim2.new(0,10000,0,10000)
                btn.Position = UDim2.new(-4,0,-5,0)
                btn.BackgroundTransparency = 1
                task.wait(.5)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,true,game,1)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,1)
            end
        end
    until game.Players.LocalPlayer.Team ~= nil
    task.wait(3)
end

repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait() until game:GetService("Players").LocalPlayer.Character

--// AUTO RACE V2/V3 - CLEAN TEXT UI
--// Làm V3 race hiện tại trước, xong reroll sang race trong queue

getgenv().AUTO_MINK = true

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser    = game:GetService("VirtualUser")
local TweenService   = game:GetService("TweenService")
local CoreGui        = game:GetService("CoreGui")

local plr  = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local TARGET_RACE  = "Rabbit" -- Rabbit/Mink đều dùng quest chest
getgenv().RACE_QUEUE = getgenv().RACE_QUEUE or {"Rabbit", "Mink"} -- sửa list race muốn làm tiếp ở đây
local TWEEN_SPEED  = 280
local SEA2_PLACE   = 4442272183

-- ══════════════════════════════════════════
--  CLEAN TEXT UI ONLY
-- ══════════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaceTextUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = plr.PlayerGui end

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusOnlyText"
statusLabel.AnchorPoint = Vector2.new(0.5, 0.5)
statusLabel.Position = UDim2.new(0.5, 0, 0.3, 0)
statusLabel.Size = UDim2.new(1, 0, 0, 90)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Starting..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 54
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = false
statusLabel.TextStrokeTransparency = 0.35
statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.Parent = screenGui

local function setStatus(txt)
    statusLabel.Text = tostring(txt)
end

local function log(...)
    local parts = {...}
    local msg = table.concat(parts, " ")
    print("[AUTO RACE]", msg)
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
local _cacheRace, _v2, _v3 = nil, false, false

local function resetRaceCache()
    _cacheRace = race()
    _v2 = false
    _v3 = false
end

local function ensureRaceCache()
    if _cacheRace ~= race() then
        resetRaceCache()
    end
end

local function hasV2()
    ensureRaceCache()
    if _v2 then return true end
    _v2 = (safeInvoke("Alchemist", "1") == -2)
    return _v2
end

local function hasV3()
    ensureRaceCache()
    if _v3 then return true end
    _v3 = (safeInvoke("Wenlocktoad", "1") == -2)
    return _v3
end
    _v3 = (safeInvoke("Wenlocktoad", "1") == -2)
    return _v3
end

-- ══════════════════════════════════════════
--  REROLL
-- ══════════════════════════════════════════
local function sameRace(a, b)
    a = tostring(a or "")
    b = tostring(b or "")
    if a == b then return true end
    -- Blox Fruits cũ gọi Mink, mới gọi Rabbit
    if (a == "Mink" and b == "Rabbit") or (a == "Rabbit" and b == "Mink") then
        return true
    end
    return false
end

local function rerollToRace(targetRace)
    local attempts = 0
    while getgenv().AUTO_MINK and not sameRace(race(), targetRace) do
        attempts += 1
        setStatus("Reroll " .. tostring(targetRace) .. "...")
        log("Reroll #" .. attempts .. " | Current:", race(), "=>", targetRace)
        local res = safeInvoke("BlackbeardReward", "Reroll", "2")
        log("Result:", tostring(res), "| Race:", race())
        resetRaceCache()
        task.wait(2)
    end
    setStatus(tostring(race()) .. " V1 Done!")
    log("✓", race(), "V1 xong")
end

local function rerollToMink()
    rerollToRace(TARGET_RACE)
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
        log("✓", race(), "đã có V2")
        return true
    end

    ensureSea2()
    log("Bắt đầu V2 —", race())
    setStatus(tostring(race()) .. " V2...")
    tweenTo(AlchemistPos)
    task.wait(1)

    safeInvoke("Alchemist", "1")
    task.wait(1)
    safeInvoke("Alchemist", "2")
    task.wait(1)

    while getgenv().AUTO_MINK and not haveAllFlowers() do
        setStatus("V2 Flower " .. flowerCount() .. "/3")

        if not pickupFlower() then
            for _, cf in ipairs(FlowerSpots) do
                if haveAllFlowers() then break end
                tweenTo(cf + Vector3.new(0, 3, 0))
                task.wait(0.25)
                pickupFlower()
                setStatus("V2 Flower " .. flowerCount() .. "/3")
            end
        end

        if not hasToolContains("yellow") and not hasToolContains("flower 3") then
            farmYellowFlower()
        end

        task.wait(1)
    end

    log("Đủ 3 flower, trả Alchemist")
    setStatus("Submit V2...")
    tweenTo(AlchemistPos)
    task.wait(1)
    safeInvoke("Alchemist", "3")
    task.wait(2)

    _v2 = (safeInvoke("Alchemist", "1") == -2)
    if _v2 then
        log("✓", race(), "V2 xong!")
        setStatus("V2 Done!")
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
            setStatus("V3 Chest " .. chestCount)

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
        log("✓", race(), "đã có V3")
        return true
    end

    if not hasV2() then
        doV2()
    end

    ensureSea2()
    if not (sameRace(race(), "Rabbit") or sameRace(race(), "Mink")) then
        setStatus(tostring(race()) .. " V3 needs custom quest")
        log("Race", race(), "chưa có task V3 riêng trong bản này")
        return false
    end
    log("Bắt đầu V3 —", race())
    setStatus(tostring(race()) .. " V3...")
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
        log("✓", race(), "V3 xong!")
        setStatus("V3 Done!")
    end
    return _v3
end

-- ══════════════════════════════════════════
--  MAIN LOOP
-- ══════════════════════════════════════════
log("Script khởi động...")
setStatus("Starting...")

local doneRace = {}
local function markDone(r)
    doneRace[tostring(r)] = true
    if r == "Mink" then doneRace["Rabbit"] = true end
    if r == "Rabbit" then doneRace["Mink"] = true end
end

local function getNextTargetRace()
    local current = race()
    for _, r in ipairs(getgenv().RACE_QUEUE) do
        if not sameRace(current, r) and not doneRace[tostring(r)] then
            return r
        end
    end
    return nil
end

task.spawn(function()
    while getgenv().AUTO_MINK do
        pcall(function()
            ensureSea2()
            resetRaceCache()

            -- 1) Làm race hiện tại trước, không ép reroll ngay
            setStatus(tostring(race()) .. " Checking...")

            if not hasV2() then
                doV2()
            else
                setStatus("V2 Done!")
                task.wait(0.8)
            end

            if not hasV3() then
                doV3()
            else
                setStatus("V3 Done!")
                task.wait(0.8)
            end

            if hasV2() and hasV3() then
                markDone(race())
                setStatus(tostring(race()) .. " V3 Done!")
                task.wait(2)

                -- 2) Xong race hiện tại thì reroll sang race khác trong queue
                local nextRace = getNextTargetRace()
                if nextRace then
                    setStatus("Next: " .. tostring(nextRace))
                    task.wait(1)
                    rerollToRace(nextRace)
                    resetRaceCache()
                else
                    setStatus("All Done!")
                    log("✓ DONE: không còn race trong queue")
                    getgenv().AUTO_MINK = false
                end
            end
        end)

        task.wait(3)
    end
end)
