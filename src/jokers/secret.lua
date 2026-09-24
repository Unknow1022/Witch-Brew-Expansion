-- Secret Jokers (Secret Rarity)
SMODS.Atlas {
    key = "secret_jokers",
    path = "secret_jokers.png",
    px = 71,
    py = 95
}
-- Helper to register secret jokers with standard attributes and badges
local function register_secret_joker(def)
    def.rarity = def.rarity or 4
    def.is_secret = true
    def.soul_pos = def.soul_pos or { x = 1, y = (def.pos and def.pos.y) or 0 }
    def.cost = def.cost or 20
    def.in_pool = def.in_pool or function(self, args)
        return false, { allow_duplicates = false }
    end
    def.set_card_type_badge = def.set_card_type_badge or function(self, card, badges)
        badges[1] = create_badge('Secret', HEX('000000'), G.C.WHITE, 1.2)
    end
    def.set_badges = def.set_badges or function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Secret', HEX('000000'), G.C.WHITE, 1.2)
        end
    end
    return SMODS.Joker(def)
end

-- Color palettes analyzed directly from secret_jokers.png for each Secret / Amalgam Joker
local SECRET_JOKER_PALETTES = {
    ['esteban']                     = { HEX('cab564'), HEX('d4be69'), HEX('5a5a5a'), HEX('97884b'), HEX('ffffff') },
    ['thiago']                      = { HEX('a1a0ff'), HEX('c0c0ff'), HEX('4948c8'), HEX('162ca2'), HEX('e5e5ff') },
    ['black_hole_joker']            = { HEX('ff6b00'), HEX('fe9d56'), HEX('424242'), HEX('1e1f88'), HEX('ffffff') },
    ['squele']                      = { HEX('ff2400'), HEX('ffffff'), HEX('000000'), HEX('291e1e') },
    ['bluxdir']                     = { HEX('00df00'), HEX('00ec00'), HEX('016400'), HEX('467437'), HEX('ffffff') },
    ['charles']                     = { HEX('f40000'), HEX('a90000'), HEX('ff2a00'), HEX('ee0000'), HEX('ff788c') },
    ['mochi']                       = { HEX('e100ca'), HEX('c400ca'), HEX('ffe22b'), HEX('82ebff'), HEX('cc8b58') },
    ['helin']                       = { HEX('8d60b5'), HEX('00ff3d'), HEX('d3d3d3'), HEX('bababa'), HEX('ffffff') },
    ['raytracing']                  = { HEX('7093cf'), HEX('415d8d'), HEX('e0ac54'), HEX('606060'), HEX('ffffff') },
    ['paco']                        = { HEX('ebb746'), HEX('fefe46'), HEX('ffd16d'), HEX('ff0005'), HEX('8a5000') },
    ['yairo']                       = { HEX('6c93c5'), HEX('8fb6e8'), HEX('3506d5'), HEX('ff91ed'), HEX('e9f3ff') },
    ['kyra']                        = { HEX('69e8f6'), HEX('ffffff'), HEX('292d2f'), HEX('363636') },
    ['brainprint']                  = { HEX('4b69cf'), HEX('7d93e2'), HEX('c6d2fc'), HEX('f9edd3'), HEX('ffffff') },
    ['vampiric_midas']              = { HEX('fee25d'), HEX('ffcc7e'), HEX('af823c'), HEX('766200'), HEX('ffffff') },
    ['certified_programming']        = { HEX('80ff01'), HEX('6cdb00'), HEX('4d9a00'), HEX('b6fe6c'), HEX('ffffff') },
    ['galactic_traveler']            = { HEX('3d4b74'), HEX('4b5596'), HEX('fadc34'), HEX('fede2e'), HEX('131320') },
    ['colorful_street']              = { HEX('27773c'), HEX('6ea43e'), HEX('75648b'), HEX('7f3701'), HEX('4c402b') },
    ['astra']                       = { HEX('d488f2'), HEX('e7acff'), HEX('bf73dd'), HEX('873ba5'), HEX('a2b1da') },
    ['marie']                       = { HEX('3afb41'), HEX('9effa1'), HEX('65ff57'), HEX('ffda61'), HEX('ffffff') },
    ['callie']                      = { HEX('ff4dca'), HEX('ff77dd'), HEX('ff3efc'), HEX('ffda61'), HEX('ffffff') },
    ['sally']                       = { HEX('e8413e'), HEX('e85f5c'), HEX('ff0000'), HEX('8c000c'), HEX('ffffff') },
    ['mime_king']                   = { HEX('fa4c3a'), HEX('e8463d'), HEX('edf1f8'), HEX('646464'), HEX('ffffff') },
    ['photo_album']                 = { HEX('5d8ea4'), HEX('926e3b'), HEX('fd5f55'), HEX('fbf1e1'), HEX('ffffff') },
    ['pirate_egg']                  = { HEX('fddd30'), HEX('f7f571'), HEX('fda200'), HEX('be9b63'), HEX('4f6367') },
    ['reinforced_boots']            = { HEX('ffe682'), HEX('fddd30'), HEX('caad3b'), HEX('dbb83e'), HEX('4f6367') },
    ['wee_comedian']                = { HEX('69e8f6'), HEX('009cfd'), HEX('26acff'), HEX('cd2f25'), HEX('ffffff') },
    ['golden_lucky_cat']            = { HEX('fac15e'), HEX('ffc360'), HEX('fb2700'), HEX('fbf5ea'), HEX('eab14f') },
    ['unrecognizable_antique']      = { HEX('82b171'), HEX('b4c863'), HEX('e7d3bc'), HEX('dbf574'), HEX('4f6367') },
    ['macabre_emoji']               = { HEX('ff0f00'), HEX('b54d25'), HEX('9c2d06'), HEX('ffffff'), HEX('000000') },
    -- Aliases en español
    ['midas_vampirico']             = { HEX('fee25d'), HEX('ffcc7e'), HEX('af823c'), HEX('766200'), HEX('ffffff') },
    ['programacion_certificacion']   = { HEX('80ff01'), HEX('6cdb00'), HEX('4d9a00'), HEX('b6fe6c'), HEX('ffffff') },
    ['viajero_galactico']           = { HEX('3d4b74'), HEX('4b5596'), HEX('fadc34'), HEX('fede2e'), HEX('131320') },
    ['calle_colorida']               = { HEX('27773c'), HEX('6ea43e'), HEX('75648b'), HEX('7f3701'), HEX('4c402b') },
    ['rey_de_mimos']                = { HEX('fa4c3a'), HEX('e8463d'), HEX('edf1f8'), HEX('646464'), HEX('ffffff') },
    ['album_de_fotos']              = { HEX('5d8ea4'), HEX('926e3b'), HEX('fd5f55'), HEX('fbf1e1'), HEX('ffffff') },
    ['huevo_pirata']                = { HEX('fddd30'), HEX('f7f571'), HEX('fda200'), HEX('be9b63'), HEX('4f6367') },
    ['botas_reforzadas']            = { HEX('ffe682'), HEX('fddd30'), HEX('caad3b'), HEX('dbb83e'), HEX('4f6367') },
    ['gato_dorado_suerte']          = { HEX('fac15e'), HEX('ffc360'), HEX('fb2700'), HEX('fbf5ea'), HEX('eab14f') },
    ['antiguedad_irreconocible']    = { HEX('82b171'), HEX('b4c863'), HEX('e7d3bc'), HEX('dbf574'), HEX('4f6367') },
    ['emoji_macabro']               = { HEX('ff0f00'), HEX('b54d25'), HEX('9c2d06'), HEX('ffffff'), HEX('000000') },
}

