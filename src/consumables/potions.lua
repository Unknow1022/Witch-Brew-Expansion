--[[
    Potions & Brews Consumable System
    Part of Witcher Brew Expansion
--]]

SMODS.Atlas {
    key = "witch_brew_potions",
    path = "potions.png",
    px = 71,
    py = 95
}

SMODS.ConsumableType {
    key = 'Potion',
    primary_colour = HEX('2e8b57'),
    secondary_colour = HEX('1a4d2e'),
    loc_txt = {
        name = 'Potion',
        collection = 'Potions',
        underscores_single = 'Potion',
        underscores_plural = 'Potions'
    },
    shop_rate = 0.8,
    collection_rows = { 2, 4 },
    default = 'c_Witch_brew_potion_estiramiento'
}

-- 1. Stretch Potion
SMODS.Consumable {
    key = 'potion_estiramiento',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 0, y = 0 },
    cost = 4,
    loc_txt = {
        name = 'Stretch Potion',
        text = {
            "Allows selecting and playing",
            "up to {C:attention}7 cards{} in your next hand"
        }
    },
    can_use = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and G.hand and G.hand.config
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.4, 0.5)
                G.hand.config.highlighted_limit = 7
                G.GAME.potion_estiramiento_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = '7 Cards!', colour = G.C.GREEN })
                return true
            end
        }))
    end
}

-- 2. Lightning Potion
SMODS.Consumable {
    key = 'potion_rayo',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 1, y = 0 },
    cost = 4,
    loc_txt = {
        name = 'Lightning Potion',
        text = {
            "Cards played in your next hand gain a",
            "{C:attention}random enhancement{}, with a {C:green}1 in 5{} chance",
            "to be destroyed when scoring ends"
        }
    },
    can_use = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.5, 0.6)
                G.GAME.potion_rayo_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Lightning Active!', colour = G.C.GOLD })
                return true
            end
        }))
    end
}

-- 3. Blizzard Potion
SMODS.Consumable {
    key = 'potion_ventisca',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 2, y = 0 },
    cost = 4,
    loc_txt = {
        name = 'Blizzard Potion',
        text = {
            "Shuffles all played and discarded",
            "cards back into the deck, then",
            "draws a {C:attention}completely new hand{}"
        }
    },
    can_use = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and G.hand and G.deck and G.discard
    end,
    use = function(self, card, area, copier)
        play_sound('tarot1')
        card:juice_up(0.4, 0.6)

        -- 1. Return all discard pile cards to deck ensuring full visibility and interaction
        if G.discard and G.discard.cards then
            for i = #G.discard.cards, 1, -1 do
                local c = G.discard.cards[i]
                c.states.visible = true
                c.states.drag.can = true
                c.states.collide.can = true
                c.facing = 'back'
                G.discard:remove_card(c)
                G.deck:emplace(c)
            end
        end

        -- 2. Return current hand cards to deck
        if G.hand and G.hand.cards then
            for i = #G.hand.cards, 1, -1 do
                local c = G.hand.cards[i]
                c:highlight(false)
                c.states.visible = true
                c.states.drag.can = true
                c.states.collide.can = true
                c.facing = 'back'
                G.hand:remove_card(c)
                G.deck:emplace(c)
            end
            G.hand.highlighted = {}
        end

        -- 3. Shuffle deck
        G.deck:shuffle('ventisca')
        play_sound('cardFan2')

        -- 4. Redraw full hand
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local draw_count = (G.hand and G.hand.config and G.hand.config.card_limit) or 8
                G.FUNCS.draw_from_deck_to_hand(draw_count)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Blizzard!', colour = G.C.BLUE })
                return true
            end
        }))
    end
}

-- 4. Fury Potion
SMODS.Consumable {
    key = 'potion_furia',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 3, y = 0 },
    cost = 4,
    loc_txt = {
        name = 'Fury Potion',
        text = {
            "Destroys up to {C:attention}3 selected cards{}",
            "from your hand"
        }
    },
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted >= 1 and #G.hand.highlighted <= 3
    end,
    use = function(self, card, area, copier)
        local targets = {}
        for _, c in ipairs(G.hand.highlighted) do
            table.insert(targets, c)
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('slice1')
                card:juice_up(0.5, 0.6)
                for _, target in ipairs(targets) do
                    target:start_dissolve()
                end
                if G.hand then G.hand:unhighlight_all() end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Fury!', colour = G.C.RED })
                return true
            end
        }))
    end
}

-- 5. Amalgam Potion
G.FUNCS = G.FUNCS or {}

local function get_card_edition_info(c)
    if not (c and c.edition) then return 0, nil end
    if c.edition.negative then return 2, 'negative' end
    if c.edition.polychrome then return 2, 'polychrome' end
    if c.edition.holo then return 1, 'holo' end
    if c.edition.foil then return 1, 'foil' end
    return 0, nil
end

local function get_valid_joker_key(k)
    if not k then return nil end
    if not G.P_CENTERS then return k end
    if G.P_CENTERS[k] then return k end
    local clean = tostring(k):gsub('^j_Witch_brew_', ''):gsub('^j_Witch brew_', ''):gsub('^j_', '')
    local candidates = {
        'j_Witch brew_' .. clean,
        'j_Witch_brew_' .. clean,
        'j_' .. clean,
        clean
    }
    for _, cand in ipairs(candidates) do
        if G.P_CENTERS[cand] then return cand end
    end
    for p_key, _ in pairs(G.P_CENTERS) do
        if string.find(string.lower(p_key), string.lower(clean), 1, true) then return p_key end
    end
    return nil
end

G.AMALGAM_RECIPES = {
    {
        pair = { 'brainstorm', 'blueprint' },
        key = 'brainprint',
        name = 'Brainprint',
        quote = "\"UNBELIEVABLE ALCHEMY! Blueprint and Brainstorm merge into the ultimate mimic: Brainprint!\""
    },
    {
        pair = { 'midas_mask', 'vampire' },
        key = 'midas_vampirico',
        name = 'Vampiric Midas',
        quote = "\"Golden greed meets immortal hunger! Midas Mask and Vampire fuse into Vampiric Midas!\""
    },
    {
        pair = { 'hologram', 'certificate' },
        key = 'programacion_certificacion',
        name = 'Certified Programming',
        quote = "\"Holographic seals certified! Hologram and Certificate combine into Certified Programming!\""
    },
    {
        pair = { 'constellation', 'astronomer' },
        key = 'viajero_galactico',
        name = 'Galactic Traveler',
        quote = "\"The cosmos aligns! Constellation and Astronomer unite into the Galactic Traveler!\""
    },
    {
        pair = { 'four_fingers', 'shortcut' },
        key = 'calle_colorida',
        name = 'Colorful Street',
        quote = "\"Rules bend to the colors! Four Fingers and Shortcut synthesize into Colorful Street!\""
    }
}

function get_amalgam_recipe_match(j1, j2)
    if not j1 or not j2 then return nil end
    local k1 = tostring((j1.config and j1.config.center and j1.config.center.key) or '')
    local k2 = tostring((j2.config and j2.config.center and j2.config.center.key) or '')
    local n1 = tostring((j1.ability and j1.ability.name) or (j1.config and j1.config.center and j1.config.center.name) or '')
    local n2 = tostring((j2.ability and j2.ability.name) or (j2.config and j2.config.center and j2.config.center.name) or '')

    for _, recipe in ipairs(G.AMALGAM_RECIPES or {}) do
        local target_a = recipe.pair[1]
        local target_b = recipe.pair[2]

        local match1 = (string.find(k1, target_a, 1, true) or string.find(string.lower(n1), target_a, 1, true))
        local match2 = (string.find(k2, target_b, 1, true) or string.find(string.lower(n2), target_b, 1, true))
        if match1 and match2 then return recipe end

        local rev1 = (string.find(k1, target_b, 1, true) or string.find(string.lower(n1), target_b, 1, true))
        local rev2 = (string.find(k2, target_a, 1, true) or string.find(string.lower(n2), target_a, 1, true))
        if rev1 and rev2 then return recipe end
    end

    return nil
end

local function calculate_amalgam_outcome(j1, j2)
    if not j1 then return 2, false, nil, 0, nil end
    local r1 = (j1.config and j1.config.center and j1.config.center.rarity) or 1
    local r2 = (j2 and j2.config and j2.config.center and j2.config.center.rarity) or 1
    if type(r1) ~= 'number' then r1 = (r1 == 'Witch_brew_song' and 4) or 3 end
    if type(r2) ~= 'number' then r2 = (r2 == 'Witch_brew_song' and 4) or 3 end
    local ed_b1, ed_t1 = get_card_edition_info(j1)
    local ed_b2, ed_t2 = get_card_edition_info(j2)
    local total_ed_bonus = ed_b1 + ed_b2

    local best_edition = nil
    if ed_t1 == 'negative' or ed_t2 == 'negative' then
        best_edition = { negative = true }
    elseif ed_t1 == 'polychrome' or ed_t2 == 'polychrome' then
        best_edition = { polychrome = true }
    elseif (ed_t1 == 'holo' and ed_t2 == 'holo') or (ed_t1 == 'foil' and ed_t2 == 'holo') or (ed_t1 == 'holo' and ed_t2 == 'foil') then
        best_edition = { polychrome = true }
    elseif ed_t1 == 'holo' or ed_t2 == 'holo' then
        best_edition = { holo = true }
    elseif ed_t1 == 'foil' and ed_t2 == 'foil' then
        best_edition = { holo = true }
    elseif ed_t1 == 'foil' or ed_t2 == 'foil' then
        best_edition = { foil = true }
    end

    -- Specific Amalgam Fusion Recipes (e.g. Brainstorm + Blueprint -> Brainprint)
    if j1 and j2 then
        local recipe = get_amalgam_recipe_match(j1, j2)
        if recipe then
            return 'amalgam', true, best_edition, total_ed_bonus, recipe
        end
    end

    -- Secret: 1 Legendary alone or with any Joker
    if (not j2 and r1 == 4) or (r1 == 4 or r2 == 4) then
        return 4, true, best_edition, total_ed_bonus, nil
    end

    local max_r = math.max(r1, r2)
    local min_r = math.min(r1, r2)
    local base_r = 2

    -- STRICT BALANCE RULE:
    -- To create a Legendary, you MUST combine:
    -- 2 Rares (3 + 3) OR 1 Rare and 1 Uncommon (3 + 2)
    if max_r == 3 and min_r >= 2 then
        base_r = 4
    elseif max_r >= 3 then
        base_r = 3
    elseif max_r == 2 and min_r == 2 then
        base_r = 3
    elseif max_r == 2 and total_ed_bonus >= 1 then
        base_r = 3
    elseif total_ed_bonus >= 2 and min_r == 1 and max_r == 1 then
        base_r = 3
    else
        base_r = 2
    end

    local is_secret = false
    if base_r == 4 and total_ed_bonus >= 2 then
        is_secret = true
    end

    return base_r, is_secret, best_edition, total_ed_bonus, nil
