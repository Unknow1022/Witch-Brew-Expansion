--[[
    Witch Brew Expansion
    CardSleeves Mod Compatibility
    Adds sleeve versions of all 4 custom decks with unique combo fusion effects:
    - Friendly Sleeve (with Friendly Deck: spawns 3 Negative Eternals with up to 1 Legendary, -2 joker slots, -1 discard)
    - Caveman Sleeve (with Caveman Deck: stone cards get Silver Seals, +3 Mult and +20 Chips on score, +1 Hand)
    - Strategist Sleeve (with Strategist Deck: 20-card deck, Magic Trick + Tarot Merchant, +1 shop slot, +$1 per played hand)
    - Overseer Sleeve (with Overseer Deck: 2 Spectrals at end of round, tripled tags, removes Joker markup, +$5, +1 Hand)
--]]

-- Atlases for Custom Sleeves
SMODS.Atlas {
    key = "witch_brew_sleeves",
    path = "sleeves.png",
    px = 73,
    py = 95
}
-- Helper to parse localization strings for Sleeve objects
local function reparse_sleeve_entry(entry)
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

-- Check if current selected deck matches target key
local function is_deck_matching(target_key)
    if not target_key then return false end
    local ok, res = pcall(function()
        if CardSleeves and CardSleeves.Sleeve and CardSleeves.Sleeve.get_current_deck_key then
            local current = CardSleeves.Sleeve.get_current_deck_key() or ""
            current = tostring(current)
            if current == target_key
                or current == "b_" .. target_key
                or current == "b_Witch_brew_" .. target_key
                or string.find(current, target_key, 1, true) ~= nil then
                return true
            end
        end
        if CardSleeves and CardSleeves.current_deck then
            local current = tostring(CardSleeves.current_deck)
            if string.find(current, target_key, 1, true) ~= nil then
                return true
            end
        end
        if G and G.GAME then
            local b = G.GAME.selected_back or G.GAME.viewed_back
            if b then
                local k = b.name or (b.effect and b.effect.center and b.effect.center.key) or b.key or ""
                k = tostring(k)
                if k == target_key or string.find(k, target_key, 1, true) ~= nil then
                    return true
                end
            end
        end
        if G and G.deck and G.deck.name then
            local d = tostring(G.deck.name)
            if string.find(d, target_key, 1, true) ~= nil then
                return true
            end
        end
        return false
    end)
    return ok and res or false
end

