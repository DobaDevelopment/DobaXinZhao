--[[    DOBA DEVELOPMENT, ITS MY HOBBY ENJOY    ]]
require("common.log")
module("Doba Xin Zhao", package.seeall, log.setup)

if Player.CharName ~= "XinZhao" then return end
local _SDK = _G.CoreEx
local Game = _SDK.Game
local Input = _SDK.Input
local HealthPred, Prediction = _G.Libs.HealthPred, _G.Libs.Prediction
local Orbwalker, Collision = _G.Libs.Orbwalker, _G.Libs.CollisionLib
local DmgLib, ImmobileLib = _G.Libs.DamageLib, _G.Libs.ImmobileLib
local Spell, Menu = _G.Libs.Spell, _G.Libs.NewMenu
local TS = _G.Libs.TargetSelector()
local ObjManager, EventManager = _SDK.ObjectManager, _SDK.EventManager
local Enums, Geometry, Renderer =_SDK.Enums, _SDK.Geometry, _SDK.Renderer
local XinZhao = {}
local XinZhaoPrioHi = {}
local XinZhaoPrioNo = {}

--[[    MENU SECTION    ]]
function XinZhao.LoadMenu()
    Menu.RegisterMenu("Doba Xin Zhao", "Doba Xin Zhao", function()
	Menu.NewTree("Combo", "Combo", function ()
        Menu.Checkbox("Combo.CastQ","Cast Q",true)
        Menu.Checkbox("Combo.CastW","Cast W",true)
        Menu.Checkbox("Combo.CastE","Cast E",true)
        Menu.Checkbox("Combo.CastR","Cast R",false) end)

    Menu.NewTree("Harass", "Harass Settings", function()
        Menu.ColoredText("Mana Percentage", 0xFFD700FF, true)
        Menu.Slider("ManaSlider","",50,0,100)
        Menu.Checkbox("Harass.CastW",   "Use W", true) end)

    Menu.NewTree("Waveclear", "Clear", function ()
        Menu.ColoredText("Mana Percentage", 0xFFD700FF, true)
        Menu.Slider("ManaSliderLane","",50,0,100)
		Menu.ColoredText("Lane", 0xFFD700FF, true)
        Menu.Checkbox("Lane.Q","Cast Q",true)
		Menu.Checkbox("Lane.W","Cast W",true)
        Menu.Checkbox("Lane.E","Cast E",false)
        Menu.Separator()
        Menu.ColoredText("Mana Percentage", 0xFFD700FF, true)
        Menu.Slider("ManaSliderJungle","",50,0,100)
		Menu.ColoredText("Jungle", 0xFFD700FF, true)
        Menu.Checkbox("Jungle.Q",   "Use Q", true)
        Menu.Checkbox("Jungle.W",   "Use W", true)
        Menu.Checkbox("Jungle.E",   "Use E", false) end)

    Menu.NewTree("Prediction", "Prediction Settings", function()
        Menu.Slider("Chance.W","HitChance W",0.75, 0, 1, 0.05) end)

    Menu.NewTree("Range", "Spell Range Settings", function()
        Menu.Slider("Max.W","W Max Range", 875, 500, 875)
        Menu.Slider("Min.W","W Min Range",50, 0, 400)
        Menu.Slider("Max.E","E Max Range", 875, 500, 875)
        Menu.Slider("Min.E","E Min Range",50, 0, 400) end)

    Menu.NewTree("Draw", "Drawing Settings", function()
        Menu.Checkbox("Drawing.W.Enabled",   "Draw W Range", false)
        Menu.ColorPicker("Drawing.W.Color", "Draw W Color", 0x30e6f0ff)
        Menu.Checkbox("Drawing.E.Enabled",   "Draw E Range", true)
        Menu.ColorPicker("Drawing.E.Color", "Draw E Color", 0x3060f0ff) end) end) end

--[[    SPELLS INFO SECTION / VIKI LOL CHAMP    ]]
local Q = Spell.Active({
        Slot = Enums.SpellSlots.Q,
        Range = 325,
        Delay = 0.25,
        Key = "Q",
})
local W = Spell.Skillshot({ 
        Slot = Enums.SpellSlots.W,
        Range = 900,
        Delay = 0.25,
        Collisions = { WindWall = true, Minions = true },
        Type = "Linear",
        UseHitbox = true,
        Key = "W"
})
local E = Spell.Targeted({
        Slot = Enums.SpellSlots.E,
        Range = 650,
        Radius = 125,
        Type = "Circular",
        Key = "E"
})
local R = Spell.Active({
        Slot = Enums.SpellSlots.R,
        Range = 325,
        Radius = 225,
        Key = "R"
})
--[[    USEFULL FUNCTION    ]]
local function GameIsAvailable()--Check if Game is On
    return not (Game.IsChatOpen() or Game.IsMinimized() or Player.IsDead or Player.IsRecalling) 
