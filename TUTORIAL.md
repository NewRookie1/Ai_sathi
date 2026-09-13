# AI Saathi — New User Tutorial Guide

Welcome! **AI Saathi (Artisan AI)** is a voice-first app that helps artisans
scan products, create catalog listings, get smart prices, manage orders,
check market trends, and grow together through Community.

> No tech skills needed. You can **speak** instead of typing.
> Works in 10 languages: English, Hindi, Marathi, Gujarati, Bengali,
> Tamil, Telugu, Kannada, Malayalam, Punjabi.

---

## 1. Install the app

1. Copy `app-release.apk` to your Android phone.
   - Latest build: `ai_saathi/build/app/outputs/flutter-apk/app-release.apk`
2. Tap the file → **Install** → allow “Install unknown apps” if asked.
3. Open **AI Saathi**.
4. Allow **Microphone** (voice) and **Camera** (scanner) when asked.
   - No permission = voice/scanner will show a text box instead.

No internet? The app still opens. Use **Demo Mode** (see below).
For full AI (voice chat, price, image analysis) you need internet —
the app talks to the online backend automatically.

---

## 2. First launch (2 minutes)

### Step 1 — Choose language
First screen = language grid. Tap your language.
You can change it later: **Profile → Language**.

### Step 2 — Onboarding (4 slides)
Swipe through:
1. Speak Your Product, 2. Scan and Identify,
3. Smart Pricing, 4. Grow Your Business.
Tap **Skip** or **Get Started**.

### Step 3 — Login
- **New here?** Tap “Create Account”, enter name + email + password.
- **Returning?** Enter email + password → Sign In.
- **Just exploring?** Tap **Try Demo Mode** — no account, no internet
  needed. Perfect for practice.

You land on **Home**.

---

## 3. Home — your daily dashboard

Bottom bar (left → right):
**Home | Products | Orders | 🎤 | Market | Community | Profile**

- The **orange mic button in the center** floats above the bar.
  Tap it anytime → Voice Assistant.
- **Quick actions**: Scan Product, My Products, Orders, Market.
- **Community banner** → opens Community Hub.
- **Recent products / orders** — demo cards at first; your real data
  appears once you add products and get orders.

---

## 4. Voice Assistant (the heart of the app)

Tap the **center mic** or **AI Assistant** card.

### Voice mode
1. Tap the big **mic (72px)** → speak (auto-stops at 20 sec).
2. App shows your words → thinks → speaks the answer + does the action.
3. If it understood, it listens again automatically. Tap **stop** to end.

### Text mode
Tap the **keyboard icon** (top bar) → type → Send.
Useful in noisy places or if mic fails.

### What to say (examples)
- “Open my products” / “Show new orders”
- “Scan product” / “Add new product”
- “Suggest price for clay diyas”
- “Show market trends”
- “Open collective orders” / “Open collaboration” / “Open community”
- “Go back” / “Help”

Tips:
- Speak slowly, one command at a time.
- If it says “did not understand”, try shorter words or type it.
- Status text under the mic shows Sending → Thinking → answer.

---

## 5. Scan a product with camera

1. Home → **Scan Product** (or Voice: “scan product”).
2. Point camera → **Capture** (or pick from gallery).
3. AI fills: Name, Category, Material, Craft, Colors, Description.
4. Tap **Add to Catalog** → review in Add Product → **Save**.

If analysis fails: check internet, retake in good light, or fill manually.

---

## 6. Products

**Products tab** = your catalog.
- Search bar filters by name.
- Tap a card → details: photos, price + min–max range, views/orders/sold,
  **Get Price** (AI suggestion + reasoning), **Market** (trends for that
  category), **Delete** (asks first).

**Add Product (+ button):**
1. Photo (camera → scanner, or gallery — auto-analyzes).
2. Name (required), Description, Category (Pottery, Textiles…),
   Material, Craft Type, Price, Quantity, Tags.
3. **Save Product** → appears at top of list.