local function get_secret_palette(card, center)
    local key = (center and (center.key or center.name)) or (card and get_card_key and get_card_key(card)) or ''
    key = string.lower(tostring(key))
    local clean_key = key:gsub('^j_witch_brew_', ''):gsub('^j_', '')
    if SECRET_JOKER_PALETTES[clean_key] then
        return SECRET_JOKER_PALETTES[clean_key]
    end
    for k, palette in pairs(SECRET_JOKER_PALETTES) do
        if string.find(key, k, 1, true) then
            return palette
        end
    end
    if string.find(key, 'black_hole', 1, true) then return SECRET_JOKER_PALETTES['black_hole_joker'] end
    if string.find(key, 'astra', 1, true) then return SECRET_JOKER_PALETTES['astra'] end
    if string.find(key, 'marie', 1, true) then return SECRET_JOKER_PALETTES['marie'] end
    if string.find(key, 'callie', 1, true) then return SECRET_JOKER_PALETTES['callie'] end
    if string.find(key, 'sally', 1, true) then return SECRET_JOKER_PALETTES['sally'] end
    if string.find(key, 'programacion', 1, true) or string.find(key, 'certificacion', 1, true) or string.find(key, 'certified', 1, true) or string.find(key, 'programming', 1, true) then return SECRET_JOKER_PALETTES['certified_programming'] end
    if string.find(key, 'viajero', 1, true) or string.find(key, 'galactico', 1, true) or string.find(key, 'galactic', 1, true) or string.find(key, 'traveler', 1, true) then return SECRET_JOKER_PALETTES['galactic_traveler'] end
    if string.find(key, 'calle', 1, true) or string.find(key, 'colorida', 1, true) or string.find(key, 'colorful', 1, true) or string.find(key, 'street', 1, true) then return SECRET_JOKER_PALETTES['colorful_street'] end
    if string.find(key, 'midas', 1, true) or string.find(key, 'vampirico', 1, true) or string.find(key, 'vampiric', 1, true) then return SECRET_JOKER_PALETTES['vampiric_midas'] end
    if string.find(key, 'mime', 1, true) or string.find(key, 'mimo', 1, true) then return SECRET_JOKER_PALETTES['mime_king'] end
    if string.find(key, 'photo', 1, true) or string.find(key, 'album', 1, true) or string.find(key, 'foto', 1, true) then return SECRET_JOKER_PALETTES['photo_album'] end
    if string.find(key, 'egg', 1, true) or string.find(key, 'huevo', 1, true) or string.find(key, 'pirat', 1, true) then return SECRET_JOKER_PALETTES['pirate_egg'] end
    if string.find(key, 'boot', 1, true) or string.find(key, 'bota', 1, true) then return SECRET_JOKER_PALETTES['reinforced_boots'] end
    if string.find(key, 'wee', 1, true) or string.find(key, 'comedian', 1, true) then return SECRET_JOKER_PALETTES['wee_comedian'] end
    if string.find(key, 'lucky_cat', 1, true) or string.find(key, 'gato', 1, true) then return SECRET_JOKER_PALETTES['golden_lucky_cat'] end
    if string.find(key, 'antique', 1, true) or string.find(key, 'antiguedad', 1, true) then return SECRET_JOKER_PALETTES['unrecognizable_antique'] end
    if string.find(key, 'emoji', 1, true) or string.find(key, 'macabre', 1, true) or string.find(key, 'macabro', 1, true) then return SECRET_JOKER_PALETTES['macabre_emoji'] end
    if (center and (center.is_amalgam or center.rarity == 'Amalgam')) or (card and is_amalgam_card and is_amalgam_card(card)) then
        return { HEX('8a2be2'), HEX('bf55ec'), HEX('00ffff'), HEX('ffffff') }
    end
    return { HEX('d4af37'), HEX('ffffff'), HEX('ff4500'), HEX('00e5ff') }
end

local function add_secret_particles(card, center)
    if not card or not (card.VT or card.T) then return end
    if card.children and card.children.secret_particles then
        card.children.secret_particles:remove()
        card.children.secret_particles = nil
    end

    local palette = get_secret_palette(card, center)
    local p = Particles(0, 0, 0, 0, {
        timer = 0.08,
        scale = 0.16,
        speed = 0.55,
        lifespan = 1.6,
        attach = card,
        colours = palette,
        fill = true,
        padding = 0,
        vel_variation = 0.5,
        initialize = true,
    })
    p.custom_draw = true
    card.children.secret_particles = p
end

