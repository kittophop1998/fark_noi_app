# FarkNoi Design System

This is the **portable specification**: everything needed to draw a new FarkNoi
screen — or a screen in a different codebase that should look like FarkNoi —
without opening this repository. Every value below is copied from what actually
ships (`src/app/globals.css`, `src/theme/`, `src/components/ui/`) as of this
writing. If a future change to the app disagrees with a number here, the app is
right and this file is stale — update it in the same commit.

Two companion documents go deeper for people working inside this repository:
`DESIGN_SYSTEM.md` explains *why* each token exists and which component owns
it, and `docs/` covers screen-specific decisions (`docs/home.md`,
`docs/page-header.md`, `docs/maps.md`, …). This file does not replace either —
it is the subset that travels.

---

## 1. Design direction

FarkNoi is a Thai neighbourhood errand marketplace: somebody already going that
way, and somebody nearby asking them to pick something up on the way. It is
**Soft Marketplace + Local Community + Mobility**, and it handles other
people's money between two strangers who have never met — so the visual
language carries two jobs that pull in opposite directions:

- **Approachable** — a neighbour doing you a favour, not a logistics vendor.
  Warm, light, human, conversational.
- **Trustworthy** — credit is held, receipts are photographed, scores cannot be
  edited. Nothing may feel improvised.

The resolution: **a warm, quiet page, and one loud thing on it.** Roughly 70%
of any screen is warm neutral surface, 20% is content and typography, and 10%
is coral — the action, the active tab, the selected filter. Coral is what you
*do*; it is never decoration.

The interface must not resemble: admin dashboards, enterprise SaaS, banking
apps, logistics control panels, dense data tables, or a traditional
delivery-driver app. Deliberately absent from the product: gradients, neon,
glassmorphism, heavy borders, deep shadows, giant typography, and any motion
that is not confirming something the user just did.

## 2. Principles

1. **Mobile first.** Design from 360–430px and adapt upward, never the reverse.
2. **Marketplace, not dashboard.** No KPI tiles, no admin density.
3. **Action first.** One clear thing to do, always findable.
4. **Local and human.** Conversational Thai, real objects, no jargon.
5. **Trust by design.** Never claim a number, badge or status the backend has
   not actually sent.
6. **Content before decoration.** A shadow, a gradient or an icon must earn its
   place; whitespace and a heading are the default, not a fallback.
7. **Consistency over novelty.** Compose the existing components before
   inventing a new look.

## 3. Layout, breakpoints and page width