-- Inject localization for Sleeves into G.localization.descriptions.Sleeve
local function inject_sleeve_localization()
    if not (G.localization and G.localization.descriptions) then return end
    G.localization.descriptions.Sleeve = G.localization.descriptions.Sleeve or {}

    local is_es = (G.SETTINGS and (G.SETTINGS.language == 'es' or G.SETTINGS.language == 'es_419' or G.SETTINGS.language == 'es_ES')) or (G.Witch_brew_SPANISH == true)

    local sleeve_locs = {
        -- 1. Friendly Sleeve
        friendly = {
            name = is_es and "Funda Amistosa" or "Friendly Sleeve",
            text = is_es and {
                "Inicia con {C:attention}1{} Joker {C:dark_edition}Negativo{} {C:attention}Eterno{} aleatorio,",
                "{C:inactive}(Cualq. rareza, no Secretos ni comodines de venta){},",
                "{C:red}-1{} Descarte"
            } or {
                "Start run with {C:attention}1{} random {C:dark_edition}Negative{} {C:attention}Eternal Joker{},",
                "{C:inactive}(Any rarity, no Secret or sell/destroy Jokers){},",
                "{C:red}-1{} Discard"
            }
        },
        friendly_alt = {
            name = is_es and "Funda Amistosa (Fusión)" or "Friendly Sleeve (Fusion)",
            text = is_es and {
                "{C:attention}Fusión Amistosa{}:",
                "Genera {C:attention}3{} Jokers {C:dark_edition}Negativos{} {C:attention}Eternos{},",
                "{C:inactive}(Cualq. rareza, chance de Legendario y Secreto){},",
                "{C:red}-2{} Ranuras de Joker, {C:red}-1{} Descarte"
            } or {
                "{C:attention}Friendly Fusion{}:",
                "Spawns {C:attention}3{} {C:dark_edition}Negative{} {C:attention}Eternal Jokers{},",
                "{C:inactive}(Any rarity, chance of Legendary or Secret){},",
                "{C:red}-2{} Joker Slots, {C:red}-1{} Discard"
            }
        },

        -- 2. Caveman Sleeve
        cavernicola = {
            name = is_es and "Funda Cavernícola" or "Caveman Sleeve",
            text = is_es and {
                "Todas las {C:attention}Figuras{} iniciales {C:inactive}(J, Q, K){}",
                "se convierten en {C:attention}Cartas de Piedra{},",
                "{C:blue}+1{} Mano"
            } or {
                "All starting {C:attention}Face Cards{} {C:inactive}(J, Q, K){}",
                "become {C:attention}Stone Cards{},",
                "{C:blue}+1{} Hand"
            }
        },
        cavernicola_alt = {
            name = is_es and "Funda Cavernícola (Fusión)" or "Caveman Sleeve (Fusion)",
            text = is_es and {
                "{C:attention}Fusión Prehistórica{}:",
                "Inicia solo con {C:attention}Ases, 2s y 3s{} (4 de c/u),",
                "Las demás cartas iniciales son {C:attention}Cartas de Piedra{},",
                "Las Cartas de Piedra otorgan {C:mult}+1{} Mult al puntuar,",
                "{C:blue}+1{} Mano"
            } or {
                "{C:attention}Prehistoric Fusion{}:",
                "Start with only {C:attention}Aces, 2s, and 3s{} (4 of each),",
                "All other starting cards become {C:attention}Stone Cards{},",
                "Stone Cards give {C:mult}+1{} Mult when scored,",
                "{C:blue}+1{} Hand"
            }
        },

        -- 3. Strategist Sleeve
        strategist = {
            name = is_es and "Funda Estratega" or "Strategist Sleeve",
            text = is_es and {
                "Inicia con el vale {C:attention}Truco de Magia{},",
                "Inicia con {C:money}$5{},",
                "{C:red}-1{} Descarte"
            } or {
                "Start with {C:attention}Magic Trick{} voucher,",
                "Start with {C:money}$5{},",
                "{C:red}-1{} Discard"
            }
        },
        strategist_alt = {
            name = is_es and "Funda Estratega (Fusión)" or "Strategist Sleeve (Fusion)",
            text = is_es and {
                "{C:attention}Fusión Estratégica{}:",
                "Mazo reducido a {C:attention}20 cartas{} {C:inactive}(10 al As){},",
                "Inicia con vales {C:attention}Truco de Magia{} y {C:attention}Mercader de Tarot{},",
                "{C:attention}+1{} Carta en tienda, manos jugadas otorgan {C:money}+$1{}"
            } or {
                "{C:attention}Grandmaster Fusion{}:",
                "Deck reduced to {C:attention}20 cards{} {C:inactive}(10 through Ace){},",
                "Start with {C:attention}Magic Trick{} and {C:attention}Tarot Merchant{},",
                "{C:attention}+1{} Shop card slot, played hands give {C:money}+$1{}"
            }
        },

        -- 4. Overseer Sleeve
        overseer = {
            name = is_es and "Funda Supervisora" or "Overseer Sleeve",
            text = is_es and {
                "{C:attention}Las Etiquetas se duplican{},",
                "Derrotar Ciega Jefe crea carta {C:spectral}Espectral{} aleatoria"
            } or {
                "{C:attention}Tags are always doubled{},",
                "Defeating Boss Blind creates random {C:spectral}Spectral card{}"
            }
        },
        overseer_alt = {
            name = is_es and "Funda Supervisora (Fusión)" or "Overseer Sleeve (Fusion)",
            text = is_es and {
                "{C:attention}Fusión Supervisora{}:",
                "Crea {C:attention}2{} cartas {C:spectral}Espectrales{} aleatorias al final de ronda,",
                "Etiquetas se {C:attention}triplican (X3){},",
                "Sin sobrecoste de Jokers, inicia con {C:money}$7{} y {C:blue}+1{} Mano"
            } or {
                "{C:attention}Omniscient Fusion{}:",
                "Creates {C:attention}2{} random {C:spectral}Spectral cards{} at end of round,",
                "Tags are {C:attention}tripled (X3){},",
                "No Joker price markup penalty, start with {C:money}$7{} and {C:blue}+1{} Hand"
            }
        },
        -- 5. Alchemist Sleeve
        alchemist = {
            name = is_es and "Funda Alquimista" or "Alchemist Sleeve",
            text = is_es and {
                "Crea {C:attention}1 Poción{} aleatoria",
                "al iniciar cada ronda",
                "{C:inactive}(Debe tener espacio de consumibles){}"
            } or {
                "Creates {C:attention}1 random Potion{}",
                "at start of each round",
                "{C:inactive}(Must have consumable space){}"
            }
        },
        alchemist_alt = {
            name = is_es and "Funda Alquimista (Fusión)" or "Alchemist Sleeve (Fusion)",
            text = is_es and {
                "{C:attention}Fusión Alquimista{}:",
                "Al iniciar la partida, invoca a",
                "{C:attention}Kyra{} {C:dark_edition}(Eterna){},",
                "y otorga el vale {C:attention}Destilación Recurrente{} cada ronda",
                "{C:inactive}(Las pociones no ocupan ranuras de consumibles){}"
            } or {
                "{C:attention}Alchemical Fusion{}:",
                "At start of run, summons",
                "{C:attention}Kyra{} {C:dark_edition}(Eternal){},",
                "and grants {C:attention}Recurring Distillation{} voucher each round",
                "{C:inactive}(Potions take 0 consumable slots){}"
            }
        }
    }

    for key, data in pairs(sleeve_locs) do
        -- Register with multiple possible prefix patterns so SMODS/CardSleeves always finds it
        local keys_to_set = {
            "sleeve_" .. key,
            "sleeve_Witch_brew_" .. key,
            key,
            "Witch_brew_" .. key
        }
        for _, k in ipairs(keys_to_set) do
            local entry = G.localization.descriptions.Sleeve[k] or {}
            entry.name = data.name
            entry.text = copy_table(data.text)
            reparse_sleeve_entry(entry)
            G.localization.descriptions.Sleeve[k] = entry
        end
    end

    -- Safeguard all entries in G.localization.descriptions.Sleeve
    for _, s_entry in pairs(G.localization.descriptions.Sleeve) do
        if type(s_entry) == 'table' then
            reparse_sleeve_entry(s_entry)
        end
    end

    -- Ensure no metatable on G.localization.descriptions.Sleeve interferes with SMODS localization loading
    setmetatable(G.localization.descriptions.Sleeve, nil)