SMODS.DrawStep {
    key = 'secret_particles',
    order = 65,
    func = function(self)
        if self.children and self.children.secret_particles and (self.config.center.discovered or self.bypass_discovery_center) then
            self.children.secret_particles:draw()
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

if SMODS.draw_ignore_keys then
    SMODS.draw_ignore_keys.secret_particles = true
end

local orig_card_set_sprites = Card.set_sprites
function Card:set_sprites(_center, _front)
    orig_card_set_sprites(self, _center, _front)
    if self.children and self.children.secret_particles then
        self.children.secret_particles:remove()
        self.children.secret_particles = nil
    end
    local c = _center or self.config.center
    if c and (c.is_secret or c.is_amalgam or (is_secret_card and is_secret_card(self)) or (is_amalgam_card and is_amalgam_card(self))) then
        add_secret_particles(self, c)
    end
end

local orig_card_remove = Card.remove
function Card:remove()
    if self.children and self.children.secret_particles then
        self.children.secret_particles:remove()
        self.children.secret_particles = nil
    end
    return orig_card_remove(self)
end

-- 1. Esteban
register_secret_joker {
    key = 'esteban',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Esteban',
        text = {
            "Played {C:spades}Spades{} and {C:clubs}Clubs{}",
            "give {X:mult,C:white}X#1#{} Mult when scored"
        }
    },
    config = { extra = { xmult = 2.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 2.5
        return { vars = { xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs') then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2.5,
                    card = card
                }
            end
        end
    end
}

-- 2. Thiago
register_secret_joker {
    key = 'thiago',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'Thiago',
        text = {
            "Gives {X:mult,C:white}+X1{} Mult for every",
            "{C:chips}#1# Chips{} scored in hand"
        }
    },
    config = { extra = { chips_per_xmult = 20 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local chips_req = (card and card.ability and card.ability.extra and card.ability.extra.chips_per_xmult) or (self.config and self.config.extra and self.config.extra.chips_per_xmult) or 20
        return { vars = { chips_req } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local current_chips = (hand_chips and hand_chips > 0 and hand_chips) or (context.chips and context.chips > 0 and context.chips) or 0
            local chips_req = (card.ability and card.ability.extra and card.ability.extra.chips_per_xmult) or 20
            local xmult = math.floor(current_chips / chips_req)
            if xmult > 1 then
                return {
                    Xmult = xmult,
                    card = card
                }
            end
        end
    end
}

-- 3. Black Hole
register_secret_joker {
    key = 'black_hole_joker',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    loc_txt = {
        name = 'Black Hole',
        text = {
            "Raises final {C:chips}Chips{} and",
            "{C:mult}Mult{} to the power of {C:attention}^#1#{}"
        }
    },
    config = { extra = { pow = 1.2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local pow = (card and card.ability and card.ability.extra and card.ability.extra.pow) or (self.config and self.config.extra and self.config.extra.pow) or 1.2
        return { vars = { pow } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local pow = (card.ability and card.ability.extra and card.ability.extra.pow) or 1.2

            if hand_chips and hand_chips > 1 then
                hand_chips = math.floor(hand_chips ^ pow)
            end
            if mult and mult > 1 then
                mult = math.floor(mult ^ pow)
            end

            update_hand_text({ sound = 'chips2', modded = true }, { chips = hand_chips, mult = mult })

            return {
                message = '^' .. tostring(pow) .. '!',
                colour = G.C.DARK_EDITION,
                card = card
            }
        end
    end
}

-- 4. Squele
register_secret_joker {
    key = 'squele',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },
    loc_txt = {
        name = 'Squele',
        text = {
            "Played {C:hearts}Hearts{} give {C:mult}+#1#{} Mult",
            "and {X:mult,C:white}X#2#{} Mult when scored.",
            "{C:green}#3# in #4#{} chance to create a",
            "{C:dark_edition}Negative{} {C:attention}Bloodstone{}"
        }
    },
    config = { extra = { mult = 10, xmult = 1.5, odds = 8 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local mult = (card and card.ability and card.ability.extra and card.ability.extra.mult) or (self.config and self.config.extra and self.config.extra.mult) or 10
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 1.5
        local odds = (card and card.ability and card.ability.extra and card.ability.extra.odds) or (self.config and self.config.extra and self.config.extra.odds) or 8
        return { vars = { mult, xmult, (G.GAME and G.GAME.probabilities.normal or 1), odds } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Hearts') then
            local norm = (G.GAME and G.GAME.probabilities.normal or 1)
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 10
            local does_project = pseudorandom('squele_project') < (norm / odds)

            if does_project and not context.blueprint and G.jokers then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_j = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_bloodstone', 'squele')
                        new_j:set_edition({ negative = true }, true)
                        new_j:add_to_deck()
                        G.jokers:emplace(new_j)
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Negative Bloodstone!', colour = G.C.DARK_EDITION })
                        return true
                    end
                }))
            end

            return {
                mult = card.ability.extra.mult,
                x_mult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

-- 5. Bluxdir
register_secret_joker {
    key = 'bluxdir',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 4 },
    soul_pos = { x = 1, y = 4 },
    loc_txt = {
        name = 'Bluxdir',
        text = {
            "Discarding a hand levels up",
            "that discarded {C:attention}poker hand{}"
        }
    },
    config = {},
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.pre_discard and not context.hook and context.full_hand and #context.full_hand > 0 then
            local text, loc_disp_text, poker_hands, scoring_hand, disp_text = G.FUNCS.get_poker_hand_info(context.full_hand)
            if text and text ~= 'NULL' and G.GAME and G.GAME.hands and G.GAME.hands[text] then
                level_up_hand(card, text, false, 1)
            end
        end
    end
}

-- 6. Charles
register_secret_joker {
    key = 'charles',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 5 },
    soul_pos = { x = 1, y = 5 },
    loc_txt = {
        name = 'Charles',
        text = {
            "Earn {C:money}$#2#{} for each scored card.",
            "Played {C:spades}Spades{} and {C:hearts}Hearts{}",
            "give {X:mult,C:white}X#1#{} Mult when scored"
        }
    },
    config = { extra = { xmult = 2, dollars = 5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 2
        local dollars = (card and card.ability and card.ability.extra and card.ability.extra.dollars) or (self.config and self.config.extra and self.config.extra.dollars) or 5
        return { vars = { xmult, dollars } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if has_charles_and_mochi() then
                return {
                    repetitions = 1,
                    card = card
                }
            end
        end

        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            if has_charles_and_mochi() then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        card:juice_up(0.8, 0.8)
                        return true
                    end
                }))
            end
        end

        if context.individual and context.cardarea == G.play then
            local dollars = (card.ability and card.ability.extra and card.ability.extra.dollars) or 5
            local gives_xmult = context.other_card:is_suit('Spades') or context.other_card:is_suit('Hearts')
            local xmult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2

            if gives_xmult then
                return {
                    x_mult = xmult,
                    dollars = dollars,
                    card = card
                }
            else
                return {
                    dollars = dollars,
                    card = card
                }
            end
        end
    end
}

-- 7. Mochi
register_secret_joker {
    key = 'mochi',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 6 },
    soul_pos = { x = 1, y = 6 },
    loc_txt = {
        name = 'Mochi',
        text = {
            "Scored cards become {C:attention}Wild Cards{}.",
            "Gives {X:mult,C:white}+X#1#{} Mult for each",
            "{C:attention}Wild Card{} in your full deck",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult_gain = (card and card.ability and card.ability.extra and card.ability.extra.xmult_gain) or (self.config and self.config.extra and self.config.extra.xmult_gain) or 0.25
        local wild_count = 0
        if G.playing_cards then
            for _, pcard in ipairs(G.playing_cards) do
                if is_wild_card(pcard) then
                    wild_count = wild_count + 1
                end
            end
        end
        local current_xmult = 1.0 + (wild_count * xmult_gain)
        return { vars = { xmult_gain, current_xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config and context.other_card.config.center ~= G.P_CENTERS.m_wild then
                context.other_card:set_ability(G.P_CENTERS.m_wild)
                context.other_card:juice_up()
            end
        end

        if context.joker_main then
            local wild_count = 0
            if G.playing_cards then
                for _, pcard in ipairs(G.playing_cards) do
                    if is_wild_card(pcard) then
                        wild_count = wild_count + 1
                    end
                end
            end
            local xmult_gain = (card.ability and card.ability.extra and card.ability.extra.xmult_gain) or 0.25
            local total_xmult = 1.0 + (wild_count * xmult_gain)
            if total_xmult > 1 then
                return {
                    Xmult = total_xmult
                }
            end
        end
    end
}

-- 8. Helin
register_secret_joker {
    key = 'helin',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 7 },
    soul_pos = { x = 1, y = 7 },
    loc_txt = {
        name = 'Helin',
        text = {
            "Raises {C:mult}Mult{} to the power",
            "of {X:mult,C:white}^#1#{} at end of scoring"
        }
    },
    config = { extra = { power = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local power = (card and card.ability and card.ability.extra and card.ability.extra.power) or (self.config and self.config.extra and self.config.extra.power) or 2
        return { vars = { power } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local pow = (card.ability and card.ability.extra and card.ability.extra.power) or 2
            if to_big or type(mult) == 'table' then
                return {
                    e_mult = pow,
                    card = card
                }
            elseif mult and mult > 1 then
                mult = math.floor(mult ^ pow)
                update_hand_text({ sound = 'multhit2', modded = true }, { mult = mult })
                return {
                    message = '^' .. tostring(pow) .. ' Mult!',
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
}

-- 9. RayTracing
register_secret_joker {
    key = 'raytracing',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 8 },
    soul_pos = { x = 1, y = 8 },
    loc_txt = {
        name = 'RayTracing',
        text = {
            "Creates {C:attention}2{} random {C:dark_edition}Negative{}",
            "{C:spectral}Spectral{} cards at end of round",
            "{C:inactive}(Except La Muchachada){}"
        }
    },
    config = {},
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    local spectral_cards = {}
                    if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Spectral'] then
                        for _, center in ipairs(G.P_CENTER_POOLS['Spectral']) do
                            if center.key ~= 'c_Witch_brew_la_muchachada' and center.key ~= 'c_la_muchachada' and center.key ~= 'la_muchachada' then
                                table.insert(spectral_cards, center.key)
                            end
                        end
                    end
                    for i = 1, 2 do
                        local chosen_spectral = (#spectral_cards > 0) and pseudorandom_element(spectral_cards, 'raytracing_spectral') or 'c_ankh'
                        local new_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, chosen_spectral, 'raytracing')
                        new_card:set_edition({ negative = true }, true)
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                    end
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = '+2 Negative Spectrals!', colour = G.C.DARK_EDITION })
                    card:juice_up(0.6, 0.6)
                    return true
                end
            }))
        end
    end
}

-- 10. Paco
register_secret_joker {
    key = 'paco',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 9 },
    soul_pos = { x = 1, y = 9 },
    loc_txt = {
        name = 'Paco',
        text = {
            "Gives {X:mult,C:white}X#1#{} Mult for each",
            "remaining {C:attention}discard{}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_per_discard = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local xmult_per_discard = (card and card.ability and card.ability.extra and card.ability.extra.xmult_per_discard) or (self.config and self.config.extra and self.config.extra.xmult_per_discard) or 2
        local total_xmult = math.max(1, discards * xmult_per_discard)
        return { vars = { xmult_per_discard, total_xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
            local xmult_per_discard = (card.ability and card.ability.extra and card.ability.extra.xmult_per_discard) or 2
            local total_xmult = discards * xmult_per_discard
            if total_xmult > 1 then
                return {
                    Xmult = total_xmult
                }
            end
        end
    end
}

-- 11. Yairo
register_secret_joker {
    key = 'yairo',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 10 },
    soul_pos = { x = 1, y = 10 },
    loc_txt = {
        name = 'Yairo',
        text = {
            "Played {C:attention}6s{} and {C:attention}7s{} give",
            "{X:mult,C:white}X#1#{} Mult and {X:chips,C:white}X#2#{} Chips",
            "when scored"
        }
    },
    config = { extra = { xmult = 3, xchips = 1.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.xmult or 3, ex.xchips or 1.5 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = (context.other_card.get_id and context.other_card:get_id()) or (context.other_card.base and context.other_card.base.id)
            local val = context.other_card.base and context.other_card.base.value
            if id == 6 or id == 7 or val == '6' or val == '7' then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 3,
                    x_chips = (card.ability and card.ability.extra and card.ability.extra.xchips) or 1.5,
                    card = card
                }
            end
        end
    end
}

-- 12. Kyra
register_secret_joker {
    key = 'kyra',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 11 },
    soul_pos = { x = 1, y = 11 },
    loc_txt = {
        name = 'Kyra',
        text = {
            "{C:attention}Potions{} don't take consumable space.",
            "Click button and pay {C:money}$#1#{}",
            "to brew a random {C:attention}Potion{}"
        }
    },
    config = { extra = { cost = 2 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local cost = (card and card.ability and card.ability.extra and card.ability.extra.cost) or (self.config and self.config.extra and self.config.extra.cost) or 2
        return { vars = { cost } }
    end,
    calculate = function(self, card, context)
        -- Visual feedback when triggering round end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card:juice_up(0.3, 0.4)
        end
    end
}



-- Kyra Interaction Callbacks & Button Injection
G.FUNCS = G.FUNCS or {}

G.FUNCS.can_pay_kyra = function(e)
    local card = e.config.ref_table
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    -- Kyra allows potions to bypass consumable capacity limits
    if cur_dollars >= 2 and not (card and card.debuff) and not (G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND or G.STATE == G.STATES.PLAY_TAROT) then
        e.config.colour = G.C.GOLD
        e.config.button = 'pay_kyra'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.pay_kyra = function(e)
    local card = e.config.ref_table
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    if cur_dollars >= 2 and G.consumeables then
        ease_dollars(-2)
        play_sound('coin3')
        if card then card:juice_up(0.6, 0.6) end
        G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.25,
            func = function()
                local new_potion = (create_potion_card_safe and create_potion_card_safe(G.consumeables, 'kyra_brew')) or create_card('Potion', G.consumeables, nil, nil, nil, nil, nil, 'kyra')
                if not new_potion or not new_potion.config then
                    new_potion = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'kyra_fallback')
                end
                new_potion:add_to_deck()
                G.consumeables:emplace(new_potion)
                G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
                new_potion:juice_up(0.6, 0.6)
                card_eval_status_text(card or new_potion, 'extra', nil, nil, nil, { message = '+Potion', colour = G.C.GREEN })
                return true
            end
        }))
    end
end

local orig_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local t = orig_use_and_sell_buttons(card)
    if card and card.area and card.area.config and card.area.config.type == 'joker' and card_has_key(card, 'kyra') and not card.debuff then
        local pay_button = {
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
                                align = "cr",
                                padding = 0.1,
                                r = 0.08,
                                minw = 1.25,
                                hover = true,
                                shadow = true,
                                colour = G.C.GOLD,
                                one_press = false,
                                button = 'pay_kyra',
                                func = 'can_pay_kyra'
                            },
                            nodes = {
                                { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                {
                                    n = G.UIT.C,
                                    config = { align = "tm" },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", maxw = 1.25 },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "POTION", colour = G.C.WHITE, scale = 0.38, shadow = true } }
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "$2", colour = G.C.WHITE, scale = 0.52, shadow = true } }
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
            table.insert(t.nodes[1].nodes, pay_button)
        end
    end
    return t
end

-- Helper to register Amalgam Tier Jokers with Amalgama badge
function register_amalgam_joker(def)
    def.rarity = def.rarity or 4
    def.is_amalgam = true
    def.soul_pos = def.soul_pos or { x = 1, y = (def.pos and def.pos.y) or 0 }
    def.cost = def.cost or 25
    def.in_pool = def.in_pool or function(self, args)
        return false, { allow_duplicates = false }
    end
    def.set_card_type_badge = def.set_card_type_badge or function(self, card, badges)
        badges[1] = create_badge('Amalgam', HEX('8a2be2'), G.C.WHITE, 1.2)
    end
    def.set_badges = def.set_badges or function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Amalgam', HEX('8a2be2'), G.C.WHITE, 1.2)
        end
    end
    return SMODS.Joker(def)
end

-- Amalgam Joker: Brainprint (Brainstorm + Blueprint)
register_amalgam_joker {
    key = 'brainprint',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 12 },
    soul_pos = { x = 1, y = 12 },
    loc_txt = {
        name = 'Brainprint',
        text = {
            "Copies abilities of the {C:attention}Jokers{}",
            "to the immediate left and right"
        }
    },
    config = {},
    blueprint_compat = false,
    calculate = function(self, card, context)
        if not G.jokers or not G.jokers.cards then return end
        local my_idx = nil
        for idx, j in ipairs(G.jokers.cards) do
            if j == card then my_idx = idx; break end
        end
        if not my_idx then return end

        local left_joker = (my_idx > 1) and G.jokers.cards[my_idx - 1] or nil
        local right_joker = (my_idx < #G.jokers.cards) and G.jokers.cards[my_idx + 1] or nil

        local left_ret = nil
        local right_ret = nil

        -- Copiar Joker Izquierdo
        if left_joker and left_joker ~= card and is_joker_copiable(left_joker) then
            left_ret = SMODS.blueprint_effect(card, left_joker, context)
        end

        -- Copiar Joker Derecho
        if right_joker and right_joker ~= card and is_joker_copiable(right_joker) then
            right_ret = SMODS.blueprint_effect(card, right_joker, context)
        end

        if left_ret and right_ret then
            if type(left_ret) == 'table' and type(right_ret) == 'table' then
                local merged = {}
                for k, v in pairs(left_ret) do merged[k] = v end
                if right_ret.chips then merged.chips = (merged.chips or 0) + right_ret.chips end
                if right_ret.mult then merged.mult = (merged.mult or 0) + right_ret.mult end
                if right_ret.x_mult or right_ret.Xmult then
                    local xm1 = merged.x_mult or merged.Xmult or 1
                    local xm2 = right_ret.x_mult or right_ret.Xmult or 1
                    merged.x_mult = xm1 * xm2
                end
                if right_ret.dollars then merged.dollars = (merged.dollars or 0) + right_ret.dollars end
                merged.card = card
                return merged
            else
                return left_ret
            end
        elseif left_ret then
            if type(left_ret) == 'table' then left_ret.card = card end
            return left_ret
        elseif right_ret then
            if type(right_ret) == 'table' then right_ret.card = card end
            return right_ret
        end
    end
}


-- Amalgam Joker: Vampiric Midas (Midas Mask + Vampire)
register_amalgam_joker {
    key = 'midas_vampirico',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 0 },
    soul_pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Vampiric Midas',
        text = {
            "Turns scored cards into {C:attention}Gold Cards{},",
            "then absorbs their enhancements to gain",
            "{X:mult,C:white}+X#1#{} Mult each {C:inactive}(keeps seals & editions){}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0 } }
    end,
    calculate = function(self, card, context)
        if context.blueprint then return nil end

        -- Al jugar la mano: primero convierte a Oro, luego absorbe mejoras (sin tocar sellos ni ediciones)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local cards_to_process = context.scoring_hand or context.full_hand or {}

            -- 1. Coloca el efecto de Oro
            for _, c in ipairs(cards_to_process) do
                if not c.debuff and c.config.center ~= G.P_CENTERS.m_gold then
                    c:set_ability(G.P_CENTERS.m_gold, nil, true)
                    local target = c
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target then target:juice_up() end
                            return true
                        end
                    }))
                end
            end

            -- 2. Absorbe mejoras (Oro o cualquier otra mejora, preservando sellos y ediciones)
            local absorbed_count = 0
            for _, c in ipairs(cards_to_process) do
                if not c.debuff and c.config.center ~= G.P_CENTERS.c_base then
                    absorbed_count = absorbed_count + 1
                    c:set_ability(G.P_CENTERS.c_base, nil, true)
                    local target = c
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target then target:juice_up() end
                            return true
                        end
                    }))
                end
            end

            if absorbed_count > 0 then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + absorbed_count * (card.ability.extra.xmult_gain or 0.25)
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        -- Otorga XMult en joker_main al jugarse las cartas
        if context.joker_main and not context.blueprint and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

-- Amalgam Joker: Certified Programming (Hologram + Certificate)
register_amalgam_joker {
    key = 'programacion_certificacion',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 1 },
    soul_pos = {
        x = 3,
        y = 1,
        draw = function(card, scale_mod, rotate_mod)
            if card.children.floating_sprite then
                scale_mod = scale_mod or (0.07 + 0.02 * math.sin(1.8 * G.TIMERS.REAL))
                rotate_mod = rotate_mod or (0.05 * math.sin(1.219 * G.TIMERS.REAL))
                card.hover_tilt = (card.hover_tilt or 1) * 1.5
                card.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, card.children.center, 2 * scale_mod, 2 * rotate_mod)
                card.hover_tilt = (card.hover_tilt or 1.5) / 1.5
            end
        end
    },
    loc_txt = {
        name = 'Certified Programming',
        text = {
            "At start of round, adds {C:attention}2{} cards with a",
            "random {C:attention}Seal{} and {C:attention}Enhancement{} to hand.",
            "Gains {X:mult,C:white}+X#1#{} Mult when any card is added to deck",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0 } }
    end,
    calculate = function(self, card, context)
        -- Añade 2 cartas con sello y mejora al inicio de ronda
        if context.first_hand_drawn then
            local target_card = context.blueprint_card or card
            G.E_MANAGER:add_event(Event({
                func = function()
                    local created_cards = {}
                    for i = 1, 2 do
                        local _card = create_playing_card({
                            front = pseudorandom_element(G.P_CARDS, pseudoseed('cert_fr' .. i)),
                            center = G.P_CENTERS.c_base
                        }, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Enhanced })
                        local seals = { 'Red', 'Blue', 'Gold', 'Purple' }
                        local chosen_seal = pseudorandom_element(seals, pseudoseed('cert_seal' .. i))
                        _card:set_seal(chosen_seal, true)
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Enhanced then
                            local chosen_enh = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('cert_enh' .. i))
                            if chosen_enh then _card:set_ability(chosen_enh) end
                        end
                        created_cards[#created_cards + 1] = _card
                    end
                    G.hand:sort()
                    card_eval_status_text(target_card, 'extra', nil, nil, nil, { message = localize('k_plus_card') })
                    if playing_card_joker_effects then
                        playing_card_joker_effects(created_cards)
                    elseif SMODS and SMODS.calculate_context then
                        SMODS.calculate_context({ playing_card_added = true, cards = created_cards })
                    end
                    return true
                end
            }))
        end
        -- Gana +XMult cuando se añade cualquier carta a la baraja
        if context.playing_card_added and not context.blueprint and context.cards and #context.cards > 0 then
            card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + #context.cards * (card.ability.extra.xmult_gain or 0.25)
            return {
                message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                colour = G.C.RED,
                card = card
            }
        end
        -- Otorga XMult en joker_main
        if context.joker_main and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

-- Amalgam Joker: Galactic Traveler (Constellation + Astronomer)
register_amalgam_joker {
    key = 'viajero_galactico',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 2 },
    soul_pos = { x = 3, y = 2 },
    loc_txt = {
        name = 'Galactic Traveler',
        text = {
            "{C:blue}Planets{} and {C:blue}Celestial Packs{} are {C:attention}free{}.",
            "Gains {X:mult,C:white}+X#1#{} Mult per {C:blue}Planet{} used.",
            "Doubles sell value of {C:blue}Planets{}.",
            "{C:green}#3# in #4#{} chance to level up played hand",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0, odds = 2 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0, (G.GAME and G.GAME.probabilities.normal or 1), extra.odds or 2 } }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.I and G.I.CARD then
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.I and G.I.CARD then
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                end
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        if context.blueprint then return nil end
        -- Chance de 1 en 2 de subir nivel de la mano jugada
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 2
            if pseudorandom('viajero_galactico') < G.GAME.probabilities.normal / odds then
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.scoring_name, 'poker_hands'), chips = G.GAME.hands[context.scoring_name].chips, mult = G.GAME.hands[context.scoring_name].mult, level=G.GAME.hands[context.scoring_name].level})
                level_up_hand(card, context.scoring_name, nil, 1)
                update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
                return {
                    message = localize('k_level_up_ex'),
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
        -- Gana +XMult cuando se consume un Planeta
        if context.using_consumeable and not context.blueprint then
            if context.consumeable and context.consumeable.ability and context.consumeable.ability.set == 'Planet' then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + (card.ability.extra.xmult_gain or 0.25)
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        -- Otorga XMult en joker_main
        if context.joker_main and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

-- Amalgam Joker: Colorful Street (Four Fingers + Shortcut + Smeared Joker)
register_amalgam_joker {
    key = 'calle_colorida',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 3 },
    soul_pos = { x = 3, y = 3 },
    loc_txt = {
        name = 'Colorful Street',
        text = {
            "{C:attention}Flushes{} and {C:attention}Straights{} can be made with {C:attention}4 cards{}.",
            "{C:attention}Straights{} can skip gaps of {C:attention}1 rank{}.",
            "{C:hearts}Hearts{} & {C:diamonds}Diamonds{} count as same suit,",
            "{C:spades}Spades{} & {C:clubs}Clubs{} count as same suit"
        }
    },
    config = {},
    blueprint_compat = false
}

