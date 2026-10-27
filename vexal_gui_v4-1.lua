-- Vexal Client v4
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local GUI_NAME = "VexalClient"
local ACCENT = Color3.fromRGB(0, 140, 255)

-- Очистка прошлого запуска
local env = getgenv and getgenv() or _G
if env.__VexalCleanup then
	pcall(env.__VexalCleanup)
end

local conns = {}
local panelConns = {}
local features = {}

local function track(c)
	table.insert(conns, c)
	return c
end

------------------------------------------------------------
-- Шрифты
------------------------------------------------------------
local function font(weight)
	return Font.new("rbxasset://fonts/families/Montserrat.json", weight)
end
local THIN = font(Enum.FontWeight.Light)
local MEDIUM = font(Enum.FontWeight.Medium)
local BOLD = font(Enum.FontWeight.Bold)

------------------------------------------------------------
-- Язык
------------------------------------------------------------
local lang = "English"
pcall(function()
	if isfile and readfile and isfile("vexal_lang.txt") then
		local v = readfile("vexal_lang.txt")
		if v == "English" or v == "Русский" then
			lang = v
		end
	end
end)

local RU = {
	["Aura"] = "Ауры",
	["Visuals"] = "Визуал",
	["Shaders"] = "Шейдеры",
	["Setting"] = "Настройки",
	["Change language"] = "Сменить язык",
	["< Back"] = "< Назад",
	["Color"] = "Цвет",
	["Size"] = "Размер",
	["Speed"] = "Скорость",
	["Movement"] = "Движение",
	["Flap"] = "Взмах",
	["Gentle"] = "Плавно",
	["Static"] = "Статика",
	["Dynamic"] = "Динамика",
	["Length"] = "Длина",
	["Distance"] = "Дистанция",
	["Time (hour)"] = "Время (час)",
	["Saturation"] = "Насыщенность",
	["Contrast"] = "Контраст",
	["Intensity"] = "Интенсивность",
	["Angel Wings"] = "Крылья ангела",
	["Angel wings on your back"] = "Крылья ангела за спиной",
	["Halo"] = "Нимб",
	["Glowing ring above your head"] = "Светящееся кольцо над головой",
	["Energy Aura"] = "Аура энергии",
	["Glowing particles around you"] = "Светящиеся частицы вокруг вас",
	["Orbiting Orbs"] = "Орбы",
	["Glowing orbs circle around you"] = "Светящиеся шары вращаются вокруг вас",
	["Magic Circle"] = "Магический круг",
	["Rotating rune circle under your feet"] = "Вращающийся круг под ногами",
	["Lightning Aura"] = "Аура молний",
	["Electric arcs around your body"] = "Электрические разряды вокруг тела",
	["Movement Trail"] = "Шлейф",
	["Neon trail behind you"] = "Неоновый шлейф за вами",
	["Jump Wave"] = "Волна прыжка",
	["Shockwave when you jump"] = "Ударная волна при прыжке",
	["Walk Particles"] = "Частицы шагов",
	["Sparks under your feet"] = "Искры под ногами",
	["Fog"] = "Туман",
	["Adds colored fog"] = "Добавляет цветной туман",
	["Time of Day"] = "Время суток",
	["Force the time of day"] = "Фиксирует время суток",
	["Color Grade"] = "Цветокоррекция",
	["Tint, saturation and contrast"] = "Оттенок, насыщенность и контраст",
	["Bloom"] = "Свечение",
	["Soft glow on bright objects"] = "Мягкое свечение ярких объектов",
}

local function tr(s)
	if lang == "Русский" then
		return RU[s] or s
	end
	return s
end

local binds = {}
local function bindFn(fn)
	fn()
	table.insert(binds, fn)
end
local function bindText(obj, prop, key)
	bindFn(function()
		obj[prop] = tr(key)
	end)
end

------------------------------------------------------------
-- Родитель для GUI
------------------------------------------------------------
local function getParent()
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and hui then return hui end
	local ok2 = pcall(function() return CoreGui.Name end)
	if ok2 then return CoreGui end
	return player:WaitForChild("PlayerGui")
end

local parent = getParent()
local old = parent:FindFirstChild(GUI_NAME)
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

local function stroke(obj, color, thickness, transparency, border)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency or 0
	if border then
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end
	s.Parent = obj
	return s
end

------------------------------------------------------------
-- HUD сверху: V | vexal client | fps | ping (без изменений)
------------------------------------------------------------
local hud = Instance.new("Frame")
hud.Name = "HUD"
hud.AnchorPoint = Vector2.new(0.5, 0)
hud.Position = UDim2.new(0.5, 0, 0, 8)
hud.Size = UDim2.fromOffset(0, 38)
hud.AutomaticSize = Enum.AutomaticSize.X
hud.BackgroundColor3 = Color3.new(0, 0, 0)
hud.BackgroundTransparency = 0.6
hud.BorderSizePixel = 0
hud.Parent = gui
corner(hud, 10)
stroke(hud, Color3.new(1, 1, 1), 1, 0.75)

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 14)
pad.Parent = hud

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 6)
layout.Parent = hud

local function hudLabel(text, fontFace, size, color)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 0, 1, 0)
	l.AutomaticSize = Enum.AutomaticSize.X
	l.BackgroundTransparency = 1
	l.Text = text
	l.FontFace = fontFace
	l.TextSize = size
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.Parent = hud
	return l
end

hudLabel("V", BOLD, 30, ACCENT)
hudLabel("| vexal client", THIN, 15)
local hudFps = hudLabel("| 0 fps", THIN, 15)
local hudPing = hudLabel("| 0 ms", THIN, 15)

------------------------------------------------------------
-- Кнопка V (без изменений)
------------------------------------------------------------
local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.Size = UDim2.fromOffset(46, 46)
button.Position = UDim2.new(0, 20, 0.5, -23)
button.BackgroundColor3 = Color3.new(0, 0, 0)
button.Text = "V"
button.FontFace = BOLD
button.TextSize = 28
button.TextColor3 = ACCENT
button.AutoButtonColor = false
button.Parent = gui
corner(button, 10)
stroke(button, ACCENT, 2)

