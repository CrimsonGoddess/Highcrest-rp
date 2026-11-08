function debugPrint(message)
    if not Config.Debug then
        return
    end
    print("^2[INFO] ^0" .. message)
end

if Config.Framework == "auto" then
    local hasQBCore = GetResourceState("qb-core") == "started"
    local hasESX = GetResourceState("es_extended") == "started"
    local hasQBox = GetResourceState("qbx_core") == "started"
    
    if hasQBox then
        Config.Framework = "qbox"
        debugPrint("Script detected resource ^2\"qbx_core\"^0, framework was set to qbox")
    elseif hasQBCore then
        Config.Framework = "qb-core"
        debugPrint("Script detected resource ^2\"qb-core\"^0, framework was set to qb-core")
    elseif hasESX then
        Config.Framework = "esx"
        debugPrint("Script detected resource ^2\"es_extended\"^0, framework was set to esx")
    else
        Config.Framework = "standalone"
        debugPrint("Script was unable to detect the framework, it was set to ^2standalone^0")
    end
end

if Config.Housing == "auto" then
    local hasQBHouses = GetResourceState("qb-houses") == "started"
    local hasLoafHousing = GetResourceState("loaf_housing") == "started"
    local hasBcsHousing = GetResourceState("bcs_housing") == "started"
    local hasNolagProperties = GetResourceState("nolag_properties") == "started"
    local hasPSHousing = GetResourceState("ps-housing") == "started"
    local hasQSHousing = GetResourceState("qs-housing") == "started"
    
    if hasQBHouses then
        Config.Housing = "default"
    elseif hasLoafHousing then
        Config.Housing = "loaf_housing"
    elseif hasBcsHousing then
        Config.Housing = "bcs_housing"
    elseif hasNolagProperties then
        Config.Housing = "nolag_properties"
    elseif hasPSHousing then
        Config.Housing = "ps-housing"
    elseif hasQSHousing then
        Config.Housing = "quasar-housing"
    else
        Config.Housing = "custom"
    end
end

if Config.Item.Inventory == "auto" then
    local hasQBInventory = GetResourceState("qb-inventory") == "started"
    local hasOxInventory = GetResourceState("ox_inventory") == "started"
    local hasQSInventory = GetResourceState("qs-inventory") == "started"
    
    if hasQBInventory then
        Config.Item.Inventory = "default"
    elseif hasOxInventory then
        Config.Item.Inventory = "ox_inventory"
    elseif hasQSInventory then
        Config.Item.Inventory = "qs-inventory"
    else
        Config.Item.Inventory = "custom"
    end
end

if Config.Phone == "auto" then
    local hasGksPhone = GetResourceState("gksphone") == "started"
    local hasHighPhone = GetResourceState("high-phone") == "started"
    local hasLbPhone = GetResourceState("lb-phone") == "started"
    local hasOkokPhone = GetResourceState("okokPhone") == "started"
    local hasQSSmartphonePro = GetResourceState("qs-smartphone-pro") == "started"
    local hasQSSmartphone = GetResourceState("qs-smartphone") == "started"
    local hasRoadPhone = GetResourceState("roadphone") == "started"
    local hasJprPhone = GetResourceState("jpr-phonesystem") == "started"
    local hasYSeries = GetResourceState("yseries") == "started"
    local hasNpwd = GetResourceState("npwd") == "started"
    
    if hasGksPhone then
        Config.Phone = "gksphone"
    elseif hasHighPhone then
        Config.Phone = "high-phone"
    elseif hasLbPhone then
        Config.Phone = "lb-phone"
    elseif hasOkokPhone then
        Config.Phone = "okokPhone"
    elseif hasQSSmartphonePro then
        Config.Phone = "qs-smartphone-pro"
    elseif hasQSSmartphone then
        Config.Phone = "qs-smartphone"
    elseif hasRoadPhone then
        Config.Phone = "roadphone"
    elseif hasYSeries then
        Config.Phone = "yseries"
    elseif hasNpwd then
        Config.Phone = "npwd"
    else
        if hasJprPhone or Config.Phone == "jpr-phone" then
            Config.Phone = "default"
        elseif GetResourceState("qb-phone") == "started" or Config.Framework == "esx" then
            Config.Phone = "default"
        else
            Config.Phone = "custom"
        end
    end
end

if Config.Framework == "standalone" then
    if Config.UseExistentValues then
        Config.UseExistentValues = false
        debugPrint("Script detected ^2\"Config.UseExistentValues\"^0 on ^2standalone^0, it was automatically ^2turned off^0")
    end
end
