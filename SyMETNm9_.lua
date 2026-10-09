-- ============================================================
--  RynerHUB Loader
--  Urutan: 1) cek game  2) key system  3) auto-load game sesuai PlaceId
-- ============================================================

-- === Game yang didukung (PlaceId -> nama) ===
local GAMES = {
    [93978595733734]  = "Violence District",
    [124216119978534] = "Ride a Pet",
}

-- === Key system (project Supabase RynerHUB) ===
local KEY_ENDPOINT = "https://qnvoipytnavzgmwfqkms.supabase.co/functions/v1/script"
local GET_KEY_URL  = "https://rynerweb.vercel.app"
local UI_URL       = "https://www.ophyn.space/interface"
local LOGO         = "rbxassetid://110525773603905"
local DISCORD      = "discord.gg/wBMUk86q"
-- URL raw tempat loader ini di-host. Dipakai fitur "Auto Load Script"
-- (jalankan ulang loader setelah teleport). Kosong = fitur itu tidak aktif.
local LOADER_URL   = ""
local THEME        = "Plum"   -- kalau lib key UI tidak punya tema ini, otomatis fallback

-- === Pengambil script ===
local ENDPOINT       = "https://hbbgmyrfbtxxusznsfpu.supabase.co/functions/v1/getscript"
local CLIENT_HEADER  = "v1"
local SIGNING_SECRET = "c6d29c54402965955abe8b56f0059a68546f24273b0e4ac118abff5c2f7cb380"

local HttpService = game:GetService("HttpService")
local genv = (getgenv and getgenv()) or _G
if LOADER_URL ~= "" then genv.RynerLoaderURL = LOADER_URL end

-- Pesan untuk yang coba HttpGet / writefile lalu execute
local TROLL = "Lu ngapain anjing"

local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = 6,
        })
    end)
    warn("[RYNERHUB] " .. text)
end

-- ============================================================
-- 1) CEK GAME DULU (sebelum key UI muncul)
-- ============================================================
local PLACE_ID  = game.PlaceId
local GAME_NAME = GAMES[PLACE_ID]

if not GAME_NAME then
    notify("RynerHUB", "Game ini belum didukung.")
    return
end

-- ============================================================
-- Util
-- ============================================================
local function clean(k)
    return (tostring(k or ""):gsub("%s+", ""))
end

local function validKey(k)
    return k:match("^RYNER%-HUB%-%w+$") ~= nil
end

local hwid = "Unknown"
pcall(function()
    hwid = game:GetService("RbxAnalyticsService"):GetClientId()
end)
if type(hwid) ~= "string" or #hwid < 4 then
    notify("RynerHUB", "Gagal membaca ID perangkat.")
    return
end

local placeId = tostring(PLACE_ID)

local username = "Unknown"
pcall(function()
    username = game:GetService("Players").LocalPlayer.Name
end)

-- UserId Roblox: tidak berubah walau data Roblox dihapus (dipakai server
-- supaya key tetap valid saat HWID/ClientId berubah)
local userId = 0
pcall(function()
    userId = game:GetService("Players").LocalPlayer.UserId
end)

local function sha256hex(str)
    if crypt and crypt.hash then
        local ok, r = pcall(crypt.hash, str, "sha256")
        if ok and r then return r end
    end
    if syn and syn.crypt and syn.crypt.hash then
        local ok, r = pcall(syn.crypt.hash, str, "sha256")
        if ok and r then return r end
    end
    if sha256 then
        local ok, r = pcall(sha256, str)
        if ok and r then return r end
    end
    return nil
end

-- ============================================================
-- 2) KEY CHECK (key baru otomatis terkunci ke HWID ini)
-- ============================================================
local function checkKey(key)
    local ok, res = pcall(function()
        return game:HttpGet(KEY_ENDPOINT
            .. "?key=" .. HttpService:UrlEncode(key)
            .. "&hwid=" .. HttpService:UrlEncode(hwid)
            .. "&uid=" .. tostring(userId)
            .. "&check=1")
    end)
    return ok and type(res) == "string" and res:match("^%s*ok%s*$") ~= nil
end

