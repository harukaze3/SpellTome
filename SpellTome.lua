-- SpellTome.lua

-- Main frame (512x512: AuctionFrame-Bid panel is 512 px wide)
local frame = CreateFrame("Frame", "SpellTomeFrame", UIParent)
frame:SetWidth(512)
frame:SetHeight(512)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
-- shrink hit rect less on the top so the title bar remains draggable
frame:SetHitRectInsets(15, 35, 15, 100)
frame:SetScript("OnShow", function() PlaySound("TalentScreenOpen") end)
frame:SetScript("OnHide", function() PlaySound("TalentScreenClose") end)

-- Portrait: Spellbook-Icon texture in the circular portrait slot.
local portrait = frame:CreateTexture("SpellTomePortrait", "BACKGROUND")
portrait:SetTexture("Interface\\spellbook\\spellbook-icon")
portrait:SetWidth(58)
portrait:SetHeight(60)
portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -4)

-- Frame title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("CENTER", frame, "CENTER", 6, 230)
title:SetText("Spell Tome")

-- Close button
local closeButton = CreateFrame("Button", "SpellTomeCloseButton", frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 3, -8)
closeButton:SetScript("OnClick", function()
    frame:Hide()
end)

-- ---------------------------------------------------------------------------
-- Tab system
-- ---------------------------------------------------------------------------
local tabContents  = {}
local tabButtons   = {}
local tabNames     = { "Spells", "Talents", "Level 1" }

-- One content frame per tab; anchored to the panel's inner content area
for i = 1, 3 do
    local content = CreateFrame("Frame", "SpellTomeContent"..i, frame)
    content:SetPoint("TOPLEFT",     frame, "TOPLEFT",     15,  -55)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -35,  100)
    content:Hide()
    tabContents[i] = content
end

local BuildSpellsContent
local BuildScrollContent
local ApplySearch
local ResetScrollSystem
local AddHeader
local MakeIconFrame
local BuildTab2AllSpellsContent

-- -----------------------------------------------------------------------
local spellsAllSpells = {10,17,53,78,99,116,118,133,136,139,168,172,331,348,370,403,408,465,467,543,585,587,588,589,596,604,635,686,688,687,689,693,697,702,703,710,724,755,759,772,779,845,853,879,974,980,1008,1022,1064,1079,1098,1120,1126,1130,1160,1194,1241,1243,1454,1449,1459,1463,1464,14752,1490,1495,1499,14914,1513,15407,1714,1752,1850,1856,19236,19306,19386,1943,1949,19434,19476,1966,1978,19740,19742,19750,19876,19888,19891,19975,2006,2008,20043,20233,20243,20484,2054,2060,2061,2096,2098,2120,2136,20925,21562,21849,22568,22570,23455,2362,23922,24275,25782,25894,25914,2637,26364,2643,26573,26679,27243,27576,2812,28176,2908,2912,29170,2944,2948,2973,29722,29893,30108,30283,3044,30455,30706,31633,31661,31935,32379,32546,32645,33745,33876,33878,34861,34913,34914,3599,3674,36744,403,41635,42243,42955,43987,44203,44614,45297,45517,47897,50518,50577,50582,50769,5143,5171,5176,5185,5217,5221,5277,5308,5394,5504,5570,56354,56641,5675,5676,5730,5740,5782,57763,587,58861,59881,6117,61391,6143,61846,6201,6229,6343,6353,6366,6572,6673,6770,6807,686,702,703,7235,7302,8004,8024,8033,8042,8050,8056,8070,8071,8092,8122,8181,8184,8190,8227,8232,8349,8676,8921,8936,8990,8998,9005,9484,9634,10595,11113,11366,11426,12294,12956,13165,13797,13813,16511,16689,16827,16914,17877,18220}
-- Tab 2 "Show All" spell list -- provide your own spell IDs here
local tab2AllSpells = {
12664,13854,21831,12697,12960,12677,12963,12296,16494,12867,12712,56638,12785,12328,12704,12815,20505,23695,46855,29838,12294,46866,64976,35449,46860,29725,29623,29859,56614,46924,61222,12835,12856,12879,13002,20496,12323,16492,12861,23588,20503,57522,29592,12292,29889,20501,16284,56924,23881,29776,46911,29763,60970,29801,46915,56932,46917,12818,12727,12666,50687,12753,12975,12799,29599,12764,59089,12804,12811,12803,16542,29594,50720,29792,29144,46949,57499,20243,47296,46953,58874,55918,20209,20332,20239,20261,25836,31821,20215,20235,20256,20245,53661,31823,20216,20361,31826,25829,31836,20473,31830,53553,31841,31842,54155,53576,53557,53563,63650,20266,53519,20215,20100,64205,20470,20147,53530,20488,20140,20911,20182,31849,20198,33776,20925,31852,20135,31860,53592,31935,53585,53711,53696,53595,20064,20105,25957,20337,20045,26016,20121,20375,26023,25988,35397,31838,20113,31869,20057,31872,53488,20066,31878,31881,53376,53648,35395,53503,53382,53385,12592,12840,16770,54659,29444,12577,12606,12469,44399,54646,12605,12598,18464,55340,31570,12043,12503,54354,15060,31572,31583,12042,44396,44379,31588,246,54490,44403,35581,44425,11080,54734,12341,12848,54749,12350,12353,12358,11366,12351,12873,13043,29076,31640,11368,11113,31642,12400,34296,11129,31680,44441,31658,44443,31661,44448,44472,44457,12497,16766,55094,15047,28332,29440,12571,12953,12472,12488,16758,12519,12983,11958,12490,31669,55092,28593,54787,11426,31678,31683,44545,44549,31687,44561,44571,44572,18829,18176,17814,18180,18372,18183,17805,53759,17785,18288,18219,18095,32383,32394,18223,54038,18275,47197,30064,18220,30057,32484,47200,30108,58435,48181,18693,18696,18699,47231,18704,18707,18744,18756,19028,18708,30145,18773,18710,85175,18768,23825,47247,30321,47193,35693,30248,63158,54349,30146,63123,47240,47241,17803,17792,18120,63351,17780,18127,17877,59741,18136,17918,17930,34939,17834,18130,30302,17958,17962,30296,63254,30292,54118,47260,30283,47223,47270,50796,14164,14148,14142,14161,51633,13866,14983,14169,14137,16515,14117,31209,14177,14176,31245,14195,14159,51626,58426,31383,51636,31236,58410,1329,51629,51669,51662,47205,13793,13863,13852,14166,13854,13845,13872,14251,13807,13867,13875,13789,61331,13803,13877,13964,30920,31126,61329,13750,31131,51679,35553,51674,32601,58413,51689,51690,58425,13971,14072,30893,14094,14063,14066,14278,14173,14071,13980,14080,30895,14185,14083,16511,31223,30906,31213,14183,31230,31220,51696,51701,36554,58415,51712,51513,19556,19587,35030,19551,19560,53265,19620,19573,19602,20895,19577,19592,34454,19625,34460,37587,34465,53253,34470,53264,38373,53260,56318,53270,19412,53622,19431,34484,19423,19490,34954,19456,19434,34949,19466,19420,35102,23989,24691,34476,19509,53238,19506,35111,34489,53232,53217,34490,53224,53246,53209,52788,19500,19160,24283,19388,63458,34496,19259,19503,19298,19287,56337,56344,56341,19373,19306,24297,34493,34503,19386,34499,34839,53297,53299,3674,53304,53292,53301,14791,52803,14785,14771,14767,14774,14777,14751,14769,33172,14781,14772,33202,18555,63574,33190,34910,45244,54521,63506,57472,47537,47508,47515,33206,47517,52800,47540,15012,17191,15011,27904,18535,19236,27816,15363,27790,15014,15017,15018,20711,15031,33154,15356,34860,724,33146,64129,33162,63737,56543,34861,47560,47567,47788,15336,15338,15310,15320,15317,15328,15450,15316,15407,15311,17323,15332,15487,15290,27840,33215,33371,63627,15473,33225,47570,33193,64044,34914,47582,51167,47585,16112,16108,16161,28998,29180,16116,16164,60188,16544,29065,29000,16041,30666,30674,16582,16166,51486,63372,51740,30679,51479,30706,51482,62101,51490,52456,12974,16130,17489,16293,16305,16287,51881,29080,43338,16272,49789,29193,18848,51885,30809,29086,63374,30819,17364,51527,60103,51522,30814,30823,51524,51532,51533,16229,16225,16209,29191,16217,16198,16232,55198,16240,16206,16221,29202,16188,30866,16213,30886,16190,51886,51555,30873,30869,51558,974,51561,51566,61295,16818,57814,16847,35364,16822,16840,61346,57865,16820,16913,16924,33591,5570,57851,33956,16899,33596,24858,48384,33602,48393,33607,48525,50516,33831,48514,48511,48505,16938,16862,16949,16999,16931,24866,61336,16944,16968,16975,37117,48410,16941,16979,49376,47180,57881,24894,33856,17007,34300,33957,57877,33867,48485,48495,33876,33878,48491,51269,63503,50334,17051,17066,17061,17073,17120,16835,17108,16864,48412,24972,17115,17116,24946,17124,33880,17078,34153,18562,33883,33890,48500,48545,33891,63411,51183,48438,49483,49491,55226,49393,49509,55108,48982,49480,50034,49489,49497,55136,49395,50029,49005,49504,53138,49543,49016,50371,81138,49530,55233,81164,49534,50111,49028,51456,50147,49789,55062,49664,50138,50887,49039,51473,51130,50115,49657,51109,49791,49796,55610,49538,59057,50043,49203,50385,66192,54637,51271,50152,49143,50191,50130,49184,51746,49568,55133,49562,49565,49589,49572,55237,51465,49158,51970,49628,55623,49194,49638,49599,55667,49611,56835,52143,66817,51052,50392,63560,49632,49222,49655,51161,55090,50121,49206
}
-- normalize lists: remove duplicates and sort numerically
local function normalizeNumericList(t)
    if type(t) ~= "table" then return t end
    local seen = {}
    for _, v in ipairs(t) do seen[v] = true end
    local out = {}
    for v in pairs(seen) do table.insert(out, v) end
    table.sort(out)
    -- clear and copy back
    for i = 1, #t do t[i] = nil end
    for i, v in ipairs(out) do t[i] = v end
    return t