end

G.FUNCS.amalgam_cannot_select = function(e)
    play_sound('cancel', 1)
end

local function format_dialogue_lines(text, max_len)
    max_len = max_len or 50
    if not text or #text <= max_len then
        return text or "", ""
    end
    local cut = max_len
    local space = nil
    for i = max_len, 1, -1 do
        if text:sub(i, i) == ' ' then
            space = i
            break
        end
    end
    if space and space > 15 then
        cut = space
    end
    local l1 = text:sub(1, cut - 1)
    local l2 = text:sub(cut + 1)
    return l1, l2
end

G.AMALGAM_STATE = {
    outcome_text = "Select 2 Jokers to preview rarity",
    kyra_quote = "\"Pick two unbonded souls, and let the brew do its magic.\"",
    line1 = "\"Pick two unbonded souls, and let the brew",
    line2 = "do its magic.\"",
    edition_note = "",
    combine_text = "Select 2 Jokers",
    can_combine = false
}

local function set_amalgam_quote(full_text)
    local l1, l2 = format_dialogue_lines(full_text, 50)
    G.AMALGAM_STATE.kyra_quote = full_text
    G.AMALGAM_STATE.line1 = l1
    G.AMALGAM_STATE.line2 = l2
end

local function update_amalgam_preview()
    local sel = G.AMALGAM_SELECTION or {}
    G.AMALGAM_STATE.can_combine = false
    G.AMALGAM_STATE.edition_note = ""

    if #sel == 2 then
        G.AMALGAM_STATE.can_combine = true
        local target_rarity, is_secret_summon, best_edition, total_ed_bonus, recipe = calculate_amalgam_outcome(sel[1], sel[2])

        if recipe then
            G.AMALGAM_STATE.outcome_text = "AMALGAM: " .. (recipe.name or "Special")
            set_amalgam_quote(recipe.quote or "\"An ancient fusion formula! The two Jokers merge!\"")
            G.AMALGAM_STATE.combine_text = "FUSE AMALGAM!"
        elseif is_secret_summon then
            G.AMALGAM_STATE.outcome_text = "SECRET JOKER!"
            set_amalgam_quote("\"THE VEIL IS TORN! A SECRET JOKER IS BEING SUMMONED!\"")
            G.AMALGAM_STATE.combine_text = "COMBINE JOKERS!"
        elseif target_rarity == 4 then
            G.AMALGAM_STATE.outcome_text = "LEGENDARY"
            set_amalgam_quote("\"Tremendous power gathers... Cauldron unveils a LEGENDARY creation!\"")
            G.AMALGAM_STATE.combine_text = "COMBINE JOKERS!"
        elseif target_rarity == 3 then
            G.AMALGAM_STATE.outcome_text = "RARE"
            set_amalgam_quote("\"The flames burn hot! A Rare Joker is ready to materialize!\"")
            G.AMALGAM_STATE.combine_text = "COMBINE JOKERS!"
        else
            G.AMALGAM_STATE.outcome_text = "UNCOMMON"
            set_amalgam_quote("\"The cauldron hums gently. An Uncommon ally will rise from the smoke.\"")
            G.AMALGAM_STATE.combine_text = "COMBINE JOKERS!"
        end

        if best_edition then
            local ed_name = best_edition.negative and "Negative" or (best_edition.polychrome and "Polychrome" or (best_edition.holo and "Holographic" or "Foil"))
            G.AMALGAM_STATE.edition_note = "★ Infused Edition: " .. ed_name .. (total_ed_bonus > 0 and " (Elevates Alchemy Tier!)" or "")
        end
    elseif #sel == 1 and sel[1].config and sel[1].config.center and sel[1].config.center.rarity == 4 then
        G.AMALGAM_STATE.can_combine = true
        G.AMALGAM_STATE.outcome_text = "SECRET JOKER! (1 Legendary)"
        set_amalgam_quote("\"A Legendary presence stirs... We could awaken an ancient Secret right now!\"")
        G.AMALGAM_STATE.combine_text = "COMBINE JOKERS!"
    elseif #sel == 1 then
        G.AMALGAM_STATE.outcome_text = "Select 1 more Joker..."
        set_amalgam_quote("\"One ingredient in the brew. Select its partner to reveal our destiny.\"")
        G.AMALGAM_STATE.combine_text = "Select 1 more"
    else
        G.AMALGAM_STATE.outcome_text = "Select 2 Jokers to preview rarity"
        set_amalgam_quote("\"Pick two unbonded souls, and let the brew do its magic.\"")
        G.AMALGAM_STATE.combine_text = "Select 2 Jokers"
    end

    if G.amalgam_combine_button then
        G.amalgam_combine_button.config.colour = G.AMALGAM_STATE.can_combine and G.C.GREEN or G.C.UI.BACKGROUND_INACTIVE
    end
end

G.FUNCS.amalgam_toggle_joker = function(e)
    if not e or not e.config or not e.config.ref_table or not e.config.ref_table.card then return end
    local card = e.config.ref_table.card
    if card.ability and card.ability.eternal then
        play_sound('cancel', 1)
        return
    end

    G.AMALGAM_SELECTION = G.AMALGAM_SELECTION or {}
    local found_idx = nil
    for i, c in ipairs(G.AMALGAM_SELECTION) do
        if c == card then found_idx = i break end
    end

    if found_idx then
        table.remove(G.AMALGAM_SELECTION, found_idx)
        play_sound('cardSlide1', 1)
    else
        if #G.AMALGAM_SELECTION >= 2 then
            table.remove(G.AMALGAM_SELECTION, 1)
        end
        table.insert(G.AMALGAM_SELECTION, card)
        play_sound('card1', 1)
    end

    if G.amalgam_joker_btn_nodes then
        for _, entry in ipairs(G.amalgam_joker_btn_nodes) do
            local is_selected = false
            for _, sel_card in ipairs(G.AMALGAM_SELECTION) do
                if sel_card == entry.card then is_selected = true break end
            end
            if entry.state then
                entry.state.label = is_selected and "[ ✓ ]" or "[   ]"
            end
            if entry.btn then
                entry.btn.config.colour = is_selected and G.C.GREEN or G.C.L_BLACK
                entry.btn.config.outline = not is_selected and 0.04 or nil
                entry.btn.config.outline_colour = not is_selected and G.C.WHITE or nil
            end
        end
    end

    update_amalgam_preview()
end

if G.FUNCS and G.FUNCS.exit_overlay_menu then
    local orig_exit_overlay_menu = G.FUNCS.exit_overlay_menu
    G.FUNCS.exit_overlay_menu = function()
        if G.amalgam_temp_areas then
            for _, area in ipairs(G.amalgam_temp_areas) do
                area:remove()
            end
            G.amalgam_temp_areas = nil
        end
        if G.pouch_temp_areas then
            for _, area in ipairs(G.pouch_temp_areas) do
                area:remove()
            end
            G.pouch_temp_areas = nil
        end
        G.amalgam_joker_btn_nodes = nil
        G.amalgam_combine_button = nil
        if G.AMALGAM_PENDING_REFUND then
            local new_potion = (create_potion_card_safe and create_potion_card_safe(G.consumeables, 'amalgama_refund')) or create_card('Potion', G.consumeables, nil, nil, nil, nil, 'c_Witch_brew_potion_amalgama', 'refund')
            if new_potion then
                new_potion:add_to_deck()
                G.consumeables:emplace(new_potion)
                play_sound('cancel', 0.9)
            end
            G.AMALGAM_PENDING_REFUND = nil
        end
        G.AMALGAM_SELECTION = nil
        orig_exit_overlay_menu()
    end
end

G.FUNCS.amalgam_cancel_menu = function(e)
    G.FUNCS.exit_overlay_menu()
end

G.FUNCS.amalgam_confirm_combine = function(e)
    local sel = G.AMALGAM_SELECTION
    if not (G.AMALGAM_STATE and G.AMALGAM_STATE.can_combine) then
        play_sound('cancel', 1)
        return
    end
    if not sel or (#sel < 1) then return end
    local j1 = sel[1]
    local j2 = sel[2]
    if not j2 and not (j1.config and j1.config.center and j1.config.center.rarity == 4) then
        return
    end

    G.AMALGAM_PENDING_REFUND = nil
    if G.amalgam_temp_areas then
        for _, area in ipairs(G.amalgam_temp_areas) do
            area:remove()
        end
        G.amalgam_temp_areas = nil
    end
    G.amalgam_joker_btn_nodes = nil
    G.amalgam_combine_button = nil
    G.AMALGAM_SELECTION = nil
    G.FUNCS.exit_overlay_menu()

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.3,
        func = function()
            play_sound('polychrome1')

            local target_rarity, is_secret_summon, inherited_edition, total_ed_bonus, recipe = calculate_amalgam_outcome(j1, j2)

            if j1 then j1:start_dissolve() end
            if j2 then j2:start_dissolve() end

            local new_joker = nil
            if recipe then
                local final_key = get_valid_joker_key(recipe.key)
                if final_key and G.P_CENTERS and G.P_CENTERS[final_key] then
                    new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, final_key, 'amalgama_recipe')
                else
                    new_joker = create_card('Joker', G.jokers, true, nil, nil, nil, nil, 'amalgama_fallback')
                end
            elseif is_secret_summon then
                local secret_keys = {
                    'esteban', 'thiago', 'black_hole_joker',
                    'squele', 'bluxdir', 'charles', 'mochi',
                    'helin', 'raytracing', 'paco', 'yairo',
                    'kyra'
                }
                local valid_keys = {}
                for _, k in ipairs(secret_keys) do
                    local vk = get_valid_joker_key(k)
                    if vk and G.P_CENTERS and G.P_CENTERS[vk] then table.insert(valid_keys, vk) end
                end
                local chosen_key = (#valid_keys > 0) and pseudorandom_element(valid_keys, pseudoseed('amalgama_secret')) or nil
                if chosen_key then
                    new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'amalgama')
                else
                    new_joker = create_card('Joker', G.jokers, true, nil, nil, nil, nil, 'amalgama')
                end
            else
                new_joker = create_card('Joker', G.jokers, (target_rarity == 4), nil, nil, nil, nil, 'amalgama')
                if target_rarity < 4 and new_joker then
                    local pool = get_current_pool('Joker', target_rarity)
                    if pool and #pool > 0 then
                        local chosen_center = pseudorandom_element(pool, pseudoseed('amalgama_pool'))
                        if chosen_center and G.P_CENTERS[chosen_center] then
                            new_joker:set_ability(G.P_CENTERS[chosen_center])
                        end
                    end
                end
            end

            if new_joker then
                if inherited_edition then
                    new_joker:set_edition(inherited_edition, true)
                end
                new_joker:add_to_deck()
                G.jokers:emplace(new_joker)
                new_joker:juice_up(0.7, 0.7)
            end

            local msg = recipe and ('Amalgama: ' .. recipe.name) or 'Amalgam!'
            local col = recipe and HEX('8a2be2') or G.C.DARK_EDITION
            card_eval_status_text(new_joker or G.jokers, 'extra', nil, nil, nil, { message = msg, colour = col })
            return true
        end
    }))
