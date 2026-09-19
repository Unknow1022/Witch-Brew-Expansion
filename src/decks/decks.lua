-- Decks Atlas
SMODS.Atlas {
    key = "witch_brew_decks",
    path = "decks.png",
    px = 71,
    py = 95
}
-- Custom Decks (Barajas)

-- Helper to parse localization strings for Back objects
local function reparse_deck_entry(entry)
    if not entry then return end
    local parse_fn = loc_parse_string or function(s) return { { strings = { s }, control = {} } } end

    if entry.text then
        entry.text_parsed = {}
        for _, line in ipairs(entry.text) do
            if type(line) == 'table' then
                local sub = {}
                for _, sub_line in ipairs(line) do
                    sub[#sub + 1] = parse_fn(sub_line) or { { strings = { tostring(sub_line) }, control = {} } }
                end
                entry.text_parsed[#entry.text_parsed + 1] = sub
            else
                entry.text_parsed[#entry.text_parsed + 1] = parse_fn(line) or { { strings = { tostring(line) }, control = {} } }
            end
        end
    else
        entry.text_parsed = entry.text_parsed or {}
    end

    if entry.name then
        entry.name_parsed = {}
        local names = (type(entry.name) == 'table') and entry.name or { entry.name }
        for _, line in ipairs(names) do
            entry.name_parsed[#entry.name_parsed + 1] = parse_fn(line) or { { strings = { tostring(line) }, control = {} } }
        end
    else
        entry.name_parsed = entry.name_parsed or {}
    end
end

-- 1. Caveman Deck
SMODS.Back {
    name = 'Caveman Deck',
    key = 'cavernicola',
    atlas = 'witch_brew_decks',
    pos = { x = 0, y = 0 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Caveman Deck',
        text = {
            "Start with only {C:attention}A, 2, 3, 4, 6, 8{} of each suit in your full deck,",
            "all other starting cards are {C:attention}Stone Cards{},",
            "{C:red}-1{} Hand"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local is_combo = G.GAME and (G.GAME.cavernicola_sleeve_combo or is_sleeve_matching("cavernicola"))
                if G.playing_cards then
                    local keep_ranks = { ['Ace'] = true, ['2'] = true, ['3'] = true, ['4'] = true, ['6'] = true, ['8'] = true }
                    local silver_seal_key = (G.P_SEALS and G.P_SEALS['Witch_brew_silver'] and 'Witch_brew_silver') or 'silver'
                    for _, card in ipairs(G.playing_cards) do
                        local val = card.base and card.base.value
                        if not keep_ranks[val] then
                            card:set_ability(G.P_CENTERS.m_stone)
                            if is_combo then
                                card:set_seal(silver_seal_key, nil, true)
                            end
                        end
                    end
                end

                if not is_combo then
                    G.GAME.round_resets.hands = math.max(1, G.GAME.round_resets.hands - 1)
                    ease_hands_played(-1)
                end

                return true
            end
        }))
    end
}

-- 2. Strategist Deck
SMODS.Back {
    name = 'Strategist Deck',
    key = 'strategist',
    atlas = 'witch_brew_decks',
    pos = { x = 1, y = 0 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Strategist Deck',
        text = {
            "Start with a {C:attention}24-card deck{}",
            "{C:inactive}(Aces, Kings, Queens, Jacks, 10s, 9s){}",
            "Start with {C:attention}Magic Trick{} voucher,",
            "Start with {C:money}$0{}, {C:red}-1{} hand, {C:red}-2{} discards,",
            "Blind score targets are {C:attention}X1.2{}"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local is_combo = G.GAME and (G.GAME.strategist_sleeve_combo or is_sleeve_matching("strategist"))
                if G.playing_cards then
                    for i = #G.playing_cards, 1, -1 do
                        local card = G.playing_cards[i]
                        local val = card.base and card.base.value
                        local keep = false
                        if is_combo then
                            -- 20 cards: Ace, King, Queen, Jack, 10
                            keep = (val == 'Ace' or val == 'King' or val == 'Queen' or val == 'Jack' or val == '10')
                        else
                            -- 24 cards: Ace, King, Queen, Jack, 10, 9
                            keep = (val == 'Ace' or val == 'King' or val == 'Queen' or val == 'Jack' or val == '10' or val == '9')
                        end
                        if not keep then
                            if card.area then
                                card.area:remove_card(card)
                            end
                            card:remove()
                            table.remove(G.playing_cards, i)
                        end
                    end
                end

                G.GAME.dollars = 0

                G.GAME.round_resets.hands = math.max(1, G.GAME.round_resets.hands - 1)
                ease_hands_played(-1)

                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 2)
                ease_discard(-2)

                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers['v_magic_trick'] = true
                if is_combo then
                    G.GAME.used_vouchers['v_tarot_merchant'] = true
                    if G.GAME.shop then
                        G.GAME.shop.joker_max = (G.GAME.shop.joker_max or 2) + 1
                    end
                    G.GAME.modifiers = G.GAME.modifiers or {}
                    G.GAME.modifiers.money_per_hand = (G.GAME.modifiers.money_per_hand or 0) + 1
                end

                G.GAME.starting_params.ante_scaling = (G.GAME.starting_params.ante_scaling or 1) * 1.2

                return true
            end
        }))
    end
}

-- 3. Overseer Deck
SMODS.Back {
    name = 'Overseer Deck',
    key = 'overseer',
    atlas = 'witch_brew_decks',
    pos = { x = 2, y = 0 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Overseer Deck',
        text = {
            "Creates a random {C:spectral}Spectral card{}",
            "at the end of round {C:inactive}(except Rot and Soul){},",
            "{C:attention}Tags are always doubled{},",
            "Joker prices are {C:red}X1.5{},",
            "Start with {C:money}$2{}, {C:red}-1{} hand, {C:red}-1{} discard"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.overseer_deck = true
                local is_combo = G.GAME and (G.GAME.overseer_sleeve_combo or is_sleeve_matching("overseer"))
                if is_combo then
                    G.GAME.overseer_no_markup = true
                    G.GAME.dollars = 7
                else
                    G.GAME.dollars = 2
                    G.GAME.round_resets.hands = math.max(1, G.GAME.round_resets.hands - 1)
                    ease_hands_played(-1)
                end

                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 1)
                ease_discard(-1)

                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        local is_combo = G.GAME and (G.GAME.overseer_sleeve_combo or is_sleeve_matching("overseer"))
        if not is_combo and context.end_of_round and not context.individual and not context.repetition then
            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local forbidden = { ['c_rot'] = true, ['c_soul'] = true, ['c_Witch_brew_rot'] = true }
                        local valid_spectrals = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Spectral'] then
                            for _, center in ipairs(G.P_CENTER_POOLS['Spectral']) do
                                if not forbidden[center.key] and not string.find(center.key, 'rot', 1, true) and not string.find(center.key, 'soul', 1, true) then
                                    table.insert(valid_spectrals, center.key)
                                end
                            end
                        end
                        local chosen_key = (#valid_spectrals > 0) and pseudorandom_element(valid_spectrals, pseudoseed('overseer')) or 'c_ankh'
                        local scard = create_card('Spectral', G.consumeables, nil, nil, nil, nil, chosen_key, 'overseer')
                        scard:add_to_deck()
                        G.consumeables:emplace(scard)
                        scard:juice_up(0.5, 0.5)
                        return true
                    end
                }))
            end
        end
    end
}

