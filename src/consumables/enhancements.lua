-- Enhancements & Custom Seals
SMODS.Atlas {
    key = "enhancements",
    path = "enhancements.png",
    px = 71,
    py = 95
}

-- Helper functions for Custom Enhancement Centers
function get_custom_enhancement(name, fallback)
    if G.P_CENTERS then
        if G.P_CENTERS['m_Witch_brew_' .. name] then return G.P_CENTERS['m_Witch_brew_' .. name] end
        if G.P_CENTERS['m_' .. name] then return G.P_CENTERS['m_' .. name] end
        for k, v in pairs(G.P_CENTERS) do
            if type(v) == 'table' and string.find(k, name, 1, true) and v.set == 'Enhanced' then
                return v
            end
        end
    end
    return fallback
end

function get_diamond_enhancement_center() return get_custom_enhancement('diamond', G.P_CENTERS.m_steel) end
function get_investment_enhancement_center() return get_custom_enhancement('investment', G.P_CENTERS.m_gold) end
function get_lead_enhancement_center() return get_custom_enhancement('lead', G.P_CENTERS.m_steel) end
function get_jeweled_enhancement_center() return get_custom_enhancement('jeweled', G.P_CENTERS.m_lucky) end

-- Seal 1: Dark Green Seal (Reworked)
SMODS.Seal {
    key = 'dark_green',
    atlas = 'enhancements',
    pos = { x = 0, y = 0 },
    badge_colour = HEX('1b4d2e'),
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = 'Dark Green Seal',
        label = 'Dark Green Seal',
        text = {
            "Gives {X:mult,C:white}X2.5{} Mult when scored,",
            "{C:green}#1# in 5{} chance to break",
            "when played"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.probabilities.normal or 1) } }
    end,
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            if not card.dark_green_scored_this_hand then
                card.dark_green_scored_this_hand = true
                local prob = (G.GAME and G.GAME.probabilities.normal or 1)
                if pseudorandom('dark_green_break') < (prob / 5) then
                    card.dark_green_broken = true
                    card.shattered = true
                end
            end
            return {
                x_mult = 2.5
            }
        end
    end
}

-- Seal 2: White Seal
SMODS.Seal {
    key = 'white',
    atlas = 'enhancements',
    pos = { x = 1, y = 0 },
    badge_colour = HEX('ffffff'),
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = 'White Seal',
        label = 'White Seal',
        text = {
            "Upgrades a random {C:attention}poker hand{}",
            "by {C:attention}+1 level{} when scored"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            local hands = {}
            if G.GAME and G.GAME.hands then
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then
                        table.insert(hands, k)
                    end
                end
                if #hands == 0 then
                    for k, v in pairs(G.GAME.hands) do
                        table.insert(hands, k)
                    end
                end
            end
            local chosen_hand = pseudorandom_element(hands, pseudoseed('white_seal_hand')) or 'High Card'
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    play_sound('tarot1')
                    card:juice_up(0.3, 0.5)
                    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = chosen_hand, level = (G.GAME.hands[chosen_hand] and G.GAME.hands[chosen_hand].level or 1) + 1})
                    level_up_hand(card, chosen_hand, false, 1)
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Level Up!', colour = G.C.SECONDARY_SET.Planet })
                    return true
                end
            }))
        end
    end
}

-- Seal 3: Silver Seal
SMODS.Seal {
    key = 'silver',
    atlas = 'enhancements',
    pos = { x = 2, y = 0 },
    badge_colour = HEX('bdc3c7'),
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = 'Silver Seal',
        label = 'Silver Seal',
        text = {
            "{C:green}#1# in 4{} chance to convert into a {C:attention}Steel Card{} when played.",
            "With {C:attention}Steel Card{}: gives {X:mult,C:white}X#2#{} Mult",
            "when scored and {X:mult,C:white}X#3#{} Mult while held in hand"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
        end
        return { vars = { (G.GAME and G.GAME.probabilities.normal or 1), 2, 2.5 } }
    end,
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            local is_steel = (card.ability and card.ability.name == 'Steel Card') or (card.config and card.config.center == G.P_CENTERS.m_steel)
            local norm = (G.GAME and G.GAME.probabilities.normal or 1)
            if not is_steel and pseudorandom('silver_to_steel') < (norm / 4) then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        play_sound('gold_seal')
                        card:set_ability(G.P_CENTERS.m_steel)
                        card:juice_up(0.6, 0.6)
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Forged into Steel!', colour = G.C.GREY })
                        return true
                    end
                }))
            end
            if is_steel then
                return {
                    x_mult = 2.0,
                    card = card
                }
            end
        end
    end
}