end

G.FUNCS.open_amalgam_menu = function()
    if not (create_UIBox_generic_options and G.FUNCS.overlay_menu and G.jokers and G.jokers.cards) then return end

    if G.amalgam_temp_areas then
        for _, area in ipairs(G.amalgam_temp_areas) do
            area:remove()
        end
    end
    G.amalgam_temp_areas = {}
    G.amalgam_joker_btn_nodes = {}

    local card_scale = (#G.jokers.cards > 5) and 0.55 or 0.7
    local joker_nodes = {}

    for _, j in ipairs(G.jokers.cards) do
        local is_eternal = (j.ability and j.ability.eternal)
        local is_selected = false
        for _, sel in ipairs(G.AMALGAM_SELECTION or {}) do
            if sel == j then is_selected = true break end
        end

        local c_area = CardArea(
            0, 0,
            G.CARD_W * card_scale,
            G.CARD_H * card_scale,
            {card_limit = 1, type = 'title', highlight_limit = 0, card_w = G.CARD_W * card_scale}
        )
        table.insert(G.amalgam_temp_areas, c_area)
        local copy = copy_card(j, nil, card_scale)
        c_area:emplace(copy)

        local btn_state = {
            label = is_eternal and "[ X ]" or (is_selected and "[ ✓ ]" or "[   ]")
        }
        local btn_colour = is_eternal and G.C.UI.BACKGROUND_INACTIVE or (is_selected and G.C.GREEN or G.C.L_BLACK)
        local btn_func = is_eternal and 'amalgam_cannot_select' or 'amalgam_toggle_joker'

        local button_node = {
            n = G.UIT.R, config = {
                align = "cm",
                minw = 1.3,
                minh = 0.52,
                r = 0.1,
                hover = not is_eternal,
                colour = btn_colour,
                outline = not is_selected and not is_eternal and 0.04 or nil,
                outline_colour = not is_selected and not is_eternal and G.C.WHITE or nil,
                button = btn_func,
                ref_table = {card = j},
                shadow = true
            }, nodes = {
                {n = G.UIT.T, config = {ref_table = btn_state, ref_value = 'label', scale = 0.44, colour = is_eternal and G.C.RED or G.C.WHITE, shadow = true}}
            }
        }
        if not is_eternal then
            table.insert(G.amalgam_joker_btn_nodes, { btn = button_node, card = j, state = btn_state })
        end

        local col_nodes = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                {n = G.UIT.O, config = {object = c_area}}
            }},
            is_eternal and {n = G.UIT.R, config = {align = "cm", padding = 0.02}, nodes = {
                {n = G.UIT.T, config = {text = "[Eternal]", scale = 0.32, colour = G.C.RED, shadow = true}}
            }} or {n = G.UIT.R, config = {align = "cm", minh = 0.22}, nodes = {}},
            {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                button_node
            }}
        }

        table.insert(joker_nodes, {
            n = G.UIT.C,
            config = {
                align = "cm",
                padding = 0.08,
                r = 0.15,
                colour = is_selected and {0.2, 0.5, 0.2, 0.5} or {0.1, 0.1, 0.1, 0.3},
                outline = is_selected and 0.05 or nil,
                outline_colour = is_selected and G.C.GREEN or nil
            },
            nodes = col_nodes
        })
    end

    -- Robust lookup for Kyra center
    local kyra_center = nil
    if G.P_CENTERS then
        kyra_center = G.P_CENTERS['j_Witch_brew_kyra']
            or G.P_CENTERS['j_Witch brew_kyra']
            or G.P_CENTERS['j_kyra']
            or G.P_CENTERS['kyra']
        if not kyra_center then
            for k, v in pairs(G.P_CENTERS) do
                if string.find(string.lower(k), 'kyra', 1, true) then
                    kyra_center = v
                    break
                end
            end
        end
    end

    -- Kyra avatar setup (scale 0.72)
    local kyra_scale = 0.72
    local kyra_w = G.CARD_W * kyra_scale
    local kyra_h = G.CARD_H * kyra_scale
    local kyra_area = CardArea(
        0, 0,
        kyra_w,
        kyra_h,
        {card_limit = 1, type = 'title', highlight_limit = 0, card_w = kyra_w}
    )
    table.insert(G.amalgam_temp_areas, kyra_area)
    local kyra_card = Card(0, 0, kyra_w, kyra_h, G.P_CARDS.empty, kyra_center or G.P_CENTERS.j_joker)
    if kyra_center then
        kyra_card:set_ability(kyra_center)
    end
    kyra_area:emplace(kyra_card)

    update_amalgam_preview()

    local combine_btn_node = {
        n = G.UIT.R, config = {
            align = "cm",
            minw = 3.8,
            minh = 0.8,
            r = 0.15,
            hover = true,
            colour = G.AMALGAM_STATE.can_combine and G.C.GREEN or G.C.UI.BACKGROUND_INACTIVE,
            button = 'amalgam_confirm_combine',
            shadow = true
        }, nodes = {
            {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'combine_text', scale = 0.55, colour = G.C.WHITE, shadow = true}}
        }
    }
    G.amalgam_combine_button = combine_btn_node

    local t = create_UIBox_generic_options({
        back_func = 'amalgam_cancel_menu',
        back_label = "Cancel",
        contents = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.15}, nodes = {
                {n = G.UIT.T, config = {text = "Amalgam Potion", scale = 0.65, colour = G.C.GOLD, shadow = true}}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.08}, nodes = {
                {n = G.UIT.T, config = {text = "Select 2 Jokers to combine (Eternal jokers cannot be combined):", scale = 0.38, colour = G.C.WHITE}}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.15, colour = G.C.L_BLACK, r = 0.15}, nodes = joker_nodes},
            {n = G.UIT.R, config = {align = "cm", padding = 0.12}, nodes = {
                {n = G.UIT.C, config = {align = "cm", padding = 0.1, colour = G.C.BLACK, r = 0.1, minw = 6, minh = 0.7, outline = 0.04, outline_colour = G.C.GOLD}, nodes = {
                    {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'outcome_text', scale = 0.48, colour = G.C.GOLD, shadow = true}}
                }}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                combine_btn_node
            }},
            -- Kyra Dialogue Box
            {n = G.UIT.R, config = {align = "cm", padding = 0.12, colour = G.C.L_BLACK, r = 0.15, emboss = 0.05, minw = 9.2}, nodes = {
                {n = G.UIT.C, config = {align = "cm", padding = 0.08}, nodes = {
                    {n = G.UIT.O, config = {object = kyra_area}},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.02}, nodes = {
                        {n = G.UIT.T, config = {text = "Kyra", scale = 0.42, colour = G.C.PURPLE, shadow = true}}
                    }}
                }},
                {n = G.UIT.C, config = {align = "cl", padding = 0.12, minw = 6.8}, nodes = {
                    {n = G.UIT.R, config = {align = "cl", padding = 0.02, maxw = 6.8}, nodes = {
                        {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'line1', scale = 0.32, maxw = 6.8, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
                    }},
                    {n = G.UIT.R, config = {align = "cl", padding = 0.02, maxw = 6.8}, nodes = {
                        {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'line2', scale = 0.32, maxw = 6.8, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
                    }},
                    {n = G.UIT.R, config = {align = "cl", padding = 0.02, maxw = 6.8}, nodes = {
                        {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'edition_note', scale = 0.32, maxw = 6.8, colour = G.C.DARK_EDITION, shadow = true}}
                    }}
                }}
            }}
        }
    })
    G.FUNCS.overlay_menu{definition = t}
end

SMODS.Consumable {
    key = 'potion_amalgama',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 4, y = 0 },
    cost = 6,
    loc_txt = {
        name = 'Amalgam Potion',
        text = {
            "Combines {C:attention}2 Jokers{} to generate one of {C:attention}higher rarity{}.",
            "Editions boost the fusion tier and carry over to the new Joker.",
            "Can summon {C:dark_edition}Secret Jokers{} from Legendary or high-tier fusions."
        }
    },
    can_use = function(self, card)
        if not (G.jokers and G.jokers.cards) then return false end
        local eligible_count = 0
        local has_non_eternal_legendary = false
        for _, j in ipairs(G.jokers.cards) do
            if not (j.ability and j.ability.eternal) then
                eligible_count = eligible_count + 1
                if j.config and j.config.center and j.config.center.rarity == 4 then
                    has_non_eternal_legendary = true
                end
            end
        end
        return (eligible_count >= 2) or has_non_eternal_legendary
    end,
    use = function(self, card, area, copier)
        G.AMALGAM_SELECTION = {}
        G.AMALGAM_PENDING_REFUND = true
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                if G.FUNCS and G.FUNCS.open_amalgam_menu then
                    G.FUNCS.open_amalgam_menu()
                end
                return true
            end
        }))
    end
}

-- 6. Mercury Potion
SMODS.Consumable {
    key = 'potion_mercurio',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 0, y = 1 },
    cost = 4,
    loc_txt = {
        name = 'Mercury Potion',
        text = {
            "Gives {C:blue}+1 Hand{} and {C:red}+1 Discard{}",
            "for the current round. Gain {C:money}$1{}",
            "for each remaining hand on blind defeat"
        }
    },
    can_use = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.4, 0.5)
                ease_hands_played(1)
                ease_discard(1)
                G.GAME.potion_mercurio_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = '+1 Hand & Discard!', colour = G.C.BLUE })
                return true
            end
        }))
    end
}

