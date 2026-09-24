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
    collection_rows = { 4, 5 },
    default = 'c_Witch_brew_potion_stretch'
}

-- Potion Particles, Visual hooks

local function get_potion_particle_colours(card)
    local key = (card and card.config and card.config.center and (card.config.center.key or card.config.center_key))
        or (card and card.config and card.config.center_key)
        or (card and card.ability and card.ability.name)
        or ''
    key = string.lower(tostring(key))
    if string.find(key, 'white_honey', 1, true) or string.find(key, 'miel_blanca', 1, true) then
        return { HEX('ffffff'), HEX('fef08a'), HEX('facc15'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'kikimore', 1, true) or string.find(key, 'kikimora', 1, true) then
        return { HEX('a855f7'), HEX('4ade80'), HEX('6b21a8'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'drowner', 1, true) or string.find(key, 'sumergido', 1, true) then
        return { HEX('0d9488'), HEX('2dd4bf'), HEX('99f6e4'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'thunderbolt', 1, true) then
        return { HEX('f59e0b'), HEX('facc15'), HEX('fffbeb'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'white_raffard', 1, true) or string.find(key, 'raffard', 1, true) then
        return { HEX('ef4444'), HEX('dc2626'), HEX('cbd5e1'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'amalgam', 1, true) or string.find(key, 'amalgama', 1, true) then
        return { HEX('a855f7'), HEX('ec4899'), HEX('3b82f6'), HEX('10b981'), HEX('fbbf24'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'lightning', 1, true) or string.find(key, 'rayo', 1, true) or string.find(key, 'trueno', 1, true) then
        return { HEX('f59e0b'), HEX('fbbf24'), HEX('fef08a'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'blizzard', 1, true) or string.find(key, 'ventisca', 1, true) or string.find(key, 'orca', 1, true) then
        return { HEX('06b6d4'), HEX('38bdf8'), HEX('67e8f9'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'fury', 1, true) or string.find(key, 'furia', 1, true) then
        return { HEX('ef4444'), HEX('dc2626'), HEX('fca5a5'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'mercury', 1, true) or string.find(key, 'mercurio', 1, true) then
        return { HEX('cbd5e1'), HEX('94a3b8'), HEX('f8fafc'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'mirror', 1, true) or string.find(key, 'espejo', 1, true) then
        return { HEX('8b5cf6'), HEX('a78bfa'), HEX('c4b5fd'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'clock', 1, true) or string.find(key, 'reloj', 1, true) then
        return { HEX('d97706'), HEX('fbbf24'), HEX('fef3c7'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'swallow', 1, true) or string.find(key, 'golondrina', 1, true) then
        return { HEX('22c55e'), HEX('4ade80'), HEX('86efac'), HEX('fef08a'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'tawny_owl', 1, true) or string.find(key, 'lechuza', 1, true) then
        return { HEX('2563eb'), HEX('3b82f6'), HEX('f59e0b'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'petri', 1, true) or string.find(key, 'filtro_petri', 1, true) then
        return { HEX('7e22ce'), HEX('a855f7'), HEX('e9d5ff'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'golden_oriole', 1, true) or string.find(key, 'oropendola', 1, true) then
        return { HEX('eab308'), HEX('facc15'), HEX('fef08a'), { 1, 1, 1, 0.95 } }
    elseif string.find(key, 'black_blood', 1, true) or string.find(key, 'sangre_negra', 1, true) then
        return { HEX('881337'), HEX('e11d48'), HEX('1e293b'), { 1, 1, 1, 0.95 } }
    else
        return { HEX('2e8b57'), HEX('50c878'), HEX('a7f3d0'), HEX('10b981'), HEX('34d399'), { 1, 1, 1, 0.9 } }
    end
end

if SMODS and SMODS.DrawStep then
    SMODS.DrawStep {
        key = 'potion_particles',
        order = -35,
        func = function(self)
            if self.children.potion_particles and self.children.potion_particles.draw then
                if not self.dissolve or self.dissolve <= 0.01 then
                    self.children.potion_particles:draw()
                end
            end
        end,
        conditions = { vortex = false, facing = 'front' }
    }
end

local card_update_potion_ref = Card.update
function Card:update(dt)
    card_update_potion_ref(self, dt)
    if self.ability and self.ability.set == 'Potion' then
        local is_active = self.states.visible and self.facing ~= 'back' and not (self.dissolve and self.dissolve > 0) and not self.shattered and (not self.area or self.area ~= G.deck)
        if is_active then
            if not self.children.potion_particles and Particles then
                local colours = get_potion_particle_colours(self)
                local p = Particles(0, 0, 0, 0, {
                    timer = 0.14,
                    scale = 0.16,
                    speed = 0.6,
                    lifespan = 1.1,
                    attach = self,
                    colours = colours,
                    fill = true,
                    initialize = true
                })
                p.custom_draw = true
                self.children.potion_particles = p
            end
        elseif self.children.potion_particles then
            pcall(function() self.children.potion_particles:remove() end)
            self.children.potion_particles = nil
        end
    elseif self.children.potion_particles then
        pcall(function() self.children.potion_particles:remove() end)
        self.children.potion_particles = nil
    end
end

local card_use_potion_ref = Card.use_consumeable
function Card:use_consumeable(area, copier)
    if self.ability and self.ability.set == 'Potion' and Particles then
        local colours = get_potion_particle_colours(self)
        local burst = Particles(0, 0, 0, 0, {
            timer = 0.008,
            pulse_max = 24,
            scale = 0.28,
            speed = 2.5,
            lifespan = 0.7,
            attach = self,
            colours = colours,
            fill = true
        })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            blockable = false,
            blocking = false,
            func = function()
                if burst and burst.remove then
                    pcall(function() burst:remove() end)
                end
                return true
            end
        }))
    end
    return card_use_potion_ref(self, area, copier)
end

local card_start_dissolve_potion_ref = Card.start_dissolve
function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
    if self.ability and self.ability.set == 'Potion' and not dissolve_colours then
        dissolve_colours = get_potion_particle_colours(self)
    end
    return card_start_dissolve_potion_ref(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
end

local card_start_materialize_potion_ref = Card.start_materialize
function Card:start_materialize(dissolve_colours, silent, timefac)
    if self.ability and self.ability.set == 'Potion' and not dissolve_colours then
        dissolve_colours = get_potion_particle_colours(self)
    end
    return card_start_materialize_potion_ref(self, dissolve_colours, silent, timefac)
end


-- 1. Stretch Potion
SMODS.Consumable {
    key = 'potion_stretch',
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
                G.GAME.potion_stretch_active = true
                G.GAME.potion_estiramiento_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = '7 Cards!', colour = G.C.GREEN })
                return true
            end
        }))
    end
}

-- 2. Lightning Potion
SMODS.Consumable {
    key = 'potion_lightning',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 1, y = 0 },
    cost = 4,
    config = { extra = { odds = 5 } },
    loc_txt = {
        name = 'Lightning Potion',
        text = {
            "Cards played in your next hand gain a",
            "{C:attention}random enhancement{}, with a {C:green}#1# in #2#{} chance",
            "to be destroyed after scoring ends"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.probabilities.normal) or 1, (card and card.ability and card.ability.extra and card.ability.extra.odds) or 5 } }
    end,
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
                G.GAME.potion_lightning_active = true
                G.GAME.potion_rayo_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Lightning Active!', colour = G.C.GOLD })
                return true
            end
        }))
    end
}

-- 3. Blizzard Potion
SMODS.Consumable {
    key = 'potion_blizzard',
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
    key = 'potion_fury',
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
        key = 'vampiric_midas',
        name = 'Vampiric Midas',
        quote = "\"Golden greed meets immortal hunger! Midas Mask and Vampire fuse into Vampiric Midas!\""
    },
    {
        pair = { 'hologram', 'certificate' },
        key = 'certified_programming',
        name = 'Certified Programming',
        quote = "\"Holographic seals certified! Hologram and Certificate combine into Certified Programming!\""
    },
    {
        pair = { 'constellation', 'astronomer' },
        key = 'galactic_traveler',
        name = 'Galactic Traveler',
        quote = "\"The cosmos aligns! Constellation and Astronomer unite into the Galactic Traveler!\""
    },
    {
        pair = { 'four_fingers', 'shortcut' },
        key = 'colorful_street',
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
    outcome_text = "Select 2 Jokers to preview",
    kyra_quote = "\"Pick two Jokers... and not eternal ones, I don't work miracles.\"",
    line1 = "\"Pick two Jokers... and not eternal ones,",
    line2 = "I don't work miracles.\"",
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
            G.AMALGAM_STATE.outcome_text = "ALCHEMICAL FUSION: " .. (recipe.name or "Special")
            set_amalgam_quote(recipe.quote or "\"The ancient fusion formula... stand back, sparks will fly.\"")
            G.AMALGAM_STATE.combine_text = "✨ FUSE AMALGAM ✨"
        elseif is_secret_summon then
            G.AMALGAM_STATE.outcome_text = "SECRET JOKER!"
            set_amalgam_quote("\"A Secret Joker? Don't you dare tell anyone I taught you this recipe.\"")
            G.AMALGAM_STATE.combine_text = "✨ SUMMON SECRET ✨"
        elseif target_rarity == 4 then
            G.AMALGAM_STATE.outcome_text = "TRANSMUTATION: LEGENDARY"
            set_amalgam_quote("\"A Legendary transmutation? Well... seems you have some talent after all.\"")
            G.AMALGAM_STATE.combine_text = "✨ TRANSMUTE TO LEGENDARY ✨"
        elseif target_rarity == 3 then
            G.AMALGAM_STATE.outcome_text = "TRANSMUTATION: RARE"
            set_amalgam_quote("\"A Rare Joker. Could be worse, I suppose...\"")
            G.AMALGAM_STATE.combine_text = "✨ TRANSMUTE TO RARE ✨"
        else
            G.AMALGAM_STATE.outcome_text = "TRANSMUTATION: UNCOMMON"
            set_amalgam_quote("\"Fairly basic, but at least it will serve some purpose.\"")
            G.AMALGAM_STATE.combine_text = "✨ TRANSMUTE TO UNCOMMON ✨"
        end

        if best_edition then
            local ed_name = best_edition.negative and "Negative" or (best_edition.polychrome and "Polychrome" or (best_edition.holo and "Holographic" or "Foil"))
            G.AMALGAM_STATE.edition_note = "★ Will Infuse Edition: " .. ed_name .. (total_ed_bonus > 0 and " (+1 Alchemical Tier)" or "")
        end
    elseif #sel == 1 and sel[1].config and sel[1].config.center and sel[1].config.center.rarity == 4 then
        G.AMALGAM_STATE.can_combine = true
        G.AMALGAM_STATE.outcome_text = "SECRET JOKER! (Legendary Sacrifice)"
        set_amalgam_quote("\"Sacrificing a Legendary? You're insane... but I like it.\"")
        G.AMALGAM_STATE.combine_text = "✨ TRANSMUTE SECRET ✨"
    elseif #sel == 1 then
        G.AMALGAM_STATE.outcome_text = "Need 1 more Joker..."
        set_amalgam_quote("\"Missing the second ingredient. Don't keep me waiting all day.\"")
        G.AMALGAM_STATE.combine_text = "Pick 1 More"
    else
        G.AMALGAM_STATE.outcome_text = "Select 2 Jokers to preview"
        set_amalgam_quote("\"Pick two Jokers... and not eternal ones, I don't work miracles.\"")
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
                entry.state.label = is_selected and "✓ CHOSEN" or "+ SELECT"
            end
            if entry.btn then
                entry.btn.config.colour = is_selected and G.C.GREEN or G.C.L_BLACK
                entry.btn.config.outline = 0.04
                entry.btn.config.outline_colour = is_selected and G.C.WHITE or {0.4, 0.4, 0.4, 0.5}
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
            local new_potion = (create_potion_card_safe and create_potion_card_safe(G.consumeables, 'amalgama_refund')) or create_card('Potion', G.consumeables, nil, nil, nil, nil, 'c_Witch_brew_potion_amalgam', 'refund')
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
            label = is_eternal and "[ 🔒 ETERNO ]" or (is_selected and "✓ CHOSEN" or "+ SELECT")
        }
        local btn_colour = is_eternal and G.C.UI.BACKGROUND_INACTIVE or (is_selected and G.C.GREEN or G.C.L_BLACK)
        local btn_func = is_eternal and 'amalgam_cannot_select' or 'amalgam_toggle_joker'

        local button_node = {
            n = G.UIT.R, config = {
                align = "cm",
                minw = 1.35,
                minh = 0.48,
                r = 0.1,
                hover = not is_eternal,
                colour = btn_colour,
                outline = 0.04,
                outline_colour = is_selected and G.C.WHITE or (not is_eternal and {0.4, 0.4, 0.4, 0.5} or nil),
                button = btn_func,
                ref_table = {card = j},
                shadow = true
            }, nodes = {
                {n = G.UIT.T, config = {ref_table = btn_state, ref_value = 'label', scale = 0.34, colour = is_eternal and G.C.RED or G.C.WHITE, shadow = true}}
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
                {n = G.UIT.T, config = {text = "[Eternal]", scale = 0.30, colour = G.C.RED, shadow = true}}
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
                colour = is_selected and {0.14, 0.38, 0.14, 0.9} or {0.06, 0.06, 0.06, 0.65},
                outline = is_selected and 0.05 or 0.03,
                outline_colour = is_selected and G.C.GREEN or {0.25, 0.25, 0.25, 0.5}
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
            minw = 4.4,
            minh = 0.82,
            r = 0.16,
            hover = true,
            colour = G.AMALGAM_STATE.can_combine and G.C.GREEN or G.C.UI.BACKGROUND_INACTIVE,
            button = 'amalgam_confirm_combine',
            shadow = true
        }, nodes = {
            {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'combine_text', scale = 0.52, colour = G.C.WHITE, shadow = true}}
        }
    }
    G.amalgam_combine_button = combine_btn_node

    local t = create_UIBox_generic_options({
        back_func = 'amalgam_cancel_menu',
        back_label = "Cancel",
        contents = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.12}, nodes = {
                {n = G.UIT.T, config = {text = "⚗️ AMALGAM TRANSMUTATION", scale = 0.65, colour = G.C.GOLD, shadow = true}}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.04}, nodes = {
                {n = G.UIT.T, config = {text = "Select 2 Jokers to transmute into a higher rarity (Eternals cannot be fused):", scale = 0.35, colour = G.C.WHITE}}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.12, colour = G.C.L_BLACK, r = 0.15, outline = 0.03, outline_colour = G.C.GOLD}, nodes = joker_nodes},
            {n = G.UIT.R, config = {align = "cm", padding = 0.08}, nodes = {
                {n = G.UIT.C, config = {align = "cm", padding = 0.08, colour = G.C.BLACK, r = 0.12, minw = 7.5, minh = 0.85, outline = 0.04, outline_colour = G.C.GOLD}, nodes = {
                    {n = G.UIT.R, config = {align = "cm", padding = 0.01}, nodes = {
                        {n = G.UIT.T, config = {text = "⚗️ TRANSMUTATION PREVIEW", scale = 0.26, colour = G.C.GOLD}}
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.02}, nodes = {
                        {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'outcome_text', scale = 0.48, colour = G.C.WHITE, shadow = true}}
                    }}
                }}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.08}, nodes = {
                combine_btn_node
            }},
            -- Kyra Dialogue Box
            {n = G.UIT.R, config = {align = "cm", padding = 0.12, colour = G.C.L_BLACK, r = 0.15, emboss = 0.05, minw = 9.5, outline = 0.04, outline_colour = G.C.PURPLE}, nodes = {
                {n = G.UIT.C, config = {align = "cm", padding = 0.06}, nodes = {
                    {n = G.UIT.O, config = {object = kyra_area}},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.02}, nodes = {
                        {n = G.UIT.T, config = {text = "Kyra", scale = 0.38, colour = G.C.PURPLE, shadow = true}}
                    }}
                }},
                {n = G.UIT.C, config = {align = "cl", padding = 0.12, minw = 7.2, colour = G.C.BLACK, r = 0.12, outline = 0.03, outline_colour = G.C.PURPLE}, nodes = {
                    {n = G.UIT.R, config = {align = "cl", padding = 0.02}, nodes = {
                        {n = G.UIT.T, config = {text = "💬 KYRA", scale = 0.26, colour = G.C.PURPLE}}
                    }},
                    {n = G.UIT.R, config = {align = "cl", padding = 0.02, maxw = 7.0}, nodes = {
                        {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'line1', scale = 0.33, maxw = 7.0, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
                    }},
                    {n = G.UIT.R, config = {align = "cl", padding = 0.02, maxw = 7.0}, nodes = {
                        {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'line2', scale = 0.33, maxw = 7.0, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
                    }},
                    {n = G.UIT.R, config = {align = "cl", padding = 0.02, maxw = 7.0}, nodes = {
                        {n = G.UIT.T, config = {ref_table = G.AMALGAM_STATE, ref_value = 'edition_note', scale = 0.32, maxw = 7.0, colour = G.C.DARK_EDITION, shadow = true}}
                    }}
                }}
            }}
        }
    })
    G.FUNCS.overlay_menu{definition = t}
