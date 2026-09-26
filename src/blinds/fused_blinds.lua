-- Fused Boss Blinds for Battle of Gods Mode (Ante 12+)
SMODS.Atlas {
    key = "witch_brew_fused_blinds",
    path = "fused_blinds.png",
    px = 34,
    py = 34
}

G.Witch_brew_BLIND_THEMES = G.Witch_brew_BLIND_THEMES or {}

local fused_themes = {
    ['obelisk'] = {
        name = 'The Obelisk',
        boss_colour = HEX('6d6a41'),
        new_colour = HEX('2d271c'),
        special_colour = HEX('8e8958'),
        tertiary_colour = HEX('1a160f'),
        contrast = 2
    },
    ['minotaur'] = {
        name = 'The Minotaur',
        boss_colour = HEX('b04d16'),
        new_colour = HEX('441a06'),
        special_colour = HEX('d56a28'),
        tertiary_colour = HEX('200a02'),
        contrast = 2
    },
    ['fortress'] = {
        name = 'The Fortress',
        boss_colour = HEX('b7616a'),
        new_colour = HEX('421b22'),
        special_colour = HEX('dc7d88'),
        tertiary_colour = HEX('220b10'),
        contrast = 2
    },
    ['mind_flayer'] = {
        name = 'The Mind Flayer',
        boss_colour = HEX('ab9297'),
        new_colour = HEX('392552'),
        special_colour = HEX('c8a4df'),
        tertiary_colour = HEX('1c0d2b'),
        contrast = 2
    },
    ['leviathan'] = {
        name = 'The Leviathan',
        boss_colour = HEX('579ec2'),
        new_colour = HEX('173b50'),
        special_colour = HEX('84c5e6'),
        tertiary_colour = HEX('091c28'),
        contrast = 2
    },
    ['iron_maiden'] = {
        name = 'The Iron Maiden',
        boss_colour = HEX('864242'),
        new_colour = HEX('381414'),
        special_colour = HEX('aa5a5a'),
        tertiary_colour = HEX('1c0808'),
        contrast = 2
    },
    ['cyclops'] = {
        name = 'The Cyclops',
        boss_colour = HEX('7c71b9'),
        new_colour = HEX('2b2052'),
        special_colour = HEX('9b8ee2'),
        tertiary_colour = HEX('140d2a'),
        contrast = 2
    },
    ['thorn_crown'] = {
        name = 'The Thorn Crown',
        boss_colour = HEX('6d6565'),
        new_colour = HEX('292424'),
        special_colour = HEX('8d8282'),
        tertiary_colour = HEX('141111'),
        contrast = 2
    },
    ['ouroboros'] = {
        name = 'The Ouroboros',
        boss_colour = HEX('49ac65'),
        new_colour = HEX('174724'),
        special_colour = HEX('6fd38c'),
        tertiary_colour = HEX('0a2411'),
        contrast = 2
    },
    ['nightshade'] = {
        name = 'The Nightshade',
        boss_colour = HEX('85719f'),
        new_colour = HEX('2f2242'),
        special_colour = HEX('a792c3'),
        tertiary_colour = HEX('170e23'),
        contrast = 2
    },
    ['black_diamond'] = {
        name = 'The Black Diamond',
        boss_colour = HEX('b1b693'),
        new_colour = HEX('383b27'),
        special_colour = HEX('cad0ac'),
        tertiary_colour = HEX('1c1e11'),
        contrast = 2
    },
    ['blood_moon'] = {
        name = 'The Blood Moon',
        boss_colour = HEX('b27ca5'),
        new_colour = HEX('44253d'),
        special_colour = HEX('cf9fc4'),
        tertiary_colour = HEX('22101e'),
        contrast = 2
    }
}

for k, v in pairs(fused_themes) do
    G.Witch_brew_BLIND_THEMES[k] = v
    G.Witch_brew_BLIND_THEMES['bl_Witch_brew_' .. k] = v
    if G.C and G.C.BLIND then
        G.C.BLIND['bl_Witch_brew_' .. k] = v.boss_colour
    end
