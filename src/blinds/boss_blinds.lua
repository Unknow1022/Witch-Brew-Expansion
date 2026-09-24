-- Boss Blinds Atlas
SMODS.Atlas {
    key = "witch_brew_blinds",
    path = "blinds.png",
    px = 34,
    py = 34
}
-- Boss Blinds
G.Witch_brew_BLIND_THEMES = {
    ['pole'] = {
        name = 'The Pole',
        boss_colour = HEX('868686'),
        new_colour = HEX('2b2b2b'),
        special_colour = HEX('a3a3a3'),
        tertiary_colour = HEX('1a1a1a'),
        contrast = 2
    },
    ['stick'] = {
        name = 'The Rod',
        boss_colour = HEX('439a4f'),
        new_colour = HEX('1a3e20'),
        special_colour = HEX('71b27a'),
        tertiary_colour = HEX('0e2312'),
        contrast = 2
    },
    ['wizard'] = {
        name = 'The Magician',
        boss_colour = HEX('8a52b4'),
        new_colour = HEX('3d165c'),
        special_colour = HEX('ad75d7'),
        tertiary_colour = HEX('200933'),
        contrast = 2.5
    },
    ['mountain'] = {
        name = 'The Mountain',
        boss_colour = HEX('5b94b3'),
        new_colour = HEX('1a3c4f'),
        special_colour = HEX('78b1d0'),
        tertiary_colour = HEX('0f222d'),
        contrast = 2
    },
    ['door'] = {
        name = 'The Door',
        boss_colour = HEX('ff1fdb'),
        new_colour = HEX('610052'),
        special_colour = HEX('ff55e4'),
        tertiary_colour = HEX('300028'),
        contrast = 2.5
    },
    ['triangle'] = {
        name = 'The Triangle',
        boss_colour = HEX('2e8a81'),
        new_colour = HEX('0d3d37'),
        special_colour = HEX('52aea5'),
        tertiary_colour = HEX('05211e'),
        contrast = 2
    },
    ['cube'] = {
        name = 'The Cube',
        boss_colour = HEX('5e8bd6'),
        new_colour = HEX('18386e'),
        special_colour = HEX('7ba8f3'),
        tertiary_colour = HEX('0b1c3b'),
        contrast = 2.5
    },
    ['void'] = {
        name = 'The Void',
        boss_colour = HEX('150426'),
        new_colour = HEX('090112'),
        special_colour = HEX('b067b1'),
        tertiary_colour = HEX('000000'),
        contrast = 3
    },
    ['guitar'] = {
        name = 'The Guitar',
        boss_colour = HEX('ce515a'),
        new_colour = HEX('541318'),
        special_colour = HEX('ef727b'),
        tertiary_colour = HEX('2b080b'),
        contrast = 2.5
    },
    ['phone'] = {
        name = 'The Phone',
        boss_colour = HEX('00b281'),
        new_colour = HEX('004230'),
        special_colour = HEX('00e3a5'),
        tertiary_colour = HEX('002118'),
        contrast = 2
    },
    ['pinza'] = {
        name = 'The Pincer',
        boss_colour = HEX('777777'),
        new_colour = HEX('2d3436'),
        special_colour = HEX('b2bec3'),
        tertiary_colour = HEX('181d1e'),
        contrast = 3
    },
    ['doppelganger'] = {
        name = 'The Doppelgänger',
        boss_colour = HEX('1c2833'),
        new_colour = HEX('0e141a'),
        special_colour = HEX('aeb6bf'),
        tertiary_colour = HEX('070a0d'),
        contrast = 2.5
    },
    ['The Doppelgänger'] = {
        name = 'The Doppelgänger',
        boss_colour = HEX('1c2833'),
        new_colour = HEX('0e141a'),
        special_colour = HEX('aeb6bf'),
        tertiary_colour = HEX('070a0d'),
        contrast = 2.5
    },
    ['The Doppelganger'] = {
        name = 'The Doppelgänger',
        boss_colour = HEX('1c2833'),
        new_colour = HEX('0e141a'),
        special_colour = HEX('aeb6bf'),
        tertiary_colour = HEX('070a0d'),
        contrast = 2.5
    },
    ['The Void'] = {
        name = 'The Void',
        boss_colour = HEX('150426'),
        new_colour = HEX('090112'),
        special_colour = HEX('b067b1'),
        tertiary_colour = HEX('000000'),
        contrast = 3
    },
    ['The Pincer'] = {
        name = 'The Pincer',
        boss_colour = HEX('777777'),
        new_colour = HEX('2d3436'),
        special_colour = HEX('b2bec3'),
        tertiary_colour = HEX('181d1e'),
        contrast = 3
    }
}

