# Word Trip Game — MVP Plan

> Based on: RESEARCH.md
> Target: Cross-platform (iOS + Android + Web)
> Stack: Flutter + Flame + Supabase + AI (Claude/OpenAI API)

---

## Vision

A word puzzle game that fixes every reason players quit competitors —
no forced ads, infinite fresh puzzles, and something genuinely learned from every word.

**Tagline:** *"Every word, a journey. Every journey, something learned."*

---

## MVP Scope

The MVP proves one thing: **players stay because the core loop is better.**
No world map. No leaderboards. No events. Just the best word puzzle experience available.

---

## Part 1 — MVP Features

### 1.1 Core Gameplay Loop

**Letter Wheel + Crossword Grid**
- Circular letter wheel (6–8 letters) at the bottom of the screen
- Swipe across letters to form words
- Valid words snap into a crossword-style grid above
- Satisfying micro-animations: letter snap, particle burst on word completion
- Shuffle button to rearrange wheel (costs 1 coin OR free with timer)
- All required words must be found to complete a level

**Bonus Word Discovery**
- Players can form words not required by the puzzle
- Bonus words go into a "discovery bank" shown at the end of each level
- No penalty for wrong swipes — gentle "not a word" shake only
- Encourages exploration over pure task completion

**Word Definition Card**
- After each valid word is found, a card slides up briefly showing:
  - The word
  - Part of speech
  - Short definition (1 line)
  - Optional: tap to expand etymology
- Differentiator: makes players feel they are learning, not just tapping
- Definitions sourced via Free Dictionary API + AI enrichment for rare words

**Level Structure**
- Each level: 1 crossword grid, 1 letter wheel, 6–12 required words
- 3 difficulty tiers: Beginner (4–5 letter words), Explorer (5–7), Voyager (7–9)
- Average session time target: 3–5 minutes per level
- "Next Level" always one tap away after completion

**Hint System (Soft Paywall Gateway)**
- 3 hint types: Reveal a Letter / Reveal a Word / Shuffle for Free
- Players start with 20 coins
- Hints cost coins (5 / 15 / 3 respectively)
- Coins earned by: completing levels, watching rewarded ads (opt-in), daily login
- No hard block — players can always skip a puzzle if truly stuck

---

### 1.2 AI Puzzle Generation

**Why:** Content exhaustion is the #2 churn cause. Static libraries repeat words. AI solves this permanently.

**How it works:**
- Backend generates puzzles on demand using Claude/OpenAI API
- Input: theme keyword + difficulty tier + target word count
- Output: letter set, required word list, bonus word list, definitions
- Puzzles cached per user to prevent repetition (stored in Supabase)
- Fallback: pre-generated offline puzzle bank of 500 levels ships with the app

**Themes (rotated daily):**
- Day 1: Ocean / Day 2: Ancient Rome / Day 3: Cooking / Day 4: Space...
- Theme shown as subtle background illustration per level
- Players feel novelty even when the mechanic is familiar

**Content safety:**
- Word list filtered against a blocklist before serving
- Minimum word frequency threshold (no obscure jargon in Beginner tier)

---

### 1.3 Daily Challenge

**Why:** Wordle grew 90 → 2M users with zero paid marketing using just this mechanic.