end

SMODS.Consumable {
    key = 'potion_amalgam',
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
    key = 'potion_mercury',
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
                G.GAME.potion_mercury_active = true
                G.GAME.potion_mercurio_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = '+1 Hand & Discard!', colour = G.C.BLUE })
                return true
            end
        }))
    end
}

-- 7. Mirror Potion
SMODS.Consumable {
    key = 'potion_mirror',
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
                G.GAME.potion_mirror_active = true
                G.GAME.potion_espejo_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Mirror Active!', colour = G.C.PURPLE })
                return true
            end
        }))
    end
}

-- 8. Clock Potion
SMODS.Consumable {
    key = 'potion_clock',
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
        G.GAME.potion_clock_pending_hands = (G.GAME.potion_clock_pending_hands or 0) + 1
        G.GAME.potion_reloj_pending_hands = G.GAME.potion_clock_pending_hands
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.4, 0.6)
                local returned_count = 0
                if G.GAME.last_played_hand_cards and G.discard and G.hand then
                    local to_return = {}
                    for _, target in ipairs(G.GAME.last_played_hand_cards) do
                        for i = #G.discard.cards, 1, -1 do
                            local dc = G.discard.cards[i]
                            if dc == target then
                                table.insert(to_return, dc)
                                break
                            end
                        end
                    end
                    local total = #to_return
                    for i, dc in ipairs(to_return) do
                        dc.states.visible = true
                        dc.states.drag.can = true
                        dc.states.collide.can = true
                        dc.facing = 'back'
                        draw_card(G.discard, G.hand, i * 100 / math.max(1, total), 'up', true, dc)
                        returned_count = returned_count + 1
                    end
                end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Rewind! +' .. returned_count, colour = G.C.BLUE })
                return true
            end
        }))
    end
}

