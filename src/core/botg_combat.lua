-- Direct God Combat (Idea 9), Chronos Paradox Rewind (Idea 12), and Glitch Tears (Idea 16)
SMODS.Atlas {
    key = "witch_brew_glitch",
    path = "glitch.png",
    px = 71,
    py = 95
}



-- Direct God Combat (Turn-Based Boss HP & Counter-Attacks)
if Blind and Blind.press_play then
    local orig_blind_press_play = Blind.press_play
    function Blind:press_play()
        local ret = orig_blind_press_play(self)

        if G.GAME and G.GAME.battle_of_gods and self.boss and not self.disabled then
            -- Boss counter-attack after hand is evaluated
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 1.2,
                func = function()
                    if G.GAME.chips and self.chips and G.GAME.chips < self.chips and not self.disabled then
                        local roll = pseudorandom('botg_counter_' .. (G.GAME.round_resets.ante or 1) .. (G.GAME.current_round.hands_played or 1))
                        if roll < 0.33 then
                            -- Minor lightning zap: lose $2
                            local penalty = math.min(G.GAME.dollars or 0, 2)
                            if penalty > 0 then
                                ease_dollars(-penalty)
                                attention_text({ text = 'Boss Counter: Divine Zap (-$' .. penalty .. ')', scale = 0.55, hold = 1.2, backdrop_colour = G.C.GOLD, align = 'cm', offset = {x = 0, y = -1} })
                                play_sound('cancel', 1.1, 0.6)
                            end
                        elseif roll < 0.66 then
                            -- Minor distraction: temporarily shake cards
                            attention_text({ text = 'Boss Counter: Intimidation Roar!', scale = 0.55, hold = 1.2, backdrop_colour = G.C.RED, align = 'cm', offset = {x = 0, y = -1} })
                            if G.hand and G.hand.cards then
                                for _, c in ipairs(G.hand.cards) do c:juice_up(0.2, 0.2) end
                            end
                            play_sound('whoosh1', 0.9, 0.5)
                        else
                            -- Cosmic ward
                            attention_text({ text = 'Boss Counter: Aegis Pulse!', scale = 0.55, hold = 1.2, backdrop_colour = G.C.PURPLE, align = 'cm', offset = {x = 0, y = -1} })
                            if self.wiggle then self:wiggle() end
                        end
                    end
                    return true
                end
            }))
        end

        return ret
    end
end

-- Dimensional Glitch Tears
function botg_corrupt_card_glitch(card)
    if not card or not card.ability then return end
    if botg_trigger_mod_achievement then
        botg_trigger_mod_achievement('glitch_in_the_aegis')
    end
    card.ability.glitched = true
    card.ability.glitch_mult = pseudorandom('botg_glitch_mult_' .. (card.ID or 0)) * 7.5 + 0.5 -- X0.5 to X8.0
    card.ability.glitch_mult = math.floor(card.ability.glitch_mult * 10) / 10

    card_eval_status_text(card, 'extra', nil, nil, nil, {
        message = 'Glitched! X' .. card.ability.glitch_mult .. ' Mult',
        colour = G.C.PURPLE
    })
    card:juice_up(0.6, 0.6)
    play_sound('holo1', 1.2, 0.8)
end

-- Calculate Glitch Multiplier
if Card and Card.calculate_joker then
    local orig_calc_joker = Card.calculate_joker
    function Card:calculate_joker(context)
        local ret = orig_calc_joker(self, context)
        if self.ability and self.ability.glitched and context.joker_main then
            if ret then
                ret.x_mult = (ret.x_mult or 1) * self.ability.glitch_mult
            else
                ret = {
                    x_mult = self.ability.glitch_mult,
                    message = 'X' .. self.ability.glitch_mult .. ' Mult [Glitched]',
                    colour = G.C.PURPLE
                }
            end
        end
        return ret
    end
end