-- 7. Mirror Potion
SMODS.Consumable {
    key = 'potion_espejo',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 1, y = 1 },
    cost = 5,
    loc_txt = {
        name = 'Mirror Potion',
        text = {
            "Retriggers abilities of the",
            "{C:attention}rightmost Joker{}",
            "for the entire current round"
        }
    },
    can_use = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and G.jokers and G.jokers.cards and #G.jokers.cards > 0
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.5, 0.6)
                G.GAME.potion_espejo_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Mirror Active!', colour = G.C.PURPLE })
                return true
            end
        }))
    end
}

-- 8. Clock Potion
SMODS.Consumable {
    key = 'potion_reloj',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 2, y = 1 },
    cost = 5,
    loc_txt = {
        name = 'Clock Potion',
        text = {
            "Returns cards from your {C:attention}last played hand{}",
            "back to hand, and grants",
            "{C:blue}+1 Hand{} in the next round"
        }
    },
    can_use = function(self, card)
        return G.STATE == G.STATES.SELECTING_HAND and G.GAME.last_played_hand_cards and #G.GAME.last_played_hand_cards > 0
    end,
    use = function(self, card, area, copier)
        G.GAME.potion_reloj_pending_hands = (G.GAME.potion_reloj_pending_hands or 0) + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.4, 0.6)
                local returned_count = 0
                if G.GAME.last_played_hand_cards and G.discard and G.hand then
                    for _, target in ipairs(G.GAME.last_played_hand_cards) do
                        for i = #G.discard.cards, 1, -1 do
                            local dc = G.discard.cards[i]
                            if dc == target then
                                dc.states.visible = true
                                dc.states.drag.can = true
                                dc.states.collide.can = true
                                dc.facing = 'front'
                                G.discard:remove_card(dc)
                                G.hand:emplace(dc)
                                returned_count = returned_count + 1
                                break
                            end
                        end
                    end
                end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Rewind! +' .. returned_count, colour = G.C.BLUE })
                return true
            end
        }))
    end
}

-- Potion Engine Hooks (Rayo, Reloj & Estiramiento reset)
local card_play_ref = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e)
    if G.hand and G.hand.highlighted then
        G.GAME.last_played_hand_cards = {}
        for _, c in ipairs(G.hand.highlighted) do
            table.insert(G.GAME.last_played_hand_cards, c)
        end
    end

    if G.GAME and G.GAME.potion_rayo_active and G.hand and G.hand.highlighted then
        local enhs = { G.P_CENTERS.m_bonus, G.P_CENTERS.m_mult, G.P_CENTERS.m_wild, G.P_CENTERS.m_glass, G.P_CENTERS.m_steel, G.P_CENTERS.m_gold, G.P_CENTERS.m_lucky }
        for _, c in ipairs(G.hand.highlighted) do
            local chosen_enh = pseudorandom_element(enhs, pseudoseed('potion_rayo_enh'))
            c:set_ability(chosen_enh)
            if pseudorandom('potion_rayo_destroy') < 0.2 then
                c.potion_rayo_destruct = true
            end
        end
        G.GAME.potion_rayo_active = nil
    end

    card_play_ref(e)

    -- Reset Estiramiento if active
    if G.GAME and G.GAME.potion_estiramiento_active then
        if G.hand and G.hand.config then
            G.hand.config.highlighted_limit = 5
        end
        G.GAME.potion_estiramiento_active = nil
    end
end

-- Hook scoring completion to dissolve rayo destruct cards
local eval_card_ref = G.FUNCS.evaluate_play
if eval_card_ref then
    G.FUNCS.evaluate_play = function(e)
        eval_card_ref(e)
        if G.play and G.play.cards then
            for _, c in ipairs(G.play.cards) do
                if c.potion_rayo_destruct then
                    c.potion_rayo_destruct = nil
                    c:start_dissolve()
                end
            end
        end
    end
end

-- Hook joker calculation for Pocion de Espejo (retrigger rightmost joker)
local orig_calculate_joker = Card.calculate_joker
function Card:calculate_joker(context)
    local ret = orig_calculate_joker(self, context)
    if G.GAME and G.GAME.potion_espejo_active and not context.potion_espejo_retrigger and not context.retrigger_joker_check then
        if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
            local rightmost = G.jokers.cards[#G.jokers.cards]
            if self == rightmost and not self.debuff then
                local ctx_copy = {}
                for k, v in pairs(context) do ctx_copy[k] = v end
                ctx_copy.potion_espejo_retrigger = true
                local ret2 = orig_calculate_joker(self, ctx_copy)
                if ret2 then
                    card_eval_status_text(self, 'extra', nil, nil, nil, { message = 'Espejo!', colour = G.C.PURPLE })
                    if type(ret) == 'table' and type(ret2) == 'table' then
                        if ret2.chips then ret.chips = (ret.chips or 0) + ret2.chips end
                        if ret2.mult then ret.mult = (ret.mult or 0) + ret2.mult end
                        if ret2.x_mult or ret2.Xmult then
                            local xm1 = ret.x_mult or ret.Xmult or 1
                            local xm2 = ret2.x_mult or ret2.Xmult or 1
                            ret.x_mult = xm1 * xm2
                        end
                        if ret2.dollars then ret.dollars = (ret.dollars or 0) + ret2.dollars end
                    elseif not ret then
                        ret = ret2
                    end
                end
            end
        end
    end
    return ret
end

-- Hook new_round for Pocion de Reloj (+1 mano siguiente ronda)
if new_round then
    local orig_new_round = new_round
    function new_round()
        orig_new_round()
        if G.GAME and G.GAME.potion_reloj_pending_hands and G.GAME.potion_reloj_pending_hands > 0 then
            ease_hands_played(G.GAME.potion_reloj_pending_hands)
            G.GAME.potion_reloj_pending_hands = 0
        end
    end
end

-- Hook end_round for Pocion de Mercurio ($1 por mano restante al ganar la Ciega) y reset de flags
if end_round then
    local orig_end_round = end_round
    function end_round()
        if G.GAME and G.GAME.potion_mercurio_active and G.GAME.blind and (G.GAME.chips >= G.GAME.blind.chips) then
            local left = (G.GAME.current_round and G.GAME.current_round.hands_left) or 0
            if left > 0 then
                ease_dollars(left)
                card_eval_status_text(G.deck or G.hand, 'extra', nil, nil, nil, { message = '+$' .. left, colour = G.C.MONEY })
            end
        end
        if G.GAME then
            G.GAME.potion_mercurio_active = nil
            G.GAME.potion_espejo_active = nil
        end
        return orig_end_round()
    end
end

-- Helper to safely instantiate a Potion card without crash
function create_potion_card_safe(area, key_append)
    local card = nil
    if SMODS and SMODS.create_card then
        local ok, res = pcall(function()
            return SMODS.create_card({ set = 'Potion', area = area or G.consumeables, key_append = key_append or 'potion' })
        end)
        if ok and res then card = res end
    end
    if not card or not card.config then
        local valid_keys = {}
        local pool = (G.P_CENTER_POOLS and G.P_CENTER_POOLS['Potion']) or {}
        for _, c in ipairs(pool) do
            if c.key and G.P_CENTERS and G.P_CENTERS[c.key] then
                table.insert(valid_keys, c.key)
            end
        end
        if #valid_keys == 0 and G.P_CENTERS then
            for k, _ in pairs(G.P_CENTERS) do
                if string.find(k, 'potion_') then table.insert(valid_keys, k) end
            end
        end
        local chosen_key = (#valid_keys > 0) and pseudorandom_element(valid_keys, pseudoseed(key_append or 'potion_rnd')) or nil
        if chosen_key and G.P_CENTERS and G.P_CENTERS[chosen_key] then
            card = Card((area or G.consumeables).T.x, (area or G.consumeables).T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[chosen_key])
        end
    end
    if not card or not card.config then
        card = create_card('Spectral', area or G.consumeables, nil, nil, nil, nil, nil, 'potion_fallback')
    end
    return card
end

-- Hook G.FUNCS.can_play to respect dynamic highlighted_limit (e.g. 7 cards from Pocion de Estiramiento)
local orig_can_play = G.FUNCS.can_play
G.FUNCS.can_play = function(e)
    local max_highlighted = (G.hand and G.hand.config and G.hand.config.highlighted_limit) or 5
    if not G.hand or not G.hand.highlighted or #G.hand.highlighted <= 0 or (G.GAME and G.GAME.blind and G.GAME.blind.block_play) or #G.hand.highlighted > max_highlighted then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.BLUE
        e.config.button = 'play_cards_from_highlighted'
    end
end

-- Hook create_card_for_shop to allow Potions to appear in shop (boosted by Embrujo x2 and Caldero x4)
local orig_create_card_for_shop = create_card_for_shop
function create_card_for_shop(area)
    if area == G.shop_jokers and not (G.SETTINGS and G.SETTINGS.tutorial_progress and G.SETTINGS.tutorial_progress.forced_shop) then
        local forced_tag = nil
        if G.GAME and G.GAME.tags then
            for _, v in ipairs(G.GAME.tags) do
                if not forced_tag then
                    forced_tag = v:apply_to_run({ type = 'store_joker_create', area = area })
                    if forced_tag then return orig_create_card_for_shop(area) end
                end
            end
        end

        G.GAME.potion_rate = G.GAME.potion_rate or 1.2
        local mult = 1
        if G.GAME.used_vouchers and (G.GAME.used_vouchers.v_Witch_brew_caldero or G.GAME.used_vouchers.v_caldero or G.GAME.used_vouchers.caldero) then
            mult = 4
        elseif G.GAME.used_vouchers and (G.GAME.used_vouchers.v_Witch_brew_embrujo or G.GAME.used_vouchers.v_embrujo or G.GAME.used_vouchers.embrujo) then
            mult = 2
        end

        local cur_potion_rate = G.GAME.potion_rate * mult
        local total_rate = (G.GAME.joker_rate or 20) + (G.GAME.tarot_rate or 4) + (G.GAME.planet_rate or 4) + (G.GAME.playing_card_rate or 0) + (G.GAME.spectral_rate or 0) + cur_potion_rate
        local polled_rate = pseudorandom(pseudoseed('potion_shop' .. (G.GAME.round_resets and G.GAME.round_resets.ante or 1))) * total_rate

        if polled_rate <= cur_potion_rate then
            local card = create_potion_card_safe(area, 'sho_potion')
            if card then
                create_shop_card_ui(card, 'Potion', area)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if G.GAME and G.GAME.tags then
                            for _, v in ipairs(G.GAME.tags) do
                                if v:apply_to_run({ type = 'store_joker_modify', card = card }) then break end
                            end
                        end
                        return true
                    end
                }))
                return card
            end
        end
    end
    return orig_create_card_for_shop(area)