Reference widths: **360 / 390 / 430px** for phones. Breakpoints (note: `sm`
diverges from Tailwind's own 640px default):

| Name | Width | Note |
| --- | --- | --- |
| `sm` | 480px | a large phone starting to earn more than one column |
| `md` | 768px | tablet |
| `lg` | 1024px | the one structural switch — bottom nav becomes a top nav |
| `xl` | 1280px | wide desktop |

Two extra variants ask about height as well, because a phone held sideways is
~800×380: **`roomy`** (`min-width:480px` and `min-height:600px`) is where a
bottom sheet may become a centred panel; **`squat`** (`max-height:520px` and
`min-width:640px`) is where a vertical stack should turn on its side. **Never
gate a full-screen surface on width alone.**

Three content measures, chosen by what the screen is, never invented per page:

| Measure | Width | For |
| --- | --- | --- |
| `narrow` | 620px | a form or a detail screen |
| `feed` | 760px | a browsed marketplace list (a card still reads as a row at this width) |
| `wide` | 1200px | a layout that genuinely uses the space — a feed beside a map |

A browsed list becomes two columns at `lg` inside the `feed` measure (~370px a
column). A chronological stream stays one column at every width.

**The page gutter is 16 / 24 / 32** — mobile / tablet / desktop, applied once
by the page container. Anything that bleeds full-width (a carousel track, a
sticky action bar) must bleed by exactly these three numbers, or it hangs past
the screen edge and the page pans sideways. Never combine a bleed with an
explicit `width: 100%` — a negative margin only widens a box whose width is
`auto`.

## 4. Colour

Colour runs in three layers, and a screen only ever touches the third: a
**ramp** (a tint decided once), a **role** (why a colour is used), and a
**utility** (what a component writes — `text-muted`, `bg-surface`). Naming a
raw hex value or a ramp step in a component is the palette mistake: it means a
role was needed and got inlined instead of named.

### 4.1 Brand — one coral ramp, three roles, and they are not interchangeable

```
50 #fff5f2  100 #ffe8e1  200 #ffd0c4  300 #ffad98  400 #ff8065
500 #ff6548  600 #f24e32  700 #cc3b24  800 #a93221  900 #8b2e22
```

| Role | Step | Value | Contrast on white | For |
| --- | --- | --- | --- | --- |
| `brand` | 500 | `#FF6548` | 2.91:1 | Coral as a **shape** — a logo plate, a map pin, an icon on a tint. **Never a label.** |
| `primary` | 600 | `#F24E32` | 3.55:1 | Every **filled action**. What a button label needs; 500 cannot give it. |
| `primary-ink` | 700 | `#CC3B24` | 4.98:1 | Coral **text** on white or the lightest tint. |
| `primary-ink-strong` | 800 | `#A93221` | 5.65:1 on the 100-tint | Coral text **on a coral tint** — a secondary button's label, a selected chip. `primary-ink` there is only 4.24:1 and misses AA at 14px semibold. |

Supporting: `primary-hover` (700), `primary-active` (800), `primary-soft`
(100, the tint a secondary action sits on), `primary-subtle` (50, lightest
wash), `primary-soft-strong` (200, that tint's hover), `primary-border` (200).

**One filled coral action per screen.** A real alternative is the soft
secondary button; a way out is outline or ghost. A list of otherwise-equal
choices (three plan cards, say) must not each carry a filled button — that is
three rivals and no primary.

### 4.2 Status — four families, six roles each

```
green   50 #ecfdf5  100 #d1fae5  200 #a7f3d0  500 #10b981  600 #059669  700 #047857  800 #065f46
amber   50 #fffbeb  100 #fef3c7  200 #fde68a  400 #fbbf24  500 #f59e0b  600 #d97706  700 #b45309  800 #92400e
blue    50 #eff6ff  100 #dbeafe  200 #bfdbfe  600 #2563eb  700 #1d4ed8  800 #1e40af
red     50 #fef2f2  100 #fee2e2  200 #fecaca  600 #dc2626  700 #b91c1c  800 #991b1b
```

Every status resolves to one of **success** (green), **warning** (amber),
**error/danger** (red), or **info** (blue). Each family exposes the same six
roles:

| Suffix | For |
| --- | --- |
| plain (`success`) | the colour itself — an icon, a dot, a bar |
| `-soft` | the tinted ground a badge or notice sits on |
| `-strong` | text on that ground |
| `-border` | a hairline around it |
| `-fill` | a **filled control's** background — a step darker than plain, because a filled button label needs 4.5:1 and the plain step does not always clear it |
| `-foreground` | the ink on `-fill` (white) |

`danger` and `error` are the identical values under two names: a destructive
*action* is a danger, the state it leaves behind is an error. Nothing here is
fully saturated — a status is information, not an alarm.

**Rating is amber but is its own role, not `warning`.** Warning means "needs
your attention"; a five-star review needs nothing at all. The unearned half of
a star row is drawn in a neutral grey, not omitted — three filled stars alone
reads as "three", not as "three out of five".

### 4.3 The route — one recurring picture, four roles

A line between two places with something happening on it — a trip card, an
order timeline, a map. Naming the ends as roles is what stops each surface
inventing its own colour for "where this is going":

| Role | Colour | Meaning | Drawn |
| --- | --- | --- | --- |
| origin | green (`success`) | where the traveller set off | **hollow** — they are no longer there |
| destination | coral (`brand`) | the point of the errand | filled |
| current | blue (`info`) | where somebody is *now* — same blue as a device-location dot | filled |
| stop | amber (`warning`) | a shop on the way — a pause, not an end | smaller than either terminus |
| line | neutral grey | the connector, which must never outweigh its ends | — |
| line (strong) | `primary-200` | the connector **only** on a surface whose subject is the journey (e.g. a trip card) | tinted toward the destination |

These are deliberately separate from the status palette: nothing has
*succeeded* because a trip has an origin.

### 4.4 Ink and surfaces

Nothing in the product is pure black, and nothing sits on pure white by
default.

| Role | Value | Contrast on the page ground | For |
| --- | --- | --- | --- |
| text (primary) | near-black (`neutral-900`) | 16.5:1 | headings and body |
| muted (secondary) | dark grey (`neutral-700`) | 7.3:1 | supporting copy |
| faint (tertiary) | mid grey (`neutral-600`) | 4.7:1 | metadata, timestamps |
| disabled | `neutral-400` | — | an unavailable control's label |
| inverse | white | on a filled ground | text on coral / dark fills |

| Surface | Value | For |
| --- | --- | --- |
| page background | `#FFFAF8` — warm off-white, **never pure white** | the app ground |
| surface | white | a card, a sheet |
| surface-muted | `neutral-50` | a recess inside a card |
| surface-strong | `neutral-100` | that recess's hover |

The page is warmed once, in the background colour, precisely so the warmth
lives in the paper and the chroma stays on the actions — a warm neutral ramp
throughout would make the whole screen read as one orange wash.

**One trap:** a "muted" *text* role and a "muted" *surface* role are different
values (dark grey vs. very light grey) and must not share one name in an
implementation — that is how a background ends up painted in text colour.

One filled-coral **surface** exists in the whole product: the order-status
hero, where "what is happening with my errand right now" is answered on
colour so it cannot be scrolled past. It uses the 700 step, not the button's
600, because a two-line sentence needs 4.5:1 and white-on-600 is only 3.55:1
— fine for a short button label, not for running text. **One coral ground per
screen, and only where colour is the message.**

### 4.5 Borders

Default is a 1px hairline in a light neutral (`neutral-200`). A subtler
variant exists for a divider *inside* an object, and a stronger one for a
control's hover state — never for a resting card. A default card carries **no
border at all**: it is defined by its white surface against the warm page
background plus a barely-there shadow. A border-around-every-box is the
fastest way to make a light product look like a form from 2009.

One measured exception: an object that rests on the *page* background (not on
white) needs a **warm-tinted** hairline (`#eee4df`, not the cool default),
because a cool grey ring on warm paper reads as a seam rather than an edge.
Reach for it only there; on white, add a border only to the one card variant
built for it (see §6).

## 5. Typography

One font family for the whole product, chosen for Thai legibility first (in
this app: a rounded Thai/Latin family bundled locally so it works offline;
substitute your own if porting). Body text never drops under 16px on mobile —
Thai has no capital letters to anchor a glyph on and its marks stack above and
below the line, so it loses legibility a step earlier than Latin does.
Nothing in the product is smaller than 12px. Form fields are forced to 16px on
touch devices specifically, because a smaller size makes iOS Safari zoom in on
focus and never zoom back out.

Semantic styles — always imported by name, never composed by hand as a raw
size + weight:

| Name | Size / weight | Line height | For |
| --- | --- | --- | --- |
| `display` | 32 / 700 | 1.25 | the one statement on a screen |
| `heading1` | 28 / 700 | 1.29 | a root screen's title |
| `heading2` | 24 / 700 | 1.33 | a section heading, a pushed screen's title |
| `heading3` | 20 / 600 | 1.4 | a card title |
| `title` | 18 / 600 | 1.45 | a row title, a field group's name |
| `body` | 16 / 400 | 1.5 | the reading size — never smaller on mobile |
| `bodySmall` | 14 / 400 | 1.5 | supporting copy under a title |
| `label` | 14 / 600 | — | a form label, a column heading |
| `caption` | 13 / 400 | 1.42 | metadata — a timestamp, a distance |
| `overline` | 12 / 600, uppercase | 1.35 | a small marker above a heading |
| `price` | 18 / 700, tabular | — | a figure in a row |
| `priceLarge` | 24 / 700, tabular | — | the figure a screen is about — a balance, a total |

`display` / `heading1` / `heading2` are the only fluid steps (they scale down
slightly below ~480px so a headline doesn't force three lines on a narrow
phone); everything `heading3` and below is a fixed size at every width — body
copy is tuned for legibility, not for filling the viewport.

**Money always uses `price` / `priceLarge`**, set in tabular figures. A total
that re-renders in proportional digits jitters sideways as it updates, and a
column of numbers fails to line up on the decimal.

Colour is never baked into a type style — compose it separately (a caption in
default ink vs. a caption in muted ink are the same size token, different
colour utility).

**Weights**: 400 regular, 500 medium, 600 semibold, 700 bold. Don't build
hierarchy from bold alone — combine it with size, spacing and colour.

> **The trap.** If your build tooling merges Tailwind-style classes
> automatically (e.g. `tailwind-merge`), every new font-size step must be
> registered in that merge tool's font-size group in the same commit an
> unregistered `text-*` step gets silently treated as a *colour* class and
> deletes the real colour class beside it — nothing errors, the element just
> inherits body ink. This has already happened once in this product (every
> filled button briefly rendered a dark label on orange).

## 6. Radius

Chosen by what a thing **is**, never by taste — a screen may not invent a step
in between.

| Step | Value | For |
| --- | --- | --- |
| `xs` | 6px | a tag, a swatch, a progress bar |
| `sm` | 8px | a small tile, an icon button |
| `md` | 12px | **every control** — button, input, select, textarea |
| `lg` | 16px | a standard card — a trip, an order, a person |
| `xl` | 20px | a hero card, a wallet balance, a bottom sheet |
| `2xl` | 24px | a modal, a full-bleed panel |
| `pill` | ∞ | chips, badges, avatars, search fields |

## 7. Spacing

A 4px ladder, so a value computed in code and a utility class always agree:

```
4  8  12  16  20  24  32  40  48  64
```

| Value | Typical use |
| --- | --- |
| 4px | tiny internal separation |
| 8px | icon-to-text gap |
| 12px | compact component gap; also a dense card's padding |
| 16px | standard component spacing; the mobile page gutter; a card's dense padding |
| 20px | a card's standard content padding |
| 24px | section-internal spacing; the tablet page gutter; a card that is the screen's main event |
| 32px | section separation; the desktop page gutter |
| 48px+ | major page separation |

No arbitrary spacing outside this ladder, except a genuinely dynamic value
(a safe-area inset) that cannot be expressed any other way.

## 8. Elevation

Shadows are subtle, warm-tinted, and there are exactly four — prefer a
surface-colour change or a border before reaching for one:

| Step | Value | For |
| --- | --- | --- |
| `xs` | `0 1px 2px rgba(0,0,0,.06)` | a resting card in a feed |
| `sm` | `0 2px 8px rgba(0,0,0,.06), 0 1px 2px rgba(0,0,0,.04)` | something raised on purpose — a sticky bar, a floating control |
| `md` | `0 8px 24px rgba(0,0,0,.10)` | something genuinely floating — a modal, a popover, a menu |
| `sheet` | `0 -8px 24px rgba(0,0,0,.10)` | a bottom sheet — the shadow falls upward |

Avoid heavy shadows, multiple stacked shadow layers, and grey floating boxes
everywhere. Most grouping should be spacing and surface colour alone.

## 9. Motion

`--motion-fast` 140ms (press feedback), `--motion-normal` 200ms (the default —
hover, tab changes, most transitions), `--motion-slow` 300ms (a sheet or
modal entering/leaving). Easing: `cubic-bezier(0.32, 0.72, 0, 1)`.

Use motion for: press feedback, hover, tab/segment changes, sheets opening,
card selection, success confirmation. Nowhere else — no decorative animation,
no bouncing, no long blocking transitions. The product's one "something
moved" affordance is a 1% scale-down on press for 120ms, applied to any
tappable object (a card, a nav tab, a list row).

Respect `prefers-reduced-motion` globally (collapse all durations to ~0) —
which means **any animation must be visually correct at its end frame**, since
that's all a reduced-motion user will see. An animation that fades out or
loops needs its own explicit handling; one that settles into a resting state
does not.

## 10. Icons

One icon family, line style (Lucide in this app), stroke 1.75–2px. Sizes:
**16 / 18 / 20 / 24px**, with 20 as the default for UI. Only the bottom
navigation steps up to 24px, because there the icon carries as much of the
labelling job as the text does. The icon library draws functional icons only
— it does not draw the brand mark, which is its own component.

## 11. Components

Everything below already exists in the reference implementation. **Compose
these before writing anything new** — a screen that needs a look no variant
provides has usually found a design question, not a licence for a one-off
style.

### Buttons

Six variants, three sizes, nothing else:

| Variant | Look | For |
| --- | --- | --- |
| `primary` | filled coral (`primary` role), white label | the one thing to do next — one per screen |
| `secondary` | soft coral fill, coral-on-tint label, no border | a real alternative to primary |
| `outline` | soft neutral fill (not a ring), default ink | a neutral action not brand-weighted — "แก้ไข", "ยกเลิก" |
| `ghost` | transparent, coral label, tint on hover | tertiary / inline |
| `danger` | filled red | destructive, irreversible — never the default focus |
| `success` | filled green | a rare *confirming* action that is not the screen's coral CTA (e.g. "confirm payment received") |

There is deliberately **no outlined brand button** — a ring of coral around a
second action is exactly how a screen ends up with two CTAs of equal weight.

Sizes: `small` 36px, `medium` 44px (the touch-target minimum), `large` 52px
(the committing action — on a phone, the difference between a button you aim
at and one that's already where your thumb is). An icon-only square variant
holds the same 44px floor.

States every button supports: default / hover / active / focus / disabled /
loading. A **disabled** button keeps its own colour at reduced opacity (~45%)
rather than collapsing to grey, so its unavailable action is still legible.
**Loading** shows a spinner inside the button and blocks a second press —
never a separate overlay.

### Inputs

Standard height ~52px, 12px radius, visible label above the field (never
placeholder-as-label), helper text below when useful, error message under the
field (never a red border alone — always paired with text and `aria-invalid`).
Minimum touch target 44×44px. A native `<select>` beats a custom dropdown on a
phone. A checkbox means "agreeing to something, applied on submit"; a switch
means "takes effect now" — picking the wrong one strands an unsaved change.

### Cards

A card means **one real thing the user recognises** — a trip, a request, an
order, a place, a person. That is the whole test: a group of three form
fields is not an object and gets a section heading plus spacing instead. Cards
are never nested inside cards.

| Variant | Look | For |
| --- | --- | --- |
| `plain` (default) | white surface, whisper of a shadow, **no border** | the default card |
| `interactive` | `plain` + itself the tap target, shadow deepens on hover | a card that is a link |
| `soft` | tinted, no border | a grouped block inside an otherwise card-free page |
| `outlined` | hairline border, white surface | a card that must sit on a *white* surface, where shadow alone can't separate it |
| `elevated` | deeper shadow | something that genuinely floats — a sheet, a popover |
| `accent` | brand-tinted fill | at most one per screen, for the current task |

Content padding: 12px dense, 16px standard-dense, **20px default**, 24px for a
card that is the screen's main event.

Domain cards (trip, request, order, store, person) share the same geometry,
spacing, typography and interaction behaviour. Suggested content priority per
card type:

**Trip card** — runner identity → destination → origin→destination route →
departure time → distance from user → remaining capacity → trust signal
(rating) → primary action.

**Request card** — store → items summary → delivery location → reward →
route impact if useful → requester trust → accept action.

**Order card** — current human-readable status (never the raw backend enum)
→ store/request summary → other participant → next action → relevant timing.

### Badges and chips — two different concepts

- **Badge** — a status you *read*, not act on. Six tones (`success`,
  `warning`, `error`, `info`, `neutral`, `brand`), each a soft tint with
  strong-coloured text; two sizes, both ≥12px text. The label is always
  human-readable copy, never the raw backend value, and tone is never the
  *only* signal — the label alone must work in greyscale.
- **Chip** — a preset you *select* (a radius filter, an amount). Pill-shaped,
  has a selected state. A badge you can tap is a chip mis-named.

Use chips for filters, categories, amounts. Don't use a chip for information
that deserves plain text.

### Example status vocabulary

Raw backend state values are never shown to a user. An example mapping
(order lifecycle), for the *shape* of the pattern rather than exact copy:

| Raw state | Shown as | Tone |
| --- | --- | --- |
| `WAITING_MATCH` | "กำลังรอคนที่ผ่านทางมารับฝาก" | warning |
| `REQUESTED` | "รอผู้เดินทางตอบรับ" | warning |
| `ACCEPTED` | "ตอบรับแล้ว" | info |
| `PURCHASING` | "กำลังซื้อ" | info |
| `PURCHASED` | "ซื้อของเรียบร้อย" | info |
| `DELIVERING` | "กำลังนำมาส่ง" | info |
| `DELIVERED` | "มาถึงที่นัดแล้ว" | **warning** — goods arrived, money hasn't moved yet; that's a job still owed, not a finished one |
| `COMPLETED` | "จบงานแล้ว" | success |
| `REJECTED` | "ถูกปฏิเสธ" | error |
| `CANCELLED` / `EXPIRED` | "ยกเลิกแล้ว" / "คำฝากหมดเวลาแล้ว" | neutral |

The state→tone mapping is a **product judgement**, decided per workflow next
to the enum it describes — not something a generic status component should
know, because the same raw value can mean different things (or carry
different urgency) in different workflows.

### Other primitives to compose before building new

Avatar, Tabs, Dialog, Bottom sheet, Popover, Dropdown menu, Skeleton, Toast,
segmented control (2–3 views max — a fourth is a chip row instead), radio
group (one choice from a few that each need a line of explanation), empty
state / error state / loading state components, a price-summary row
(itemised lines, a rule, one bold tabular total), a "place" row (pin mark,
name, address clamped to two lines).

## 12. Page skeleton

Every screen is composed the same way, and a screen never draws its own
header or sets its own max-width:

```
Page
  PageContent
    Section (title, content)
    Section (title, content)
  StickyFooter            ← optional, holds the one primary action
```

### The page header (app bar)

One component draws the band at the top of every route — a screen never
builds its own title block:

```
[safe area]
[bell]        [page title, one line, centred on the viewport]        [name] [avatar]
──────────────────────────────────────────────────────────────────────────  ← flat edge
```

Fixed rules, no exceptions per screen:

- **One row, 56px, one flat fill colour** — no gradient, no artwork layer, no
  scrim, no rounded bottom corners, nothing sticky except a thin safe-area
  strip.
- **Coloured tone or neutral tone only.** A "coloured" header is a dark coral
  fill with white text — never the bright brand coral itself, because white
  text on the brightest step fails contrast for anything longer than a short
  label. A "neutral" header is a plain surface with a hairline, reserved for
  screens where somebody is checking a figure or confirming something (a
  statement, a settings screen, a legal document).
- **Left = what's waiting for me** (a notification bell, nothing else).
  **Middle = what screen is this** (the route name, truncates last). **Right
  = who am I** (display name + avatar, also the way into the profile screen).
  The name truncates before the title ever does.
- **No back button, ever.** Most screens are reachable from several paths, so
  a top-left arrow would point somewhere different depending on how someone
  arrived. Use the platform's own back gesture and a tab bar/menu instead. The
  one exception is a screen that can *name* its own parent explicitly (e.g. a
  multi-step flow that knows step 2 always follows step 1).
- **A screen's own controls (refresh, help) publish into a title-adjacent slot
  the shell renders, never a second row.** They never share the header with
  the bell.
- One route may render **no chrome at all** (a full-screen map/tool) — that's
  a deliberate exception per route, decided once, not a variant every screen
  can opt into.

## 13. Navigation

Bottom tab bar (mobile) — four fixed tabs plus one raised centre action:

```
หน้าหลัก (home)  |  คำสั่งฝาก (orders)  |  [ raised: ฝากซื้อ ]  |  กิจกรรม (activity)  |  บัญชี (account)
```

- The **raised centre button** is the marketplace's other half — starting the
  "ask someone to buy something" flow — and its icon/label may swap on the one
  screen that's the mirror flow (starting a trip), but never elsewhere: a
  centre button that changes identity as you browse is worse than one that
  never moves.
- Five tabs is the ceiling for a 64px bar; a sixth is a session-average
  mis-tap. Secondary destinations (settings, earnings) live one level down
  from a tab, not in the bar.
- Label real user intent, not backend nouns — "กิจกรรม" (activity) rather than
  "กล่องข้อความ" (inbox) if there's no real conversation feature behind it.
- Desktop replaces the bottom bar with a top nav at `lg` — wordmark,
  destinations, the same primary action, the bell, an account menu — and it
  becomes the *only* place identity and destinations live at that width (the
  header band collapses to a plain title, so nothing is drawn twice).

## 14. Search and marketplace density

Search is a primary discovery pattern (destination, store, area, trip) and
should feel lightweight — a rounded, prominent field, not a dense form
control.

Keep any marketplace list scannable: **one primary piece of information, two
to four secondary signals, one main action** per card. Never put every
available field on a card — the rest belongs on its detail page.

## 15. Home / landing pattern

Home is a **preview screen**, not a dashboard of live counters. A representative
running order: header band → promotional carousel (secondary, capped height,
never overpowering the primary action) → primary CTA → a small row of quick
actions → a live/nearby preview (capped to a few rows, "see all" opens the
real feed) → trust/safety content last.

Never lead a home screen with raw counters ("Active Orders: 3", "Wallet:
฿420") — those belong deeper, in their own context. One filled coral action
on the whole page; everything else is a link, a tint, or a small secondary
control. One column on a phone; a rail (secondary content only — never
content the user must act on first) may appear beside the main column from
`lg`, built with CSS so both are in the DOM at every width (never swap layouts
with a JS media-query check, which renders the wrong one for a frame and
drops content from the accessibility tree at the other width).

## 16. Maps

Maps support a decision (nearby trips, an origin/destination, a delivery
point) — never decoration alone. Always provide the same information as a
card/list wherever practical; do not make the map the only way to read it.

Two footguns worth naming explicitly for anyone implementing this pattern
fresh: mapping libraries and GeoJSON typically take `[lng, lat]` while
product/API code says `lat, lng` — get the swap wrong once and a pin lands on
the wrong continent with no type error. And a map library's own zoom levels
are sometimes offset by one from the "256px tile" zoom convention other tools
use — verify empirically rather than assuming parity.

## 17. Empty, loading and error states

**Empty state** explains three things: what's missing, why it may be missing,
and what to do next. Example: "ยังไม่มีใครกำลังไปทางนี้ — ลองขยายระยะค้นหา
หรือกลับมาดูอีกครั้งเมื่อมีทริปใหม่" rather than a bare "ไม่พบข้อมูล".

**Loading state** — skeletons shaped like the real content for cards, lists,
profile blocks; never a full-screen blocking spinner when partial content
could render. A skeleton for a list row should mirror that row's real layout
exactly, so nothing jumps when data arrives. Avoid a dedicated
route-level loading screen that shows on every navigation — only a component
waiting on its own data should show a skeleton, scoped to itself.

**Error state** is specific and offers a retry: "โหลดทริปใกล้คุณไม่สำเร็จ —
ลองใหม่อีกครั้ง", never a bare "Something went wrong." Never render a raw
backend string or a stack trace. For a serious action (a multi-field form),
preserve the user's input across a failed submit.

## 18. Images

Consistent aspect ratios, controlled cropping (`object-cover`, not stretch), a
defined fallback/placeholder state, and one shared media component rather than
a bespoke `<img>` per screen. An uploaded image (a banner, a store photo) must
never be allowed to dictate page layout — always constrain it to a fixed
frame.

## 19. Carousel (if the product has promotional content)

Treat any home-page carousel as supporting content, not a hero. Keep its
height modest relative to the primary action beneath it (roughly a 2.5–2.7:1
width:height band reads as "promotional strip", not "poster"). If it loops,
each resting position should show a real neighbouring slide (a peek) rather
than blank space or a decorative filler strip — that's what tells a reader it
swipes at all, without needing an arrow or caption.

## 20. Accessibility

- Text contrast must meet WCAG AA at the size it's set — see the ink table in
  §4.4 for what each role actually clears.
- **One focus treatment for the whole product** — a 2px outline in the focus
  colour at 2px offset, declared globally. Never remove it, never re-style it
  per component.
- Icon-only buttons require an accessible name (`aria-label`).
- Never communicate meaning through colour alone — a status badge's label
  must say the state in words even in greyscale.
- Touch targets ≥44×44px, everywhere, no exceptions for "it looked fine on
  desktop".

## 21. Desktop adaptation

Increase information density without becoming an admin dashboard:

- Good: two-column marketplace layouts, a map+list split view, a larger
  search surface, a side detail panel, a multi-card grid.
- Avoid: dense tables for ordinary marketplace flows, a permanent sidebar
  full of system navigation, an overly wide form (forms stay at the `narrow`
  620px measure even on a 1440px screen).

An admin/back-office surface may use denser information architecture where
genuinely necessary, but must still use the same tokens, buttons, inputs and
status system as the customer-facing product — admin density must never leak
back into the customer experience.

## 22. What to check before shipping a screen

1. **No raw colour, no invented spacing or radius.** Every value traces to a
   token in §4–§7. A safe-area inset or another genuinely dynamic pixel value
   is the only legitimate exception.
2. **Compose existing components.** A look no variant provides is a design
   question to raise, not a local override to ship.
3. **Exactly one filled primary action per screen.**
4. **Use the page skeleton; never draw a header or set a page's own width.**
5. **Is this really a card?** (§11 Cards) — if it's a group of form fields,
   it's a section heading and spacing instead.
6. **Never render a number, badge, rating or status the backend hasn't
   actually sent.** An unrated person is drawn as "new", never as a zero.
7. **Never compute a distance, capacity, deadline or total on the client** —
   the server is the source of truth for anything like this.
8. **Touch targets ≥44px; focus ring intact.**
9. Does it feel like a marketplace, not a dashboard? Is the main action
   obvious? Is it comfortable at 390px? Are colours all coming from tokens?
