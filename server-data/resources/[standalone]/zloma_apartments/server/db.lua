-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Schema creation and additive migrations run here on startup; no external SQL import.
DB = { ready = false }

local schema = {
    [[CREATE TABLE IF NOT EXISTS `zloma_apartments` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `hotel_id` VARCHAR(64) NOT NULL,
        `room_number` INT NOT NULL,
        `floor` INT NOT NULL DEFAULT 1,
        `status` ENUM('free','rented','owned') DEFAULT 'free',
        `owner_id` VARCHAR(64) DEFAULT NULL,
        `roommate_id` VARCHAR(64) DEFAULT NULL,
        `rent_type` ENUM('prepaid','contract') DEFAULT NULL,
        `rent_start` DATETIME DEFAULT NULL,
        `rent_end` DATETIME DEFAULT NULL,
        `next_payment` DATETIME DEFAULT NULL,
        `daily_price` INT DEFAULT 0,
        `safe_level` INT DEFAULT 1,
        `door_security` INT DEFAULT 1,
        UNIQUE KEY `hotel_room` (`hotel_id`, `room_number`),
        KEY `owner` (`owner_id`),
        KEY `roommate` (`roommate_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
    [[CREATE TABLE IF NOT EXISTS `zloma_apartment_settings` (
        `identifier` VARCHAR(64) PRIMARY KEY,
        `doorbell_notify` TINYINT(1) DEFAULT 1,
        `payment_remind` TINYINT(1) DEFAULT 1
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
    [[CREATE TABLE IF NOT EXISTS `zloma_apartment_personal_safes` (
        `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `identifier` VARCHAR(80) NOT NULL UNIQUE,
        `pin_hash` VARCHAR(64) DEFAULT NULL,
        `capacity_level` INT NOT NULL DEFAULT 1,
        `security_level` INT NOT NULL DEFAULT 1
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
    [[CREATE TABLE IF NOT EXISTS `zloma_apartment_room_safes` (
        `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `hotel_id` VARCHAR(64) NOT NULL,
        `room_number` INT NOT NULL,
        `pin_hash` VARCHAR(64) DEFAULT NULL,
        `capacity_level` INT NOT NULL DEFAULT 1,
        `security_level` INT NOT NULL DEFAULT 1,
        UNIQUE KEY `hotel_room` (`hotel_id`, `room_number`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
    [[CREATE TABLE IF NOT EXISTS `zloma_apartment_hotels` (
        `id` VARCHAR(32) PRIMARY KEY,
        `data` LONGTEXT NOT NULL,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
    [[CREATE TABLE IF NOT EXISTS `zloma_apartment_furniture_sets` (
        `name` VARCHAR(64) PRIMARY KEY,
        `props` LONGTEXT NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
    [[CREATE TABLE IF NOT EXISTS `zloma_apartment_furniture_placements` (
        `hotel_id` VARCHAR(32) NOT NULL,
        `room_number` INT NOT NULL,
        `set_name` VARCHAR(64) NOT NULL,
        `anchor` TEXT NOT NULL,
        PRIMARY KEY (`hotel_id`, `room_number`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
    [[CREATE TABLE IF NOT EXISTS `zloma_apartment_meta` (
        `k` VARCHAR(64) PRIMARY KEY,
        `v` TEXT
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
}

-- Additive changes for previously shipped schemas. Do not rename/drop user data.
local columns = {
    { 'zloma_apartments', 'safe_level', 'INT DEFAULT 1' },
    { 'zloma_apartments', 'roommate_id', 'VARCHAR(64) DEFAULT NULL' },
    { 'zloma_apartments', 'door_security', 'INT DEFAULT 1' },
    { 'zloma_apartment_personal_safes', 'capacity_level', 'INT NOT NULL DEFAULT 1' },
    { 'zloma_apartment_personal_safes', 'security_level', 'INT NOT NULL DEFAULT 1' },
    { 'zloma_apartment_room_safes', 'capacity_level', 'INT NOT NULL DEFAULT 1' },
    { 'zloma_apartment_room_safes', 'security_level', 'INT NOT NULL DEFAULT 1' },
    { 'zloma_apartment_settings', 'doorbell_notify', 'TINYINT(1) DEFAULT 1' },
    { 'zloma_apartment_settings', 'payment_remind', 'TINYINT(1) DEFAULT 1' },
    { 'zloma_apartment_hotels', 'updated_at', 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' },
}
local indexes = {
    { 'zloma_apartments', 'PRIMARY', {'id'}, true },
    { 'zloma_apartments', 'hotel_room', {'hotel_id','room_number'}, true },
    { 'zloma_apartments', 'owner', {'owner_id'}, false },
    { 'zloma_apartments', 'roommate', {'roommate_id'}, false },
    { 'zloma_apartment_personal_safes', 'PRIMARY', {'id'}, true },
    { 'zloma_apartment_personal_safes', 'identifier', {'identifier'}, true },
    { 'zloma_apartment_room_safes', 'PRIMARY', {'id'}, true },
    { 'zloma_apartment_room_safes', 'hotel_room', {'hotel_id','room_number'}, true },
    { 'zloma_apartment_settings', 'PRIMARY', {'identifier'}, true },
    { 'zloma_apartment_hotels', 'PRIMARY', {'id'}, true },
    { 'zloma_apartment_furniture_sets', 'PRIMARY', {'name'}, true },
    { 'zloma_apartment_furniture_placements', 'PRIMARY', {'hotel_id','room_number'}, true },
    { 'zloma_apartment_meta', 'PRIMARY', {'k'}, true },
}
local function hasColumn(tbl,name)
    return MySQL.scalar.await([[SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? LIMIT 1]],{tbl,name})~=nil
end
local function indexState(wanted)
    local rows=MySQL.query.await([[SELECT INDEX_NAME AS index_name, NON_UNIQUE AS non_unique,
        SEQ_IN_INDEX AS sequence_number, COLUMN_NAME AS column_name FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?]],{wanted[1]}) or {}
    local groups={}
    for _,row in ipairs(rows)do
        local entry=groups[row.index_name] or {columns={},unique=tonumber(row.non_unique)==0}
        entry.columns[tonumber(row.sequence_number)]=row.column_name;groups[row.index_name]=entry
    end
    for _,entry in pairs(groups)do
        local same=#entry.columns==#wanted[3] and (not wanted[4] or entry.unique)
        for i,name in ipairs(wanted[3])do if entry.columns[i]~=name then same=false end end
        if same then return true end
    end
    return false,groups[wanted[2]]~=nil
end
local function initialize()
    -- CREATE IF NOT EXISTS and information_schema checks work on both MySQL and
    -- MariaDB; no vendor-only ADD COLUMN IF NOT EXISTS, JSON type or collation.
    for _,query in ipairs(schema)do MySQL.query.await(query)end
    for _,c in ipairs(columns)do
        if not hasColumn(c[1],c[2])then
            local ok,err=pcall(MySQL.query.await,('ALTER TABLE `%s` ADD COLUMN `%s` %s'):format(c[1],c[2],c[3]))
            -- Another server may have completed the same additive migration.
            if not ok and not hasColumn(c[1],c[2])then error(err,0)end
        end
    end
    -- Reject unknown/incomplete old layouts instead of accepting ready=true and
    -- failing later during an inventory/payment operation.
    for _,query in ipairs(schema)do
        local tbl=query:match('CREATE TABLE IF NOT EXISTS `([%w_]+)`')
        for line in query:gmatch('[^\r\n]+')do
            local name=line:match('^%s*`([%w_]+)`%s+')
            if name and not hasColumn(tbl,name)then
                error(('Unsupported existing schema: %s.%s is missing; no rows were rewritten.'):format(tbl,name),0)
            end
        end
        local engine=MySQL.scalar.await([[SELECT ENGINE FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?]],{tbl})
        if not engine or tostring(engine):lower()~='innodb'then
            error(('Table %s must use InnoDB; automatic engine conversion is intentionally not performed.'):format(tbl),0)
        end
    end
    for _,wanted in ipairs(indexes)do
        local exists,conflict=indexState(wanted)
        if not exists then
            if conflict then error(('Incompatible index %s.%s; review existing index without dropping data.'):format(wanted[1],wanted[2]),0)end
            local names={};for i,name in ipairs(wanted[3])do names[i]='`'..name..'`'end
            local kind=wanted[2]=='PRIMARY'and 'PRIMARY KEY' or ((wanted[4]and 'UNIQUE KEY 'or 'KEY ')..'`'..wanted[2]..'`')
            local ok,err=pcall(MySQL.query.await,('ALTER TABLE `%s` ADD %s (%s)'):format(wanted[1],kind,table.concat(names,',')))
            if not ok and not indexState(wanted)then error(err,0)end
        end
    end
    -- Historical released rows carried no active booking. Occupied rows and
    -- every safe/settings/furniture row are preserved.
    MySQL.update.await("DELETE FROM zloma_apartments WHERE status = 'free'")
    MySQL.insert.await([[INSERT INTO zloma_apartment_meta (k,v) VALUES ('schema_version','2')
        ON DUPLICATE KEY UPDATE v=VALUES(v)]])
end
function DB.init()
    DB.ready=false
    local ok,err=pcall(initialize)
    if not ok then
        error('[zloma_apartments] Database setup failed. Check schema compatibility and CREATE/ALTER/INDEX/SELECT/INSERT/UPDATE/DELETE permissions. '..tostring(err),0)
    end
    DB.ready=true
    return true
end

function DB.meta(key)
    return MySQL.scalar.await('SELECT v FROM zloma_apartment_meta WHERE k = ?', { key })
end

function DB.setMeta(key, value)
    MySQL.insert.await('INSERT INTO zloma_apartment_meta (k, v) VALUES (?, ?) ON DUPLICATE KEY UPDATE v = VALUES(v)', { key, value })
end

-- Bookings -------------------------------------------------------------------

function DB.loadBookings()
    return MySQL.query.await([[SELECT hotel_id, room_number, status, owner_id, roommate_id, rent_type, daily_price, safe_level, door_security,
        UNIX_TIMESTAMP(rent_start) AS rent_start, UNIX_TIMESTAMP(rent_end) AS rent_end, UNIX_TIMESTAMP(next_payment) AS next_payment
        FROM zloma_apartments WHERE status != 'free']]) or {}
end

function DB.insertBooking(b)
    return MySQL.insert.await([[INSERT INTO zloma_apartments
        (hotel_id, room_number, floor, status, owner_id, roommate_id, rent_type, rent_start, rent_end, next_payment, daily_price, safe_level)
        VALUES (?, ?, ?, ?, ?, NULL, ?, FROM_UNIXTIME(?), FROM_UNIXTIME(?), FROM_UNIXTIME(?), ?, ?)]],
        { b.hotel, b.room, b.floor, b.status, b.owner, b.rentType, b.rentStart, b.rentEnd, b.nextPayment, b.dailyPrice, b.safeLevel })
end

function DB.deleteBooking(hotel, room)
    return MySQL.update.await('DELETE FROM zloma_apartments WHERE hotel_id = ? AND room_number = ?', { hotel, room })
end

function DB.setRoommate(hotel, room, identifier)
    return MySQL.update.await('UPDATE zloma_apartments SET roommate_id = ? WHERE hotel_id = ? AND room_number = ?', { identifier, hotel, room })
end

function DB.setSafeLevel(hotel, room, level)
    return MySQL.update.await('UPDATE zloma_apartments SET safe_level = ? WHERE hotel_id = ? AND room_number = ?', { level, hotel, room })
end

function DB.setNextPayment(hotel, room, timestamp)
    return MySQL.update.await('UPDATE zloma_apartments SET next_payment = FROM_UNIXTIME(?) WHERE hotel_id = ? AND room_number = ?', { timestamp, hotel, room })
end

-- One-time rename for servers that ran the private build (hotel id main_hotel).
function DB.renameHotel(from, to)
    local taken = MySQL.scalar.await('SELECT 1 FROM zloma_apartments WHERE hotel_id = ? LIMIT 1', { to })
    if taken then return 0 end
    return MySQL.update.await('UPDATE zloma_apartments SET hotel_id = ? WHERE hotel_id = ?', { to, from }) or 0
end

-- Settings -------------------------------------------------------------------

function DB.settings(identifier)
    local row = MySQL.single.await('SELECT doorbell_notify, payment_remind FROM zloma_apartment_settings WHERE identifier = ?', { identifier })
    if not row then return { doorbell_notify = true, payment_remind = true } end
    return { doorbell_notify = row.doorbell_notify == 1 or row.doorbell_notify == true, payment_remind = row.payment_remind == 1 or row.payment_remind == true }
end

function DB.saveSettings(identifier, s)
    return MySQL.insert.await([[INSERT INTO zloma_apartment_settings (identifier, doorbell_notify, payment_remind) VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE doorbell_notify = VALUES(doorbell_notify), payment_remind = VALUES(payment_remind)]],
        { identifier, s.doorbell_notify and 1 or 0, s.payment_remind and 1 or 0 })
end

-- Personal safes -------------------------------------------------------------

function DB.safe(identifier)
    MySQL.insert.await('INSERT IGNORE INTO zloma_apartment_personal_safes (identifier) VALUES (?)', { identifier })
    return MySQL.single.await('SELECT id, identifier, pin_hash, capacity_level, security_level FROM zloma_apartment_personal_safes WHERE identifier = ?', { identifier })
end

function DB.setSafeCapacity(id, level)
    return MySQL.update.await('UPDATE zloma_apartment_personal_safes SET capacity_level = ? WHERE id = ?', { level, id })
end

local PIN_SALT = ':apartment-pin:'
function DB.setPin(id, pin)
    return MySQL.update.await('UPDATE zloma_apartment_personal_safes SET pin_hash = SHA2(CONCAT(identifier, ?, ?), 256) WHERE id = ?', { PIN_SALT, pin, id })
end

function DB.pinHash(identifier, pin)
    return MySQL.scalar.await('SELECT SHA2(CONCAT(?, ?, ?), 256)', { identifier, PIN_SALT, pin })
end

function DB.setSafeSecurity(id, level)
    return MySQL.update.await('UPDATE zloma_apartment_personal_safes SET security_level = ? WHERE id = ?', { level, id })
end

function DB.setDoorSecurity(hotel, room, level)
    return MySQL.update.await('UPDATE zloma_apartments SET door_security = ? WHERE hotel_id = ? AND room_number = ?', { level, hotel, room })
end

-- Room safes (Config.Safe.Mode = 'apartment') -----------------------------------
-- The PIN hash is keyed by the room, so a new tenant's PIN is independent.

local function roomKey(hotel, room) return ('room:%s:%d'):format(hotel, room) end

function DB.roomSafe(hotel, room)
    MySQL.insert.await('INSERT IGNORE INTO zloma_apartment_room_safes (hotel_id, room_number) VALUES (?, ?)', { hotel, room })
    return MySQL.single.await('SELECT id, hotel_id, room_number, pin_hash, capacity_level, security_level FROM zloma_apartment_room_safes WHERE hotel_id = ? AND room_number = ?', { hotel, room })
end

function DB.setRoomSafePin(id, hotel, room, pin)
    return MySQL.update.await('UPDATE zloma_apartment_room_safes SET pin_hash = SHA2(CONCAT(?, ?, ?), 256) WHERE id = ?', { roomKey(hotel, room), PIN_SALT, pin, id })
end

function DB.roomPinHash(hotel, room, pin)
    return MySQL.scalar.await('SELECT SHA2(CONCAT(?, ?, ?), 256)', { roomKey(hotel, room), PIN_SALT, pin })
end

function DB.clearRoomSafePin(hotel, room)
    return MySQL.update.await('UPDATE zloma_apartment_room_safes SET pin_hash = NULL WHERE hotel_id = ? AND room_number = ?', { hotel, room })
end

function DB.setRoomSafeCapacity(id, level)
    return MySQL.update.await('UPDATE zloma_apartment_room_safes SET capacity_level = ? WHERE id = ?', { level, id })
end

function DB.setRoomSafeSecurity(id, level)
    return MySQL.update.await('UPDATE zloma_apartment_room_safes SET security_level = ? WHERE id = ?', { level, id })
end

-- Buildings ------------------------------------------------------------------

function DB.loadHotels()
    return MySQL.query.await('SELECT id, data FROM zloma_apartment_hotels') or {}
end

function DB.saveHotel(id, data)
    return MySQL.insert.await('INSERT INTO zloma_apartment_hotels (id, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data)', { id, data })
end

function DB.deleteHotelOverride(id)
    return MySQL.update.await('DELETE FROM zloma_apartment_hotels WHERE id = ?', { id })
end

function DB.deleteHotel(id)
    MySQL.update.await('DELETE FROM zloma_apartment_furniture_placements WHERE hotel_id = ?', { id })
    return MySQL.update.await('DELETE FROM zloma_apartment_hotels WHERE id = ?', { id })
end

-- Furniture ------------------------------------------------------------------

function DB.loadFurniture()
    return MySQL.query.await('SELECT name, props FROM zloma_apartment_furniture_sets') or {},
        MySQL.query.await('SELECT hotel_id, room_number, set_name, anchor FROM zloma_apartment_furniture_placements') or {}
end

function DB.saveSet(name, props)
    return MySQL.insert.await('INSERT INTO zloma_apartment_furniture_sets (name, props) VALUES (?, ?) ON DUPLICATE KEY UPDATE props = VALUES(props)', { name, props })
end

function DB.deleteSet(name)
    return MySQL.update.await('DELETE FROM zloma_apartment_furniture_sets WHERE name = ?', { name })
end

function DB.savePlacements(rows)
    if #rows == 0 then return true end
    local queries = {}
    for i, r in ipairs(rows) do
        queries[i] = { query = [[INSERT INTO zloma_apartment_furniture_placements (hotel_id, room_number, set_name, anchor) VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE set_name = VALUES(set_name), anchor = VALUES(anchor)]], values = { r.hotel, r.room, r.set, r.anchor } }
    end
    return MySQL.transaction.await(queries)
end

function DB.deletePlacement(hotel, room)
    return MySQL.update.await('DELETE FROM zloma_apartment_furniture_placements WHERE hotel_id = ? AND room_number = ?', { hotel, room })
end