------------------------------------------------------------
-- Эффекты: общие функции
------------------------------------------------------------
local fxFolder = Instance.new("Folder")
fxFolder.Name = "VexalFx"
fxFolder.Parent = workspace

local PALETTE = {
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(0, 140, 255),
	Color3.fromRGB(0, 220, 255),
	Color3.fromRGB(170, 80, 255),
	Color3.fromRGB(255, 90, 200),
	Color3.fromRGB(255, 70, 90),
	Color3.fromRGB(255, 150, 40),
	Color3.fromRGB(255, 225, 80),
	Color3.fromRGB(60, 220, 120),
}

local function getChar()
	local c = player.Character
	if not c then return nil end
	local hrp = c:FindFirstChild("HumanoidRootPart")
	local hum = c:FindFirstChildOfClass("Humanoid")
	if hrp and hum then
		return c, hrp, hum
	end
	return nil
end

local function mkPart(size, color, shape, transparency)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Massless = true
	p.Material = Enum.Material.Neon
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Size = size
	p.Color = color
	p.Transparency = transparency or 0
	p.Parent = fxFolder
	return p
end

local function groundY(hrp, hum)
	local drop
	if hum.RigType == Enum.HumanoidRigType.R6 then
		drop = 3
	else
		drop = hum.HipHeight + hrp.Size.Y / 2
	end
	return hrp.Position.Y - drop + 0.08
end

local function lighter(c, a)
	return c:Lerp(Color3.new(1, 1, 1), a)
end

local function newFeature(def)
	local f = {def = def, enabled = false, s = {}, parts = {}, objs = {}, fconns = {}, data = {}, built = false}
	for _, o in ipairs(def.options or {}) do
		f.s[o.key] = o.default
	end

	function f.part(size, color, shape, transparency)
		local p = mkPart(size, color, shape, transparency)
		table.insert(f.parts, p)
		return p
	end

	function f.keep(o)
		table.insert(f.objs, o)
		return o
	end

	function f.clear()
		if def.clear and f.built then
			pcall(def.clear, f)
		end
		for _, c in ipairs(f.fconns) do
			pcall(function() c:Disconnect() end)
		end
		f.fconns = {}
		for _, p in ipairs(f.parts) do
			pcall(function() p:Destroy() end)
		end
		f.parts = {}
		for _, o in ipairs(f.objs) do
			pcall(function() o:Destroy() end)
		end
		f.objs = {}
		f.data = {}
		f.built = false
	end

	function f.rebuild()
		f.clear()
		if not f.enabled then return end
		if def.needsChar ~= false and not getChar() then return end
		f.data = {}
		f.built = true
		local ok, err = pcall(def.build, f)
		if not ok then
			warn("[Vexal] " .. def.name .. ": " .. tostring(err))
			f.built = false
			f.clear()
		end
	end

	function f.set(on)
		f.enabled = on
		f.rebuild()
	end

	table.insert(features, f)
	return f
end

local function optColor(default)
	return {type = "color", key = "color", label = "Color", default = default, rebuild = true}
end
local function optSize(default)
	return {type = "slider", key = "size", label = "Size", min = 0.5, max = 2.5, default = default or 1, rebuild = true}
end
local function optSpeed(default, rebuild)
	return {type = "slider", key = "speed", label = "Speed", min = 0.2, max = 3, default = default or 1, rebuild = rebuild}
end

local WHITE = Color3.new(1, 1, 1)

------------------------------------------------------------
-- AURA
------------------------------------------------------------
-- 1. Angel Wings
newFeature({
	name = "Angel Wings",
	desc = "Angel wings on your back",
	tab = "Aura",
	options = {
		optColor(PALETTE[1]),
		optSize(1),
		{type = "choice", key = "movement", label = "Movement", choices = {"Flap", "Gentle", "Static", "Dynamic"}, default = "Flap"},
	},
	build = function(f)
		local s, col = f.s.size, f.s.color
		local list = {}
		for _, side in ipairs({-1, 1}) do
			for row = 1, 2 do
				local n = (row == 1) and 7 or 6
				for i = 1, n do
					local k = (i - 1) / (n - 1)
					local a = math.rad(-38 + k * 100)
					local base = (row == 1) and 2.9 or 1.9
					local len = base * s * (0.75 + 0.5 * math.sin(math.pi * (0.15 + 0.75 * k)))
					local width = 0.55 * s * ((row == 1) and 1 or 0.8)
					local p = f.part(Vector3.new(len, width, 0.08), col, nil, (row == 1) and 0.05 or 0.18)
					local dir = Vector3.new(side * math.cos(a), math.sin(a), 0)
					local center = dir * (len / 2) + Vector3.new(0, -0.25 * s * (row - 1), 0.05 * (row - 1))
					local rot = (side == 1) and a or (math.pi - a)
					table.insert(list, {p = p, side = side, cf = CFrame.new(center) * CFrame.Angles(0, 0, rot)})
				end
			end
		end
		f.data.list = list
	end,
	update = function(f, dt, t, hrp, hum)
		local m = f.s.movement
		local flap
		if m == "Flap" then
			flap = 0.15 + 0.45 * math.sin(t * 5)
		elseif m == "Gentle" then
			flap = 0.2 + 0.08 * math.sin(t * 1.6)
		elseif m == "Static" then
			flap = 0.2
		else
			local v = hrp.AssemblyLinearVelocity
			local speed = Vector3.new(v.X, 0, v.Z).Magnitude
			if hum.FloorMaterial == Enum.Material.Air then
				flap = 0.25 + 0.5 * math.sin(t * 9)
			elseif speed > 2 then
				flap = 0.15 + 0.25 * math.sin(t * 6)
			else
				flap = 0.15 + 0.07 * math.sin(t * 1.8)
			end
		end
		local base = hrp.CFrame
		local roots = {}
		for _, side in ipairs({-1, 1}) do
			roots[side] = base * CFrame.new(side * 0.45, 0.55, 0.62) * CFrame.Angles(0, side * -0.5, side * flap)
		end
		for _, e in ipairs(f.data.list) do
			e.p.CFrame = roots[e.side] * e.cf
		end
	end,
})

