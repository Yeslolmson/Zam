```lua
local p=game:GetService("Players")
local lp=p.LocalPlayer
local uis=game:GetService("UserInputService")
local rs=game:GetService("RunService")
local cam=workspace.CurrentCamera
local mouse=lp:GetMouse()

local C={MainKey=Enum.KeyCode.G,Circle=100,Target="Hitbox"}
local S={BT=false,SA=false,AB=false,ESP=false,Gui=true,Set=false}

-- Helper to create instances
local function new(c,par,props)
    local o=Instance.new(c)
    for k,v in pairs(props or {}) do o[k]=v end
    if par then o.Parent=par end
    return o
end

-- Main GUI
local sg=new("ScreenGui",lp:WaitForChild("PlayerGui"),{Name="RivalsCheatGUI",ResetOnSpawn=false})
local mob=new("TextButton",sg,{Size=UDim2.new(0,50,0,50),Position=UDim2.new(0,10,0,10),BackgroundColor3=Color3.fromRGB(50,50,50),Text="☰",Font=Enum.Font.SourceSansBold,TextSize=18,TextColor3=Color3.fromRGB(255,255,255),ZIndex=10})
local main=new("Frame",sg,{Size=UDim2.new(0,300,0,400),Position=UDim2.new(0.5,-150,0.5,-200),BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Active=true})
local dragMain=new("TextButton",main,{Size=UDim2.new(1,-40,0,40),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(45,45,45),Text="≡ Drag",Font=Enum.Font.SourceSans,TextSize=14,TextColor3=Color3.fromRGB(200,200,200),AutoButtonColor=false,ZIndex=2})
local logo=new("ImageButton",main,{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-35,0,5),BackgroundTransparency=1,Image="rbxassetid://7072707420",ZIndex=5})
new("TextLabel",main,{Size=UDim2.new(1,-40,0,30),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,Text="Rivals Cheats",Font=Enum.Font.SourceSansBold,TextSize=20,TextColor3=Color3.fromRGB(255,255,255)})
local cont=new("Frame",main,{Size=UDim2.new(1,-20,1,-50),Position=UDim2.new(0,10,0,40),BackgroundTransparency=1})

-- Toggle creation function
local function mktoggle(name,y,cb)
    local b=new("TextButton",cont,{Size=UDim2.new(1,0,0,35),Position=UDim2.new(0,0,0,y),BackgroundColor3=Color3.fromRGB(50,50,50),Text=name..": OFF",Font=Enum.Font.SourceSans,TextSize=16,TextColor3=Color3.fromRGB(255,255,255),AutoButtonColor=false})
    local st=false
    b.MouseButton1Click:Connect(function()
        st=not st
        b.Text=name..": "..(st and "ON" or "OFF")
        b.BackgroundColor3=st and Color3.fromRGB(0,150,0) or Color3.fromRGB(50,50,50)
        cb(st)
    end)
    return {
        Set=function(v)
            st=v
            b.Text=name..": "..(v and "ON" or "OFF")
            b.BackgroundColor3=v and Color3.fromRGB(0,150,0) or Color3.fromRGB(50,50,50)
        end,
        Get=function() return st end
    }
end

-- Declare circle variable before toggles (will be assigned later)
local circle

local bt=mktoggle("Backtrack",0,function(v) S.BT=v end)
local sa=mktoggle("Silent Aim",40,function(v) S.SA=v if circle then circle.Visible=v end end)
local ab=mktoggle("AimBox",80,function(v) S.AB=v end)
local esp=mktoggle("ESP",120,function(v)
    S.ESP=v
    if v then
        for _,pl in pairs(p:GetPlayers()) do
            if pl~=lp then createESP(pl) end
        end
    else
        for pl,d in pairs(frames) do
            d.Frame:Destroy()
            frames[pl]=nil
        end
    end
end)

-- Settings GUI
local setf=new("Frame",sg,{Size=UDim2.new(0,300,0,400),Position=main.Position,BackgroundColor3=Color3.fromRGB(40,40,40),BorderSizePixel=0,Visible=false})
local dragSet=new("TextButton",setf,{Size=UDim2.new(1,-40,0,40),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(55,55,55),Text="≡ Drag",Font=Enum.Font.SourceSans,TextSize=14,TextColor3=Color3.fromRGB(200,200,200),AutoButtonColor=false,ZIndex=2})
new("TextLabel",setf,{Size=UDim2.new(1,-40,0,30),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,Text="Settings",Font=Enum.Font.SourceSansBold,TextSize=20,TextColor3=Color3.fromRGB(255,255,255)})
local circLabel=new("TextLabel",setf,{Size=UDim2.new(0,150,0,30),Position=UDim2.new(0,10,0,50),BackgroundTransparency=1,Text="Circle Size: "..C.Circle,Font=Enum.Font.SourceSans,TextSize=16,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left})

-- Slider creation
local function mkSlider(parent,pos,w,min,max,val,cb)
    local bg=new("Frame",parent,{Size=UDim2.new(0,w,0,10),Position=pos,BackgroundColor3=Color3.fromRGB(80,80,80),BorderSizePixel=0})
    local fill=new("Frame",bg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(0,150,0),BorderSizePixel=0})
    local h=new("TextButton",bg,{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,0,0,-5),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Text="",AutoButtonColor=false})
    local v=val
    local drag=false
    local function upd(x)
        local rel=math.clamp(x-bg.AbsolutePosition.X,0,bg.AbsoluteSize.X)
        local t=rel/bg.AbsoluteSize.X
        v=min+t*(max-min)
        fill.Size=UDim2.new(t,0,1,0)
        h.Position=UDim2.new(t,-10,0,-5)
        cb(v)
    end
    h.MouseButton1Down:Connect(function() drag=true upd(mouse.X) end)
    bg.MouseButton1Down:Connect(function() upd(mouse.X) end)
    uis.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(mouse.X)
        elseif drag and i.UserInputType==Enum.UserInputType.Touch then upd(i.Position.X) end
    end)
    uis.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    local t=(v-min)/(max-min)
    fill.Size=UDim2.new(t,0,1,0)
    h.Position=UDim2.new(t,-10,0,-5)
    return {
        Set=function(n)
            v=math.clamp(n,min,max)
            t=(v-min)/(max-min)
            fill.Size=UDim2.new(t,0,1,0)
            h.Position=UDim2.new(t,-10,0,-5)
            cb(v)
        end,
        Get=function() return v end
    }
end

local circSlider=mkSlider(setf,UDim2.new(0,10,0,80),200,50,300,C.Circle,function(v)
    C.Circle=math.floor(v)
    circLabel.Text="Circle Size: "..C.Circle
    updateCircle()
end)

new("TextLabel",setf,{Size=UDim2.new(0,120,0,30),Position=UDim2.new(0,10,0,120),BackgroundTransparency=1,Text="AimBox Target:",Font=Enum.Font.SourceSans,TextSize=16,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left})
local targetBtn=new("TextButton",setf,{Size=UDim2.new(0,120,0,30),Position=UDim2.new(0,140,0,120),BackgroundColor3=Color3.fromRGB(60,60,60),Text=C.Target,Font=Enum.Font.SourceSans,TextSize=16,TextColor3=Color3.fromRGB(255,255,255)})

local targets={"Head","Body","Hitbox"}
local idx=table.find(targets,C.Target) or 3
targetBtn.MouseButton1Click:Connect(function()
    idx=idx%#targets+1
    C.Target=targets[idx]
    targetBtn.Text=C.Target
end)

logo.MouseButton1Click:Connect(function()
    S.Set=not S.Set
    setf.Visible=S.Set
    main.Visible=not S.Set
    logo.Parent=S.Set and setf or main
    logo.Position=UDim2.new(1,-35,0,5)
end)

-- Drag functionality
local function dragify(f,h)
    local d,ds,fs=false,nil,nil
    h.MouseButton1Down:Connect(function()
        d=true
        ds=Vector2.new(mouse.X,mouse.Y)
        fs=f.Position
    end)
    uis.InputChanged:Connect(function(i)
        if d and i.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=Vector2.new(mouse.X,mouse.Y)-ds
            f.Position=UDim2.new(fs.X.Scale,fs.X.Offset+delta.X,fs.Y.Scale,fs.Y.Offset+delta.Y)
        end
    end)
    uis.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end
    end)
    h.TouchStarted:Connect(function(i)
        d=true
        ds=i.Position
        fs=f.Position
    end)
    uis.TouchMoved:Connect(function(i,g)
        if d then
            local delta=i.Position-ds
            f.Position=UDim2.new(fs.X.Scale,fs.X.Offset+delta.X,fs.Y.Scale,fs.Y.Offset+delta.Y)
        end
    end)
    uis.TouchEnded:Connect(function(i,g) d=false end)
end

dragify(main,dragMain)
dragify(setf,dragSet)

local function toggleGUI()
    S.Gui=not S.Gui
    main.Visible=S.Gui and not S.Set
    setf.Visible=S.Gui and S.Set
    logo.Parent=S.Set and setf or main
end

mob.MouseButton1Click:Connect(toggleGUI)
uis.InputBegan:Connect(function(i,g)
    if not g and i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==C.MainKey then toggleGUI() end
end)

-- ESP container
local espc=new("ScreenGui",lp:WaitForChild("PlayerGui"),{Name="ESPContainer",ResetOnSpawn=false})
local frames={}

local function updESP()
    for pl,fd in pairs(frames) do
        if not pl.Parent or not pl.Character or not pl.Character:FindFirstChild("HumanoidRootPart") then
            fd.Frame:Destroy()
            frames[pl]=nil
        else
            local rp=pl.Character.HumanoidRootPart
            local sp,on=cam:WorldToScreenPoint(rp.Position)
            if on then
                local size=50/(cam.CFrame.Position-rp.Position).Magnitude*10
                fd.Frame.Visible=true
                fd.Frame.Position=UDim2.new(0,sp.X-size/2,0,sp.Y-size/2)
                fd.Frame.Size=UDim2.new(0,size,0,size)
                fd.NameLabel.Text=pl.Name
            else
                fd.Frame.Visible=false
            end
        end
    end
end

local function createESP(pl)
    if pl==lp or frames[pl] then return end
    local f=new("Frame",espc,{BackgroundTransparency=1,BorderSizePixel=2,BorderColor3=Color3.fromRGB(255,255,255),Size=UDim2.new(0,50,0,50),Visible=false})
    local l=new("TextLabel",f,{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=pl.Name,Font=Enum.Font.SourceSans,TextSize=14,TextColor3=Color3.fromRGB(255,255,255),TextStrokeTransparency=0})
    frames[pl]={Frame=f,NameLabel=l}
end

p.PlayerAdded:Connect(function(pl)
    if S.ESP then
        task.wait(1)
        createESP(pl)
    end
end)

p.PlayerRemoving:Connect(function(pl)
    if frames[pl] then
        frames[pl].Frame:Destroy()
        frames[pl]=nil
    end
end)

-- Helper: find enemy behind local player (for backtrack)
local function getBehind(max)
    local ch=lp.Character
    if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
    local root=ch.HumanoidRootPart
    local cl,cd=nil,max
    for _,pl in pairs(p:GetPlayers()) do
        if pl~=lp and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local er=pl.Character.HumanoidRootPart
            local dist=(root.Position-er.Position).Magnitude
            if dist<cd then
                local look=er.CFrame.LookVector
                local to=(root.Position-er.Position).Unit
                if look:Dot(to)<-0.5 then
                    cl=er
                    cd=dist
                end
            end
        end
    end
    return cl
end

local function btAtk()
    if not S.BT then return end
    local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    if not tool or not tool:IsA("Tool") or tool.Name:lower():find("knife")==nil then return end
    local er=getBehind(10)
    if er then
        local ch=lp.Character
        local root=ch.HumanoidRootPart
        local lookCF=CFrame.lookAt(root.Position,er.Position)
        local _,yaw,_=lookCF:ToEulerAnglesYXZ()
        root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,yaw,0)
        tool:Activate()
    end
end

mouse.Button1Down:Connect(btAtk)

-- Circle (silent aim visual)
circle=new("Frame",sg,{Size=UDim2.new(0,C.Circle*2,0,C.Circle*2),Position=UDim2.new(0.5,-C.Circle,0.5,-C.Circle),BackgroundTransparency=1,BorderSizePixel=0,Visible=false})
local cborder=new("Frame",circle,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=0.8,BackgroundColor3=Color3.fromRGB(255,0,0),BorderSizePixel=0})
new("UICorner",cborder,{CornerRadius=UDim.new(1,0)})

local function updateCircle()
    circle.Size=UDim2.new(0,C.Circle*2,0,C.Circle*2)
    circle.Position=UDim2.new(0.5,-C.Circle,0.5,-C.Circle)
end

local origCF,frameCount=nil,0
local function getCircle()
    local center=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    local cl,cd=nil,C.Circle
    for _,pl in pairs(p:GetPlayers()) do
        if pl~=lp and pl.Character and pl.Character:FindFirstChild("Head") then
            local h=pl.Character.Head
            local sp,on=cam:WorldToScreenPoint(h.Position)
            if on then
                local dist=(Vector2.new(sp.X,sp.Y)-center).Magnitude
                if dist<cd then
                    cl=h
                    cd=dist
                end
            end
        end
    end
    return cl
end

local function saShot()
    if not S.SA then return end
    local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    if not tool or not tool:IsA("Tool") then return end
    local t=getCircle()
    if t then
        origCF=cam.CFrame
        cam.CFrame=CFrame.lookAt(cam.CFrame.Position,t.Position)
        tool:Activate()
        frameCount=2
    end
end

rs.RenderStepped:Connect(function()
    if frameCount>0 then
        frameCount-=1
        if frameCount==0 and origCF then
            cam.CFrame=origCF
            origCF=nil
        end
    end
end)

mouse.Button1Down:Connect(saShot)

-- AimBox (triggerbot)
local function getPart()
    if not lp.Character then return end
    local ray=cam:ScreenPointToRay(mouse.X,mouse.Y)
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={lp.Character}
    params.FilterType=Enum.RaycastFilterType.Blacklist
    local res=workspace:Raycast(ray.Origin,ray.Direction*500,params)
    if res and res.Instance then
        local char=res.Instance.Parent
        if char:IsA("Model") then
            local pl=p:GetPlayerFromCharacter(char)
            if pl and pl~=lp then
                return res.Instance,pl
            end
        end
    end
end

local function valid(part)
    if C.Target=="Hitbox" then return true
    elseif C.Target=="Head" then return part.Name=="Head"
    elseif C.Target=="Body" then return part.Name=="HumanoidRootPart" or part.Name=="Torso" or part.Parent:FindFirstChild("HumanoidRootPart")==part
    end
    return false
end

local function abCheck()
    if not S.AB then return end
    if not lp.Character or not lp.Character:FindFirstChildOfClass("Tool") then return end
    local part,pl=getPart()
    if part and valid(part) then
        local tool=lp.Character:FindFirstChildOfClass("Tool")
        if tool and tool:IsA("Tool") then
            tool:Activate()
        end
    end
end

-- Only trigger on mouse movement to avoid spam
mouse.Move:Connect(abCheck)

-- ESP render loop
rs.RenderStepped:Connect(function()
    if S.ESP then updESP() end
end)

-- Initial state
main.Visible=true
setf.Visible=false
logo.Parent=main
circle.Visible=false

print("Loaded")
```