end

normalizeNumericList(spellsAllSpells)
-- ---------------------------------------------------------------------------


local function CreateSearchBox(parent, name)
    local box = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    box:SetWidth(160)
    box:SetHeight(20)
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", 60, 5)
    box:SetAutoFocus(false)
    box:SetMaxLetters(64)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOMLEFT", box, "TOPLEFT", 0, 2)
    label:SetText("Search:")
    return box
end



-- Search boxes must be created before the collapse/expand all button
local spellSearchBox = CreateSearchBox(tabContents[1], "SpellTomeSearchBox")
local tab2SearchBox  = CreateSearchBox(tabContents[2], "SpellTomeSearchBox2")
local tab3SearchBox  = CreateSearchBox(tabContents[3], "SpellTomeSearchBox3")


-- The collapse/expand all button and its update function must be created after ss2 and the search boxes
local tab2CollapseExpandBtn, UpdateTab2CollapseExpandBtn


-- Class filter dropdown (tab 1)

local function CreateDropdown(parent, name, onClass, onAll)
    local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 16, 12)
    UIDropDownMenu_SetWidth(dd, 90)
    UIDropDownMenu_Initialize(dd, function(self)
        local info = UIDropDownMenu_CreateInfo()
        info.text    = "By Class"
        info.value   = "class"
        info.checked = (UIDropDownMenu_GetSelectedValue(self) == "class")
        info.func    = function()
            UIDropDownMenu_SetSelectedValue(self, "class")
            UIDropDownMenu_SetText(self, "By Class")
            if onClass then onClass() end
        end
        UIDropDownMenu_AddButton(info)
        info.text    = "Show All"
        info.value   = "all"
        info.checked = (UIDropDownMenu_GetSelectedValue(self) == "all")
        info.func    = function()
            UIDropDownMenu_SetSelectedValue(self, "all")
            UIDropDownMenu_SetText(self, "Show All")
            if onAll then onAll() end
        end
        UIDropDownMenu_AddButton(info)
    end)
    UIDropDownMenu_SetSelectedValue(dd, "class")
    UIDropDownMenu_SetText(dd, "By Class")
    return dd
end
-- forward declarations for dropdowns and toggle button (created after scroll systems)
local spellClassDropDown, tab2DropDown, classToggleBtn, tab2ClassToggleBtn

-- Parchment overlay shown on all tabs
local parchmentBg = frame:CreateTexture(nil, "OVERLAY")
parchmentBg:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Parchment-Horizontal")
parchmentBg:SetPoint("TOPLEFT",     frame, "TOPLEFT",     17,  -74)
parchmentBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8,   80)

local bidPanels = {}
for _, d in ipairs({
    { "Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft",  256, 256,   0,    0 },
    { "Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight", 256, 256, 256,    0 },
    { "Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft",  256, 256,   0, -256 },
    { "Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight", 159, 256, 353, -256, 0.40, 1.0, 0, 1.0 },
    { "Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Bot", 97, 256, 256, -256},
}) do
    local t = frame:CreateTexture(nil, "ARTWORK")
    t:SetTexture(d[1]) ; t:SetWidth(d[2]) ; t:SetHeight(d[3])
    t:SetPoint("TOPLEFT", frame, "TOPLEFT", d[4], d[5])
    if d[6] then t:SetTexCoord(d[6], d[7], d[8], d[9]) end
    bidPanels[#bidPanels + 1] = t
end

-- Level 1 tab: populate these tables with spell IDs by hand
local tankSpells   = { 5487, 78, 26573, 168, 58567, 1515, 6343, 687, 13163,
                        5730, 498, 53600, 688, 324, 2973, 25780, 8017, 71, 6807, 1776, 5277 }
local dpsSpells    = { 8050, 1752, 56641, 172, 8017, 403, 2973, 21084, 75,
                        34428, 768, 17364, 688, 1776, 1515, 7165, 116, 980, 5143, 8042, 2136,
                        1978, 686, 53, 8921, 1120, 585, 35509, 78, 348, 3044,
                        8092, 3599, 133, 589, 1495, 1454, 8024 }
local healerSpells = {635, 331, 5185, 2060, 774, 139, 1022, 20166, 1454, 6117, 17, 2006}
local depSpells    = {}

-- { label, spells }  (top-level categories)
local categoryDefs = {
    { "Tank Role",             tankSpells   },
    { "DPS Role",              dpsSpells    },
    { "Healer Role",           healerSpells },
    { "Requires Dependencies", depSpells    },
}

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "SpellTome" then
        if type(BuildTab2All) == "function" then pcall(BuildTab2All) end
    end
end)

-- Tab 1 class spell lists
local classSpells = {
    -- Warrior
    { 78,772,1160,1464,5308,6572,12294,20243,23922,30214,45517,50582,69304,69305 },
    -- Paladin
    { 465,635,853,879,1022,2812,8990,19740,19742,19750,19876,19888,19891,20233,20925,24275,25782,25894,25914,26573,31935,53600 },
    -- Mage
    { 116,118,168,1035,1194,1241,1266,1267,1467,1472,1481,2124,2141,2948,5143,6121,6144,7302,11113,11366,11426,31661,31766,34913,42208,42955,44614,51797,73543,74623,74624,74626,74650 },
    -- Warlock
    { 172,348,687,688,689,693,697,702,710,755,980,1098,1120,1454,1490,1714,1949,2362,5676,5782,6201,6229,6353,6366,12956,17877,18220,28176,29722,30108,30283,34143,42227,43991,47897,50577,73538 },
    -- Rogue
    { 53,408,703,1752,1943,1966,2098,6770,8676,11327,16511,26679,27576,32645,56354,60847,67380 },
    -- Hunter
    { 136,1130,1495,1499,1513,1978,2643,2973,3044,3674,13165,13797,13813,19306,19434,20043,26748,42243,56641,61846 },
    -- Priest
    { 17,139,585,588,589,596,724,1243,2006,2054,2060,2061,2096,2944,7235,8092,8122,9484,14752,14914,15407,19236,19476,21562,23455,29170,32379,32546,34861,34914,41635 },
    -- Shaman
    { 331,370,974,1064,2008,3599,5396,5675,5730,8004,8024,8033,8042,8050,8056,8073,8181,8184,8190,8232,8349,10595,26364,30706,31633,36744,45297,51730,52109,52127,69630 },
    -- Druid
    { 99,779,1079,1126,1850,2637,2908,2912,5176,5185,5217,5221,5570,6807,8070,8921,8936,8998,9005,9634,15438,16689,16827,19975,20484,21849,22568,22570,33745,33876,33878,42231,44203,50518,50769,57763,58861,59881,61391 },
    -- Death Knight (WIP)
    nil,
}

local subBearForm         = {6807, 779, 99, 1853, 16979, 772}
local subDefensiveStance  = {355, 2565, 772}
local subCatForm          = {1079, 49376, 8152, 1082}
local subComboGenerator   = {5171, 2098}
local subPaladinSeal      = {20185, 20186}
local subStealth          = {921, 6770}
local subDrainSoul        = {6201, 7728}

