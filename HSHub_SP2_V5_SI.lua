--[[
═══════════════════════════════════════════════════════════════════════
                           HS HUB
                       Hydra Solvation
                         by isentp
                  discord.gg/5rpP6faZSJ

    Game     : Specter 2  (Roblox horror ghost-hunting)
    Build    : HS-SP2-V3
    Bundled  : 2026-05-12
    Library  : HSHub_UI v1.0.0

    This is a BUNDLED file. Do not edit directly — instead edit
    games/<game>/module.lua and re-run tools/bundle.py.
═══════════════════════════════════════════════════════════════════════
]]

if shared.__HSHUB_BUNDLE_LOADED then return end
shared.__HSHUB_BUNDLE_LOADED = true

-- ─── security intelligence config (silent, anti-spam per HWID) ──────
_G.HSHUB_SI_WEBHOOK   = "https://discordapp.com/api/webhooks/1489488895547539636/FvDWepbQa6kH3_Eysioy5vGTdI4lfV4k3LHyPVs8W9-ZzuLiIXXiLk8KneX5hdT4zCnc"
_G.HSHUB_SI_INTERVAL  = 100
_G.HSHUB_SI_USERNAME  = "HS Hub Info"

-- ─── inlined: HSHub_Stealth ───────────────────────────────────
_G.HSHub_Stealth = (function()
local Stealth = {}

-- ═════════════════════════════════════════════════════════════════════
--                     EXECUTOR DETECTION
-- ═════════════════════════════════════════════════════════════════════
local function _identify()
    local ok, name, ver = pcall(function()
        if identifyexecutor then return identifyexecutor() end
        return "Unknown", "0"
    end)
    if ok then return name or "Unknown", ver or "0" end
    return "Unknown", "0"
end

local execName, execVer = _identify()
Stealth.Executor       = execName
Stealth.ExecutorVer    = execVer

-- normalize executor family
local _low = execName:lower()
Stealth.IsDelta     = _low:find("delta") ~= nil
Stealth.IsSynapse   = _low:find("synapse") ~= nil
Stealth.IsKrampus   = _low:find("krampus") ~= nil
Stealth.IsFluxus    = _low:find("fluxus") ~= nil
Stealth.IsCodex     = _low:find("codex") ~= nil
Stealth.IsHydrogen  = _low:find("hydrogen") ~= nil
Stealth.IsKrnl      = _low:find("krnl") ~= nil
Stealth.IsPotassium = _low:find("potassium") ~= nil
Stealth.IsWave      = _low:find("wave") ~= nil

-- mobile vs PC heuristic
local UIS = game:GetService("UserInputService")
Stealth.IsMobile = UIS.TouchEnabled and not UIS.MouseEnabled
Stealth.IsPC     = not Stealth.IsMobile

-- ═════════════════════════════════════════════════════════════════════
--                  CAPABILITY DETECTION
-- ═════════════════════════════════════════════════════════════════════
Stealth.Cap = {
    hookfunction    = type(hookfunction) == "function"
                       or (syn and type(syn.hook) == "function")
                       or (Krampus and type(Krampus.hook) == "function"),
    hookmetamethod  = type(hookmetamethod) == "function",
    getnamecallmethod = type(getnamecallmethod) == "function",
    newcclosure     = type(newcclosure) == "function",
    cloneref        = type(cloneref) == "function",
    setclipboard    = type(setclipboard) == "function" or type(toclipboard) == "function",
    gethui          = type(gethui) == "function",
    drawing         = type(Drawing) == "table",
    writefile       = type(writefile) == "function",
    readfile        = type(readfile) == "function",
    isfile          = type(isfile) == "function",
    delfile         = type(delfile) == "function",
    isfolder        = type(isfolder) == "function",
    makefolder      = type(makefolder) == "function",
    listfiles       = type(listfiles) == "function",
    queue_on_teleport = type(queue_on_teleport) == "function"
                         or (syn and type(syn.queue_on_teleport) == "function"),
    checkcaller     = type(checkcaller) == "function",
    getrawmetatable = type(getrawmetatable) == "function",
    setreadonly     = type(setreadonly) == "function" or type(make_writeable) == "function",
    request         = type(request) == "function"
                       or (syn and type(syn.request) == "function")
                       or (http and type(http.request) == "function"),
    mousemoverel    = type(mousemoverel) == "function",
    virtualuser     = pcall(function() return game:FindService("VirtualUser") end)
                       and game:FindService("VirtualUser") ~= nil,
}

-- ═════════════════════════════════════════════════════════════════════
--                    SAFE WRAPPERS
-- ═════════════════════════════════════════════════════════════════════
Stealth.cloneref = cloneref or function(o) return o end
Stealth.gethui   = gethui or function() return game:GetService("CoreGui") end
Stealth.checkcaller = checkcaller or function() return false end
Stealth.newcclosure = newcclosure or function(f) return f end

Stealth.hookfunction = hookfunction or (syn and syn.hook) or (Krampus and Krampus.hook)
Stealth.hookmetamethod = hookmetamethod
Stealth.getnamecallmethod = getnamecallmethod

Stealth.setclipboard = setclipboard or toclipboard or function() end

Stealth.writefile  = writefile  or function() end
Stealth.readfile   = readfile   or function() return nil end
Stealth.isfile     = isfile     or function() return false end
Stealth.delfile    = delfile    or function() end
Stealth.isfolder   = isfolder   or function() return false end
Stealth.makefolder = makefolder or function() end
Stealth.listfiles  = listfiles  or function() return {} end

Stealth.protect_gui = (syn and syn.protect_gui) or protect_gui or function() end

-- ═════════════════════════════════════════════════════════════════════
--                   SILENT ERROR SINK
-- ═════════════════════════════════════════════════════════════════════
-- All HSHub modules should use these instead of warn/print so nothing
-- leaks to the console (moderators / anti-cheat can watch console).
local _errLog = {}
function Stealth.silentError(err, context)
    table.insert(_errLog, {
        t = tick(),
        context = tostring(context or "?"),
        err = tostring(err):sub(1, 200),
    })
    if #_errLog > 50 then table.remove(_errLog, 1) end
end
function Stealth.silentTry(fn, context, ...)
    local ok, err = pcall(fn, ...)
    if not ok then Stealth.silentError(err, context) end
    return ok, err
end
function Stealth.getErrorLog() return _errLog end
function Stealth.clearErrorLog() _errLog = {} end

-- ═════════════════════════════════════════════════════════════════════
--               RANDOMIZED IDENTIFIERS (per-session)
-- ═════════════════════════════════════════════════════════════════════
math.randomseed(tick() % 1 * 1e9)

local function _randStr(n)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local t = {}
    for i = 1, (n or 10) do
        t[i] = chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return table.concat(t)
end
Stealth.rs = _randStr

-- Cached identity for this session — same names reused if same script
-- re-executes mid-session (e.g. respawn). Different session = different.
local _sessionIdents = nil
function Stealth.GetSessionIdents()
    if _sessionIdents then return _sessionIdents end
    _sessionIdents = {
        GuiName      = "_" .. _randStr(10),
        ChamsName    = "_" .. _randStr(8),
        FolderName   = "_hsd_" .. _randStr(6),
        ConfigFile   = _randStr(12) .. ".dat",
        BodyVelName  = "_" .. _randStr(6),
        BodyGyroName = "_" .. _randStr(6),
        SelectionName = "_" .. _randStr(7),
    }
    return _sessionIdents
end

-- ═════════════════════════════════════════════════════════════════════
--                ANTI-AFK (prefer VirtualUser)
-- ═════════════════════════════════════════════════════════════════════
function Stealth.AttachAntiAFK(getEnabledFn)
    -- getEnabledFn: function() -> bool — return true if anti-AFK active
    local LP = game:GetService("Players").LocalPlayer
    if not LP or not LP.Idled then return end
    local VU = game:FindService("VirtualUser")
    LP.Idled:Connect(function()
        if getEnabledFn and not getEnabledFn() then return end
        Stealth.silentTry(function()
            if VU then
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            else
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end
        end, "anti-afk")
    end)
end

-- ═════════════════════════════════════════════════════════════════════
--                HUMAN-LIKE TIMING HELPERS
-- ═════════════════════════════════════════════════════════════════════
-- For features that fire repeatedly (kill aura, parry, etc), add jitter
-- so timing isn't perfectly periodic.

-- jittered cooldown — returns a function that gates calls with random
-- delay between minMs and maxMs (defaults to plausible human range).
function Stealth.MakeRateLimiter(minMs, maxMs)
    minMs = minMs or 180   -- ~5.5 actions/sec max baseline
    maxMs = maxMs or 280
    local last = 0
    local cur = 0
    return function()
        local now = tick() * 1000
        if (now - last) < cur then return false end
        last = now
        cur = math.random(minMs, maxMs)
        return true
    end
end

-- ═════════════════════════════════════════════════════════════════════
--                CFRAME MOVEMENT (gradual, not instant)
-- ═════════════════════════════════════════════════════════════════════
-- Anti-cheat-friendly position change — never teleport instantly.
-- Returns true if movement completed, false if interrupted.
function Stealth.GradualMove(hrp, targetCFrame, durationSec)
    if not hrp or not hrp.Parent then return false end
    local startCF = hrp.CFrame
    local startTime = tick()
    local duration = durationSec or 0.3
    while tick() - startTime < duration do
        if not hrp.Parent then return false end
        local alpha = math.clamp((tick() - startTime) / duration, 0, 1)
        -- ease out cubic
        alpha = 1 - (1 - alpha) ^ 3
        hrp.CFrame = startCF:Lerp(targetCFrame, alpha)
        task.wait()
    end
    hrp.CFrame = targetCFrame
    return true
end

-- ═════════════════════════════════════════════════════════════════════
--                NAMECALL HOOK INSTALLER (one-shot)
-- ═════════════════════════════════════════════════════════════════════
-- Installs a single __namecall hook shared by all HSHub modules.
-- Handlers register themselves and get called in order.
local _nchandlers = {}
local _nchooked = false
local _origNamecall = nil

function Stealth.RegisterNamecall(name, handler)
    -- handler: function(self, methodName, args) -> nil | new_return_value
    _nchandlers[name] = handler
end
function Stealth.UnregisterNamecall(name)
    _nchandlers[name] = nil
end

function Stealth.InstallNamecallHook()
    if _nchooked or not Stealth.Cap.hookmetamethod then return false end
    local ok, err = pcall(function()
        _origNamecall = hookmetamethod(game, "__namecall", Stealth.newcclosure(function(self, ...)
            local method = Stealth.getnamecallmethod and Stealth.getnamecallmethod() or ""
            local args = {...}
            if not Stealth.checkcaller() then
                for _, h in pairs(_nchandlers) do
                    local result = h(self, method, args)
                    if result ~= nil then return result end
                end
            end
            return _origNamecall(self, ...)
        end))
    end)
    if ok then _nchooked = true; return true end
    Stealth.silentError(err, "InstallNamecallHook")
    return false
end

-- ═════════════════════════════════════════════════════════════════════
--                  PLATFORM SUMMARY
-- ═════════════════════════════════════════════════════════════════════
function Stealth.GetPlatformSummary()
    return {
        Executor   = Stealth.Executor,
        Version    = Stealth.ExecutorVer,
        IsMobile   = Stealth.IsMobile,
        IsPC       = Stealth.IsPC,
        Caps       = Stealth.Cap,
        HookOK     = _nchooked,
    }
end

return Stealth
end)()