-- 9. Swallow Potion
SMODS.Consumable {
    key = 'potion_swallow',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 3, y = 1 },
    cost = 4,
    config = { extra = { max_cards = 2, money = 5 } },
    loc_txt = {
        name = 'Swallow Potion',
        text = {
            "Enhances up to {C:attention}#1#{} selected cards",
            "into {C:attention}Lucky Cards{}, and grants",
            "{C:money}+$#2#{} immediately"
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.max_cards or 2, extra.money or 5 } }
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted >= 1 and #G.hand.highlighted <= 2
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
                play_sound('tarot1')
                card:juice_up(0.4, 0.5)
                for _, target in ipairs(targets) do
                    target:set_ability(G.P_CENTERS.m_lucky)
                    target:juice_up(0.3, 0.3)
                end
                ease_dollars((card.ability and card.ability.extra and card.ability.extra.money) or 5)
                if G.hand then G.hand:unhighlight_all() end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Swallow!', colour = G.C.GREEN })
                return true
            end
        }))
    end
}

-- 10. Tawny Owl Potion
SMODS.Consumable {
    key = 'potion_tawny_owl',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 4, y = 1 },
    cost = 4,
    config = { extra = { hands = 1, discards = 2, hand_size = 1 } },
    loc_txt = {
        name = 'Tawny Owl Potion',
        text = {
            "Grants {C:blue}+#1# Hand{} and {C:red}+#2# Discards{}",
            "for this round, and {C:attention}+#3#{} hand size",
            "for the rest of the blind"
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.hands or 1, extra.discards or 2, extra.hand_size or 1 } }
    end,
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
                ease_hands_played((card.ability and card.ability.extra and card.ability.extra.hands) or 1)
                ease_discard((card.ability and card.ability.extra and card.ability.extra.discards) or 2)
                local hs = (card.ability and card.ability.extra and card.ability.extra.hand_size) or 1
                if G.hand and G.hand.change_size then
                    G.hand:change_size(hs)
                end
                G.GAME.potion_tawny_owl_active = (G.GAME.potion_tawny_owl_active or 0) + hs
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Tawny Owl!', colour = G.C.BLUE })
                return true
            end
        }))
    end
}