local depSubDefs = {
    { "Bear Form",         subBearForm        },
    { "Defensive Stance",  subDefensiveStance },
    { "Cat Form",          subCatForm         },
    { "Combo Generator",   subComboGenerator  },
    { "Paladin Seal",      subPaladinSeal     },
    { "Stealth",           subStealth         },
    { "Drain Soul",        subDrainSoul       },
}

-- Tab 2 class spell lists (user can populate these with their own IDs)
tab2ClassSpells = tab2ClassSpells or {
    -- Warrior
    {12664, 13854, 21831, 12697, 12960, 12677, 12963, 12296, 16494, 12867, 12712, 56638, 12785, 12328, 12704, 12815, 20505, 23695, 46855, 29838, 12294, 46866, 64976, 35449, 46860, 29725, 29623, 29859, 56614, 46924, 61222, 12835, 12856, 12879, 13002, 20496, 12323, 16492, 12861, 23588, 20503, 57522, 29592, 12292, 29889, 20501, 16284, 56924, 23881, 29776, 46911, 29763, 60970, 29801, 46915, 56932, 46917, 12818, 12727, 12666, 50687, 12753, 12975, 12799, 29599, 12764, 59089, 12804, 12811, 12803, 16542, 29594, 50720, 29792, 29144, 46949, 57499, 20243, 47296, 46953, 58874, 55918}, 
    -- Paladin
    {20209, 20332, 20239, 20261, 25836, 31821, 20215, 20235, 20256, 20245, 53661, 31823, 20216, 20361, 31826, 25829, 31836, 20473, 31830, 53553, 31841, 31842, 54155, 53576, 53557, 53563, 63650, 20266, 53519, 20215, 20100, 64205, 20470, 20147, 53530, 20488, 20140, 20911, 20182, 31849, 20198, 33776, 20925, 31852, 20135, 31860, 53592, 31935, 53585, 53711, 53696, 53595, 20064, 20105, 25957, 20337, 20045, 26016, 20121, 20375, 26023, 25988, 35397, 31838, 20113, 31869, 20057, 31872, 53488, 20066, 31878, 31881, 53376, 53648, 35395, 53503, 53382, 53385}, 
    -- Mage
    {12592, 12840, 16770, 54659, 29444, 12577, 12606, 12469, 44399, 54646, 12605, 12598, 18464, 55340, 31570, 12043, 12503, 54354, 15060, 31572, 31583, 12042, 44396, 44379, 31588, 246, 54490, 44403, 35581, 44425, 11080, 54734, 12341, 12848, 54749, 12350, 12353, 12358, 11366, 12351, 12873, 13043, 29076, 31640, 11368, 11113, 31642, 12400,  34296, 11129, 31680, 44441, 31658, 44443, 31661, 44448, 44472, 44457, 12497, 16766, 55094, 15047, 28332, 29440, 12571, 12953, 12472, 12488, 16758, 12519, 12983, 11958, 12490, 31669, 55092, 28593, 54787, 11426, 31678, 31683, 44545, 44549, 31687, 44561, 44571, 44572},
    -- Warlock
    {18829, 18176, 17814, 18180, 18372, 18183, 17805, 53759, 17785, 18288, 18219, 18095, 32383, 32394, 18223, 54038, 18275, 47197, 30064, 18220, 30057, 32484, 47200, 30108, 58435, 48181, 18693, 18696, 18699, 47231, 18704, 18707, 18744, 18756, 19028, 18708, 30145, 18773, 18710, 85175, 18768, 23825, 47247, 30321, 47193, 35693, 30248, 63158, 54349, 30146, 63123, 47240, 47241, 17803, 17792, 18120, 63351, 17780, 18127, 17877, 59741, 18136, 17918, 17930, 34939, 17834, 18130, 30302, 17958, 17962, 30296, 63254, 30292, 54118, 47260, 30283, 47223, 47270, 50796}, 
    -- Rogue
    {14164, 14148, 14142, 14161, 51633, 13866, 14983, 14169, 14137, 16515, 14117, 31209, 14177, 14176, 31245, 14195, 14159, 51626, 58426, 31383, 51636, 31236, 58410, 1329, 51629, 51669, 51662, 47205, 13793, 13863, 13852, 14166, 13854, 13845, 13872, 14251, 13807, 13867, 13875, 13789, 61331, 13803, 13877, 13964, 30920, 31126, 61329, 13750, 31131, 51679, 35553, 51674, 32601, 58413, 51689, 51690, 58425, 13971, 14072, 30893, 14094, 14063, 14066, 14278, 14173, 14071, 13980, 14080, 30895, 14185, 14083, 16511, 31223, 30906, 31213, 14183, 31230, 31220, 51696, 51701, 36554, 58415, 51712, 51513}, 
    -- Hunter
    {19556, 19587, 35030, 19551, 19560, 53265, 19620, 19573, 19602, 20895, 19577, 19592, 34454, 19625, 34460, 37587, 34465, 53253, 34470, 53264, 38373, 53260, 56318, 53270, 19412, 53622, 19431, 34484, 19423, 19490, 34954, 19456, 19434, 34949, 19466, 19420, 35102, 23989, 24691, 34476, 19509, 53238, 19506, 35111, 34489, 53232, 53217, 34490, 53224, 53246, 53209, 52788, 19500, 19160, 24283, 19388, 63458, 34496, 19259, 19503, 19298, 19287, 56337, 56344, 56341, 19373, 19306, 24297, 34493, 34503, 19386, 34499, 34839, 53297, 53299, 3674, 53304, 53292, 53301}, 
    -- Priest
    {14791, 52803, 14785, 14771, 14767, 14774, 14777, 14751, 14769, 33172, 14781, 14772, 33202, 18555, 63574, 33190, 34910, 45244, 54521, 63506, 57472, 47537, 47508, 47515, 33206, 47517, 52800, 47540, 15012, 17191, 15011, 27904, 18535, 19236, 27816, 15363, 27790, 15014, 15017, 15018, 20711, 15031, 33154, 15356, 34860, 724, 33146, 64129, 33162, 63737, 56543, 34861, 47560, 47567, 47788, 15336, 15338, 15310, 15320, 15317, 15328, 15450, 15316, 15407, 15311, 17323, 15332, 15487, 15290, 27840, 33215, 33371, 63627, 15473, 33225, 47570, 33193, 64044, 34914, 47582, 51167, 47585}, 
    -- Shaman
    {16112, 16108, 16161, 28998, 29180, 16116, 16164, 60188, 16544, 29065, 29000, 16041, 30666, 30674, 16582, 16166, 51486, 63372, 51740, 30679, 51479, 30706, 51482, 62101, 51490, 52456, 12974, 16130, 17489, 16293, 16305, 16287, 51881, 29080, 43338, 16272, 49789, 29193, 18848, 51885, 30809, 29086, 63374, 30819, 17364, 51527, 60103, 51522, 30814, 30823, 51524, 51532, 51533, 16229, 16225, 16209, 29191, 16217, 16198, 16232, 55198, 16240, 16206, 16221, 29202, 16188, 30866, 16213, 30886, 16190, 51886, 51555, 30873, 30869, 51558, 974, 51561, 51566, 61295}, 
    -- Druid
    {16818, 57814, 16847, 35364, 16822, 16840, 61346, 57865, 16820, 16913, 16924, 33591, 5570, 57851, 33956, 16899, 33596, 24858, 48384, 33602, 48393, 33607, 48525, 50516, 33831, 48514, 48511, 48505, 16938, 16862, 16949, 16999, 16931, 24866, 61336, 16944, 16968, 16975, 37117, 48410, 16941, 16979, 49376, 47180, 57881, 24894, 33856, 17007, 34300, 33957, 57877, 33867, 48485, 48495, 33876, 33878, 48491, 51269, 63503, 50334, 17051, 17066, 17061, 17073, 17120, 16835, 17108, 16864, 48412, 24972, 17115, 17116, 24946, 17124, 33880, 17078, 34153, 18562, 33883, 33890, 48500, 48545, 33891, 63411, 51183, 48438}, 
    -- Death Knight
    {49483, 49491, 55226, 49393, 49509, 55108, 48982, 49480, 50034, 49489, 49497, 55136, 49395, 50029, 49005, 49504, 53138, 49543, 49016, 50371, 81138, 49530, 55233, 81164, 49534, 50111, 49028, 51456, 50147, 49789, 55062, 49664, 50138, 50887, 49039, 51473, 51130, 50115, 49657, 51109, 49791, 49796, 55610, 49538, 59057, 50043, 49203, 50385, 66192, 54637, 51271, 50152, 49143, 50191, 50130, 49184, 51746, 49568, 55133, 49562, 49565, 49589, 49572, 55237, 51465, 49158, 51970, 49628, 55623, 49194, 49638, 49599, 55667, 49611, 56835, 52143, 66817, 51052, 50392, 63560, 49632, 49222, 49655, 51161, 55090, 50121, 49206}, 
}