**How it works:**
- One special themed puzzle unlocks at midnight (user's local time)
- Same puzzle for all players that day (shared experience)
- Limited to 3 attempts per day (creates replay tension)
- Players who complete it earn a Daily Gem (premium currency)

**Shareable Result Card**
- After completing (or failing) the daily challenge, a card is generated:
  - Game name + date + theme
  - Score (words found / total words, time taken)
  - Word tiles shown as colored blocks — no actual words revealed (no spoilers)
  - "Play today's challenge" deep link
- One-tap share to Instagram, WhatsApp, X, iMessage
- This is the primary organic acquisition channel

**Streak Counter**
- Consecutive daily challenge completions tracked
- Streak shown on home screen with flame icon
- Losing a streak costs 1 Streak Shield (earnable, not purchaseable only)
- Push notification at 8pm local time: "Today's challenge closes in 4 hours"

---

### 1.4 Account + Cloud Save

**Why:** Losing progress when switching phones is a top-cited reason players quit competitors permanently.

**Implementation:**
- Sign up via Email / Google / Apple (Sign in with Apple required for iOS App Store)
- All progress, coins, streak, and puzzle history synced to Supabase in real time
- Guest mode available — progress saved locally, prompt to create account at Day 3
- Switching devices: full state restored within seconds of login
- Purchased premium status tied to account, not device

---

### 1.5 Monetization (Respectful by Design)

**Free Tier — Full Access:**
- All regular levels playable with no paywalls
- Daily challenge always free
- Opt-in rewarded video ads to earn coins (player initiates, never forced)
- 3 free hints per day (resets at midnight)

**Premium — One-Time Purchase ($3.99):**
- Zero ads, forever (including no ad prompts)
- 5 free hints per day (instead of 3)
- Exclusive "Voyager" theme pack (dark mode variant with constellation background)
- Priority access to new theme drops

**Coins — Optional IAP:**
- 100 coins: $0.99
- 300 coins: $1.99 (best value badge)
- 750 coins: $3.99
- Coins used only for hints + shuffles — never for level access

**Rules enforced in code:**
- No ads during active gameplay — only shown on level complete screen, opt-in
- No countdown timers pressuring purchases
- No "best value" popups triggered by level failure
- No subscription model at launch (revisit at Phase 2)

---

### 1.6 Accessibility

**Why:** Zero competitors support this. Captures an underserved, high-loyalty segment.

- Font size: Small / Medium / Large / Extra Large (default: Medium)
- Font style toggle: Standard / OpenDyslexic
- High contrast mode (dark background, bold letter tiles)
- Letter tile size adjustable (impacts wheel layout)
- Audio: word pronunciation played on tap-and-hold of any completed word
- All interactive elements meet 44×44pt minimum tap target (Apple HIG standard)
- Colorblind-safe palette for tile feedback colors (no red/green only distinction)

---

### 1.7 Onboarding

**Rule:** Do it, don't read it. No tutorial walls.

- Level 1: only 4 letters on the wheel, 2 required words — impossible to fail
- Level 2: 5 letters, hint button highlighted once with a pulse animation
- Level 3: bonus word discovery introduced via gentle highlight
- Level 4: daily challenge button introduced (pulse animation, no forced entry)
- No text instructions. No skip buttons needed. First word found within 10 seconds.

---

## Part 2 — MVP Technical Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App (Client)                │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │  Flame Engine│  │   Supabase   │  │  Ad SDK   │  │
│  │  (game loop) │  │  (auth/sync) │  │ (opt-in)  │  │
│  └──────────────┘  └──────────────┘  └───────────┘  │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│               Backend (Supabase + Edge Functions)   │
│  ┌──────────────────────┐  ┌────────────────────┐   │
│  │  AI Puzzle Generator │  │  Daily Challenge   │   │
│  │  (Claude/OpenAI API) │  │  Scheduler (CRON)  │   │
│  └──────────────────────┘  └────────────────────┘   │
│  ┌──────────────────────┐  ┌────────────────────┐   │
│  │  Puzzle Cache (PG)   │  │  User Progress (PG)│   │
│  └──────────────────────┘  └────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Key decisions:**
- Offline-first: 500 pre-generated puzzles ship with the app (no internet needed for core play)
- AI generation happens server-side (API keys never in client)
- Supabase Realtime for cross-device sync (no polling)
- Flutter + Flame for iOS, Android, Web from one codebase

---

## Part 3 — Build Phases

### Phase 0 — Setup (Week 1)
- [ ] Flutter + Flame project scaffold
- [ ] Supabase project: auth, tables (users, progress, puzzles, daily_challenges)
- [ ] CI/CD pipeline (GitHub Actions → TestFlight + Play Internal)
- [ ] Design system: colors, typography, tile components

### Phase 1 — Core Loop (Weeks 2–4)
- [ ] Letter wheel component (swipe gesture, letter selection logic)
- [ ] Crossword grid component (word placement, reveal animation)
- [ ] Word validation engine (dictionary + AI-generated word list)
- [ ] Bonus word bank UI
- [ ] Definition card component (Free Dictionary API integration)
- [ ] Level complete screen (score, bonus words found, next level CTA)
- [ ] Hint system (3 types, coin deduction logic)
- [ ] Offline puzzle bank (500 levels, JSON, bundled in assets)

### Phase 2 — Retention Layer (Weeks 5–7)
- [ ] Account system (email + Google + Apple auth via Supabase)
- [ ] Cloud save (progress sync on every level complete)
- [ ] Daily challenge (puzzle + 3-attempt limit + streak counter)
- [ ] Shareable result card generator (Flutter's canvas → image export)
- [ ] Push notifications (daily challenge reminder at 8pm)
- [ ] Coin economy (earn, spend, IAP integration)
- [ ] Opt-in rewarded ad integration (Google AdMob)

### Phase 3 — Polish + Monetization (Weeks 8–10)
- [ ] AI puzzle generator (Supabase Edge Function + Claude API)
- [ ] Premium one-time purchase (RevenueCat for cross-platform IAP)
- [ ] Accessibility features (font size, OpenDyslexic, high contrast, audio)
- [ ] Onboarding flow (4 guided levels)
- [ ] Sound design (correct word chime, level complete fanfare, shuffle whoosh)
- [ ] App icon, splash screen, store assets

### Phase 4 — Launch Prep (Weeks 11–12)
- [ ] App Store + Play Store submission (metadata, screenshots, privacy policy)
- [ ] Web deployment (Flutter web → Vercel or Netlify)
- [ ] Beta test with 50–100 users (TestFlight + Play Internal Track)
- [ ] Fix top 5 issues from beta feedback
- [ ] Soft launch: 2–3 markets first (see GTM below)

---

## Part 4 — Go-To-Market Strategy

### 4.1 Positioning

**Primary message:** "The word game that doesn't interrupt you."
**Secondary message:** "Learn something from every word you find."

Target the frustrated audience directly — people actively searching for Wordscapes/Word Trip alternatives.

---

### 4.2 Pre-Launch (Weeks 1–8, while building)

**Content seeding:**
- Build in public on X/Twitter: weekly dev logs with short clips of game animations
- Post to r/indiegaming, r/flutter, r/WordGames as development updates (not promotion)
- Short TikTok/Reels of satisfying letter-swipe animations (no commentary needed — ASMR-style gameplay captures attention organically)

**Waitlist:**
- Simple landing page (Flutter web or Carrd): tagline + email capture + "notify me at launch"
- Target: 500 waitlist signups before launch
- Incentive: waitlist members get 200 bonus coins + premium theme at launch

**App Store Optimization (ASO) research:**
- Identify keywords competitors rank for: "word puzzle", "word connect", "word trip", "word game offline"
- Identify gaps: "word game no ads", "word game learn vocabulary", "word game definitions"
- Draft title + subtitle + keyword fields before submission

---

### 4.3 Launch Strategy — Soft Launch First

**Why soft launch:** Catch critical bugs before ratings are permanent. App Store ratings reset per major version but Play Store ratings are permanent.

**Soft launch markets (Week 11–12):**
- Canada (iOS) — English-speaking, similar to US, smaller scale
- Australia (Android) — Active word game market, lower CPIs than US
- Goal: 1,000 installs, 4.0+ rating, Day-7 retention > 30%

**Hard launch (Week 13–14):**
- US, UK, India (English)
- Coordinate with influencer outreach (see below)
- Submit featured app request to Apple + Google (requires strong Day-7 retention metric)

---

### 4.4 Organic Acquisition Channels

**1. Daily Challenge Sharing (Built-In Viral Loop)**
- Every share of a daily challenge result = a deep link install prompt
- Target: 5% of daily players share their result
- At 1,000 DAU → 50 shares/day → ~10–15 new installs/day at zero cost

**2. App Store Optimization**
- Title: "Word Trip: Daily Word Puzzle"
- Subtitle: "Find words. Learn meanings."
- Keywords targeting: "word game no ads", "word puzzle offline", "learn vocabulary game"
- Screenshot 1: "No forced ads. Ever." — addresses #1 competitor complaint directly
- Screenshot 2: Gameplay showing definition card
- Screenshot 3: Daily challenge + share card

**3. Reddit + Community Seeding**
- r/WordGames — share daily challenge results, engage genuinely
- r/Vocabulary — word-of-the-day tie-ins, crosspost daily challenge themes
- r/indiegaming — dev log updates drive goodwill and installs from adjacent audiences
- Facebook Groups: "Word Game Addicts", "Wordscapes Players" — position as the alternative

**4. SEO / Web (Long-Term)**
- Flutter web version playable at [yourdomain].com/daily
- Target keyword: "word game online free no ads"
- Blog posts: "Best word games with no ads (2026)", "Word games that teach vocabulary"
- Web users who enjoy the daily challenge convert to app installs

---

### 4.5 Paid Acquisition (Post-Validation Only)

**Do not run paid ads until:**
- Day-7 retention > 30%
- Day-30 retention > 15%
- LTV / CPI ratio > 3x

**When metrics are proven:**
- Meta (Facebook/Instagram): target fans of Wordscapes, Word Trip, Wordle
- Google UAC: target "word puzzle game" intent keywords
- Apple Search Ads: exact match on competitor names + "word game no ads"
- TikTok: boosted versions of organic gameplay clips

**Budget allocation (post-validation):**
- 50% Apple Search Ads (highest intent, best conversion for games)
- 30% Meta (broad audience, lookalike from email waitlist)
- 20% Google UAC

---

### 4.6 Press + Influencer Outreach

**Mobile game press:**
- TouchArcade, Pocket Gamer, 148Apps — send review builds 2 weeks before launch
- Pitch angle: "The word game that fixed everything players hate about Wordscapes"

**YouTube / TikTok creators:**
- Target: word game review channels (50K–500K subscribers, not mega-influencers)
- Micro-influencer deal: free premium + $100–200 flat fee per video
- Channels to target: word game lists ("Top 10 word games 2026"), vocabulary learning channels, "no ads games" niche

**Educational angle:**
- Outreach to vocabulary/language teachers on TikTok and Instagram
- "Use this in your classroom" positioning — drives word-of-mouth in an untapped segment

---

### 4.7 Retention + Re-Engagement

**Push notifications (non-spammy):**
- Daily at 8pm: "Today's challenge: [Theme]. Closes at midnight."
- Streak at risk: "Your 7-day streak ends tonight. 2 minutes to keep it."
- Weekly: "New theme pack dropped: [Theme]" (only if player hasn't opened app in 3 days)
- Maximum 1 notification per day. Players can customize or disable.

**Email (for account holders):**
- Weekly: "This week's top bonus word discoveries" (curated, fun, not spammy)
- Monthly: "You've learned X words this month" (personalized stat — shareable)

---

### 4.8 Launch Week Metrics to Watch

| Metric | Target | Red Flag |
|---|---|---|
| Day-1 retention | > 40% | < 25% |
| Day-7 retention | > 30% | < 20% |
| Day-30 retention | > 15% | < 10% |
| Daily challenge completion rate | > 60% | < 40% |
| Share rate (daily challenge) | > 5% of completions | < 2% |
| App Store rating | > 4.3 | < 4.0 |
| Crash-free sessions | > 99% | < 98% |
| Avg. session length | > 8 minutes | < 4 minutes |

---

### 4.9 Revenue Milestones

| Milestone | Target | Key Driver |
|---|---|---|
| Month 1 | $500 MRR | Waitlist conversions to premium + rewarded ads |
| Month 3 | $3,000 MRR | Organic growth + daily challenge shares |
| Month 6 | $10,000 MRR | Paid UA kicks in after LTV proven |
| Month 12 | $50,000 MRR | Localization live, featuring secured, subscription launched |

---

## Part 5 — What We Are NOT Building in MVP

Keeping scope tight is as important as knowing what to build.

| Feature | Why Deferred |
|---|---|
| World map / geographic progression | Requires significant art assets; retention loop works without it |
| Multiplayer / friend challenges | Adds backend complexity; validate solo retention first |
| Subscription model | One-time purchase is simpler and more trusted at launch |
| 5+ language localization | Validate English market before investing in localization |
| Seasonal events / limited-time challenges | Requires live ops capability; post-launch feature |
| Leaderboards | Needs sufficient user base to be meaningful |
| Custom word pack creation (user-generated) | Moderation complexity; Phase 3 consideration |

---

## Summary

```
MVP = Core loop + AI puzzles + Daily challenge + Cloud save + Fair monetization

GTM = Organic first (daily share loop + ASO + community)
      → Soft launch (Canada + Australia) to validate metrics
      → Hard launch (US/UK/India) once retention proven
      → Paid UA only after LTV/CPI > 3x

Edge = Fair ads + Infinite content + Vocabulary learning + Accessibility
       (everything competitors fail at, fixed by design)
```