-- 11. Petri's Philter
SMODS.Consumable {
    key = 'potion_petri',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 0, y = 2 },
    cost = 4,
    config = { extra = { levels = 2 } },
    loc_txt = {
        name = "Petri's Philter",
        text = {
            "Increases the level of your",
            "{C:attention}most played poker hand{}",
            "by {C:attention}+#1# levels{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.levels or 2 } }
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.5, 0.6)
                local chosen_hand = 'High Card'
                local max_played = -1
                if G.GAME and G.GAME.hands then
                    for handname, handinfo in pairs(G.GAME.hands) do
                        if handinfo.played and handinfo.played > max_played and handinfo.visible then
                            max_played = handinfo.played
                            chosen_hand = handname
                        end
                    end
                end
                level_up_hand(card, chosen_hand, nil, (card.ability and card.ability.extra and card.ability.extra.levels) or 2)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Level Up!', colour = G.C.PURPLE })
                return true
            end
        }))
    end
}

-- 12. Golden Oriole Potion
SMODS.Consumable {
    key = 'potion_golden_oriole',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 1, y = 2 },
    cost = 5,
    config = { extra = { money = 6 } },
    loc_txt = {
        name = 'Golden Oriole Potion',
        text = {
            "Disables the current {C:attention}Boss Blind{}",
            "ability and earns {C:money}+$#1#{}",
            "{C:inactive}(Can only be used during Boss Blind){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.money or 6 } }
    end,
    can_use = function(self, card)
        return G.GAME and G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.5, 0.6)
                if G.GAME and G.GAME.blind and G.GAME.blind.disable then
                    G.GAME.blind:disable()
                end
                ease_dollars((card.ability and card.ability.extra and card.ability.extra.money) or 6)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Oriole!', colour = G.C.GOLD })
                return true
            end
        }))
    end
}