end

-- Hook check_for_buy_space: if Kyra is owned, Potions don't take consumable space
local orig_check_for_buy_space = G.FUNCS.check_for_buy_space
G.FUNCS.check_for_buy_space = function(card)
    local has_kyra = false
    if G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            if card_has_key(j, 'kyra') and not j.debuff then
                has_kyra = true
                break
            end
        end
    end

    if has_kyra and card and card.ability then
        if card.ability.set == 'Potion' then
            return true
        end
        if card.ability.consumeable and G.consumeables then
            local non_potion_count = 0
            for _, c in ipairs(G.consumeables.cards) do
                if not (c.ability and c.ability.set == 'Potion') then
                    if not (c.edition and c.edition.negative) then
                        non_potion_count = non_potion_count + 1
                    end
                end
            end
            local bonus = (card.edition and card.edition.negative) and 1 or 0
            if non_potion_count < G.consumeables.config.card_limit + bonus then
                return true
            end
            alert_no_space(card, G.consumeables)
            return false
        end
    end
    return orig_check_for_buy_space(card)
end

--------------------------------------------------------------------------------
-- POTION BACKPACK ("MOCHILA DE POCIONES") & KYRA'S SIMULATION LAB
--------------------------------------------------------------------------------

G.POUCH_SIM_STATE = {
    dialogue = "\"Welcome to my Alchemical Testing Lab! Pick or hover any potion to simulate its elemental reaction.\"",
    line1 = "\"Welcome to my Alchemical Testing Lab! Pick or hover",
    line2 = "any potion to simulate its reaction.\"",
    status = "Testing Ready"
}

local function set_pouch_dialogue(full_text)
    local l1, l2 = format_dialogue_lines(full_text, 50)
    G.POUCH_SIM_STATE.dialogue = full_text
    G.POUCH_SIM_STATE.line1 = l1
    G.POUCH_SIM_STATE.line2 = l2
end

-- Pouch Storage Functions
G.FUNCS.store_potion_in_pouch = function(e)
    local card = e and e.config and e.config.ref_table
    if not card or not card.ability or card.ability.set ~= 'Potion' then return end
    G.GAME.potion_pouch = G.GAME.potion_pouch or {}
    if #G.GAME.potion_pouch >= 6 then
        play_sound('cancel', 1)
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Pouch Full! (Max 6)', colour = G.C.RED })
        return
    end

    play_sound('cardSlide1', 1)
    card:juice_up(0.4, 0.4)
    
    local p_key = (card.config and card.config.center and card.config.center.key) or (card.ability and card.ability.key) or 'potion_estiramiento'
    local p_name = (card.ability and card.ability.name) or (card.config and card.config.center and card.config.center.name) or 'Potion'
    table.insert(G.GAME.potion_pouch, {
        key = p_key,
        name = p_name,
        cost = card.cost or 4
    })

    if card.area then
        card.area:remove_card(card)
    end
    card:remove()

    card_eval_status_text(G.consumeables or card, 'extra', nil, nil, nil, { message = '🎒 Stored in Pouch!', colour = HEX('2e8b57') })
end

G.FUNCS.withdraw_potion_from_pouch = function(e)
    local idx = e and e.config and e.config.ref_table and e.config.ref_table.idx
    if not idx or not G.GAME.potion_pouch or not G.GAME.potion_pouch[idx] then return end
    if G.consumeables and #G.consumeables.cards >= G.consumeables.config.card_limit then
        play_sound('cancel', 1)
        card_eval_status_text(G.consumeables, 'extra', nil, nil, nil, { message = 'Belt Full!', colour = G.C.RED })
        return
    end

    local entry = table.remove(G.GAME.potion_pouch, idx)
    play_sound('cardSlide2', 1)
    local final_key = entry.key
    if not (G.P_CENTERS and G.P_CENTERS[final_key]) then
        final_key = get_valid_joker_key(entry.key) or entry.key
    end
    local new_card = create_card('Potion', G.consumeables, nil, nil, nil, nil, final_key, 'pouch_withdraw')
    new_card:add_to_deck()
    G.consumeables:emplace(new_card)
    new_card:juice_up(0.5, 0.5)

    G.FUNCS.exit_overlay_menu()
    G.FUNCS.open_potion_pouch()
end

G.FUNCS.use_potion_from_pouch = function(e)
    local idx = e and e.config and e.config.ref_table and e.config.ref_table.idx
    if not idx or not G.GAME.potion_pouch or not G.GAME.potion_pouch[idx] then return end

    local entry = table.remove(G.GAME.potion_pouch, idx)
    play_sound('tarot1')
    local center = (G.P_CENTERS and G.P_CENTERS[entry.key]) or (G.P_CENTERS and G.P_CENTERS[get_valid_joker_key(entry.key) or ''])
    if center then
        local temp_card = Card(0, 0, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
        if center.use then
            center:use(temp_card, G.consumeables)
        elseif temp_card.use then
            temp_card:use(G.consumeables)
        end
        temp_card:remove()
    end

    G.FUNCS.exit_overlay_menu()
end

-- Hook card action buttons to inject [ 🎒 POUCH ] when inspecting any Potion
local orig_pouch_use_and_sell = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local t = orig_pouch_use_and_sell(card)
    if card and card.ability and card.ability.set == 'Potion' and card.area == G.consumeables then
        local pouch_button = {
            n = G.UIT.R,
            config = { align = 'cl' },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cr" },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                ref_table = card,
                                align = "cm",
                                padding = 0.1,
                                r = 0.08,
                                minw = 1.25,
                                hover = true,
                                shadow = true,
                                colour = HEX('2e8b57'),
                                one_press = true,
                                button = 'store_potion_in_pouch'
                            },
                            nodes = {
                                { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                {
                                    n = G.UIT.C,
                                    config = { align = "cm" },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", maxw = 1.25 },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "🎒 POUCH", colour = G.C.WHITE, scale = 0.38, shadow = true } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if t and t.nodes and t.nodes[1] and t.nodes[1].nodes then
            table.insert(t.nodes[1].nodes, pouch_button)
        end
    end
    return t
end

-- Persistent [ 🎒 POUCH ] button placed directly below Consumables (G.consumeables)
local function create_pouch_hud_button()
    if not (G.consumeables and G.consumeables.T) then return end
    if G.HUD_pouch and not G.HUD_pouch.REMOVED then return end

    local t = {
        n = G.UIT.ROOT,
        config = { align = "cm", padding = 0, colour = G.C.CLEAR },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    id = 'potion_pouch_hud_button',
                    align = "cm",
                    minh = 0.44,
                    minw = 1.45,
                    padding = 0.05,
                    r = 0.1,
                    hover = true,
                    colour = HEX('2e8b57'),
                    button = "open_potion_pouch",
                    shadow = true
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", maxw = 1.4 },
                        nodes = {
                            { n = G.UIT.T, config = { text = "🎒 POUCH", scale = 0.34, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                        }
                    }
                }
            }
        }
    }

    G.HUD_pouch = UIBox{
        definition = t,
        config = {
            align = "bm",
            offset = { x = 0, y = 0.18 },
            major = G.consumeables,
            bond = 'Weak'
        }
    }
end

if Game and Game.update then
    local orig_game_update_pouch = Game.update
    function Game:update(dt)
        orig_game_update_pouch(self, dt)
        if G.STAGE == G.STAGES.RUN and G.consumeables then
            if not G.HUD_pouch or G.HUD_pouch.REMOVED then
                create_pouch_hud_button()
            end
        elseif G.HUD_pouch then
            G.HUD_pouch:remove()
            G.HUD_pouch = nil
        end
    end
end

-- Helper to generate virtual cards for the simulation hand
local function make_sim_card(area, code)
    local sim_w = G.CARD_W * 0.50
    local sim_h = G.CARD_H * 0.50
    local fallback_codes = {'S_A','H_K','D_Q','C_J','S_T','H_9','D_8','C_7','S_6','H_5','D_4','C_3','S_2'}
    code = code or pseudorandom_element(fallback_codes, pseudoseed('sim_card'))
    local pcard = (G.P_CARDS and G.P_CARDS[code]) or (G.P_CARDS and pseudorandom_element(G.P_CARDS)) or G.P_CARDS.empty
    local c = Card(0, 0, sim_w, sim_h, pcard, G.P_CENTERS.c_base)
    c.facing = 'front'
    area:emplace(c)
    return c
end

-- Kyra speaking wobble animation
local function kyra_speak()
    if G.pouch_kyra_card then
        G.pouch_kyra_card:juice_up(0.7, 0.7)
        for k = 1, 3 do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.09,
                func = function()
                    if G.pouch_kyra_card then
                        G.pouch_kyra_card:juice_up(0.35, 0.45)
                    end
                    return true
                end
            }))
        end
    end
end