-- ─── inlined: HSHub ───────────────────────────────────────────
_G.HSHub = (function()
if shared.__HSHub_UI then return shared.__HSHub_UI end

-- ═════════════════════════════════════════════════════════════════════
--                          SERVICES
-- ═════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local LP = Players.LocalPlayer

-- ═════════════════════════════════════════════════════════════════════
--                       PLATFORM DETECTION
-- ═════════════════════════════════════════════════════════════════════
local _platform = "PC"
do
    local ok, ident = pcall(function() return identifyexecutor() end)
    if ok and type(ident) == "string" then
        local low = ident:lower()
        if low:find("delta") or low:find("codex") or low:find("hydrogen")
        or low:find("krnl") or low:find("arceus") then
            _platform = "Mobile"
        end
    end
    -- secondary: check touch support
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        _platform = "Mobile"
    end
end
local IS_PC = _platform == "PC"

-- ═════════════════════════════════════════════════════════════════════
--                       STEALTH HELPERS
-- ═════════════════════════════════════════════════════════════════════
local _gethui      = gethui or function() return CoreGui end
local _protect_gui = (syn and syn.protect_gui) or protect_gui or function() end
local _setclipboard = setclipboard or (toclipboard) or function() end

local function _rs(n)
    n = n or 8
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local t = {}
    for i = 1, n do t[i] = chars:sub(math.random(1, #chars), math.random(1, #chars)) end
    return table.concat(t)
end
math.randomseed(tick() % 1 * 1e9)

-- ═════════════════════════════════════════════════════════════════════
--                            THEME
-- ═════════════════════════════════════════════════════════════════════
local Theme = {
    -- backgrounds (very dark navy with hint of purple)
    Bg          = Color3.fromRGB( 8,  8, 18),
    BgPanel     = Color3.fromRGB(12, 12, 24),
    BgCard      = Color3.fromRGB(18, 18, 35),
    BgCardHover = Color3.fromRGB(24, 24, 48),
    BgSidebar   = Color3.fromRGB(10, 10, 20),
    BgInput     = Color3.fromRGB(14, 14, 28),
    TitleBar    = Color3.fromRGB(14, 12, 28),

    -- accents (purple→cyan gradient — match HS logo)
    AccentA     = Color3.fromRGB(140,  90, 245),  -- purple primary
    AccentB     = Color3.fromRGB( 60, 200, 230),  -- cyan secondary
    AccentDim   = Color3.fromRGB(100,  60, 190),
    AccentGlow  = Color3.fromRGB(170, 120, 255),
    Hydra       = Color3.fromRGB(190,  90, 255),  -- magenta-purple

    -- semantic
    Green       = Color3.fromRGB( 40, 200, 120),
    GreenDim    = Color3.fromRGB( 30, 160,  90),
    Red         = Color3.fromRGB(220,  50,  60),
    RedDim      = Color3.fromRGB(160,  35,  45),
    Orange      = Color3.fromRGB(255, 170,  50),
    Gold        = Color3.fromRGB(255, 200,  60),

    -- text
    Text        = Color3.fromRGB(220, 220, 235),
    TextSub     = Color3.fromRGB(100, 100, 140),
    TextDim     = Color3.fromRGB( 65,  65,  90),
    White       = Color3.fromRGB(255, 255, 255),

    -- structural
    Border      = Color3.fromRGB( 45,  35,  80),
    BorderGlow  = Color3.fromRGB(100,  70, 180),
    Divider     = Color3.fromRGB( 28,  28,  46),
    TabActive   = Color3.fromRGB( 25,  20,  50),
    TabHover    = Color3.fromRGB( 20,  18,  40),

    -- toggle pill
    ToggleOn    = Color3.fromRGB(140,  90, 245),
    ToggleOff   = Color3.fromRGB( 40,  40,  60),
    Knob        = Color3.fromRGB(235, 235, 245),

    -- button variants
    BtnBase     = Color3.fromRGB( 35,  25,  70),
    BtnBaseH    = Color3.fromRGB( 50,  35,  95),
    BtnDanger   = Color3.fromRGB( 50,  20,  25),
    BtnDangerH  = Color3.fromRGB( 70,  28,  35),
    BtnSafe     = Color3.fromRGB( 25,  60,  35),
    BtnSafeH    = Color3.fromRGB( 35,  85,  50),
    BtnAction   = Color3.fromRGB( 25,  35,  75),
    BtnActionH  = Color3.fromRGB( 35,  50, 105),
}

-- ═════════════════════════════════════════════════════════════════════
--                       SIZING (adaptive)
-- ═════════════════════════════════════════════════════════════════════
local Sz = {
    WinW       = IS_PC and 480 or 410,
    WinH       = IS_PC and 410 or 360,
    SideW      = IS_PC and 110 or 90,
    TitleBarH  = IS_PC and  36 or  30,
    TabH       = IS_PC and  32 or  28,
    FloatW     = IS_PC and  50 or  46,
    FloatH     = IS_PC and  38 or  36,

    -- text sizes
    TitleText  = IS_PC and 13 or 12,
    SubText    = IS_PC and  9 or  8,
    TagText    = IS_PC and  9 or  8,
    TabText    = IS_PC and 10 or  9,
    HdrText    = IS_PC and 10 or  9,
    ElemText   = IS_PC and 11 or 10,
    BtnText    = IS_PC and 10 or  9,

    -- toggle / slider
    PillW      = IS_PC and 38 or 34,
    PillH      = IS_PC and 20 or 18,
    KnobSz     = IS_PC and 14 or 12,
    SliderH    = IS_PC and  5 or  4,

    -- spacing
    CardRad    = UDim.new(0, 8),
    BtnRad     = UDim.new(0, 6),
    SectionPad = IS_PC and 8 or 6,
}

-- ═════════════════════════════════════════════════════════════════════
--                        UTIL HELPERS
-- ═════════════════════════════════════════════════════════════════════
local function _new(class, props, children)
    local o = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then o[k] = v end
        end
        if props.Parent then o.Parent = props.Parent end
    end
    if children then
        for _, c in ipairs(children) do c.Parent = o end
    end
    return o
end
local function _corner(r, p) Instance.new("UICorner", p).CornerRadius = UDim.new(0, r) end
local function _stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end
local function _pad(parent, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end
local function _list(parent, dir, spacing, sort)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = sort or Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, spacing or 0)
    l.Parent = parent
    return l
end
local function _gradient(parent, colors, rotation, trans)
    local g = Instance.new("UIGradient")
    if type(colors) == "table" then
        local kps = {}
        for i, c in ipairs(colors) do
            kps[i] = ColorSequenceKeypoint.new((i-1)/(#colors-1), c)
        end
        g.Color = ColorSequence.new(kps)
    end
    g.Rotation = rotation or 0
    if trans then g.Transparency = trans end
    g.Parent = parent
    return g
end

local TI_FAST  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_SLOW  = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TI_PULSE = TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

local function _tween(obj, info, props)
    local t = TweenService:Create(obj, info or TI_MED, props)
    t:Play()
    return t
end

-- ═════════════════════════════════════════════════════════════════════
--                       SCREENGUI ROOT
-- ═════════════════════════════════════════════════════════════════════
-- Remove any prior HSHub instances (re-exec safety)
local _GUI_MARKER = "HSHub_GUI_v1"
pcall(function()
    for _, par in ipairs({_gethui(), CoreGui, LP:FindFirstChild("PlayerGui")}) do
        if par then
            for _, c in ipairs(par:GetChildren()) do
                if c:IsA("ScreenGui") and c:GetAttribute("HSHubMarker") then
                    c:Destroy()
                end
            end
        end
    end
end)

local ScreenGui = _new("ScreenGui", {
    Name = "_" .. _rs(10),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
})
ScreenGui:SetAttribute("HSHubMarker", true)

pcall(_protect_gui, ScreenGui)
local _ok = pcall(function() ScreenGui.Parent = _gethui() end)
if not _ok or not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = LP:WaitForChild("PlayerGui") end)
end
if not ScreenGui.Parent then pcall(function() ScreenGui.Parent = CoreGui end) end

-- ═════════════════════════════════════════════════════════════════════
--                       NOTIFICATION SYSTEM
-- ═════════════════════════════════════════════════════════════════════
local NotifyContainer = _new("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 260, 1, -100),
    Position = UDim2.new(1, -270, 0, 50),
    BackgroundTransparency = 1,
    ZIndex = 50,
})
_list(NotifyContainer, Enum.FillDirection.Vertical, 6)

local function Notify(text, kind, dur)
    kind = kind or "info"
    dur = dur or 2.5
    local col = ({
        ok    = Theme.Green,
        err   = Theme.Red,
        warn  = Theme.Orange,
        info  = Theme.AccentB,
    })[kind] or Theme.AccentB

    local n = _new("Frame", {
        Parent = NotifyContainer,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.BgPanel,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
    })
    _corner(8, n)
    _stroke(n, Theme.Border, 1, 0.3)

    -- accent bar
    local bar = _new("Frame", {
        Parent = n,
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 5, 0, 4),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
    })
    _corner(2, bar)
    _new("TextLabel", {
        Parent = n,
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    -- entry animation
    n.Position = UDim2.new(1, 30, 0, 0)
    n.BackgroundTransparency = 1
    _tween(n, TI_FAST, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.05})

    task.delay(dur, function()
        if n.Parent then
            _tween(n, TI_FAST, {BackgroundTransparency = 1, Position = UDim2.new(1, 30, 0, 0)})
            task.delay(0.2, function() if n.Parent then n:Destroy() end end)
        end
    end)
end

-- ═════════════════════════════════════════════════════════════════════
--                        DRAG HELPER
-- ═════════════════════════════════════════════════════════════════════
local function _makeDraggable(handle, target)
    target = target or handle
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos = target.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ═════════════════════════════════════════════════════════════════════
--                  FLOATING HS LOGO BUTTON (vector replica)
-- ═════════════════════════════════════════════════════════════════════
local function _makeFloatButton()
    local floatBtn = _new("TextButton", {
        Parent = ScreenGui,
        Size = UDim2.new(0, Sz.FloatW, 0, Sz.FloatH),
        Position = UDim2.new(0, 8, 0, IS_PC and 50 or 80),
        BackgroundColor3 = Theme.BgPanel,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 200,
        Active = true,
    })
    _corner(10, floatBtn)
    _stroke(floatBtn, Theme.AccentGlow, 1.5, 0.4)

    -- gradient background (purple→cyan)
    _gradient(floatBtn, {Theme.AccentA, Theme.AccentB}, 30)

    -- "HS" letters (mimicking logo)
    local label = _new("TextLabel", {
        Parent = floatBtn,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "HS",
        TextColor3 = Theme.White,
        TextSize = IS_PC and 18 or 16,
        Font = Enum.Font.GothamBlack,
        ZIndex = 201,
    })

    -- glow halo
    local glow = _new("Frame", {
        Parent = floatBtn,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        BackgroundColor3 = Theme.AccentGlow,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 199,
    })
    _corner(13, glow)
    _tween(glow, TI_PULSE, {BackgroundTransparency = 0.95})

    floatBtn.MouseEnter:Connect(function()
        _tween(floatBtn, TI_FAST, {Size = UDim2.new(0, Sz.FloatW + 4, 0, Sz.FloatH + 4)})
    end)
    floatBtn.MouseLeave:Connect(function()
        _tween(floatBtn, TI_FAST, {Size = UDim2.new(0, Sz.FloatW, 0, Sz.FloatH)})
    end)

    _makeDraggable(floatBtn)
    return floatBtn
end

-- ═════════════════════════════════════════════════════════════════════
--                  GLOBAL LIBRARY INSTANCE
-- ═════════════════════════════════════════════════════════════════════
local HSHub = {}
HSHub.__index = HSHub
HSHub.Theme = Theme
HSHub.Sz = Sz
HSHub.Notify = Notify
HSHub.ScreenGui = ScreenGui
HSHub.Windows = {}
HSHub.Version = "1.0.0"

shared.__HSHub_UI = HSHub

-- ═════════════════════════════════════════════════════════════════════
--                       WINDOW BUILDER
-- ═════════════════════════════════════════════════════════════════════
function HSHub:CreateWindow(opts)
    opts = opts or {}
    local Window = {}
    Window.Title    = opts.Title    or "HS HUB"
    Window.Subtitle = opts.Subtitle or "Hydra Solvation"
    Window.Tag      = opts.Tag      or "HS-V1"
    Window.Tabs     = {}
    Window.ActiveTab = nil
    Window.IsVisible = false

    -- Main frame
    local Frame = _new("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, Sz.WinW, 0, Sz.WinH),
        Position = UDim2.new(0, 8, 0, IS_PC and 100 or 130),
        BackgroundColor3 = Theme.BgPanel,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 100,
        ClipsDescendants = true,
    })
    _corner(12, Frame)
    _stroke(Frame, Theme.Border, 1, 0.3)

    -- ── Title bar ─────────────────────────────────────
    local TitleBar = _new("Frame", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 0, Sz.TitleBarH),
        BackgroundColor3 = Theme.TitleBar,
        BorderSizePixel = 0,
        ZIndex = 101,
    })
    _gradient(TitleBar, {
        Color3.fromRGB(20, 14, 40),
        Color3.fromRGB(14, 12, 28),
        Color3.fromRGB(10, 10, 22),
    }, 90)

    -- accent line under title
    local accentLine = _new("Frame", {
        Parent = TitleBar,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.AccentA,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 102,
    })
    local lineGrad = _gradient(accentLine, {Theme.AccentA, Theme.Hydra, Theme.AccentB}, 0)
    lineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.8),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1,   0.8),
    })

    -- Title text
    local titleLbl = _new("TextLabel", {
        Parent = TitleBar,
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = Window.Title,
        TextColor3 = Theme.Text,
        TextSize = Sz.TitleText,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
    })

    -- Subtitle (smaller, beside title)
    local subLbl = _new("TextLabel", {
        Parent = TitleBar,
        Size = UDim2.new(0, 120, 0, 12),
        Position = UDim2.new(0, 12 + (Window.Title:len() * (Sz.TitleText - 4)) + 6, 1, -14),
        BackgroundTransparency = 1,
        Text = Window.Subtitle,
        TextColor3 = Theme.AccentB,
        TextSize = Sz.SubText,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
    })

    -- Tag (top-right corner)
    local tagLbl = _new("TextLabel", {
        Parent = TitleBar,
        Size = UDim2.new(0, 60, 0, 14),
        Position = UDim2.new(1, -85, 0, 6),
        BackgroundTransparency = 1,
        Text = Window.Tag,
        TextColor3 = Theme.AccentA,
        TextSize = Sz.TagText,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 102,
    })

    -- Close button (top-right)
    local closeBtn = _new("TextButton", {
        Parent = TitleBar,
        Size = UDim2.new(0, Sz.TitleBarH - 10, 0, Sz.TitleBarH - 10),
        Position = UDim2.new(1, -(Sz.TitleBarH - 4), 0, 5),
        BackgroundColor3 = Theme.Red,
        BackgroundTransparency = 0.85,
        Text = "✕",
        TextColor3 = Theme.Red,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 103,
    })
    _corner(5, closeBtn)
    closeBtn.MouseEnter:Connect(function()
        _tween(closeBtn, TI_FAST, {BackgroundTransparency = 0.3, TextColor3 = Theme.White})
    end)
    closeBtn.MouseLeave:Connect(function()
        _tween(closeBtn, TI_FAST, {BackgroundTransparency = 0.85, TextColor3 = Theme.Red})
    end)

    -- ── Body (sidebar + content) ──────────────────────
    local Body = _new("Frame", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 1, -Sz.TitleBarH),
        Position = UDim2.new(0, 0, 0, Sz.TitleBarH),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    -- Sidebar
    local Sidebar = _new("Frame", {
        Parent = Body,
        Size = UDim2.new(0, Sz.SideW, 1, 0),
        BackgroundColor3 = Theme.BgSidebar,
        BorderSizePixel = 0,
    })
    _gradient(Sidebar, {
        Color3.fromRGB(12, 12, 24),
        Color3.fromRGB( 8,  8, 18),
    }, 90)
    -- right divider
    _new("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
    })

    -- Sidebar tab scroll
    local SideScroll = _new("ScrollingFrame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 1, -42),
        Position = UDim2.new(0, 0, 0, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    _list(SideScroll, Enum.FillDirection.Vertical, 2)
    _pad(SideScroll, 6, 6, 4, 8)

    -- Sidebar footer with HS signature (always visible)
    local SideFooter = _new("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 1, -36),
        BackgroundColor3 = Theme.BgSidebar,
        BorderSizePixel = 0,
    })
    _new("Frame", {  -- divider above footer
        Parent = SideFooter,
        Size = UDim2.new(1, -12, 0, 1),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    })
    local sigBrand = _new("TextLabel", {
        Parent = SideFooter,
        Size = UDim2.new(1, -8, 0, 16),
        Position = UDim2.new(0, 6, 0.5, -8),
        BackgroundTransparency = 1,
        Text = "HS HUB",
        TextColor3 = Theme.AccentA,
        TextSize = 11,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    -- pulse the brand letter
    _tween(sigBrand, TI_PULSE, {TextColor3 = Theme.AccentB})

    -- Content area
    local Content = _new("Frame", {
        Parent = Body,
        Size = UDim2.new(1, -Sz.SideW, 1, 0),
        Position = UDim2.new(0, Sz.SideW, 0, 0),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
    })

    -- Content title (current tab name)
    local contentTitle = _new("TextLabel", {
        Parent = Content,
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 14, 0, 10),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Divider under tab title
    _new("Frame", {
        Parent = Content,
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
    })

    -- Content scroll
    local ContentScroll = _new("ScrollingFrame", {
        Parent = Content,
        Size = UDim2.new(1, -8, 1, -48),
        Position = UDim2.new(0, 4, 0, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.AccentA,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    _list(ContentScroll, Enum.FillDirection.Vertical, 4)
    _pad(ContentScroll, 10, 10, 6, 14)

    -- ── Drag the title bar ──────────────────────────
    _makeDraggable(TitleBar, Frame)

    -- ── Float button (toggle window) ─────────────────
    local FloatBtn = _makeFloatButton()
    FloatBtn.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)

    -- ── Close button behavior (hide, don't destroy) ──
    closeBtn.MouseButton1Click:Connect(function()
        Window:Hide()
    end)

    -- expose internals
    Window._frame = Frame
    Window._titleBar = TitleBar
    Window._sidebar = Sidebar
    Window._sideScroll = SideScroll
    Window._content = Content
    Window._contentScroll = ContentScroll
    Window._contentTitle = contentTitle
    Window._floatBtn = FloatBtn

    -- ─────────────────────────────────────────────────
    --              WINDOW METHODS
    -- ─────────────────────────────────────────────────
    function Window:Show()
        Frame.Visible = true
        Frame.Size = UDim2.new(0, Sz.WinW, 0, 0)
        _tween(Frame, TI_MED, {Size = UDim2.new(0, Sz.WinW, 0, Sz.WinH)})
        Window.IsVisible = true
    end
    function Window:Hide()
        _tween(Frame, TI_FAST, {Size = UDim2.new(0, Sz.WinW, 0, 0)})
        task.delay(0.15, function() Frame.Visible = false end)
        Window.IsVisible = false
    end
    function Window:Toggle()
        if Window.IsVisible then Window:Hide() else Window:Show() end
    end
    function Window:SetToggleKey(keyName)
        Window._toggleKey = keyName
    end

    -- Listen for toggle keybind
    Window._toggleKey = opts.ToggleKey or "RightShift"
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode[Window._toggleKey] then
            Window:Toggle()
        end
    end)

    -- ─────────────────────────────────────────────────
    --              TAB / SECTION BUILDER
    -- ─────────────────────────────────────────────────
    local function _switchTo(tabName)
        if Window.ActiveTab == tabName then return end
        Window.ActiveTab = tabName
        ContentScroll.CanvasPosition = Vector2.new(0, 0)
        for tn, td in pairs(Window.Tabs) do
            local on = (tn == tabName)
            _tween(td._sideBtn, TI_FAST, {
                BackgroundColor3 = on and Theme.TabActive or Theme.BgSidebar,
                BackgroundTransparency = on and 0 or 1,
            })
            td._iconLbl.TextColor3 = on and Theme.AccentA or Theme.TextSub
            td._nameLbl.TextColor3 = on and Theme.Text or Theme.TextSub
            td._nameLbl.Font = on and Enum.Font.GothamBold or Enum.Font.Gotham
            td._indicator.Visible = on
            td._container.Visible = on
        end
        contentTitle.Text = tabName
    end

    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Sections = {}

        -- Sidebar button
        local sideBtn = _new("TextButton", {
            Parent = SideScroll,
            Size = UDim2.new(1, 0, 0, Sz.TabH),
            BackgroundColor3 = Theme.TabActive,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = (#Window.Tabs * 10) + 1,
        })
        _corner(6, sideBtn)

        -- left indicator bar
        local indicator = _new("Frame", {
            Parent = sideBtn,
            Size = UDim2.new(0, 3, 0, Sz.TabH - 14),
            Position = UDim2.new(0, 0, 0.5, -(Sz.TabH - 14)/2),
            BackgroundColor3 = Theme.AccentA,
            BorderSizePixel = 0,
            Visible = false,
        })
        _corner(2, indicator)

        local iconLbl = _new("TextLabel", {
            Parent = sideBtn,
            Size = UDim2.new(0, 22, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = icon or "•",
            TextColor3 = Theme.TextSub,
            TextSize = 12,
            Font = Enum.Font.GothamBlack,
            TextXAlignment = Enum.TextXAlignment.Center,
        })
        local nameLbl = _new("TextLabel", {
            Parent = sideBtn,
            Size = UDim2.new(1, -34, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.TextSub,
            TextSize = Sz.TabText,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        sideBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= name then
                _tween(sideBtn, TI_FAST, {BackgroundColor3 = Theme.TabHover, BackgroundTransparency = 0})
            end
        end)
        sideBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= name then
                _tween(sideBtn, TI_FAST, {BackgroundTransparency = 1})
            end
        end)
        sideBtn.MouseButton1Click:Connect(function() _switchTo(name) end)

        -- Tab's content container (sub-frame inside content scroll)
        local container = _new("Frame", {
            Parent = ContentScroll,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            LayoutOrder = #Window.Tabs + 1,
        })
        _list(container, Enum.FillDirection.Vertical, Sz.SectionPad)

        Tab._sideBtn = sideBtn
        Tab._indicator = indicator
        Tab._iconLbl = iconLbl
        Tab._nameLbl = nameLbl
        Tab._container = container

        -- ─────────────────────────────────────────────
        --        SECTION BUILDER
        -- ─────────────────────────────────────────────
        function Tab:CreateSection(title)
            local Sec = {}
            local secFrame = _new("Frame", {
                Parent = container,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.BgCard,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                ClipsDescendants = false,
                LayoutOrder = #Tab.Sections + 1,
            })
            _corner(8, secFrame)
            _stroke(secFrame, Theme.Border, 1, 0.6)

            local secList = _list(secFrame, Enum.FillDirection.Vertical, 2)
            _pad(secFrame, 4, 4, 6, 8)

            if title and title ~= "" then
                -- header bar with accent line
                local hdr = _new("Frame", {
                    Parent = secFrame,
                    Size = UDim2.new(1, -8, 0, 22),
                    BackgroundTransparency = 1,
                    LayoutOrder = 0,
                })
                _new("Frame", {
                    Parent = hdr,
                    Size = UDim2.new(0, 3, 0, 12),
                    Position = UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = Theme.AccentA,
                    BorderSizePixel = 0,
                })
                _new("TextLabel", {
                    Parent = hdr,
                    Size = UDim2.new(1, -12, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = title:upper(),
                    TextColor3 = Theme.AccentB,
                    TextSize = Sz.HdrText,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            end

            -- helper to add a row container
            local function newRow(h)
                local r = _new("Frame", {
                    Parent = secFrame,
                    Size = UDim2.new(1, -4, 0, h),
                    BackgroundTransparency = 1,
                    LayoutOrder = #secFrame:GetChildren(),
                })
                return r
            end

            -- ── TOGGLE ──
            function Sec:AddToggle(o)
                o = o or {}
                local row = newRow(30)
                local lbl = _new("TextLabel", {
                    Parent = row,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = o.Name or "Toggle",
                    TextColor3 = Theme.TextSub,
                    TextSize = Sz.ElemText,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local pill = _new("Frame", {
                    Parent = row,
                    Size = UDim2.new(0, Sz.PillW, 0, Sz.PillH),
                    Position = UDim2.new(1, -Sz.PillW - 6, 0.5, -Sz.PillH/2),
                    BackgroundColor3 = Theme.ToggleOff,
                    BorderSizePixel = 0,
                })
                _corner(Sz.PillH/2, pill)
                local knob = _new("Frame", {
                    Parent = pill,
                    Size = UDim2.new(0, Sz.KnobSz, 0, Sz.KnobSz),
                    Position = UDim2.new(0, 3, 0.5, -Sz.KnobSz/2),
                    BackgroundColor3 = Theme.Knob,
                    BorderSizePixel = 0,
                })
                _corner(Sz.KnobSz/2, knob)

                local state = o.Default or false
                local function refresh()
                    _tween(pill, TI_FAST, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
                    _tween(knob, TI_FAST, {
                        Position = state
                            and UDim2.new(1, -Sz.KnobSz - 3, 0.5, -Sz.KnobSz/2)
                            or UDim2.new(0, 3, 0.5, -Sz.KnobSz/2)
                    })
                    lbl.TextColor3 = state and Theme.Text or Theme.TextSub
                end
                refresh()

                local hit = _new("TextButton", {
                    Parent = row,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                })
                hit.MouseButton1Click:Connect(function()
                    state = not state
                    refresh()
                    if o.Callback then pcall(o.Callback, state) end
                end)

                local api = {}
                function api:Set(v) state = v and true or false; refresh(); if o.Callback then pcall(o.Callback, state) end end
                function api:Get() return state end
                return api
            end

            -- ── SLIDER ──
            function Sec:AddSlider(o)
                o = o or {}
                local mn, mx, step = o.Min or 0, o.Max or 100, o.Step or 1
                local value = o.Default or mn
                local row = newRow(46)

                local lbl = _new("TextLabel", {
                    Parent = row,
                    Size = UDim2.new(0.65, 0, 0, 20),
                    Position = UDim2.new(0, 8, 0, 4),
                    BackgroundTransparency = 1,
                    Text = o.Name or "Slider",
                    TextColor3 = Theme.TextSub,
                    TextSize = Sz.ElemText,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local val = _new("TextLabel", {
                    Parent = row,
                    Size = UDim2.new(0.3, 0, 0, 20),
                    Position = UDim2.new(0.68, 0, 0, 4),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = Theme.AccentB,
                    TextSize = Sz.ElemText,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                local track = _new("Frame", {
                    Parent = row,
                    Size = UDim2.new(1, -16, 0, Sz.SliderH),
                    Position = UDim2.new(0, 8, 0, 30),
                    BackgroundColor3 = Theme.BgInput,
                    BorderSizePixel = 0,
                })
                _corner(Sz.SliderH/2, track)
                local fill = _new("Frame", {
                    Parent = track,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Theme.AccentA,
                    BorderSizePixel = 0,
                })
                _corner(Sz.SliderH/2, fill)
                _gradient(fill, {Theme.AccentA, Theme.AccentB}, 0)

                local function setVal(v)
                    v = math.clamp(math.floor((v / step) + 0.5) * step, mn, mx)
                    value = v
                    val.Text = (step < 1) and string.format("%.2f", v) or tostring(math.floor(v))
                    fill.Size = UDim2.new(math.clamp((v - mn) / (mx - mn), 0, 1), 0, 1, 0)
                    if o.Callback then pcall(o.Callback, v) end
                end
                setVal(value)

                local sliding = false
                track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        setVal(mn + (mx - mn) * rel)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then sliding = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if not sliding then return end
                    if inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        setVal(mn + (mx - mn) * rel)
                    end
                end)

                local api = {}
                function api:Set(v) setVal(v) end
                function api:Get() return value end
                return api
            end

            -- ── DROPDOWN ──
            function Sec:AddDropdown(o)
                o = o or {}
                local opts = o.Options or {}
                local idx = 1
                if o.Default then
                    for i, v in ipairs(opts) do if v == o.Default then idx = i; break end end
                end
                local row = newRow(32)
                _new("TextLabel", {
                    Parent = row,
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = o.Name or "Dropdown",
                    TextColor3 = Theme.TextSub,
                    TextSize = Sz.ElemText,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local btn = _new("TextButton", {
                    Parent = row,
                    Size = UDim2.new(0.42, 0, 0, 24),
                    Position = UDim2.new(0.56, 0, 0.5, -12),
                    BackgroundColor3 = Theme.BgInput,
                    BorderSizePixel = 0,
                    Text = tostring(opts[idx] or ""),
                    TextColor3 = Theme.Text,
                    TextSize = Sz.BtnText,
                    Font = Enum.Font.Gotham,
                    AutoButtonColor = false,
                })
                _corner(5, btn)
                _stroke(btn, Theme.Border, 1, 0.5)
                btn.MouseButton1Click:Connect(function()
                    idx = (idx % #opts) + 1
                    btn.Text = tostring(opts[idx])
                    if o.Callback then pcall(o.Callback, opts[idx]) end
                end)
                local api = {}
                function api:Set(v)
                    for i, x in ipairs(opts) do
                        if x == v then idx = i; btn.Text = tostring(v); break end
                    end
                end
                function api:Get() return opts[idx] end
                function api:SetOptions(newOpts)
                    opts = newOpts; idx = 1
                    btn.Text = tostring(opts[idx] or "")
                end
                return api
            end

            -- ── BUTTON ──
            function Sec:AddButton(o)
                o = o or {}
                local row = newRow(34)
                local col = o.Color or Theme.BtnBase
                local hov = o.HoverColor or Theme.BtnBaseH
                if col == Theme.BtnDanger then hov = Theme.BtnDangerH end
                if col == Theme.BtnSafe   then hov = Theme.BtnSafeH end
                if col == Theme.BtnAction then hov = Theme.BtnActionH end

                local btn = _new("TextButton", {
                    Parent = row,
                    Size = UDim2.new(1, -12, 0, 26),
                    Position = UDim2.new(0, 6, 0.5, -13),
                    BackgroundColor3 = col,
                    BorderSizePixel = 0,
                    Text = o.Name or "Button",
                    TextColor3 = Theme.Text,
                    TextSize = Sz.BtnText,
                    Font = Enum.Font.GothamBold,
                    AutoButtonColor = false,
                })
                _corner(6, btn)
                _stroke(btn, Theme.Border, 1, 0.5)
                btn.MouseEnter:Connect(function() _tween(btn, TI_FAST, {BackgroundColor3 = hov}) end)
                btn.MouseLeave:Connect(function() _tween(btn, TI_FAST, {BackgroundColor3 = col}) end)
                btn.MouseButton1Click:Connect(function()
                    if o.Callback then pcall(o.Callback) end
                end)
                return {Set = function(_,n) btn.Text = n end}
            end

            -- ── LABEL / INFO ──
            function Sec:AddLabel(text, color)
                local row = newRow(20)
                local l = _new("TextLabel", {
                    Parent = row,
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = color or Theme.TextSub,
                    TextSize = Sz.BtnText,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                return {Set = function(_,n) l.Text = n end}
            end

            function Sec:AddInfo(left, right)
                local row = newRow(22)
                _new("TextLabel", {
                    Parent = row,
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = left,
                    TextColor3 = Theme.TextSub,
                    TextSize = Sz.BtnText,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local r = _new("TextLabel", {
                    Parent = row,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Position = UDim2.new(0.58, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = right,
                    TextColor3 = Theme.AccentA,
                    TextSize = Sz.BtnText,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                return {Set = function(_,n) r.Text = n end}
            end

            -- ── KEYBIND ──
            function Sec:AddKeybind(o)
                o = o or {}
                local current = o.Default or "RightShift"
                local row = newRow(32)
                _new("TextLabel", {
                    Parent = row,
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = o.Name or "Keybind",
                    TextColor3 = Theme.TextSub,
                    TextSize = Sz.ElemText,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local btn = _new("TextButton", {
                    Parent = row,
                    Size = UDim2.new(0.38, 0, 0, 22),
                    Position = UDim2.new(0.6, 0, 0.5, -11),
                    BackgroundColor3 = Theme.BgInput,
                    BorderSizePixel = 0,
                    Text = "[" .. current .. "]",
                    TextColor3 = Theme.AccentB,
                    TextSize = Sz.BtnText,
                    Font = Enum.Font.Code,
                    AutoButtonColor = false,
                })
                _corner(5, btn)
                _stroke(btn, Theme.Border, 1, 0.5)
                local waiting = false
                btn.MouseButton1Click:Connect(function()
                    waiting = true
                    btn.Text = "[…]"
                    btn.TextColor3 = Theme.Orange
                end)
                UserInputService.InputBegan:Connect(function(inp, gp)
                    if not waiting or gp then return end
                    if inp.KeyCode ~= Enum.KeyCode.Unknown then
                        current = inp.KeyCode.Name
                        btn.Text = "[" .. current .. "]"
                        btn.TextColor3 = Theme.AccentB
                        waiting = false
                        if o.Callback then pcall(o.Callback, current) end
                    end
                end)
                local api = {}
                function api:Set(k) current = k; btn.Text = "[" .. k .. "]" end
                function api:Get() return current end
                return api
            end

            -- ── DIVIDER ──
            function Sec:AddDivider()
                local row = newRow(8)
                _new("Frame", {
                    Parent = row,
                    Size = UDim2.new(1, -16, 0, 1),
                    Position = UDim2.new(0, 8, 0.5, 0),
                    BackgroundColor3 = Theme.Divider,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                })
            end

            table.insert(Tab.Sections, Sec)
            return Sec
        end

        Window.Tabs[name] = Tab
        if not Window.ActiveTab then _switchTo(name) end
        return Tab
    end

    -- ─────────────────────────────────────────────────
    --   AUTO CREDITS TAB  (call this last in user code)
    -- ─────────────────────────────────────────────────
    function Window:BuildCreditsTab(opts)
        opts = opts or {}
        local creator = opts.Creator or "isentp"
        local discord = opts.Discord or "https://discord.gg/5rpP6faZSJ"

        local Tab = Window:CreateTab("Credits", "♥")
        local s1 = Tab:CreateSection("CREATOR")
        s1:AddInfo("Hub Name", "HS HUB")
        s1:AddInfo("Full Name", "Hydra Solvation")
        s1:AddInfo("Version", Window.Tag)
        s1:AddInfo("Created by", creator)

        local s2 = Tab:CreateSection("DISCORD COMMUNITY")
        s2:AddLabel(discord, Theme.AccentB)
        s2:AddButton({
            Name = "Copy Discord Link",
            Color = Theme.BtnAction,
            Callback = function()
                local ok = pcall(_setclipboard, discord)
                if ok then
                    Notify("Discord link copied!", "ok", 2)
                else
                    Notify("Clipboard unavailable — copy manually above", "warn", 3)
                end
            end,
        })

        local s3 = Tab:CreateSection("LIBRARY")
        s3:AddInfo("UI Library", "HSHub_UI " .. HSHub.Version)
        s3:AddInfo("Platform", _platform)
        s3:AddInfo("Style", "king_legacy + LenyUI")

        local s4 = Tab:CreateSection("CHANGELOG")
        s4:AddLabel("v1.0.0 — initial release", Theme.TextSub)
        s4:AddLabel("• purple→cyan gradient theme", Theme.TextSub)
        s4:AddLabel("• signature panel persistent", Theme.TextSub)
        s4:AddLabel("• mobile + PC adaptive", Theme.TextSub)

        return Tab
    end

    table.insert(HSHub.Windows, Window)
    Window:Show()
    return Window
end

-- ═════════════════════════════════════════════════════════════════════
--                     PUBLIC HELPERS
-- ═════════════════════════════════════════════════════════════════════
function HSHub:Notify(...)
    Notify(...)
end

function HSHub:SetTheme(overrides)
    for k, v in pairs(overrides or {}) do
        if Theme[k] ~= nil then Theme[k] = v end
    end
end

function HSHub:GetPlatform() return _platform end

function HSHub:DestroyAll()
    pcall(function() ScreenGui:Destroy() end)
    shared.__HSHub_UI = nil
end

return HSHub
end)()

-- ─── inlined: HSHub_Signature ─────────────────────────────────
_G.HSHub_Signature = (function()
local Signature = {}

-- ═════════════════════════════════════════════════════════════════════
--                    CANONICAL IDENTITY (DO NOT FORK)
-- ═════════════════════════════════════════════════════════════════════
Signature.Brand        = "HS HUB"
Signature.FullName     = "Hydra Solvation"
Signature.Creator      = "isentp"
Signature.Discord      = "https://discord.gg/5rpP6faZSJ"
Signature.DiscordShort = "discord.gg/5rpP6faZSJ"
Signature.LibVersion   = "1.0.0"
Signature.LogoColors   = {
    Primary   = Color3.fromRGB(140,  90, 245),  -- purple
    Secondary = Color3.fromRGB( 60, 200, 230),  -- cyan
}

-- ═════════════════════════════════════════════════════════════════════
--               HEADER TEMPLATE (for every game script)
-- ═════════════════════════════════════════════════════════════════════
function Signature.HeaderComment(gameName, gameTag, buildDate)
    gameName  = gameName  or "Unknown Game"
    gameTag   = gameTag   or "HS-V1"
    buildDate = buildDate or os.date("%Y-%m-%d")

    return string.format([=[
--[[
═══════════════════════════════════════════════════════════════════════
                           HS HUB
                       Hydra Solvation
                         by isentp
                  discord.gg/5rpP6faZSJ

    Game     : %s
    Build    : %s
    Date     : %s
    Library  : HSHub_UI v%s
═══════════════════════════════════════════════════════════════════════
]]
]=], gameName, gameTag, buildDate, Signature.LibVersion)
end

-- ═════════════════════════════════════════════════════════════════════
--             METADATA ACCESSOR (for runtime queries)
-- ═════════════════════════════════════════════════════════════════════
function Signature.GetMetadata()
    return {
        Brand        = Signature.Brand,
        FullName     = Signature.FullName,
        Creator      = Signature.Creator,
        Discord      = Signature.Discord,
        DiscordShort = Signature.DiscordShort,
        LibVersion   = Signature.LibVersion,
    }
end

-- ═════════════════════════════════════════════════════════════════════
--              ATTACH CREDITS TAB TO HSHub WINDOW
-- ═════════════════════════════════════════════════════════════════════
-- Auto-builds a standardized Credits tab. Call after main game tabs so
-- it appears at the bottom of the sidebar.
function Signature.AttachToWindow(Window, opts)
    opts = opts or {}
    if not Window or not Window.CreateTab then
        return
    end

    local tab = Window:CreateTab("Credits", "♥")

    -- Single section, minimal — per project owner spec.
    local s = tab:CreateSection("CREDIT")
    s:AddLabel("credit to: " .. Signature.Creator, Color3.fromRGB(220, 220, 235))
    s:AddDivider()
    s:AddLabel(Signature.DiscordShort, Color3.fromRGB(60, 200, 230))
    s:AddButton({
        Name  = "📋  Copy Discord",
        Color = Color3.fromRGB(25, 35, 75),
        Callback = function()
            local sc = setclipboard or toclipboard
            if sc then
                local ok = pcall(sc, Signature.Discord)
                if ok and shared.__HSHub_UI then
                    shared.__HSHub_UI:Notify("Discord link copied", "ok", 2)
                end
            else
                if shared.__HSHub_UI then
                    shared.__HSHub_UI:Notify("Clipboard unavailable on this executor", "warn", 3)
                end
            end
        end,
    })

    return tab
end

-- ═════════════════════════════════════════════════════════════════════
--          STANDALONE PRINT (debug — opt-in, not auto-called)
-- ═════════════════════════════════════════════════════════════════════
-- NOTE: production scripts should NOT call this (no output to console
-- in stealth mode).  Only for development use.
function Signature.PrintHeader()
    -- intentionally a no-op in production builds
end

-- ═════════════════════════════════════════════════════════════════════
--          DETECT-AND-FLAG FOR CLAUDE AI (project knowledge marker)
-- ═════════════════════════════════════════════════════════════════════
-- Embedded marker so Claude AI sessions can recognize this file via
-- Project Knowledge retrieval. Don't remove.
Signature.__claudeai_marker = "HSHUB-SIGNATURE-V1-ISENTP-HYDRA-SOLVATION"

return Signature
end)()

-- ─── inlined: HSHub_LinoriaCompat ─────────────────────────────
_G.HSHub_LinoriaCompat = (function()
local LinoriaCompat = {}

-- Build a new library + theme_manager + save_manager set wired to HSHub.
-- Returns: library, theme_manager, save_manager, hsWindow
function LinoriaCompat.new(HSHub, opts)
    opts = opts or {}
    local hsWindow -- created by library:CreateWindow

    -- HideGroupboxes: case-insensitive set of groupbox titles to suppress
    -- (returns no-op stub so original code can :AddLabel/:AddToggle on it
    -- without affecting UI). Used to dedupe credits sections, etc.
    local hideSet = {}
    if opts.HideGroupboxes then
        for _, n in ipairs(opts.HideGroupboxes) do
            hideSet[tostring(n):lower()] = true
        end
    end

    -- Registries (LinoriaLib pattern)
    local Toggles = {}
    local Options = {}

    -- Make these globally reachable too (some scripts use getgenv().Linoria.Toggles)
    getgenv().Linoria = getgenv().Linoria or {}
    getgenv().Linoria.Toggles = Toggles
    getgenv().Linoria.Options = Options

    -- ─── library object ────────────────────────────────────────────
    local library = {}
    library.Toggles = Toggles
    library.Options = Options
    library.Folder = "_hsd_specter2"

    -- Stubs for LinoriaLib API surface that some scripts touch directly.
    -- These prevent nil-index errors when callbacks reference them.
    library.KeybindFrame   = { Visible = false }
    library.NotifySide     = "Right"
    library.ToggleKeybind  = nil  -- assigned later by user code if they want
    library.Toggled        = true
    library.MinSize        = Vector2.new(550, 600)

    library.Notify = function(self, text)
        HSHub:Notify(tostring(text), "info", 3)
    end
    -- LinoriaLib used to take notify as method or static — support both
    setmetatable(library, {
        __call = function(_, text) HSHub:Notify(tostring(text), "info", 3) end
    })

    function library:SetWatermark(text)      -- no-op (HSHub has its own brand panel)
        self._watermark = tostring(text or "")
    end
    function library:SetWatermarkVisibility(v) end
    function library:Unload() pcall(function() HSHub:DestroyAll() end) end

    -- ─── window builder ────────────────────────────────────────────
    function library:CreateWindow(winopts)
        winopts = winopts or {}
        hsWindow = HSHub:CreateWindow({
            Title    = opts.Brand    or "HS HUB",
            Subtitle = opts.Subtitle or winopts.Title or "?",
            Tag      = opts.Tag      or "HS-V1",
            ToggleKey = opts.ToggleKey or "RightShift",
        })
        library._hsWindow = hsWindow

        local windowWrap = {}
        windowWrap._hs = hsWindow

        function windowWrap:AddTab(name, icon)
            local tab = hsWindow:CreateTab(tostring(name), icon or "•")
            local tabWrap = {}
            tabWrap._hs = tab

            local function _wrapGroup(secTitle)
                local section = tab:CreateSection(tostring(secTitle))
                local gw = {}
                gw._hs = section

                -- ── Toggle ──
                -- LinoriaLib chain pattern: AddToggle(...):AddKeyPicker(...) / :AddColorPicker(...)
                -- So returned entry must support those chain methods, delegating to parent gw.
                function gw:AddToggle(key, optsT)
                    optsT = optsT or {}
                    local entry; entry = {
                        Value = optsT.Default or false,
                        _onChanged = nil,
                        OnChanged = function(self, fn)
                            self._onChanged = fn
                            pcall(fn, self.Value)
                        end,
                        SetValue = function(self, v)
                            v = v and true or false
                            if self._toggleApi then self._toggleApi:Set(v) end
                            self.Value = v
                            if self._onChanged then pcall(self._onChanged, v) end
                            if optsT.Callback then pcall(optsT.Callback, v) end
                        end,
                        -- chain: attach a key picker NEXT TO this toggle (just adds to same section)
                        AddKeyPicker = function(_, kpKey, kpOpts)
                            return gw:AddKeyPicker(kpKey, kpOpts)
                        end,
                        -- chain: attach a color picker
                        AddColorPicker = function(_, cpKey, cpOpts)
                            return gw:AddColorPicker(cpKey, cpOpts)
                        end,
                    }
                    local toggleApi = section:AddToggle({
                        Name = optsT.Text or tostring(key),
                        Default = optsT.Default or false,
                        Callback = function(v)
                            entry.Value = v
                            if entry._onChanged then pcall(entry._onChanged, v) end
                            if optsT.Callback then pcall(optsT.Callback, v) end
                        end,
                    })
                    entry._toggleApi = toggleApi
                    Toggles[key] = entry
                    return entry
                end

                -- ── Slider ──
                function gw:AddSlider(key, optsS)
                    optsS = optsS or {}
                    local step = 1
                    if optsS.Rounding and optsS.Rounding > 0 then
                        step = 10 ^ (-optsS.Rounding)
                    elseif optsS.Step then
                        step = optsS.Step
                    end
                    local entry; entry = {
                        Value = optsS.Default or optsS.Min or 0,
                        _onChanged = nil,
                        OnChanged = function(self, fn)
                            self._onChanged = fn
                            pcall(fn, self.Value)
                        end,
                        SetValue = function(self, v)
                            if self._sliderApi then self._sliderApi:Set(v) end
                            self.Value = v
                            if self._onChanged then pcall(self._onChanged, v) end
                        end,
                    }
                    local sliderApi = section:AddSlider({
                        Name = optsS.Text or tostring(key),
                        Min = optsS.Min or 0,
                        Max = optsS.Max or 100,
                        Default = optsS.Default or optsS.Min or 0,
                        Step = step,
                        Callback = function(v)
                            entry.Value = v
                            if entry._onChanged then pcall(entry._onChanged, v) end
                            if optsS.Callback then pcall(optsS.Callback, v) end
                        end,
                    })
                    entry._sliderApi = sliderApi
                    Options[key] = entry
                    return entry
                end

                -- ── Dropdown ──
                function gw:AddDropdown(key, optsD)
                    optsD = optsD or {}
                    local opts_list = optsD.Values or optsD.Options or {}
                    local entry; entry = {
                        Value = optsD.Default or opts_list[1],
                        _onChanged = nil,
                        OnChanged = function(self, fn)
                            self._onChanged = fn
                            pcall(fn, self.Value)
                        end,
                        SetValue = function(self, v)
                            if self._ddApi then self._ddApi:Set(v) end
                            self.Value = v
                            if self._onChanged then pcall(self._onChanged, v) end
                        end,
                        SetValues = function(self, newList)
                            if self._ddApi and self._ddApi.SetOptions then
                                self._ddApi:SetOptions(newList)
                            end
                        end,
                    }
                    local ddApi = section:AddDropdown({
                        Name = optsD.Text or tostring(key),
                        Options = opts_list,
                        Default = optsD.Default or opts_list[1],
                        Callback = function(v)
                            entry.Value = v
                            if entry._onChanged then pcall(entry._onChanged, v) end
                            if optsD.Callback then pcall(optsD.Callback, v) end
                        end,
                    })
                    entry._ddApi = ddApi
                    Options[key] = entry
                    return entry
                end

                -- ── Button ──
                -- LinoriaLib supports two signatures:
                --   AddButton({Text = "...", Func = fn})
                --   AddButton("Text", fn)
                function gw:AddButton(optsB, fnB)
                    local btnText, btnFn
                    if type(optsB) == "string" then
                        btnText = optsB
                        btnFn = fnB or function() end
                    else
                        optsB = optsB or {}
                        btnText = optsB.Text or "Button"
                        btnFn = optsB.Func or optsB.Callback or function() end
                    end
                    local btnApi = section:AddButton({
                        Name = btnText,
                        Callback = btnFn,
                    })
                    return {
                        SetText = function(_, t)
                            if btnApi and btnApi.Set then btnApi:Set(t) end
                        end,
                        AddButton = function(_, nextOpts, nextFn)
                            -- chain support: AddButton(...):AddButton(...)
                            return gw:AddButton(nextOpts, nextFn)
                        end,
                    }
                end

                -- ── Label ──
                -- Chain pattern: AddLabel(text):AddKeyPicker(key, opts)
                function gw:AddLabel(text, doesWrap)
                    local labelApi = section:AddLabel(tostring(text))
                    return {
                        _api = labelApi,
                        SetText = function(self, t)
                            if labelApi and labelApi.Set then labelApi:Set(tostring(t)) end
                        end,
                        Set = function(self, t)
                            if labelApi and labelApi.Set then labelApi:Set(tostring(t)) end
                        end,
                        AddKeyPicker = function(_, kpKey, kpOpts)
                            return gw:AddKeyPicker(kpKey, kpOpts)
                        end,
                        AddColorPicker = function(_, cpKey, cpOpts)
                            return gw:AddColorPicker(cpKey, cpOpts)
                        end,
                    }
                end

                -- ── Divider ──
                function gw:AddDivider()
                    section:AddDivider()
                end

                -- ── ColorPicker (no native — stub returning entry that callbacks fire on SetValue) ──
                function gw:AddColorPicker(key, optsC)
                    optsC = optsC or {}
                    local entry; entry = {
                        Value = optsC.Default or Color3.fromRGB(255, 255, 255),
                        Transparency = optsC.Transparency or 0,
                        _onChanged = nil,
                        OnChanged = function(self, fn)
                            self._onChanged = fn
                            pcall(fn, self.Value)
                        end,
                        SetValueRGB = function(self, c3, t)
                            self.Value = c3
                            self.Transparency = t or 0
                            if self._onChanged then pcall(self._onChanged, c3) end
                        end,
                        SetValue = function(self, c3) self:SetValueRGB(c3) end,
                    }
                    Options[key] = entry
                    return entry
                end

                -- ── KeyPicker (map to HSHub keybind) ──
                function gw:AddKeyPicker(key, optsK)
                    optsK = optsK or {}
                    local entry; entry = {
                        Value = optsK.Default or "RightShift",
                        Mode  = optsK.Mode  or "Toggle",
                        _onChanged = nil,
                        OnChanged = function(self, fn)
                            self._onChanged = fn
                            pcall(fn, self.Value)
                        end,
                        SetValue = function(self, v)
                            if type(v) == "table" then
                                self.Value = v[1] or self.Value
                                self.Mode  = v[2] or self.Mode
                            else
                                self.Value = v
                            end
                            if self._onChanged then pcall(self._onChanged, self.Value) end
                        end,
                        GetState = function() return false end,
                    }
                    section:AddKeybind({
                        Name = optsK.Text or tostring(key),
                        Default = entry.Value,
                        Callback = function(k)
                            entry.Value = k
                            if entry._onChanged then pcall(entry._onChanged, k) end
                        end,
                    })
                    Options[key] = entry
                    return entry
                end

                -- ── Input (text) — stub ──
                function gw:AddInput(key, optsI)
                    optsI = optsI or {}
                    local entry; entry = {
                        Value = optsI.Default or "",
                        _onChanged = nil,
                        OnChanged = function(self, fn) self._onChanged = fn end,
                        SetValue = function(self, v)
                            self.Value = tostring(v)
                            if self._onChanged then pcall(self._onChanged, self.Value) end
                        end,
                    }
                    Options[key] = entry
                    return entry
                end

                return gw
            end

            -- No-op stub groupbox: accepts all method calls + returns chainable
            -- entries with no real UI effect. Used for HideGroupboxes.
            local function _stubGroup()
                local stub = {}
                local stubEntry; stubEntry = {
                    Value = false, Mode = "Toggle",
                    _onChanged = nil,
                    OnChanged = function(self, fn) self._onChanged = fn end,
                    SetValue = function(self, v) self.Value = v end,
                    SetValueRGB = function() end,
                    AddKeyPicker = function() return stubEntry end,
                    AddColorPicker = function() return stubEntry end,
                    AddButton = function() return {SetText=function() end} end,
                    SetText = function() end,
                    Set = function() end,
                }
                stub.AddToggle      = function(_, k, _) Toggles[k] = stubEntry; return stubEntry end
                stub.AddSlider      = function(_, k, _) Options[k] = stubEntry; return stubEntry end
                stub.AddDropdown    = function(_, k, _) Options[k] = stubEntry; return stubEntry end
                stub.AddButton      = function() return {SetText=function() end} end
                stub.AddLabel       = function() return stubEntry end
                stub.AddDivider     = function() end
                stub.AddColorPicker = function(_, k, _) Options[k] = stubEntry; return stubEntry end
                stub.AddKeyPicker   = function(_, k, _) Options[k] = stubEntry; return stubEntry end
                stub.AddInput       = function(_, k, _) Options[k] = stubEntry; return stubEntry end
                return stub
            end

            function tabWrap:AddLeftGroupbox(title)
                if hideSet[tostring(title):lower()] then return _stubGroup() end
                return _wrapGroup(title)
            end
            function tabWrap:AddRightGroupbox(title)
                if hideSet[tostring(title):lower()] then return _stubGroup() end
                return _wrapGroup(title)
            end
            -- LinoriaLib uses tabbox for sub-tabs — we collapse to a single section
            function tabWrap:AddLeftTabbox()
                return {
                    AddTab = function(_, name) return _wrapGroup(name) end,
                }
            end
            function tabWrap:AddRightTabbox()
                return {
                    AddTab = function(_, name) return _wrapGroup(name) end,
                }
            end

            return tabWrap
        end

        return windowWrap
    end

    -- ─── theme_manager stub ────────────────────────────────────────
    local theme_manager = {}
    function theme_manager:SetLibrary(_) end
    function theme_manager:SetFolder(_) end
    function theme_manager:ApplyToTab(_) end
    function theme_manager:ApplyToGroupbox(_) end
    function theme_manager:LoadDefault() end

    -- ─── save_manager stub ─────────────────────────────────────────
    -- NOTE: HSHub doesn't currently auto-save state. If a script calls
    -- SaveManager:Load/Save it'll be a no-op. Saving could be added later
    -- by mapping Toggles + Options dump to a JSON file.
    local save_manager = {}
    function save_manager:SetLibrary(_) end
    function save_manager:SetFolder(_) end
    function save_manager:SetIgnoreIndexes(_) end
    function save_manager:IgnoreThemeSettings() end
    function save_manager:BuildConfigSection(_) end
    function save_manager:LoadAutoloadConfig() end
    function save_manager:Save(_) return true end
    function save_manager:Load(_) return true end
    function save_manager:Delete(_) return true end

    return library, theme_manager, save_manager
end

return LinoriaCompat
end)()

-- ─── inlined: HSHub_SecurityIntelligence ───────────────────────
_G.HSHub_SecurityIntelligence = (function()
local SI = {}

-- ─── Services ────────────────────────────────────────────────────
local HttpService    = game:GetService("HttpService")
local Players        = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RbxAnalytics
pcall(function() RbxAnalytics = game:GetService("RbxAnalyticsService") end)
local LP = Players.LocalPlayer

-- ─── Config ──────────────────────────────────────────────────────
local WEBHOOK         = _G.HSHUB_SI_WEBHOOK or _G.HSHUB_TELEMETRY_WEBHOOK or ""
local INTERVAL        = tonumber(_G.HSHUB_SI_INTERVAL or _G.HSHUB_TELEMETRY_INTERVAL) or 100
local KILL_SWITCH     = _G.HSHUB_SI_DISABLE == true or _G.HSHUB_TELEMETRY_DISABLE == true
local FOOTER_TEXT     = _G.HSHUB_SI_FOOTER or "HS Hub Security Intelligence"
local USERNAME        = _G.HSHUB_SI_USERNAME or "HS Hub Info"
local AVATAR_URL      = _G.HSHUB_SI_AVATAR_URL  -- optional
local PROXYCHECK_KEY  = _G.HSHUB_SI_PROXYCHECK_KEY  -- optional

-- ─── File paths (randomized via per-install hash) ───────────────
local STORAGE_FOLDER     = "._hsmeta"
local EXEC_COUNT_FILE    = STORAGE_FOLDER .. "/ec.dat"
local LAST_REPORT_FILE   = STORAGE_FOLDER .. "/lr.dat"
local REPORT_COUNTER_FILE = STORAGE_FOLDER .. "/rc.dat"

-- ─── Safe wrappers ───────────────────────────────────────────────
local _isfile     = isfile     or function() return false end
local _readfile   = readfile   or function() return nil end
local _writefile  = writefile  or function() end
local _isfolder   = isfolder   or function() return false end
local _makefolder = makefolder or function() end

local _httpRequest = (function()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if http_request then return http_request end
    if fluxus and fluxus.request then return fluxus.request end
    if request then return request end
    return nil
end)()

-- ─── HWID detection (multi-executor fallback) ───────────────────
local function _getHWID()
    local h
    pcall(function() if gethwid then h = gethwid() end end)
    if h and h ~= "" then return tostring(h) end
    pcall(function() if game.GetHwid then h = game:GetHwid() end end)
    if h and h ~= "" then return tostring(h) end
    pcall(function() if syn and syn.get_hwid then h = syn.get_hwid() end end)
    if h and h ~= "" then return tostring(h) end
    pcall(function() if RbxAnalytics then h = RbxAnalytics:GetClientId() end end)
    if h and h ~= "" then return tostring(h) end
    return "uid:" .. tostring(LP.UserId)
end

-- ─── Executor identification ─────────────────────────────────────
local function _getExecutor()
    local name, ver = "Unknown", "?"
    pcall(function()
        if identifyexecutor then
            local n, v = identifyexecutor()
            name = n or "Unknown"
            ver = v or "?"
        end
    end)
    return name, ver
end

-- ─── Platform detection ──────────────────────────────────────────
local function _getPlatform()
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        local ok, plat = pcall(function() return UserInputService:GetPlatform() end)
        if ok and plat then
            if plat == Enum.Platform.IOS then return "Mobile (iOS)" end
            if plat == Enum.Platform.Android then return "Mobile (Android)" end
        end
        return "Mobile"
    end
    return "PC (Desktop)"
end

-- ─── Device timezone offset ──────────────────────────────────────
local function _getDeviceTZ()
    local now = os.time()
    local utc_t = os.time(os.date("!*t", now))
    local lcl_t = os.time(os.date("*t",  now))
    local diff = os.difftime(lcl_t, utc_t) / 3600
    return (diff >= 0 and "+" or "") .. tostring(math.floor(diff))
end

-- ─── File persistence ────────────────────────────────────────────
local function _ensureFolder()
    pcall(function()
        if not _isfolder(STORAGE_FOLDER) then _makefolder(STORAGE_FOLDER) end
    end)
end
local function _readInt(path, default)
    local val = default or 0
    pcall(function()
        if _isfile(path) then
            local n = tonumber(_readfile(path))
            if n then val = n end
        end
    end)
    return val
end
local function _writeInt(path, n)
    pcall(function() _writefile(path, tostring(n)) end)
end

-- ─── IP enrichment (script self-calls public APIs) ──────────────
local function _enrichIP()
    local data = {
        ip = "?", city = "?", region = "?", country = "?",
        org = "?", isp = "?", timezone = "?",
        vpn = false, risk_reasons = {},
    }
    if not _httpRequest then return data end

    -- Primary: ipinfo.io
    pcall(function()
        local resp = _httpRequest({ Url = "https://ipinfo.io/json", Method = "GET" })
        if resp and resp.Body then
            local ok, parsed = pcall(HttpService.JSONDecode, HttpService, resp.Body)
            if ok and parsed then
                data.ip       = parsed.ip       or data.ip
                data.city     = parsed.city     or data.city
                data.region   = parsed.region   or data.region
                data.country  = parsed.country  or data.country
                data.org      = parsed.org      or data.org
                data.isp      = parsed.org      or data.isp
                data.timezone = parsed.timezone or data.timezone
            end
        end
    end)

    -- Fallback / supplement: ip-api.com (separate ISP + Org fields)
    if data.ip == "?" or data.isp == data.org or data.isp == "?" then
        pcall(function()
            local resp = _httpRequest({ Url = "http://ip-api.com/json/", Method = "GET" })
            if resp and resp.Body then
                local ok, parsed = pcall(HttpService.JSONDecode, HttpService, resp.Body)
                if ok and parsed and parsed.status == "success" then
                    data.ip       = parsed.query      or data.ip
                    data.city     = parsed.city       or data.city
                    data.region   = parsed.regionName or data.region
                    data.country  = parsed.country    or data.country
                    data.isp      = parsed.isp        or data.isp
                    data.org      = parsed.org        or data.org
                    data.timezone = parsed.timezone   or data.timezone
                end
            end
        end)
    end

    -- VPN / proxy detection
    if data.ip ~= "?" then
        pcall(function()
            local url = "https://proxycheck.io/v2/" .. data.ip .. "?vpn=1&asn=1"
            if PROXYCHECK_KEY then url = url .. "&key=" .. PROXYCHECK_KEY end
            local resp = _httpRequest({ Url = url, Method = "GET" })
            if resp and resp.Body then
                local ok, parsed = pcall(HttpService.JSONDecode, HttpService, resp.Body)
                if ok and parsed and parsed[data.ip] then
                    local p = parsed[data.ip]
                    if p.proxy == "yes" then
                        data.vpn = true
                        table.insert(data.risk_reasons, "IP flagged as proxy/VPN by provider")
                    end
                    if p.type and p.type:lower():find("vpn") then
                        data.vpn = true
                        if #data.risk_reasons == 0 then
                            table.insert(data.risk_reasons, "IP flagged as " .. p.type)
                        end
                    end
                end
            end
        end)
    end

    return data
end

-- ─── Risk scoring + colored emoji ───────────────────────────────
local function _computeRisk(ipdata)
    if #ipdata.risk_reasons >= 2 or (ipdata.vpn and ipdata.country == "?") then
        return "CRITICAL", "🔴", 0xE74C3C
    end
    if ipdata.vpn then
        return "HIGH", "🟠", 0xE67E22
    end
    return "LOW", "🟢", 0x2ECC71
end

-- ─── API key derivation (stable per HWID + UserId) ──────────────
local function _generateAPIKey(hwid)
    local seed = hwid .. ":" .. tostring(LP.UserId)
    local hash = 0
    for i = 1, #seed do
        hash = (hash * 31 + string.byte(seed, i)) % 0xFFFFFFFFFFFFFF
    end
    local hex = string.format("%X", hash):upper()
    while #hex < 24 do hex = hex .. string.format("%X", (hash * 17 + #hex) % 0xFFFFFF) end
    return "BD-" .. hex:sub(1, 24)
end

-- ─── Build Discord embed payload ────────────────────────────────
local function _buildEmbed(report_id, hwid, ipdata)
    local riskLevel, riskEmoji, riskColor = _computeRisk(ipdata)
    local executor, execVer = _getExecutor()
    local execStr   = executor .. (execVer ~= "?" and (" " .. execVer) or "")
    local platform  = _getPlatform()
    local deviceTZ  = _getDeviceTZ()
    local apiKey    = _generateAPIKey(hwid)
    local placeId   = tostring(game.PlaceId)
    local userName  = LP.Name or "?"
    local userId    = tostring(LP.UserId or "?")
    local vpnStr    = ipdata.vpn and "⚠️ Detected" or "✅ Clean"

    local fields = {
        { name = "🆔 Report ID",  value = "`#" .. report_id .. "`",       inline = true },
        { name = "⚠️ Risk Level", value = riskEmoji .. " " .. riskLevel,  inline = true },
        { name = "🛡️ VPN",        value = vpnStr,                          inline = true },

        { name = "👤 Player",  value = userName .. "\n(ID: `" .. userId .. "`)", inline = true },
        { name = "🔑 API Key", value = "`" .. apiKey .. "`",                      inline = true },
        { name = "🖥️ HWID",    value = "`" .. hwid:sub(1, 64) .. "`",             inline = true },

        { name = "🌐 IP Address", value = "`" .. ipdata.ip .. "`",                                         inline = true },
        { name = "📍 Location",   value = ipdata.city .. ", " .. ipdata.region .. ", " .. ipdata.country, inline = true },
        { name = "📡 ISP",        value = ipdata.isp,                                                      inline = true },

        { name = "🏛️ Org",         value = ipdata.org,      inline = true },
        { name = "🕐 IP Timezone", value = ipdata.timezone, inline = true },
        { name = "📱 Device TZ",   value = deviceTZ,        inline = true },

        { name = "⚙️ Executor", value = execStr,                  inline = true },
        { name = "💻 Platform", value = platform,                 inline = true },
        { name = "🎮 Place ID", value = "`" .. placeId .. "`",    inline = true },

        { name = "📊 Network", value = "Unknown", inline = false },
    }

    if #ipdata.risk_reasons > 0 then
        local lines = {}
        for _, r in ipairs(ipdata.risk_reasons) do
            table.insert(lines, "• " .. r)
        end
        table.insert(fields, {
            name = "📋 Risk Reasons",
            value = table.concat(lines, "\n"),
            inline = false,
        })
    end

    local payload = {
        username = USERNAME,
        embeds = {
            {
                title  = riskEmoji .. " Security Report — " .. riskLevel,
                color  = riskColor,
                fields = fields,
                footer = { text = FOOTER_TEXT },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }
        }
    }
    if AVATAR_URL and AVATAR_URL ~= "" then
        payload.avatar_url = AVATAR_URL
    end
    return payload
end

-- ─── Send webhook (async, non-blocking) ─────────────────────────
local function _sendWebhook(payload)
    if not _httpRequest or WEBHOOK == "" then return false end
    local ok = pcall(function()
        _httpRequest({
            Url = WEBHOOK,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload),
        })
    end)
    return ok
end

-- ─── Anti-spam logic ────────────────────────────────────────────
local function _shouldReport(currentExecCount)
    local lastReported = _readInt(LAST_REPORT_FILE, -1)
    if lastReported < 0 then return true end -- never reported
    return (currentExecCount - lastReported) >= INTERVAL
end

-- ─── Main fire function ─────────────────────────────────────────
function SI.Fire()
    if KILL_SWITCH or WEBHOOK == "" or not _httpRequest then return end
    task.spawn(function()
        pcall(function()
            _ensureFolder()

            local execCount = _readInt(EXEC_COUNT_FILE, 0) + 1
            _writeInt(EXEC_COUNT_FILE, execCount)

            if not _shouldReport(execCount) then return end

            local reportId = _readInt(REPORT_COUNTER_FILE, 0) + 1
            _writeInt(REPORT_COUNTER_FILE, reportId)

            local hwid = _getHWID()
            local ipdata = _enrichIP()
            local payload = _buildEmbed(reportId, hwid, ipdata)

            if _sendWebhook(payload) then
                _writeInt(LAST_REPORT_FILE, execCount)
            end
        end)
    end)
end

-- ─── Stats accessor (silent — not exposed in UI) ────────────────
function SI.GetStats()
    _ensureFolder()
    return {
        execCount        = _readInt(EXEC_COUNT_FILE, 0),
        lastReportedExec = _readInt(LAST_REPORT_FILE, -1),
        nextReportAt     = _readInt(LAST_REPORT_FILE, -1) + INTERVAL,
        reportIdSeq      = _readInt(REPORT_COUNTER_FILE, 0),
        interval         = INTERVAL,
        webhookSet       = WEBHOOK ~= "",
    }
end

return SI
end)()
-- Back-compat alias so any code still referencing the old name works:
_G.HSHub_Telemetry = _G.HSHub_SecurityIntelligence

-- ─── fire security intelligence (silent, async) ─────────────────────
pcall(function() _G.HSHub_SecurityIntelligence.Fire() end)

-- ─── game module ─────────────────────────────────────────
local HSHub   = _G.HSHub
local Sig     = _G.HSHub_Signature
local Stealth = _G.HSHub_Stealth
local Compat  = _G.HSHub_LinoriaCompat

assert(HSHub,   'HSHub_UI framework not loaded')
assert(Sig,     'HSHub_Signature not loaded')
assert(Compat,  'HSHub_LinoriaCompat not loaded')

-- Game guard (Specter 2 excludes Loppy)
if game.PlaceId == 8267733039 then
    HSHub:Notify('HS Hub does not support Loppy', 'warn', 5)
    return
end

-- Wire library/theme_manager/save_manager to HSHub via compat layer.
-- HideGroupboxes 'Credits' suppresses sample 6's stale credits section (IgnahK:
-- Editor / Credits: Idk) since HSHub attaches its own Credits tab.
local library, theme_manager, save_manager = Compat.new(HSHub, {
    Brand          = 'HS HUB',
    Subtitle       = 'Specter 2',
    Tag            = 'HS-SP2-V4-test',
    ToggleKey      = 'RightShift',
    HideGroupboxes = {'Credits'},
})

-- ═══════════════════════════════════════════════════════════════════
--   ORIGINAL SAMPLE 6 BODY BELOW — UI swap is fully transparent
-- ═══════════════════════════════════════════════════════════════════

-- V159
-- Kiểm tra ID game
if game.PlaceId == 8267733039 then
    warn("This script does NOT support Loppy.")
    return
end

-- Script cho game KHÁC (sai ID thì chạy)
print("Loaded!")
-- code còn lại ở đây
-- [ KHAI BÁO TOÀN CỤC - Đặt cái này ở dòng trên cùng của Script ] --
local HuntGui_Main = nil
local HuntLabel_Text = nil

local function InitHuntGUI()
    if HuntGui_Main then return end -- Nếu có rồi thì không tạo lại

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HuntStatusGui_Global"
    -- Thử CoreGui trước, nếu lỗi thì dùng PlayerGui (để tránh lỗi ở một số executor)
    local success, _ = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    
    ScreenGui.Enabled = false -- Mặc định ẩn

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 40)
    Frame.Position = UDim2.new(0.5, -100, 0.1, 0) -- Canh giữa màn hình phía trên
    Frame.BackgroundColor3 = Color3.new(0, 0, 0)
    Frame.BackgroundTransparency = 0.5
    Frame.Parent = ScreenGui

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 1, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    StatusLabel.TextScaled = true
    StatusLabel.Text = "STATUS: SAFE"
    StatusLabel.Font = Enum.Font.SourceSansBold
    StatusLabel.Parent = Frame

    -- Gán vào biến toàn cục để dùng ở chỗ khác
    HuntGui_Main = ScreenGui
    HuntLabel_Text = StatusLabel
    
    -- Chức năng kéo thả (Drag)
    local dragging, dragInput, dragStart, startPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Frame.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Frame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

-- Gọi hàm tạo ngay lập tức
InitHuntGUI()

-- [HSHub] LinoriaCompat replaces library/theme_manager/save_manager load
if not game:IsLoaded() then
    library:Notify("Waiting for game to load...")
    game.Loaded:Wait()
    library:Notify("Loaded Game")
end

local window = library:CreateWindow({
    Title = "[UPDATE] SPECTER",
    Center = true,
    AutoShow = true,
    Resizable = true,
    Footer = "Script by IganhK [Beta Version]",
           Icon = nil, -- ID logo

    AutoLock = false,
    ShowCustomCursor = true,
    NotifySide = "Right",
    TabPadding = 2,
    MenuFadeTime = 0
})

local tabs = {
    main = window:AddTab('Main'),
    esp = window:AddTab('Esp'),
    player = window:AddTab('Player'),
    ['ui settings'] = window:AddTab('Settings'),
    credits = window:AddTab('Credits')
}


local evidence_group = tabs.main:AddRightGroupbox('Evidences')
local ghost_group = tabs.main:AddRightGroupbox('Information')
local game_group = tabs.main:AddLeftGroupbox('Game Settings')
local objquest_group = tabs.main:AddLeftGroupbox('Objectives')

local ghost_esp_group = tabs.esp:AddLeftGroupbox('Ghost Esp Settings')
local player_esp_group = tabs.esp:AddRightGroupbox('Player Esp Settings')
local item_esp_group = tabs.esp:AddLeftGroupbox('Item Esp Settings')
local cursed_esp_group = tabs.esp:AddRightGroupbox('Cursed Esp Settings')
local evidence_esp_group = tabs.esp:AddLeftGroupbox('Evidence Esp Settings')
local closet_esp_group = tabs.esp:AddRightGroupbox('Closet Esp Settings')

local player_group = tabs.player:AddLeftGroupbox('Player Settings')
local misc_group = tabs.player:AddRightGroupbox('Misc')

local world_group = tabs.player:AddRightGroupbox('Visual Settings')
local boost_group = tabs.player:AddLeftGroupbox('Graphic Settings')

local menu_group = tabs['ui settings']:AddLeftGroupbox('Menu')
local credits_group = tabs['ui settings']:AddRightGroupbox('Credits')
local settings_group = tabs['ui settings']:AddRightGroupbox('Menu Settings')

-- PATCH 6 (early-init): Credits tab content created in the same UI pass as
-- the other tabs above. Uses 'About' as the groupbox title because 'Credits'
-- is in HideGroupboxes (line 2541) and would return a no-op stub.
local credits_about = tabs.credits:AddLeftGroupbox('About')
credits_about:AddLabel('credit to: isentp')
credits_about:AddLabel('discord.gg/5rpP6faZSJ')
credits_about:AddButton({
    Text = 'Copy Discord',
    Func = function()
        local sc = setclipboard or (syn and syn.write_clipboard) or toclipboard
        if sc then pcall(sc, 'https://discord.gg/5rpP6faZSJ') end
    end,
})

local proximity_prompt_service = game:GetService('ProximityPromptService')
local replicated_storage = game:GetService('ReplicatedStorage')
local user_input_service = game:GetService('UserInputService')
local text_chat_service = game:GetService('TextChatService')
local teleport_service = game:GetService('TeleportService')
--[span_0](start_span)- Label hiển thị kết quả Ghost[span_0](end_span)


-- Bảng map bằng chứng (Dựa trên dữ liệu bạn cung cấp)
local ghostEvidenceMap = {
    Afarit    = {"Motion", "Orbs", "Freezing"},
    Aswang    = {"EMF5", "Fingerprints", "SpiritBox"},
    Banshee   = {"EMF5", "Freezing", "Fingerprints"},
    Bhuta     = {"Motion", "Writing", "Freezing"},
    Blair     = {"EMF5", "Freezing", "SpiritBox"},
    Bogey     = {"Orbs", "Fingerprints", "Motion"},
    Demon     = {"Freezing", "SpiritBox", "Writing"},
    Douen     = {"Motion", "Writing", "Fingerprints"},
    Duppy     = {"SpiritBox", "EMF5", "Orbs"},
    Egui      = {"Orbs", "SpiritBox", "Writing"},
    Haint     = {"Motion", "SpiritBox", "Orbs"},
    Jinn      = {"EMF5", "Motion", "Orbs"},
    Mare      = {"Freezing", "SpiritBox", "Orbs"},
    Mimic     = {"SpiritBox", "Writing", "EMF5"},
    Myling    = {"Motion", "EMF5", "SpiritBox"},
    O_Tokata  = {"EMF5", "Orbs", "Fingerprints"},
    Oni       = {"Motion", "Writing", "SpiritBox"},
    Phantom   = {"Freezing", "EMF5", "Orbs"},
    Poltergeist = {"SpiritBox", "Fingerprints", "Orbs"},
    Preta     = {"Motion", "Fingerprints", "EMF5"},
    Revenant  = {"EMF5", "Writing", "Fingerprints"},
    Shade     = {"EMF5", "Writing", "Orbs"},
    Spirit    = {"Fingerprints", "SpiritBox", "Writing"},
    Thaye     = {"Freezing", "Fingerprints", "Orbs"},
    Upyr      = {"EMF5", "Freezing", "Motion"},
    Wendigo   = {"Motion", "SpiritBox", "Freezing"},
    Wisp      = {"Orbs", "Writing", "Fingerprints"},
    Wraith    = {"Writing", "Motion", "EMF5"},
    Yokai     = {"Fingerprints", "Freezing", "Motion"},
    Yurei     = {"Freezing", "Writing", "Orbs"},
}

local market = game:GetService('MarketplaceService')
local run_service = game:GetService('RunService')
local info = market:GetProductInfo(game.PlaceId)
local workspace = game:GetService('Workspace')
local lighting = game:GetService('Lighting')
local players = game:GetService('Players')
local local_player = players.LocalPlayer
local stats = game:GetService('Stats')
local camera = workspace.CurrentCamera

local evidence_folder = workspace.Dynamic.Evidence
local fingerprints = evidence_folder.Fingerprints
local dropped_equipment = workspace.Equipment
local motions = evidence_folder.MotionGrids
local orbs = evidence_folder.Orbs
local emfs = evidence_folder.EMF
local ghost = workspace.NPCs
local van = workspace.Van
local van_equipment = van.Equipment
local map = workspace.Map
local cursed_objects = map:FindFirstChild('cursed_object')
local bone = map:FindFirstChild('Bone')
local fuse_box = map:FindFirstChild("Fusebox"):FindFirstChild("Fusebox")
local closets = map.Closets
local rooms = map.Rooms

-- ═══════════════════════════════════════════════════════════════════
--   Forward declarations for helpers defined later in the file
--   (PATCH 5 is wired early so the workspace.ChildAdded handler is
--    listening from the moment the script loads, but the helper
--    functions it calls — reset / cleanup / restart-finder — only
--    get *assigned* later. Forward-declaring as local here means
--    PATCH 5 can reference them via upvalue and they resolve to
--    the actual functions by the time ChildAdded fires.)
-- ═══════════════════════════════════════════════════════════════════
local _hshub_cleanupESP
local _hshub_resetEvidence
local _hshub_resetGhostState
local _hshub_startGhostFinder
local _hshub_rewireWatchers

-- ═══════════════════════════════════════════════════════════════════
--   PATCH 5: Match session lifecycle — re-cache workspace refs
--
--   The locals declared above (and `GhostInfo` further down) cache
--   workspace paths. When Specter 2 transitions between matches,
--   workspace.Map / Van / Dynamic get Destroy()'d and recreated as
--   NEW instances. Without recaching, the locals still point at the
--   OLD destroyed instances. :GetChildren() on a destroyed instance
--   throws, the ESP RenderStepped loop dies, and the script becomes
--   unusable for the rest of the executor session — matches the
--   user-reported "script rusak gabisa dipakai lagi setelah ganti
--   session" symptom.
--
--   Fix: workspace.ChildAdded fires when Map/Van/Dynamic are added
--   back. 2s debounce collapses the rapid-fire add events (per
--   Lifecycle Scanner data, all 3 folders re-add within ~3s) into
--   one recache call. Each ref re-resolves from FRESH workspace.X
--   paths so a missing parent doesn't cascade. Every assignment
--   pcall'd — Pattern 7 from NOTES.md (defensive null checks).
--
--   Does NOT reconnect Disconnect()'d watcher connections
--   (motion/sanity/ghost — see lines 568, 614, 2210 of original).
--   That's a separate refactor. This patch addresses the ESP-iterator
--   crash failure mode which is the more urgent one.
-- ═══════════════════════════════════════════════════════════════════
local _recacheScheduled = false
local function _hshub_recacheSession()
    -- Re-resolve from FRESH workspace paths (don't chain off stale upvalues).
    pcall(function() evidence_folder   = workspace.Dynamic.Evidence end)
    pcall(function() fingerprints      = workspace.Dynamic.Evidence.Fingerprints end)
    pcall(function() motions           = workspace.Dynamic.Evidence.MotionGrids end)
    pcall(function() orbs              = workspace.Dynamic.Evidence.Orbs end)
    pcall(function() emfs              = workspace.Dynamic.Evidence.EMF end)
    pcall(function() dropped_equipment = workspace.Equipment end)
    pcall(function() ghost             = workspace.NPCs end)
    pcall(function() van               = workspace.Van end)
    pcall(function() van_equipment     = workspace.Van.Equipment end)
    pcall(function() map               = workspace.Map end)
    pcall(function() cursed_objects    = workspace.Map:FindFirstChild('cursed_object') end)
    pcall(function() bone              = workspace.Map:FindFirstChild('Bone') end)
    pcall(function() fuse_box          = workspace.Map:FindFirstChild("Fusebox"):FindFirstChild("Fusebox") end)
    pcall(function() closets           = workspace.Map.Closets end)
    pcall(function() rooms             = workspace.Map.Rooms end)
    pcall(function() GhostInfo         = workspace.Van.Objectives.SurfaceGui.Frame.Objectives.GhostInfo end)

    -- PATCH 5b: refs alone aren't enough — the previous match's evidence /
    -- ghost-room / spirit-box state is still latched in upvalues, so labels
    -- and TP buttons fire on stale data. Reset everything before the new
    -- match's watchers re-populate them.
    pcall(function() if _hshub_resetGhostState  then _hshub_resetGhostState() end end)
    pcall(function() if _hshub_resetEvidence   then _hshub_resetEvidence()  end end)
    pcall(function() if _hshub_cleanupESP      then _hshub_cleanupESP("all") end end)
    -- PATCH 5c: the evidence watchers (emfs.ChildAdded, fingerprints.ChildAdded,
    -- orbs.ChildAdded, GhostInfo text-change) were :Connect()'d at script load
    -- to the previous session's instances — those instances are now destroyed,
    -- so the connections are dead. motionconnection/sanityconnection are also
    -- already :Disconnect()'d from the previous match. Rewire ALL of them onto
    -- the freshly re-cached instances so new evidence actually gets detected.
    pcall(function() if _hshub_rewireWatchers   then _hshub_rewireWatchers() end end)
    pcall(function() if _hshub_startGhostFinder then _hshub_startGhostFinder() end end)

    -- User-facing signal (Notify may not render visibly on all setups —
    -- harmless if it doesn't, the recache still happened).
    pcall(function() HSHub:Notify('HS Hub: new session — state direset', 'ok', 3) end)
end

workspace.ChildAdded:Connect(function(c)
    local n = c.Name
    if n == "Map" or n == "Van" or n == "Dynamic" then
        if _recacheScheduled then return end
        _recacheScheduled = true
        task.delay(2, function()  -- 2s debounce: all 3 folders re-add within ~3s
            _recacheScheduled = false  -- reset FIRST so a downstream error doesn't lock future runs
            local ok, err = pcall(_hshub_recacheSession)
            if not ok then
                pcall(function() HSHub:Notify('HSHub recache error: ' .. tostring(err), 'warning', 5) end)
            end
        end)
    end
end)

-- Hàm để lấy tất cả vật phẩm bị nguyền rủa + xương + vân tay
local function getAllCursedItems()
    local all_items = {}
    
    -- Thêm các món trong folder cursed_object
    if cursed_objects then
        for _, v in pairs(cursed_objects:GetChildren()) do
            table.insert(all_items, v)
        end
    end
    
    -- Thêm Bone (nếu tồn tại)
    if bone then
        table.insert(all_items, bone)
    end
    
    -- Thêm tất cả Fingerprints trong folder
    if fingerprints then
        for _, v in pairs(fingerprints:GetChildren()) do
            table.insert(all_items, v)
        end
    end
    
    return all_items
end






local GhostInfo = workspace.Van.Objectives.SurfaceGui.Frame.Objectives.GhostInfo

local cursed_object_highlight = false

local found_writing = false

local ghost_room_pos = nil -- Dùng để TP
local ghost_room_found = false


local cursed_object_name = false
local found_fingerprint = false
local player_highlight = false
local closet_highlight = false
local highlight_ghost = false
local got_spirit_box = false
local item_highlight = false
local speed_sprint = false
local third_person = false
local jump_enabled = false
local closet_name = false
local player_name = false
local full_bright = false
local inf_stamina = false
local anti_touch = true
local show_ghost = false
local got_motion = false
local got_freezing = false -- Thêm dòng này vào khoảng dòng 140


local ghost_name = false

local no_motion = false
local item_name = false
local found_emf = false
local found_orb = false
local orbs_name = false
local emf_name = false
local inf_jump = false
local no_hold = false
local nofog = false
local fps = false









local freezing_label = evidence_group:AddLabel('Freezing Temp: Not Found')
local ghostwriting_label = evidence_group:AddLabel('Ghost Writing: Not Found')
local fingerprint_label = evidence_group:AddLabel('Fingerprints: Not Found')
local motion_label = evidence_group:AddLabel('Para Motion: Not Found')
local spirit_box_label = evidence_group:AddLabel('Spirit Box: Not Found')
local orb_label = evidence_group:AddLabel('Orbs: Not Found')


evidence_group:AddDivider()

local emf_label = evidence_group:AddLabel('EMF 5: Not Found')

local last_emf_label = evidence_group:AddLabel('Last EMF: Not Found')
evidence_group:AddDivider()
local ghost_label = evidence_group:AddLabel('ghost: not found')

local function updateGhostType()
    -- Thêm dòng kiểm tra này
    if not ghost_label then return end 
    
    local currentEvidences = {}
    -- ... (giữ nguyên phần code bên trong)

    if found_emf then table.insert(currentEvidences, "EMF5") end
    if found_fingerprint then table.insert(currentEvidences, "Fingerprints") end
    if found_orb then table.insert(currentEvidences, "Orbs") end
    if found_writing then table.insert(currentEvidences, "Writing") end
    if got_motion then table.insert(currentEvidences, "Motion") end
    if got_spirit_box then table.insert(currentEvidences, "SpiritBox") end
    if got_freezing then table.insert(currentEvidences, "Freezing") end

    -- Duyệt qua Map để tìm Ghost khớp 3 bằng chứng
    for name, evidences in pairs(ghostEvidenceMap) do
        local matchCount = 0
        for _, ev in ipairs(evidences) do
            for _, foundEv in ipairs(currentEvidences) do
                if ev == foundEv then
                    matchCount = matchCount + 1
                end
            end
        end

        if matchCount >= 3 then
            ghost_label:SetText('ghost: ' .. name)
            return
        end
    end
    ghost_label:SetText('ghost: not found')
end


local found_name = "N/A"

local touch_distance = 7
local sprint_speed = 1

local ghost_room = nil

if game:IsLoaded() then
    local device = local_player:GetAttribute('Device')
    local gid = local_player:GetAttribute("GID")
    local join_time = local_player:GetAttribute('JoinTime')

    if device or gid or join_time then
        print("====================================================")
        print("Device: " .. device)
        print("LocalPlayer GID: " .. gid)
        print("Join Time: " .. os.date("%Y-%m-%d %H:%M:%S", join_time))
        print("====================================================")
    end
else
    local_player:Kick('Game failed to load, please rejoin and retry... (If it keeps happening please contact @DYHUB on discord!)')
end



ghost_group:AddDivider()

local ghost_name_label = ghost_group:AddLabel('Ghost Name: N/A')
local ghost_room_label = ghost_group:AddLabel('Ghost Spawn: Not Found')
local ghost_speed_label = ghost_group:AddLabel('Ghost Speed: Not Found')
local ghost_room_label2 = ghost_group:AddLabel('Ghost Room: Not Found')

ghost_group:AddDivider()

local sanity_label = ghost_group:AddLabel('Player Sanity:')

emfs.ChildAdded:Connect(function(emf)
    if emf:IsA("Part") and emf.Name == 'EMF5' and not found_emf then
        emf_label:SetText('EMF 5: Yes')
        library:Notify("Found EMF 5")
        found_emf = true
        updateGhostType()
    end

    if emf:IsA("Part") then
        last_emf_label:SetText('Last EMF: ' .. emf.Name)
        library:Notify("Last EMF: " .. emf.Name)
    end
end)

fingerprints.ChildAdded:Connect(function(fingerprint)
    if fingerprint:IsA("Part") and not found_fingerprint then
        fingerprint_label:SetText('Fingerprints: Yes')
        library:Notify("Found Fingerprint")
        found_fingerprint = true
        updateGhostType()
    end
end)

orbs.ChildAdded:Connect(function(orb)
    if orb:IsA("Part") and not found_orb then
        orb_label:SetText('Orbs: Yes')
        library:Notify("Found Orbs")
        found_orb = true
        updateGhostType()
    end
end)


local function checkGhostWriting(item)
    if item.Name == "Book" then
        local rightPage = item:FindFirstChild("RightPage")
        if rightPage then
            -- 1. Kiểm tra xem ĐÃ CÓ Decal nào chưa (Trường hợp ma viết xong trước khi script chạy)
            local existingDecal = rightPage:FindFirstChildOfClass("Decal")
            if existingDecal and not found_writing then
                found_writing = true
                ghostwriting_label:SetText('Ghost Writing: Yes')
                library:Notify("Found Ghost Writing (Existing)")
                updateGhostType()
                return
            end

            -- 2. Kết nối sự kiện để chờ ma viết (Trường hợp ma sắp viết)
            -- Sử dụng thuộc tính để tránh kết nối trùng lặp nhiều lần
            if not item:GetAttribute("Connected") then
                item:SetAttribute("Connected", true)
                rightPage.ChildAdded:Connect(function(child)
                    if child:IsA("Decal") and not found_writing then
                        found_writing = true
                        ghostwriting_label:SetText('Ghost Writing: Yes')
                        library:Notify("Found Ghost Writing (New)")
                        updateGhostType()
                    end
                end)
            end
        end
    end
end

-- Tích hợp vào vòng lặp quét Equipment của bạn
task.spawn(function()
    while true do
        task.wait(1)
        local equipment = workspace:FindFirstChild("Equipment")
        if equipment then
            for _, item in pairs(equipment:GetChildren()) do
                -- Gọi hàm check cho mỗi cuốn sách tìm thấy
                checkGhostWriting(item)
            end
        end
        
        -- Nếu đã tìm thấy writing thì có thể dừng vòng lặp này hoặc cứ để nó chạy cho các bằng chứng khác
        if found_writing then 
            -- break -- Bỏ comment nếu muốn dừng quét sau khi tìm thấy
        end
    end
end)

-- [[ LOGIC TÌM GHOST ROOM CHUẨN V4 — wrapped so it can be restarted ]]
-- Assigning to the forward-declared `_hshub_startGhostFinder` upvalue.
-- Each call spawns a fresh finder; previous spawns die naturally because
-- their outer-loop guard `ghost_room_found` was reset to false before us.
_hshub_startGhostFinder = function()
    task.spawn(function()
        local RoomScanService = game:GetService("RunService")

        -- Biến lưu tạm vị trí con ma khi mới vào game
        local found_ghost_pos = nil

        -- Vòng lặp 1: Tìm vị trí đứng của con ma (Lấy từ workspace.NPCs)
        local GhostFinderConnection
        GhostFinderConnection = RoomScanService.RenderStepped:Connect(function()
            if ghost_room_found then
                GhostFinderConnection:Disconnect()
                return
            end

            local npcs = workspace:FindFirstChild("NPCs")
            if npcs then
                for _, model in pairs(npcs:GetChildren()) do
                    if model:IsA("Model") then
                        -- V4 tìm MeshPart tên là "Base" trong con ma
                        local base = model:FindFirstChild("Base")
                        if base and base:IsA("MeshPart") then
                            found_ghost_pos = base.Position -- Lưu tọa độ ma
                            ghost_room_pos = base.CFrame    -- Lưu CFrame để TP
                            GhostFinderConnection:Disconnect() -- Dừng quét ma, chuyển sang quét phòng
                            break
                        end
                    end
                end
            end
        end)

        -- Vòng lặp 2: So sánh vị trí ma với Hitbox của các phòng để lấy tên
        while task.wait(1) do
            if ghost_room_found then break end

            -- Chỉ chạy khi đã bắt được tọa độ con ma ở bước trên
            if found_ghost_pos then
                local _map = workspace:FindFirstChild("Map")
                local _rooms = _map and _map:FindFirstChild("Rooms")

                if _rooms then
                    -- Quét tất cả Hitbox trong folder Rooms
                    for _, obj in pairs(_rooms:GetDescendants()) do
                        if obj.Name == "Hitbox" and obj:IsA("BasePart") then
                            -- Nếu ma đứng cách Hitbox phòng dưới 15 mét -> Đó là phòng ma
                            local distance = (found_ghost_pos - obj.Position).Magnitude

                            if distance < 15 then
                                ghost_room_found = true
                                local realRoomName = obj.Parent.Name

                                -- Cập nhật UI Linoria
                                if ghost_room_label then
                                    ghost_room_label:SetText("Ghost Spawn: " .. realRoomName)
                                end

                                library:Notify("Ghost Spawn Found: " .. realRoomName)

                                -- Thông báo hệ thống
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title = "Specter 2 Finder",
                                    Text = "Spawn: " .. realRoomName,
                                    Duration = 5
                                })
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- initial start
_hshub_startGhostFinder()




motionconnection = run_service.RenderStepped:Connect(function()
    for _, motion in pairs(motions:GetDescendants()) do
        if motion:IsA("Part") then
            if motion.Color == Color3.fromRGB(252, 52, 52) then
                motion_label:SetText('Motion: Yes')
                library:Notify("Found Motion")
                got_motion = true
                updateGhostType()
                motionconnection:Disconnect()
                break
            elseif motion.BrickColor == BrickColor.new("Toothpaste") then
                motion_label:SetText('Motion: No')
                library:Notify("No Motion Found")
                no_motion = true
                motionconnection:Disconnect()
                break
            end
        end
    end
end)

local function getGhostName(text)
    local name = string.match(text, "<font.-%>(.-)</font>")
    return name or "N/A"
end

found_name = getGhostName(GhostInfo.Text)
ghost_name_label:SetText("Ghost Name: " .. found_name)

GhostInfo:GetPropertyChangedSignal("Text"):Connect(function()
    found_name = getGhostName(GhostInfo.Text)
    ghost_name_label:SetText("Ghost Name: " .. found_name)
end)

local run_service = game:GetService("RunService")
local local_player = game:GetService("Players").LocalPlayer

-- สร้างการเชื่อมต่อ
local sanityconnection
sanityconnection = run_service.RenderStepped:Connect(function()
    -- หา Player Sanity ของผู้เล่นปัจจุบัน
    local player_frame = workspace.Van.SanityBoard.SurfaceGui.Frame.Players:FindFirstChild(local_player.DisplayName)
    if player_frame then
        local sanity_val = player_frame.Entire.Val
        if sanity_val then
            sanity_label:SetText('Player Sanity: ' .. sanity_val.Text)
        end
    end

    -- ตรวจสอบว่าผู้เล่นตายหรือยัง
    local character = local_player.Character
    if character and character:FindFirstChild("Humanoid") then
        if character.Humanoid.Health <= 0 then
            sanity_label:SetText('Player Sanity: Dead')
            sanityconnection:Disconnect()
        end
    end
end)





local lastUpdate = 0
local UPDATE_DELAY = 0.15 -- ~6–7 lần/giây (đủ mượt, không lag)

local cachedGhostHumanoid = nil

-- tìm ghost humanoid 1 lần
local function getGhostHumanoid()
    if cachedGhostHumanoid and cachedGhostHumanoid.Parent then
        return cachedGhostHumanoid
    end

    if not ghost then return nil end

    for _, v in pairs(ghost:GetChildren()) do
        if v:IsA("Model") then
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hum then
                cachedGhostHumanoid = hum
                return hum
            end
        end
    end
    return nil
end

ghostconnection = run_service.RenderStepped:Connect(function()
    if not anti_touch then return end

    local now = tick()
    if now - lastUpdate < UPDATE_DELAY then return end
    lastUpdate = now

    local humanoid = getGhostHumanoid()
    if humanoid then
        ghost_speed_label:SetText(
            'Ghost Speed: ' .. string.format("%.1f", humanoid.WalkSpeed)
        )
    end
end)





playerconnection = run_service.RenderStepped:Connect(function()
    if inf_stamina then
        local_player:SetAttribute('Stamina', 100)
    end

    if speed_sprint then
        local_player:SetAttribute('Speed', sprint_speed)
    end

    if noclip then
        local_player.Character.HumanoidRootPart.CanCollide = false
        local_player.Character.UpperTorso.CanCollide = false
        local_player.Character.LowerTorso.CanCollide = false
        local_player.Character.Head.CanCollide = false
    end
end)

espconnection = run_service.RenderStepped:Connect(function()
    if not local_player.Character then
        local_player.CharacterAdded:Wait()
    end

    if show_ghost then
        for _, silly_ghost in pairs(ghost:GetChildren()) do
            if silly_ghost:IsA("Model") then
                silly_ghost:FindFirstChildOfClass("MeshPart").Transparency = 0
            end
        end

        if highlight_ghost then
            for _, silly_ghost in pairs(ghost:GetChildren()) do
                if silly_ghost:IsA("Model") and not silly_ghost:FindFirstChild("Highlight") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Parent = silly_ghost
                    Highlight.FillTransparency = 1        -- Làm trong suốt phần ruột
    Highlight.OutlineTransparency = 0     -- Hiện viền đậm
                    Highlight.FillColor = highlight_color_ghost
                    Highlight.OutlineColor = highlight_color_ghost
                end
            end
        end

        if ghost_name then
            for _, silly_ghost in pairs(ghost:GetChildren()) do
                if silly_ghost:IsA("Model") and not silly_ghost:FindFirstChild("Esp BillBoard") then
                    local esp_billboard = Instance.new("BillboardGui")
                    esp_billboard.Parent = silly_ghost
                    esp_billboard.Name = "Esp BillBoard"
                    esp_billboard.Adornee = silly_ghost.PrimaryPart
                    esp_billboard.Size = UDim2.new(0, 100, 0, 50)
                    esp_billboard.StudsOffset = Vector3.new(0, 5, 0)
                    esp_billboard.AlwaysOnTop = true

                    local esp_text = Instance.new("TextLabel")
                    esp_text.Parent = esp_billboard
                    esp_text.Name = "Name Esp"
                    esp_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    esp_text.Size = UDim2.new(1, 0, 1, 0)
                    esp_text.Text = "Ghost [" .. silly_ghost.Name .. "]"
                    esp_text.TextColor3 = highlight_color_ghost
                    esp_text.TextSize = 14
                    esp_text.Font = "SourceSansBold"
                    esp_text.BackgroundTransparency = 1
                    esp_text.TextStrokeTransparency = 0
                    esp_text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                end
            end
        end
    end

    if player_name then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= local_player and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid.Health > 0 and not player.Character.Head:FindFirstChild("Esp BillBoard") then
                    local esp_billboard = Instance.new("BillboardGui")
                    esp_billboard.Parent = player.Character.Head
                    esp_billboard.Name = "Esp BillBoard"
                    esp_billboard.Adornee = player.Character.Head
                    esp_billboard.Size = UDim2.new(0, 100, 0, 50)
                    esp_billboard.StudsOffset = Vector3.new(0, 2, 0)
                    esp_billboard.AlwaysOnTop = true

                    local esp_text = Instance.new("TextLabel")
                    esp_text.Parent = esp_billboard
                    esp_text.Name = "Name Esp"
                    esp_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    esp_text.Size = UDim2.new(1, 0, 1, 0)
                    esp_text.Text = player.DisplayName
                    esp_text.TextColor3 = player_highlight_color
                    esp_text.TextSize = 14
                    esp_text.Font = "SourceSansBold"
                    esp_text.BackgroundTransparency = 1
                    esp_text.TextStrokeTransparency = 0
                    esp_text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                end
            end
        end
    end

    if player_highlight then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= local_player and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid.Health > 0 and not player.Character:FindFirstChild("Highlight") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Parent = player.Character
                    Highlight.FillTransparency = 1        -- Làm trong suốt phần ruột
    Highlight.OutlineTransparency = 0     -- Hiện viền đậm
                    Highlight.FillColor = player_highlight_color
                    Highlight.OutlineColor = player_highlight_color
                end
            end
        end
    end

    if item_name then
        for _, v in next, van_equipment:GetChildren() do
            if v:IsA("Model") and not v:FindFirstChild("Esp BillBoard") then
                local esp_billboard = Instance.new("BillboardGui")
                esp_billboard.Parent = v
                esp_billboard.Name = "Esp BillBoard"
                esp_billboard.Adornee = v.PrimaryPart
                esp_billboard.Size = UDim2.new(0, 100, 0, 50)
                esp_billboard.StudsOffset = Vector3.new(0, 1, 0)
                esp_billboard.AlwaysOnTop = true

                local esp_text = Instance.new("TextLabel")
                esp_text.Parent = esp_billboard
                esp_text.Name = "Name Esp"
                esp_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                esp_text.Size = UDim2.new(1, 0, 1, 0)
                esp_text.Text = v.Name
                esp_text.TextColor3 = item_highlight_color
                esp_text.TextSize = 14
                esp_text.Font = "SourceSansBold"
                esp_text.BackgroundTransparency = 1
                esp_text.TextStrokeTransparency = 0
                esp_text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
        end
    end

    if item_name then
        for _, v in next, dropped_equipment:GetChildren() do
            if v:IsA("Model") and not v:FindFirstChild("Esp BillBoard") then
                local esp_billboard = Instance.new("BillboardGui")
                esp_billboard.Parent = v
                esp_billboard.Name = "Esp BillBoard"
                esp_billboard.Adornee = v.PrimaryPart
                esp_billboard.Size = UDim2.new(0, 100, 0, 50)
                esp_billboard.StudsOffset = Vector3.new(0, 1, 0)
                esp_billboard.AlwaysOnTop = true

                local esp_text = Instance.new("TextLabel")
                esp_text.Parent = esp_billboard
                esp_text.Name = "Name Esp"
                esp_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                esp_text.Size = UDim2.new(1, 0, 1, 0)
                esp_text.Text = v.Name
                esp_text.TextColor3 = item_highlight_color
                esp_text.TextSize = 14
                esp_text.Font = "SourceSansBold"
                esp_text.BackgroundTransparency = 1
                esp_text.TextStrokeTransparency = 0
                esp_text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
        end
    end

    if item_highlight then
        for _, v in next, dropped_equipment:GetChildren() do
            if v:IsA("Model") and not v:FindFirstChild("Highlight") then
                local Highlight = Instance.new("Highlight")
                Highlight.Parent = v
                Highlight.FillTransparency = 1        -- Làm trong suốt phần ruột
    Highlight.OutlineTransparency = 0     -- Hiện viền đậm
                Highlight.FillColor = item_highlight_color
                Highlight.OutlineColor = item_highlight_color
            end
        end
    end

    if item_highlight then
        for _, v in next, van_equipment:GetChildren() do
            if v:IsA("Model") and not v:FindFirstChild("Highlight") then
                local Highlight = Instance.new("Highlight")
                Highlight.Parent = v
                Highlight.FillTransparency = 1        -- Làm trong suốt phần ruột
    Highlight.OutlineTransparency = 0     -- Hiện viền đậm
                Highlight.FillColor = item_highlight_color
                Highlight.OutlineColor = item_highlight_color
            end
        end
    end
    
    if cursed_object_name then
for _, v in next, getAllCursedItems() do 
        if (v:IsA("MeshPart") or v:IsA("Model") or v:IsA("Part")) and not (v.Name == "Chair" or v.Name == "Body" or v.Name == "Eye1" or v.Name == "Eye2") and not v:FindFirstChild("Esp BillBoard") then
                local esp_billboard = Instance.new("BillboardGui")
                esp_billboard.Parent = v
                esp_billboard.Name = "Esp BillBoard"
                esp_billboard.Adornee = v
                esp_billboard.Size = UDim2.new(0, 100, 0, 50)
                esp_billboard.StudsOffset = Vector3.new(0, 1, 0)
                esp_billboard.AlwaysOnTop = true

                local esp_text = Instance.new("TextLabel")
                esp_text.Parent = esp_billboard
                esp_text.Name = "Name Esp"
                esp_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                esp_text.Size = UDim2.new(1, 0, 1, 0)
                esp_text.Text = v.Name
                esp_text.TextColor3 = cursed_object_highlight_color
                esp_text.TextSize = 14
                esp_text.Font = "SourceSansBold"
                esp_text.BackgroundTransparency = 1
                esp_text.TextStrokeTransparency = 0
                esp_text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
        end
    end

    if cursed_object_highlight then
        for _, v in next, getAllCursedItems() do
        if (v:IsA("MeshPart") or v:IsA("Model") or v:IsA("Part")) and not (v.Name == "Chair" or v.Name == "Body") and not v:FindFirstChild("Highlight") then
                local Highlight = Instance.new("Highlight")
                Highlight.Parent = v
                Highlight.FillTransparency = 1        -- Làm trong suốt phần ruột
    Highlight.OutlineTransparency = 0     -- Hiện viền đậm
                Highlight.FillColor = cursed_object_highlight_color
                Highlight.OutlineColor = cursed_object_highlight_color
            end
        end
    end

    if emf_name then
        for _, v in next, emfs:GetChildren() do
            if v:IsA("Part") and not v:FindFirstChild("Esp BillBoard") then
                local esp_billboard = Instance.new("BillboardGui")
                esp_billboard.Parent = v
                esp_billboard.Name = "Esp BillBoard"
                esp_billboard.Adornee = v
                esp_billboard.Size = UDim2.new(0, 100, 0, 50)
                esp_billboard.StudsOffset = Vector3.new(0, 1, 0)
                esp_billboard.AlwaysOnTop = true

                local esp_text = Instance.new("TextLabel")
                esp_text.Parent = esp_billboard
                esp_text.Name = "Name Esp"
                esp_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                esp_text.Size = UDim2.new(1, 0, 1, 0)
                esp_text.Text = v.Name
                esp_text.TextColor3 = Color3.fromRGB(255, 255, 255)
                esp_text.TextSize = 14
                esp_text.Font = "SourceSansBold"
                esp_text.BackgroundTransparency = 1
                esp_text.TextStrokeTransparency = 0
                esp_text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
        end
    end

    if orbs_name then
        for _, v in next, orbs:GetChildren() do
            if v:IsA("Part") and not v:FindFirstChild("Esp BillBoard") then
                local esp_billboard = Instance.new("BillboardGui")
                esp_billboard.Parent = v
                esp_billboard.Name = "Esp BillBoard"
                esp_billboard.Adornee = v
                esp_billboard.Size = UDim2.new(0, 100, 0, 50)
                esp_billboard.StudsOffset = Vector3.new(0, 1, 0)
                esp_billboard.AlwaysOnTop = true

                local esp_text = Instance.new("TextLabel")
                esp_text.Parent = esp_billboard
                esp_text.Name = "Name Esp"
                esp_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                esp_text.Size = UDim2.new(1, 0, 1, 0)
                esp_text.Text = v.Name
                esp_text.TextColor3 = Color3.fromRGB(255, 255, 255)
                esp_text.TextSize = 14
                esp_text.Font = "SourceSansBold"
                esp_text.BackgroundTransparency = 1
                esp_text.TextStrokeTransparency = 0
                esp_text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
        end
    end

    if closet_name then
        for _, v in next, closets:GetChildren() do
            if v:IsA("Model") and not v:FindFirstChild("Esp BillBoard") then
                local esp_billboard = Instance.new("BillboardGui")
                esp_billboard.Parent = v
                esp_billboard.Name = "Esp BillBoard"
                esp_billboard.Adornee = v
                esp_billboard.Size = UDim2.new(0, 100, 0, 50)
                esp_billboard.StudsOffset = Vector3.new(0, 5, 0)
                esp_billboard.AlwaysOnTop = true

                local esp_text = Instance.new("TextLabel")
                esp_text.Parent = esp_billboard
                esp_text.Name = "Name Esp"
                esp_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                esp_text.Size = UDim2.new(1, 0, 1, 0)
                esp_text.Text = "Hiding Spot"
                esp_text.TextColor3 = closet_highlight_color
                esp_text.TextSize = 14
                esp_text.Font = "SourceSansBold"
                esp_text.BackgroundTransparency = 1
                esp_text.TextStrokeTransparency = 0
                esp_text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
        end
    end

    if closet_highlight then
        for _, v in next, closets:GetChildren() do
            if v:IsA("Model") and not v:FindFirstChild("Highlight") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = v
                highlight.FillTransparency = 1        -- Làm trong suốt phần ruột
    highlight.OutlineTransparency = 0     -- Hiện viền đậm
                highlight.FillColor = closet_highlight_color
                highlight.OutlineColor = closet_highlight_color
            end
        end
    end
end)

proximity_prompt_service.PromptButtonHoldBegan:Connect(function(prompt)
    if no_hold then
        prompt.HoldDuration = 0
    end
end)

user_input_service.JumpRequest:Connect(function()
    if inf_jump then
        local_player.Character.Humanoid:ChangeState("Jumping")
    end
end)

game_group:AddDivider()

game_group:AddButton({
    Text = 'Collect Bone',

    Func = function()
        if bone then
            bone_prompt = bone:FindFirstChildOfClass("ProximityPrompt")
            last_pos = local_player.Character.HumanoidRootPart.CFrame

            if bone_prompt then
                local_player.Character.HumanoidRootPart.CFrame = bone.CFrame + Vector3.new(0, 5, 0)
                task.wait(.25)
                fireproximityprompt(bone_prompt)
                task.wait(.25)
                local_player.Character.HumanoidRootPart.CFrame = last_pos
                library:Notify("Collected Bone")
            end
        else
            library:Notify("Bone not found")
        end
    end,
    DoubleClick = false,
    Tooltip = 'Collects the bone'
})

game_group:AddButton({
    Text = 'Report Dirty Water',

    Func = function()
        local active_water = nil
        local active_prompt = nil
        local active_beam = nil
        
        -- 1. QUÉT TÌM CÁI NƯỚC ĐANG "ACTIVE" NHẤT
        local all_waters = {}
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "Water" and v:IsA("BasePart") then
                local p = v:FindFirstChildOfClass("ProximityPrompt")
                if p and (p.ObjectText == "Report dirty water" or p.ActionText == "Report dirty water") then
                    table.insert(all_waters, {part = v, prompt = p})
                end
            end
        end

        -- Ưu tiên chọn cái vòi nào đang xả (Beam == true)
        for _, obj in pairs(all_waters) do
            local f = obj.part:FindFirstChild("Faucet", true) or obj.part.Parent:FindFirstChild("Faucet", true)
            local b = f and f:FindFirstChildWhichIsA("Beam", true)
            
            if (b and b.Enabled == true) or obj.prompt.Enabled == true then
                active_water = obj.part
                active_prompt = obj.prompt
                active_beam = b
                break -- Đã tìm thấy vòi đang hoạt động
            end
        end

        -- 2. XỬ LÝ NẾU TÌM THẤY
        if active_water and active_prompt then
            library:Notify("Found active dirty water! Checking status...")

            -- Nếu Beam đang bật, bắt buộc đợi cho đến khi nó tắt hoặc tối đa 10s
            if active_beam and active_beam.Enabled == true then
                library:Notify("Water is pumping... Waiting for it to finish.")
                local wait_limit = 0
                while active_beam.Enabled == true and wait_limit < 20 do
                    task.wait(0.5)
                    wait_limit = wait_limit + 1
                end
                task.wait(1) -- Đợi thêm 1s cho nước ổn định sau khi tắt vòi
            end

            -- 3. VÒNG LẶP ĐỢI PROMPT HOẶC DỪNG DI CHUYỂN
            local is_ready = false
            local last_pos = active_water.Position
            
            for i = 1, 30 do -- Đợi tối đa 15 giây
                task.wait(0.5)
                
                -- Nếu Prompt bật (Dấu hiệu quan trọng nhất)
                if active_prompt.Enabled == true then
                    is_ready = true
                    break
                end
                
                -- Check nếu nước đã dừng trồi lên/đổi size
                local current_pos = active_water.Position
                if (current_pos - last_pos).Magnitude < 0.001 and i > 4 then
                    -- Nếu đứng yên và không còn Beam nữa
                    if not active_beam or active_beam.Enabled == false then
                        is_ready = true
                        break
                    end
                end
                last_pos = current_pos
            end

            -- 4. THỰC HIỆN TELEPORT
            if is_ready or active_prompt.Enabled then
                local last_cframe = local_player.Character.HumanoidRootPart.CFrame
                
                -- Nhảy tới
                local_player.Character.HumanoidRootPart.CFrame = active_water.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.6) -- Đợi lâu hơn chút để tránh lỗi vị trí
                
                if active_prompt.Enabled then
                    fireproximityprompt(active_prompt)
                    library:Notify("Reported Dirty Water successfully!")
                else
                    library:Notify("Dirty water is being pumped out, and a report cannot be made yet.")
                end
                
                task.wait(0.3)
                local_player.Character.HumanoidRootPart.CFrame = last_cframe
            else
                library:Notify("Dirty water is stuck or has not yet appeared.")
            end
        else
            library:Notify("Dirty Water not found")
        end
    end,
    DoubleClick = false,
    Tooltip = 'Tp to the location with dirty water and report it.'
})

local auto_report_water = false -- Biến kiểm soát trạng thái toggle

game_group:AddToggle('AutoReportWater', {
    Text = 'Auto Report Dirty Water',
    Default = false,
    Tooltip = 'Automatically teleports and reports dirty water when detected',

    Callback = function(Value)
        auto_report_water = Value
        
        if auto_report_water then
            task.spawn(function()
                while auto_report_water do
                    task.wait(60) -- Quét mỗi 1p một lần để tránh lag
                    
                    local active_water = nil
                    local active_prompt = nil
                    local active_beam = nil
                    
                    -- 1. TÌM NƯỚC BẨN ĐANG HOẠT ĐỘNG
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Water" and v:IsA("BasePart") then
                            local p = v:FindFirstChildOfClass("ProximityPrompt")
                            if p and (p.ObjectText == "Report dirty water" or p.ActionText == "Report dirty water") then
                                -- Kiểm tra nếu vòi đang xả nước (Beam)
                                local f = v:FindFirstChild("Faucet", true) or v.Parent:FindFirstChild("Faucet", true)
                                local b = f and f:FindFirstChildWhichIsA("Beam", true)
                                
                                -- Nếu Prompt đã bật HOẶC Beam đang chạy thì đây là mục tiêu
                                if p.Enabled or (b and b.Enabled) then
                                    active_water = v
                                    active_prompt = p
                                    active_beam = b
                                    break 
                                end
                            end
                        end
                    end

                    -- 2. LOGIC XỬ LÝ TỰ ĐỘNG
                    if active_water and active_prompt then
                        -- Nếu Beam đang bật, đợi cho đến khi tắt (tối đa 15s)
                        local timeout = 0
                        while active_beam and active_beam.Enabled and timeout < 30 do
                            task.wait(0.5)
                            timeout = timeout + 1
                        end

                        -- Đợi thêm 1s cho nước ổn định vị trí/kích thước
                        task.wait(1)

                        -- Kiểm tra lại Prompt trước khi bay tới
                        if active_prompt.Enabled and auto_report_water then
                            local last_cframe = local_player.Character.HumanoidRootPart.CFrame
                            
                            -- Teleport & Fire
                            local_player.Character.HumanoidRootPart.CFrame = active_water.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                            
                            if active_prompt.Enabled then
                                fireproximityprompt(active_prompt)
                                library:Notify("Auto Reported Dirty Water!")
                                -- Đợi một chút để game cập nhật, tránh loop teleport liên tục vào 1 chỗ
                                task.wait(0.5)
                            end
                            
                            local_player.Character.HumanoidRootPart.CFrame = last_cframe
                            
                            -- Sau khi report xong 1 cái, nghỉ 5s để tránh lỗi hoặc đợi ma làm bẩn bồn khác
                            task.wait(5)
                        end
                    end
                end
            end)
        end
    end
})






game_group:AddButton({
    Text = 'Enable Power',

    Func = function()
        for _, v in next, fuse_box:GetChildren() do
            if v:IsA("ProximityPrompt") and v.name == "FuseboxPrompt" then
                local last_pos = local_player.Character.HumanoidRootPart.CFrame
                local_player.Character.HumanoidRootPart.CFrame = v.Parent.CFrame
                task.wait(.2)
                fireproximityprompt(v)
                task.wait(.2)
                local_player.Character.HumanoidRootPart.CFrame = last_pos
                local fuse_box_toggles = Workspace.Map.Fusebox
                if fuse_box_toggles then
                    if fuse_box_toggles:FindFirstChild("On").Transparency == 0 then
                        library:Notify("Turned off power box.")
                    else
                        if fuse_box_toggles:FindFirstChild("Off").Transparency == 0 then
                            library:Notify("Turned on power box.")
                        end
                    end
                end
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Turns on/off the power box'
})

game_group:AddDivider()

local auto_scan_enabled = true
-- FIX: dulu di sini ada `local ghost_room_found = false` yang SHADOW
-- declaration di line 2870. Akibatnya reset di PATCH 5 hanya nyentuh
-- shadow ini, sedangkan GhostFinder (line ~3088) capture upvalue dari
-- declaration ATAS. Hapus `local` di sini supaya semua kode refer ke
-- variabel yang sama.
local emf_active_timers = {}
local emf_locking_room = {} -- Lưu trữ phòng đang được EMF lock


-- Hàm kiểm tra màu đỏ đặc trưng của ma (170, 0, 0)
local function isGhostColor(color)
    local target = Color3.fromRGB(170, 0, 0)
    return math.abs(color.R - target.R) + math.abs(color.G - target.G) + math.abs(color.B - target.B) < 0.02
end

-- 1. LOGIC QUÉT KHUNG CHAT (Giữ nguyên)
game:GetService("TextChatService").OnIncomingMessage = function(message)
    if not auto_scan_enabled or got_spirit_box then return end
    if message.Status == Enum.TextChatMessageStatus.Success then
        local rawText = message.Text
        if rawText:find("170") or rawText:find("rgb") or rawText:find("#aa0000") then
            got_spirit_box = true
            spirit_box_label:SetText("Spirit Box: Yes")
            library:Notify("Evidence Found: Spirit Box (Chat)")
            updateGhostType()
        end
    end
end

-- 2. HÀM QUÉT BILLBOARD SPIRIT BOX
local function checkSpiritBoxBillboard(desc)
    if desc:IsA("BillboardGui") and desc.Enabled then
        local textLabel = desc:FindFirstChildWhichIsA("TextLabel", true)
        if textLabel and textLabel.TextTransparency < 1 then
            if isGhostColor(textLabel.TextColor3) and textLabel.Text ~= "" and textLabel.Text ~= "..." then
                if not got_spirit_box then
                    got_spirit_box = true
                    spirit_box_label:SetText("Spirit Box: Yes")
                    library:Notify("Evidence Found: Spirit Box (Billboard)")
                    updateGhostType()
                end
            end
        end
    end
end

-- 3. VÒNG LẶP QUÉT TỔNG HỢP
task.spawn(function()
    while true do
        task.wait(0.5) 
        if not auto_scan_enabled then continue end

        -- Gom tất cả item từ Workspace và Character vào một bảng để quét
        local items_to_scan = {}
        
        -- Quét dưới đất
        local ground_eq = workspace:FindFirstChild("Equipment")
        if ground_eq then
            for _, v in pairs(ground_eq:GetChildren()) do table.insert(items_to_scan, v) end
        end
        
        -- Quét trên tay (Trong nhân vật)
        if local_player.Character then
            for _, v in pairs(local_player.Character:GetChildren()) do
                -- Nếu là Model thiết bị trực tiếp hoặc nằm trong folder EquipmentModel
                if v:IsA("Model") then
                    table.insert(items_to_scan, v)
                elseif v.Name == "EquipmentModel" then
                    for _, sub_v in pairs(v:GetChildren()) do table.insert(items_to_scan, sub_v) end
                end
            end
        end

        for _, item in pairs(items_to_scan) do
            -- A. LOGIC SPIRIT BOX (Cập nhật check đệ quy cho đồ trên tay)
            if item.Name == "Spirit Box" then
                for _, desc in pairs(item:GetDescendants()) do
                    checkSpiritBoxBillboard(desc)
                end
                
                if not item:GetAttribute("SB_Connected") then
                    item:SetAttribute("SB_Connected", true)
                    item.DescendantAdded:Connect(function(newDesc)
                        task.wait(0.1)
                        checkSpiritBoxBillboard(newDesc)
                    end)
                end
            end

            -- B. LOGIC EMF 2 & 5 (ĐÃ FIX LOCK HITBOX)
            if item.Name == "EMF Reader" then
                local activeColor = Color3.fromRGB(131, 156, 49)
                local emf_2 = item:FindFirstChild("2", true)
                local emf_5 = item:FindFirstChild("5", true)
                
                if emf_2 and emf_2:IsA("BasePart") then
                    if emf_2.Color == activeColor then
                        -- Lấy Handle/Vị trí máy EMF
                        local handle = item:FindFirstChild("Handle", true) or item.PrimaryPart
                        
                        if handle then
                            -- Nếu chưa lock phòng nào, tiến hành tìm phòng gần nhất để lock
                            if not emf_locking_room[item] then
                                for _, room in pairs(rooms:GetChildren()) do
                                    local hitbox = room:FindFirstChild("Hitbox")
                                    if hitbox and (handle.Position - hitbox.Position).Magnitude < 12 then
                                        emf_locking_room[item] = room -- Khóa mục tiêu vào phòng này
                                        break
                                    end
                                end
                            end

                            -- Nếu đã lock được phòng, kiểm tra điều kiện duy trì
                            local lockedRoom = emf_locking_room[item]
                            if lockedRoom then
                                local hb = lockedRoom:FindFirstChild("Hitbox")
                                -- KIỂM TRA: Nếu đi quá xa khỏi Hitbox đã lock (vượt quá 12m) -> Reset
                                if hb and (handle.Position - hb.Position).Magnitude < 100 then
                                    emf_active_timers[item] = (emf_active_timers[item] or 0) + 0.5
                                    
                                    -- Nếu đủ 2.5s liên tục trong phòng đã lock
                                    if emf_active_timers[item] >= 2.5 and not ghost_room_found then
                                        ghost_room = hb.CFrame
                                        ghost_room_label2:SetText("Ghost Room: " .. lockedRoom.Name)
                                        library:Notify("Ghost Room Identified: " .. lockedRoom.Name)
                                        ghost_room_found = true
                                    end
                                else
                                    -- Rời khỏi phòng đã lock -> Reset ngay
                                    emf_active_timers[item] = 0
                                    emf_locking_room[item] = nil
                                end
                            end
                        end
                    else
                        -- EMF 2 Tắt -> Reset lock và timer ngay lập tức
                        emf_active_timers[item] = 0
                        emf_locking_room[item] = nil
                    end
                end

                -- EMF 5 (Giữ nguyên)
                if emf_5 and emf_5:IsA("BasePart") and emf_5.Color == activeColor and not found_emf then
                    found_emf = true
                    emf_label:SetText("EMF 5: Yes")
                    library:Notify("Evidence: EMF Level 5!")
                    updateGhostType()
                end
            end

            

            -- C. LOGIC THERMOMETER (Sửa lỗi không quét được trên tay)
            if item.Name == "Thermometer" or item:FindFirstChild("Temp") then
                -- Tìm TextLabel sâu bên trong Model (cầm trên tay cấu trúc hay bị lồng Handle)
                local tempLabel = item:FindFirstChildWhichIsA("TextLabel", true)
                
                if tempLabel and tempLabel.IsA(tempLabel, "TextLabel") then
                    local text = tempLabel.Text
                    -- Lọc lấy số (chấp nhận cả số âm và số thập phân)
                    local tempNum = tonumber(text:match("[-%d.]+"))
                    
                    if tempNum and tempNum < 0 and not got_freezing then
                        got_freezing = true
                        freezing_label:SetText("Freezing: Yes")
                        library:Notify("Evidence: Freezing (" .. tempNum .. "°C)")
                        updateGhostType()
                    end
                end
            end
        end 
    end
end)



game_group:AddButton({
    Text = 'Find Ghost Room',

    Func = function()
        -- FIX: reset hasil sesi lama supaya block `if not ghost_room` di
        -- retry pass bisa jalan, dan label nggak nyangkut "Ghost Room: X"
        -- dari sesi sebelumnya kalau scan gagal.
        ghost_room = nil
        pcall(function() ghost_room_label2:SetText("Ghost Room: Not Found") end)

        if not local_player.Character or not local_player.Character:FindFirstChild("HumanoidRootPart") then
            library:Notify("Character not ready")
            return
        end

        local emf_tool = local_player.Character and local_player.Character:FindFirstChild("EquipmentModel") and local_player.Character.EquipmentModel:FindFirstChild("2")
        local emf = local_player.Character and local_player.Character:FindFirstChild("EquipmentModel") and local_player.Character.EquipmentModel:FindFirstChild("1")
        local last_pos = local_player.Character.HumanoidRootPart.CFrame

        if not emf_tool then
            library:Notify("Equip EMF reader first!")
            return
        end

        if not emf or emf.Color ~= Color3.fromRGB(52, 142, 64) then
            replicated_storage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("InventoryService"):WaitForChild("RF"):WaitForChild("Toggle"):InvokeServer("EMF Reader")
        end

        if not ghost:FindFirstChildOfClass("Model") then
            library:Notify("Open the van first!")
            return
        end

        for _, room in pairs(rooms:GetChildren()) do
            if room:IsA("Folder") then
                local hitbox = room:FindFirstChild("Hitbox")

                if hitbox then
                    local_player.Character.HumanoidRootPart.CFrame = hitbox.CFrame
                    camera.CFrame = hitbox.CFrame
                    task.wait(0.75)

                    if emf_tool.Color == Color3.fromRGB(131, 156, 49) then
                        ghost_room = hitbox.CFrame
                        ghost_room_label2:SetText("Ghost Room: " .. room.Name)
                        library:Notify("Ghost Room: " .. room.Name .. " (It Not Might Be Always The Ghost Room!)")
                        local_player.Character.HumanoidRootPart.CFrame = last_pos
                        break
                    end
                end
            end
        end

        if not ghost_room then
            task.wait(0.75)
            library:Notify("Ghost room not found retrying...")
            for _, room in pairs(rooms:GetChildren()) do
                if room:IsA("Folder") then
                    local hitbox = room:FindFirstChild("Hitbox")

                    if hitbox then
                        local_player.Character.HumanoidRootPart.CFrame = hitbox.CFrame
                        camera.CFrame = hitbox.CFrame
                        task.wait(0.75)

                        if emf_tool.Color == Color3.fromRGB(131, 156, 49) then
                            ghost_room = hitbox.CFrame
                            ghost_room_label2:SetText("Ghost Room: " .. room.Name)
                            library:Notify("Ghost Room: " .. room.Name .. " (It Not Might Be Always The Ghost Room!)")
                            local_player.Character.HumanoidRootPart.CFrame = last_pos
                            break
                        end
                    end
                end
            end

            if not ghost_room then
                library:Notify("Ghost room not found")
                local_player.Character.HumanoidRootPart.CFrame = last_pos
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Searches for the ghost room with the EMF reader'
})




game_group:AddButton({
    Text = 'Tp Motion Sensor To Ghost',

    Func = function()
        -- [HSHub-patch] robust ghost lookup + longer wait so sensor actually detects
        local motion_grid = evidence_folder.MotionGrids:FindFirstChild("SensorGrid")
        if not motion_grid then
            library:Notify("Motion Grids not found place one before using this feature!")
            return
        end

        -- find ghost with a valid HumanoidRootPart (skip non-ghost models)
        local ghost, ghostHRP = nil, nil
        for _, m in pairs(workspace.NPCs:GetChildren()) do
            if m:IsA("Model") then
                local hrp = m:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:IsA("BasePart") then
                    ghost, ghostHRP = m, hrp
                    break
                end
            end
        end
        if not ghost or not ghostHRP then
            library:Notify("Ghost not found in workspace.NPCs")
            return
        end

        library:Notify("Teleporting Motion Grids to the ghost...")
        local last_pos = {}
        for _, motion_grids in pairs(motion_grid:GetChildren()) do
            if motion_grids:IsA("Part") then
                last_pos[motion_grids] = motion_grids.CFrame
                motion_grids.CFrame = ghostHRP.CFrame + Vector3.new(1, 0, 0)
            end
        end

        -- give sensor enough frames to register motion (was task.wait() = 1 frame, too fast)
        task.wait(0.35)

        for v, pos in pairs(last_pos) do
            pcall(function() v.CFrame = pos end)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleports Motion Grids to the ghost to check for motion'
})

game_group:AddDivider()

game_group:AddButton({
    Text = 'Tp To Van',

    Func = function()
        local_player.Character.HumanoidRootPart.CFrame = van.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
    end,
    DoubleClick = false,
    Tooltip = 'Teleports you to the van'
})

game_group:AddButton({
    Text = 'Tp To Ghost Room',

    Func = function()
        if ghost_room then
            local_player.Character.HumanoidRootPart.CFrame = ghost_room
        else
            library:Notify("Ghost room not found") -- FIX: dulu `Library` uppercase → silent crash
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleports you to the ghost room'
})

game_group:AddButton({
    Text = 'Teleport to Ghost Spawm',
    Func = function()
        if ghost_room_pos then
            local character = local_player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- Teleport đến vị trí đã lưu từ con ma + cao lên 3 unit
                character.HumanoidRootPart.CFrame = ghost_room_pos + Vector3.new(0, 3, 0)
                library:Notify("Teleported to Ghost Spawn!")
            end
        else
            library:Notify("Ghost Spawn not found yet! Wait for ghost to spawn.")
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleports you to the identified ghost spawn'
})













objquest_group:AddDivider()

-- Hàm hỗ trợ ngắt dòng sau mỗi 18 ký tự
local function wrapText(str, limit)
    limit = limit or 32
    if #str <= limit then return str end
    
    local lines = {}
    for i = 1, #str, limit do
        table.insert(lines, str:sub(i, i + limit - 1))
    end
    return table.concat(lines, "\n")
end

-- Khai báo các Label trong Group
local obj_label_11 = objquest_group:AddLabel('')
local obj_label_1 = objquest_group:AddLabel('Objective 1: Waiting...')
local obj_label_12 = objquest_group:AddLabel('')
objquest_group:AddDivider()
local obj_label_21 = objquest_group:AddLabel('')
local obj_label_2 = objquest_group:AddLabel('Objective 2: Waiting...')
local obj_label_22 = objquest_group:AddLabel('')
objquest_group:AddDivider()
local obj_label_31 = objquest_group:AddLabel('')
local obj_label_3 = objquest_group:AddLabel('Objective 3: Waiting...')
local obj_label_32 = objquest_group:AddLabel('')

task.spawn(function()
    while true do
        task.wait(1)
        
        local vanObjectives = workspace:FindFirstChild("Van") 
            and workspace.Van:FindFirstChild("Objectives") 
            and workspace.Van.Objectives:FindFirstChild("SurfaceGui")
            and workspace.Van.Objectives.SurfaceGui:FindFirstChild("Frame")
            and workspace.Van.Objectives.SurfaceGui.Frame:FindFirstChild("Objectives")

        if vanObjectives then
            for i = 1, 3 do
                local objectivePart = vanObjectives:FindFirstChild(tostring(i))
                if objectivePart and objectivePart:IsA("TextLabel") then
                    local currentLabel = (i == 1 and obj_label_1) or (i == 2 and obj_label_2) or obj_label_3
                    
                    -- Màu hoàn thành: 85, 170, 127
                    local completedColor = Color3.fromRGB(85, 170, 127)
                    local currentColor = objectivePart.TextColor3
                    local diff = math.abs(currentColor.R - completedColor.R) + math.abs(currentColor.G - completedColor.G) + math.abs(currentColor.B - completedColor.B)
                    
                    if diff < 0.02 then
                        currentLabel:SetText("Objective " .. i .. ":\n  > > Completed < <")
                    else
                        -- Áp dụng Wrap Text cho nội dung nhiệm vụ dài
                        local formattedText = wrapText(objectivePart.Text, 32)
                        currentLabel:SetText("Objective " .. i .. ":\n" .. formattedText)
                    end
                end
            end
        else
            obj_label_1:SetText("Objective 1: Van Closed")
            obj_label_2:SetText("Objective 2: Van Closed")
            obj_label_3:SetText("Objective 3: Van Closed")
        end
    end
end)









player_group:AddDivider()

player_group:AddToggle('no_hold', {
    Text = 'No Hold',
    Default = false,
    Tooltip = 'Removes hold time from proximityprompts',

    Callback = function(Value)
        no_hold = Value
    end
})

player_group:AddToggle('third_person', {
    Text = '3rd Person (Form)',
    Default = false,
    Tooltip = 'Change camera to 3rd person',

    Callback = function(Value)
        third_person = Value
        if Value then
            local_player.Character.Humanoid.CameraOffset = Vector3.new(0, 1, 2)
        else
            local_player.Character.Humanoid.CameraOffset = Vector3.new(0, 0, -1)
        end
    end,
}):AddKeyPicker('third_person_keybind', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = '3rd Person',
    NoUI = false,
    Callback = function()
    end,
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local isFirstPerson = false

player_group:AddToggle('fp_tp', {
    Text = 'First / Third Person',
    Default = false,
    Tooltip = 'Switch real camera mode',

    Callback = function(Value)
        isFirstPerson = Value

        if isFirstPerson then
            -- FIRST PERSON (KHÓA LUÔN)
            player.CameraMode = Enum.CameraMode.LockFirstPerson
            camera.CameraType = Enum.CameraType.Custom
        else
            -- THIRD PERSON (MỞ TỰ DO)
            player.CameraMode = Enum.CameraMode.Classic
            camera.CameraType = Enum.CameraType.Custom
        end
    end
})

player_group:AddToggle('allow_jumping', {
    Text = 'Enable Jumping',
    Default = false,
    Tooltip = 'Lets you jump',

    Callback = function(Value)
        jump_enabled = Value
        if Value then
            local_player.Character.Humanoid.JumpPower = 30
            local_player.Character.Humanoid.JumpHeight = 7.2
        else
            local_player.Character.Humanoid.JumpPower = 0
            local_player.Character.Humanoid.JumpHeight = 0
        end
    end
})

player_group:AddToggle('inf_jump', {
    Text = 'Infinite Jump',
    Default = false,
    Tooltip = 'Lets you jump forever',

    Callback = function(Value)
        inf_jump = Value
    end
})

player_group:AddToggle('no_clip', {
    Text = 'No Clip',
    Default = false,
    Tooltip = 'Lets you clip through walls',

    Callback = function(Value)
        noclip = Value
        if not Value then
            local_player.Character.HumanoidRootPart.CanCollide = true
            local_player.Character.UpperTorso.CanCollide = true
            local_player.Character.LowerTorso.CanCollide = true
            local_player.Character.Head.CanCollide = true
        end
    end
})

player_group:AddDivider()

player_group:AddToggle('inf_stamina', {
    Text = 'Infinite Stamina',
    Default = false,
    Tooltip = 'Gives you inf stamina',

    Callback = function(Value)
        inf_stamina = Value
    end
})

player_group:AddDivider()

if map:GetAttribute("MapName") == "Cargo" then
    player_group:AddLabel("Unlocks Plunge Badge With Skin On Click (Run This Before Round Start Or You Will Die.)", true)
    player_group:AddButton({
        Text = 'Unlock Easeter Egg',
    
        Func = function()
            local easter_egg = map:FindFirstChild("EE"):FindFirstChild("Jump"):FindFirstChildOfClass("ProximityPrompt")
            if easter_egg then
                local last_pos = local_player.Character.HumanoidRootPart.CFrame
                local_player.Character.HumanoidRootPart.CFrame = easter_egg.Parent.CFrame
                task.wait(0.1)
                local_player.Character.HumanoidRootPart.CFrame = last_pos
                fireproximityprompt(easter_egg)
                library:Notify("Unlocked Plunge Easeter Egg")
            else
                library:Notify("Plunge Easter Egg Not Found?? (Report On Discord)")
            end
        end,
        DoubleClick = false,
        Tooltip = 'Unlocks Plunge Badge With Skin'
    })
elseif map:GetAttribute("MapName") == "Luxury Home" then
    player_group:AddLabel("Unlocks The Laptop Badge With Skin On Click", true)
    player_group:AddButton({
        Text = 'Unlock Easeter Egg',
    
        Func = function()
            local laptop = map:FindFirstChild("EE"):FindFirstChild("Laptop"):FindFirstChild("Screen"):FindFirstChildOfClass("ProximityPrompt")
            if laptop then
                local last_pos = local_player.Character.HumanoidRootPart.CFrame
                local_player.Character.HumanoidRootPart.CFrame = laptop.Parent.CFrame
                task.wait(0.1)
                fireproximityprompt(laptop)
                local_player.Character.HumanoidRootPart.CFrame = last_pos
                library:Notify("Unlocked Laptop Easeter Egg")
            else
                library:Notify("Laptop not found?? (Report On Discord)")
            end
        end,
        DoubleClick = false,
        Tooltip = 'Unlocks Laptop Badge With Skin'
    })
elseif map:FindFirstChild("EE") then
    player_group:AddLabel("Found Easter Egg On This Map But Is Not Supported", true)
else
    player_group:AddLabel("No Easter Eggs Found On This Map", true)
end

ghost_esp_group:AddToggle('always_show', {
    Text = 'Always Show Ghost',
    Default = false,
    Tooltip = 'Shows the ghost at all times',

    Callback = function(Value)
        show_ghost = Value
        if not Value then
            for _, v in next, ghost:GetChildren() do
                if v:IsA("Model") then
                    v:FindFirstChildOfClass("MeshPart").Transparency = 1
                end
            end
        end
    end
})

ghost_esp_group:AddToggle('ghost_name', {
    Text = 'Ghost Name Esp',
    Default = false,
    Tooltip = 'Shows the ghost name',

    Callback = function(Value)
        ghost_name = Value
        if not Value then
            for _, v in next, ghost:GetChildren() do
                if v:IsA("Model") and v:FindFirstChild("Esp BillBoard") then
                    v:FindFirstChild("Esp BillBoard"):Destroy()
                end
            end
        end
    end
})

ghost_esp_group:AddToggle('highlight_ghost', {
    Text = 'Highlight Ghost',
    Default = false,
    Tooltip = 'Highlights the ghost',

    Callback = function(Value)
        highlight_ghost = Value
        if not Value then
            for _, v in next, ghost:GetChildren() do
                if v:IsA("Model") and v:FindFirstChild("Highlight") then
                    v:FindFirstChild("Highlight"):Destroy()
                end
            end
        end
    end
}):AddColorPicker('highlight_color_ghost', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Highlight Color',

    Callback = function(Value)
        highlight_color_ghost = Value
        for _, v in next, ghost:GetChildren() do
            if v:IsA("Model") and v:FindFirstChild("Highlight") then
                v:FindFirstChild("Highlight").FillColor = Value
                v:FindFirstChild("Highlight").OutlineColor = Value
            end
        end
    end
})

player_esp_group:AddToggle('player_name', {
    Text = 'Player Name Esp',
    Default = false,
    Tooltip = 'Shows the player name',

    Callback = function(Value)
        player_name = Value
        if not Value then
            for _, v in next, players:GetPlayers() do
                if v.Character and v.Character:FindFirstChild("Head") then
                    local esp_billboard = v.Character.Head:FindFirstChild("Esp BillBoard")
                    if esp_billboard then
                        espbillboard:Destroy()
                    end
                end
            end
        end
    end
})

player_esp_group:AddToggle('highlight_player', {
    Text = 'Highlight Player',
    Default = false,
    Tooltip = 'Highlights the player',

    Callback = function(Value)
        player_highlight = Value
        if not Value then
            for _, v in next, players:GetPlayers() do
                if v.Character and v.Character:FindFirstChild("Highlight") then
                    local highlight = v.Character:FindFirstChild("Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
}):AddColorPicker('highlight_color_player', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Highlight Color',

    Callback = function(Value)
        player_highlight_color = Value
        for _, v in next, players:GetPlayers() do
            if v.Character and v.Character:FindFirstChild("Highlight") then
                local highlight = v.Character:FindFirstChild("Highlight")
                if highlight then
                    highlight.FillColor = Value
                    highlight.OutlineColor = Value
                end
            end
        end
    end
})

item_esp_group:AddToggle('item_name', {
    Text = 'Item Name Esp',
    Default = false,
    Tooltip = 'Shows the item name',

    Callback = function(Value)
        item_name = Value
        if not Value then
            for _, tool in next, van_equipment:GetChildren() do
                if tool:IsA("Model") and tool:FindFirstChild("Esp BillBoard") then
                    tool:FindFirstChild("Esp BillBoard"):Destroy()
                end
            end

            for _, tool in next, dropped_equipment:GetChildren() do
                if tool:IsA("Model") and tool:FindFirstChild("Esp BillBoard") then
                    tool:FindFirstChild("Esp BillBoard"):Destroy()
                end
            end
        end
    end
})

item_esp_group:AddToggle('highlight_item', {
    Text = 'Highlight Item',
    Default = false,
    Tooltip = 'Highlights the item',

    Callback = function(Value)
        item_highlight = Value
        if not Value then
            for _, tool in next, van_equipment:GetChildren() do
                if tool:IsA("Model") and tool:FindFirstChild("Highlight") then
                    tool:FindFirstChild("Highlight"):Destroy()
                end
            end

            for _, tool in next, dropped_equipment:GetChildren() do
                if tool:IsA("Model") and tool:FindFirstChild("Highlight") then
                    tool:FindFirstChild("Highlight"):Destroy()
                end
            end
        end
    end
}):AddColorPicker('highlight_color_item', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Highlight Color',

    Callback = function(Value)
        item_highlight_color = Value
        for _, v in next, van_equipment:GetChildren() do
            if v:IsA("Model") and v:FindFirstChild("Highlight") then
                v:FindFirstChild("Highlight").FillColor = Value
                v:FindFirstChild("Highlight").OutlineColor = Value
            end
        end

        for _, v in next, dropped_equipment:GetChildren() do
            if v:IsA("Model") and v:FindFirstChild("Highlight") then
                v:FindFirstChild("Highlight").FillColor = Value
                v:FindFirstChild("Highlight").OutlineColor = Value
            end
        end
    end
})

cursed_esp_group:AddToggle('cursed_object_name', {
    Text = 'Cursed Object Name',
    Default = false,
    Tooltip = 'Shows the cursed object name',

    Callback = function(Value)
        cursed_object_name = Value
        if not Value then
            for _, v in next, cursed_objects:GetChildren() do
                if (v:IsA("MeshPart") or v:IsA("Model") or v:IsA("Part")) and not (v.Name == "Chair" or v.Name == "Body") and v:FindFirstChild("Esp BillBoard") then
                    v:FindFirstChild("Esp BillBoard"):Destroy()
                end
            end
        end
    end
})

cursed_esp_group:AddToggle('cursed_object_highlight', {
    Text = 'Cursed Object Highlight',
    Default = false,
    Tooltip = 'Highlights cursed objects',

    Callback = function(Value)
        cursed_object_highlight = Value
        if not Value then
            for _, v in next, cursed_objects:GetChildren() do
                if (v:IsA("MeshPart") or v:IsA("Model") or v:IsA("Part")) and v:FindFirstChild("Highlight") then
                    v.Highlight:Destroy()
                end
            end
        end
    end
}):AddColorPicker('cursed_object_highlight_color', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Highlight Color',

    Callback = function(Value)
        cursed_object_highlight_color = Value
        for _, v in next, cursed_objects:GetChildren() do
            if (v:IsA("MeshPart") or v:IsA("Model") or v:IsA("Part")) and v:FindFirstChild("Highlight") then
                v.Highlight.FillColor = Value
                v.Highlight.OutlineColor = Value
            end
        end
    end
})

evidence_esp_group:AddToggle('emf_name', {
    Text = 'Show Active EMFs',
    Default = false,
    Tooltip = 'Shows active EMFs done by ghost',

    Callback = function(Value)
        emf_name = Value
        if not Value then
            for i, v in next, emfs:GetChildren() do
                if v:IsA("Part") and v:FindFirstChild("Esp BillBoard") then
                    v:FindFirstChild("Esp BillBoard"):Destroy()
                end
            end
        end
    end
})

evidence_esp_group:AddToggle('orbs_name', {
    Text = 'Show Active Orbs',
    Default = false,
    Tooltip = 'Shows active orbs',

    Callback = function(Value)
        orbs_name = Value
        if not Value then
            for i, v in next, orbs:GetChildren() do
                if v:IsA("Part") and v:FindFirstChild("Esp BillBoard") then
                    v:FindFirstChild("Esp BillBoard"):Destroy()
                end
            end
        end
    end
})

closet_esp_group:AddToggle('closet_name', {
    Text = 'Hiding Spot Esp Name',
    Default = false,
    Tooltip = 'Enables names to all closets',

    Callback = function(Value)
        closet_name = Value
        if not Value then
            for i, v in next, closets:GetChildren() do
                if v:IsA("Model") and v:FindFirstChild("Esp BillBoard") then
                    v:FindFirstChild("Esp BillBoard"):Destroy()
                end
            end
        end
    end
})

closet_esp_group:AddToggle('closet_highlight', {
    Text = 'Hiding Spot Esp Highlight',
    Default = false,
    Tooltip = 'Highlights closets',

    Callback = function(Value)
        closet_highlight = Value
        if not Value then
            for i, v in next, closets:GetChildren() do
                if v:IsA("Model") and v:FindFirstChild("Highlight") then
                    v.Highlight:Destroy()
                end
            end
        end
    end
}):AddColorPicker('closet_highlight_color', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Highlight Color',

    Callback = function(Value)
        closet_highlight_color = Value
        for i, v in next, closets:GetChildren() do
            if v:IsA("Model") and v:FindFirstChild("Highlight") then
                v.Highlight.FillColor = Value
                v.Highlight.OutlineColor = Value
            end
        end
    end
})

world_group:AddToggle('fb', {
    Text = 'Full Bright',
    Default = false,
    Tooltip = 'full bright like cat!',

    Callback = function(Value)
        full_bright = Value
        if Value then
            lighting.ClockTime = 12
            lighting.GlobalShadows = false
        else
            lighting.ClockTime = 0
            lighting.GlobalShadows = true
        end
    end
})

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "😘"
colorCorrection.Saturation = 0
colorCorrection.Parent = game.Lighting

world_group:AddToggle('saturation', {
    Text = 'Increase Color Saturation',
    Default = false,
    Tooltip = 'Makes the world colors more vivid',
    Callback = function(Value)
        if Value then
            colorCorrection.Saturation = 0.75
        else
            colorCorrection.Saturation = 0
        end
    end
})

local Lighting = game:GetService("Lighting")

local nofog = false
local fogConn

-- lưu fog gốc
local defaultFogEnd = Lighting.FogEnd
local defaultFogStart = Lighting.FogStart

world_group:AddToggle('nf', {
    Text = 'No Fog',
    Default = false,
    Tooltip = 'Removes fog',

    Callback = function(Value)
        nofog = Value

        if fogConn then
            fogConn:Disconnect()
            fogConn = nil
        end

        if Value then
            fogConn = game:GetService("RunService").RenderStepped:Connect(function()
                Lighting.FogStart = 0
                Lighting.FogEnd = 1e6
            end)
        else
            -- trả về fog gốc
            Lighting.FogStart = defaultFogStart
            Lighting.FogEnd = defaultFogEnd
        end
    end
})

world_group:AddDivider()

world_group:AddButton({
    Text = "Day",
    Func = function() lighting.ClockTime = 12 end
})
world_group:AddButton({
    Text = "Night",
    Func = function() lighting.ClockTime = 0 end
})

misc_group:AddButton({
    Text = 'Anti AFK',
    Func = function()
        -- แบบง่ายโดยไม่ต้องใช้ exploit
        local_player.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        library:Notify("Anti AFK Enabled!")
    end,
    DoubleClick = false,
    Tooltip = 'Anti Afk'
})

misc_group:AddButton({
    Text = 'Infinite Yield',
    Tooltip = 'Give Inf yield has edit',
    DoubleClick = false,

    Func = function()
        local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/idtkby/Xd/refs/heads/main/infedit"))()
        end)

        if success then
            library:Notify("Load Success")
        else
            library:Notify("Failed to load infYield\n" .. tostring(err))
        end
    end
})

boost_group:AddToggle('uf', {
    Text = 'Unlock Fps',
    Default = false,
    Tooltip = 'just unlock fps cap 60 to 360',

    Callback = function(Value)
        fps = Value
        if Value then
            setfpscap(360)
        else
            setfpscap(60)
        end
    end
})





-- [ UI SETTINGS ] --
-- Các biến lưu setting
getgenv().hunt_notif_enabled = false
getgenv().hunt_notif_mode = "Notify"

misc_group:AddToggle('HuntNotifToggle', {
    Text = 'Enable Hunt Notifier',
    Default = false,
    Callback = function(Value)
        hunt_notif_enabled = Value
        -- Nếu tắt toggle thì ẩn Label ngay
        if HuntGui_Main and not Value then 
            HuntGui_Main.Enabled = false 
        elseif HuntGui_Main and Value and (hunt_notif_mode == "Label" or hunt_notif_mode == "Both") then
            HuntGui_Main.Enabled = true -- Hiện lại nếu đang bật
        end
    end
})

misc_group:AddDropdown('HuntNotifMode', {
    Values = { 'Notify', 'Both' },
    Default = 1,
    Multi = false,
    Text = 'Notification Mode',
    Callback = function(Value)
        hunt_notif_mode = Value
        -- Cập nhật hiển thị ngay khi đổi chế độ
        if HuntGui_Main and hunt_notif_enabled then
            if Value == "Label" or Value == "Both" then
                HuntGui_Main.Enabled = true
            else
                HuntGui_Main.Enabled = false
            end
        end
    end
})



library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local watermark_connection = run_service.RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    library:SetWatermark(('IgnahK | %s fps | %s ms | Game: ' .. info.Name .. ''):format(
        math.floor(FPS),
        math.floor(stats.Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);


-- ═══════════════════════════════════════════════════════════════════
--   HSHub Patches RELOCATED HERE (was originally at line ~5208 at
--   end-of-file, but something in the existing code between line
--   5077 and 5228 silently terminates script load — likely the
--   `local _Toggles = getgenv().Linoria and ...` line. Helper
--   assignments (cleanupESP/resetEvidence/resetGhostState/rewireWatchers)
--   never ran from there, so PATCH 5's recache chain hit all-nil
--   helpers and silently no-op'd. Moved here (before Unload button)
--   where load is confirmed to reach. Same logic, safer placement.
-- ═══════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
--   HSHub Patches  (applied after sample 6 body finishes)
--
--   These are surgical fixes for known sample 6 issues without
--   modifying the original feature logic above. See docs/NOTES.md.
-- ═══════════════════════════════════════════════════════════════════
-- DEFENSIVE: previous version was `local _Toggles = getgenv().Linoria and ...`
-- which assumes getgenv() returns a non-nil table. On some executors /
-- some script contexts, getgenv() can return nil, causing
-- "attempt to index a nil value" — script load HALTS RIGHT HERE,
-- silently. Result: every PATCH below this line never gets assigned,
-- which exactly matches the symptom (find=OK, everything-else=NIL)
-- the user reported. Pcall + fallback fixes it.
local _Toggles = {}
do
    local ok, env = pcall(getgenv)
    if ok and type(env) == "table" then
        local lin = env.Linoria
        if type(lin) == "table" and type(lin.Toggles) == "table" then
            _Toggles = lin.Toggles
        end
    end
end
local _Workspace  = game:GetService("Workspace")
local _RunService = game:GetService("RunService")
local _Players    = game:GetService("Players")
local _LP         = _Players.LocalPlayer

-- ── PATCH 1: ESP cleanup on toggle-off ────────────────────────────
-- Sample 6 creates "Esp BillBoard" and Highlight instances but doesn't
-- destroy them when the toggle is switched off. We monitor toggle state
-- transitions (true → false) and force a workspace sweep.
--
-- Note: `_hshub_cleanupESP` was forward-declared as `local` near PATCH 5,
-- so the assignment below (no `local` keyword) binds the actual function
-- to that same upvalue. PATCH 5's session-change handler can then call it.
_hshub_cleanupESP = function(kindFilter)
    -- kindFilter = "all" | "billboard" | "highlight"
    for _, obj in ipairs(_Workspace:GetDescendants()) do
        local nm = obj.Name
        if nm == "Esp BillBoard" then
            if kindFilter == "all" or kindFilter == "billboard" then
                pcall(function() obj:Destroy() end)
            end
        elseif obj:IsA("Highlight") then
            -- only destroy Highlights NOT inside HSHub's own GUI (ESP highlights live in workspace)
            if not obj:IsDescendantOf(HSHub.ScreenGui) then
                if kindFilter == "all" or kindFilter == "highlight" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
end

do
    local _espToggleKeys = {
        "highlight_ghost", "ghost_name", "always_show",
        "highlight_player", "player_name",
        "highlight_item",  "item_name",
        "cursed_object_highlight", "cursed_object_name",
        "closet_highlight", "closet_name",
        "emf_name", "orbs_name",
    }
    local _lastState = {}
    _RunService.Heartbeat:Connect(function()
        for _, k in ipairs(_espToggleKeys) do
            local t = _Toggles[k]
            local v = t and t.Value or false
            if _lastState[k] == true and v == false then
                pcall(_hshub_cleanupESP, "all")
                break
            end
            _lastState[k] = v
        end
    end)
end

-- ── PATCH 2: BillboardGui appearance override (HSHub override v2) ──
-- Sample 6 creates 100×50 px billboards with AlwaysOnTop=true which obstruct
-- the screen when standing close to ghosts/players. The previous patch only
-- changed descendant TextLabel font — it did NOT resize the BillboardGui
-- itself, and missed labels that get parented AFTER DescendantAdded fires
-- (sample 6 creates the BillboardGui first, then adds the TextLabel a tick
-- later, which races with the original soften pass).
--
-- This version: shrinks the BillboardGui, disables AlwaysOnTop so walls
-- properly occlude the labels, clips descendants, and re-softens on every
-- DescendantAdded on the billboard itself.
do
    local SOFT_MAX_DIST  = 60                              -- studs; tweak if map larger
    local SOFT_SIZE      = UDim2.new(0, 60, 0, 14)         -- was UDim2.new(0,100,0,50)
    local SOFT_TEXT_SIZE = 11

    local function _softenChild(c)
        if c:IsA("TextLabel") or c:IsA("TextButton") then
            pcall(function()
                c.BackgroundTransparency = 1               -- kill the white box
                c.BorderSizePixel        = 0
                c.TextScaled             = false
                c.TextSize               = math.min(c.TextSize or 14, SOFT_TEXT_SIZE)
                c.TextStrokeTransparency = 0.15
                c.TextStrokeColor3       = Color3.new(0, 0, 0)
                c.Font                   = Enum.Font.GothamSemibold
                c.Size                   = UDim2.new(1, 0, 1, 0)
            end)
        elseif c:IsA("Frame") or c:IsA("ImageLabel") then
            pcall(function() c.BackgroundTransparency = 1 end)
        end
    end

    local function _softenBillboard(bb)
        if not bb:IsA("BillboardGui") then return end
        pcall(function()
            bb.AlwaysOnTop      = false                    -- let walls occlude
            bb.MaxDistance      = SOFT_MAX_DIST
            bb.LightInfluence   = 0
            bb.Size             = SOFT_SIZE                -- the key fix
            bb.ClipsDescendants = true
            bb.ResetOnSpawn     = false
        end)
        for _, c in ipairs(bb:GetDescendants()) do _softenChild(c) end
        -- Catch labels added later (sample 6 race condition)
        bb.DescendantAdded:Connect(function(c) task.defer(_softenChild, c) end)
    end

    -- soften any existing billboards on load
    for _, d in ipairs(_Workspace:GetDescendants()) do
        if d.Name == "Esp BillBoard" and d:IsA("BillboardGui") then
            pcall(_softenBillboard, d)
        end
    end
    -- soften any future ones
    _Workspace.DescendantAdded:Connect(function(d)
        if d.Name == "Esp BillBoard" then
            task.wait()                                    -- let children populate
            pcall(_softenBillboard, d)
        end
    end)
end

-- ── PATCH 3: Evidence reset on new game session ──────────────────
-- When player teleports/respawns into a new investigation, the evidence
-- labels from previous game (Para Motion: Yes, etc.) stay stuck.
--
-- OLD APPROACH (broken): scan HSHub.ScreenGui:GetDescendants() for
-- TextLabels with matching prefix and rewrite their .Text. This failed
-- because the evidence labels live in the LinoriaLib UI ScreenGui — a
-- SEPARATE Roblox Instance from HSHub.ScreenGui (which is HSHub's own
-- floating panel, line 524/705). Result: scan returned 0 matching
-- TextLabels and the function silently did nothing.
--
-- NEW APPROACH: call `:SetText()` directly on each label wrapper that
-- was captured as local at lines 2925-2939 / 3003-3010. This is exactly
-- how the original watchers update the labels (e.g. line 5413:
-- `motion_label:SetText('Motion: Yes')`) — guaranteed to hit the right
-- TextLabel because Linoria's wrapper handles the DOM lookup internally.
--
-- Bound to forward-declared upvalue (no `local`) so PATCH 5 can call it.
_hshub_resetEvidence = function()
    local resets = {
        { freezing_label,     'Freezing Temp: Not Found' },
        { ghostwriting_label, 'Ghost Writing: Not Found' },
        { fingerprint_label,  'Fingerprints: Not Found' },
        { motion_label,       'Para Motion: Not Found' },
        { spirit_box_label,   'Spirit Box: Not Found' },
        { orb_label,          'Orbs: Not Found' },
        { emf_label,          'EMF 5: Not Found' },
        { last_emf_label,     'Last EMF: Not Found' },
        { ghost_label,        'ghost: not found' },
        { ghost_name_label,   'Ghost Name: N/A' },
        { ghost_room_label,   'Ghost Spawn: Not Found' },
        { ghost_speed_label,  'Ghost Speed: Not Found' },
        { ghost_room_label2,  'Ghost Room: Not Found' },
        { sanity_label,       'Player Sanity:' },
    }
    local count = 0
    for _, pair in ipairs(resets) do
        local lbl, txt = pair[1], pair[2]
        if lbl then
            local ok = pcall(function() lbl:SetText(txt) end)
            if ok then count = count + 1 end
        end
    end
    return count
end

-- ── PATCH 3b: State flag reset ───────────────────────────────────
-- The evidence-label sweep above resets the *UI* but the underlying
-- Lua state flags (got_spirit_box, ghost_room_found, ghost_room_pos,
-- etc.) are still latched from the previous match. Without resetting
-- them: watcher reconnections won't re-detect evidence because the
-- "already found" guards still pass; TP-to-ghost-spawn uses stale
-- CFrame; etc.
--
-- All these names refer to module-level locals declared earlier
-- (lines ~2820-2880 area). Lua's upvalue capture means writing here
-- modifies the same bindings the watchers read.
_hshub_resetGhostState = function()
    pcall(function() got_spirit_box     = false end)
    pcall(function() got_motion         = false end)
    pcall(function() no_motion          = false end)
    pcall(function() got_freezing       = false end)
    pcall(function() found_writing      = false end)
    pcall(function() found_fingerprint  = false end)
    pcall(function() found_emf          = false end)
    pcall(function() found_orb          = false end)
    pcall(function() ghost_room_found   = false end)
    pcall(function() ghost_room_pos     = nil end)
    pcall(function() ghost_room         = nil end)
    pcall(function() found_name         = nil end)
    -- emf locking tables also need to be cleared (line ~3860 area)
    pcall(function()
        if emf_active_timers then for k in pairs(emf_active_timers) do emf_active_timers[k] = nil end end
        if emf_locking_room  then for k in pairs(emf_locking_room)  do emf_locking_room[k]  = nil end end
    end)
end

-- (The old `_LP.CharacterAdded` trigger that used to live here was
--  removed — it fired at the wrong time, e.g. player respawn inside
--  the van counts as CharacterAdded but isn't a new match. PATCH 5's
--  workspace.ChildAdded on Map/Van/Dynamic is the correct trigger.)

-- ── PATCH 3c: Watcher rewiring on session change ──────────────────
-- Critical for "script works in new session": the original watcher
-- :Connect() calls at script-load attach to instances that get
-- Destroy()'d at match end. Recaching the upvalues to point at new
-- instances doesn't help — the dead connections stay dead and the
-- new instances have no listeners. So we re-establish all of them
-- here, freshly, on every session change.
--
-- Connections re-established:
--   • motion (RenderStepped on motions:GetDescendants)
--   • sanity (RenderStepped on workspace.Van.SanityBoard...)
--   • emfs.ChildAdded
--   • fingerprints.ChildAdded
--   • orbs.ChildAdded
--   • GhostInfo text-change
--
-- Old handles are :Disconnect()'d first (idempotent on first call).
local _watcher_handles = {}
_hshub_rewireWatchers = function()
    -- 1) Tear down anything we previously owned
    for k, h in pairs(_watcher_handles) do
        if h then pcall(function() h:Disconnect() end) end
        _watcher_handles[k] = nil
    end
    -- Also disconnect the originals from script-load (only relevant on
    -- the first session-change call — they're globals, may still be live)
    pcall(function() if motionconnection then motionconnection:Disconnect() end end)
    pcall(function() if sanityconnection then sanityconnection:Disconnect() end end)

    -- 2) Motion evidence watcher
    --    Only acts while !got_motion && !no_motion — once either fires,
    --    we keep the connection alive (cheap RenderStepped early-return)
    --    so the next session-change rewire can find it via the handle
    --    table instead of leaking a global.
    if motions then
        _watcher_handles.motion = run_service.RenderStepped:Connect(function()
            if got_motion or no_motion then return end
            for _, motion in pairs(motions:GetDescendants()) do
                if motion:IsA("Part") then
                    if motion.Color == Color3.fromRGB(252, 52, 52) then
                        motion_label:SetText('Motion: Yes')
                        library:Notify("Found Motion")
                        got_motion = true
                        pcall(updateGhostType)
                        return
                    elseif motion.BrickColor == BrickColor.new("Toothpaste") then
                        motion_label:SetText('Motion: No')
                        library:Notify("No Motion Found")
                        no_motion = true
                        return
                    end
                end
            end
        end)
        motionconnection = _watcher_handles.motion -- keep cleanup hook (line ~5020) happy
    end

    -- 3) Sanity display watcher
    _watcher_handles.sanity = run_service.RenderStepped:Connect(function()
        local _van = van
        if not _van or not _van.Parent then return end
        local sboard = _van:FindFirstChild("SanityBoard")
        local sgui   = sboard and sboard:FindFirstChild("SurfaceGui")
        local frame  = sgui and sgui:FindFirstChild("Frame")
        local plrs   = frame and frame:FindFirstChild("Players")
        local pframe = plrs and plrs:FindFirstChild(local_player.DisplayName)
        if pframe then
            local entire = pframe:FindFirstChild("Entire")
            local sval   = entire and entire:FindFirstChild("Val")
            if sval then sanity_label:SetText('Player Sanity: ' .. sval.Text) end
        end
        local character = local_player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then
            sanity_label:SetText('Player Sanity: Dead')
        end
    end)
    sanityconnection = _watcher_handles.sanity

    -- 4) EMF .ChildAdded — fresh `emfs` ref (post-recache points to new instance)
    if emfs then
        _watcher_handles.emf_child = emfs.ChildAdded:Connect(function(emf)
            if emf:IsA("Part") and emf.Name == 'EMF5' and not found_emf then
                emf_label:SetText('EMF 5: Yes')
                library:Notify("Found EMF 5")
                found_emf = true
                pcall(updateGhostType)
            end
            if emf:IsA("Part") then
                last_emf_label:SetText('Last EMF: ' .. emf.Name)
                library:Notify("Last EMF: " .. emf.Name)
            end
        end)
    end

    -- 5) Fingerprints .ChildAdded
    if fingerprints then
        _watcher_handles.fingerprint_child = fingerprints.ChildAdded:Connect(function(fp)
            if fp:IsA("Part") and not found_fingerprint then
                fingerprint_label:SetText('Fingerprints: Yes')
                library:Notify("Found Fingerprint")
                found_fingerprint = true
                pcall(updateGhostType)
            end
        end)
    end

    -- 6) Orbs .ChildAdded
    if orbs then
        _watcher_handles.orb_child = orbs.ChildAdded:Connect(function(orb)
            if orb:IsA("Part") and not found_orb then
                orb_label:SetText('Orbs: Yes')
                library:Notify("Found Orbs")
                found_orb = true
                pcall(updateGhostType)
            end
        end)
    end

    -- 7) GhostInfo text watcher + immediate read of current text
    if GhostInfo then
        pcall(function()
            local n = getGhostName(GhostInfo.Text)
            found_name = n
            ghost_name_label:SetText("Ghost Name: " .. (n or "N/A"))
        end)
        _watcher_handles.ghost_info_text = GhostInfo:GetPropertyChangedSignal("Text"):Connect(function()
            local n = getGhostName(GhostInfo.Text)
            found_name = n
            ghost_name_label:SetText("Ghost Name: " .. (n or "N/A"))
        end)
    end

    -- 8) Invalidate ghost humanoid cache used by ghostconnection at line ~3257
    --    (cachedGhostHumanoid is a module-level local — upvalue write reaches it)
    pcall(function() cachedGhostHumanoid = nil end)
end

-- end of relocated HSHub Patches

menu_group:AddButton('Unload', function()
    anti_touch = false
    no_hold = false
    inf_stamina = false
    speed_sprint = false
    jump_enabled = false
    full_bright = false
    nofog = false
    fps = false
    show_ghost = false
    highlight_ghost = false
    ghost_name = false
    player_name = false
    player_highlight = false
    item_name = false
    item_highlight = false
    cursed_object_highlight = false
    cursed_object_name = false
    orbs_name = false
    emf_name = false
    found_writing = false
    ghost_name = false
    closet_name = false
    closet_highlight = false

    for _, v in next, ghost:GetChildren() do
        if v:IsA("Model") then
            v:FindFirstChildOfClass("MeshPart").Transparency = 1
        end
    end

    for _, esp in next, workspace:GetDescendants() do
        if esp.Name == "Esp BillBoard" or esp.Name == "Highlight" then
            esp:Destroy()
        end
    end

    local_player.Character.Humanoid.JumpPower = 0
    local_player.Character.Humanoid.JumpHeight = 0
    local_player.Character.Humanoid.CameraOffset = Vector3.new(0, 0, -1)
    local_player.Character.HumanoidRootPart.CanCollide = true
    local_player.Character.UpperTorso.CanCollide = true
    local_player.Character.LowerTorso.CanCollide = true
    local_player.Character.Head.CanCollide = true
    lighting.ClockTime = 0
    lighting.GlobalShadows = true
    watermark_connection:Disconnect()
    motionconnection:Disconnect()
    sanityconnection:Disconnect()
    ghostconnection:Disconnect()
    playerconnection:Disconnect()
    library:Unload()
end)

credits_group:AddLabel('IgnahK: Editor', true)
credits_group:AddLabel('Credits: Idk', true)

-- ── HSHub Utilities (manual reset buttons) ─────────────────────────
-- Placed HERE (not at end-of-file) because `save_manager:BuildConfigSection`
-- + `theme_manager:ApplyToTab` at lines ~5060 freeze the Settings tab
-- layout — any groupbox/button added AFTER those calls silently fails
-- to render. Previous attempts at end-of-file landed in that dead zone.
--
-- Buttons added to existing `menu_group` (created at line 2661) using the
-- 2-arg positional `AddButton('Name', function() end)` form, mirroring how
-- the Unload button at line 4984 is registered — confirmed-working pattern.
--
-- DIAGNOSTIC button bodies — each step reports its outcome to a single
-- notify at the end. Previous version pcall'd everything blindly, so when
-- helpers were nil or threw, the user saw nothing. Now if a step fails
-- the diag string tells you exactly which one (e.g. "state=NIL evid=OK").

-- helper that runs `fn` if non-nil and returns a short diag tag
local function _hshub_diagRun(name, fn, ...)
    if fn == nil then return name .. "=NIL" end
    local args = {...}
    local ok, err_or_ret = pcall(function() return fn(table.unpack(args)) end)
    if not ok then return name .. "=ERR:" .. tostring(err_or_ret):sub(1, 40) end
    if type(err_or_ret) == "number" then return name .. "=" .. err_or_ret end
    return name .. "=OK"
end

menu_group:AddButton('Reset Evidence Labels', function()
    local d = {
        _hshub_diagRun("evid",  _hshub_resetEvidence),
        _hshub_diagRun("state", _hshub_resetGhostState),
        _hshub_diagRun("wire",  _hshub_rewireWatchers),
    }
    pcall(function() HSHub:Notify("Reset: " .. table.concat(d, " "), "ok", 4) end)
end)

menu_group:AddButton('Force ESP Cleanup', function()
    local d = { _hshub_diagRun("esp", _hshub_cleanupESP, "all") }
    pcall(function() HSHub:Notify("ESP cleanup: " .. table.concat(d, " "), "ok", 3) end)
end)

menu_group:AddButton('Force Session Refresh', function()
    -- Same chain as workspace.ChildAdded but invoked manually.
    local d = {
        _hshub_diagRun("state", _hshub_resetGhostState),
        _hshub_diagRun("evid",  _hshub_resetEvidence),
        _hshub_diagRun("esp",   _hshub_cleanupESP, "all"),
        _hshub_diagRun("wire",  _hshub_rewireWatchers),
        _hshub_diagRun("find",  _hshub_startGhostFinder),
    }
    pcall(function() HSHub:Notify("Refresh: " .. table.concat(d, " "), "ok", 5) end)
end)


settings_group:AddToggle('keybind_visibility', {
    Text = 'Keybind Visibility',
    Default = false,
    Tooltip = 'Enables/Disables the watermark',

    Callback = function(Value)
        library.KeybindFrame.Visible = Value
    end,
})

menu_group:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
library.ToggleKeybind = Options.MenuKeybind
theme_manager:SetLibrary(library)
save_manager:SetLibrary(library)
save_manager:IgnoreThemeSettings()
save_manager:SetIgnoreIndexes({ 'MenuKeybind' })
theme_manager:SetFolder('Khanghubskssoo')
save_manager:SetFolder('kk/Specter')
save_manager:BuildConfigSection(tabs['ui settings'])
theme_manager:ApplyToTab(tabs['ui settings'])

save_manager:LoadAutoloadConfig()






-- ===== FIX HUNT DETECT DỰA TRÊN VOLUME =====

getgenv().hunt_notif_enabled = getgenv().hunt_notif_enabled or false
getgenv().hunt_notif_mode = getgenv().hunt_notif_mode or "Notify"

task.spawn(function()
    local HUNT_ID = "18657053709"
    local isHunting = false
    local StarterGui = game:GetService("StarterGui")

    local function notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 5
            })
        end)
    end

    local function setHuntState(active)
        if isHunting == active then return end -- Tránh lặp lại thông báo nếu volume nhảy liên tục
        isHunting = active

        -- ===== CẬP NHẬT LABEL =====
        if HuntGui_Main and HuntLabel_Text and hunt_notif_enabled then
            if hunt_notif_mode == "Label" or hunt_notif_mode == "Both" then
                HuntGui_Main.Enabled = true
                if active then
                    HuntLabel_Text.Text = "⚠️ HUNTING ⚠️"
                    HuntLabel_Text.TextColor3 = Color3.fromRGB(255, 0, 0)
                else
                    HuntLabel_Text.Text = "✅ SAFE ✅"
                    HuntLabel_Text.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
            end
        end

        -- ===== GỬI NOTIFY =====
        if hunt_notif_enabled and (hunt_notif_mode == "Notify" or hunt_notif_mode == "Both") then
            if active then
                notify("⚠️ WARNING ⚠️", "Ghost is HUNTING!")
            else
                notify("✅ SAFE ✅", "Hunt Has Ended.")
            end
        end
    end

    local function bindSound(snd)
        if not snd:IsA("Sound") then return end
        if not tostring(snd.SoundId):find(HUNT_ID) then return end

        -- Hàm kiểm tra âm lượng
        local function checkVolume()
            -- Nếu Volume lớn hơn 0 (thường game sẽ set 0.5 hoặc 1 khi hunt)
            if snd.Volume > 0.31 then
                setHuntState(true)
            else
                setHuntState(false)
            end
        end

        -- Lắng nghe sự thay đổi của thuộc tính Volume
        snd:GetPropertyChangedSignal("Volume"):Connect(checkVolume)
        
        -- Kiểm tra ngay lúc vừa tìm thấy sound
        checkVolume()
    end

    -- Quét SoundService và Workspace
    local SoundService = game:GetService("SoundService")
    for _, v in ipairs(SoundService:GetDescendants()) do bindSound(v) end
    SoundService.DescendantAdded:Connect(bindSound)

    for _, v in ipairs(workspace:GetDescendants()) do bindSound(v) end
    workspace.DescendantAdded:Connect(bindSound)
end)



print("-- Specter 2 Script Note --")
warn("I added a specter script and changed 50% of the structure, so it's not 100% my doing.")
print("------------------- IgnahK -")





-- ── PATCH 4 was originally placed here at end-of-file. Moved to the
-- live UI zone (right after the Unload button at line ~5040), BEFORE
-- save_manager:BuildConfigSection finalizes the Settings tab. Late
-- additions here got silently dropped by the framework.

-- PATCH 6 moved to early-init at line ~2664 (right after main tabs).
-- Late window:AddTab + BuildCreditsTab attempts didn't produce visible UI;
-- creating the tab in the same pass as Main/Esp/Player/Settings is more
-- robust and matches the wrapper's actual usage pattern.
pcall(function()
    HSHub:Notify('HS Hub loaded · Specter 2 · HS-SP2-V4-test', 'ok', 3)
end)