-- ============================================================
-- 3) LOAD SCRIPT GAME (permintaan bertanda tangan, tidak ada
--    file yang ditulis ke disk; script hanya hidup di memori)
-- ============================================================
local function runScript(key)
    genv.Key = key

    local ts  = tostring(os.time())
    local sig = sha256hex(SIGNING_SECRET .. "|" .. placeId .. "|" .. username .. "|" .. hwid .. "|" .. ts)
    if not sig then error("Executor tidak mendukung sha256.") end

    local url = ENDPOINT
        .. "?place_id=" .. HttpService:UrlEncode(placeId)
        .. "&username=" .. HttpService:UrlEncode(username)
        .. "&hwid="     .. HttpService:UrlEncode(hwid)
        .. "&ts="       .. HttpService:UrlEncode(ts)
        .. "&sig="      .. HttpService:UrlEncode(sig)

    local ok, src = pcall(function()
        if request then
            local r = request({
                Url = url,
                Method = "GET",
                Headers = {
                    ["X-Ryner-Client"] = CLIENT_HEADER,
                    ["User-Agent"]     = "Roblox/WinInet",
                },
            })
            return r and r.Body
        end
        return game:HttpGet(url)
    end)

    if not ok or type(src) ~= "string" then
        error("Gagal mengambil script " .. GAME_NAME .. " dari server.")
    end
    if src:lower():find("lu ngapain anjing", 1, true) or #src < 100 then
        error(TROLL)
    end

    local fn, err = loadstring(src)
    if not fn then error("Script gagal dikompilasi: " .. tostring(err)) end

    -- Token sekali pakai: script game (lewat guard di bagian atasnya) hanya
    -- jalan kalau dipanggil dari loader ini. Kalau di-execute langsung dari
    -- file / hasil dump -> token tidak ada -> muncul teks TROLL.
    genv.__RYNER = {
        t = ts,
        h = sha256hex(SIGNING_SECRET .. "|auth|" .. hwid .. "|" .. ts),
    }
    local okRun, errRun = pcall(fn)
    genv.__RYNER = nil
    if not okRun then error(tostring(errRun)) end
end

local function launch(key)
    local ok, e = pcall(runScript, clean(key))
    if not ok then
        notify("RynerHUB", tostring(e))
    end
end

-- ============================================================
-- Key sudah diisi lewat getgenv().Key -> coba langsung tanpa UI
-- ============================================================
local preset = clean(genv.Key or "")
if preset ~= "" and preset ~= "RYNER-HUB-XXXXXXXXXX" and validKey(preset) and checkKey(preset) then
    launch(preset)
    return
end

-- ============================================================
-- Belum ada key valid -> UI Key System (tema plum)
-- ============================================================
local okLib, KeySystem = pcall(function()
    return loadstring(game:HttpGet(UI_URL))()
end)
if not okLib or type(KeySystem) ~= "table" then
    notify("RynerHUB", "Gagal memuat UI Key System. Coba lagi nanti.")
    return
end

local supported = {}
for id in pairs(GAMES) do
    table.insert(supported, id)
end

local function buildKeyUI(theme)
    return KeySystem.new({
        Title = "RYNERHUB",
        Description = "Key System - " .. GAME_NAME,
        Logo = LOGO,
        Theme = theme,
        Folder = "RynerHUB-KSY",

        Changelogocolor = false,
        ChangeTheme = false,

        discord_link = DISCORD,
        Discord = "true",
        Website = "false",
        Informations = "true",

        SupportedGames = supported,

        KeySystem = {
            URL = GET_KEY_URL,
            SaveKey = true,
            Key = function(k)
                k = clean(k)
                if not validKey(k) then
                    return false, "Format key salah. Contoh: RYNER-HUB-XXXXXXXXXX"
                end
                if checkKey(k) then return true end
                return false, "Key tidak valid, sudah dipakai di perangkat lain, atau sudah di-reset."
            end,
        },

        -- Key valid -> otomatis load script sesuai game
        Callback = function(key)
            launch(key)
        end,
    })
end

local okUI, ui = pcall(buildKeyUI, THEME)
if not okUI then
    okUI, ui = pcall(buildKeyUI, "Indigo") -- fallback kalau tema Plum tidak ada
end
if not okUI then
    notify("RynerHUB", "Gagal membuat UI Key System.")
    return
end

pcall(function() ui.Gui.Name = "RynerHUB" end)