-- Simulation: Kyra tests potion reaction on virtual mini-hand (8 cards, plays & refreshes)
G.FUNCS.pouch_test_potion = function(e)
    if not e or not e.config or not e.config.ref_table then return end
    local pot_key = e.config.ref_table.key or 'potion_rayo'
    if not G.pouch_sim_hand_area or not G.pouch_sim_hand_area.cards then return end

    -- Reset cards if previous simulation spawned Jokers or modified hand size
    local has_joker = false
    for _, c in ipairs(G.pouch_sim_hand_area.cards) do
        if c.ability and c.ability.set == 'Joker' then has_joker = true break end
    end
    if (has_joker or #G.pouch_sim_hand_area.cards < 8) and pot_key ~= 'potion_amalgama' and pot_key ~= 'potion_espejo' then
        for i = #G.pouch_sim_hand_area.cards, 1, -1 do
            local c = G.pouch_sim_hand_area.cards[i]
            G.pouch_sim_hand_area:remove_card(c)
            c:remove()
        end
        local default_codes = { 'S_A', 'H_K', 'D_Q', 'C_J', 'S_T', 'H_9', 'D_8', 'C_7' }
        for _, cd in ipairs(default_codes) do
            make_sim_card(G.pouch_sim_hand_area, cd)
        end
    end

    -- Reset virtual simulation cards state
    for _, c in ipairs(G.pouch_sim_hand_area.cards) do
        c:highlight(false)
        c.states.visible = true
        c.facing = 'front'
        c.edition = nil
        c:set_ability(G.P_CENTERS.c_base)
    end

    if string.find(pot_key, 'rayo', 1, true) then
        set_pouch_dialogue("\"Lightning Potion: Played cards ignite with elemental enhancements! 1 in 5 cards risks destruction.\"")
        G.POUCH_SIM_STATE.status = "⚡ Simulation: Hand Played & Lightning Infusion!"
        kyra_speak()
        play_sound('tarot2', 1)
        local enhs = { G.P_CENTERS.m_bonus, G.P_CENTERS.m_mult, G.P_CENTERS.m_glass, G.P_CENTERS.m_steel, G.P_CENTERS.m_lucky }
        -- Select and play first 5 cards
        for i = 1, math.min(5, #G.pouch_sim_hand_area.cards) do
            local c = G.pouch_sim_hand_area.cards[i]
            c:highlight(true)
            local enh = pseudorandom_element(enhs, pseudoseed('sim_rayo_' .. i))
            c:set_ability(enh)
            c:juice_up(0.5, 0.5)
        end
        if #G.pouch_sim_hand_area.cards >= 5 then
            local doomed = G.pouch_sim_hand_area.cards[5]
            doomed:juice_up(0.7, 0.8)
            card_eval_status_text(doomed, 'extra', nil, nil, nil, { message = '⚡ 1 in 5 Destroyed!', colour = G.C.GOLD })
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    doomed:start_dissolve()
                    return true
                end
            }))
        end
        -- Refill played cards with fresh cards from the mini deck
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.8,
            func = function()
                if G.pouch_sim_hand_area and G.pouch_sim_hand_area.cards then
                    for _, c in ipairs(G.pouch_sim_hand_area.cards) do
                        c:highlight(false)
                    end
                    while #G.pouch_sim_hand_area.cards < 8 do
                        make_sim_card(G.pouch_sim_hand_area)
                    end
                end
                return true
            end
        }))
    elseif string.find(pot_key, 'estiramiento', 1, true) then
        set_pouch_dialogue("\"Stretch Potion: Your mental reach expands! Up to 7 cards are selected and played together in a single hand!\"")
        G.POUCH_SIM_STATE.status = "✋ Simulation: 7-Card Hand Played!"
        kyra_speak()
        play_sound('tarot1', 1)
        for i = 1, math.min(7, (G.pouch_sim_hand_area.cards and #G.pouch_sim_hand_area.cards or 0)) do
            local c = G.pouch_sim_hand_area.cards[i]
            c:highlight(true)
            c:juice_up(0.35, 0.35)
        end
        if G.pouch_sim_hand_area.cards and G.pouch_sim_hand_area.cards[1] then
            card_eval_status_text(G.pouch_sim_hand_area.cards[1], 'extra', nil, nil, nil, { message = '7 Cards Limit!', colour = G.C.GREEN })
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.6,
            func = function()
                if G.pouch_sim_hand_area and G.pouch_sim_hand_area.cards then
                    for _, c in ipairs(G.pouch_sim_hand_area.cards) do c:highlight(false) end
                end
                return true
            end
        }))
    elseif string.find(pot_key, 'ventisca', 1, true) then
        set_pouch_dialogue("\"Blizzard Potion: The winter vortex cleanses the board! 8 brand new cards are dealt from the Red Deck!\"")
        G.POUCH_SIM_STATE.status = "❄ Simulation: Blizzard Redraw (8 Fresh Cards)!"
        kyra_speak()
        play_sound('cardFan2', 1)
        for _, c in ipairs(G.pouch_sim_hand_area.cards) do
            c:juice_up(0.5, 0.6)
            c.facing = 'back'
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.35,
            func = function()
                if G.pouch_sim_hand_area and G.pouch_sim_hand_area.cards then
                    -- Empty hand and deal 8 completely new different cards
                    for i = #G.pouch_sim_hand_area.cards, 1, -1 do
                        local old = G.pouch_sim_hand_area.cards[i]
                        G.pouch_sim_hand_area:remove_card(old)
                        old:remove()
                    end
                    local fresh_codes = { 'H_A', 'C_K', 'S_Q', 'D_J', 'H_T', 'C_9', 'S_8', 'D_7' }
                    for _, cd in ipairs(fresh_codes) do
                        local nc = make_sim_card(G.pouch_sim_hand_area, cd)
                        nc:juice_up(0.4, 0.4)
                    end
                    play_sound('cardSlide1', 1)
                end
                return true
            end
        }))
    elseif string.find(pot_key, 'furia', 1, true) then
        set_pouch_dialogue("\"Fury Potion: Pure alchemical incineration! Disintegrate up to 3 unwanted cards directly from your hand!\"")
        G.POUCH_SIM_STATE.status = "🔥 Simulation: 3 Cards Incinerated & Refilled!"
        kyra_speak()
        play_sound('slice1', 1)
        for i = 1, math.min(3, (G.pouch_sim_hand_area.cards and #G.pouch_sim_hand_area.cards or 0)) do
            local c = G.pouch_sim_hand_area.cards[i]
            c:highlight(true)
            c:juice_up(0.5, 0.5)
            card_eval_status_text(c, 'extra', nil, nil, nil, { message = 'Dissolved!', colour = G.C.RED })
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    c:start_dissolve()
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                if G.pouch_sim_hand_area and G.pouch_sim_hand_area.cards then
                    while #G.pouch_sim_hand_area.cards < 8 do
                        make_sim_card(G.pouch_sim_hand_area)
                    end
                end
                return true
            end
        }))
    elseif string.find(pot_key, 'mercurio', 1, true) then
        set_pouch_dialogue("\"Mercury Potion: Liquid gold momentum! +1 Hand and Discard now, plus $1 bounty per remaining hand on Blind win!\"")
        G.POUCH_SIM_STATE.status = "💰 Simulation: +1 Hand, +1 Discard, +$1 per Hand!"
        kyra_speak()
        play_sound('coin1', 1)
        for _, c in ipairs(G.pouch_sim_hand_area.cards) do
            c:juice_up(0.3, 0.4)
        end
        if G.pouch_sim_hand_area.cards[1] then
            card_eval_status_text(G.pouch_sim_hand_area.cards[1], 'extra', nil, nil, nil, { message = '+$1 per hand!', colour = G.C.MONEY })
        end
    elseif string.find(pot_key, 'espejo', 1, true) then
        set_pouch_dialogue("\"Mirror Potion: The rightmost Joker echoes its calculation! Watch Jolly Joker trigger twice on this Pair!\"")
        G.POUCH_SIM_STATE.status = "🪞 Simulation: Pair Played + Rightmost Joker Retrigger!"
        kyra_speak()
        play_sound('tarot2', 1)

        -- 1. Remove current cards to set up real play demonstration
        for i = #G.pouch_sim_hand_area.cards, 1, -1 do
            local old = G.pouch_sim_hand_area.cards[i]
            G.pouch_sim_hand_area:remove_card(old)
            old:remove()
        end

        local sim_w = G.CARD_W * 0.50
        local sim_h = G.CARD_H * 0.50

        -- 2. Spawn Joker (Comodín) and Jolly Joker (Comodín Alegre, rightmost)
        local c_joker = (G.P_CENTERS and G.P_CENTERS.j_joker) or G.P_CENTERS.c_base
        local c_jolly = (G.P_CENTERS and G.P_CENTERS.j_jolly) or (G.P_CENTERS and G.P_CENTERS.j_half) or c_joker

        local j1 = Card(0, 0, sim_w, sim_h, G.P_CARDS.empty, c_joker)
        j1.facing = 'front'
        G.pouch_sim_hand_area:emplace(j1)
        j1:juice_up(0.5, 0.5)

        local j2 = Card(0, 0, sim_w, sim_h, G.P_CARDS.empty, c_jolly)
        j2.facing = 'front'
        G.pouch_sim_hand_area:emplace(j2)
        j2:juice_up(0.5, 0.5)

        -- 3. Spawn 5 playing cards with a Pair (Ace of Spades, Ace of Hearts, King of Diamonds, 10 of Clubs, 7 of Spades)
        local pair_codes = { 'S_A', 'H_A', 'D_K', 'C_T', 'S_7' }
        local play_cards = {}
        for _, cd in ipairs(pair_codes) do
            local c = make_sim_card(G.pouch_sim_hand_area, cd)
            table.insert(play_cards, c)
        end

        card_eval_status_text(j1, 'extra', nil, nil, nil, { message = 'Joker (+4)', colour = G.C.BLUE })
        card_eval_status_text(j2, 'extra', nil, nil, nil, { message = 'Rightmost 🪞', colour = G.C.PURPLE })

        -- 4. Play the Pair (select Ace of Spades + Ace of Hearts)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.6,
            func = function()
                play_sound('cardSlide1', 1)
                if play_cards[1] then play_cards[1]:highlight(true); play_cards[1]:juice_up(0.4, 0.4) end
                if play_cards[2] then play_cards[2]:highlight(true); play_cards[2]:juice_up(0.4, 0.4) end
                card_eval_status_text(play_cards[1] or j2, 'extra', nil, nil, nil, { message = 'Pair Played!', colour = G.C.ORANGE })
                return true
            end
        }))

        -- 5. Score Pair: +20 Chips
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.6,
            func = function()
                play_sound('chips1', 1)
                if play_cards[1] then play_cards[1]:juice_up(0.3, 0.3) end
                if play_cards[2] then play_cards[2]:juice_up(0.3, 0.3) end
                card_eval_status_text(play_cards[2] or j2, 'extra', nil, nil, nil, { message = '+20 Chips', colour = G.C.CHIPS })
                return true
            end
        }))

        -- 6. Trigger Comodín (Left Joker): +4 Mult
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.6,
            func = function()
                play_sound('chips2', 1)
                if j1 then
                    j1:juice_up(0.7, 0.7)
                    card_eval_status_text(j1, 'extra', nil, nil, nil, { message = '+4 Mult', colour = G.C.MULT })
                end
                return true
            end
        }))

        -- 7. Trigger Comodín Alegre (Rightmost Joker, 1st trigger): +8 Mult for Pair
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.6,
            func = function()
                play_sound('multhit1', 1)
                if j2 then
                    j2:juice_up(0.7, 0.7)
                    card_eval_status_text(j2, 'extra', nil, nil, nil, { message = '+8 Mult (Pair!)', colour = G.C.MULT })
                end
                return true
            end
        }))

        -- 8. Mirror Potion Retrigger on Rightmost Joker (Jolly Joker): +8 Mult again!
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                play_sound('tarot2', 1)
                if j2 then
                    j2:juice_up(0.9, 0.9)
                    card_eval_status_text(j2, 'extra', nil, nil, nil, { message = '🪞 Mirror Retrigger! +8 Mult', colour = G.C.PURPLE })
                end
                return true
            end
        }))

        -- 9. Clean up and restore default 8 cards
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 2.4,
            func = function()
                if G.pouch_sim_hand_area and G.pouch_sim_hand_area.cards then
                    for i = #G.pouch_sim_hand_area.cards, 1, -1 do
                        local c = G.pouch_sim_hand_area.cards[i]
                        G.pouch_sim_hand_area:remove_card(c)
                        c:remove()
                    end
                    local default_codes = { 'S_A', 'H_K', 'D_Q', 'C_J', 'S_T', 'H_9', 'D_8', 'C_7' }
                    for _, cd in ipairs(default_codes) do
                        make_sim_card(G.pouch_sim_hand_area, cd)
                    end
                    if G.POUCH_SIM_STATE then
                        G.POUCH_SIM_STATE.status = "Testing Ready"
                        set_pouch_dialogue("\"Pick or hover any potion to simulate its elemental reaction on this virtual mini-hand.\"")
                    end
                end
                return true
            end
        }))
    elseif string.find(pot_key, 'reloj', 1, true) then
        set_pouch_dialogue("\"Clock Potion: Chrono-alchemy! Returns cards from your last played hand and reserves +1 Hand next round!\"")
        G.POUCH_SIM_STATE.status = "⏰ Simulation: Hand Rewind & Future Turn!"
        kyra_speak()
        play_sound('cardSlide1', 1)
        for i = 1, math.min(5, (G.pouch_sim_hand_area.cards and #G.pouch_sim_hand_area.cards or 0)) do
            local c = G.pouch_sim_hand_area.cards[i]
            c:highlight(true)
            c:juice_up(0.4, 0.4)
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                if G.pouch_sim_hand_area and G.pouch_sim_hand_area.cards then
                    if G.pouch_sim_hand_area.cards[1] then
                        card_eval_status_text(G.pouch_sim_hand_area.cards[1], 'extra', nil, nil, nil, { message = 'Rewound!', colour = G.C.BLUE })
                    end
                    for _, c in ipairs(G.pouch_sim_hand_area.cards) do c:highlight(false) end
                end
                return true
            end
        }))
    elseif string.find(pot_key, 'amalgama', 1, true) then
        set_pouch_dialogue("\"Amalgam Potion: Two Jokers fuse into higher power! The resulting creation inherits the finest edition!\"")
        G.POUCH_SIM_STATE.status = "✨ Simulation: Joker Fusion & Edition Inheritance!"
        kyra_speak()
        play_sound('tarot1', 1)

        -- 1. Remove all current cards from mini hand
        for i = #G.pouch_sim_hand_area.cards, 1, -1 do
            local old = G.pouch_sim_hand_area.cards[i]
            G.pouch_sim_hand_area:remove_card(old)
            old:remove()
        end

        -- 2. Pick 2 random base Joker centers
        local available_jokers = {}
        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker then
            for _, c in ipairs(G.P_CENTER_POOLS.Joker) do
                if not c.no_pool_flag and type(c.rarity) == 'number' and c.rarity <= 2 and c.key ~= 'j_joker' then
                    table.insert(available_jokers, c)
                end
            end
        end
        local fallback_keys = { 'j_greedy_joker', 'j_lusty_joker', 'j_wrathful_joker', 'j_gluttenous_joker', 'j_half', 'j_popcorn', 'j_ramen', 'j_dusk' }
        local c1_center = (#available_jokers > 0 and pseudorandom_element(available_jokers, pseudoseed('am_sim1'))) or (G.P_CENTERS[pseudorandom_element(fallback_keys, pseudoseed('am_fb1'))] or G.P_CENTERS.j_joker)
        local c2_center = (#available_jokers > 0 and pseudorandom_element(available_jokers, pseudoseed('am_sim2'))) or (G.P_CENTERS[pseudorandom_element(fallback_keys, pseudoseed('am_fb2'))] or G.P_CENTERS.j_joker)

        -- 3. Assign random editions (guarantee at least one has an edition to showcase inheritance)
        local ed1 = pseudorandom_element({ { foil = true }, { holo = true }, nil }, pseudoseed('am_ed1'))
        local ed2 = pseudorandom_element({ { holo = true }, { polychrome = true }, nil }, pseudoseed('am_ed2'))
        if not ed1 and not ed2 then
            ed1 = pseudorandom_element({ { foil = true }, { holo = true }, { polychrome = true } }, pseudoseed('am_force_ed'))
        end

        -- Best edition calculation
        local function calc_fusion_ed(e1, e2)
            local t1 = e1 and (e1.polychrome and 'polychrome' or (e1.holo and 'holo' or (e1.foil and 'foil')))
            local t2 = e2 and (e2.polychrome and 'polychrome' or (e2.holo and 'holo' or (e2.foil and 'foil')))
            if t1 == 'polychrome' or t2 == 'polychrome' then
                return { polychrome = true }, "Polychrome"
            elseif (t1 == 'holo' and t2 == 'holo') or (t1 == 'foil' and t2 == 'holo') or (t1 == 'holo' and t2 == 'foil') then
                return { polychrome = true }, "Polychrome (Upgraded!)"
            elseif t1 == 'holo' or t2 == 'holo' then
                return { holo = true }, "Holographic"
            elseif t1 == 'foil' and t2 == 'foil' then
                return { holo = true }, "Holographic (Upgraded!)"
            elseif t1 == 'foil' or t2 == 'foil' then
                return { foil = true }, "Foil"
            end
            return nil, "None"
        end
        local best_ed, ed_name = calc_fusion_ed(ed1, ed2)

        local sim_w = G.CARD_W * 0.50
        local sim_h = G.CARD_H * 0.50
        local j1 = Card(0, 0, sim_w, sim_h, G.P_CARDS.empty, c1_center)
        j1.facing = 'front'
        if ed1 then j1:set_edition(ed1, true) end
        G.pouch_sim_hand_area:emplace(j1)
        j1:juice_up(0.6, 0.6)

        local j2 = Card(0, 0, sim_w, sim_h, G.P_CARDS.empty, c2_center)
        j2.facing = 'front'
        if ed2 then j2:set_edition(ed2, true) end
        G.pouch_sim_hand_area:emplace(j2)
        j2:juice_up(0.6, 0.6)

        local ed1_str = ed1 and (ed1.polychrome and "Poly" or (ed1.holo and "Holo" or "Foil")) or "Base"
        local ed2_str = ed2 and (ed2.polychrome and "Poly" or (ed2.holo and "Holo" or "Foil")) or "Base"
        card_eval_status_text(j1, 'extra', nil, nil, nil, { message = ed1_str, colour = G.C.BLUE })
        card_eval_status_text(j2, 'extra', nil, nil, nil, { message = ed2_str, colour = G.C.BLUE })

        -- 4. Melting / Dissolve fusion effect
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('polychrome1', 1)
                if j1 then j1:juice_up(0.8, 0.8); j1:start_dissolve() end
                if j2 then j2:juice_up(0.8, 0.8); j2:start_dissolve() end
                return true
            end
        }))

        -- 5. Spawn fused resulting Joker inheriting the best edition
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.6,
            func = function()
                if G.pouch_sim_hand_area then
                    local rare_jokers = {}
                    if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker then
                        for _, c in ipairs(G.P_CENTER_POOLS.Joker) do
                            if not c.no_pool_flag and ((type(c.rarity) == 'number' and c.rarity >= 3) or type(c.rarity) == 'string') then
                                table.insert(rare_jokers, c)
                            end
                        end
                    end
                    local res_center = (#rare_jokers > 0 and pseudorandom_element(rare_jokers, pseudoseed('am_res')))
                        or G.P_CENTERS.j_blueprint or G.P_CENTERS.j_brainstorm or G.P_CENTERS.j_joker

                    local res_joker = Card(0, 0, sim_w, sim_h, G.P_CARDS.empty, res_center)
                    res_joker.facing = 'front'
                    if best_ed then
                        res_joker:set_edition(best_ed, true)
                    end
                    G.pouch_sim_hand_area:emplace(res_joker)
                    res_joker:juice_up(0.9, 0.9)
                    play_sound('tarot2', 1)

                    card_eval_status_text(res_joker, 'extra', nil, nil, nil, { message = '★ ' .. ed_name .. ' Fusion!', colour = HEX('8a2be2') })

                    -- 6. Restore 8 normal playing cards after 2.4s
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 2.4,
                        func = function()
                            if G.pouch_sim_hand_area and G.pouch_sim_hand_area.cards then
                                for i = #G.pouch_sim_hand_area.cards, 1, -1 do
                                    local c = G.pouch_sim_hand_area.cards[i]
                                    G.pouch_sim_hand_area:remove_card(c)
                                    c:remove()
                                end
                                local default_codes = { 'S_A', 'H_K', 'D_Q', 'C_J', 'S_T', 'H_9', 'D_8', 'C_7' }
                                for _, cd in ipairs(default_codes) do
                                    make_sim_card(G.pouch_sim_hand_area, cd)
                                end
                                if G.POUCH_SIM_STATE then
                                    G.POUCH_SIM_STATE.status = "Testing Ready"
                                    set_pouch_dialogue("\"Pick or hover any potion to simulate its elemental reaction on this virtual mini-hand.\"")
                                end
                            end
                            return true
                        end
                    }))
                end
                return true
            end
        }))
    end
