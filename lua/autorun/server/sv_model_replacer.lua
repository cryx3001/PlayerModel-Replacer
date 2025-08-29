print("Hello world!")

util.AddNetworkString("PlyModelRep_AskOriginalModels")
util.AddNetworkString("PlyModelRep_SendOriginalModel")

net.Receive("PlyModelRep_AskOriginalModels", function(len, ply)
    if not IsValid(ply) then return end

    local tblPlayerModels = {}
    for _, targetPly in ipairs(player.GetAll()) do
        if IsValid(targetPly) and targetPly:IsConnected() then
            tblPlayerModels[targetPly:SteamID64()] = targetPly:GetModel()
        end
    end

    net.Start("PlyModelRep_SendOriginalModel")
    net.WriteTable(tblPlayerModels)
    net.Send(ply)
end)