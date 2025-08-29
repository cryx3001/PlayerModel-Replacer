CreateConVar("cl_player_model_replacer_enable", "0", {FCVAR_ARCHIVE}, "Enable PlayerModel Replacer")

local defaultModel = "models/player/kleiner.mdl"

local function replacePlayerModelPly(ply, model)
    if ply == LocalPlayer() then return end

    if IsValid(ply) then
        ply:SetModel(model)
    end
end

local function replacePlayerModelsByDefault()
    for _, ply in ipairs(player.GetAll()) do
        replacePlayerModelPly(ply, defaultModel)
    end
end

local function replacePlayerModels()
    local convarValue = GetConVar("cl_player_model_replacer_enable"):GetBool()

    if convarValue then
        replacePlayerModelsByDefault()
    else
        net.Start("PlyModelRep_AskOriginalModels")
        net.SendToServer()
    end

end

cvars.AddChangeCallback("cl_player_model_replacer_enable", function(convar_name, value_old, value_new)
    replacePlayerModels()
end)

net.Receive("PlyModelRep_SendOriginalModel", function(len, ply)
    local tblPlayerModels = net.ReadTable()
    for steamID64, model in pairs(tblPlayerModels) do
        local targetPly = player.GetBySteamID64(steamID64)
        replacePlayerModelPly(targetPly, model)
    end
end)

hook.Add("InitPostEntity", "PlyModelRep_WarnPlayer", function()
    if not GetConVar("cl_player_model_replacer_enable"):GetBool() then return end

    timer.Simple(1, function()
        chat.AddText(Color(0, 255, 0), "[PlayerModel Replacer] ", Color(255, 255, 255), "Player models are replaced with " , Color(200,200,200), defaultModel, Color(255, 255, 255), ". You can change this by setting ", Color(200,200,200), "cl_player_model_replacer_enable", Color(255, 255, 255), " convar to 0 in the console or in the context menu.")
    end)
end)

hook.Add("OnEntityCreated", "PlyModelRep_OnEntityCreated", function(ent)
    if not ent:IsPlayer() then return end

    if GetConVar("cl_player_model_replacer_enable"):GetBool() then
        timer.Simple(0, function()
            replacePlayerModelPly(ent, defaultModel)
        end)
    end
end)

hook.Add("InitPostEntity", "PlyModelRep_InitPostEntity", function()
    replacePlayerModels()
end)

list.Set("DesktopWindows", "PlayerModelReplacer", {
    title = "PlayerModel Replacer",
    icon = "icon16/user.png",
    onewindow = true,

    init = function(icon, window)
        window:SetTitle("PlayerModel Replacer")
        window:SetSize(400, 200)
        window:Center()

        local checkbox = vgui.Create("DCheckBoxLabel", window)
        checkbox:SetPos(10, 30)
        checkbox:SetText("Enable PlayerModel Replacer\n(replaces all player models with " .. defaultModel .. ")")
        checkbox:SetConVar("cl_player_model_replacer_enable")
        checkbox:SizeToContents()
        checkbox:SetValue(GetConVar("cl_player_model_replacer_enable"):GetBool() and 1 or 0)
    end
})