-- Component jokers for each Amalgam Joker
local COMPONENT_JOKERS_BY_AMALGAM = {
    ['brainprint']                  = { 'j_blueprint', 'j_brainstorm' },
    ['midas_vampirico']             = { 'j_midas_mask', 'j_vampire' },
    ['programacion_certificacion']   = { 'j_hologram', 'j_certificate' },
    ['viajero_galactico']           = { 'j_constellation', 'j_astronomer' },
    ['calle_colorida']               = { 'j_four_fingers', 'j_shortcut', 'j_smeared' },
}

local AMALGAM_NAME_MAP = {
    ['Astronomer']      = 'viajero_galactico',
    ['Constellation']   = 'viajero_galactico',
    ['Four Fingers']    = 'calle_colorida',
    ['Shortcut']        = 'calle_colorida',
    ['Smeared Joker']   = 'calle_colorida',
    ['Midas Mask']      = 'midas_vampirico',
    ['Vampire']         = 'midas_vampirico',
    ['Hologram']        = 'programacion_certificacion',
    ['Certificate']     = 'programacion_certificacion',
    ['Blueprint']       = 'brainprint',
    ['Brainstorm']      = 'brainprint',
}

-- Hook find_joker so Amalgams count as possessing their constituent jokers
local orig_find_joker = find_joker
function find_joker(name, non_debuff)
    local jokers = orig_find_joker and orig_find_joker(name, non_debuff) or {}
    local amalgam_match = AMALGAM_NAME_MAP[name]
    if amalgam_match and G.jokers and G.jokers.cards then
        for _, v in ipairs(G.jokers.cards) do
            if v and card_has_key(v, amalgam_match) and (non_debuff or not v.debuff) then
                local already_in = false
                for _, existing in ipairs(jokers) do
                    if existing == v then already_in = true; break end
                end
                if not already_in then
                    table.insert(jokers, v)
                end
            end
        end
    end
    return jokers