-- Enhancement 1: Shiny Card (formerly Diamond Card)
SMODS.Enhancement {
    key = 'diamond',
    atlas = 'enhancements',
    pos = { x = 3, y = 0 },
    discovered = true,
    unlocked = true,
    config = { extra = { x_mult = 1.5, dollars = 3 } },
    loc_txt = {
        name = 'Shiny Card',
        text = {
            "Gives {X:mult,C:white}X#1#{} Mult when {C:attention}retriggered{},",
            "gives {C:money}$#2#{} once when",
            "held in hand at end of round"
        }
    },
    loc_vars = function(self, info_queue, card)
        local x_mult = (card and card.ability and card.ability.extra and card.ability.extra.x_mult) or (self.config and self.config.extra and self.config.extra.x_mult) or 1.5
        local dollars = (card and card.ability and card.ability.extra and card.ability.extra.dollars) or (self.config and self.config.extra and self.config.extra.dollars) or 3
        return { vars = { x_mult, dollars } }
    end,
    calculate = function(self, card, context)
        if card.ability and card.ability.h_dollars and card.ability.h_dollars > 0 then
            card.ability.h_dollars = 0
        end
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or { x_mult = 1.5, dollars = 3 }
        local is_retrigger = (card.repetition_trigger and card.repetition_trigger ~= 0 and card.repetition_trigger ~= false)
            or (card.retrigger_count and card.retrigger_count > 0)
            or (context.retrigger_count and context.retrigger_count > 0)

        if (context.main_scoring or context.cardarea == G.play) and not context.repetition and not context.repetition_only and not context.end_of_round then
            if is_retrigger then
                return {
                    x_mult = extra.x_mult,
                    card = card
                }
            end
        end

        if (context.end_of_round or context.playing_card_end_of_round) and context.cardarea == G.hand then
            if not context.repetition and not context.repetition_only and not is_retrigger then
                return {
                    dollars = extra.dollars,
                    card = card
                }
            end
        end
    end
}

-- Enhancement 2: Investment Card
SMODS.Enhancement {
    key = 'investment',
    atlas = 'enhancements',
    pos = { x = 0, y = 1 },
    discovered = true,
    unlocked = true,
    config = { extra = { interest_pct = 10, max_interest = 10 } },
    loc_txt = {
        name = 'Investment Card',
        text = {
            "Earns {C:money}#1#% interest{} on your current money",
            "{C:inactive}(Max {C:money}$#2#{C:inactive}){} when held in hand at end of round"
        }
    },
    loc_vars = function(self, info_queue, card)
        local interest_pct = (card and card.ability and card.ability.extra and card.ability.extra.interest_pct) or (self.config and self.config.extra and self.config.extra.interest_pct) or 10
        local max_interest = (card and card.ability and card.ability.extra and card.ability.extra.max_interest) or (self.config and self.config.extra and self.config.extra.max_interest) or 10
        return { vars = { interest_pct, max_interest } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.hand then
            local current_money = (G.GAME and G.GAME.dollars) or 0
            local interest = math.min(card.ability.extra.max_interest, math.floor(current_money * (card.ability.extra.interest_pct / 100)))
            if interest > 0 then
                ease_dollars(interest)
                return {
                    message = '+$' .. interest .. ' Interest',
                    colour = G.C.MONEY
                }
            end
        end
    end
}

-- Enhancement 3: Lead Card
SMODS.Enhancement {
    key = 'lead',
    atlas = 'enhancements',
    pos = { x = 1, y = 1 },
    discovered = true,
    unlocked = true,
    config = { bonus = 10 },
    loc_txt = {
        name = 'Lead Card',
        text = {
            "{C:chips}+#1#{} Chips.",
            "Transmutes permanently at random into",
            "{C:gold}Gold{}, {C:attention}Shiny{}, or {C:grey}Metal Card{}",
            "if hand beats the Blind requirement"
        }
    },
    loc_vars = function(self, info_queue, card)
        if card and card.ability and not card.ability.bonus then
            card.ability.bonus = (self.config and self.config.bonus) or 10
        end
        local bonus = (card and card.ability and card.ability.bonus) or (self.config and self.config.bonus) or 10
        return { vars = { bonus } }
    end,
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            card.lead_scored_in_hand = true
        end
    end
}

-- Enhancement 4: Jeweled Card
SMODS.Enhancement {
    key = 'jeweled',
    atlas = 'enhancements',
    pos = {  x = 2, y = 1 },
    discovered = true,
    unlocked = true,
    config = { extra = { x_mult = 1.25, dollars = 2 } },
    loc_txt = {
        name = 'Jeweled Card',
        text = {
            "Gives {X:mult,C:white}X#1#{} Mult and {C:money}$#2#{}",
            "when scored"
        }
    },
    loc_vars = function(self, info_queue, card)
        local x_mult = (card and card.ability and card.ability.extra and card.ability.extra.x_mult) or (self.config and self.config.extra and self.config.extra.x_mult) or 1.25
        local dollars = (card and card.ability and card.ability.extra and card.ability.extra.dollars) or (self.config and self.config.extra and self.config.extra.dollars) or 2
        return { vars = { x_mult, dollars } }
    end,
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            return {
                x_mult = card.ability.extra.x_mult,
                dollars = card.ability.extra.dollars,
                card = card
            }
        end
    end
}