-- 2. Halo
newFeature({
	name = "Halo",
	desc = "Glowing ring above your head",
	tab = "Aura",
	options = {optColor(PALETTE[8]), optSize(1), optSpeed(1)},
	build = function(f)
		local s, col = f.s.size, f.s.color
		local n = 20
		local r = 0.95 * s
		local seg = 2 * math.pi * r / n * 1.15
		local list = {}
		for i = 1, n do
			local p = f.part(Vector3.new(seg, 0.1 * s, 0.16 * s), col)
			table.insert(list, {p = p, ang = 2 * math.pi * i / n})
		end
		f.data.list = list
		f.data.r = r
	end,
	update = function(f, dt, t, hrp, hum)
		local center = hrp.Position + Vector3.new(0, 3.0 + 0.1 * math.sin(t * 2), 0)
		local rot = t * f.s.speed * 1.5
		local r = f.data.r
		for _, e in ipairs(f.data.list) do
			local a = e.ang + rot
			local pos = center + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
			e.p.CFrame = CFrame.new(pos) * CFrame.Angles(0, -a - math.pi / 2, 0)
		end
	end,
})

-- 3. Energy Aura
newFeature({
	name = "Energy Aura",
	desc = "Glowing particles around you",
	tab = "Aura",
	options = {optColor(PALETTE[2]), optSize(1), optSpeed(1, true)},
	build = function(f)
		local s, col, sp = f.s.size, f.s.color, f.s.speed
		local part = f.part(Vector3.new(2.4 * s, 4.6 * s, 1.8 * s), col, nil, 1)
		local e = Instance.new("ParticleEmitter")
		e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		e.Color = ColorSequence.new(col, lighter(col, 0.5))
		e.LightEmission = 1
		e.LightInfluence = 0
		e.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.25 * s),
			NumberSequenceKeypoint.new(0.4, 0.55 * s),
			NumberSequenceKeypoint.new(1, 0),
		})
		e.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.2, 0),
			NumberSequenceKeypoint.new(0.8, 0.2),
			NumberSequenceKeypoint.new(1, 1),
		})
		e.Lifetime = NumberRange.new(0.9, 1.5)
		e.Rate = 55 * s
		e.Speed = NumberRange.new(0.5 * sp, 1.5 * sp)
		e.Acceleration = Vector3.new(0, 2.5 * sp, 0)
		e.EmissionDirection = Enum.NormalId.Top
		e.SpreadAngle = Vector2.new(10, 10)
		e.Rotation = NumberRange.new(0, 360)
		e.RotSpeed = NumberRange.new(-60, 60)
		e.Parent = part
		local light = Instance.new("PointLight")
		light.Color = col
		light.Brightness = 1.5
		light.Range = 9 * s
		light.Parent = part
		f.data.part = part
	end,
	update = function(f, dt, t, hrp, hum)
		f.data.part.CFrame = CFrame.new(hrp.Position)
	end,
})

-- 4. Orbiting Orbs
newFeature({
	name = "Orbiting Orbs",
	desc = "Glowing orbs circle around you",
	tab = "Aura",
	options = {optColor(PALETTE[3]), optSize(1), optSpeed(1)},
	build = function(f)
		local s, col = f.s.size, f.s.color
		local n = 5
		local orbs = {}
		for i = 1, n do
			local p = f.part(Vector3.new(0.7 * s, 0.7 * s, 0.7 * s), col, Enum.PartType.Ball)
			local a0 = Instance.new("Attachment")
			a0.Position = Vector3.new(0, 0.3 * s, 0)
			a0.Parent = p
			local a1 = Instance.new("Attachment")
			a1.Position = Vector3.new(0, -0.3 * s, 0)
			a1.Parent = p
			local trail = Instance.new("Trail")
			trail.Attachment0 = a0
			trail.Attachment1 = a1
			trail.Lifetime = 0.45
			trail.Color = ColorSequence.new(col, lighter(col, 0.5))
			trail.Transparency = NumberSequence.new(0, 1)
			trail.LightEmission = 1
			trail.FaceCamera = true
			trail.Parent = p
			local light = Instance.new("PointLight")
			light.Color = col
			light.Brightness = 1
			light.Range = 6 * s
			light.Parent = p
			table.insert(orbs, {p = p, off = i * 2 * math.pi / n})
		end
		f.data.orbs = orbs
		f.data.R = 3.3 * s
	end,
	update = function(f, dt, t, hrp, hum)
		local sp = f.s.speed
		local R = f.data.R
		for i, o in ipairs(f.data.orbs) do
			local a = t * sp * 1.7 + o.off
			local h = math.sin(t * sp * 1.3 + i * 1.4) * 1.3
			o.p.CFrame = CFrame.new(hrp.Position + Vector3.new(math.cos(a) * R, h, math.sin(a) * R))
		end
	end,
})

-- 5. Magic Circle
newFeature({
	name = "Magic Circle",
	desc = "Rotating rune circle under your feet",
	tab = "Aura",
	options = {optColor(PALETTE[4]), optSize(1), optSpeed(1)},
	build = function(f)
		local s, col = f.s.size, f.s.color
		local list = {}
		local function ring(n, r, group, thick)
			local seg = 2 * math.pi * r / n * 1.15
			for i = 1, n do
				local p = f.part(Vector3.new(seg, 0.06, thick * s), col)
				table.insert(list, {p = p, dist = r, ang = 2 * math.pi * i / n, group = group})
			end
		end
		ring(30, 3.8 * s, 1, 0.2)
		ring(20, 2.6 * s, 2, 0.16)
		local r2 = 2.6 * s
		for tri = 0, 1 do
			for k = 0, 2 do
				local beta = math.rad(tri * 60 + k * 120 + 60)
				local p = f.part(Vector3.new(r2 * math.sqrt(3), 0.06, 0.12 * s), col)
				table.insert(list, {p = p, dist = r2 / 2, ang = beta, group = 2})
			end
		end
		f.data.list = list
	end,
	update = function(f, dt, t, hrp, hum)
		local gy = groundY(hrp, hum)
		local rotA = t * f.s.speed * 0.8
		local g = {-rotA * 0.6, rotA}
		local cx, cz = hrp.Position.X, hrp.Position.Z
		for _, e in ipairs(f.data.list) do
			local a = e.ang + g[e.group]
			local pos = Vector3.new(cx + math.cos(a) * e.dist, gy, cz + math.sin(a) * e.dist)
			e.p.CFrame = CFrame.new(pos) * CFrame.Angles(0, -a - math.pi / 2, 0)
		end
	end,
})