-- 4. Friendly Deck (Baraja Amistosa)
SMODS.Back {
    name = 'Friendly Deck',
    key = 'friendly',
    atlas = 'witch_brew_decks',
    pos = { x = 3, y = 0 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Friendly Deck',
        text = {
            "Start run with {C:attention}2 random Negative Eternal Jokers{},",
            "{C:inactive}(Except Legendary or Secret){},",
            "{C:red}-1{} Joker slot,",
            "{C:red}-1{} Discard"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local is_combo = G.GAME and (G.GAME.friendly_sleeve_combo or is_sleeve_matching("friendly"))
                local num_jokers = is_combo and 3 or 2
                local slot_penalty = is_combo and 2 or 1

                if G.jokers and G.jokers.config then
                    G.jokers.config.card_limit = math.max(1, G.jokers.config.card_limit - slot_penalty)
                end
                if G.GAME and G.GAME.starting_params and G.GAME.starting_params.joker_slots then
                    G.GAME.starting_params.joker_slots = math.max(1, G.GAME.starting_params.joker_slots - slot_penalty)
                end

                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 1)
                ease_discard(-1)

                play_sound('foil1')
                for i = 1, num_jokers do
                    local new_joker = nil
                    local attempts = 0
                    repeat
                        attempts = attempts + 1
                        local roll = pseudorandom('friendly_roll_' .. i .. '_' .. attempts)
                        local roll_type = 'common'

                        if is_combo and roll < 0.01 then -- 1 en 100 de ser secreto
                            roll_type = 'secret'
                        elseif is_combo and roll < 0.06 then -- 1 en 20 de ser legendario (0.01 + 0.05)
                            roll_type = 'legendary'
                        elseif is_combo and roll < 0.185 then -- 1 en 8 de ser raro (0.06 + 0.125)
                            roll_type = 'rare'
                        elseif is_combo and roll < 0.435 then -- 1 en 4 de ser poco comun (0.185 + 0.25)
                            roll_type = 'uncommon'
                        elseif not is_combo and roll < 0.125 then -- 1 en 8 de ser raro
                            roll_type = 'rare'
                        elseif not is_combo and roll < 0.375 then -- 1 en 4 de ser poco comun (0.125 + 0.25)
                            roll_type = 'uncommon'
                        else -- 1 en 2 de ser comun (resto)
                            roll_type = 'common'
                        end

                        if roll_type == 'secret' then
                            local secret_keys = {
                                'esteban', 'thiago', 'black_hole_joker',
                                'squele', 'bluxdir', 'charles', 'mochi',
                                'helin', 'raytracing', 'paco', 'yairo',
                                'kyra'
                            }
                            local valid_secrets = {}
                            for _, sk in ipairs(secret_keys) do
                                local k = 'j_Witch_brew_' .. sk
                                if G.P_CENTERS and G.P_CENTERS[k] then
                                    table.insert(valid_secrets, k)
                                end
                            end
                            if #valid_secrets == 0 and G.P_CENTERS then
                                for pk, pv in pairs(G.P_CENTERS) do
                                    if pv.set == 'Joker' and (pv.is_secret or pv.rarity == 'Secret') then
                                        table.insert(valid_secrets, pk)
                                    end
                                end
                            end
                            local chosen_secret = (#valid_secrets > 0) and pseudorandom_element(valid_secrets, pseudoseed('friendly_secret_' .. i .. '_' .. attempts)) or nil
                            if chosen_secret then
                                new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_secret, 'friendly_secret')
                            else
                                new_joker = create_card('Joker', G.jokers, true, 4, nil, false, nil, 'friendly_legendary')
                            end
                        elseif roll_type == 'legendary' then
                            new_joker = create_card('Joker', G.jokers, true, 4, nil, false, nil, 'friendly_legendary')
                        elseif roll_type == 'rare' then
                            new_joker = create_card('Joker', G.jokers, false, 3, nil, false, nil, 'friendly_rare')
                        elseif roll_type == 'uncommon' then
                            new_joker = create_card('Joker', G.jokers, false, 2, nil, false, nil, 'friendly_uncommon')
                        else
                            new_joker = create_card('Joker', G.jokers, false, 1, nil, false, nil, 'friendly_common')
                        end

                        if new_joker and roll_type ~= 'secret' and is_invalid_eternal_joker(new_joker) then
                            if new_joker.area then new_joker.area:remove_card(new_joker) end
                            new_joker:remove()
                            new_joker = nil
                        end
                    until new_joker or attempts >= 20

                    if not new_joker then
                        new_joker = create_card('Joker', G.jokers, false, 1, nil, false, nil, 'friendly_fallback')
                    end

                    new_joker:set_eternal(true)
                    if new_joker.ability then new_joker.ability.eternal = true end
                    new_joker:set_edition({ negative = true }, true)
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    new_joker:juice_up(0.5, 0.5)
                end
                return true
            end
        }))
    end
}

