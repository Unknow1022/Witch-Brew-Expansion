-- Boss Possession Stickers & Mechanics for Battle of Gods Mode
SMODS.Atlas {
    key = "witch_brew_stickers",
    path = "stickers.png",
    px = 71,
    py = 95
}

-- 1. Possessed: The Needle (X10 Mult on 1-hand rounds)
SMODS.Sticker {
    key = "possessed_needle",
    atlas = "witch_brew_stickers",
    pos = { x = 0, y = 0 },
    badge_colour = HEX('e5b80b'),
    order = 11,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Needle)",
        text = {
            "Inverted Boss Blessing.",
            "Only 1 hand allowed per round,",
            "but that hand scores {X:mult,C:white}X10{} Mult"
        }
    },
    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_played == 0 then
            return {
                x_mult = 10,
                message = 'X10 Mult [Needle]',
                colour = G.C.PURPLE
            }
        end
    end
}

-- 2. Possessed: The Flint (Halved base stats, X2 Mult per scoring card)
SMODS.Sticker {
    key = "possessed_flint",
    atlas = "witch_brew_stickers",
    pos = { x = 1, y = 0 },
    badge_colour = HEX('e56a2f'),
    order = 12,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Flint)",
        text = {
            "Inverted Boss Blessing.",
            "Base Chips and Mult are halved,",
            "but each scoring card gives {X:mult,C:white}X2{} Mult"
        }
    },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            return {
                x_mult = 2,
                colour = G.C.ORANGE
            }
        end
    end
}

-- 3. Possessed: The Pillar (Empowers previously played cards)
SMODS.Sticker {
    key = "possessed_pillar",
    atlas = "witch_brew_stickers",
    pos = { x = 2, y = 0 },
    badge_colour = HEX('7e6752'),
    order = 13,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Pillar)",
        text = {
            "Inverted Boss Blessing.",
            "Cards played previously this Ante",
            "score {C:chips}+150{} Chips and {C:mult}+20{} Mult"
        }
    },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card and context.other_card.ability and context.other_card.ability.played_this_ante then
                return {
                    chips = 150,
                    mult = 20,
                    colour = G.C.PURPLE
                }
            end
        end
    end
}

-- 4. Possessed: The Hook (Discards 2 cards on play, grants +X1.75 Mult)
SMODS.Sticker {
    key = "possessed_hook",
    atlas = "witch_brew_stickers",
    pos = { x = 3, y = 0 },
    badge_colour = HEX('a84024'),
    order = 14,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Hook)",
        text = {
            "Inverted Boss Blessing.",
            "Discards 2 random cards on play;",
            "each discarded card adds {X:mult,C:white}+X0.75{} Mult"
        }
    },
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = 1.75,
                message = 'X1.75 Mult [Hook]',
                colour = G.C.RED
            }
        end
    end
}

-- 5. Possessed: The Psychic (Must play 5 cards, grants X3 Mult)
SMODS.Sticker {
    key = "possessed_psychic",
    atlas = "witch_brew_stickers",
    pos = { x = 4, y = 0 },
    badge_colour = HEX('efc03c'),
    order = 15,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Psychic)",
        text = {
            "Inverted Boss Blessing.",
            "Must play 5 cards;",
            "5-card hands trigger {X:mult,C:white}X3{} Mult"
        }
    },
    calculate = function(self, card, context)
        if context.joker_main and context.full_hand and #context.full_hand >= 5 then
            return {
                x_mult = 3,
                message = 'X3 Mult [Psychic]',
                colour = G.C.GOLD
            }
        end
    end
}

-- 6. Possessed: The Arm (Sacrifices 1 hand level for X4 Mult)
SMODS.Sticker {
    key = "possessed_arm",
    atlas = "witch_brew_stickers",
    pos = { x = 0, y = 1 },
    badge_colour = HEX('6865f3'),
    order = 16,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Arm)",
        text = {
            "Inverted Boss Blessing.",
            "Decreases level of played poker hand,",
            "but triggers {X:mult,C:white}X4{} Mult"
        }
    },
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = 4,
                message = 'X4 Mult [Arm]',
                colour = G.C.PURPLE
            }
        end
    end
}

-- 7. Possessed: The Eye (Restricts to 1 hand type for X3.5 Mult)
SMODS.Sticker {
    key = "possessed_eye",
    atlas = "witch_brew_stickers",
    pos = { x = 1, y = 1 },
    badge_colour = HEX('4b71e4'),
    order = 17,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Eye)",
        text = {
            "Inverted Boss Blessing.",
            "Only 1 hand type allowed this round,",
            "which scores {X:mult,C:white}X3.5{} Mult"
        }
    },
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = 3.5,
                message = 'X3.5 Mult [Eye]',
                colour = G.C.BLUE
            }
        end
    end
}