-- 13. Black Blood Potion
SMODS.Consumable {
    key = 'potion_black_blood',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 2, y = 2 },
    cost = 5,
    config = { extra = { max_cards = 2 } },
    loc_txt = {
        name = 'Black Blood Potion',
        text = {
            "Enhances up to {C:attention}#1#{} selected cards",
            "into {C:attention}Glass Cards{}, and adds a",
            "random {C:dark_edition}Edition{} to one of them"
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.max_cards or 2 } }
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted >= 1 and #G.hand.highlighted <= 2
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
                play_sound('tarot2')
                card:juice_up(0.5, 0.6)
                for _, target in ipairs(targets) do
                    target:set_ability(G.P_CENTERS.m_glass)
                    target:juice_up(0.3, 0.3)
                end
                local chosen_card = pseudorandom_element(targets, pseudoseed('black_blood_ed'))
                if chosen_card then
                    local ed = poll_edition('black_blood_edition', nil, true, true)
                    if ed then
                        chosen_card:set_edition(ed, true)
                    end
                end
                if G.hand then G.hand:unhighlight_all() end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Black Blood!', colour = G.C.DARK_EDITION })
                return true
            end
        }))
    end
}

-- 14. White Honey Potion
SMODS.Consumable {
    key = 'potion_white_honey',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 3, y = 2 },
    cost = 5,
    loc_txt = {
        name = 'White Honey Potion',
        text = {
            "Purges {C:attention}Perishable{} and {C:attention}Rental{} stickers",
            "from all owned Jokers, and reduces current",
            "Blind score requirement by {C:attention}1.5%{} per card in deck",
            "{C:inactive}(Max 60% reduction){}"
        }
    },
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.5, 0.6)
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        if j.set_perishable then j:set_perishable(false) end
                        if j.set_rental then j:set_rental(false) end
                        j.ability.perishable = nil
                        j.ability.perish_tally = nil
                        j.ability.rental = nil
                        j:juice_up(0.3, 0.3)
                    end
                end
                if G.GAME and G.GAME.blind and G.GAME.blind.chips then
                    local rem = (G.deck and #G.deck.cards) or 0
                    local reduce_pct = math.min(0.60, rem * 0.015)
                    G.GAME.blind.chips = math.max(1, math.floor(G.GAME.blind.chips * (1 - reduce_pct)))
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Purged & Reduced!', colour = G.C.GREEN })
                return true
            end
        }))
    end
}

-- 15. Kikimore Hive Ichor
SMODS.Consumable {
    key = 'potion_kikimore',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 4, y = 2 },
    cost = 5,
    loc_txt = {
        name = 'Kikimore Hive Ichor',
        text = {
            "For the rest of this Ante, whenever cards",
            "are played, every matching rank in your",
            "{C:attention}unplayed deck{} permanently gains {C:chips}+10{} Chips"
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
                G.GAME.potion_kikimore_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Hive Resonating!', colour = G.C.PURPLE })
                return true
            end
        }))
    end
}

-- 16. Drowner Pheromone Flask
SMODS.Consumable {
    key = 'potion_drowner',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 0, y = 3 },
    cost = 5,
    loc_txt = {
        name = 'Drowner Pheromone Flask',
        text = {
            "Rewinds time in the current realm:",
            "Reduces {C:attention}Ante{} by {C:attention}1{}, and",
            "earns {C:money}+$10{} sunken treasure"
        }
    },
    can_use = function(self, card)
        return G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante and G.GAME.round_resets.ante > 1
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.5, 0.6)
                ease_ante(-1)
                G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
                ease_dollars(10)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Ante -1!', colour = G.C.DARK_EDITION })
                return true
            end
        }))
    end
}

-- 17. Thunderbolt Potion
SMODS.Consumable {
    key = 'potion_thunderbolt',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 1, y = 3 },
    cost = 4,
    loc_txt = {
        name = 'Thunderbolt Potion',
        text = {
            "Cards played in your next hand",
            "permanently gain {C:chips}+50{} Bonus Chips",
            "and {C:mult}+10{} Mult"
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
                G.GAME.potion_thunderbolt_active = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Thunderbolt Armed!', colour = G.C.GOLD })
                return true
            end
        }))
    end
}