end

-- Sync G.GAME.used_jokers so constituent jokers are flagged as used when owning Amalgams
local function sync_amalgam_used_jokers()
    if not (G.jokers and G.jokers.cards and G.GAME and G.GAME.used_jokers) then return end
    local owned_comps = {}
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff then
            for amalgam_key, comps in pairs(COMPONENT_JOKERS_BY_AMALGAM) do
                if card_has_key(j, amalgam_key) then
                    for _, comp_key in ipairs(comps) do
                        owned_comps[comp_key] = true
                    end
                end
            end
        end
    end
    for _, comps in pairs(COMPONENT_JOKERS_BY_AMALGAM) do
        for _, comp_key in ipairs(comps) do
            if owned_comps[comp_key] then
                G.GAME.used_jokers[comp_key] = true
            else
                local actually_owns = false
                for _, j in ipairs(G.jokers.cards) do
                    if j.config and j.config.center and j.config.center.key == comp_key then
                        actually_owns = true
                        break
                    end
                end
                if not actually_owns then
                    G.GAME.used_jokers[comp_key] = nil
                end
            end
        end
    end
end

local orig_card_add_to_deck = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    local ret = orig_card_add_to_deck and orig_card_add_to_deck(self, from_debuff)
    sync_amalgam_used_jokers()
    return ret