-- 5. Alchemist Deck (Baraja Alquimista)
SMODS.Back {
    name = 'Alchemist Deck',
    key = 'alchemist',
    atlas = 'witch_brew_decks',
    pos = { x = 0, y = 1 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Alchemist Deck',
        text = {
            "Start run with the voucher",
            "{C:attention,T:v_Witch_brew_destilacion_recurrente}Recurring Distillation{}"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.alchemist_deck = true
                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers.v_Witch_brew_destilacion_recurrente = true
                G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true
                G.GAME.used_vouchers.v_destilacion_recurrente = true
                G.GAME.used_vouchers.destilacion_recurrente = true

                local is_combo = G.GAME and (G.GAME.alchemist_sleeve_combo or is_sleeve_matching("alchemist"))
                if is_combo then
                    G.GAME.alchemist_sleeve_combo = true
                    if not G.GAME.alchemist_fusion_kyra_given and G.jokers then
                        G.GAME.alchemist_fusion_kyra_given = true
                        local kyra_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_Witch_brew_kyra', 'alchemist_fusion')
                        if not kyra_card or not kyra_card.config then
                            kyra_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'kyra', 'alchemist_fusion_fallback')
                        end
                        if kyra_card then
                            kyra_card:set_eternal(true)
                            if kyra_card.ability then kyra_card.ability.eternal = true end
                            kyra_card:add_to_deck()
                            G.jokers:emplace(kyra_card)
                            kyra_card:juice_up(0.6, 0.6)
                            card_eval_status_text(kyra_card, 'extra', nil, nil, nil, { message = 'Kyra Summoned!', colour = G.C.GOLD })
                        end
                    end
                end
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        if (context.first_hand_drawn or context.setting_blind) and not context.blueprint and not context.individual and not context.repetition then
            G.GAME.used_vouchers = G.GAME.used_vouchers or {}
            G.GAME.used_vouchers.v_Witch_brew_destilacion_recurrente = true
            G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true

            local is_combo = G.GAME and (G.GAME.alchemist_sleeve_combo or is_sleeve_matching("alchemist"))
            if is_combo and not G.GAME.alchemist_fusion_kyra_given and G.jokers then
                G.GAME.alchemist_fusion_kyra_given = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local kyra_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_Witch_brew_kyra', 'alchemist_fusion')
                        if not kyra_card or not kyra_card.config then
                            kyra_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'kyra', 'alchemist_fusion_fallback')
                        end
                        if kyra_card then
                            kyra_card:set_eternal(true)
                            if kyra_card.ability then kyra_card.ability.eternal = true end
                            kyra_card:add_to_deck()
                            G.jokers:emplace(kyra_card)
                            kyra_card:juice_up(0.6, 0.6)
                            card_eval_status_text(kyra_card, 'extra', nil, nil, nil, { message = 'Kyra Summoned!', colour = G.C.GOLD })
                        end
                        return true
                    end
                }))
            end
        end
    end
}

