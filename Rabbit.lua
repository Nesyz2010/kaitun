--// STOP OLD SCRIPT + CLEAN UI
getgenv().AUTO_MINK = false
getgenv().AUTO_RACE_V3 = false
task.wait(0.5)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local plr = Players.LocalPlayer

local function clearOldGui(parent)
    for _, v in ipairs(parent:GetChildren()) do
        if v.Name == "AutoMinkGUI"
        or v.Name == "CleanRaceTextUI"
        or v.Name == "RaceCleanOneText"
        or v.Name == "RaceSmallTextUI"
        then
            v:Destroy()
        end
    end
end

pcall(function() clearOldGui(CoreGui) end)
pcall(function() clearOldGui(plr.PlayerGui) end)

task.wait(0.5)
getgenv().AUTO_RACE_V3 = true

repeat task.wait() until game:IsLoaded()
repeat task.wait() until plr and plr.Character

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")

local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local SEA2_PLACE = 4442272183
local TWEEN_SPEED = 285

-- Thứ tự race muốn làm
local RACE_QUEUE = {
    "Angel",
    "Rabbit",
    "Human",
    "Shark",
}

--// SMALL CLEAN TEXT UI
local gui = Instance.new("ScreenGui")
gui.Name = "RaceSmallTextUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = plr:WaitForChild("PlayerGui") end

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.new(0.5, 0, 0.28, 0)
label.Size = UDim2.new(0, 520, 0, 70)
label.BackgroundTransparency = 1
label.Text = "Loading..."
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.35
label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
label.Font = Enum.Font.GothamBold
label.TextScaled = false
label.TextSize = 46
label.Parent = gui

local function ui(msg)
    label.Text = tostring(msg)
    print("[AUTO RACE]", msg)
end

local function safeInvoke(...)
    local args = {...}
    local ok, res = pcall(function()
        return CommF:InvokeServer(table.unpack(args))
    end)
    if ok then return res end
    warn("[AUTO RACE] Invoke error:", res)
    return nil
end

local function getChar()
    return plr.Character or plr.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild("HumanoidRootPart", 20)
end

local function getHum()
    return getChar():WaitForChild("Humanoid", 20)
end

local function rawRace()
    local ok, val = pcall(function()
        return tostring(plr.Data.Race.Value)
    end)
    return ok and val or "Unknown"
end

local function normRace(r)
    r = tostring(r or "")
    if r == "Mink" then return "Rabbit" end
    if r == "Skypiea" or r == "Sky" then return "Angel" end
    if r == "Fishman" then return "Shark" end
    return r
end

local function currentRace()
    return normRace(rawRace())
end

plr.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    while getgenv().AUTO_RACE_V3 and task.wait(5) do
        pcall(function()
            if not getChar():FindFirstChild("HasBuso") then
                safeInvoke("Buso")
            end
        end)
    end
end)

local function tweenTo(cf)
    local hrp = getHRP()
    if not hrp then return false end

    pcall(function()
        for _, v in ipairs(getChar():GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)

    local dist = (hrp.Position - cf.Position).Magnitude
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
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, "E", false, game)
    end)
end

local function ensureSea2()
    if game.PlaceId ~= SEA2_PLACE then
        ui("Travel Sea 2...")
        safeInvoke("TravelDressrosa")
        task.wait(6)
    end
end

local v2CacheRace, v3CacheRace, v2Cache, v3Cache

local function resetRaceCache()
    v2CacheRace, v3CacheRace = nil, nil
    v2Cache, v3Cache = nil, nil
end

local function hasV2()
    local r = rawRace()
    if v2CacheRace == r and v2Cache ~= nil then return v2Cache end
    v2CacheRace = r
    v2Cache = (safeInvoke("Alchemist", "1") == -2)
    return v2Cache
end

local function hasV3()
    local r = rawRace()
    if v3CacheRace == r and v3Cache ~= nil then return v3Cache end
    v3CacheRace = r
    v3Cache = (safeInvoke("Wenlocktoad", "1") == -2)
    return v3Cache
end