end

local orig_card_remove_from_deck = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
    local ret = orig_card_remove_from_deck and orig_card_remove_from_deck(self, from_debuff)
    sync_amalgam_used_jokers()
    return ret
end

-- Hook get_current_pool so constituent jokers are blocked from appearing in shop
local orig_get_current_pool = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    sync_amalgam_used_jokers()
    local pool, pool_key = orig_get_current_pool(_type, _rarity, _legendary, _append)
    if _type == 'Joker' and pool and not (next(find_joker("Showman"))) then
        local banned = {}
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if not j.debuff then
                    for amalgam_key, comps in pairs(COMPONENT_JOKERS_BY_AMALGAM) do
                        if card_has_key(j, amalgam_key) then
                            for _, comp_key in ipairs(comps) do
                                banned[comp_key] = true
                            end
                        end
                    end
                end
            end
        end
        if next(banned) then
            local has_available = false
            for _, k in ipairs(pool) do
                if k ~= 'UNAVAILABLE' and not banned[k] then
                    has_available = true
                    break
                end
            end
            if has_available then
                for i = 1, #pool do
                    if pool[i] ~= 'UNAVAILABLE' and banned[pool[i]] then
                        pool[i] = 'UNAVAILABLE'
                    end
                end
            end
        end
    end
    return pool, pool_key
end

-- Helper & hook Card:set_cost to double sell value of Planet cards for Galactic Traveler
local function has_viajero_galactico()
    if not (G and G.jokers and G.jokers.cards) then return false end
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff and card_has_key(j, 'viajero_galactico') then
            return true
        end
    end
    return false
end

local orig_card_set_cost = Card.set_cost
function Card:set_cost()
    orig_card_set_cost(self)
    if self.ability and self.ability.set == 'Planet' and has_viajero_galactico() then
        self.sell_cost = math.max(2, (self.sell_cost or 1) * 2)
        self.sell_cost_label = self.sell_cost
    end
end

-- 1. Astra
register_secret_joker {
    key = 'astra',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 13 },
    soul_pos = { x = 1, y = 13 },
    loc_txt = {
        name = 'Astra',
        text = {
            "When acquired, permanently",
            "levels up all {C:attention}poker hands{}",
            "by {C:attention}+#1#{}"
        }
    },
    config = { extra = { levels = 2 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability and card.ability.extra and card.ability.extra.levels) or 2 } }
    end,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            for hand_name, _ in pairs(G.GAME.hands) do
                level_up_hand(card, hand_name, true, (card.ability and card.ability.extra and card.ability.extra.levels) or 2)
            end
        end
    end
}

-- 2. Marie
-- Enhanced cards give X2 Mult. Retrigger 1 time for Seal, +1 more time for Edition.
register_secret_joker {
    key = 'marie',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 14 },
    soul_pos = { x = 1, y = 14 },
    loc_txt = {
        name = 'Marie',
        text = {
            "{C:attention}Enhanced{} cards give",
            "{X:mult,C:white}X#1#{} Mult when scored.",
            "Retriggers {C:attention}1{} time with a {C:attention}Seal{},",
            "and {C:attention}1{} more time with an {C:attention}Edition{}"
        }
    },
    config = { extra = { x_mult = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability and card.ability.extra and card.ability.extra.x_mult) or 2 } }
    end,
    calculate = function(self, card, context)
        -- X2 Mult whenever scored card has any enhancement
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other then
                local is_enhanced = (other.config and other.config.center and other.config.center ~= G.P_CENTERS.c_base and other.config.center.set == 'Enhanced') or (other.ability and other.ability.set == 'Enhanced')
                if is_enhanced then
                    local base_xmult = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2
                    return {
                        x_mult = base_xmult,
                        card = card
                    }
                end
            end
        end

        -- Retrigger: 1 time with any Seal, +1 more time with any Edition
        if context.repetition and context.cardarea == G.play then
            local other = context.other_card
            if other then
                local has_seal = (other.seal ~= nil and other.seal ~= '')
                local has_ed = (other.edition ~= nil and not other.edition.base)
                local reps = (has_seal and 1 or 0) + (has_ed and 1 or 0)

                if reps > 0 then
                    return {
                        repetitions = reps,
                        card = card,
                        message = localize('k_again_ex')
                    }
                end
            end
        end
    end
}


-- 3. Callie
-- Otorga 1 mejora aleatoria de cualquier tipo a las cartas (excepto negativo) una vez por carta, no sobreescribe mejoras ya existentes.
register_secret_joker {
    key = 'callie',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 15 },
    soul_pos = { x = 1, y = 15 },
    loc_txt = {
        name = 'Callie',
        text = {
            "Scored cards gain a random missing",
            "{C:attention}Enhancement{}, {C:attention}Seal{}, or {C:attention}Edition{}",
            "{C:inactive}(except Negative, once per card){}"
        }
    },
    config = { extra = {} },
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local target = context.other_card
            if target and not target.debuff then
                target.ability = target.ability or {}
                if not target.ability.callie_upgraded then
                    local has_enh = (target.config and target.config.center and target.config.center ~= G.P_CENTERS.c_base)
                    local has_seal = (target.seal ~= nil and target.seal ~= '')
                    local has_ed = (target.edition ~= nil and not target.edition.base)

                    local types = {}
                    if not has_enh then table.insert(types, 'enh') end
                    if not has_seal then table.insert(types, 'seal') end
                    if not has_ed then table.insert(types, 'edition') end

                    -- No sobreescribir si ya tiene todas las mejoras posibles
                    if #types == 0 then
                        target.ability.callie_upgraded = true
                        return
                    end

                    local has_marie = false
                    if G.jokers and G.jokers.cards then
                        for _, jk in ipairs(G.jokers.cards) do
                            if jk.config and jk.config.center and (jk.config.center.key == 'j_witch_brew_marie' or jk.config.center.key == 'marie' or (jk.config.center.key and string.find(jk.config.center.key:lower(), 'marie'))) then
                                has_marie = true; break
                            end
                        end
                    end

                    local gift_type = pseudorandom_element(types, pseudoseed('callie_choice'))

                    if gift_type == 'enh' then
                        local pool = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Enhanced then
                            for _, enh in ipairs(G.P_CENTER_POOLS.Enhanced) do
                                if enh.key and enh.key ~= 'c_base' then
                                    table.insert(pool, enh)
                                end
                            end
                        end
                        if #pool > 0 then
                            local chosen = pseudorandom_element(pool, pseudoseed('callie_enh'))
                            if chosen then target:set_ability(chosen) end
                        end
                    elseif gift_type == 'seal' then
                        local seal_pool = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Seal and #G.P_CENTER_POOLS.Seal > 0 then
                            for _, s in ipairs(G.P_CENTER_POOLS.Seal) do
                                local k = s.key or s.name
                                if k then table.insert(seal_pool, k) end
                            end
                        elseif G.P_SEALS then
                            for k, _ in pairs(G.P_SEALS) do
                                table.insert(seal_pool, k)
                            end
                        end
                        if #seal_pool == 0 then
                            seal_pool = { 'Red', 'Blue', 'Gold', 'Purple' }
                        end
                        local chosen_seal = pseudorandom_element(seal_pool, pseudoseed('callie_seal'))
                        target:set_seal(chosen_seal, true)
                    elseif gift_type == 'edition' then
                        local ed_pool = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Edition and #G.P_CENTER_POOLS.Edition > 0 then
                            for _, ed in ipairs(G.P_CENTER_POOLS.Edition) do
                                local ed_k = ed.key or ed.name
                                if ed_k and ed_k ~= 'base' and ed_k ~= 'e_base' and ed_k ~= 'negative' and ed_k ~= 'e_negative' then
                                    table.insert(ed_pool, ed_k)
                                end
                            end
                        end
                        if #ed_pool == 0 then
                            ed_pool = { 'foil', 'holo', 'polychrome' }
                        end
                        local chosen_ed = pseudorandom_element(ed_pool, pseudoseed('callie_ed'))
                        local clean_key = type(chosen_ed) == 'string' and chosen_ed:gsub('^e_', '') or chosen_ed
                        target:set_edition({ [clean_key] = true }, true, true)
                    end

                    target.ability.callie_upgraded = true
                    target:juice_up(0.3, 0.3)
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.GOLD,
                        card = card
                    }
                end
            end
        end
    end
}