-- Inject Deck localizations into G.localization.descriptions.Back with parsed entries
function inject_witch_brew_deck_localization()
    if not (G.localization and G.localization.descriptions) then return end
    G.localization.descriptions.Back = G.localization.descriptions.Back or {}

    local is_es = (G.SETTINGS and (G.SETTINGS.language == 'es' or G.SETTINGS.language == 'es_419' or G.SETTINGS.language == 'es_ES')) or (G.Witch_brew_SPANISH == true)

    local deck_locs = {
        cavernicola = {
            name = is_es and "Baraja Cavernícola" or "Caveman Deck",
            text = is_es and {
                "Inicia solo con {C:attention}A, 2, 3, 4, 6, 8{} de cada palo,",
                "Las demás cartas iniciales son {C:attention}Cartas de Piedra{},",
                "{C:red}-1{} Mano"
            } or {
                "Start run with only {C:attention}A, 2, 3, 4, 6, 8{} of each suit,",
                "All other starting cards become {C:attention}Stone Cards{},",
                "{C:red}-1{} Hand"
            }
        },
        strategist = {
            name = is_es and "Baraja Estratega" or "Strategist Deck",
            text = is_es and {
                "Inicia con baraja de {C:attention}24 cartas{} {C:inactive}(9 al As){},",
                "Inicia con vale {C:attention}Truco de Magia{} y {C:money}$0{},",
                "Objetivo de Ciegas es {C:attention}X1.2{},",
                "{C:red}-1{} Mano, {C:red}-2{} Descartes"
            } or {
                "Start run with a {C:attention}24-card deck{} {C:inactive}(9 through Ace){},",
                "Start with {C:attention}Magic Trick{} voucher and {C:money}$0{},",
                "Blind score targets are {C:attention}X1.2{},",
                "{C:red}-1{} Hand, {C:red}-2{} Discards"
            }
        },
        overseer = {
            name = is_es and "Baraja Supervisora" or "Overseer Deck",
            text = is_es and {
                "Crea carta {C:spectral}Espectral{} aleatoria al final de ronda",
                "{C:inactive}(excepto Podredumbre y Alma){},",
                "{C:attention}Las Etiquetas se duplican{},",
                "Precios de Jokers son {C:red}X1.5{},",
                "Inicia con {C:money}$2{}, {C:red}-1{} Mano, {C:red}-1{} Descarte"
            } or {
                "Creates a random {C:spectral}Spectral card{} at end of round",
                "{C:inactive}(except Rot and Soul){},",
                "{C:attention}Tags are always doubled{},",
                "Joker prices are {C:red}X1.5{},",
                "Start with {C:money}$2{}, {C:red}-1{} Hand, {C:red}-1{} Discard"
            }
        },
        friendly = {
            name = is_es and "Baraja Amistosa" or "Friendly Deck",
            text = is_es and {
                "Inicia con {C:attention}2{} Jokers {C:dark_edition}Negativos{} {C:attention}Eternos{} aleatorios,",
                "{C:inactive}(Cualq. rareza, no Secretos ni comodines de venta){},",
                "{C:red}-1{} Ranura de Joker, {C:red}-1{} Descarte"
            } or {
                "Start run with {C:attention}2{} random {C:dark_edition}Negative{} {C:attention}Eternal Jokers{},",
                "{C:inactive}(Any rarity, no Secret or sell/destroy Jokers){},",
                "{C:red}-1{} Joker Slot, {C:red}-1{} Discard"
            }
        },
        alchemist = {
            name = is_es and "Baraja Alquimista" or "Alchemist Deck",
            text = is_es and {
                "Inicia la partida con el vale",
                "{C:attention,T:v_Witch_brew_destilacion_recurrente}Destilación Recurrente{}"
            } or {
                "Start run with the voucher",
                "{C:attention,T:v_Witch_brew_destilacion_recurrente}Recurring Distillation{}"
            }
        }
    }

    for key, data in pairs(deck_locs) do
        local keys_to_set = {
            "b_" .. key,
            "b_Witch_brew_" .. key,
            key,
            "Witch_brew_" .. key
        }
        for _, k in ipairs(keys_to_set) do
            local entry = G.localization.descriptions.Back[k] or {}
            entry.name = data.name
            entry.text = copy_table(data.text)
            reparse_deck_entry(entry)
            G.localization.descriptions.Back[k] = entry
        end
    end

    for _, b_entry in pairs(G.localization.descriptions.Back) do
        if type(b_entry) == 'table' then
            reparse_deck_entry(b_entry)
        end
    end

    setmetatable(G.localization.descriptions.Back, nil)