-- Layout constants (tab 3 frame = 512 px; parchment width 487 px; scroll area = SCROLL_W px)
local ICON_SIZE     = 32
local ICON_GAP      = 5
local ICON_MARGIN   = 10
local HEADER_H      = 20
local SCROLLBAR_W   = 16
local SCROLL_W      = 487 - SCROLLBAR_W  -- parchment width (512-8-17=487 px) minus scrollbar
local ICONS_PER_ROW = math.floor((SCROLL_W - ICON_MARGIN * 2 + ICON_GAP) / (ICON_SIZE + ICON_GAP))
local ROW_H         = ICON_SIZE + ICON_GAP  -- pixel height of one icon row

local function CreateScrollSystem(tabFrame, sfTopX, sfTopY, sfBotX, sfBotY, upX, upY, downX, downY)
    local ss = {}  -- scroll-state table
    ss.targetScroll  = 0
    ss.settingScroll = false
    ss.icons         = {}  -- { frame, name } entries for search filtering

    ss.scrollFrame = CreateFrame("ScrollFrame", nil, tabFrame)
    ss.scrollFrame:SetPoint("TOPLEFT",     frame, "TOPLEFT",     sfTopX, sfTopY)
    ss.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", sfBotX, sfBotY)
    ss.scrollFrame:EnableMouseWheel(true)

    ss.scrollChild = CreateFrame("Frame", nil, ss.scrollFrame)
    ss.scrollChild:SetWidth(SCROLL_W)
    ss.scrollChild:SetHeight(1)
    ss.scrollFrame:SetScrollChild(ss.scrollChild)

    -- Up arrow
    ss.scrollUp = CreateFrame("Button", nil, tabFrame)
    ss.scrollUp:SetWidth(SCROLLBAR_W + 16) ; ss.scrollUp:SetHeight(SCROLLBAR_W + 16)
    ss.scrollUp:SetPoint("TOPLEFT", frame, "TOPLEFT", upX, upY)
    ss.scrollUp:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
    ss.scrollUp:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
    ss.scrollUp:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
    ss.scrollUp:SetScript("OnClick", function()
        ss.targetScroll = math.max(0, ss.targetScroll - ROW_H * 2)
    end)

    -- Down arrow
    ss.scrollDown = CreateFrame("Button", nil, tabFrame)
    ss.scrollDown:SetWidth(SCROLLBAR_W + 16) ; ss.scrollDown:SetHeight(SCROLLBAR_W + 16)
    ss.scrollDown:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", downX, downY)
    ss.scrollDown:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
    ss.scrollDown:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
    ss.scrollDown:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
    ss.scrollDown:SetScript("OnClick", function()
        local _, maxV = ss.scrollBar:GetMinMaxValues()
        ss.targetScroll = math.min(maxV, ss.targetScroll + ROW_H * 2)
    end)

    -- Slider
    ss.scrollBar = CreateFrame("Slider", nil, tabFrame)
    ss.scrollBar:SetOrientation("VERTICAL")
    ss.scrollBar:SetPoint("TOPLEFT",    ss.scrollUp,   "TOPLEFT",    8, -17)
    ss.scrollBar:SetPoint("BOTTOMLEFT", ss.scrollDown, "BOTTOMLEFT", 8,  17)
    ss.scrollBar:SetWidth(SCROLLBAR_W)
    ss.scrollBar:SetMinMaxValues(0, 0)
    ss.scrollBar:SetValue(0)
    ss.scrollBar:SetValueStep(ROW_H)
    ss.scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")

    ss.scrollBar:SetScript("OnValueChanged", function(self, value)
        if not ss.settingScroll then
            ss.targetScroll = value
            ss.scrollFrame:SetVerticalScroll(value)
        end
    end)
    ss.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local _, maxV = ss.scrollBar:GetMinMaxValues()
        ss.targetScroll = math.max(0, math.min(ss.targetScroll - delta * ROW_H * 3, maxV))
    end)
    ss.scrollFrame:SetScript("OnScrollRangeChanged", function(self, _, yRange)
        local maxY = math.max(0, yRange)
        ss.scrollBar:SetMinMaxValues(0, maxY)
        ss.targetScroll = math.min(ss.targetScroll, maxY)
    end)
    ss.scrollFrame:SetScript("OnUpdate", function(self, elapsed)
        local current = self:GetVerticalScroll()
        local diff    = ss.targetScroll - current
        local rate = math.min(elapsed * 5, 1)
        local newPos  = math.abs(diff) < 0.5 and ss.targetScroll or current + diff * rate
        self:SetVerticalScroll(newPos)
        ss.settingScroll = true ; ss.scrollBar:SetValue(newPos) ; ss.settingScroll = false
        if ss.UpdateSearchArrows then pcall(ss.UpdateSearchArrows, ss) end
    end)

    return ss
end


local do_ss = {}
for i = 1, 3 do
    do_ss[i] = CreateScrollSystem(tabContents[i], 17, -75, -(8 + SCROLLBAR_W), 80, 478, -67, 478, -440)
end
local ss1, ss2, ss3 = do_ss[1], do_ss[2], do_ss[3]

-- Now that ss2 and tab2SearchBox are initialized, create the collapse/expand all button for Tab 2
tab2CollapseExpandBtn = CreateFrame("Button", "SpellTomeTab2CollapseExpandBtn", tabContents[2], "UIPanelButtonTemplate")
tab2CollapseExpandBtn:SetWidth(100)
tab2CollapseExpandBtn:SetHeight(22)
tab2CollapseExpandBtn:SetPoint("TOPRIGHT", tabContents[2], "TOPRIGHT", -120, 12)
tab2CollapseExpandBtn:SetText("Collapse All")
tab2CollapseExpandBtn:Hide()

function UpdateTab2CollapseExpandBtn()
    if not ss2 or not tab2CollapseExpandBtn then return end
    ss2._collapsed = ss2._collapsed or {}
    local allExpanded = true
    for i = 1, 10 do
        if ss2._collapsed[i] then
            allExpanded = false
            break
        end
    end
    if allExpanded then
        tab2CollapseExpandBtn:SetText("Collapse All")
    else
        tab2CollapseExpandBtn:SetText("Expand All")
    end
end

tab2CollapseExpandBtn:SetScript("OnClick", function()
    local val = UIDropDownMenu_GetSelectedValue and UIDropDownMenu_GetSelectedValue(tab2DropDown)
    if val ~= "class" then return end -- Only operate if By Class is selected
    ss2._collapsed = ss2._collapsed or {}
    local anyCollapsed = false
    for i = 1, 10 do if ss2._collapsed[i] then anyCollapsed = true; break end end
    if anyCollapsed then
        for i = 1, 10 do ss2._collapsed[i] = false end
    else
        for i = 1, 10 do ss2._collapsed[i] = true end
    end
    ss2._preserveScroll = true
    BuildTab2Content("class")
    UpdateTab2CollapseExpandBtn()
end)


-- Ensure class toggle button and dropdowns exist (create now that ss1 is available)
if not classToggleBtn then
    classToggleBtn = CreateFrame("Button", "SpellTomeClassToggleButton", tabContents[1], "UIPanelButtonTemplate")
    classToggleBtn:SetWidth(100); classToggleBtn:SetHeight(22)
    classToggleBtn:SetPoint("TOPRIGHT", tabContents[1], "TOPRIGHT", -120, 12)
    classToggleBtn:SetText("Expand All")
    classToggleBtn:Hide()
end

local function UpdateClassToggleButton()
    if not ss1 or not classToggleBtn then return end
    ss1._collapsed = ss1._collapsed or {}
    local allExpanded = true
    for i = 1, 10 do
        if ss1._collapsed[i] then
            allExpanded = false
            break
        end
    end
    if allExpanded then
        classToggleBtn:SetText("Collapse All")
    else
        classToggleBtn:SetText("Expand All")
    end
end

classToggleBtn:SetScript("OnClick", function()
    ss1._collapsed = ss1._collapsed or {}
    local anyCollapsed = false
    for i = 1, 10 do if ss1._collapsed[i] then anyCollapsed = true; break end end
    if anyCollapsed then
        for i = 1, 10 do ss1._collapsed[i] = false end
    else
        for i = 1, 10 do ss1._collapsed[i] = true end
    end
    ss1._preserveScroll = true
    BuildSpellsContent("class")
    UpdateClassToggleButton()
end)

