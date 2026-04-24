-- ========== ROYZSTECU KEY SYSTEM + AUTO LOADER ==========
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Konfigurasi Firebase
local FIREBASE_URL = "https://databasekey-89582-default-rtdb.firebaseio.com/premium_keys"

-- Referensi GUI
local ScreenGui = nil
local MainFrame = nil
local KeyBox = nil
local MessageLabel = nil

-- Fungsi untuk memverifikasi key ke Firebase
local function verifyKey(key)
    if key == "" then return false end
    local url = FIREBASE_URL .. "/" .. HttpService:UrlEncode(key) .. ".json"
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if not success then
        return false, "Gagal terhubung ke server."
    end
    local data = HttpService:JSONDecode(response)
    if not data or not data.expiry then
        return false, "Key tidak ditemukan."
    end
    local expiry = tonumber(data.expiry)
    local now = os.time() * 1000
    if expiry < now then
        return false, "Key sudah kadaluarsa."
    end
    local remaining = expiry - now
    local days = math.floor(remaining / (1000 * 60 * 60 * 24))
    local hours = math.floor((remaining % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    return true, string.format("Akses diberikan. Berlaku: %d hari %d jam.", days, hours)
end

-- Fungsi untuk memuat dan menjalankan cheat utama
local function loadCheat()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/GALAXY-IP/Cheat/main/AllGame.lua"))()
    end)
    if not success then
        warn(result)
        return false
    end
    return true
end

-- Membuat GUI Keren untuk Input Key
local function createLoginGUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RoyzLoginUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 260)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundTransparency = 0.08
    MainFrame.Parent = ScreenGui
    -- Efek bayangan
    local shadow = Instance.new("UICorner")
    shadow.CornerRadius = UDim.new(0, 16)
    shadow.Parent = MainFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(Color3.fromRGB(35, 35, 55), Color3.fromRGB(18, 18, 28))
    gradient.Parent = MainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "⚡ ROYZSTECU EVIL AI ⚡"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = MainFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Masukkan Key Premium"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 220)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.Parent = MainFrame

    KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(0.8, 0, 0, 45)
    KeyBox.Position = UDim2.new(0.1, 0, 0, 100)
    KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.TextSize = 16
    KeyBox.PlaceholderText = "Masukkan key di sini"
    KeyBox.Text = ""
    KeyBox.Parent = MainFrame
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 12)

    local loginButton = Instance.new("TextButton")
    loginButton.Size = UDim2.new(0.8, 0, 0, 45)
    loginButton.Position = UDim2.new(0.1, 0, 0, 160)
    loginButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    loginButton.Text = "🔓 LOGIN"
    loginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginButton.Font = Enum.Font.GothamBold
    loginButton.TextSize = 18
    loginButton.Parent = MainFrame
    Instance.new("UICorner", loginButton).CornerRadius = UDim.new(0, 12)

    MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(0.9, 0, 0, 40)
    MessageLabel.Position = UDim2.new(0.05, 0, 0, 215)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = "Menunggu input key..."
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 12
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = MainFrame

    loginButton.MouseButton1Click:Connect(function()
        local key = KeyBox.Text
        if key == "" then
            MessageLabel.Text = "⚠️ Key tidak boleh kosong!"
            return
        end
        MessageLabel.Text = "⏳ Memverifikasi key..."
        MessageLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        loginButton.Visible = false

        local valid, msg = verifyKey(key)
        if valid then
            MessageLabel.Text = "✅ " .. msg
            MessageLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            task.wait(0.5)
            MessageLabel.Text = "🚀 Memuat cheat..."
            task.wait(0.3)
            -- Hapus GUI
            ScreenGui:Destroy()
            -- Load cheat utama
            local loaded = loadCheat()
            if not loaded then
                warn("Gagal memuat cheat!")
            end
        else
            MessageLabel.Text = "❌ " .. msg
            MessageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            loginButton.Visible = true
        end
    end)
end

-- Mulai GUI
createLoginGUI()