-- 4. Sally
-- Desafío activo cada ciega. Al completarlo, otorga $10 y un consumible negativo aleatorio.
register_secret_joker {
    key = 'sally',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 16 },
    soul_pos = { x = 1, y = 16 },
    loc_txt = {
        name = 'Sally',
        text = {
            "Complete the challenge each blind to",
            "earn {C:money}$10{} and a random {C:dark_edition}Negative{} consumable",
            "{C:inactive}(Current: #1#){}"
        }
    },
    config = { extra = { quest = 'Play 3 Hands', progress = 0, needed = 3, reward_money = 10, completed = false } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local prog = ex.progress or 0
        local need = ex.needed or 3
        local q_name = ex.quest or 'Play 3 Hands'
        return { vars = { q_name .. ' (' .. prog .. '/' .. need .. ')' } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.completed = false
            card.ability.extra.progress = 0
            local quests = {
                { name = 'Play 3 Hands', needed = 3, type = 'hand' },
                { name = 'Discard 2 Times', needed = 2, type = 'discard' },
                { name = 'Score 10 Cards', needed = 10, type = 'score' }
            }
            local q = pseudorandom_element(quests, pseudoseed('sally_quest'))
            card.ability.extra.quest = q.name
            card.ability.extra.needed = q.needed
            card.ability.extra.q_type = q.type
        end
        if context.cardarea == G.jokers and not context.blueprint and not card.ability.extra.completed then
            local completed = false
            if context.before and card.ability.extra.q_type == 'hand' then
                card.ability.extra.progress = card.ability.extra.progress + 1
                if card.ability.extra.progress >= card.ability.extra.needed then completed = true end
            elseif context.pre_discard and card.ability.extra.q_type == 'discard' then
                card.ability.extra.progress = card.ability.extra.progress + 1
                if card.ability.extra.progress >= card.ability.extra.needed then completed = true end
            elseif context.individual and context.cardarea == G.play and card.ability.extra.q_type == 'score' then
                card.ability.extra.progress = card.ability.extra.progress + 1
                if card.ability.extra.progress >= card.ability.extra.needed then completed = true end
            end
            if completed and not card.ability.extra.completed then
                card.ability.extra.completed = true
                ease_dollars(card.ability.extra.reward_money or 10)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local c = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'sally')
                        c:set_edition({ negative = true }, true)
                        c:add_to_deck()
                        G.consumeables:emplace(c)
                        return true
                    end
                }))
                return {
                    message = '+$10',
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
}

-- 1. Mime King (Baron + Mime)
register_amalgam_joker {
    key = 'mime_king',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 4 },
    soul_pos = { x = 3, y = 4 },
    loc_txt = {
        name = 'Mime King',
        text = {
            "Cards held in hand retrigger",
            "{C:attention}#2#{} times. {C:attention}Kings{} held",
            "in hand give {X:mult,C:white}X#1#{} Mult"
        }
    },
    config = { extra = { x_mult = 2, repetitions = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.x_mult or 2, ex.repetitions or 2 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card:get_id() == 13 then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2,
                    card = card
                }
            end
        end
        if context.repetition and context.cardarea == G.hand and not context.end_of_round then
            return {
                message = localize('k_again_ex'),
                repetitions = (card.ability and card.ability.extra and card.ability.extra.repetitions) or 2,
                card = card
            }
        end
    end
}

-- 2. Photo Album (Photograph + Hanging Chad)
register_amalgam_joker {
    key = 'photo_album',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 5 },
    soul_pos = { x = 3, y = 5 },
    loc_txt = {
        name = 'Photo Album',
        text = {
            "First played card retriggers {C:attention}#2#{} times.",
            "{C:attention}Face cards{} retrigger {C:attention}#3#{} time.",
            "First {C:attention}face card{} gives {X:mult,C:white}X#1#{} Mult"
        }
    },
    config = { extra = { x_mult = 2.5, first_reps = 3, face_reps = 1 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.x_mult or 2.5, ex.first_reps or 3, ex.face_reps or 1 } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local reps = 0
            -- First card gets 3 retriggers
            if context.other_card == context.scoring_hand[1] then
                reps = reps + ((card.ability and card.ability.extra and card.ability.extra.first_reps) or 3)
            end
            -- Face cards get 1 retrigger
            if context.other_card:is_face() then
                reps = reps + ((card.ability and card.ability.extra and card.ability.extra.face_reps) or 1)
            end
            if reps > 0 then
                return {
                    message = localize('k_again_ex'),
                    repetitions = reps,
                    card = card
                }
            end
        end
        -- First face card gives x2.5 Mult
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_face() then
                -- Find the first face card in scoring_hand
                local first_face = nil
                for _, c in ipairs(context.scoring_hand or {}) do
                    if c:is_face() then first_face = c; break end
                end
                if first_face and context.other_card == first_face then
                    return {
                        x_mult = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2.5,
                        card = card
                    }
                end
            end
        end
    end
}