function get_witch_brew_blind_theme(blind)
    if not blind or not G.Witch_brew_BLIND_THEMES then return nil end
    local key = ''
    local bname = ''
    if type(blind) == 'string' then
        key = blind
        bname = blind
    elseif type(blind) == 'table' then
        key = (blind.config and blind.config.blind and blind.config.blind.key)
            or (blind.config and blind.config.center and blind.config.center.key)
            or blind.key
            or blind.name
            or ''
        bname = blind.name or ''
    end
    key = string.gsub(key, '^bl_Witch_brew_', '')
    key = string.gsub(key, '^b_Witch_brew_', '')
    key = string.gsub(key, '^bl_', '')
    key = string.gsub(key, '^b_', '')

    local theme = G.Witch_brew_BLIND_THEMES[key] or (bname ~= '' and G.Witch_brew_BLIND_THEMES[bname])
    if not theme then
        local lkey = string.lower(key)
        local lbname = string.lower(bname)
        if string.find(lkey, 'doppel', 1, true) or string.find(lbname, 'doppel', 1, true) then
            return G.Witch_brew_BLIND_THEMES['doppelganger']
        end
        if string.find(lkey, 'void', 1, true) or string.find(lbname, 'void', 1, true) then
            return G.Witch_brew_BLIND_THEMES['void']
        end
        if string.find(lkey, 'pinza', 1, true) or string.find(lkey, 'pincer', 1, true) or string.find(lbname, 'pincer', 1, true) or string.find(lbname, 'pinza', 1, true) then
            return G.Witch_brew_BLIND_THEMES['pinza']
        end
        for k, v in pairs(G.Witch_brew_BLIND_THEMES) do
            if string.find(key, k, 1, true) or (bname ~= '' and (string.find(bname, v.name, 1, true) or string.find(bname, k, 1, true))) then
                theme = v
                break
            end
        end
    end
    return theme
end

function ease_custom_blind_background(blind)
    local theme = get_witch_brew_blind_theme(blind)
    if not theme then return end

    G.GAME.blind_color = theme.special_colour or theme.boss_colour
    G.ARGS.blind_colour = G.GAME.blind_color
    if G.C and G.C.DYN_UI then
        if G.C.DYN_UI.BOSS_MAIN and theme.boss_colour then
            ease_colour(G.C.DYN_UI.BOSS_MAIN, theme.boss_colour)
        end
        if G.C.DYN_UI.BOSS_DARK and (theme.tertiary_colour or theme.boss_colour) then
            ease_colour(G.C.DYN_UI.BOSS_DARK, theme.tertiary_colour or theme.boss_colour)
        end
        if G.C.DYN_UI.MAIN and theme.special_colour then
            ease_colour(G.C.DYN_UI.MAIN, theme.special_colour)
        end
        if G.C.DYN_UI.DARK and theme.tertiary_colour then
            ease_colour(G.C.DYN_UI.DARK, theme.tertiary_colour)
        end
    end
    ease_background_colour{
        new_colour = theme.new_colour,
        special_colour = theme.special_colour,
        tertiary_colour = theme.tertiary_colour,
        contrast = theme.contrast or 2,
        _is_witch_brew_theme = true
    }
end

local function sync_witch_brew_blind_colours()
    if not G.C or not G.C.BLIND or not G.Witch_brew_BLIND_THEMES then return end
    for key, data in pairs(G.Witch_brew_BLIND_THEMES) do
        G.C.BLIND[key] = data.boss_colour
        G.C.BLIND['b_Witch_brew_' .. key] = data.boss_colour
        G.C.BLIND['bl_Witch_brew_' .. key] = data.boss_colour
        if data.name then
            G.C.BLIND[data.name] = data.boss_colour
        end
    end
