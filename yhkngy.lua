-- cobble hills | player box esp
-- single-file Luau script for Delta (or any executor with the Drawing API)

if _G.__cobble_esp_unload then pcall(_G.__cobble_esp_unload) end

if not Drawing then
    return warn("[cobble esp] this executor does not expose the Drawing API")
end

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local boxes       = {}
local connections = {}
local running     = true

local function make_box()
    local sq = Drawing.new("Square")
    sq.Visible      = false
    sq.Color        = Color3.fromRGB(255, 0, 0)
    sq.Thickness    = 1.5
    sq.Filled       = false
    sq.Transparency = 1
    return sq
end

local function get_box(player)
    local b = boxes[player]
    if not b then
        b = make_box()
        boxes[player] = b
    end
    return b
end

local function destroy_box(player)
    local b = boxes[player]
    if b then
        pcall(function() b:Remove() end)
        boxes[player] = nil
    end
end

local function project(world_pos, camera)
    local s, _ = camera:WorldToViewportPoint(world_pos)
    return Vector2.new(s.X, s.Y), s.Z
end

local function update()
    if not running then return end
    local camera = workspace.CurrentCamera
    if not camera then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local box  = get_box(player)
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")

            if hrp and head and hum and hum.Health > 0 then
                local head_s, head_z = project(head.Position, camera)
                local hrp_s,  hrp_z  = project(hrp.Position,  camera)

                if head_z > 0 and hrp_z > 0 then
                    local upper = hrp_s.Y - head_s.Y
                    if upper > 0 then
                        local top    = head_s.Y
                        local bottom = hrp_s.Y + upper
                        local height = bottom - top
                        local width  = height
                        local left   = hrp_s.X - width * 0.5

                        box.Size     = Vector2.new(width, height)
                        box.Position = Vector2.new(left, top)
                        box.Visible  = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
    end
end

table.insert(connections, Players.PlayerRemoving:Connect(destroy_box))

table.insert(connections, RunService.RenderStepped:Connect(function()
    pcall(update)
end))

_G.__cobble_esp_unload = function()
    running = false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    connections = {}
    for _, b in pairs(boxes) do pcall(function() b:Remove() end) end
    boxes = {}
    _G.__cobble_esp_unload = nil
end

warn("[cobble esp] loaded — red box on every player. re-execute or call _G.__cobble_esp_unload() to clear")