if not spellClassDropDown then
    spellClassDropDown = CreateDropdown(tabContents[1], "SpellTomeClassDropDown",
        function() BuildSpellsContent("class"); classToggleBtn:Show(); UpdateClassToggleButton() end,
        function() BuildSpellsContent("all"); classToggleBtn:Hide() end)
end



local allSpells = {
    17, 53, 71, 75, 78, 99, 100, 116, 133, 139, 168, 172,
    324, 331, 348, 355, 403, 498, 585, 589, 635, 686, 687, 688, 697,
    768, 772, 774, 779, 921, 980, 1022, 1079, 1082, 1120, 1243,
    1515, 1715, 1752, 1776, 1853, 1978,
    2006, 2060, 2098, 2136, 2565, 2973, 3044, 3599,
    5143, 5171, 5185, 5277, 5487, 5730, 6117, 6201, 6343,
    6770, 6807, 7165, 8017, 8024, 8042, 8050, 8092, 8152, 8921,
    13163, 16979, 17364, 19740, 20166, 20185, 20186, 21084,
    25780, 26573, 34428, 35509, 49376, 53600, 56641, 58567, 69305,
}

-- quick lookup sets for membership tests
local function toSet(t)
    local s = {}
    if type(t) == "table" then for _, v in ipairs(t) do s[v] = true end end
    return s
end
local allSpellsSet = toSet(allSpells)

-- Robust check whether the player already knows a spell (tries several APIs safely)
local function PlayerKnowsSpell(spellId)
    local name = GetSpellInfo(spellId)
    if not name then return false end
    -- Try IsSpellKnown by id or name (wrap in pcall in case API not present)
    local ok, res = pcall(IsSpellKnown, spellId)
    if ok and type(res) == "boolean" then return res end
    ok, res = pcall(IsSpellKnown, name)
    if ok and type(res) == "boolean" then return res end
    -- Try IsPlayerSpell (older API) by name/id
    ok, res = pcall(IsPlayerSpell, spellId)
    if ok and type(res) == "boolean" then return res end
    ok, res = pcall(IsPlayerSpell, name)
    if ok and type(res) == "boolean" then return res end
    -- Fallback: scan spellbook names (BOOKTYPE_SPELL may be nil on some clients; use default)
    for i = 1, 200 do
        local sbname = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not sbname then break end
        if sbname == name then return true end
    end
    return false
end