end

-- Register CardSleeves objects
local registered_sleeves = false
function register_witch_brew_sleeves()
    if registered_sleeves then return end
    if not (CardSleeves and CardSleeves.Sleeve) then return end
    registered_sleeves = true

    local mod_obj = (get_witch_brew_mod and get_witch_brew_mod())
        or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'])
        or Witch_brew_MOD
        or SMODS.current_mod
    local prev_current_mod = SMODS.current_mod
    if not SMODS.current_mod and mod_obj then
        SMODS.current_mod = mod_obj
    end

    inject_sleeve_localization()

    -- 1. Friendly Sleeve
    CardSleeves.Sleeve {
        key = "friendly",
        mod = mod_obj,
        name = "Friendly Sleeve",
        atlas = "witch_brew_sleeves",
        pos = { x = 3, y = 0 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Friendly Sleeve",
            text = {
                "Start run with {C:attention}1 random Negative Eternal Joker{},",
                "{C:inactive}(Except Legendary or Secret){},",
                "{C:red}-1{} Discard"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("friendly")
            local raw_k = (self.original_key or self.key or "friendly")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_Witch_brew_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_Witch_brew_" .. base_key .. "_alt") or ("sleeve_Witch_brew_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.friendly_sleeve_selected = true
            local is_combo = is_deck_matching("friendly")
            if is_combo then
                G.GAME.friendly_sleeve_combo = true
                -- Handled cooperatively with Friendly Deck apply in decks.lua
            else
                -- Standalone Friendly Sleeve: -1 Discard, +1 Negative Eternal Joker
                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 1)
                ease_discard(-1)

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        play_sound('foil1')
                        local new_joker = nil
                        local attempts = 0
                        repeat
                            attempts = attempts + 1
                            local rarity_roll = pseudorandom('friendly_sleeve_rarity_' .. attempts)
                            local rarity_float = (rarity_roll > 0.95 and 0.99) or (rarity_roll > 0.70 and 0.8) or 0.5
                            new_joker = create_card('Joker', G.jokers, false, rarity_float, nil, false, nil, 'friendly_sleeve')
                            if new_joker and is_invalid_eternal_joker(new_joker) then
                                if new_joker.area then new_joker.area:remove_card(new_joker) end
                                new_joker:remove()
                                new_joker = nil
                            end
                        until new_joker or attempts >= 20
                        if not new_joker then
                            new_joker = create_card('Joker', G.jokers, false, 0.5, nil, false, nil, 'friendly_sleeve_fallback')
                        end
                        new_joker:set_eternal(true)
                        if new_joker.ability then new_joker.ability.eternal = true end
                        new_joker:set_edition({ negative = true }, true)
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        new_joker:juice_up(0.5, 0.5)
                        return true
                    end
                }))
            end
        end
    }

    -- 2. Caveman Sleeve
    CardSleeves.Sleeve {
        key = "cavernicola",
        mod = mod_obj,
        name = "Caveman Sleeve",
        atlas = "witch_brew_sleeves",
        pos = { x = 0, y = 0 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Caveman Sleeve",
            text = {
                "All starting {C:attention}Face Cards{} (J, Q, K)",
                "become {C:attention}Stone Cards{},",
                "{C:blue}+1{} Hand"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("cavernicola")
            local raw_k = (self.original_key or self.key or "cavernicola")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_Witch_brew_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_Witch_brew_" .. base_key .. "_alt") or ("sleeve_Witch_brew_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.cavernicola_sleeve_selected = true
            local is_combo = is_deck_matching("cavernicola")
            if is_combo then
                G.GAME.cavernicola_sleeve_combo = true
                -- Offset -1 Hand penalty from Caveman Deck
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                ease_hands_played(1)
            else
                -- Standalone Caveman Sleeve: face cards become stone cards, +1 hand
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                ease_hands_played(1)

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        if G.playing_cards then
                            for _, card in ipairs(G.playing_cards) do
                                if card:is_face() then
                                    card:set_ability(G.P_CENTERS.m_stone)
                                    card:juice_up(0.2, 0.2)
                                end
                            end
                        end
                        return true
                    end
                }))
            end
        end,
        calculate = function(self, sleeve, context)
            if G.GAME and G.GAME.cavernicola_sleeve_combo then
                if context.cardarea == G.play and context.individual and context.other_card then
                    if context.other_card.ability and (context.other_card.ability.name == 'Stone Card' or context.other_card.ability.effect == 'Stone Card') then
                        return {
                            mult = 1,
                            card = context.other_card
                        }
                    end
                end
            end
        end
    }

    -- 3. Strategist Sleeve
    CardSleeves.Sleeve {
        key = "strategist",
        mod = mod_obj,
        name = "Strategist Sleeve",
        atlas = "witch_brew_sleeves",
        pos = { x = 1, y = 0 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Strategist Sleeve",
            text = {
                "Start with {C:attention}Magic Trick{} voucher,",
                "Start with {C:money}$5{}, {C:red}-1{} Discard"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("strategist")
            local raw_k = (self.original_key or self.key or "strategist")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_Witch_brew_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_Witch_brew_" .. base_key .. "_alt") or ("sleeve_Witch_brew_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.strategist_sleeve_selected = true
            local is_combo = is_deck_matching("strategist")
            if is_combo then
                G.GAME.strategist_sleeve_combo = true
                -- Condense starting deck further: remove 9s as well (leaving exactly 20 cards: 10, J, Q, K, A)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        if G.playing_cards then
                            for i = #G.playing_cards, 1, -1 do
                                local card = G.playing_cards[i]
                                local val = card.base and card.base.value
                                if val == '9' then
                                    if card.area then card.area:remove_card(card) end
                                    card:remove()
                                    table.remove(G.playing_cards, i)
                                end
                            end
                        end
                        return true
                    end
                }))

                -- Start with Tarot Merchant voucher
                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers['v_tarot_merchant'] = true

                -- +1 Shop card slot
                if G.GAME.shop then
                    G.GAME.shop.joker_max = (G.GAME.shop.joker_max or 2) + 1
                end

                -- Played hands grant +$1
                G.GAME.modifiers = G.GAME.modifiers or {}
                G.GAME.modifiers.money_per_hand = (G.GAME.modifiers.money_per_hand or 0) + 1
            else
                -- Standalone Strategist Sleeve: Magic Trick voucher, +$5, -1 Discard
                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers['v_magic_trick'] = true
                ease_dollars(5)
                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 1)
                ease_discard(-1)
            end
        end
    }

    -- 4. Overseer Sleeve
    CardSleeves.Sleeve {
        key = "overseer",
        mod = mod_obj,
        name = "Overseer Sleeve",
        atlas = "witch_brew_sleeves",
        pos = { x = 2, y = 0 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Overseer Sleeve",
            text = {
                "{C:attention}Tags are always doubled{},",
                "Defeating a Boss Blind creates a random {C:spectral}Spectral card{}"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("overseer")
            local raw_k = (self.original_key or self.key or "overseer")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_Witch_brew_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_Witch_brew_" .. base_key .. "_alt") or ("sleeve_Witch_brew_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.overseer_sleeve_selected = true
            local is_combo = is_deck_matching("overseer")
            if is_combo then
                G.GAME.overseer_sleeve_combo = true
                G.GAME.overseer_no_markup = true
                -- Offset -1 Hand penalty and add +$5
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                ease_hands_played(1)
                ease_dollars(5)
            else
                -- Standalone Overseer Sleeve: tags are doubled
                G.GAME.overseer_sleeve_active = true
            end
        end,
        calculate = function(self, sleeve, context)
            local is_combo = G.GAME and G.GAME.overseer_sleeve_combo
            if is_combo then
                -- Combo effect: 2 Spectrals at end of round
                if context.end_of_round and not context.individual and not context.repetition then
                    for i = 1, 2 do
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
                                    local chosen_key = (#valid_spectrals > 0) and pseudorandom_element(valid_spectrals, pseudoseed('overseer_sleeve_combo_' .. i)) or 'c_ankh'
                                    local scard = create_card('Spectral', G.consumeables, nil, nil, nil, nil, chosen_key, 'overseer_combo')
                                    scard:add_to_deck()
                                    G.consumeables:emplace(scard)
                                    scard:juice_up(0.5, 0.5)
                                    return true
                                end
                            }))
                        end
                    end
                end
            else
                -- Standalone Overseer Sleeve: Defeating a Boss Blind creates a random Spectral card
                if context.end_of_round and G.GAME and G.GAME.blind and G.GAME.blind.boss and not context.individual and not context.repetition then
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
                                local chosen_key = (#valid_spectrals > 0) and pseudorandom_element(valid_spectrals, pseudoseed('overseer_sleeve_boss')) or 'c_ankh'
                                local scard = create_card('Spectral', G.consumeables, nil, nil, nil, nil, chosen_key, 'overseer_boss')
                                scard:add_to_deck()
                                G.consumeables:emplace(scard)
                                scard:juice_up(0.5, 0.5)
                                return true
                            end
                        }))
                    end
                end
            end
        end
    }

    -- 5. Alchemist Sleeve
    CardSleeves.Sleeve {
        key = "alchemist",
        mod = mod_obj,
        name = "Alchemist Sleeve",
        atlas = "witch_brew_sleeves",
        pos = { x = 0, y = 1 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Alchemist Sleeve",
            text = {
                "Creates {C:attention}1 random Potion{}",
                "at start of each round",
                "{C:inactive}(Must have consumable space){}"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("alchemist")
            local raw_k = (self.original_key or self.key or "alchemist")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_Witch_brew_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_Witch_brew_" .. base_key .. "_alt") or ("sleeve_Witch_brew_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.alchemist_sleeve_selected = true
            local is_combo = is_deck_matching("alchemist")
            if is_combo then
                G.GAME.alchemist_sleeve_combo = true
                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers.v_Witch_brew_destilacion_recurrente = true
                G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true
                G.GAME.used_vouchers.v_destilacion_recurrente = true
                G.GAME.used_vouchers.destilacion_recurrente = true

                G.E_MANAGER:add_event(Event({
                    func = function()
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
                        return true
                    end
                }))
            else
                G.GAME.alchemist_sleeve_active = true
            end
        end,
        calculate = function(self, sleeve, context)
            local is_combo = G.GAME and G.GAME.alchemist_sleeve_combo
            if is_combo then
                -- Fusion effect: Summon Kyra (Eternal) 1 time at start of match and grant Recurring Distillation each round
                if (context.first_hand_drawn or context.setting_blind) and not context.blueprint and not context.individual and not context.repetition then
                    G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                    G.GAME.used_vouchers.v_Witch_brew_destilacion_recurrente = true
                    G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true

                    if not G.GAME.alchemist_fusion_kyra_given and G.jokers then
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
            else
                -- Standalone effect: 1 random potion at start of each round
                if context.first_hand_drawn and not context.blueprint and not context.individual and not context.repetition then
                    local can_spawn = G.consumeables and (#G.consumeables.cards < G.consumeables.config.card_limit or (G.jokers and next(find_joker('Kyra'))))
                    if can_spawn then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_potion = (create_potion_card_safe and create_potion_card_safe(G.consumeables, 'alchemist_sleeve'))
                                    or create_card('Potion', G.consumeables, nil, nil, nil, nil, nil, 'alchemist_sleeve')
                                if new_potion then
                                    new_potion:add_to_deck()
                                    G.consumeables:emplace(new_potion)
                                    new_potion:juice_up(0.5, 0.5)
                                    card_eval_status_text(new_potion, 'extra', nil, nil, nil, { message = '+1 Potion!', colour = G.C.SECONDARY_SET.Enhanced })
                                end
                                return true
                            end
                        }))
                    end
                end
            end
        end
    }

    SMODS.current_mod = prev_current_mod
    inject_sleeve_localization()
