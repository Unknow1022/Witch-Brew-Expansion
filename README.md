# 🃏 Witch Brew Expansion

<div align="center">

![Balatro Version](https://img.shields.io/badge/Balatro-v1.0.1o-orange?style=for-the-badge&logo=balatro)
![Steamodded](https://img.shields.io/badge/Steamodded-v1.0.0%2B-blue?style=for-the-badge)
![Witch Brew Expansion Version](https://img.shields.io/badge/Version-v1.4.0-9932CC?style=for-the-badge)
![CardSleeves](https://img.shields.io/badge/CardSleeves-Compatible-ff69b4?style=for-the-badge)
![JokerDisplay](https://img.shields.io/badge/JokerDisplay-Compatible-2ea44f?style=for-the-badge)
![Malverk](https://img.shields.io/badge/Malverk-Compatible-800080?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-English%20%7C%20Espa%C3%B1ol-lightgrey?style=for-the-badge)

**A massive, feature-packed Balatro expansion built on the Steamodded (SMODS) framework.**  
Introduces an exclusive Secret rarity, 57 uniquely synergized Jokers (including Musical & Amalgam Jokers), a dedicated **Potions & Brews** consumable system with persistent Pouch storage & Kyra's Simulation Lab, Job Cards and Employment Booster Packs, dynamic Boss Blinds with CRT ambient lighting, custom Decks and Card Sleeves with Deck-Fusion mechanics, innovative Seals with spectral breaks, 6 Vouchers, 12 Spectrals, Tags, 10 high-difficulty synergy Challenges, and in-game configuration settings.

> 💬 **Mod Philosophy**:  
> *"This mod is designed not to be unfair, but not to hand out free wins either; it is focused on long runs and fun Jokers to play. Reading is recommended, and if you don't like to read, well too bad XD!"*  

[Installation](#🛠️-installation-and-requirements) • [Overview](#📊-general-content-overview) • [Potions & Brews](#🧪-potions--brews-system-8-potions--backpack) • [CardSleeves & Fusions](#🛡️-cardsleeves-5--deck-fusions) • [Challenges](#🏆-synergy-challenges---10) • [Secret Jokers](#🌟-secret-rarity-17-secret-jokers) • [Standard Jokers](#🎭-standard-jokers-40-jokers) • [Job Cards](#💼-job-cards---10--booster-packs-4) • [Spectrals & Seals](#🌌-spectral-consumables-12-seals--enhancements) • [Vouchers & Tags](#🎫-vouchers--tags) • [Boss Blinds](#👁️-boss-blinds---12) • [Decks](#🎴-custom-decks-5) • [FAQ](#❓-frequently-asked-questions-faq)

</div>

---

## 📊 General Content Overview

| Category | Amount | Description |
| :--- | :---: | :--- |
| 🌟 **Secret Jokers** | **17** | Exclusive rarity summoned via *La Muchachada*, Discord Tag, or Potion Amalgams. Animated black badge. |
| 🎭 **Common Jokers** | **8** | Starter Jokers with assimilation, TTS, tempo mechanics, Discarder Joker, and Beat It (*Song*). |
| 💎 **Uncommon Jokers** | **17** | Versatile Jokers with dynamic economy, transmutations, scaling, Extended Hand, Bonfire, and Billie Jean (*Song*). |
| 👑 **Rare Jokers** | **15** | High-impact effect Jokers, debuff protection, extreme combos, Radiation, and 24K Magic (*Song*). |
| 🧪 **Potions & Brews** | **8** | New alchemical consumable category + persistent **Potion Pouch** UI & Kyra's interactive **Simulation Lab**. |
| 💼 **Job Cards** | **10** | Consumable category assigning professions and permanent enhancements to your cards. |
| 📦 **Job Booster Packs** | **4** | *Job Applications* (Regular, Jumbo, Mega) to acquire Job Cards in the shop. |
| 🌌 **Spectral Cards** | **12** | Chaotic deck manipulation, seals, Necromancy, Exorcism, Eradication, Transmutation, and Secret summoning. |
| 🎴 **Enhancements & Seals** | **7** | 4 Exclusive card enhancements and 3 unreleased Seals with animations and spectral shatter. |
| 👁️ **Dynamic Boss Blinds** | **12** | 9 Thematic Boss Blinds + 3 Showdown Blinds (Ante 8+) with reactive color palettes and shaders. |
| 🎴 **Custom Decks** | **5** | Caveman Deck, Strategist Deck, Overseer Deck, Friendly Deck, and Alchemist Deck. |
| 🛡️ **CardSleeves** | **5** | Sleeves with standalone effects and **Unique Fusions** when equipping Deck + corresponding Sleeve. |
| 🏆 **Synergy Challenges** | **10** | High-difficulty challenges based on complex Joker synergies and mod mechanics. |
| ⚙️ **In-Game Settings** | **5** | *New Runs*, *New Challenges*, *New Spectrals & Jobs*, *New Boss Blinds*, and *Fast Animations*. |
| 🎫 **Shop Vouchers** | **6** | *Taster*, *Critic*, *Embrujo*, *Caldero*, *Recurring Distillation*, and *Infinite Distillation*. |
| 🏷️ **Skip Tags** | **3** | Discord Tag, Witchcraft Tag, and Sale Tag. |
| 📈 **Total Jokers** | **57** | All with custom sprites, localization support, and **JokerDisplay** compatibility. |

---

## 🎵 What's New: The Secret Soundtrack & Polish Update (v1.4.0)

* 🎵 **Dynamic Secret Soundtrack & Pack Music (`secret_joker_music.ogg`)**:
  * Implements a dynamic audio system (`music_witch_brew_special`) that plays custom music during normal matches whenever a **Secret Joker** or **Amalgam Joker** is active in your lineup.
  * Dynamically activates when opening expansion packs (**Job Applications**, **Potion Packs**, etc.) without interrupting Boss Blind themes or shop music.
* ✨ **Secret & Amalgam Screen Sparkles (`emit_secret_screen_sparkles`)**:
  * Celebratory iridescent particles shower the screen whenever a Secret or Amalgam Joker triggers its ability in combat (featuring distinct purple/gold palettes).
* 🔊 **Composite Layered Consumable SFX**:
  * Multi-layered sound effects with pitch modulation upon using consumables:
    * **Amalgam Potion**: Resonant deep thud + magical prism chord (`timpani`, `foil1`, `polychrome1`, `tarot2`).
    * **Standard Potions**: Effervescent cork pop (`cancel`, `tarot2`).
    * **Job Cards**: Wax seal + paper crunch + coin ding (`crumple1`, `tarot1`, `coin6`).
    * **Mod Spectrals**: Deep ethereal gong + spectral bell (`timpani`, `tarot2`, `foil1`).
* 🚫 **Anti-Duplicate Joker Protection**:
  * Safe pool filtering ensures the shop and booster packs never offer duplicates of Jokers already owned in your lineup, strictly adhering to vanilla rules unless **Showman** is owned.
* 🎨 **Atmospheric Visual Polish**:
  * **Main Menu Aesthetic**: Swapped to deep black (`#0d0d0d`), dark green (`#0a3817`), and white tertiary accents running through the CRT shader.
  * **Boss Blind Lighting Persistence**: Smooth palette transitions during combat that reliably persist through hands and reset cleanly upon leaving.
* ⚖️ **Amalgam & Joker Balance Updates**:
  * **Certified Programming** *(Amalgam: Hologram + Certificate)*: Now adds **2 cards with a random Seal and Enhancement** to hand at the start of each round, and gains **+X0.25 Mult** per card added to the deck.
  * **Galactic Traveler** *(Amalgam: Constellation + Astronomer)*: Now **doubles the sell value** of Planet cards ($1 -> $2), keeps all Planet cards and Celestial Packs in the shop free ($0), and gains **+X0.25 Mult** per Planet used.
  * **Alchemist Deck & Sleeve Fusion**: Streamlined Kyra summoning at run start, preventing redundant duplicate triggers while maintaining Recurring Distillation.
  * **Runway Joker**: Dynamically tracks newly applied enhancements and editions in real time.
  * **Lucky One Joker**: Refined guaranteed probability trigger logic and stack counters.

---

## 🧪 What's New: The Alchemy & Music Update (v1.3.5)

* 🧪 **New Consumable Set: Potions & Brews (8 Potions)**:
  * **Stretch Potion**: Temporarily expands your hand play limit up to **7 cards**!
  * **Lightning Potion**: Imbues played cards with random enhancements (1 in 5 chance to disintegrate on scoring).
  * **Blizzard Potion**: Returns all discarded and played cards back to deck and redraws a complete fresh hand.
  * **Fury Potion**: Selectively incinerates and destroys up to 3 cards from your hand.
  * **Amalgam Potion**: Alchemical synthesis merging 2 target Jokers into a fused hybrid (inheriting best editions and creating special fusion recipes like **Brainprint**).
  * **Mercury Potion**: Liquid economy earning **+$1** per remaining hand upon defeating the Blind.
  * **Mirror Potion**: Reflects power, retriggering your rightmost Joker.
  * **Clock Potion**: Temporal rewind retrieving all cards from your last played hand back to your active hand and granting **+1 Hand** next round.
* 🎒 **Potion Backpack ("Mochila de Pociones") & Kyra's Lab**:
  * **Dedicated Pouch Button (`[ 🧪 POUCH ]`)**: Stashes and retrieves potions without taking up standard consumable slots.
  * **Interactive Simulation Lab**: Test and preview potion outcomes against simulated hands in a safe virtual environment before playing them.
* 🎵 **Musical Jokers (`Song` Rarity)**:
  * Distinct gold `Song` badge with unique game-changing audio/visual themes:
    * **Beat It** (*Common*): Halves Boss Blind score requirement (-1 discard during Boss).
    * **Billie Jean** (*Uncommon*): Scored King + Queen spawns a Polychrome Wild Jack in hand (*"The kid is not my son"*).
    * **24K Magic** (*Rare*): Each scored Gold Card grants **X2 Mult**.
* ⚗️ **6 New Secret & Amalgam Jokers (Now 17 Total)**:
  * **Kyra**: The potion alchemist master. Potions take 0 consumable space; summon potions for $2 and unlocks the Simulation Lab.
  * **Brainprint**: Fusion of Blueprint + Brainstorm, copying both left and right Jokers simultaneously.
  * **Vampiric Midas**: Fusion of Midas Mask + Vampire, turning face cards to gold and draining enhancements for permanent XMult.
  * **Certified Programming**: Hologram + Certificate fusion adding sealed cards and scaling XMult.
  * **Galactic Traveler**: Constellation + Astronomer fusion making all Planet cards and Celestial Packs free while scaling XMult.
  * **Colorful Street**: Four Fingers + Shortcut fusion, enabling 4-card Flushes/Straights and rank-skipping Straights.
* 🎫 **4 New Alchemical Vouchers**:
  * **Embrujo**: Potions appear 2X more frequently in shop.
  * **Caldero**: Potions appear 4X more frequently in shop (Requires Embrujo).
  * **Recurring Distillation**: 15% chance for used consumables to be recreated.
  * **Infinite Distillation**: 45% chance for used consumables to be recreated (Requires Recurring Distillation).
* 🌌 **4 New Spectral Cards**:
  * **Nigromancia**: Resurrects a Perishable copy of the last sold or destroyed Joker.
  * **Exorcism**: Cleanses Eternal, Perishable, Rental, and Debuff conditions from a Joker.
  * **Erradicación**: Destroys up to 4 selected cards (-$5).
  * **Transmutación**: Morphs 3 selected cards into the rank and suit of the leftmost card.
* 📦 **Mega Job Application Pack**:
  * New 4th employment booster pack offering 2 choices out of 5 Job Cards.

---

## 🎨 What's New in the "Re-Draw Update" (v3.4)

* 🃏 **Friendly Deck & Sleeve Rarity Adjustments**:
  * The **Negative and Eternal** Jokers materialized by the **Friendly Deck** and **Friendly Sleeve** (both standalone and Fusion) can now be of **any rarity** (Common, Uncommon, Rare, and in Fusion up to Legendary).
  * **Anti-Softlock Joker Protection**: An intelligent filter has been implemented so the Friendly Deck and Sleeve **cannot generate Eternal jokers that must be sold or destroyed to function** (such as *Gros Michel*, *Cavendish*, *Ice Cream*, *Popcorn*, *Egg*, *Invisible Joker*, *Luchador*, *Blueberry Joker*, etc.), ensuring the granted Jokers are always useful in combat.

---

## 🛡️ What's New: CardSleeves Compatibility, Fusions, Challenges & Config (v2.0)

* 🎴 **Full Compatibility with CardSleeves (`larswijn/CardSleeves`)**:
  * **5 Custom Sleeves**: Adds Sleeve versions of each mod deck (*Caveman Sleeve*, *Strategist Sleeve*, *Overseer Sleeve*, *Friendly Sleeve*, and *Alchemist Sleeve*).
  * **Deck Fusion Mechanic**: Equipping a Deck and its corresponding Sleeve activates unique fusion effects:
    * **Friendly Fusion** (*Friendly Deck + Friendly Sleeve*): Spawns **3 Negative Eternal Jokers** of any rarity (with the possibility of up to **1 Legendary Joker**, excluding consumable/sell jokers), with a `-2` Joker slot and `-1` discard penalty.
    * **Prehistoric Fusion** (*Caveman Deck + Caveman Sleeve*): Applies a **Silver Seal** to all starting stone cards, stone cards grant **+3 Mult** and **+20 Chips** when scored, and negates the -1 hand penalty.
    * **Grandmaster Fusion** (*Strategist Deck + Strategist Sleeve*): Deck condensed to **20 cards** (10 through Ace), grants **Magic Trick** and **Tarot Merchant** vouchers, **+1 shop slot**, and **+$1** per played hand.
    * **Omniscient Fusion** (*Overseer Deck + Overseer Sleeve*): Creates **2 Spectral cards** per round, **triples tags (x3)**, **removes Joker markup**, and starts with `+$7` and `+1` hand.
    * **Alchemical Fusion** (*Alchemist Deck + Alchemist Sleeve*): At the start of each round, summons **Kyra (Eternal)** if not owned and ensures the **Recurring Distillation** voucher is active (potions take 0 consumable slots).

* 🏆 **10 Complex Synergy Challenges (`New Challenges`)**:
  * Challenges based on high-level synergies and strict rules.

* ⚙️ **In-Game Settings**:
  * **New Runs**: Seed variation with an exclusive salt to diverge from vanilla Balatro generation.
  * **New Challenges**: Dynamically toggles the presence of the 10 Witch_Brew challenges.
  * **New Spectrals & Job Cards**: Enables or disables the appearance of job and spectral cards in runs without altering save files.

---

## 🖥️ What's New in the "Display Update" (v2.0)

* 🎨 **Total Renovation of the JokerDisplay Suite (44 Jokers)**:
  * **Clean and Modular Architecture**: All displays reside in a separate `.lua` file (`src/compat/jokerdisplay.lua`) without altering wildcard logic.
  * **Official Balatro Badges (`border_nodes`)**: Multiplications and exponents (`XMult`, `XChips`, `^Mult`, `^Chips`) are now rendered with official rounded Balatro boxes in red, blue, and dark violet, with full support for Talisman scaling and notations.
  * **Dynamic Real-Time Evaluation (`JokerDisplay.evaluate_hand`)**: Replaced static reading of selected cards with safe evaluation distinguishing scored cards, face-down cards, stone cards, and *Splash* effects.
  * **Chain Retrigger Support (`retrigger_function`)**: *Outstanding Joker*, *Miner* (Magma Core 300m+), and *Charles* (in synergy with Mochi) communicate their repetitions to the JokerDisplay engine.
  * **Copied Dynamic Displays (`get_blueprint_joker` & `JokerDisplay.copy_display`)**: *Chameleon Joker* live-adopts the GUI of the joker to its left when the target rank is met.
  * **Reactive Styles and Dynamic Colors (`style_function`)**: Green/gold highlighting for activated conditions, dimming on inactivity, and thematic colors per suit (`G.C.SUITS`).
  * **Collapsible Rows (`extra`)**: Left-clicking the display unfurls payout tables (Slot Machine), market trends (Shareholder), heat goals (Blacksmith), and sell rewards.

---

## ⚡ What's New in the "Void Update" (v1.9)

* 🕳️ **Dynamic Boss Blinds with Reactive Palettes**: Each of the 12 Boss Blinds fluidly changes the table mat color, background, and CRT filter of Balatro in real-time to its unique thematic hues.
* 🚫 **Play Nullification and Invalidity System ("Like The Psychic")**:
  * Bosses that nullify scoring (**The Mountain, The Door, The Triangle, The Guitar**) integrate the native `debuff_hand` system.
  * Shows the floating *"Hand will not score"* warning box with a boss shake when selecting invalid cards in hand.
  * **Total Joker Blockade**: When playing an invalid hand, scoring is nullified and **no Jokers trigger**.
  * **The Phone**: Scoring cards after the first are shown live crossed out with a red debuff stripe in hand and do not trigger Jokers.
* 💥 **Spectral Shatter System (`spectral_shatter`)**:
  * Cards with a **Dark Green Seal** now score their `X2.5 Mult` cleanly and guaranteed.
  * If the shatter activates (1 in 5), destruction is processed after the hand scoring ends, preventing interruptions and definitively eliminating the invisible/ghost cards bug.
  * New ethereal multi-layer sound effect alongside dark green and spectral turquoise particles.
  * Includes automatic healing support (`purge_witch_brew_ghost_cards`) that immediately fixes previous save files.
* 🃏 **New Jokers & Reworks**:
  * **DJ Joker**: Converts a single played card into a random enhanced card (Lucky, Steel, Gold, or Glass).
  * **Injured Joker (*"My Leg!"*)**: +125 Chips and X1.5 Mult on Straights, with a chance to transform into other chaotic or legendary Jokers.
  * **TTS**: Grants Chips and Mult for each letter in the English name of the scored rank, and money donations upon accumulating 50 letters.
  * **Reaper Joker**, **Infostealer Joker (*Eternal*)**, **Supersaturated Joker**, **Paint Puddle**, **Motorized Joker**, **Hired Joker**, and **Seal of Approval**.
* 🌀 **New Seals & Spectrals**:
  * **Dark Green Seal**: `X2.5 Mult` when scored, 1 in 5 to shatter with a spectral break animation.
  * **White Seal**: Levels up a random hand when scored (+1 level).
  * **Silver Seal**: 1 in 4 to convert to Steel; on Steel Cards it grants `X2 Mult` when played and `X2.5 Mult` in hand.
  * New spectral cards **Refuerzo (Reinforcement)** (applies Silver Seal) and **Supernova** (applies White Seal).
* 🏷️ **New Tags & Decks**:
  * **Witchcraft Tag**: Grants a free Mega Spectral Pack.
  * **Sale Tag**: 50% discount on items and rerolls in the next shop.
  * **Friendly Deck**: Starts with 2 random Negative Eternal Jokers of any rarity (excluding consumable/sell jokers), in exchange for -1 Joker slot and -1 discard.
* 🌐 **Full JokerDisplay Compatibility**: Real-time visualization of stats, letter counters, heat, stock prices, and multipliers on the interface.

---

## 🌟 Secret Rarity (17 Secret Jokers)

> [!IMPORTANT]
> Secret Jokers **DO NOT** appear in the ordinary shop or buffoon packs. They can be summoned via the exclusive **La Muchachada** spectral card (or with the *Discord Tag*), or synthesized through the **Amalgam Potion**. They have an animated jet-black `Secret` badge and dynamic two-layer animations.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        🌟 SECRET JOKERS (17)                           │
└────────────────────────────────────────────────────────────────────────┘
```

1. **Esteban**: Scored **Spades** and **Clubs** grant **X2.5 Mult**.  
   *(Quote: "\*Ignores the kid\*")*
2. **Thiago**: Grants **+X1 Mult** for every **20 Chips** in the played hand's final compute.  
   *(Quote: "Son, Brochacho")*
3. **Black Hole**: Raises final Chips to the power of **^1.5** and final Mult to the power of **^1.5**.  
   *(Quote: "The ultimate singularity")*
4. **Squele**: Scored **Hearts** grant **+10 Mult** and **X1.5 Mult**. 1 in 10 chance to *Project* and create a **Negative Bloodstone**.  
   *(Quote: "I project myself")*
5. **Bluxdir**: When discarding any hand, **levels up** the discarded poker hand (+1 level).  
   *(Quote: "\*Starts farming aura\*")*
6. **Charles**: Scored **Spades** and **Hearts** grant **X2 Mult**. Additionally, you gain **+$5 per scored card**.  
   *(Quote: "Homie" — Special synergy with Mochi)*
7. **Mochi**: Scored cards permanently become **Wild Cards**. Grants **+X0.25 Mult** for each Wild Card present in your full deck.  
   *(Quote: "A drawing for you! :3" — Special synergy with Charles)*
   > [!TIP]
   > **Charles & Mochi Legendary Synergy**: If you have Charles and Mochi in your lineup simultaneously, all scored cards **retrigger 1 additional time**, and at the end of the round they celebrate with the message *"Best Friends!"*.
8. **Helin**: On the **first hand** of each round, raises final Mult to the power of **^2 Mult**.  
   *(Quote: "What is the chat sending?")*
9. **RayTracing**: At the end of each round, creates **2 random Negative Spectral cards** (except La Muchachada).  
   *(Quote: "Depradosini Negrini")*
10. **Paco**: Grants **X2 Mult** for each **remaining discard** you have in the current round.  
    *(Quote: "No need to discard, every card is useful")*
11. **Yairo**: Scored rank **6** and **7** cards grant **X3 Mult** and **X1.5 Chips**.  
    *(Quote: "67!!!!")*
12. **Kyra**: The Master Potion Alchemist. **Potions do not take consumable slots**. Click the dedicated `$2` button to brew a random Potion on demand. Unlocks the persistent **Potion Pouch** and **Simulation Lab**.  
    *(Quote: "I only Help you because you paid me...")*
13. **Brainprint** *(Amalgam: Blueprint + Brainstorm)*: The ultimate mimic! Copies the abilities of **both the Joker to the left AND the Joker to the right** simultaneously, fusing their Mult, Chips, XMult, and dollar generation.  
    *(Quote: "UNBELIEVABLE ALCHEMY! Blueprint and Brainstorm merge into the ultimate mimic: Brainprint!")*
14. **Vampiric Midas** *(Amalgam: Midas Mask + Vampire)*: Converts scored face cards to **Gold Cards**. At the start of each round, consumes enhancements from cards in hand, gaining **+X0.25 Mult** per enhancement absorbed.
15. **Certified Programming** *(Amalgam: Hologram + Certificate)*: At the start of each round, adds a random card with a **Seal** to your hand. Permanently gains **+X0.5 Mult** whenever any card is added to your deck.
16. **Galactic Traveler** *(Amalgam: Constellation + Astronomer)*: Permanently gains **+X0.25 Mult** per **Planet card** used. All Planet cards and Celestial Packs in the shop are **completely free ($0)**.
17. **Colorful Street** *(Amalgam: Four Fingers + Shortcut)*: All **Flushes** and **Straights** can be made with only **4 cards**. Straights may skip **1 rank** (e.g. 2, 4, 6, 8).

---

## 🎭 Standard Jokers (40 Jokers)

### ⚪ Common (8)

* **Masterful Joker**: When scoring a Four of a Kind, Five of a Kind, or Flush Five, permanently assimilates that rank. Assimilated rank cards **count as all suits simultaneously**. Grants **+10 Mult** for each assimilated rank.
* **Outstanding Joker**: Retriggers the highest-value card in the played hand **1 time**. *(Unlock: Play a Five of a Kind)*.
* **Blueberry**: Grants **+1 Hand** when selecting a Blind. Self-destructs after 3 rounds. *(Art by kars_on_mars)*.
* **DJ Joker**: If the played hand contains exactly **1 single card**, it converts it into a random enhanced card (**Lucky, Steel, Gold, or Glass**) *(1 time per round)*.
* **Designer Joker**: Wild Cards grant **+$1** when scored.
* **TTS**: Grants **+4 Chips** and **+1 Mult** for each letter in the English name of each scored card's rank (e.g. "Ace" = 3 letters, "Queen" = 5 letters). Every **50 accumulated letters** grants a **+$10** donation.
* **Discarder Joker**: Permanently gains **+15 Chips** and **+2 Mult** for each remaining discard when the Blind is defeated. Resets after defeating a Boss Blind.
* **Beat It** *(Song Rarity)*: Reduces required **Boss Blind** score by **50%**, with **-1 Discard** during the Boss Blind. *(Quote: "No one wants to be defeated")*

---

### 🔵 Uncommon (17)

* **Shareholder Joker**: The stock price fluctuates every Blind ($2 to $15). Grants Mult equivalent to double the price and pays dividends at the end of the round. Beating the blind in 1 hand triggers a **Bull Market** ($12-$18); using your last hand causes a **Bear Market** ($2-$5). *(Unlock: Have at least $100)*.
* **Builder Joker**: If scored cards are in **strictly ascending order**, grants **+X0.5 Mult per scored card** (up to X3.5). Scoring 4 or more cards in order permanently adds **+20 Chips** to the highest one. *(Unlock: Play a Straight Flush)*.
* **Banquet**: Cards held in hand when scoring permanently gain **+2 Base Chips**. If you have 7 or more cards in hand when scoring, grants **+X2.5 Mult**. When sold, grants **+$15** and spawns a random **Negative** food Joker.
* **Appraiser**: Gains **+$1** at the end of the round for each card with an Edition (*Foil, Holo, Poly*) in your full deck.
* **Runway**: The central card of the played hand is under the *Runway Spotlight*: it gains **+X0.5 Mult** for each unique trait (*Enhancement, Edition, Seal*) present on the other cards in the hand. Upon defeating the Blind, it permanently inherits one of those traits.
* **Slot Machine**: Spins 3 reels every hand: 2 matching grant **+$3** and **+15 Mult**; 3 matching grant **+$12** and **+X2.5 Mult**; Triple 7 grants **+$35**, **+X4 Mult**, and 1 Spectral card. Lucky Cards force the 1st reel to land on a 7.
* **Duel of Value**: **X3 Mult** if the played hand is a scored Two Pair with exactly 2 even-value cards and 2 odd-value cards.
* **Reading Deficiency**: **X5 Mult** if the played hand does not trigger any other Joker in your lineup.
* **Chameleon Joker**: Copies the ability of the Joker to its left if the played hand contains at least one card of the required rank (the rank changes each round).
* **Injured Joker (*"My Leg!"*)**: Grants **+125 Chips** and **X1.5 Mult** on Straights. At the end of each round has a **1 in 5** chance to evolve/transform into *Motorized Joker*, *High Risk Joker*, *Invisible Joker*, *Mr. Bones*, *Vampire*, or *Joker Stencil*.
* **Motorized Joker**: Starts with **+20 Mult**. Every time a card retriggers, gains an additional **+2 Mult** for that hand.
* **Hired Joker**: **1 in 3** chance on every played hand to generate a random Job Card.
* **Seal of Approval**: When playing a hand of exactly 1 single card, applies a random seal (*Gold, Blue, Red, Purple, Dark Green, Silver, or White*).
* **Paint Puddle**: Selects a random suit per round (never repeats the same suit twice in a row); cards of that suit grant **+25 Mult** (+50 Mult if the card is a Wild Card).
* **Extended Hand**: Gains **+X0.1 Mult** when the played hand contains **4 or fewer cards** and **no discards** have been used this round.
* **Bonfire**: Discarding a **face card** permanently adds **+X0.05 Mult** to this Joker. **1 in 6** chance to destroy the discarded face card.
* **Billie Jean** *(Song Rarity)*: If the played hand contains both a **King** and a **Queen**, creates a **Polychrome Wild Jack** in hand. *(Quote: "The kid is not my son")*

---

### 🔴 Rare (15)

* **Doctor Jo.**: **Medical Immunity**: Perishable Jokers' counters never decrease and Rental Jokers are fully refunded. **CLEAR!**: if the last hand does not beat the Blind, removes Debuffs and grants **+1 Emergency Hand with X3 Mult** (1 time per Blind). When another Joker is destroyed, it creates a clean **Polychrome** copy of it.
* **Symmetrical Joker**: **X4 Mult** if the played hand is a Four of a Kind or Five of a Kind where all scored cards share the same suit.
* **Balance**: Generates **2 Spectral cards** if the played hand is a Four of a Kind with exactly 4 cards of the same suit.
* **Merchant**: In the shop: +1 card slot, +1 voucher, +1 booster pack, **25% discount on all items**, and higher Rare Joker spawn rate. You lose $5 upon leaving the shop.
* **Lover**: Links 2 cards from your deck as **Soulmates**. Having one in hand immediately draws its partner from the deck. If both score together in the same hand, they grant **X3 Mult**, **+$6**, and **+10 permanent Chips** to both. Hearts give +10 Mult.
* **Blacksmith**: Played cards add **+5 Heat** to the forge. Upon reaching **300 Heat**, strike the anvil: **1 in 2** chance to apply a **Silver Seal** or convert the highest scored card into a **Steel Card**, cooling to 0 Heat.
* **Lucky One**: Increases **all game probabilities by +1**. When scoring 5 Clubs, stores **1 Guaranteed Roll (100% success)**, stackable up to a maximum of **5 activations**. Permanently gains **+X0.1 Mult** every time a probability succeeds (starts at **X1.5 Mult**).
* **Miner**: Diamonds descend **+5m** into the mine: 0-50m (Coal: **+25 Chips**), 50-120m (Gold: **+$2**), 120-300m (Diamond: **+X1.35 Mult**), 300m+ (Magma Core: **+X1.5 Mult**, **retrigger**, and extracts a Spectral card at the end of the round).
* **Joke Joker?**: Appears to do nothing... but secretly, if you possess the Blank Voucher, it immediately transforms it into Antimatter (+1 Joker slot).
* **Perfectionism**: Defeating a Big Blind or Boss Blind applies **Polychrome** to a random Joker (1 in 5 to grant **Negative** instead).
* **Reaper Joker**: When selling any other Joker (except *Invisible Joker*), generates an *Invisible Joker* (**1 time per round**).
* **Infostealer Joker**: Always **Eternal**. When leaving the shop it discounts **$10** and gains **+X0.5 Mult**; if you don't have enough money, it loses **-X0.5 Mult** (minimum X1).
* **Supersaturated Joker**: When scoring, adds a random missing enhancement (*Seal, Enhancement, or Edition*). If the card already has a Seal, Enhancement, and Edition simultaneously, grants **+$10**.
* **Radiation**: Grants **X3 Mult**. At end of round, **1 in 5** chance per played hand to permanently **debuff** a random Joker in your lineup.
* **24K Magic** *(Song Rarity)*: Each scored **Gold Card** grants **X2 Mult**. *(Quote: "24 karat magic in the air")*

---

## 💼 Job Cards (10) & Booster Packs (4)

A new type of thematic consumable that assigns exclusive professions and specialized transformations to your cards:

| Job Card | Icon | Main Effect |
| :--- | :---: | :--- |
| **The Miner** | ⛏️ | Transforms 1 selected card into a **Shiny Card**. |
| **The Gardener** | 🌿 | Assigns the Gardener profession: when discarded, permanently grants **+2 Base Chips** to all cards of its suit in the deck. |
| **The Banker** | 🏦 | Transforms 1 selected card into an **Investment Card**. |
| **The Surgeon** | 🩺 | Destroys the 1st selected card and transfers all its bonus chips, enhancement, seal, and edition to the 2nd selected card. |
| **The Alchemist** | ⚗️ | Transforms 1 selected card into a **Lead Card**. |
| **The Butcher** | 🥩 | Destroys 1 card (Rank 3+) and creates 2 cards dividing its rank, with random Steel, Glass, Wild, or Lucky enhancements. |
| **The Detective** | 🔍 | Assigns the Detective profession: on the first hand of each round, reveals the next 3 cards to be drawn and gives them a Gold or Blue Seal. |
| **The Chef** | 🍳 | Assigns the Chef profession to a face card (J, Q, K): when scored, converts the other scored cards into Mult Cards. |
| **The Archaeologist** | 🏺 | Assigns the Archaeologist profession: when scored on your last hand of the round, rescues 1 discarded card and applies Foil, Holo, or Poly. |
| **The Jeweler** | 💎 | Transforms 1 selected card into a **Jeweled Card**. |

### 📦 Employment Booster Packs (Job Applications)
* **Job Application**: Choose 1 of up to 3 available Job Cards.
* **Jumbo Job Application**: Choose 1 of up to 5 available Job Cards.
* **Mega Job Application**: Choose 2 of up to 5 available Job Cards.

---

## 🧪 Potions & Brews System (8 Potions & Backpack)

A brand new alchemical consumable system introduced in **v1.3.5**. Potions appear naturally in the shop and booster packs (boosted by the *Embrujo* and *Caldero* vouchers):

| Potion | Cost | Effect |
| :--- | :---: | :--- |
| 🧪 **Stretch Potion** | $4 | Expands your play capacity: allows selecting and playing up to **7 cards** in your next hand! |
| ⚡ **Lightning Potion** | $4 | Cards played in your next hand gain a **random enhancement**, with a **1 in 5** chance to disintegrate when scoring ends. |
| ❄️ **Blizzard Potion** | $4 | Shuffles all played and discarded cards back into the deck, then draws a **completely new hand**. |
| 🔥 **Fury Potion** | $4 | Selectively incinerates and permanently destroys up to **3 selected cards** from your hand. |
| ⚗️ **Amalgam Potion** | $6 | Alchemical synthesis: merges 2 target Jokers into a unified hybrid entity. Combines best editions (Foil, Holo, Poly, Negative) and enables legendary recipes like **Brainprint** (*Blueprint + Brainstorm*). |
| 💧 **Mercury Potion** | $4 | Grants **+$1** for each remaining hand upon defeating the Blind. |
| 🪞 **Mirror Potion** | $5 | Reflects alchemical energy, **retriggering your rightmost Joker** during scoring. |
| ⏳ **Clock Potion** | $5 | Temporal rewind: returns all cards from your **last played hand** back to your hand, and grants **+1 Hand** next round. |

### 🎒 Potion Backpack ("Mochila de Pociones") & Kyra's Lab
* **Persistent Pouch (`[ 🧪 POUCH ]`)**: Stash and retrieve potions during runs without filling your standard consumable slots.
* **Kyra's Interactive Simulation Lab**: Test your brews on virtual hands in a sandbox testing area. If you recruit the Secret Joker **Kyra**, potions take **0 consumable slots** and you can brew fresh potions for **$2** on demand!

---

## 🌌 Spectral Consumables (12), Seals & Enhancements

### 🌀 Spectral Cards
* **Hierarchy**: Destroys the entire current hand, creates 3 Steel Kings with a Red Seal, **-1 Hand**.
* **Order**: Applies a **Dark Green Seal** to 1 selected card.
* **Rot**: Destroys all current Jokers (including Eternals), creates **2 random Rare Eternal Jokers**, **-1 Discard**.
* **Catastrophic**: **+4 levels** to your most played poker hand, generates **3 Negative Planets** of that same hand, and subtracts **-1 level** from all other hands.
* **Intensity**: Destroys 5 selected cards and creates 1 Polychrome Wild Card with a Red Seal of a random rank and suit.
* **La Muchachada**: Summons a random **Secret Joker** among the 17 existing ones *(exclusive to spectral packs and Discord Tag)*.
* **Refuerzo (Reinforcement)**: Applies a **Silver Seal** to 1 selected card.
* **Supernova**: Applies a **White Seal** to 1 selected card.
* **Nigromancia (Necromancy)**: Creates a copy of the **last Joker sold or destroyed** with **Perishable**; sets current money to **$0**.
* **Exorcism**: Cleanses and removes **Eternal**, **Perishable**, **Rental**, and **Debuff** from a selected (or random) Joker.
* **Erradicación (Eradication)**: Destroys up to **4 selected cards** from hand; costs **-$5**.
* **Transmutación (Transmutation)**: Converts **3 selected cards** into the rank and suit of the **leftmost** selected card.

---

### ✨ Custom Seals

| Seal | Visual | Effect |
| :--- | :---: | :--- |
| **Dark Green Seal** | 🟢 | Grants **X2.5 Mult** when scored. **1 in 5** chance to break when played via the new **Spectral Shatter** effect (ethereal sound effect, thematic particles, and leaves no ghost cards). |
| **White Seal** | ⚪ | When scored, levels up a random poker hand by **+1 level**. |
| **Silver Seal** | 🔘 | **1 in 4** chance to transmute the card into a **Steel Card** when played. While on a Steel Card, grants **X2 Mult** when played and **X2.5 Mult** while held in hand. |

---

### 🃏 Exclusive Card Enhancements
* **Shiny Card**: Grants **X1.5 Mult** when retriggered; grants **+$3** once if held in hand at the end of the round.
* **Investment Card**: Generates a **10% interest** on your current money (up to a maximum of $10) when held in hand at the end of the round.
* **Lead Card**: Grants **+10 Chips**. Permanently transmutes into a **Gold Card** if scored in the hand that defeats the Blind.
* **Jeweled Card**: Grants **X1.25 Mult** and **+$2** when scored.

---

## 👁️ Boss Blinds (12)

All Boss Blinds feature reactive lighting that alters the table mat, CRT, and live game atmosphere:

### Standard Boss Blinds (Ante 3+)
* **The Pole**: Cards with an Edition (*Foil, Holo, Poly*) lose **$10** when scored.
* **The Rod**: If your score triples the blind requirement, the next blind's requirement is multiplied by **X1.5**.
* **The Magician**: All cards that possess any enhancement (Stone, Lucky, Steel, Gold, Glass, Bonus, Mult, Wild, etc.) are debuffed.
* **The Mountain**: Using any consumable nullifies the scoring of the next played hand (shows *The Psychic*-style warning; no Joker triggers).
* **The Door**: Hands with an odd number of cards do not score (*The Psychic*-style live warning; no Joker triggers).
* **The Triangle**: Hands with an even number of cards do not score (*The Psychic*-style live warning; no Joker triggers).
* **The Cube**: Halves final Chips and Mult if the resulting number is even in the final calculation.
* **The Guitar**: Played hands of exactly 5 cards do not score (*The Psychic*-style live warning; no Joker triggers).
* **The Phone**: Only the 1st card scores and triggers Jokers; cards 2+ are shown live crossed out/debuffed in hand and do not trigger Jokers.

### 💀 Showdown Final Blinds (Ante 8+)
* **The Void**: Increases the chip requirement by **X1.25** after each played hand that does not defeat the blind ($8 reward).
* **The Pincer**: **All Jokers are disabled** until a card is destroyed during combat (destroying a glass card or shattering a card with a Dark Green Seal immediately frees your Jokers' power).
* **The Doppelgänger**: At the start of the round summons a shadowy reflection that clones a random Joker and inverts its ability in the final calculation: subtracts its Mult and Chips, and divides by its XMult.

---

## 🎴 Custom Decks (5)

* **Caveman Deck**: You start with only A, 2, 3, 4, 6, and 8 of each suit in your deck; all other starting cards are Stone Cards. Start with **-1 Hand**.
* **Strategist Deck**: You start with a compact deck of 24 cards (Aces, Kings, Queens, Jacks, 10s, and 9s). Start with the *Magic Trick* voucher, $0, **-1 hand**, **-2 discards**, and blind requirements scale X1.2.
* **Overseer Deck**: Creates a random Spectral card at the end of each round (except Rot and Soul). Tags are always doubled. Joker prices are X1.5. You start with $2, -1 hand, and -1 discard.
* **Friendly Deck**: Generates **2 random Jokers of any rarity** with Negative edition and Eternal condition at the start of the run (cannot generate Secret jokers or those requiring selling/destruction). Start with **-1 Joker Slot** and **-1 Discard**.
* **Alchemist Deck**: Starts with the **Recurring Distillation** voucher (15% chance to recreate used consumables), ensuring it is active again at the start of each round.

---

## 🎫 Vouchers & Tags

### 🎫 Shop Vouchers (6)
* **Taster**: Common Jokers appear less frequently in the shop (75% replacement by Uncommon or Rare).
* **Critic (Requires Taster)**: Common Jokers no longer appear in the shop (100% replacement).
* **Embrujo**: **Potions** appear **2X** more frequently in the shop and packs.
* **Caldero (Requires Embrujo)**: **Potions** appear **4X** more frequently in the shop and packs.
* **Recurring Distillation (Destilación Recurrente)**: **15% chance** for any used consumable to be automatically recreated.
* **Infinite Distillation (Destilación Infinita, Requires Recurring Distillation)**: **45% chance** for any used consumable to be automatically recreated.

### 🏷️ Skip Tags (3)
* **Discord Tag**: 1 in 5 chance to generate the exclusive **La Muchachada** spectral card.
* **Witchcraft Tag**: Grants a totally free **Mega Spectral Pack**.
* **Sale Tag**: All items and rerolls in the next shop have a **50% discount**.

---

## 🛠️ Installation and Requirements

### 📦 Required Dependencies
1. **[Balatro](https://store.steampowered.com/app/2379780/Balatro/)** (v1.0.1o or higher).
2. **[Steamodded (SMODS)](https://github.com/Steamodded/smods)** (version **1.0.0** or higher) — *Declared in `manifest.json`*.
3. **[Lovely](https://github.com/ethangreen-dev/lovely-injector)** (version **0.7.1** or higher) — *Required runtime injector for Steamodded*.

### 🧩 Optional Dependencies (Soft Compatibility)
1. **[CardSleeves](https://github.com/larswijn/CardSleeves)**: Enables all 4 custom Witch Brew Sleeves and unique **Deck Fusion** mechanics.
2. **[JokerDisplay](https://github.com/jie65535/JokerDisplay)** (>= 1.8.0): Full real-time HUD integration, custom badges, retrigger counters, and collapsible calculation rows across all 57 Jokers.
3. **[Malverk](https://github.com/Steamodded/smods)**: Defensive compatibility patch ensuring profile data resets cleanly without crash hooks.

---

## ❓ Frequently Asked Questions (FAQ)

<details>
<summary><b>Why can't I see Secret Jokers in the shop or in buffoon packs?</b></summary>
<br>
The 17 Secret Jokers were deliberately designed to be exclusive. Their natural appearance probability in the shop is zero; they can only be summoned by using the <b>La Muchachada</b> spectral card, redeeming a <b>Discord Tag</b>, or synthesized via the <b>Amalgam Potion</b>.
</details>

<details>
<summary><b>How does the Dark Green Seal and its spectral shatter work?</b></summary>
<br>
When scored, the card always grants its <b>X2.5 Mult</b> multiplier. During scoring, the 1 in 5 probability is calculated; if it breaks, physical destruction is postponed until all cards and Jokers have finished scoring. At that instant, the <code>spectral_shatter</code> effect plays, Jokers are notified of the destruction, and the card is cleanly purged without leaving invisible cards or gaps in your hand.
</details>

<details>
<summary><b>Is it compatible with runs in progress and other large mods?</b></summary>
<br>
Yes. Witch Brew Expansion is developed with modern Steamodded standards, using clean prefixes and without destructively overwriting engine tables. Additionally, it features preventive cleanup routines to repair save file states containing ghost cards.
</details>

---

## 👤 Credits & Acknowledgements

* **Development, Programming & Design**: [Unknow102](https://github.com/Unknow1022)
* **Modding Framework**: [Steamodded (SMODS)](https://github.com/Steamodded/smods)
* **Art Contribution**: kars_on_mars (*Blueberry Joker Art*)
* **Special Thanks**: To the Balatro Modding community and everyone who reports suggestions and feedback.

---

<div align="center">
  <sub>Made with passion for the Balatro community. Enjoy the Witch Brew experience! 🃏</sub>
</div>