-- 3. Pirate Egg (Swashbuckler + Egg)
register_amalgam_joker {
    key = 'pirate_egg',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 6 },
    soul_pos = { x = 3, y = 6 },
    loc_txt = {
        name = 'Pirate Egg',
        text = {
            "Gains {C:money}$5{} sell value at end of round.",
            "{X:mult,C:white}X0.1{} Mult per {C:money}$1{} sell value",
            "of all owned {C:attention}Jokers{}",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = { mult_per_dollar = 0.1 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local total_sell = 0
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                total_sell = total_sell + (j.sell_cost or 1)
            end
        end
        local xm = 1 + total_sell * 0.1
        return { vars = { string.format('%.1f', xm) } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.repetition then
            card.ability.extra_value = (card.ability.extra_value or 0) + 5
            card:set_cost()
            return {
                message = localize('k_val_up'),
                colour = G.C.MONEY,
                card = card
            }
        end
        if context.joker_main then
            local total_sell = 0
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    total_sell = total_sell + (j.sell_cost or 1)
                end
            end
            local xm = 1 + total_sell * 0.1
            if xm > 1 then
                return {
                    Xmult = xm,
                    card = card
                }
            end
        end
    end
}

-- 4. Reinforced Boots (Bootstraps + Bull)
register_amalgam_joker {
    key = 'reinforced_boots',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 7 },
    soul_pos = { x = 3, y = 7 },
    loc_txt = {
        name = 'Reinforced Boots',
        text = {
            "{C:mult}+10{} Mult and {C:chips}+5{} Chips",
            "for every {C:money}$1{} you have",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips and {C:mult}+#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { chips_per_dollar = 5, mult_per_dollar = 10 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local d = math.max(0, (G.GAME and G.GAME.dollars or 0) + ((G.GAME and G.GAME.dollar_buffer) or 0))
        return { vars = { d * 5, d * 10 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local d = math.max(0, (G.GAME and G.GAME.dollars or 0) + ((G.GAME and G.GAME.dollar_buffer) or 0))
            if d > 0 then
                return {
                    chips = d * 5,
                    mult = d * 10,
                    card = card
                }
            end
        end
    end
}

-- 5. Wee Comedian (Wee Joker + The Hiker / Hax)
-- Cada 2 jugado se reactiva dos veces, acumula +10 Fichas por cada 2 jugado, y otorga +16 Mult por carta Fibonacci (A, 2, 3, 5, 8).
register_amalgam_joker {
    key = 'wee_comedian',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 8 },
    soul_pos = { x = 3, y = 8 },
    loc_txt = {
        name = 'Wee Comedian',
        text = {
            "Gains {C:chips}+10{} Chips per scored {C:attention}2{}.",
            "Scored {C:attention}2s{} retrigger {C:attention}2{} times.",
            "Played {C:attention}Ace, 2, 3, 5, 8{} give {C:mult}+16{} Mult.",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
        }
    },
    config = { extra = { chips = 0, chip_gain = 10 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.chips or 0 } }
    end,
    calculate = function(self, card, context)
        -- Retrigger on 2
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 2 then
                return {
                    repetitions = 2,
                    card = card
                }
            end
        end

        -- Gain chips on 2 and mult on Fibonacci
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            local fib = (id == 14 or id == 2 or id == 3 or id == 5 or id == 8)
            local res = {}
            if id == 2 and not context.blueprint then
                card.ability.extra.chips = (card.ability.extra.chips or 0) + 10
            end
            if fib then
                res.mult = 16
                res.card = card
                return res
            end
        end

        if context.joker_main then
            if (card.ability.extra.chips or 0) > 0 then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
}

-- 6. Golden Lucky Cat (Lucky Cat + Oops! All 6s)
register_amalgam_joker {
    key = 'golden_lucky_cat',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 9 },
    soul_pos = { x = 3, y = 9 },
    loc_txt = {
        name = 'Golden Lucky Cat',
        text = {
            "Adds {C:attention}+2{} to all {C:green}probabilities{}.",
            "Gains {X:mult,C:white}+X0.5{} Mult whenever any",
            "{C:attention}Lucky{} card or probability triggers",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = { x_mult = 1.0, gain = 0.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.x_mult or 1.0 } }
    end,
    add_to_deck = function(self, card, from_debuff)
        if G.GAME and G.GAME.probabilities then
            G.GAME.probabilities.normal = (G.GAME.probabilities.normal or 1) + 2
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if G.GAME and G.GAME.probabilities then
            G.GAME.probabilities.normal = math.max(1, (G.GAME.probabilities.normal or 1) - 2)
        end
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            if other.lucky_trigger then
                card.ability.extra.x_mult = (card.ability.extra.x_mult or 1.0) + 0.5
                return {
                    message = 'Lucky! +X0.5',
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
        if context.joker_main and (card.ability.extra.x_mult or 1.0) > 1 then
            return {
                x_mult = card.ability.extra.x_mult,
                card = card
            }
        end
    end
}

-- 7. Unrecognizable Antique (Ancient Joker + Smeared Joker)
register_amalgam_joker {
    key = 'unrecognizable_antique',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 10 },
    soul_pos = { x = 3, y = 10 },
    loc_txt = {
        name = 'Unrecognizable Antique',
        text = {
            "Played cards of chosen color suit give {X:mult,C:white}X2{} Mult.",
            "{C:hearts}Hearts{} & {C:diamonds}Diamonds{} count as same suit,",
            "{C:spades}Spades{} & {C:clubs}Clubs{} count as same suit.",
            "{C:inactive}(Current suit: {C:attention}#1#{C:inactive}){}"
        }
    },
    config = { extra = { suit_group = 'Red' } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.suit_group or 'Red' } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.suit_group = pseudorandom('antiguedad_group') < 0.5 and 'Red' or 'Black'
        end
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            local s = other.base and other.base.suit
            local grp = (s == 'Hearts' or s == 'Diamonds') and 'Red' or 'Black'
            if grp == (card.ability.extra.suit_group or 'Red') then
                return {
                    x_mult = 2,
                    card = card
                }
            end
        end
    end
}

-- 8. Macabre Emoji (Smiley Face + Scary Face)
register_amalgam_joker {
    key = 'macabre_emoji',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 11 },
    soul_pos = { x = 3, y = 11 },
    loc_txt = {
        name = 'Macabre Emoji',
        text = {
            "Played {C:attention}face cards{} give",
            "{C:mult}+20{} Mult and {C:chips}+100{} Chips",
            "when scored"
        }
    },
    config = { extra = { mult = 20, chips = 100 } },
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_face() then
                return {
                    mult = 20,
                    chips = 100,
                    card = card
                }
            end
        end
    end
}

-- Registrar amalgamas en COMPONENT_JOKERS_BY_AMALGAM
if COMPONENT_JOKERS_BY_AMALGAM then
    COMPONENT_JOKERS_BY_AMALGAM['mime_king'] = { 'j_mime', 'j_baron' }
    COMPONENT_JOKERS_BY_AMALGAM['photo_album'] = { 'j_hanging_chad', 'j_photograph' }
    COMPONENT_JOKERS_BY_AMALGAM['pirate_egg'] = { 'j_swashbuckler', 'j_egg' }
    COMPONENT_JOKERS_BY_AMALGAM['reinforced_boots'] = { 'j_bootstraps', 'j_bull' }
    COMPONENT_JOKERS_BY_AMALGAM['wee_comedian'] = { 'j_wee', 'j_hiker' }
    COMPONENT_JOKERS_BY_AMALGAM['golden_lucky_cat'] = { 'j_lucky_cat', 'j_oops' }
    COMPONENT_JOKERS_BY_AMALGAM['unrecognizable_antique'] = { 'j_ancient', 'j_smeared' }
    COMPONENT_JOKERS_BY_AMALGAM['macabre_emoji'] = { 'j_smiley', 'j_scary_face' }
    -- Legacy aliases
    COMPONENT_JOKERS_BY_AMALGAM['rey_de_mimos'] = COMPONENT_JOKERS_BY_AMALGAM['mime_king']
    COMPONENT_JOKERS_BY_AMALGAM['album_de_fotos'] = COMPONENT_JOKERS_BY_AMALGAM['photo_album']
    COMPONENT_JOKERS_BY_AMALGAM['huevo_pirata'] = COMPONENT_JOKERS_BY_AMALGAM['pirate_egg']
    COMPONENT_JOKERS_BY_AMALGAM['botas_reforzadas'] = COMPONENT_JOKERS_BY_AMALGAM['reinforced_boots']
    COMPONENT_JOKERS_BY_AMALGAM['gato_dorado_suerte'] = COMPONENT_JOKERS_BY_AMALGAM['golden_lucky_cat']
    COMPONENT_JOKERS_BY_AMALGAM['antiguedad_irreconocible'] = COMPONENT_JOKERS_BY_AMALGAM['unrecognizable_antique']
    COMPONENT_JOKERS_BY_AMALGAM['emoji_macabro'] = COMPONENT_JOKERS_BY_AMALGAM['macabre_emoji']
end