end

-- Try initial registration
if CardSleeves and CardSleeves.Sleeve then
    register_witch_brew_sleeves()
end

-- Hook init_localization to ensure sleeves are registered and translated
local orig_init_loc_sleeves = init_localization
function init_localization()
    if orig_init_loc_sleeves then orig_init_loc_sleeves() end
    if CardSleeves and CardSleeves.Sleeve then
        register_witch_brew_sleeves()
    end
    inject_sleeve_localization()
end

-- Hook Game:delete_run and Game:start_run to prevent sleeves from disappearing on restart
local orig_game_delete_run = Game.delete_run
function Game:delete_run(...)
    if G.GAME and G.GAME.selected_sleeve and G.GAME.selected_sleeve ~= "sleeve_casl_none" and G.GAME.selected_sleeve ~= "" then
        G._last_selected_sleeve = G.GAME.selected_sleeve
        G.viewed_sleeve = G.GAME.selected_sleeve
        if G.PROFILES and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].MEMORY then
            G.PROFILES[G.SETTINGS.profile].MEMORY.sleeve = G.GAME.selected_sleeve
        end
    end
    return orig_game_delete_run(self, ...)
end

local orig_game_start_run = Game.start_run
function Game:start_run(args)
    args = args or {}
    if CardSleeves and CardSleeves.Sleeve then
        if not registered_sleeves then
            register_witch_brew_sleeves()
        end
        if not args.casl_sleeve_choice then
            local prev_sleeve = G._last_selected_sleeve
                or G.viewed_sleeve
                or (G.PROFILES and G.PROFILES[G.SETTINGS.profile] and (
                    (G.PROFILES[G.SETTINGS.profile].last_choices and G.PROFILES[G.SETTINGS.profile].last_choices.casl_sleeve_choice)
                    or (G.PROFILES and G.PROFILES[G.SETTINGS.profile].MEMORY and G.PROFILES[G.SETTINGS.profile].MEMORY.sleeve)
                ))
            if prev_sleeve and prev_sleeve ~= "sleeve_casl_none" and prev_sleeve ~= "" then
                args.casl_sleeve_choice = prev_sleeve
                G.viewed_sleeve = prev_sleeve
            end
        end
    end
    inject_sleeve_localization()
    return orig_game_start_run(self, args)
end

-- Defensive hook for Card.hover to guarantee sleeve entries have text_parsed
if Card and Card.hover then
    local orig_card_hover = Card.hover
    function Card:hover()
        if G.localization and G.localization.descriptions and G.localization.descriptions.Sleeve then
            for _, s_entry in pairs(G.localization.descriptions.Sleeve) do
                if type(s_entry) == 'table' and (not s_entry.text_parsed or not next(s_entry.text_parsed)) then
                    reparse_sleeve_entry(s_entry)
                end
            end
        end
        return orig_card_hover(self)
    end
end