--// V2
local AlchemistPos = CFrame.new(-2777.6001, 72.9661, -3574.7363)
local FlowerNames = {"Flower 1", "Flower 2", "Flower 3", "Blue Flower", "Red Flower", "Yellow Flower"}

local FlowerSpots = {
    CFrame.new(-961.736, 74.477, -1074.745),
    CFrame.new(-506.224, 72.477, -1745.184),
    CFrame.new(-1576.716, 198.592, 13.724),
    CFrame.new(-5412.145, 48.823, -721.537),
    CFrame.new(-5332.766, 48.823, -858.024),
    CFrame.new(-3976.421, 331.565, -537.239),
    CFrame.new(-4857.772, 717.669, -2622.354),
    CFrame.new(-1988.475, 125.507, -67.984),
    CFrame.new(-1366.914, 74.419, -122.626),
    CFrame.new(-933.705, 13.761, -1097.963),
    CFrame.new(-1919.928, 39.496, 520.123),
    CFrame.new(-3052.889, 22.028, -90.272),
    CFrame.new(-2146.043, 72.992, -3102.231),
    CFrame.new(-793.390, 72.991, -3428.879),
}

local YellowFlowerMobs = {
    "Swan Pirate", "Factory Staff", "Marine Lieutenant", "Marine Captain",
    "Zombie", "Vampire", "Snow Trooper", "Winter Warrior"
}

local function hasToolContains(txt)
    txt = tostring(txt):lower()

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

local function flowerCount()
    local c = 0
    if hasToolContains("flower 1") or hasToolContains("blue flower") then c += 1 end
    if hasToolContains("flower 2") or hasToolContains("red flower") then c += 1 end
    if hasToolContains("flower 3") or hasToolContains("yellow flower") then c += 1 end
    return c
end

local function haveAllFlowers()
    return flowerCount() >= 3
end

local function findFlower()
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
    local found = findFlower()
    if found then
        ui("Flower Found!")
        tweenTo(found.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.4)
        pressE()
        task.wait(0.8)
        return true
    end
    return false
end

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

local function findMob(names)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    for _, mob in ipairs(enemies:GetChildren()) do
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
        local enemies = workspace:FindFirstChild("Enemies")
        if not enemies then return end

        local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
        local targets = {}

        for _, mob in ipairs(enemies:GetChildren()) do
            if mob:FindFirstChild("HumanoidRootPart")
                and mob:FindFirstChild("Head")
                and mob:FindFirstChild("Humanoid")
                and mob.Humanoid.Health > 0
                and (mob.HumanoidRootPart.Position - getHRP().Position).Magnitude <= 65
            then
                table.insert(targets, mob)
            end
        end

        if #targets <= 0 then return end
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
    ui("Yellow Flower...")
    equipMelee()

    local mob = findMob(YellowFlowerMobs)
    if not mob then
        tweenTo(CFrame.new(-877.905, 77.247, -10953.135))
        task.wait(2)
        mob = findMob(YellowFlowerMobs)
    end

    if mob then
        local timeout = tick() + 120
        while getgenv().AUTO_RACE_V3
            and mob.Parent
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
    end
end

local function doV2()
    if hasV2() then
        ui("V2 Done!")
        return true
    end

    ensureSea2()
    ui("Start V2!")
    tweenTo(AlchemistPos)
    task.wait(1)

    safeInvoke("Alchemist", "1")
    task.wait(1)
    safeInvoke("Alchemist", "2")
    task.wait(1)

    while getgenv().AUTO_RACE_V3 and not haveAllFlowers() do
        ui("Flowers " .. flowerCount() .. "/3")

        if not pickupFlower() then
            for _, cf in ipairs(FlowerSpots) do
                if haveAllFlowers() then break end
                tweenTo(cf + Vector3.new(0, 3, 0))
                task.wait(0.25)
                pickupFlower()
            end
        end

        if not hasToolContains("yellow") and not hasToolContains("flower 3") then
            farmYellowFlower()
        end

        task.wait(0.5)
    end

    ui("Submit V2!")
    tweenTo(AlchemistPos)
    task.wait(1)
    safeInvoke("Alchemist", "3")
    task.wait(2)

    resetRaceCache()

    if hasV2() then
        ui("V2 Done!")
        return true
    end

    ui("V2 Retry!")
    return false