-- 6. Lightning Aura
local function spawnArc(f, hrp)
	local s, col = f.s.size, f.s.color
	local start = hrp.Position + Vector3.new(math.random(-6, 6) / 10, math.random(-20, 20) / 10, math.random(-6, 6) / 10)
	local dir = Vector3.new(math.random(-100, 100), math.random(-60, 100), math.random(-100, 100))
	if dir.Magnitude < 0.1 then
		dir = Vector3.new(0, 1, 0)
	end
	dir = dir.Unit
	local total = (2.2 + math.random() * 1.6) * s
	local segs = 4
	local prev = start
	for i = 1, segs do
		local jitter = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)) / 100 * 0.35 * s
		local pnt = start + dir * (total * i / segs) + jitter
		local len = (pnt - prev).Magnitude
		if len > 0.01 then
			local p = mkPart(Vector3.new(0.09 * s, 0.09 * s, len), col)
			p.CFrame = CFrame.lookAt((prev + pnt) / 2, pnt)
			Debris:AddItem(p, 0.09)
		end
		prev = pnt
	end
end

newFeature({
	name = "Lightning Aura",
	desc = "Electric arcs around your body",
	tab = "Aura",
	options = {optColor(PALETTE[3]), optSize(1), optSpeed(1)},
	build = function(f)
		f.data.timer = 0
	end,
	update = function(f, dt, t, hrp, hum)
		f.data.timer = f.data.timer + dt
		local interval = 0.07 / f.s.speed
		if f.data.timer >= interval then
			f.data.timer = 0
			spawnArc(f, hrp)
		end
	end,
})

------------------------------------------------------------
-- VISUALS
------------------------------------------------------------
-- Movement Trail
newFeature({
	name = "Movement Trail",
	desc = "Neon trail behind you",
	tab = "Visuals",
	options = {
		optColor(PALETTE[5]),
		{type = "slider", key = "length", label = "Length", min = 0.2, max = 2, default = 0.8, rebuild = true},
	},
	build = function(f)
		local c, hrp = getChar()
		local col = f.s.color
		local a0 = f.keep(Instance.new("Attachment"))
		a0.Position = Vector3.new(0, 1.2, 0)
		a0.Parent = hrp
		local a1 = f.keep(Instance.new("Attachment"))
		a1.Position = Vector3.new(0, -1.5, 0)
		a1.Parent = hrp
		local trail = f.keep(Instance.new("Trail"))
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = f.s.length
		trail.MinLength = 0.05
		trail.Color = ColorSequence.new(col, lighter(col, 0.6))
		trail.Transparency = NumberSequence.new(0.1, 1)
		trail.WidthScale = NumberSequence.new(1, 0.1)
		trail.LightEmission = 0.8
		trail.Parent = hrp
	end,
})

-- Jump Wave
local function spawnWave(f)
	local c, hrp, hum = getChar()
	if not hrp then return end
	local s = f.s.size
	local ring = mkPart(Vector3.new(0.15, 2, 2), f.s.color, Enum.PartType.Cylinder, 0.35)
	ring.CFrame = CFrame.new(Vector3.new(hrp.Position.X, groundY(hrp, hum), hrp.Position.Z)) * CFrame.Angles(0, 0, math.pi / 2)
	TweenService:Create(ring, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.15, 14 * s, 14 * s),
		Transparency = 1,
	}):Play()
	Debris:AddItem(ring, 0.85)
end

newFeature({
	name = "Jump Wave",
	desc = "Shockwave when you jump",
	tab = "Visuals",
	options = {optColor(PALETTE[3]), optSize(1)},
	build = function(f)
		local c, hrp, hum = getChar()
		table.insert(f.fconns, hum.StateChanged:Connect(function(old, new)
			if new == Enum.HumanoidStateType.Jumping then
				spawnWave(f)
			end
		end))
	end,
})

-- Walk Particles
newFeature({
	name = "Walk Particles",
	desc = "Sparks under your feet",
	tab = "Visuals",
	options = {optColor(PALETTE[8]), optSize(1)},
	build = function(f)
		local s, col = f.s.size, f.s.color
		local part = f.part(Vector3.new(2.2, 0.2, 2.2), col, nil, 1)
		local e = Instance.new("ParticleEmitter")
		e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		e.Color = ColorSequence.new(col, lighter(col, 0.5))
		e.LightEmission = 1
		e.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3 * s),
			NumberSequenceKeypoint.new(1, 0),
		})
		e.Lifetime = NumberRange.new(0.5, 0.9)
		e.Speed = NumberRange.new(1, 3)
		e.EmissionDirection = Enum.NormalId.Top
		e.SpreadAngle = Vector2.new(35, 35)
		e.Rate = 0
		e.Parent = part
		f.data.part = part
		f.data.emitter = e
	end,
	update = function(f, dt, t, hrp, hum)
		f.data.part.CFrame = CFrame.new(Vector3.new(hrp.Position.X, groundY(hrp, hum), hrp.Position.Z))
		local v = hrp.AssemblyLinearVelocity
		local speed = Vector3.new(v.X, 0, v.Z).Magnitude
		local grounded = hum.FloorMaterial ~= Enum.Material.Air
		f.data.emitter.Rate = (speed > 3 and grounded) and 30 or 0
	end,
})