-- 8. Possessed: The Wall (Doubles target, awards +$25 on win)
SMODS.Sticker {
    key = "possessed_wall",
    atlas = "witch_brew_stickers",
    pos = { x = 2, y = 1 },
    badge_colour = HEX('8a59a5'),
    order = 18,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Wall)",
        text = {
            "Inverted Boss Blessing.",
            "Blind target is doubled,",
            "but defeating it awards {C:money}+$25{}"
        }
    },
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual then
            ease_dollars(25)
            return {
                message = '+$25 [Wall]',
                colour = G.C.MONEY
            }
        end
    end
}

-- 9. Possessed: The Serpent (Always draws 3 cards, +30 Chips per scored card)
SMODS.Sticker {
    key = "possessed_serpent",
    atlas = "witch_brew_stickers",
    pos = { x = 3, y = 1 },
    badge_colour = HEX('439a4f'),
    order = 19,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Serpent)",
        text = {
            "Inverted Boss Blessing.",
            "Always draws 3 cards after play or discard;",
            "scoring cards give {C:chips}+30{} Chips"
        }
    },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            return {
                chips = 30,
                colour = G.C.CHIPS
            }
        end
    end
}

-- 10. Possessed: The Water (Start with 0 discards, hands draw +4 cards)
SMODS.Sticker {
    key = "possessed_water",
    atlas = "witch_brew_stickers",
    pos = { x = 4, y = 1 },
    badge_colour = HEX('579ec2'),
    order = 20,
    should_apply = false,
    loc_txt = {
        name = "Possessed (Water)",
        text = {
            "Inverted Boss Blessing.",
            "Start with 0 discards,",
            "but hands played draw +4 cards immediately"
        }
    },
    calculate = function(self, card, context)
        if context.joker_main then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    if G.FUNCS.draw_from_deck_to_hand then
                        G.FUNCS.draw_from_deck_to_hand(4)
                    end
                    return true
                end
            }))
        end
    end
}

local POSSESSED_STICKER_KEYS = {
    ['needle'] = 'possessed_needle',
    ['flint'] = 'possessed_flint',
    ['pillar'] = 'possessed_pillar',
    ['hook'] = 'possessed_hook',
    ['psychic'] = 'possessed_psychic',
    ['arm'] = 'possessed_arm',
    ['eye'] = 'possessed_eye',
    ['wall'] = 'possessed_wall',
    ['serpent'] = 'possessed_serpent',
    ['water'] = 'possessed_water'
}

local ALL_POSSESSED_KEYS = {
    'possessed_needle',
    'possessed_flint',
    'possessed_pillar',
    'possessed_hook',
    'possessed_psychic',
    'possessed_arm',
    'possessed_eye',
    'possessed_wall',
    'possessed_serpent',
    'possessed_water'
}

-- Apply a specific possession sticker to a Joker
function possess_joker(card, boss_key)
    if not card or not card.ability then return end

    -- Determine sticker key from boss key
    local matched_sticker = nil
    if boss_key then
        local lk = string.lower(boss_key)
        for name_frag, sticker_name in pairs(POSSESSED_STICKER_KEYS) do
            if string.find(lk, name_frag) then
                matched_sticker = sticker_name
                break
            end
        end
    end

    matched_sticker = matched_sticker or pseudorandom_element(ALL_POSSESSED_KEYS, pseudoseed('botg_possess_pick'))

    -- Clear existing possession stickers on this card to prevent overlap
    for _, k in ipairs(ALL_POSSESSED_KEYS) do
        if card.ability[k] and SMODS.Stickers[k] then
            SMODS.Stickers[k]:apply(card, false)
        end
    end

    -- Apply new sticker
    if SMODS.Stickers[matched_sticker] then
        SMODS.Stickers[matched_sticker]:apply(card, true)
        card.ability.possessed = true
        card.ability.active_possessed_key = matched_sticker
    end

    local st_name = (SMODS.Stickers[matched_sticker] and SMODS.Stickers[matched_sticker].loc_txt and SMODS.Stickers[matched_sticker].loc_txt.name) or "Boss Possessed"
    card_eval_status_text(card, 'extra', nil, nil, nil, {
        message = st_name .. '!',
        colour = G.C.PURPLE
    })
    play_sound('whoosh1', 0.8, 0.7)
    card:juice_up(0.4, 0.4)
end