-- Shared icon-frame builder: ss = scroll-system table from CreateScrollSystem
local function MakeIconFrame(ss, spellId, size, x, y)
    local name, _, icon = GetSpellInfo(spellId)
    name = name or ""
    if not icon then return end
    local f = CreateFrame("Frame", nil, ss.scrollChild)
    f:SetWidth(size) ; f:SetHeight(size)
    f:SetPoint("TOPLEFT", ss.scrollChild, "TOPLEFT", x, y)
    f:EnableMouse(true)
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(icon) ; tex:SetAllPoints(f)
    -- store lowercase name and spell id on the frame for quick access in handlers
    f._st_name = string.lower(name)
    f._spellId = spellId
    f._ss = ss
    local ring = nil
    -- Only create the ring for tabs 2 and 3 (not tab 1)
    if ss ~= ss1 then
        ring = f:CreateTexture(nil, "OVERLAY")
        ring:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame")
        -- Use a larger border for tab 3 icons (70x70), otherwise use size+10
        local ringSize = (ss == ss3) and 90 or (size + 10)
        ring:SetWidth(ringSize) ; ring:SetHeight(ringSize)
        ring:SetPoint("CENTER", f, "CENTER", 20, -20)
        ring:Hide()
    end
    f:SetScript("OnEnter", function(self)
        -- In tab 3, when a search query exists, only show tooltips for matching (opaque) icons
        local s = ss
        if s == ss3 then
            local q = s.searchQuery or ""
            if q ~= "" and not string.find(self._st_name or "", q, 1, true) then
                return
            end
        end
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:SetHyperlink("spell:" .. self._spellId)
        -- For Tab 1: prefer showing that the player already knows the spell.
        if ss == ss1 then
            local known = PlayerKnowsSpell(self._spellId)
            if known then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("You know this Spell", 0.2, 1.0, 0.2)
            elseif allSpellsSet[self._spellId] then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Learned at Level 1", 1.0, 0.65, 0.25)
            end
        end
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", GameTooltip_Hide)
    ss.icons[#ss.icons + 1] = { frame = f, ring = ring, name = string.lower(name or ""), y = y, h = size }
end

function BuildTab2AllSpellsContent()
    if not ss2 then return end
    ResetScrollSystem(ss2)
    local curY = -5
    AddHeader(ss2, "All Spells", curY)
    curY = curY - HEADER_H - 5
    for i, spellId in ipairs(tab2AllSpells) do
        local _, _, icon = GetSpellInfo(spellId)
        if icon then
            MakeIconFrame(ss2, spellId, ICON_SIZE,
                ICON_MARGIN + ((i-1) % ICONS_PER_ROW) * ROW_H,
                curY - math.floor((i-1) / ICONS_PER_ROW) * ROW_H)
        end
    end
    curY = curY - math.ceil(#tab2AllSpells / ICONS_PER_ROW) * ROW_H
    ss2.scrollChild:SetHeight(math.max(1, math.abs(curY) + 15))
    ss2.scrollUp:Disable() ; ss2.scrollDown:Disable()
end

BuildTab2Content = function(mode)
    -- Only show and update the collapse/expand all button if the dropdown is set to 'class'
    local val = UIDropDownMenu_GetSelectedValue and UIDropDownMenu_GetSelectedValue(tab2DropDown)
    if mode == "class" and val == "class" then
        tab2CollapseExpandBtn:Show()
        UpdateTab2CollapseExpandBtn()
    else
        tab2CollapseExpandBtn:Hide()
    end
    if not ss2 then return end
    ResetScrollSystem(ss2)
    local curY = -5
    if mode == "class" then
        local classNames = { "Warrior", "Paladin", "Mage", "Warlock", "Rogue",
                             "Hunter", "Priest", "Shaman", "Druid", "Death Knight" }
        local COLS = 2
        local BLK_GAP = 20
        local totalW = SCROLL_W - ICON_MARGIN * 2
        local BLK_W = math.floor((totalW - BLK_GAP) / COLS)
        ss2._collapsed = ss2._collapsed or {}
        local colY = { curY, curY }
        local minY = curY
        for i, name in ipairs(classNames) do
            local col = (i - 1) % COLS
            local blockX = ICON_MARGIN + col * (BLK_W + BLK_GAP)
            local blockY = colY[col+1]
            local sbg = ss2.scrollChild:CreateTexture(nil, "BACKGROUND")
            sbg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
            sbg:SetTexCoord(0, 1, 0, 0.71875)
            sbg:SetHeight(HEADER_H)
            sbg:SetWidth(BLK_W)
            sbg:SetPoint("TOPLEFT", ss2.scrollChild, "TOPLEFT", blockX, blockY)
            sbg:SetAlpha(0.75)
            local slbl = ss2.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            slbl:SetPoint("LEFT", sbg, "LEFT", 6, 0)
            slbl:SetTextColor(1, 1, 1)
            slbl:SetText(name)
            local ind = ss2.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            ind:SetPoint("RIGHT", sbg, "RIGHT", -6, 0)
            ind:SetTextColor(1, 1, 1)
            if ss2._collapsed[i] then
                ind:SetText("+")
            else
                ind:SetText("-")
            end
            local btn = CreateFrame("Button", nil, ss2.scrollChild)
            btn:SetPoint("TOPLEFT", ss2.scrollChild, "TOPLEFT", blockX, blockY)
            btn:SetSize(BLK_W, HEADER_H)
            btn:SetScript("OnClick", function()
                ss2._preserveScroll = true
                ss2._collapsed[i] = not ss2._collapsed[i]
                BuildTab2Content("class")
                if UpdateTab2ClassToggleButton then pcall(UpdateTab2ClassToggleButton) end
            end)
            local spells = tab2ClassSpells[i]
            if spells and not ss2._collapsed[i] then
                local SUB_COLS = math.max(1, math.floor((BLK_W - ICON_MARGIN * 2 + ICON_GAP) / (ICON_SIZE + ICON_GAP)))
                local usedRows = math.ceil(#spells / SUB_COLS)
                for ii, spellId in ipairs(spells) do
                    local x = blockX + ICON_MARGIN + ((ii-1) % SUB_COLS) * (ICON_SIZE + ICON_GAP)
                    local y = blockY - HEADER_H - 5 - math.floor((ii-1) / SUB_COLS) * (ICON_SIZE + ICON_GAP)
                    local _, _, icon = GetSpellInfo(spellId)
                    if icon then
                        MakeIconFrame(ss2, spellId, ICON_SIZE, x, y)
                    end
                end
                colY[col+1] = blockY - (HEADER_H + 5 + usedRows * ROW_H + BLK_GAP)
            else
                colY[col+1] = blockY - (HEADER_H + BLK_GAP)
            end
            minY = math.min(minY, colY[1], colY[2])
        end
        curY = minY
    end
    ss2.scrollChild:SetHeight(math.max(1, math.abs(curY) + 15))
    ss2.scrollUp:Enable()
    ss2.scrollDown:Enable()
end

if not tab2DropDown then
    tab2DropDown = CreateDropdown(tabContents[2], "SpellTomeTab2DropDown",
        function()
            if BuildTab2Content then BuildTab2Content("class") end
            tab2CollapseExpandBtn:Show()
            UpdateTab2CollapseExpandBtn()
        end,
        function()
            if BuildTab2AllSpellsContent then BuildTab2AllSpellsContent() end
            tab2CollapseExpandBtn:Hide()
        end)
end
do
    local arrowFrame = CreateFrame("Frame", nil, frame)
    arrowFrame:SetAllPoints(ss3.scrollFrame)
    arrowFrame:SetFrameStrata("HIGH")
    arrowFrame:SetFrameLevel(ss3.scrollFrame:GetFrameLevel() + 10)

    local top = arrowFrame:CreateTexture(nil, "OVERLAY")
    top:SetTexture("interface\\glues\\login\\ui-backarrow")
    top:SetWidth(40); top:SetHeight(40)
    top:SetPoint("TOP", arrowFrame, "TOP", 0, -6)
    top:Hide()

    local bottom = arrowFrame:CreateTexture(nil, "OVERLAY")
    bottom:SetTexture("interface\\glues\\login\\ui-backarrow")
    bottom:SetWidth(40); bottom:SetHeight(40)
    bottom:SetPoint("BOTTOM", arrowFrame, "BOTTOM", 0, 6)
    bottom:Hide()

    ss3.topArrow = top
    ss3.bottomArrow = bottom
    ss3.UpdateSearchArrows = function(self)
        if not self.topArrow then return end
        local query = self.searchQuery or ""
        if query == "" then
            self.topArrow:Hide(); self.bottomArrow:Hide(); return
        end
        local cur = self.scrollFrame:GetVerticalScroll()
        local viewH = self.scrollFrame:GetHeight()
        local foundAbove, foundBelow = false, false
        for _, entry in ipairs(self.icons) do
            if entry.name and string.find(entry.name, query, 1, true) then
                local iconTop = -entry.y
                local iconBottom = iconTop + (entry.h or 0)
                if iconBottom < cur - 1 then foundAbove = true end
                if iconTop > cur + viewH + 1 then foundBelow = true end
            end
            if foundAbove and foundBelow then break end
        end
        if foundAbove then
            if self.topArrow.SetRotation then self.topArrow:SetRotation(-math.pi/2) end
            self.topArrow:Show()
        else
            self.topArrow:Hide()
        end
        if foundBelow then
            if self.bottomArrow.SetRotation then self.bottomArrow:SetRotation(math.pi/2) end
            self.bottomArrow:Show()
        else
            self.bottomArrow:Hide()
        end
    end
end

-- Header helper: full-width stretching header on a scrollChild
AddHeader = function(ss, text, y)
    local bg = ss.scrollChild:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
    bg:SetTexCoord(0, 1, 0, 0.71875)
    bg:SetHeight(HEADER_H)
    bg:SetPoint("TOPLEFT",  ss.scrollChild, "TOPLEFT",  0, y)
    bg:SetPoint("TOPRIGHT", ss.scrollChild, "TOPRIGHT", 0, y)
    bg:SetAlpha(0.75)
    local lbl = ss.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("CENTER", ss.scrollChild, "TOP", 0, y - HEADER_H / 2)
    lbl:SetTextColor(1, 1, 1)
    lbl:SetText(text)
end

-- Resets a scroll system and destroys its scrollChild's content
ResetScrollSystem = function(ss)
    ss.targetScroll = 0
    ss.icons        = {}
    ss.scrollFrame:SetVerticalScroll(0)
    ss.settingScroll = true ; ss.scrollBar:SetValue(0) ; ss.settingScroll = false
    for _, child in ipairs({ ss.scrollChild:GetChildren() }) do
        child:Hide() ; child:SetParent(nil)
    end
    for _, region in ipairs({ ss.scrollChild:GetRegions() }) do
        region:Hide()
    end
end

-- Filters icon frames by keyword: matches stay at full opacity with a ring, non-matches fade to 20%
ApplySearch = function(ss, text)
    local query = string.lower(text or "")
    query = string.gsub(query, "[^a-z]", "")  -- strip non-alpha characters
    ss.searchQuery = query
    for _, entry in ipairs(ss.icons) do
        if query == "" or string.find(entry.name, query, 1, true) then
            entry.frame:SetAlpha(1)
            if entry.ring then
                if query ~= "" then entry.ring:Show() else entry.ring:Hide() end
            end
        else
            entry.frame:SetAlpha(0.4)
            if entry.ring then entry.ring:Hide() end
        end
    end
    if ss.UpdateSearchArrows then
        pcall(ss.UpdateSearchArrows, ss)
    end
end

-- -----------------------------------------------------------------------
-- Tab 1: Spells content builder
-- mode "class" -- By Class (placeholder, populate as needed)
-- mode "all"   -- flat grid of spellsAllSpells
-- -----------------------------------------------------------------------
BuildSpellsContent = function(mode)
    if not ss1 then return end
    -- If a caller requested preserving scroll, capture current scroll before clearing content
    local preservedScroll
    if ss1 and ss1._preserveScroll and ss1.scrollFrame then
        preservedScroll = ss1.scrollFrame:GetVerticalScroll() or 0
    end
    ResetScrollSystem(ss1)
    local curY = -5
    if mode == "all" then
        AddHeader(ss1, "All Spells", curY)
        curY = curY - HEADER_H - 5
        for i, spellId in ipairs(spellsAllSpells) do
            local _, _, icon = GetSpellInfo(spellId)
            if icon then
                MakeIconFrame(ss1, spellId, ICON_SIZE,
                    ICON_MARGIN + ((i-1) % ICONS_PER_ROW) * ROW_H,
                    curY - math.floor((i-1) / ICONS_PER_ROW) * ROW_H)
            end
        end
        curY = curY - math.ceil(#spellsAllSpells / ICONS_PER_ROW) * ROW_H
    end
    -- "class" mode: add your class-filtered content here
    if mode == "class" then
        local classNames = { "Warrior", "Paladin", "Mage", "Warlock", "Rogue",
                             "Hunter", "Priest", "Shaman", "Druid", "Death Knight" }
        local COLS = 2
        local BLK_GAP = 20
        -- compute block width to fit two columns within scroll width
        local totalW = SCROLL_W - ICON_MARGIN * 2
        local BLK_W = math.floor((totalW - BLK_GAP) / COLS)

        ss1._collapsed = ss1._collapsed or {}

        -- maintain independent vertical cursors for each column so expanded blocks push down below ones
        local colY = { curY, curY }
        local minY = curY

        for i, name in ipairs(classNames) do
            local col = (i - 1) % COLS
            local blockX = ICON_MARGIN + col * (BLK_W + BLK_GAP)
            local blockY = colY[col+1]

            local sbg = ss1.scrollChild:CreateTexture(nil, "BACKGROUND")
            sbg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
            sbg:SetTexCoord(0, 1, 0, 0.71875)
            sbg:SetHeight(HEADER_H)
            sbg:SetWidth(BLK_W)
            sbg:SetPoint("TOPLEFT", ss1.scrollChild, "TOPLEFT", blockX, blockY)
            sbg:SetAlpha(0.75)

            local slbl = ss1.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            slbl:SetPoint("LEFT", sbg, "LEFT", 6, 0)
            slbl:SetTextColor(1, 1, 1)
            slbl:SetText(name)

            -- collapse/expand indicator on the right side of the header
            local ind = ss1.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            ind:SetPoint("RIGHT", sbg, "RIGHT", -6, 0)
            ind:SetTextColor(1, 1, 1)
            if ss1._collapsed[i] then
                ind:SetText("+")
            else
                ind:SetText("-")
            end
            -- If the class dropdown is set to "class", make the collapse/expand indicator 10px larger
            local ddVal = nil
            if spellClassDropDown and UIDropDownMenu_GetSelectedValue then
                ddVal = UIDropDownMenu_GetSelectedValue(spellClassDropDown)
            end
            if ddVal == "class" then
                -- derive font from the header label and increase size by 10
                local fontPath, fontSize, fontFlags = slbl:GetFont()
                if fontPath then
                    ind:SetFont(fontPath, (fontSize or 12) + 10, fontFlags)
                end
            end

            -- clickable header to toggle collapse
            local btn = CreateFrame("Button", nil, ss1.scrollChild)
            btn:SetPoint("TOPLEFT", ss1.scrollChild, "TOPLEFT", blockX, blockY)
            btn:SetSize(BLK_W, HEADER_H)
            btn:SetScript("OnClick", function()
                -- preserve scroll position across collapse/expand
                ss1._preserveScroll = true
                ss1._collapsed[i] = not ss1._collapsed[i]
                BuildSpellsContent("class")
                if UpdateClassToggleButton then pcall(UpdateClassToggleButton) end
            end)

            -- populate icons if not collapsed
            local spells = classSpells[i]
            if spells then
                if not ss1._collapsed[i] then
                    local SUB_COLS = math.max(1, math.floor((BLK_W - ICON_MARGIN * 2 + ICON_GAP) / (ICON_SIZE + ICON_GAP)))
                    local usedRows = math.ceil(#spells / SUB_COLS)
                    for ii, spellId in ipairs(spells) do
                        local x = blockX + ICON_MARGIN + ((ii-1) % SUB_COLS) * (ICON_SIZE + ICON_GAP)
                        local y = blockY - HEADER_H - 5 - math.floor((ii-1) / SUB_COLS) * (ICON_SIZE + ICON_GAP)
                        local _, _, icon = GetSpellInfo(spellId)
                        if icon then
                            MakeIconFrame(ss1, spellId, ICON_SIZE, x, y)
                        end
                    end
                    -- move column cursor down by block contents + gap
                    colY[col+1] = blockY - (HEADER_H + 5 + usedRows * ROW_H + BLK_GAP)
                else
                    -- collapsed: only header + gap
                    colY[col+1] = blockY - (HEADER_H + BLK_GAP)
                end
            else
                -- Death Knight WIP note
                local note = ss1.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                note:SetPoint("TOPLEFT", ss1.scrollChild, "TOPLEFT", blockX + 6, blockY - HEADER_H - 6)
                note:SetText("Work in Progress")
                colY[col+1] = blockY - (HEADER_H + BLK_GAP)
            end
            minY = math.min(minY, colY[1], colY[2])
        end
        curY = minY
    end
    ss1.scrollChild:SetHeight(math.max(1, math.abs(curY) + 15))
    -- restore preserved scroll position if requested (clamped to new range)
    if preservedScroll and ss1.scrollBar then
        local minV, maxV = ss1.scrollBar:GetMinMaxValues()
        local restore = math.max(minV or 0, math.min(maxV or 0, preservedScroll))
        ss1.targetScroll = restore
        ss1.settingScroll = true ; ss1.scrollBar:SetValue(restore) ; ss1.settingScroll = false
        ss1.scrollFrame:SetVerticalScroll(restore)
        ss1._preserveScroll = nil
    end
    if mode == "all" then
        ss1.scrollUp:Disable() ; ss1.scrollDown:Disable()
    else
        ss1.scrollUp:Enable()  ; ss1.scrollDown:Enable()
    end
end

-- -----------------------------------------------------------------------
-- Tab 3: Role/All content builder
-- -----------------------------------------------------------------------
BuildScrollContent = function(mode)
    if not ss3 then return end
    ResetScrollSystem(ss3)

    local curY = -5
    if mode == "role" then
        for _, cat in ipairs(categoryDefs) do
            AddHeader(ss3, cat[1], curY)
            curY = curY - HEADER_H - 5
            for i, spellId in ipairs(cat[2]) do
                local _, _, icon = GetSpellInfo(spellId)
                if icon then
                    MakeIconFrame(ss3, spellId, ICON_SIZE,
                        ICON_MARGIN + ((i-1) % ICONS_PER_ROW) * ROW_H,
                        curY - math.floor((i-1) / ICONS_PER_ROW) * ROW_H)
                end
            end
            curY = curY - math.ceil(#cat[2] / ICONS_PER_ROW) * ROW_H - 15

            if cat[2] == depSpells then
                local SUB_COLS  = 4
                local SUB_SIZE  = 28
                local SUB_ROW_H = SUB_SIZE + ICON_GAP
                local SUB_W     = SUB_COLS * SUB_ROW_H - ICON_GAP
                local BLK_W     = SUB_W + ICON_MARGIN * 2
                local BLK_GAP   = 3
                local BLOCK_H   = HEADER_H + SUB_ROW_H * 2 + 10

                for si, sub in ipairs(depSubDefs) do
                    local blockX, blockY
                    if si <= 6 then
                        local colIdx = (si - 1) % 3
                        local rowIdx = math.floor((si - 1) / 3)
                        blockX = ICON_MARGIN + colIdx * (BLK_W + BLK_GAP)
                        blockY = curY - rowIdx * (BLOCK_H + BLK_GAP)
                    else
                        blockX = ICON_MARGIN + (BLK_W + BLK_GAP)
                        blockY = curY - 2 * (BLOCK_H + BLK_GAP)
                    end

                    local sbg = ss3.scrollChild:CreateTexture(nil, "BACKGROUND")
                    sbg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
                    sbg:SetTexCoord(0, 1, 0, 0.71875)
                    sbg:SetHeight(HEADER_H)
                    sbg:SetWidth(BLK_W)
                    sbg:SetPoint("TOPLEFT", ss3.scrollChild, "TOPLEFT", blockX, blockY)
                    sbg:SetAlpha(0.75)

                    local slbl = ss3.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    slbl:SetPoint("CENTER", sbg, "CENTER", 0, 0)
                    slbl:SetTextColor(1, 1, 1)
                    slbl:SetText(sub[1])

                    for ii, spellId in ipairs(sub[2]) do
                        if ii > SUB_COLS * 2 then break end
                        MakeIconFrame(ss3, spellId, SUB_SIZE,
                            blockX + ICON_MARGIN + ((ii-1) % SUB_COLS) * SUB_ROW_H,
                            blockY - HEADER_H - 5 - math.floor((ii-1) / SUB_COLS) * SUB_ROW_H)
                    end
                end
                curY = curY - 3 * (BLOCK_H + BLK_GAP)
            end
        end
    else -- "all"
        AddHeader(ss3, "All Spells", curY)
        curY = curY - HEADER_H - 5
        -- use built-in allSpells list for Tab 3 "Show All"
        local list = allSpells
        for i, spellId in ipairs(list) do
            local _, _, icon = GetSpellInfo(spellId)
            if icon then
                MakeIconFrame(ss3, spellId, ICON_SIZE,
                    ICON_MARGIN + ((i-1) % ICONS_PER_ROW) * ROW_H,
                    curY - math.floor((i-1) / ICONS_PER_ROW) * ROW_H)
            end
        end
        curY = curY - math.ceil(#list / ICONS_PER_ROW) * ROW_H
    end

    ss3.scrollChild:SetHeight(math.max(1, math.abs(curY) + 15))
    if mode == "all" then
        ss3.scrollUp:Disable() ; ss3.scrollDown:Disable()
    else
        ss3.scrollUp:Enable()  ; ss3.scrollDown:Enable()
    end
end

-- Dropdown menu (UIDropDownMenu API, WoW 3.3.5a)
local viewDropDown = CreateFrame("Frame", "SpellTomeViewDropDown", tabContents[3], "UIDropDownMenuTemplate")
viewDropDown:SetPoint("TOPRIGHT", tabContents[3], "TOPRIGHT", 16, 12)
UIDropDownMenu_SetWidth(viewDropDown, 90)

UIDropDownMenu_Initialize(viewDropDown, function(self)
    local info = UIDropDownMenu_CreateInfo()

    info.text    = "By Role"
    info.value   = "role"
    info.checked = (UIDropDownMenu_GetSelectedValue(self) == "role")
    info.func    = function()
        UIDropDownMenu_SetSelectedValue(self, "role")
        UIDropDownMenu_SetText(self, "By Role")
        BuildScrollContent("role")
    end
    UIDropDownMenu_AddButton(info)

    info.text    = "Show All"
    info.value   = "all"
    info.checked = (UIDropDownMenu_GetSelectedValue(self) == "all")
    info.func    = function()
        UIDropDownMenu_SetSelectedValue(self, "all")
        UIDropDownMenu_SetText(self, "Show All")
        BuildScrollContent("all")
    end
    UIDropDownMenu_AddButton(info)
end)

-- Default selection: By Role
UIDropDownMenu_SetSelectedValue(viewDropDown, "role")
UIDropDownMenu_SetText(viewDropDown, "By Role")

-- Attach search handlers now that builders and MakeIconFrame exist
spellSearchBox:SetScript("OnTextChanged", function(self)
    local query = string.lower(self:GetText() or ""):gsub("[^a-z]", "")
    if query == "" then
        local val = UIDropDownMenu_GetSelectedValue(spellClassDropDown)
        if val == "all" then
            BuildSpellsContent("all")
        else
            BuildSpellsContent("class")
        end
        ss1.targetScroll = 0
        ss1.scrollFrame:SetVerticalScroll(0)
        return
    end
    -- Rebuild ss1 content showing only matches from full list
    ResetScrollSystem(ss1)
    local curY = -5
    local matches = {}
    for _, spellId in ipairs(spellsAllSpells) do
        local name = GetSpellInfo(spellId)
        if name then
            local nameAlpha = string.lower(name):gsub("[^a-z]", "")
            if string.find(nameAlpha, query, 1, true) then
                table.insert(matches, spellId)
            end
        end
    end
    if #matches == 0 then
        AddHeader(ss1, "No results found", curY)
        curY = curY - HEADER_H - 5
    else
        AddHeader(ss1, "All Spells", curY)
        curY = curY - HEADER_H - 5
        for i, spellId in ipairs(matches) do
            MakeIconFrame(ss1, spellId, ICON_SIZE,
                ICON_MARGIN + ((i-1) % ICONS_PER_ROW) * ROW_H,
                curY - math.floor((i-1) / ICONS_PER_ROW) * ROW_H)
        end
        curY = curY - math.ceil(#matches / ICONS_PER_ROW) * ROW_H
    end
    ss1.scrollChild:SetHeight(math.max(1, math.abs(curY) + 15))
    ss1.scrollUp:Disable() ; ss1.scrollDown:Disable()
end)
tab2SearchBox:SetScript("OnTextChanged",  function(self)
    local query = string.lower(self:GetText() or ""):gsub("[^a-z]", "")
    local val = UIDropDownMenu_GetSelectedValue(tab2DropDown)
    if query == "" then
        if val == "all" then
            if BuildTab2AllSpellsContent then BuildTab2AllSpellsContent() end
        else
            if BuildTab2Content then BuildTab2Content("class") end
        end
        ss2.targetScroll = 0
        ss2.scrollFrame:SetVerticalScroll(0)
        return
    end
    -- Rebuild ss2 content showing only matches from the correct list
    ResetScrollSystem(ss2)
    local curY = -5
    local matches = {}
    local searchList = (val == "all") and tab2AllSpells or tab2ClassSpells
    if val == "all" then
        for _, spellId in ipairs(tab2AllSpells) do
            local name = GetSpellInfo(spellId)
            if name then
                local nameAlpha = string.lower(name):gsub("[^a-z]", "")
                if string.find(nameAlpha, query, 1, true) then
                    table.insert(matches, spellId)
                end
            end
        end
    else
        for _, classList in ipairs(tab2ClassSpells) do
            for _, spellId in ipairs(classList) do
                local name = GetSpellInfo(spellId)
                if name then
                    local nameAlpha = string.lower(name):gsub("[^a-z]", "")
                    if string.find(nameAlpha, query, 1, true) then
                        table.insert(matches, spellId)
                    end
                end
            end
        end
    end
    if #matches == 0 then
        AddHeader(ss2, "No results found", curY)
        curY = curY - HEADER_H - 5
    else
        AddHeader(ss2, "All Spells", curY)
        curY = curY - HEADER_H - 5
        for i, spellId in ipairs(matches) do
            MakeIconFrame(ss2, spellId, ICON_SIZE,
                ICON_MARGIN + ((i-1) % ICONS_PER_ROW) * ROW_H,
                curY - math.floor((i-1) / ICONS_PER_ROW) * ROW_H)
        end
        curY = curY - math.ceil(#matches / ICONS_PER_ROW) * ROW_H
    end
    ss2.scrollChild:SetHeight(math.max(1, math.abs(curY) + 15))
    ss2.scrollUp:Disable() ; ss2.scrollDown:Disable()
end)
-- No-op edit to ensure file is saved after edits
tab3SearchBox:SetScript("OnTextChanged",  function(self) ApplySearch(ss3, self:GetText()) end)

-- Make search boxes lose focus on Enter or Escape
local function ClearAllSearchFocus()
    for _, box in ipairs({spellSearchBox, tab2SearchBox, tab3SearchBox}) do
        if box then box:ClearFocus() end
    end
end

spellSearchBox:SetScript("OnEnterPressed", ClearAllSearchFocus)
spellSearchBox:SetScript("OnEscapePressed", ClearAllSearchFocus)
tab2SearchBox:SetScript("OnEnterPressed", ClearAllSearchFocus)
tab2SearchBox:SetScript("OnEscapePressed", ClearAllSearchFocus)
tab3SearchBox:SetScript("OnEnterPressed", ClearAllSearchFocus)
tab3SearchBox:SetScript("OnEscapePressed", ClearAllSearchFocus)

-- Clicking on the main frame (outside edit boxes) clears focus from any search box
frame:SetScript("OnMouseDown", function(self, button)
    local mf = GetMouseFocus()
    if mf == spellSearchBox or mf == tab2SearchBox or mf == tab3SearchBox then
        return
    end
    ClearAllSearchFocus()
end)

BuildSpellsContent("class")
if classToggleBtn then classToggleBtn:Show(); UpdateClassToggleButton() end
BuildTab2Content("class")
BuildScrollContent("role")

local function SelectTab(index)
    for i = 1, 3 do
        tabContents[i]:Hide()
        if i == index then
            tabButtons[i]:Disable()
        else
            tabButtons[i]:Enable()
        end
    end
    tabContents[index]:Show()
end

-- Tab buttons: 128x64, anchored to match SpellBookFrameTabButton1/2/3 from SpellBookFrame.xml
for i = 1, 3 do
    local btn = CreateFrame("Button", "SpellTomeTabButton"..i, frame)
    btn:SetWidth(128)
    btn:SetHeight(64)
    btn:SetHitRectInsets(15, 14, 13, 15)

    if i == 1 then
        btn:SetPoint("CENTER", frame, "BOTTOMLEFT", 79, 61)
    else
        btn:SetPoint("LEFT", tabButtons[i - 1], "RIGHT", -20, 0)
    end

    btn:SetNormalTexture("Interface\\SpellBook\\UI-SpellBook-Tab-Unselected")
    btn:SetDisabledTexture("Interface\\SpellBook\\UI-SpellBook-Tab3-Selected")
    btn:SetHighlightTexture("Interface\\SpellBook\\UI-SpellbookPanel-Tab-Highlight")
    btn:GetHighlightTexture():SetBlendMode("ADD")

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", btn, "CENTER", 0, 3)
    label:SetText(tabNames[i])

    btn:SetScript("OnClick", function()
        PlaySound(836)  -- IG_ABILITY_PAGE_TURN (SoundKitConstants.lua: IG_ABILITY_PAGE_TURN = 836)
        SelectTab(i)
    end)

    tabButtons[i] = btn
end

-- Select first tab on load
SelectTab(1)

-- Register with UISpecialFrames so Escape closes the frame
tinsert(UISpecialFrames, "SpellTomeFrame")

-- Slash commands
SLASH_SPELLTOME1 = "/spelltome"
SLASH_SPELLTOME2 = "/st"
SlashCmdList["SPELLTOME"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- ---------------------------------------------------------------------------
-- Launcher button
-- ---------------------------------------------------------------------------
local launchBtn = CreateFrame("Button", "SpellTomeLaunchButton", UIParent)
launchBtn:SetWidth(64)
launchBtn:SetHeight(64)
launchBtn:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
launchBtn:SetFrameStrata("MEDIUM")
launchBtn:SetMovable(true)
launchBtn:EnableMouse(true)
launchBtn:RegisterForDrag("LeftButton")
launchBtn:SetScript("OnDragStart", launchBtn.StartMoving)
launchBtn:SetScript("OnDragStop",  launchBtn.StopMovingOrSizing)
launchBtn:SetClampedToScreen(true)

local launchIcon = launchBtn:CreateTexture(nil, "ARTWORK")
launchIcon:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon")
launchIcon:SetAllPoints(launchBtn)

local launchHighlight = launchBtn:CreateTexture(nil, "HIGHLIGHT")
launchHighlight:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon")
launchHighlight:SetAllPoints(launchBtn)
launchHighlight:SetBlendMode("ADD")
launchHighlight:SetVertexColor(1, 1, 1, 0.6)

launchBtn:SetScript("OnClick", function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end)

launchBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Spell Tome")
    GameTooltip:Show()
end)
launchBtn:SetScript("OnLeave", GameTooltip_Hide)