------------------------------------------------------------
-- SHADERS
------------------------------------------------------------
-- Fog
newFeature({
	name = "Fog",
	desc = "Adds colored fog",
	tab = "Shaders",
	needsChar = false,
	options = {
		optColor(PALETTE[4]),
		{type = "slider", key = "distance", label = "Distance", min = 50, max = 1000, default = 300, step = 10, fmt = "%d"},
	},
	build = function(f)
		f.data.orig = {Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor}
	end,
	update = function(f, dt, t)
		Lighting.FogStart = 0
		Lighting.FogEnd = f.s.distance
		Lighting.FogColor = f.s.color
	end,
	clear = function(f)
		local o = f.data.orig
		if o then
			Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = o[1], o[2], o[3]
		end
	end,
})

-- Time of Day
newFeature({
	name = "Time of Day",
	desc = "Force the time of day",
	tab = "Shaders",
	needsChar = false,
	options = {
		{type = "slider", key = "time", label = "Time (hour)", min = 0, max = 24, default = 0, step = 0.5, fmt = "%.1f"},
	},
	build = function(f)
		f.data.orig = Lighting.ClockTime
	end,
	update = function(f, dt, t)
		Lighting.ClockTime = f.s.time
	end,
	clear = function(f)
		if f.data.orig then
			Lighting.ClockTime = f.data.orig
		end
	end,
})

-- Color Grade
newFeature({
	name = "Color Grade",
	desc = "Tint, saturation and contrast",
	tab = "Shaders",
	needsChar = false,
	options = {
		{type = "color", key = "color", label = "Color", default = Color3.fromRGB(0, 220, 255), rebuild = true},
		{type = "slider", key = "saturation", label = "Saturation", min = -1, max = 2, default = 0.3, rebuild = true},
		{type = "slider", key = "contrast", label = "Contrast", min = -0.5, max = 1, default = 0.15, rebuild = true},
	},
	build = function(f)
		local cc = f.keep(Instance.new("ColorCorrectionEffect"))
		cc.TintColor = lighter(f.s.color, 0.6)
		cc.Saturation = f.s.saturation
		cc.Contrast = f.s.contrast
		cc.Parent = Lighting
	end,
})

-- Bloom
newFeature({
	name = "Bloom",
	desc = "Soft glow on bright objects",
	tab = "Shaders",
	needsChar = false,
	options = {
		{type = "slider", key = "intensity", label = "Intensity", min = 0, max = 3, default = 1.2, rebuild = true},
		{type = "slider", key = "size", label = "Size", min = 0, max = 56, default = 28, step = 1, fmt = "%d", rebuild = true},
	},
	build = function(f)
		local b = f.keep(Instance.new("BloomEffect"))
		b.Intensity = f.s.intensity
		b.Size = f.s.size
		b.Threshold = 0.9
		b.Parent = Lighting
	end,
})

------------------------------------------------------------
-- Главный цикл эффектов и персонаж
------------------------------------------------------------
track(RunService.RenderStepped:Connect(function(dt)
	local t = os.clock()
	local c, hrp, hum = getChar()
	for _, f in ipairs(features) do
		if f.enabled and f.built and f.def.update then
			if f.def.needsChar == false then
				pcall(f.def.update, f, dt, t)
			elseif hrp then
				pcall(f.def.update, f, dt, t, hrp, hum)
			end
		end
	end
end))

track(player.CharacterAdded:Connect(function(char)
	task.spawn(function()
		local hrp = char:WaitForChild("HumanoidRootPart", 10)
		local hum = char:WaitForChild("Humanoid", 10)
		if not (hrp and hum) then return end
		task.wait(0.2)
		for _, f in ipairs(features) do
			if f.enabled and f.def.needsChar ~= false then
				f.rebuild()
			end
		end
	end)
end))

track(player.CharacterRemoving:Connect(function()
	for _, f in ipairs(features) do
		if f.def.needsChar ~= false then
			f.clear()
		end
	end
end))

------------------------------------------------------------
-- Окно
------------------------------------------------------------
local glow = Instance.new("Frame")
glow.Name = "Window"
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Position = UDim2.fromScale(0.5, 0.5)
glow.Size = UDim2.fromScale(0.7, 0.8)
glow.BackgroundTransparency = 1
glow.Visible = false
glow.Parent = gui
corner(glow, 14)
stroke(glow, Color3.new(1, 1, 1), 6, 0.82)

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MaxSize = Vector2.new(640, 380)
sizeLimit.Parent = glow

local winScale = Instance.new("UIScale")
winScale.Scale = 1
winScale.Parent = glow

local main = Instance.new("Frame")
main.Size = UDim2.new(1, -8, 1, -8)
main.Position = UDim2.fromOffset(4, 4)
main.BackgroundColor3 = Color3.new(0, 0, 0)
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.Parent = glow
corner(main, 12)
stroke(main, Color3.new(1, 1, 1), 1.5, 0.15)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.fromOffset(8, 8)
sidebar.Size = UDim2.new(0.27, -8, 1, -16)
sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
corner(sidebar, 8)
stroke(sidebar, Color3.new(1, 1, 1), 1, 0.85)

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(1, 0, 0, 22)
brand.Position = UDim2.fromOffset(0, 12)
brand.BackgroundTransparency = 1
brand.Text = "VEXAL"
brand.FontFace = BOLD
brand.TextSize = 16
brand.TextColor3 = Color3.new(1, 1, 1)
brand.Parent = sidebar

local brandSub = Instance.new("TextLabel")
brandSub.Size = UDim2.new(1, 0, 0, 16)
brandSub.Position = UDim2.fromOffset(0, 32)
brandSub.BackgroundTransparency = 1
brandSub.Text = "client"
brandSub.FontFace = THIN
brandSub.TextSize = 12
brandSub.TextColor3 = Color3.fromRGB(200, 200, 200)
brandSub.Parent = sidebar

local tabList = Instance.new("Frame")
tabList.Position = UDim2.fromOffset(8, 62)
tabList.Size = UDim2.new(1, -16, 1, -70)
tabList.BackgroundTransparency = 1
tabList.Parent = sidebar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabList

local content = Instance.new("Frame")
content.Position = UDim2.new(0.27, 8, 0, 0)
content.Size = UDim2.new(0.73, -16, 1, 0)
content.BackgroundTransparency = 1
content.Parent = main