-- 18. White Raffard's Decoction
SMODS.Consumable {
    key = 'potion_white_raffard',
    set = 'Potion',
    atlas = 'witch_brew_potions',
    pos = { x = 2, y = 3 },
    cost = 4,
    loc_txt = {
        name = "White Raffard's Decoction",
        text = {
            "Emergency elixir: Grants {C:blue}+1{} Hand,",
            "{C:red}+2{} Discards this round, and {C:money}+$6{}"
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
                card:juice_up(0.5, 0.6)
                ease_hands_played(1)
                ease_discard(2)
                ease_dollars(6)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = '+1 Hand / +2 Discards!', colour = G.C.GREEN })
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

    if G.GAME and G.GAME.potion_thunderbolt_active and G.hand and G.hand.highlighted then
        for _, c in ipairs(G.hand.highlighted) do
            c.ability.perma_bonus = (c.ability.perma_bonus or 0) + 50
            c.ability.mult = (c.ability.mult or 0) + 10
            c:juice_up(0.3, 0.3)
        end
        G.GAME.potion_thunderbolt_active = nil
    end

    if G.GAME and G.GAME.potion_kikimore_active and G.hand and G.hand.highlighted and G.deck and G.deck.cards then
        local played_ranks = {}
        for _, c in ipairs(G.hand.highlighted) do
            local id = c:get_id()
            if id then played_ranks[id] = true end
        end
        for _, dc in ipairs(G.deck.cards) do
            local did = dc:get_id()
            if did and played_ranks[did] then
                dc.ability.perma_bonus = (dc.ability.perma_bonus or 0) + 10
            end
        end
    end

    if G.GAME and (G.GAME.potion_lightning_active or G.GAME.potion_rayo_active) and G.hand and G.hand.highlighted then
        local enhs = { G.P_CENTERS.m_bonus, G.P_CENTERS.m_mult, G.P_CENTERS.m_wild, G.P_CENTERS.m_glass, G.P_CENTERS.m_steel, G.P_CENTERS.m_gold, G.P_CENTERS.m_lucky }
        for _, c in ipairs(G.hand.highlighted) do
            local chosen_enh = pseudorandom_element(enhs, pseudoseed('potion_rayo_enh'))
            c:set_ability(chosen_enh)
            local odds = ((G.GAME and G.GAME.probabilities.normal) or 1) / 5
            if pseudorandom('potion_rayo_destroy') < odds then
                c.potion_rayo_destruct = true
            end
        end
        G.GAME.potion_lightning_active = nil
        G.GAME.potion_rayo_active = nil
    end

    card_play_ref(e)

    -- Reset Stretch if active
    if G.GAME and (G.GAME.potion_stretch_active or G.GAME.potion_estiramiento_active) then
        if G.hand and G.hand.config then
            G.hand.config.highlighted_limit = 5
        end
        G.GAME.potion_stretch_active = nil
        G.GAME.potion_estiramiento_active = nil
    end
end

-- Hook scoring completion to dissolve rayo destruct cards AFTER scoring has finished
local orig_draw_from_play_to_discard = G.FUNCS.draw_from_play_to_discard
if orig_draw_from_play_to_discard then
    G.FUNCS.draw_from_play_to_discard = function(e)
        local destroyed_cards = {}
        if G.play and G.play.cards then
            for _, c in ipairs(G.play.cards) do
                if c.potion_rayo_destruct then
                    c.potion_rayo_destruct = nil
                    c.destroyed = true
                    table.insert(destroyed_cards, c)
                end
            end
        end
        if #destroyed_cards > 0 then
            for _, c in ipairs(destroyed_cards) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        c:start_dissolve()
                        return true
                    end
                }))
            end
            for j = 1, #G.jokers.cards do
                eval_card(G.jokers.cards[j], { cardarea = G.jokers, remove_playing_cards = true, removed = destroyed_cards })
            end
        end
        orig_draw_from_play_to_discard(e)
    end
end