end

--// V3
local ArowePos = CFrame.new(-1984.542, 124.288, -72.107)

local ChestSpots = {
    CFrame.new(-1204, 7, -5089),
    CFrame.new(-1121, 14, -5077),
    CFrame.new(-1068, 14, -5172),
    CFrame.new(-941, 14, -5154),
    CFrame.new(-879, 13, -5089),
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
    CFrame.new(574, 70, -2870),
    CFrame.new(646, 70, -2962),
    CFrame.new(505, 70, -3085),
}

local function acceptV3Quest()
    tweenTo(ArowePos)
    task.wait(1)
    safeInvoke("Wenlocktoad", "1")
    task.wait(0.8)
    safeInvoke("Wenlocktoad", "2")
    task.wait(0.8)
end

local function submitV3()
    tweenTo(ArowePos)
    task.wait(1)
    safeInvoke("Wenlocktoad", "3")
    task.wait(0.8)
    safeInvoke("Wenlocktoad", "2")
    task.wait(0.8)
    resetRaceCache()
    return hasV3()
end

local function doRabbitV3()
    ui("Start Rabbit V3!")
    acceptV3Quest()

    local chest = 0
    for loop = 1, 8 do
        if hasV3() then return true end

        for _, cf in ipairs(ChestSpots) do
            if hasV3() then return true end
            tweenTo(cf + Vector3.new(0, 3, 0))
            task.wait(0.25)
            pressE()
            chest += 1
            ui("Chest " .. tostring(chest))
        end

        submitV3()
    end

    return hasV3()
end

local function doAngelV3()
    ui("Start Angel V3!")
    acceptV3Quest()

    while getgenv().AUTO_RACE_V3 and currentRace() == "Angel" and not hasV3() do
        ui("Kill Angel Player!")
        task.wait(5)
        submitV3()
        task.wait(3)
    end

    return hasV3()
end

local function doUnsupportedV3(r)
    ui(r .. " V3 Manual!")
    acceptV3Quest()

    while getgenv().AUTO_RACE_V3 and currentRace() == r and not hasV3() do
        ui(r .. " Quest Manual")
        task.wait(6)
        submitV3()
    end

    return hasV3()
end

local function doV3()
    if hasV3() then
        ui("V3 Done!")
        return true
    end

    if not hasV2() then
        doV2()
    end

    ensureSea2()

    local r = currentRace()
    if r == "Rabbit" then
        return doRabbitV3()
    elseif r == "Angel" then
        return doAngelV3()
    else
        return doUnsupportedV3(r)
    end
end

--// REROLL
local function nextRaceAfter(r)
    r = normRace(r)
    for i, rr in ipairs(RACE_QUEUE) do
        if normRace(rr) == r then
            local nxt = RACE_QUEUE[i + 1]
            if nxt then return normRace(nxt) end
        end
    end
    return nil
end

local function rerollTo(target)
    if not target then return false end
    target = normRace(target)

    local tries = 0
    while getgenv().AUTO_RACE_V3 and currentRace() ~= target do
        tries += 1
        ui("Reroll " .. target .. " #" .. tries)
        safeInvoke("BlackbeardReward", "Reroll", "2")
        resetRaceCache()
        task.wait(2)

        if tries % 10 == 0 and currentRace() ~= target then
            ui("Check Fragments!")
            task.wait(3)
        end
    end

    ui("Race " .. target .. "!")
    return true
end

--// MAIN
task.spawn(function()
    while getgenv().AUTO_RACE_V3 do
        pcall(function()
            ensureSea2()

            local r = currentRace()
            ui(r .. " Check!")

            if not hasV2() then
                doV2()
            end

            if not hasV3() then
                doV3()
            end

            if hasV2() and hasV3() then
                ui(r .. " V3 Done!")

                local nxt = nextRaceAfter(r)
                if nxt then
                    task.wait(2)
                    rerollTo(nxt)
                else
                    ui("All Done!")
                    getgenv().AUTO_RACE_V3 = false
                end
            end
        end)

        task.wait(3)
    end
end)