end

local function sync_fused_blind_atlases()
    local atlas_obj = (SMODS and SMODS.Atlases and SMODS.Atlases['witch_brew_fused_blinds']) or (G.ASSET_ATLAS and G.ASSET_ATLAS['witch_brew_fused_blinds']) or (G.ANIMATION_ATLAS and G.ANIMATION_ATLAS['witch_brew_fused_blinds'])
    if atlas_obj then
        atlas_obj.frames = 21
        if G.ASSET_ATLAS and not G.ASSET_ATLAS['witch_brew_fused_blinds'] then G.ASSET_ATLAS['witch_brew_fused_blinds'] = atlas_obj end
        if G.ANIMATION_ATLAS and not G.ANIMATION_ATLAS['witch_brew_fused_blinds'] then G.ANIMATION_ATLAS['witch_brew_fused_blinds'] = atlas_obj end
    end
end

sync_fused_blind_atlases()
G.E_MANAGER:add_event(Event({
    func = function()
        sync_fused_blind_atlases()
        return true
    end
}))

-- 1. The Obelisk (Needle + Pillar)
SMODS.Blind {
    key = 'obelisk',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('6d6a41'),
    loc_txt = {
        name = 'The Obelisk',
        text = {
            "Play only 1 hand.",
            "Cards played previously",
            "this Ante are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if not reset then
            self.hands_sub = G.GAME.round_resets.hands - 1
            ease_hands_played(-self.hands_sub)
        end
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    disable = function(self)
        if self.hands_sub then
            ease_hands_played(self.hands_sub)
        end
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        if self.disabled then return false end
        return not not (card.ability and card.ability.played_this_ante)
    end
}

-- 2. The Minotaur (Ox + Hook)
SMODS.Blind {
    key = 'minotaur',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 1 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('b04d16'),
    loc_txt = {
        name = 'The Minotaur',
        text = {
            "Discards 2 random cards per hand.",
            "Sets money to $0 if most",
            "played poker hand is played"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    press_play = function(self)
        if self.disabled then return end
        G.E_MANAGER:add_event(Event({ func = function()
            local any_selected = nil
            local _cards = {}
            for k, v in ipairs(G.hand.cards) do
                _cards[#_cards+1] = v
            end
            for i = 1, 2 do
                if G.hand.cards[i] then 
                    local selected_card, card_key = pseudorandom_element(_cards, pseudoseed('hook'))
                    G.hand:add_to_highlighted(selected_card, true)
                    table.remove(_cards, card_key)
                    any_selected = true
                    play_sound('card1', 1)
                end
            end
            if any_selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
            return true
        end })) 
        self.triggered = true
        delay(0.7)
        return true
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if self.disabled then return end
        if handname == G.GAME.current_round.most_played_poker_hand then
            self.triggered = true
            if not check then
                ease_dollars(-G.GAME.dollars, true)
                if G.GAME.blind and G.GAME.blind.wiggle then
                    G.GAME.blind:wiggle()
                end
            end
        end
    end
}

-- 3. The Fortress (Wall + Flint)
SMODS.Blind {
    key = 'fortress',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 2 },
    dollars = 5,
    mult = 3,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('b7616a'),
    loc_txt = {
        name = 'The Fortress',
        text = {
            "Extra large blind.",
            "Base Chips and Mult",
            "are halved"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        if self.disabled then return mult, hand_chips, false end
        self.triggered = true
        return math.max(math.floor(mult * 0.5 + 0.5), 1), math.max(math.floor(hand_chips * 0.5 + 0.5), 0), true
    end,
    disable = function(self)
        self.chips = math.floor(self.chips / 1.5)
        self.chip_text = number_format(self.chips)
    end
}

-- 4. The Mind Flayer (Psychic + Arm)
SMODS.Blind {
    key = 'mind_flayer',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 3 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('ab9297'),
    debuff = { h_size_ge = 5 },
    loc_txt = {
        name = 'The Mind Flayer',
        text = {
            "Must play 5 cards.",
            "Decreases level of",
            "played poker hand"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if self.disabled then return end
        if #cards < 5 then
            self.triggered = true
            return true
        end
        if G.GAME.hands[handname] and G.GAME.hands[handname].level > 1 then
            self.triggered = true
            if not check then
                local sprite = G.GAME.blind and G.GAME.blind.children and G.GAME.blind.children.animatedSprite
                level_up_hand(sprite, handname, nil, -1)
                if G.GAME.blind and G.GAME.blind.wiggle then
                    G.GAME.blind:wiggle()
                end
            end
        end
    end
}

-- 5. The Leviathan (Water + Fish)
SMODS.Blind {
    key = 'leviathan',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 4 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('579ec2'),
    loc_txt = {
        name = 'The Leviathan',
        text = {
            "Start with 0 discards.",
            "Cards drawn face down",
            "after each hand played"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if not reset then
            self.discards_sub = G.GAME.current_round.discards_left
            ease_discard(-self.discards_sub)
            self.prepped = nil
        end
    end,
    disable = function(self)
        if self.discards_sub then
            ease_discard(self.discards_sub)
        end
        if G.hand and G.hand.cards then
            for i = 1, #G.hand.cards do
                if G.hand.cards[i].facing == 'back' then
                    G.hand.cards[i]:flip()
                end
            end
        end
    end,
    press_play = function(self)
        if not self.disabled then
            self.prepped = true
        end
    end,
    drawn_to_hand = function(self)
        self.prepped = nil
    end,
    stay_flipped = function(self, area, card)
        if not self.disabled and area == G.hand and self.prepped then
            return true
        end
    end
}

-- 6. The Iron Maiden (Manacle + Tooth)
SMODS.Blind {
    key = 'iron_maiden',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 5 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('864242'),
    loc_txt = {
        name = 'The Iron Maiden',
        text = {
            "-1 Hand Size.",
            "Lose $1 per card played"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if not reset and G.hand then
            G.hand:change_size(-1)
        end
    end,
    defeat = function(self)
        if not self.disabled and G.hand then
            G.hand:change_size(1)
        end
    end,
    disable = function(self)
        if G.hand then
            G.hand:change_size(1)
        end
        if G.FUNCS and G.FUNCS.draw_from_deck_to_hand then
            G.FUNCS.draw_from_deck_to_hand(1)
        end
    end,
    press_play = function(self)
        if self.disabled then return end
        G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function()
            if G.play and G.play.cards then
                for i = 1, #G.play.cards do
                    G.E_MANAGER:add_event(Event({ func = function()
                        if G.play and G.play.cards and G.play.cards[i] then
                            G.play.cards[i]:juice_up()
                        end
                        return true
                    end })) 
                    ease_dollars(-1)
                    delay(0.23)
                end
            end
            return true
        end }))
        self.triggered = true
        return true
    end
}

-- 7. The Cyclops (Eye + Mouth)
SMODS.Blind {
    key = 'cyclops',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 6 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('7c71b9'),
    loc_txt = {
        name = 'The Cyclops',
        text = {
            "Only 1 hand type",
            "allowed this round.",
            "Repeat hands are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if not reset then
            self.only_hand = false
            self.hands = {}
        end
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if self.disabled then return end
        if self.only_hand and self.only_hand ~= handname then
            self.triggered = true
            return true
        end
        if self.hands and self.hands[handname] then
            self.triggered = true
            return true
        end
        if not check then
            self.only_hand = handname
            self.hands[handname] = true
        end
    end
}

-- 8. The Thorn Crown (Mark + Plant)
SMODS.Blind {
    key = 'thorn_crown',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 7 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('6d6565'),
    debuff = { is_face = 'face' },
    loc_txt = {
        name = 'The Thorn Crown',
        text = {
            "All Face cards are",
            "drawn face down",
            "and debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    disable = function(self)
        if G.hand and G.hand.cards then
            for i = 1, #G.hand.cards do
                if G.hand.cards[i].facing == 'back' then
                    G.hand.cards[i]:flip()
                end
            end
        end
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    stay_flipped = function(self, area, card)
        if not self.disabled and area == G.hand and card:is_face(true) then
            return true
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        if self.disabled then return false end
        return card:is_face(true)
    end
}

-- 9. The Ouroboros (Wheel + Serpent)
SMODS.Blind {
    key = 'ouroboros',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 8 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('49ac65'),
    loc_txt = {
        name = 'The Ouroboros',
        text = {
            "After Play or Discard,",
            "always draw 3 cards.",
            "#1# in 7 drawn face down"
        }
    },
    loc_vars = function(self)
        return { vars = { '' .. (G.GAME and G.GAME.probabilities.normal or 1) } }
    end,
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    disable = function(self)
        if G.hand and G.hand.cards then
            for i = 1, #G.hand.cards do
                if G.hand.cards[i].facing == 'back' then
                    G.hand.cards[i]:flip()
                end
            end
        end
    end,
    stay_flipped = function(self, area, card)
        if not self.disabled and area == G.hand and pseudorandom(pseudoseed('ouroboros')) < ((G.GAME and G.GAME.probabilities.normal or 1) / 7) then
            return true
        end
    end
}

-- Serpent 3-card draw hook for The Ouroboros
if G.FUNCS and G.FUNCS.draw_from_deck_to_hand then
    local orig_draw_from_deck_to_hand = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        if G.GAME and G.GAME.blind and not G.GAME.blind.disabled and
           (G.GAME.blind.name == 'The Ouroboros' or (G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key == 'bl_Witch_brew_ouroboros')) and
           (G.GAME.current_round.hands_played > 0 or G.GAME.current_round.discards_used > 0) and not e then
            return orig_draw_from_deck_to_hand(math.min(#G.deck.cards, 3))
        end
        return orig_draw_from_deck_to_hand(e)
    end
end

-- 10. The Nightshade (House + Goad)
SMODS.Blind {
    key = 'nightshade',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 9 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('85719f'),
    debuff = { suit = 'Spades' },
    loc_txt = {
        name = 'The Nightshade',
        text = {
            "First hand drawn face down.",
            "All Spades are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    disable = function(self)
        if G.hand and G.hand.cards then
            for i = 1, #G.hand.cards do
                if G.hand.cards[i].facing == 'back' then
                    G.hand.cards[i]:flip()
                end
            end
        end
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    stay_flipped = function(self, area, card)
        if not self.disabled and area == G.hand and G.GAME.current_round.hands_played == 0 and G.GAME.current_round.discards_used == 0 then
            return true
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        if self.disabled then return false end
        return card:is_suit('Spades', true)
    end
}

-- 11. The Black Diamond (Window + Club)
SMODS.Blind {
    key = 'black_diamond',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 10 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('b1b693'),
    loc_txt = {
        name = 'The Black Diamond',
        text = {
            "All Clubs and Diamonds",
            "are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    disable = function(self)
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        if self.disabled then return false end
        return card:is_suit('Clubs', true) or card:is_suit('Diamonds', true)
    end
}

-- 12. The Blood Moon (Head + Goad)
SMODS.Blind {
    key = 'blood_moon',
    atlas = 'witch_brew_fused_blinds',
    pos = { x = 0, y = 11 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('b27ca5'),
    loc_txt = {
        name = 'The Blood Moon',
        text = {
            "All Hearts and Spades",
            "are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    set_blind = function(self, reset, silent)
        ease_custom_blind_background(self)
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    disable = function(self)
        if G.GAME.blind and G.GAME.blind.debuff_card then
            for _, v in ipairs(G.playing_cards) do
                G.GAME.blind:debuff_card(v)
            end
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        if self.disabled then return false end
        return card:is_suit('Hearts', true) or card:is_suit('Spades', true)
    end
}
