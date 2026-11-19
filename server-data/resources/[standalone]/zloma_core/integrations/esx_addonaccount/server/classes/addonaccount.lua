-- ZLOMA_SQL_OWNED_ACCOUNT: retain original account names/API; never save an
-- unconditional cached absolute balance after an asynchronous money operation.
function CreateAddonAccount(name,owner,money)
    local self={name=name,owner=owner,money=tonumber(money) or 0}
    local function publish(kind,amount)
        local ok,err=pcall(function()
            TriggerClientEvent('esx_addonaccount:setMoney',-1,self.name,self.money)
            if kind then TriggerEvent('esx_addonaccount:'..kind,self.name,amount) end
        end)
        if not ok then print('[esx_addonaccount] [WARNING] Committed balance retained after notification failure: '..tostring(err)) end
    end
    function self.refresh()
        local value=ZlomaAddonAccountStorage.read(self.name,self.owner)
        if type(value)~='number' then return false end
        local changed=self.money~=value
        self.money=value
        if changed then publish() end
        return true
    end
    local function change(amount,kind)
        if type(amount)~='number' or amount~=amount or amount<=0 or amount==math.huge or amount%1~=0 then return false end
        local value=ZlomaAddonAccountStorage.change(self.name,self.owner,kind=='removeMoney' and -amount or amount,false)
        if type(value)~='number' then return false end
        self.money=value
        publish(kind,amount)
        return true
    end
    function self.addMoney(amount) return change(amount,'addMoney') end
    function self.removeMoney(amount) return change(amount,'removeMoney') end
    function self.setMoney(amount)
        local value=ZlomaAddonAccountStorage.change(self.name,self.owner,amount,true)
        if type(value)~='number' then return false end
        self.money=value
        publish('setMoney',amount)
        return true
    end
    function self.save() return self.refresh() end
    return self
end