-- Hook joker calculation for Pocion de Espejo (retrigger rightmost joker)
local orig_calculate_joker = Card.calculate_joker
function Card:calculate_joker(context, ...)
    local ret, post = orig_calculate_joker(self, context, ...)
    if G.GAME and (G.GAME.potion_mirror_active or G.GAME.potion_espejo_active) and not context.potion_mirror_retrigger and not context.potion_espejo_retrigger and not context.retrigger_joker_check then
        if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
            local rightmost = G.jokers.cards[#G.jokers.cards]
            if self == rightmost and not self.debuff then
                local ctx_copy = {}
                for k, v in pairs(context) do ctx_copy[k] = v end
                ctx_copy.potion_mirror_retrigger = true
                ctx_copy.potion_espejo_retrigger = true
                local ret2 = orig_calculate_joker(self, ctx_copy, ...)
                if ret2 then
                    card_eval_status_text(self, 'extra', nil, nil, nil, { message = 'Mirror!', colour = G.C.PURPLE })
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
    return ret, post
end

-- Hook new_round for Pocion de Reloj (+1 mano siguiente ronda)
if new_round then
    local orig_new_round = new_round
    function new_round()
        orig_new_round()
        local pending_hands = (G.GAME and G.GAME.potion_clock_pending_hands) or (G.GAME and G.GAME.potion_reloj_pending_hands) or 0
        if pending_hands > 0 then
            ease_hands_played(pending_hands)
            if G.GAME then
                G.GAME.potion_clock_pending_hands = 0
                G.GAME.potion_reloj_pending_hands = 0
            end
        end
    end
end

-- Hook end_round for Pocion de Mercurio ($1 por mano restante al ganar la Ciega) y reset de flags
if end_round then
    local orig_end_round = end_round
    function end_round()
        if G.GAME and (G.GAME.potion_mercury_active or G.GAME.potion_mercurio_active) and G.GAME.blind and (G.GAME.chips >= G.GAME.blind.chips) then
            local left = (G.GAME.current_round and G.GAME.current_round.hands_left) or 0
            if left > 0 then
                ease_dollars(left)
                card_eval_status_text(G.deck or G.hand, 'extra', nil, nil, nil, { message = '+$' .. left, colour = G.C.MONEY })
            end
        end
        if G.GAME then
            if G.GAME.potion_tawny_owl_active and G.GAME.potion_tawny_owl_active > 0 then
                if G.hand and G.hand.change_size then
                    G.hand:change_size(-G.GAME.potion_tawny_owl_active)
                end
                G.GAME.potion_tawny_owl_active = nil
            end
            G.GAME.potion_mercury_active = nil
            G.GAME.potion_mercurio_active = nil
            G.GAME.potion_mirror_active = nil
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
                    if forced_tag then
                        for _, vv in ipairs(G.GAME.tags) do
                            if vv:apply_to_run({ type = 'store_joker_modify', card = forced_tag }) then break end
                        end
                        return forced_tag
                    end
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

-- Potion Storage, Backpack and lab state

G.POUCH_SIM_STATE = {
    dialogue = "\"Ugh... you again? Do whatever you need and don't touch anything else.\"",
    line1 = "\"Ugh... you again? Do whatever you need and don't",
    line2 = "touch anything else.\"",
    status = "Storage Ready"
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
    
    local p_key = (card.config and card.config.center and card.config.center.key) or (card.ability and card.ability.key) or 'potion_stretch'
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

-- Disinterested entrance quotes for Kyra (exactly 10 lines)
local kyra_bored_quotes = {
    "Ugh... you again? Do whatever you need and don't touch anything else.",
    "*Yawn*... If something is going to explode, warn me with enough time to leave.",
    "The potions are on the rack. Don't make me talk more than strictly necessary.",
    "Do you really need another potion? What persistence...",
    "Take what you want from the pouch and go, I was resting so peacefully.",
    "They don't pay me enough to feign interest. Make it quick.",
    "Flasks ready? Good. Use them or store them, makes no difference to me.",
    "If you poison yourself with a weird concoction, I'll pretend I never met you.",
    "Less talking, more alchemy. Or even better: no talking at all.",
    "*Sigh*... Go ahead, rummage through the pouch if you must, just don't break anything."
}

-- Close Potion Backpack & reset temporary cardareas
G.FUNCS.close_potion_pouch = function(e)
    if G.pouch_temp_areas then
        for _, area in ipairs(G.pouch_temp_areas) do
            area:remove()
        end
        G.pouch_temp_areas = nil
    end
    G.pouch_kyra_card = nil
    if G.FUNCS.exit_overlay_menu then
        G.FUNCS.exit_overlay_menu(e)
    end
end

-- Open Potion Backpack & Kyra's Potion Lab UI
G.FUNCS.open_potion_pouch = function()
    if not (create_UIBox_generic_options and G.FUNCS.overlay_menu) then return end

    if G.pouch_temp_areas then
        for _, area in ipairs(G.pouch_temp_areas) do
            area:remove()
        end
        G.pouch_temp_areas = nil
    end
    G.pouch_kyra_card = nil
    G.pouch_temp_areas = {}

    G.GAME.potion_pouch = G.GAME.potion_pouch or {}

    -- Random disinterested quote from Kyra on entry
    if kyra_bored_quotes and #kyra_bored_quotes > 0 then
        local quote = kyra_bored_quotes[math.random(#kyra_bored_quotes)]
        set_pouch_dialogue(quote)
    end

    -- 1. Kyra portrait with speaking animation hook
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

    -- Kyra wobble talk animation
    kyra_speak()

    -- 2. Alchemical 6-slot rack for potions
    local pot_scale = 0.62
    local pot_w = G.CARD_W * pot_scale
    local pot_h = G.CARD_H * pot_scale
    local slot_nodes = {}

    for slot_idx = 1, 6 do
        local item = G.GAME.potion_pouch[slot_idx]
        if item then
            local p_center = G.P_CENTERS[item.key] or G.P_CENTERS[get_valid_joker_key(item.key) or '']
            local item_area = CardArea(0, 0, pot_w, pot_h, { card_limit = 1, type = 'title', highlight_limit = 0, card_w = pot_w })
            table.insert(G.pouch_temp_areas, item_area)
            local item_card = Card(0, 0, pot_w, pot_h, G.P_CARDS.empty, p_center or G.P_CENTERS.c_base)
            item_card.facing = 'front'
            item_area:emplace(item_card)

            table.insert(slot_nodes, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.08,
                    r = 0.12,
                    colour = {0.08, 0.08, 0.11, 0.85},
                    outline = 0.03,
                    outline_colour = HEX('2e8b57')
                },
                nodes = {
                    { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = {
                        { n = G.UIT.T, config = { text = "Slot " .. slot_idx, scale = 0.24, colour = G.C.GOLD } }
                    }},
                    { n = G.UIT.O, config = { object = item_area } },
                    { n = G.UIT.R, config = { align = "cm", padding = 0.03, maxw = 1.4 }, nodes = {
                        { n = G.UIT.T, config = { text = item.name or "Potion", scale = 0.28, colour = G.C.WHITE, shadow = true } }
                    }},
                    { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "cm", padding = 0.06, minw = 0.62, r = 0.08, hover = true, colour = G.C.BLUE, button = 'withdraw_potion_from_pouch', ref_table = { idx = slot_idx }, shadow = true },
                            nodes = { { n = G.UIT.T, config = { text = "⮌ Pull", scale = 0.27, colour = G.C.WHITE } } }
                        },
                        { n = G.UIT.B, config = { w = 0.05, h = 0.1 } },
                        {
                            n = G.UIT.C,
                            config = { align = "cm", padding = 0.06, minw = 0.62, r = 0.08, hover = true, colour = HEX('2e8b57'), button = 'use_potion_from_pouch', ref_table = { idx = slot_idx }, shadow = true },
                            nodes = { { n = G.UIT.T, config = { text = "🧪 Use", scale = 0.27, colour = G.C.WHITE } } }
                        }
                    }}
                }
            })
        else
            -- Empty rack slot
            table.insert(slot_nodes, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.08,
                    r = 0.12,
                    minw = pot_w + 0.2,
                    minh = pot_h + 1.1,
                    colour = {0.05, 0.05, 0.07, 0.5},
                    outline = 0.03,
                    outline_colour = {0.25, 0.25, 0.3, 0.4}
                },
                nodes = {
                    { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = {
                        { n = G.UIT.T, config = { text = "Slot " .. slot_idx, scale = 0.24, colour = G.C.UI.TEXT_INACTIVE } }
                    }},
                    { n = G.UIT.R, config = { align = "cm", padding = 0.35 }, nodes = {
                        { n = G.UIT.T, config = { text = "[ Empty ]", scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } }
                    }},
                    { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = {
                        { n = G.UIT.T, config = { text = "Store potions\nfrom your belt", scale = 0.21, colour = {0.45, 0.45, 0.5, 0.6} } }
                    }}
                }
            })
        end
    end

    -- 3. Overall Laboratory Interface
    local count_text = string.format("(%d/6 potions stored)", #G.GAME.potion_pouch)
    local t = create_UIBox_generic_options({
        back_func = 'close_potion_pouch',
        back_label = "Back",
        contents = {
            { n = G.UIT.R, config = { align = "cm", padding = 0.1 }, nodes = {
                { n = G.UIT.T, config = { text = "🧪 POTION LABORATORY", scale = 0.62, colour = HEX('2e8b57'), shadow = true } }
            }},
            { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = {
                { n = G.UIT.T, config = { text = "Alchemical Rack " .. count_text, scale = 0.34, colour = G.C.GOLD } }
            }},
            { n = G.UIT.R, config = { align = "cm", padding = 0.1, colour = G.C.L_BLACK, r = 0.15, minw = 10.4, outline = 0.03, outline_colour = HEX('2e8b57') }, nodes = slot_nodes },
            -- Kyra Desk & Speech Bubble
            { n = G.UIT.R, config = { align = "cm", padding = 0.12, minh = 1.6, colour = G.C.L_BLACK, r = 0.15, emboss = 0.06, minw = 10.4, outline = 0.04, outline_colour = G.C.PURPLE }, nodes = {
                { n = G.UIT.C, config = { align = "cm", padding = 0.04, minw = 1.7, w = 1.7 }, nodes = {
                    { n = G.UIT.O, config = { object = kyra_area, w = kyra_w, h = kyra_h } },
                    { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = {
                        { n = G.UIT.T, config = { text = "Kyra", scale = 0.34, colour = G.C.PURPLE, shadow = true } }
                    }}
                }},
                { n = G.UIT.C, config = { align = "cl", padding = 0.15, minw = 8.3, w = 8.3, minh = 1.4, colour = G.C.BLACK, r = 0.12, outline = 0.03, outline_colour = G.C.PURPLE }, nodes = {
                    { n = G.UIT.R, config = { align = "cl", padding = 0.02 }, nodes = {
                        { n = G.UIT.T, config = { text = "💬 KYRA (Alchemist)", scale = 0.26, colour = G.C.PURPLE } }
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

-- Backward compatibility aliases for Potions
if G and G.P_CENTERS then
    local potion_aliases = {
        ['c_Witch_brew_potion_estiramiento'] = 'c_Witch_brew_potion_stretch',
        ['c_Witch_brew_potion_rayo'] = 'c_Witch_brew_potion_lightning',
        ['c_Witch_brew_potion_ventisca'] = 'c_Witch_brew_potion_blizzard',
        ['c_Witch_brew_potion_furia'] = 'c_Witch_brew_potion_fury',
        ['c_Witch_brew_potion_amalgama'] = 'c_Witch_brew_potion_amalgam',
        ['c_Witch_brew_potion_mercurio'] = 'c_Witch_brew_potion_mercury',
        ['c_Witch_brew_potion_espejo'] = 'c_Witch_brew_potion_mirror',
        ['c_Witch_brew_potion_reloj'] = 'c_Witch_brew_potion_clock',
        ['c_Witch_brew_potion_golondrina'] = 'c_Witch_brew_potion_swallow',
        ['c_Witch_brew_potion_lechuza'] = 'c_Witch_brew_potion_tawny_owl',
        ['c_Witch_brew_potion_filtro_petri'] = 'c_Witch_brew_potion_petri',
        ['c_Witch_brew_potion_oropendola'] = 'c_Witch_brew_potion_golden_oriole',
        ['c_Witch_brew_potion_sangre_negra'] = 'c_Witch_brew_potion_black_blood',
    }
    for old_k, new_k in pairs(potion_aliases) do
        if G.P_CENTERS[new_k] and not G.P_CENTERS[old_k] then
            G.P_CENTERS[old_k] = G.P_CENTERS[new_k]
        end
    end
end