end
local function HitChance(spell)
    return Menu.Get("Chance."..spell.Key) end
local function CanCast(spell,mode)
    return
    spell:IsReady() and Menu.Get(mode .. ".Cast"..spell.Key) end
local function GetTargets(spell)
    return {TS:GetTarget(spell.Range,true)} end
local function Lane(spell)
    return Menu.Get("Lane."..spell.Key) end
local function Jungle(spell)
    return Menu.Get("Jungle."..spell.Key) end

function XinZhao.OnNormalPriority()
    if not GameIsAvailable() then return end
        local ModeToExecute = XinZhaoPrioHi[Orbwalker.GetMode()]
    if ModeToExecute then
        ModeToExecute()
    end
end
function XinZhao.OnHighPriority()
    if not GameIsAvailable() then return end
        local ModeToExecute = XinZhaoPrioNo[Orbwalker.GetMode()]
    if ModeToExecute then
        ModeToExecute()
    end
end

--[[    COMBO SECTION    ]]
function XinZhaoPrioHi.Combo()
    local Ma = Menu.Get("Max.W")
    local Mi = Menu.Get("Min.W")
    if CanCast(W,"Combo") then
        for k, wTarget in ipairs(GetTargets(W)) do
            if wTarget:Distance(Player) < Ma and
                Player:Distance(wTarget) > Mi and
                W:CastOnHitChance(wTarget, HitChance(W)) then
            return end end end end
function XinZhaoPrioNo.Combo()
    local Ma = Menu.Get("Max.E")
    local Mi = Menu.Get("Min.E")
    if CanCast(Q,"Combo") then
        for k, v in pairs(GetTargets(Q)) do
            if Q:Cast() then
            return end end end
    if CanCast(E,"Combo") then
        for k, eTarget in ipairs(GetTargets(E)) do
            if eTarget:Distance(Player) < Ma and
                Player:Distance(eTarget) > Mi and
                E:Cast(eTarget) then
            return end end end 
    if CanCast(R,"Combo") then
        for k, v in pairs(GetTargets(R)) do
            if R:Cast() then
            return end end end end

--[[    CLEAR SECTION    ]]
function XinZhaoPrioNo.Waveclear()
    --[[    JUNGLE CLEAR SECTION    ]]
    if Menu.Get("ManaSliderJungle") < (Player.ManaPercent * 100) then
    if Jungle(Q) and Q:IsReady() then
        for k, v in pairs(ObjManager.Get("neutral", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and Q:IsInRange(minion) then
                    if Q:Cast() then
                      return end end end end end
    if Jungle(W) and W:IsReady() then
        for k, v in pairs(ObjManager.Get("neutral", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and W:IsInRange(minion) then
                    if W:Cast(minion) then
                      return
                    end end end end end
    if Jungle(E) and E:IsReady() then
        for k, v in pairs(ObjManager.Get("neutral", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and E:IsInRange(minion) then
                    if E:Cast(minion) then
                      return end end end end end end

--[[    LANE CLEAR SECTION    ]]
    if Menu.Get("ManaSliderLane") < (Player.ManaPercent * 100) then
    if Lane(Q) and Q:IsReady() then
        for k, v in pairs(ObjManager.Get("enemy", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and Q:IsInRange(minion) then
                    if Q:Cast() then
                      return end end end end end
    if Lane(W) and W:IsReady() then
        for k, v in pairs(ObjManager.Get("enemy", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and W:IsInRange(minion) then
                    if W:Cast(minion) then
                      return
                    end end end end end
    if Lane(E) and E:IsReady() then
        for k, v in pairs(ObjManager.Get("enemy", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and E:IsInRange(minion) then
                    if E:Cast(minion) then
                      return end end end end end end end

--[[    HARASS SECTION    ]]
function XinZhaoPrioNo.Harass()
    if Menu.Get("ManaSlider") > (Player.ManaPercent * 100) then return end
    local Ma = Menu.Get("Max.W")
    local Mi = Menu.Get("Min.W")
    if CanCast(W,"Harass") then
        for k, wTarget in ipairs(GetTargets(W)) do
            if wTarget:Distance(Player) < Ma and
             Player:Distance(wTarget) > Mi and
              W:CastOnHitChance(wTarget, HitChance(W)) then
                return end end end end

--[[    DRAWINGS SECTION    ]]
function XinZhao.OnDraw()
    local Pos = Player.Position
    local spells = {W,E}
    for k, v in pairs(spells) do
        if Menu.Get("Drawing."..v.Key..".Enabled", true) then
            Renderer.DrawCircle3D(Pos, v.Range, 30, 3, Menu.Get("Drawing."..v.Key..".Color")) end end end
function OnLoad()
    XinZhao.LoadMenu()
    for eventName, eventId in pairs(Enums.Events) do
        if XinZhao[eventName] then
            EventManager.RegisterCallback(eventId, XinZhao[eventName])
        end end return true end