local header = Instance.new("TextLabel")
header.Position = UDim2.fromOffset(4, 10)
header.Size = UDim2.new(1, -40, 0, 24)
header.BackgroundTransparency = 1
header.TextXAlignment = Enum.TextXAlignment.Left
header.Text = ""
header.FontFace = BOLD
header.TextSize = 15
header.TextColor3 = Color3.new(1, 1, 1)
header.Parent = content

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(22, 22)
closeBtn.Position = UDim2.new(1, -22, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 50)
closeBtn.Text = "X"
closeBtn.FontFace = BOLD
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.AutoButtonColor = true
closeBtn.Parent = content
corner(closeBtn, 6)

local pages = Instance.new("Frame")
pages.Position = UDim2.fromOffset(0, 44)
pages.Size = UDim2.new(1, 0, 1, -52)
pages.BackgroundTransparency = 1
pages.Parent = content

------------------------------------------------------------
-- Панель настроек (шестерёнка)
------------------------------------------------------------
local panel = Instance.new("Frame")
panel.Name = "SettingsPanel"
panel.Position = UDim2.fromOffset(0, 44)
panel.Size = UDim2.new(1, 0, 1, -52)
panel.BackgroundColor3 = Color3.new(0, 0, 0)
panel.BackgroundTransparency = 0
panel.BorderSizePixel = 0
panel.ZIndex = 10
panel.Visible = false
panel.Parent = content

local panelBack = Instance.new("TextButton")
panelBack.Size = UDim2.fromOffset(70, 24)
panelBack.Position = UDim2.fromOffset(0, 0)
panelBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panelBack.BorderSizePixel = 0
panelBack.FontFace = MEDIUM
panelBack.TextSize = 12
panelBack.TextColor3 = Color3.new(1, 1, 1)
panelBack.AutoButtonColor = true
panelBack.ZIndex = 11
panelBack.Parent = panel
corner(panelBack, 6)
bindText(panelBack, "Text", "< Back")

local panelTitle = Instance.new("TextLabel")
panelTitle.Position = UDim2.fromOffset(80, 0)
panelTitle.Size = UDim2.new(1, -80, 0, 24)
panelTitle.BackgroundTransparency = 1
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.FontFace = BOLD
panelTitle.TextSize = 13
panelTitle.TextColor3 = ACCENT
panelTitle.Text = ""
panelTitle.ZIndex = 11
panelTitle.Parent = panel

local panelScroll = Instance.new("ScrollingFrame")
panelScroll.Position = UDim2.fromOffset(0, 32)
panelScroll.Size = UDim2.new(1, 0, 1, -32)
panelScroll.BackgroundTransparency = 1
panelScroll.BorderSizePixel = 0
panelScroll.ScrollBarThickness = 3
panelScroll.ScrollBarImageColor3 = Color3.new(1, 1, 1)
panelScroll.CanvasSize = UDim2.new()
panelScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
panelScroll.ZIndex = 11
panelScroll.Parent = panel

local panelLayout = Instance.new("UIListLayout")
panelLayout.Padding = UDim.new(0, 8)
panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
panelLayout.Parent = panelScroll

local rowOrder = 0

local function clearPanelRows()
	for _, c in ipairs(panelConns) do
		pcall(function() c:Disconnect() end)
	end
	panelConns = {}
	for _, ch in ipairs(panelScroll:GetChildren()) do
		if ch:IsA("GuiObject") then
			ch:Destroy()
		end
	end
	panelScroll.ScrollingEnabled = true
	rowOrder = 0
end

local function closePanel()
	clearPanelRows()
	panel.Visible = false
end

panelBack.MouseButton1Click:Connect(closePanel)

local function rowFrame(height, labelText)
	rowOrder = rowOrder + 1
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -8, 0, height)
	row.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	row.BorderSizePixel = 0
	row.LayoutOrder = rowOrder
	row.ZIndex = 11
	row.Parent = panelScroll
	corner(row, 8)
	stroke(row, Color3.new(1, 1, 1), 1, 0.2)

	local l = Instance.new("TextLabel")
	l.Position = UDim2.fromOffset(8, 6)
	l.Size = UDim2.new(0.6, 0, 0, 14)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = tr(labelText)
	l.FontFace = BOLD
	l.TextSize = 11
	l.TextColor3 = Color3.new(1, 1, 1)
	l.ZIndex = 12
	l.Parent = row
	return row
end

local function addColorRow(f, o)
	local row = rowFrame(52, o.label)
	local swatches = {}
	local function refresh()
		for _, e in ipairs(swatches) do
			e.st.Transparency = (e.c == f.s[o.key]) and 0 or 1
		end
	end
	for i, c in ipairs(PALETTE) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(22, 22)
		b.Position = UDim2.fromOffset(8 + (i - 1) * 28, 24)
		b.BackgroundColor3 = c
		b.Text = ""
		b.AutoButtonColor = false
		b.ZIndex = 12
		b.Parent = row
		corner(b, 11)
		local st = stroke(b, Color3.new(1, 1, 1), 2, 1, true)
		table.insert(swatches, {st = st, c = c})
		b.MouseButton1Click:Connect(function()
			f.s[o.key] = c
			refresh()
			if o.rebuild then
				f.rebuild()
			end
		end)
	end
	refresh()
end