end

-- Close Potion Backpack & reset temporary simulation cardareas
G.FUNCS.close_potion_pouch = function(e)
    if G.pouch_temp_areas then
        for _, area in ipairs(G.pouch_temp_areas) do
            area:remove()
        end
        G.pouch_temp_areas = nil
    end
    G.pouch_sim_hand_area = nil
    G.pouch_kyra_card = nil
    if G.FUNCS.exit_overlay_menu then
        G.FUNCS.exit_overlay_menu(e)
    end
end

-- Open Potion Backpack & Kyra's Testing Lab UI
G.FUNCS.open_potion_pouch = function()
    if not (create_UIBox_generic_options and G.FUNCS.overlay_menu) then return end

    if G.pouch_temp_areas then
        for _, area in ipairs(G.pouch_temp_areas) do
            area:remove()
        end
        G.pouch_temp_areas = nil
    end
    G.pouch_sim_hand_area = nil
    G.pouch_kyra_card = nil
    G.pouch_temp_areas = {}

    G.GAME.potion_pouch = G.GAME.potion_pouch or {}

    -- 1. Kyra portrait with speaking wobble hook
    local kyra_center = get_valid_joker_key('kyra')
    local kyra_scale = 0.65
    local kyra_w = G.CARD_W * kyra_scale
    local kyra_h = G.CARD_H * kyra_scale
    local kyra_area = CardArea(0, 0, kyra_w, kyra_h, { card_limit = 1, type = 'title', highlight_limit = 0, card_w = kyra_w })
    table.insert(G.pouch_temp_areas, kyra_area)
    local kyra_card = Card(0, 0, kyra_w, kyra_h, G.P_CARDS.empty, (kyra_center and G.P_CENTERS[kyra_center]) or G.P_CENTERS.j_joker)
    kyra_card.facing = 'front'
    kyra_area:emplace(kyra_card)
    G.pouch_kyra_card = kyra_card

    -- 2. Virtual mini-deck (Red Deck texture) and 8-card mini-hand
    local sim_w = G.CARD_W * 0.50
    local sim_h = G.CARD_H * 0.50

    local sim_deck_area = CardArea(0, 0, sim_w, sim_h, { card_limit = 5, type = 'deck', highlight_limit = 0, card_w = sim_w })
    table.insert(G.pouch_temp_areas, sim_deck_area)
    local red_center = (G.P_CENTERS and G.P_CENTERS.b_red) or (G.P_CENTERS and G.P_CENTERS.c_base)
    local deck_dummy = Card(0, 0, sim_w, sim_h, G.P_CARDS.empty, red_center, { bypass_back = (red_center and red_center.pos) or {x=0, y=0}, viewed_back = true })
    deck_dummy.facing = 'back'
    deck_dummy.sprite_facing = 'back'
    sim_deck_area:emplace(deck_dummy)

    -- 8-Card mini hand
    local sim_hand_area = CardArea(0, 0, 8.8 * sim_w, sim_h * 1.08, { card_limit = 8, type = 'hand', highlight_limit = 8, card_w = sim_w })
    table.insert(G.pouch_temp_areas, sim_hand_area)
    G.pouch_sim_hand_area = sim_hand_area

    local initial_codes = { 'S_A', 'H_K', 'D_Q', 'C_J', 'S_T', 'H_9', 'D_8', 'C_7' }
    for _, code in ipairs(initial_codes) do
        make_sim_card(sim_hand_area, code)
    end

    -- 3. Stored potions in pouch (with [ ⮌ PULL ] button underneath each potion)
    local stored_nodes = {}
    if #G.GAME.potion_pouch == 0 then
        table.insert(stored_nodes, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.15 },
            nodes = {
                { n = G.UIT.T, config = { text = "Backpack is empty. Inspect any Potion in your belt and click [ 🎒 POUCH ] to store it!", scale = 0.36, colour = G.C.UI.TEXT_INACTIVE } }
            }
        })
    else
        local pot_cols = {}
        for i, item in ipairs(G.GAME.potion_pouch) do
            local p_center = G.P_CENTERS[item.key] or G.P_CENTERS[get_valid_joker_key(item.key) or '']
            local item_area = CardArea(0, 0, sim_w * 0.9, sim_h * 0.9, { card_limit = 1, type = 'title', highlight_limit = 0, card_w = sim_w * 0.9 })
            table.insert(G.pouch_temp_areas, item_area)
            local item_card = Card(0, 0, sim_w * 0.9, sim_h * 0.9, G.P_CARDS.empty, p_center or G.P_CENTERS.c_base)
            item_card.facing = 'front'
            item_area:emplace(item_card)

            table.insert(pot_cols, {
                n = G.UIT.C,
                config = { align = "cm", padding = 0.08, colour = G.C.L_BLACK, r = 0.1, outline = 0.03, outline_colour = HEX('2e8b57') },
                nodes = {
                    { n = G.UIT.O, config = { object = item_area } },
                    { n = G.UIT.R, config = { align = "cm", maxw = 1.3 }, nodes = {
                        { n = G.UIT.T, config = { text = item.name or "Potion", scale = 0.32, colour = G.C.WHITE, shadow = true } }
                    }},
                    { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "cm", padding = 0.06, minw = 0.65, r = 0.08, hover = true, colour = G.C.BLUE, button = 'withdraw_potion_from_pouch', ref_table = { idx = i }, shadow = true },
                            nodes = { { n = G.UIT.T, config = { text = "⮌ PULL", scale = 0.30, colour = G.C.WHITE } } }
                        },
                        { n = G.UIT.B, config = { w = 0.06, h = 0.1 } },
                        {
                            n = G.UIT.C,
                            config = { align = "cm", padding = 0.06, minw = 0.65, r = 0.08, hover = true, colour = G.C.GREEN, button = 'use_potion_from_pouch', ref_table = { idx = i }, shadow = true },
                            nodes = { { n = G.UIT.T, config = { text = "🧪 USE", scale = 0.30, colour = G.C.WHITE } } }
                        }
                    }}
                }
            })
        end
        table.insert(stored_nodes, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.05 },
            nodes = pot_cols
        })
    end

    -- 4. Potion Catalog Simulator Buttons
    local test_potions = {
        { key = 'potion_rayo', name = 'Lightning' },
        { key = 'potion_estiramiento', name = 'Stretch' },
        { key = 'potion_ventisca', name = 'Blizzard' },
        { key = 'potion_furia', name = 'Fury' },
        { key = 'potion_mercurio', name = 'Mercury' },
        { key = 'potion_espejo', name = 'Mirror' },
        { key = 'potion_reloj', name = 'Clock' },
        { key = 'potion_amalgama', name = 'Amalgam' }
    }
    local catalog_buttons = {}
    for _, tp in ipairs(test_potions) do
        table.insert(catalog_buttons, {
            n = G.UIT.C,
            config = {
                align = "cm",
                padding = 0.06,
                minw = 1.05,
                minh = 0.45,
                r = 0.08,
                hover = true,
                colour = HEX('2e8b57'),
                button = 'pouch_test_potion',
                ref_table = { key = tp.key, name = tp.name },
                shadow = true
            },
            nodes = {
                { n = G.UIT.T, config = { text = tp.name, scale = 0.32, colour = G.C.WHITE, shadow = true } }
            }
        })
    end

    -- 5. Build Generic Options Menu with Embedded Dialogue UIBox
    local t = create_UIBox_generic_options({
        back_func = 'close_potion_pouch',
        back_label = "Close",
        contents = {
            { n = G.UIT.R, config = { align = "cm", padding = 0.1 }, nodes = {
                { n = G.UIT.T, config = { text = "🎒 ALCHEMICAL BACKPACK & TESTING LAB", scale = 0.58, colour = HEX('2e8b57'), shadow = true } }
            }},
            { n = G.UIT.R, config = { align = "cm", padding = 0.05 }, nodes = {
                { n = G.UIT.T, config = { text = "Stored Potions in Backpack (" .. #G.GAME.potion_pouch .. "/6):", scale = 0.36, colour = G.C.GOLD } }
            }},
            { n = G.UIT.R, config = { align = "cm", padding = 0.08, colour = G.C.L_BLACK, r = 0.12, minw = 10.4, minh = 1.4 }, nodes = stored_nodes },
            { n = G.UIT.R, config = { align = "cm", padding = 0.08 }, nodes = {
                { n = G.UIT.T, config = { text = "Kyra's Alchemical Simulation Chamber (Click a Potion to Test):", scale = 0.36, colour = G.C.WHITE } }
            }},
            { n = G.UIT.R, config = { align = "cm", padding = 0.05 }, nodes = catalog_buttons },
            -- Virtual Red Deck and 8-Card Hand Chamber
            { n = G.UIT.R, config = { align = "cm", padding = 0.14, minh = 1.85, colour = G.C.BLACK, r = 0.15, minw = 10.4, outline = 0.04, outline_colour = HEX('2e8b57') }, nodes = {
                { n = G.UIT.C, config = { align = "cm", padding = 0.04, minw = 1.7, w = 1.7 }, nodes = {
                    { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = { { n = G.UIT.T, config = { text = "Red Deck (Mini)", scale = 0.26, colour = G.C.RED } } } },
                    { n = G.UIT.O, config = { object = sim_deck_area, w = sim_w, h = sim_h } }
                }},
                { n = G.UIT.C, config = { align = "cm", padding = 0.04, minw = 8.3, w = 8.3 }, nodes = {
                    { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = { { n = G.UIT.T, config = { ref_table = G.POUCH_SIM_STATE, ref_value = 'status', scale = 0.30, colour = G.C.GREEN, shadow = true } } } },
                    { n = G.UIT.O, config = { object = sim_hand_area, w = 8.8 * sim_w, h = sim_h * 1.08 } }
                }}
            }},
            -- Embedded Dialogue UIBox with Kyra wobble speaking
            { n = G.UIT.R, config = { align = "cm", padding = 0.12, minh = 1.65, colour = G.C.L_BLACK, r = 0.15, emboss = 0.06, minw = 10.4, outline = 0.04, outline_colour = HEX('2e8b57') }, nodes = {
                { n = G.UIT.C, config = { align = "cm", padding = 0.04, minw = 1.7, w = 1.7 }, nodes = {
                    { n = G.UIT.O, config = { object = kyra_area, w = kyra_w, h = kyra_h } },
                    { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = {
                        { n = G.UIT.T, config = { text = "Kyra", scale = 0.32, colour = G.C.PURPLE, shadow = true } }
                    }}
                }},
                { n = G.UIT.C, config = { align = "cl", padding = 0.15, minw = 8.3, w = 8.3, minh = 1.45, colour = G.C.BLACK, r = 0.12, outline = 0.03, outline_colour = G.C.GOLD }, nodes = {
                    { n = G.UIT.R, config = { align = "cl", padding = 0.02 }, nodes = {
                        { n = G.UIT.T, config = { text = "💬 ALCHEMICAL COMMENTARY", scale = 0.26, colour = G.C.GOLD } }
                    }},
                    { n = G.UIT.R, config = { align = "cl", padding = 0.02, maxw = 7.9 }, nodes = {
                        { n = G.UIT.T, config = { ref_table = G.POUCH_SIM_STATE, ref_value = 'line1', scale = 0.32, maxw = 7.9, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                    }},
                    { n = G.UIT.R, config = { align = "cl", padding = 0.02, maxw = 7.9 }, nodes = {
                        { n = G.UIT.T, config = { ref_table = G.POUCH_SIM_STATE, ref_value = 'line2', scale = 0.32, maxw = 7.9, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                    }}
                }}
            }}
        }
    })

    G.FUNCS.overlay_menu{
        definition = t
    }
end