end

-- 1. The Pole
SMODS.Blind {
    key = 'pole',
    atlas = 'witch_brew_blinds',
    pos = { x = 0, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 3, max = 10 },
    boss_colour = HEX('868686'),
    loc_txt = {
        name = 'The Pole',
        text = {
            "Cards with Editions (Foil, Holo, Poly)",
            "lose $10 when scored"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card and context.other_card.edition then
            ease_dollars(-10)
            return {
                message = '-$10',
                colour = G.C.MONEY
            }
        end
    end
}

-- 2. The Rod
SMODS.Blind {
    key = 'stick',
    atlas = 'witch_brew_blinds',
    pos = { x = 1, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 3, max = 10 },
    boss_colour = HEX('439a4f'),
    loc_txt = {
        name = 'The Rod',
        text = {
            "If score triples target,",
            "next round target is X1.5"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    defeat = function(self)
        if G.GAME.chips and G.GAME.blind and G.GAME.chips >= G.GAME.blind.chips * 3 then
            G.GAME.stick_penalty = 1.5
        end
    end
}

-- 3. The Magician
SMODS.Blind {
    key = 'wizard',
    atlas = 'witch_brew_blinds',
    pos = { x = 2, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 3, max = 10 },
    boss_colour = HEX('8a52b4'),
    loc_txt = {
        name = 'The Magician',
        text = {
            "All Enhanced cards",
            "are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                if self.recalc_debuff and self:recalc_debuff(c) then
                    c:set_debuff(true)
                end
            end
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        if self.disabled then return false end
        if card and card.area ~= G.jokers then
            local is_enhanced = (card.ability and card.ability.set == 'Enhanced') or
                               (card.config and card.config.center and card.config.center.set == 'Enhanced') or
                               (card.config and card.config.center_key and G.P_CENTERS and G.P_CENTERS[card.config.center_key] and G.P_CENTERS[card.config.center_key].set == 'Enhanced')
            if is_enhanced then
                return true
            end
        end
        return false
    end,
    disable = function(self)
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                c:set_debuff(false)
            end
        end
    end,
    defeat = function(self)
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                c:set_debuff(false)
            end
        end
    end
}

-- 4. The Mountain
SMODS.Blind {
    key = 'mountain',
    atlas = 'witch_brew_blinds',
    pos = { x = 3, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 3, max = 10 },
    boss_colour = HEX('5b94b3'),
    loc_txt = {
        name = 'The Mountain',
        text = {
            "Using consumables disables",
            "scoring on the next hand"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if G.GAME and G.GAME.mountain_disabled_hand then
            if not check then
                G.GAME.mountain_disabled_hand = nil
            end
            return true
        end
    end,
    defeat = function(self)
        if G.GAME then G.GAME.mountain_disabled_hand = nil end
    end,
    disable = function(self)
        if G.GAME then G.GAME.mountain_disabled_hand = nil end
    end
}

-- 5. The Door
SMODS.Blind {
    key = 'door',
    atlas = 'witch_brew_blinds',
    pos = { x = 4, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 3, max = 10 },
    boss_colour = HEX('ff1fdb'),
    loc_txt = {
        name = 'The Door',
        text = {
            "Hands with odd number",
            "of cards do not score"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if cards and #cards > 0 and (#cards % 2 ~= 0) then
            return true
        end
    end
}

-- 6. The Triangle
SMODS.Blind {
    key = 'triangle',
    atlas = 'witch_brew_blinds',
    pos = { x = 5, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 3, max = 10 },
    boss_colour = HEX('2e8a81'),
    loc_txt = {
        name = 'The Triangle',
        text = {
            "Hands with even number",
            "of cards do not score"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if cards and #cards > 0 and (#cards % 2 == 0) then
            return true
        end
    end
}

-- 7. The Cube
SMODS.Blind {
    key = 'cube',
    atlas = 'witch_brew_blinds',
    pos = { x = 0, y = 1 },
    dollars = 5,
    mult = 2,
    boss = { min = 1, max = 10 },
    boss_colour = HEX('5e8bd6'),
    loc_txt = {
        name = 'The Cube',
        text = {
            "Halves final Chips and Mult",
            "if the number is even in final scoring"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, card, context)
        if context.before then
            G.GAME.cube_triggered = nil
        end
        if context.final_scoring_step and not G.GAME.cube_triggered then
            G.GAME.cube_triggered = true
            local c_val = to_big and to_big(hand_chips or context.chips or 0) or (hand_chips or context.chips or 0)
            local m_val = to_big and to_big(mult or context.mult or 0) or (mult or context.mult or 0)
            local is_even_chips = false
            local is_even_mult = false

            if to_big then
                is_even_chips = (c_val > to_big(0)) and ((c_val % to_big(2)) == to_big(0))
                is_even_mult = (m_val > to_big(0)) and ((m_val % to_big(2)) == to_big(0))
            else
                is_even_chips = (c_val > 0) and (c_val % 2 == 0)
                is_even_mult = (m_val > 0) and (m_val % 2 == 0)
            end

            local mod_chips = is_even_chips and 0.5 or 1
            local mod_mult = is_even_mult and 0.5 or 1
            if mod_chips < 1 or mod_mult < 1 then
                return {
                    x_chips = mod_chips,
                    Xmult = mod_mult,
                    message = 'Cube Halved!',
                    colour = HEX('5e8bd6')
                }
            end
        end
    end
}

-- 8. The Void (Showdown)
SMODS.Blind {
    key = 'void',
    atlas = 'witch_brew_blinds',
    pos = { x = 1, y = 1 },
    dollars = 8,
    mult = 2,
    boss = { min = 8, max = 10, showdown = true },
    showdown = true,
    boss_colour = HEX('150426'),
    loc_txt = {
        name = 'The Void',
        text = {
            "Increases chip requirement by",
            "{C:attention}X1.25{} after each played hand",
            "that does not defeat the blind"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.chips < G.GAME.blind.chips then
                G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 1.25)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                return {
                    message = 'X1.25 Target!',
                    colour = HEX('b067b1')
                }
            end
        end
    end
}

-- 9. The Guitar (La Guitarra)
SMODS.Blind {
    key = 'guitar',
    atlas = 'witch_brew_blinds',
    pos = { x = 2, y = 1 },
    dollars = 5,
    mult = 2,
    boss = { min = 3, max = 10 },
    boss_colour = HEX('ce515a'),
    loc_txt = {
        name = 'The Guitar',
        text = {
            "Hands containing 5 cards",
            "do not score"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if cards and #cards == 5 then
            return true
        end
    end
}

-- 10. The Phone (El Teléfono)
SMODS.Blind {
    key = 'phone',
    atlas = 'witch_brew_blinds',
    pos = { x = 3, y = 1 },
    dollars = 5,
    mult = 2,
    boss = { min = 3, max = 10 },
    boss_colour = HEX('00b281'),
    loc_txt = {
        name = 'The Phone',
        text = {
            "Only the 1st scoring card scores",
            "and triggers Jokers"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, card, context)
        if context.before and context.scoring_hand and #context.scoring_hand > 1 then
            for i = 2, #context.scoring_hand do
                context.scoring_hand[i]:set_debuff(true)
                context.scoring_hand[i].debuffed_by_phone = true
            end
            return {
                message = '1st Card Only!',
                colour = HEX('00b281')
            }
        end
        if context.after and context.scoring_hand then
            for i = 2, #context.scoring_hand do
                if context.scoring_hand[i].debuffed_by_phone then
                    context.scoring_hand[i]:set_debuff(false)
                    context.scoring_hand[i].debuffed_by_phone = nil
                end
            end
        end
    end,
    defeat = function(self)
        if clear_witch_brew_phone_debuffs then clear_witch_brew_phone_debuffs() end
    end,
    disable = function(self)
        if clear_witch_brew_phone_debuffs then clear_witch_brew_phone_debuffs() end
    end
}

-- 11. The Pincer (La Pinza - Showdown Boss)
SMODS.Blind {
    key = 'pinza',
    atlas = 'witch_brew_blinds',
    pos = { x = 4, y = 1 },
    dollars = 8,
    mult = 2,
    boss = { min = 8, max = 10, showdown = true },
    showdown = true,
    boss_colour = HEX('777777'),
    loc_txt = {
        name = 'The Pincer',
        text = {
            "All Jokers are disabled until a playing",
            "card is destroyed (except card-destroying Jokers)"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        G.GAME.pinza_card_destroyed = nil
        ease_custom_blind_background(self)
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                local key = (j.config and j.config.center and j.config.center.key) or j.config.center_key or (j.ability and j.ability.name) or ''
                local destroys_cards = {
                    ['j_trading'] = true,
                    ['j_sixth_sense'] = true,
                    ['c_Witch_brew_butcher_job'] = true,
                    ['j_c_butcher'] = true
                }
                if not destroys_cards[key] then
                    j:set_debuff(true)
                end
            end
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        if self.disabled then return false end
        if card and card.area == G.jokers and not G.GAME.pinza_card_destroyed then
            local key = (card.config and card.config.center and card.config.center.key) or card.config.center_key or (card.ability and card.ability.name) or ''
            local destroys_cards = {
                ['j_trading'] = true,
                ['j_sixth_sense'] = true,
                ['c_Witch_brew_butcher_job'] = true,
                ['j_c_butcher'] = true
            }
            if destroys_cards[key] then return false end
            return true
        end
        return false
    end
}

local function joker_affects_scoring(card)
    if not card or not card.ability then return false end
    local center = card.config and card.config.center
    local key = (center and center.key) or card.config.center_key or card.ability.name or ''
    
    local non_scoring_keys = {
        ['j_riff_raff'] = true, ['j_trading'] = true, ['j_cartomancer'] = true, ['j_hallucination'] = true,
        ['j_vagabond'] = true, ['j_marble'] = true, ['j_certificate'] = true, ['j_dna'] = true,
        ['j_sixth_sense'] = true, ['j_seance'] = true, ['j_burglar'] = true, ['j_luchador'] = true,
        ['j_chicot'] = true, ['j_mr_bones'] = true, ['j_diet_cola'] = true, ['j_golden'] = true,
        ['j_delayed_grat'] = true, ['j_cloud_9'] = true, ['j_rocket'] = true, ['j_credit_card'] = true,
        ['j_to_the_moon'] = true, ['j_egg'] = true, ['j_gift'] = true, ['j_chaos'] = true,
        ['j_oops'] = true, ['j_merry_andy'] = true, ['j_troubadour'] = true, ['j_turtle_bean'] = true,
        ['j_jugglier'] = true, ['j_drunkard'] = true, ['j_faceless'] = true, ['j_mail'] = true,
        ['j_satellite'] = true, ['j_invisible'] = true, ['j_showman'] = true, ['j_matador'] = true,
        ['j_space'] = true, ['j_splash'] = true, ['j_four_fingers'] = true, ['j_shortcut'] = true,
        ['j_smeared'] = true, ['j_pareidolia'] = true, ['j_blueprint'] = true, ['j_brainstorm'] = true
    }
    if non_scoring_keys[key] or string.find(key, 'chameleon', 1, true) or string.find(key, 'brainprint', 1, true) then
        return false
    end

    local ab = card.ability
    if type(ab) == 'table' then
        if (ab.mult and ab.mult ~= 0) or (ab.chips and ab.chips ~= 0) or (ab.x_mult and ab.x_mult > 1) or (ab.Xmult and ab.Xmult > 1) or (ab.t_mult and ab.t_mult ~= 0) or (ab.t_chips and ab.t_chips ~= 0) or (ab.x_chips and ab.x_chips > 1) or ab.repetitions or ab.repetition then
            return true
        end
        if type(ab.extra) == 'table' then
            local ex = ab.extra
            if (ex.mult and ex.mult ~= 0) or (ex.chips and ex.chips ~= 0) or (ex.x_mult and ex.x_mult > 1) or (ex.Xmult and ex.Xmult > 1) or (ex.s_mult and ex.s_mult ~= 0) or (ex.xmult and ex.xmult > 1) or (ex.x_chips and ex.x_chips > 1) or ex.repetitions or ex.repetition or ex.retrigger then
                return true
            end
        end
    end

    local loc_target = (G.localization and G.localization.descriptions and G.localization.descriptions.Joker and G.localization.descriptions.Joker[key])
    local text_lines = (loc_target and loc_target.text) or (center and center.loc_txt and center.loc_txt.text)
    if text_lines then
        local combined = ""
        for _, l in ipairs(text_lines) do
            combined = combined .. " " .. tostring(l)
        end
        combined = string.lower(combined)
        local scoring_words = {'mult', 'chip', 'ficha', 'xmult', 'retrigger', 're-trigger', 'reactiv', 'repetir', 'repite', 'again'}
        for _, w in ipairs(scoring_words) do
            if string.find(combined, w, 1, true) then
                return true
            end
        end
    end

    return false
end

-- 12. The Doppelgänger (El Doppelgänger - Showdown Boss)
SMODS.Blind {
    key = 'doppelganger',
    atlas = 'witch_brew_blinds',
    pos = { x = 5, y = 1 },
    dollars = 8,
    mult = 2,
    boss = { min = 8, max = 10, showdown = true },
    showdown = true,
    boss_colour = HEX('1c2833'),
    loc_vars = function(self)
        local target_name = (G.GAME and G.GAME.doppelganger_target_name) or "a random Joker"
        return { vars = { target_name } }
    end,
    loc_txt = {
        name = 'The Doppelgänger',
        text = {
            "Possesses 1 of your Jokers.",
            "When it triggers, divide",
            "Chips and Mult by 4"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                j.doppelganger_reflected = nil
            end
        end
        G.GAME.doppelganger_target = nil
        G.GAME.doppelganger_target_name = nil

        local eligible = {}
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if not j.debuff and joker_affects_scoring(j) then
                    table.insert(eligible, j)
                end
            end
            if #eligible == 0 then
                for _, j in ipairs(G.jokers.cards) do
                    if joker_affects_scoring(j) then
                        table.insert(eligible, j)
                    end
                end
            end
            if #eligible == 0 then
                for _, j in ipairs(G.jokers.cards) do
                    table.insert(eligible, j)
                end
            end
        end

        if #eligible > 0 then
            local ante = (G.GAME.round_resets and G.GAME.round_resets.ante) or 1
            local r_num = (G.GAME.round) or 1
            local pick_idx = pseudorandom('doppel_pick_' .. ante .. '_' .. r_num, 1, #eligible)
            local chosen = eligible[pick_idx]
            G.GAME.doppelganger_target = chosen
            chosen.doppelganger_reflected = true
            local jname = (chosen.ability and chosen.ability.name) or (chosen.config and chosen.config.center and chosen.config.center.name) or 'Joker'
            G.GAME.doppelganger_target_name = jname

            self.loc_debuff_text = "Possessed: " .. jname .. " (÷4 Chips & Mult)"
            if G.GAME.blind then
                G.GAME.blind.loc_debuff_text = self.loc_debuff_text
            end

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    if chosen and not chosen.removed then
                        chosen:juice_up(0.8, 0.8)
                        attention_text({
                            text = tostring(jname) .. ' Possessed!',
                            scale = 0.7,
                            hold = 2.5,
                            colour = HEX('aeb6bf'),
                            align = 'cm',
                            offset = { x = 0, y = -1.2 }
                        })
                    end
                    return true
                end
            }))
        else
            self.loc_debuff_text = "No Jokers to possess"
            if G.GAME.blind then
                G.GAME.blind.loc_debuff_text = self.loc_debuff_text
            end
        end
    end,
    calculate = function(self, card, context)
        local context = context or card
        if not context then return end

        if context.before then
            -- Repick if target is removed or sold or not eligible
            if not G.GAME.doppelganger_target or G.GAME.doppelganger_target.removed or (G.GAME.doppelganger_target.area and G.GAME.doppelganger_target.area ~= G.jokers) then
                local eligible = {}
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        if joker_affects_scoring(j) then
                            table.insert(eligible, j)
                        end
                    end
                end
                if #eligible > 0 then
                    local ante = (G.GAME.round_resets and G.GAME.round_resets.ante) or 1
                    local r_num = (G.GAME.round) or 1
                    local pick_idx = pseudorandom('doppel_repick_' .. ante .. '_' .. r_num, 1, #eligible)
                    local chosen = eligible[pick_idx]
                    G.GAME.doppelganger_target = chosen
                    if chosen then
                        chosen.doppelganger_reflected = true
                        local jname = (chosen.ability and chosen.ability.name) or (chosen.config and chosen.config.center and chosen.config.center.name) or 'Joker'
                        G.GAME.doppelganger_target_name = jname
                        self.loc_debuff_text = "Possessed: " .. jname .. " (÷4 Chips & Mult)"
                        if G.GAME.blind then
                            G.GAME.blind.loc_debuff_text = self.loc_debuff_text
                        end
                    end
                else
                    G.GAME.doppelganger_target = nil
                    G.GAME.doppelganger_target_name = "None"
                end
            end

            -- If the possessed Joker is a retrigger Joker, flag for ÷4 penalty instead of debuffing cards
            local target = G.GAME.doppelganger_target
            if target and not target.debuff and context.scoring_hand then
                for _, scoring_card in ipairs(context.scoring_hand) do
                    local rep_eval = target:calculate_joker({
                        cardarea = G.play,
                        full_hand = context.full_hand or G.play.cards,
                        scoring_hand = context.scoring_hand,
                        poker_hands = context.poker_hands,
                        other_card = scoring_card,
                        repetition = true,
                        doppel_sim = true
                    })
                    if rep_eval and (rep_eval.repetitions or (type(rep_eval) == 'table' and rep_eval.jokers and rep_eval.jokers.repetitions)) then
                        G.GAME.doppel_retrigger_penalized = true
                    end
                end
            end
        end

        if context.after and G.GAME.doppel_retrigger_penalized then
            G.GAME.doppel_retrigger_penalized = nil
            if G.GAME.blind then
                G.GAME.blind:juice_up(0.4, 0.4)
            end
            if G.GAME.doppelganger_target then
                G.GAME.doppelganger_target:juice_up(0.4, 0.4)
            end
            play_sound('blind_chips', 0.8, 0.7)
            return {
                x_chips = 0.25,
                Xmult = 0.25,
                message = '÷4 Chips & Mult!',
                colour = G.C.RED
            }
        end
    end,
    defeat = function(self)
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                j.doppelganger_reflected = nil
            end
        end
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                if c.doppel_ignored then
                    c.doppel_ignored = nil
                    c.debuff = nil
                end
            end
        end
        G.GAME.doppelganger_target = nil
        G.GAME.doppelganger_target_name = nil
        reset_witch_brew_boss_ui()
    end,
    disable = function(self)
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                j.doppelganger_reflected = nil
            end
        end
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                if c.doppel_ignored then
                    c.doppel_ignored = nil
                    c.debuff = nil
                end
            end
        end
        G.GAME.doppelganger_target = nil
        G.GAME.doppelganger_target_name = nil
        reset_witch_brew_boss_ui()
    end
}

local function sync_blind_atlases()
    local atlas_obj = (SMODS and SMODS.Atlases and SMODS.Atlases['witch_brew_blinds']) or (G.ASSET_ATLAS and G.ASSET_ATLAS['witch_brew_blinds']) or (G.ANIMATION_ATLAS and G.ANIMATION_ATLAS['witch_brew_blinds'])
    if atlas_obj then
        if G.ASSET_ATLAS and not G.ASSET_ATLAS['witch_brew_blinds'] then G.ASSET_ATLAS['witch_brew_blinds'] = atlas_obj end
        if G.ANIMATION_ATLAS and not G.ANIMATION_ATLAS['witch_brew_blinds'] then G.ANIMATION_ATLAS['witch_brew_blinds'] = atlas_obj end
    end
    sync_witch_brew_blind_colours()
end

sync_blind_atlases()
G.E_MANAGER:add_event(Event({
    func = function()
        sync_blind_atlases()
        return true
    end
}))