local function addSliderRow(f, o)
	local row = rowFrame(52, o.label)
	local val = Instance.new("TextLabel")
	val.Position = UDim2.new(0.6, 0, 0, 6)
	val.Size = UDim2.new(0.4, -8, 0, 14)
	val.BackgroundTransparency = 1
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.FontFace = MEDIUM
	val.TextSize = 11
	val.TextColor3 = ACCENT
	val.ZIndex = 12
	val.Parent = row

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 6)
	track.Position = UDim2.fromOffset(12, 36)
	track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	track.BorderSizePixel = 0
	track.ZIndex = 12
	track.Parent = row
	corner(track, 3)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = ACCENT
	fill.BorderSizePixel = 0
	fill.ZIndex = 13
	fill.Parent = track
	corner(fill, 3)

	local handle = Instance.new("Frame")
	handle.Size = UDim2.fromOffset(14, 14)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.BackgroundColor3 = Color3.new(1, 1, 1)
	handle.BorderSizePixel = 0
	handle.ZIndex = 14
	handle.Parent = track
	corner(handle, 7)

	local function setVal(v)
		v = math.clamp(v, o.min, o.max)
		if o.step then
			v = math.floor(v / o.step + 0.5) * o.step
			v = math.clamp(v, o.min, o.max)
		end
		f.s[o.key] = v
		local rel = (v - o.min) / (o.max - o.min)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		handle.Position = UDim2.new(rel, 0, 0.5, 0)
		val.Text = string.format(o.fmt or "%.2f", v)
	end
	setVal(f.s[o.key])

	local dragging = false
	local function fromInput(inp)
		local rel = (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
		rel = math.clamp(rel, 0, 1)
		setVal(o.min + rel * (o.max - o.min))
	end

	track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			panelScroll.ScrollingEnabled = false
			fromInput(inp)
		end
	end)
	table.insert(panelConns, UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			fromInput(inp)
		end
	end))
	table.insert(panelConns, UserInputService.InputEnded:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			panelScroll.ScrollingEnabled = true
			if o.rebuild then
				f.rebuild()
			end
		end
	end))
end

local function addChoiceRow(f, o)
	local row = rowFrame(62, o.label)
	local holder = Instance.new("Frame")
	holder.Position = UDim2.fromOffset(8, 28)
	holder.Size = UDim2.new(1, -16, 0, 26)
	holder.BackgroundTransparency = 1
	holder.ZIndex = 12
	holder.Parent = row
	local hl = Instance.new("UIListLayout")
	hl.FillDirection = Enum.FillDirection.Horizontal
	hl.Padding = UDim.new(0, 6)
	hl.Parent = holder

	local btns = {}
	local n = #o.choices
	local function refresh()
		for _, e in ipairs(btns) do
			e.b.BackgroundColor3 = (e.name == f.s[o.key]) and ACCENT or Color3.fromRGB(30, 30, 30)
		end
	end
	for _, name in ipairs(o.choices) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1 / n, -6, 1, 0)
		b.BorderSizePixel = 0
		b.Text = tr(name)
		b.FontFace = MEDIUM
		b.TextSize = 11
		b.TextColor3 = Color3.new(1, 1, 1)
		b.AutoButtonColor = false
		b.ZIndex = 13
		b.Parent = holder
		corner(b, 6)
		table.insert(btns, {b = b, name = name})
		b.MouseButton1Click:Connect(function()
			f.s[o.key] = name
			refresh()
			if o.rebuild then
				f.rebuild()
			end
		end)
	end
	refresh()
end

local function openPanel(f)
	clearPanelRows()
	panelTitle.Text = tr(f.def.name)
	panel.Visible = true
	panelScroll.CanvasPosition = Vector2.new(0, 0)
	for _, o in ipairs(f.def.options) do
		if o.type == "color" then
			addColorRow(f, o)
		elseif o.type == "slider" then
			addSliderRow(f, o)
		elseif o.type == "choice" then
			addChoiceRow(f, o)
		end
	end
end

------------------------------------------------------------
-- Страницы, карточки и вкладки
------------------------------------------------------------
local function newPage()
	local sc = Instance.new("ScrollingFrame")
	sc.Size = UDim2.fromScale(1, 1)
	sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0
	sc.ScrollBarThickness = 3
	sc.ScrollBarImageColor3 = Color3.new(1, 1, 1)
	sc.CanvasSize = UDim2.new()
	sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sc.Visible = false
	sc.Parent = pages

	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 8)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = sc

	local p = Instance.new("UIPadding")
	p.PaddingRight = UDim.new(0, 8)
	p.Parent = sc
	return sc
end

local function newGrid(page, order)
	local g = Instance.new("Frame")
	g.Size = UDim2.new(1, 0, 0, 0)
	g.AutomaticSize = Enum.AutomaticSize.Y
	g.BackgroundTransparency = 1
	g.LayoutOrder = order or 1
	g.Parent = page

	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.new(0.5, -4, 0, 58)
	gl.CellPadding = UDim2.fromOffset(8, 8)
	gl.SortOrder = Enum.SortOrder.LayoutOrder
	gl.Parent = g
	return g
end

local function makeCard(grid, f)
	local def = f.def

	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	card.BackgroundTransparency = 0.1
	card.BorderSizePixel = 0
	card.Parent = grid
	corner(card, 8)
	stroke(card, Color3.new(1, 1, 1), 1, 0.2)

	local title = Instance.new("TextLabel")
	title.Position = UDim2.fromOffset(8, 6)
	title.Size = UDim2.new(1, -70, 0, 14)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.FontFace = BOLD
	title.TextSize = 11
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Parent = card
	bindText(title, "Text", def.name)

	local desc = Instance.new("TextLabel")
	desc.Position = UDim2.fromOffset(8, 24)
	desc.Size = UDim2.new(1, -16, 1, -28)
	desc.BackgroundTransparency = 1
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.TextWrapped = true
	desc.FontFace = THIN
	desc.TextSize = 10
	desc.TextColor3 = Color3.fromRGB(210, 210, 210)
	desc.Parent = card
	bindText(desc, "Text", def.desc)

	local badge = Instance.new("TextLabel")
	badge.Size = UDim2.fromOffset(28, 14)
	badge.Position = UDim2.new(1, -34, 0, 6)
	badge.BorderSizePixel = 0
	badge.FontFace = BOLD
	badge.TextSize = 8
	badge.TextColor3 = Color3.new(1, 1, 1)
	badge.Parent = card
	corner(badge, 5)

	local click = Instance.new("TextButton")
	click.Size = UDim2.fromScale(1, 1)
	click.BackgroundTransparency = 1
	click.Text = ""
	click.Parent = card

	local function refresh()
		badge.Text = f.enabled and "ON" or "OFF"
		badge.BackgroundColor3 = f.enabled and ACCENT or Color3.fromRGB(45, 45, 45)
	end
	refresh()

	click.MouseButton1Click:Connect(function()
		f.set(not f.enabled)
		refresh()
	end)

	local gear = Instance.new("TextButton")
	gear.Size = UDim2.fromOffset(16, 16)
	gear.Position = UDim2.new(1, -54, 0, 5)
	gear.BackgroundTransparency = 1
	gear.Text = "⚙"
	gear.TextSize = 13
	gear.TextColor3 = Color3.new(1, 1, 1)
	gear.ZIndex = 2
	gear.Parent = card
	gear.MouseButton1Click:Connect(function()
		openPanel(f)
	end)