end

inject_witch_brew_deck_localization()

-- Hook init_localization to ensure decks are kept synchronized and parsed
local orig_init_loc_decks = init_localization
function init_localization()
    if orig_init_loc_decks then orig_init_loc_decks() end
    inject_witch_brew_deck_localization()
end

-- Defensive hooks for Back:init and Back:generate_UI
if Back then
    if Back.init then
        local orig_back_init = Back.init
        function Back:init(selected_back)
            orig_back_init(self, selected_back)
            if self.effect and not self.effect.config then
                self.effect.config = {}
            end
        end
    end
    if Back.generate_UI then
        local orig_back_generate_ui = Back.generate_UI
        function Back:generate_UI(other, ui_scale, min_dims, challenge)
            if other and not other.config then
                other.config = {}
            end
            if self and self.effect and not self.effect.config then
                self.effect.config = {}
            end
            local ui = orig_back_generate_ui(self, other, ui_scale, min_dims, challenge)
            local name_to_check = other and other.name or self.name
            if ui and ui.nodes and name_to_check ~= 'Challenge Deck' then
                local rows = 0
                local function scan_rows(node)
                    if not node or type(node) ~= 'table' then return end
                    if node.n == G.UIT.R and node.nodes then
                        for _, c in ipairs(node.nodes) do
                            if c.n == G.UIT.T or (c.n == G.UIT.O and c.config and c.config.object) then
                                rows = rows + 1
                                return
                            end
                        end
                    end
                    if node.nodes then
                        for _, c in ipairs(node.nodes) do scan_rows(c) end
                    end
                end
                scan_rows(ui)

                local mult = (rows <= 1 and 1.30)
                    or (rows <= 2 and 1.25)
                    or (rows <= 3 and 1.20)
                    or 1.15

                local function enlarge(node)
                    if not node or type(node) ~= 'table' then return end
                    if node.config and node.config.scale then
                        node.config.scale = node.config.scale * mult
                    end
                    if node.config and node.config.object and node.config.object.scale then
                        node.config.object.scale = node.config.object.scale * mult
                        if node.config.object.update_text then
                            node.config.object:update_text(true)
                        end
                    end
                    if node.nodes then
                        for _, c in ipairs(node.nodes) do enlarge(c) end
                    end
                end
                enlarge(ui)
            end
            return ui
        end
    end
end