---

## 7. Pricing

Open via Product → **Get Price**, or **Pricing** screen.
1. Enter category + material cost + labor cost.
2. Tap **Get Price Suggestion**.
3. You get: big suggested price, range, reasoning, confidence %,
   “Estimate” badge if AI is unsure.

Use it as a guide — you set the final price.

---

## 8. Orders + Easy Delivery

**Orders tab** has 3 tabs: New / Pending / All (with counts).
Tap an order → details: buyer, items, total, address.

- New order → **Accept** (green) / **Reject** (red).
- Pending/Accepted → **Cancel** (asks “Are you sure?”).

### Easy Delivery (new)
Each order has a delivery card:
- **Pickup** (Free) / **Standard** (₹49, 3–5 days) / **Express** (₹99, 1–2 days)
- **Open-box** switch = buyer can open before paying.
- Choice saves instantly (`Delivery saved ✓`) and syncs online when logged in.

Full delivery hub: **Community → Easy Delivery** — all orders with the
same one-tap selectors + option cards.

---

## 9. Market

**Market tab** → pull down to refresh.
- Top: trending cards (category, demand badge, summary, avg price).
- Below: static insight cards (avg price, listings, demand score).

Use it before pricing: high demand (green) = you can price higher.

---

## 10. Community — grow together

Bottom bar → **Community** (group icon, between Market and Profile).

| Tile | What it does |
|---|---|
| Collective Orders | Join bulk orders (Diwali Diyas, Export Fabric…). Progress bar + spots left. **Join/Joined** toggles green instantly, count +1. Pull to refresh for server data. |
| Second Hand | Buy pre-owned tools/material. Each card: condition badge, discount %, price + MRP, **Buy** (places order) + **Contact** (seller contacts you). **Sell item** FAB lists your own item. |
| Collaboration | Find partners. Cards show type (Need help / Share material / Joint product). **Interested (count)** toggles green. **+ Create post** (title + type + desc). |
| Budget Bazaar | Cheap finds. Filter chips ≤₹299/499/999. |
| Seller Support | 6 schemes: Zero-Fee Launch, Spotlight, Training, Delivery Help, Marketing Kit, Credit. Tap **Apply** → chip turns **Applied** + registered badge on top. Plus training videos + WhatsApp help info. |
| Easy Delivery | Delivery hub described above. |

All Join / Interested / Apply buttons update **immediately** (even offline)
and sync to the server when you’re logged in.

---

## 11. Profile + Settings

**Profile tab**: your avatar, name, shop. Tiles:
- Language (10 languages, instant switch + “saved” toast)
- Notifications (orders / price / market / voice toggles)
- Shop Settings (name, location, desc)
- Payment Settings (name + UPI/Bank; UPI validated)
- Help & Support (5 FAQs + contact card)
- About, Rate App, **Logout** (asks first)

---

## 12. Troubleshooting

| Problem | Fix |
|---|---|
| Mic doesn’t record | Allow microphone in system Settings → Apps → AI Saathi → Permissions. Use keyboard mode meanwhile. |
| “Speech recognition failed” | No internet or unclear audio. Retype the command. |
| Camera black screen | Allow camera permission. Restart app. |
| Login fails | Check internet. Or use Demo Mode. Backend sleeps ~50s on first use — wait and retry. |
| Join/Interested didn’t change before (old bug) | Fixed in latest APK — update to `app-release.apk` 13-09-2026+. |
| App feels slow first time | Normal — Render free backend cold-starts. Second tap is fast. |

Support: **Profile → Help & Support**, or WhatsApp (hours in Seller Support).

---

## 13. For shop owners (30-sec pitch to artisans)

1. Speak your product → AI writes the listing.
2. Photo → AI describes it.
3. One tap → smart price + market check.
4. Orders + delivery in one place.
5. Community = bulk orders + cheap material + partners + free support.

**That’s it — tap the orange mic and say what you want to do.**
Happy selling!