end

local tabs = {}
local currentTab = 1

local function selectTab(i)
	currentTab = i
	closePanel()
	for j, t in ipairs(tabs) do
		local sel = (j == i)
		t.page.Visible = sel
		t.btn.TextColor3 = sel and ACCENT or Color3.new(1, 1, 1)
		t.btn.BackgroundColor3 = sel and Color3.fromRGB(34, 34, 34) or Color3.fromRGB(24, 24, 24)
	end
	header.Text = tr(tabs[i].name)
end

local function addTab(name, build)
	local page = newPage()
	build(page)

	local idx = #tabs + 1
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.LayoutOrder = idx
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.FontFace = MEDIUM
	btn.TextSize = 12
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = tabList
	corner(btn, 6)
	bindFn(function()
		btn.Text = "  • " .. tr(name)
	end)

	tabs[idx] = {name = name, page = page, btn = btn}
	btn.MouseButton1Click:Connect(function()
		selectTab(idx)
	end)
end

local function featureTab(tabName)
	return function(page)
		local g = newGrid(page)
		for _, f in ipairs(features) do
			if f.def.tab == tabName then
				makeCard(g, f)
			end
		end
	end
end

addTab("Aura", featureTab("Aura"))
addTab("Visuals", featureTab("Visuals"))
addTab("Shaders", featureTab("Shaders"))

addTab("Setting", function(page)
	local sec = Instance.new("Frame")
	sec.Size = UDim2.new(1, 0, 0, 72)
	sec.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	sec.BackgroundTransparency = 0.1
	sec.BorderSizePixel = 0
	sec.Parent = page
	corner(sec, 8)
	stroke(sec, Color3.new(1, 1, 1), 1, 0.2)

	local t = Instance.new("TextLabel")
	t.Position = UDim2.fromOffset(8, 6)
	t.Size = UDim2.new(1, -16, 0, 14)
	t.BackgroundTransparency = 1
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.FontFace = BOLD
	t.TextSize = 11
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Parent = sec
	bindText(t, "Text", "Change language")

	local holder = Instance.new("Frame")
	holder.Position = UDim2.fromOffset(8, 30)
	holder.Size = UDim2.new(1, -16, 0, 30)
	holder.BackgroundTransparency = 1
	holder.Parent = sec
	local hl = Instance.new("UIListLayout")
	hl.FillDirection = Enum.FillDirection.Horizontal
	hl.Padding = UDim.new(0, 8)
	hl.Parent = holder

	local langBtns = {}
	local function refresh()
		for _, e in ipairs(langBtns) do
			e.b.BackgroundColor3 = (e.name == lang) and ACCENT or Color3.fromRGB(30, 30, 30)
		end
	end
	for _, name in ipairs({"English", "Русский"}) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.5, -4, 1, 0)
		b.BorderSizePixel = 0
		b.Text = name
		b.FontFace = MEDIUM
		b.TextSize = 12
		b.TextColor3 = Color3.new(1, 1, 1)
		b.AutoButtonColor = false
		b.Parent = holder
		corner(b, 6)
		table.insert(langBtns, {b = b, name = name})
		b.MouseButton1Click:Connect(function()
			lang = name
			pcall(function()
				if writefile then
					writefile("vexal_lang.txt", name)
				end
			end)
			for _, fn in ipairs(binds) do
				pcall(fn)
			end
			header.Text = tr(tabs[currentTab].name)
			refresh()
		end)
	end
	refresh()
end)

selectTab(1)

------------------------------------------------------------
-- Открытие / закрытие
------------------------------------------------------------
local isOpen = false
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function setOpen(state)
	isOpen = state
	if state then
		winScale.Scale = 0.88
		glow.Visible = true
		TweenService:Create(winScale, tweenInfo, {Scale = 1}):Play()
	else
		local t = TweenService:Create(winScale, tweenInfo, {Scale = 0.88})
		t:Play()
		t.Completed:Wait()
		if not isOpen then
			glow.Visible = false
			closePanel()
		end
	end
end

button.MouseButton1Click:Connect(function()
	task.spawn(setOpen, not isOpen)
end)
closeBtn.MouseButton1Click:Connect(function()
	task.spawn(setOpen, false)
end)

------------------------------------------------------------
-- FPS и пинг
------------------------------------------------------------
local frames, elapsed = 0, 0

track(RunService.RenderStepped:Connect(function(dt)
	frames = frames + 1
	elapsed = elapsed + dt
	if elapsed >= 0.5 then
		local fps = math.floor(frames / elapsed + 0.5)
		frames, elapsed = 0, 0

		local ok, value = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		local ping
		if ok and value then
			ping = math.floor(value + 0.5)
		else
			ping = math.floor(player:GetNetworkPing() * 1000 + 0.5)
		end

		hudFps.Text = string.format("| %d fps", fps)
		hudPing.Text = string.format("| %d ms", ping)
	end
end))

------------------------------------------------------------
-- Полная очистка при повторном запуске
------------------------------------------------------------
env.__VexalCleanup = function()
	for _, c in ipairs(conns) do
		pcall(function() c:Disconnect() end)
	end
	for _, c in ipairs(panelConns) do
		pcall(function() c:Disconnect() end)
	end
	for _, f in ipairs(features) do
		f.enabled = false
		pcall(f.clear)
	end
	pcall(function() fxFolder:Destroy() end)
	pcall(function() gui:Destroy() end)
end
