# MachSetu: Play Console copy-paste sheet

Everything to type into Play Console, section by section. Files in this folder:

- `icon-512.png`: App icon (512 × 512)
- `feature-graphic-1024x500.png`: Feature graphic (1024 × 500)

Package name: **com.machsetu.app**

---

## 1. Create app

| Field | Value |
|---|---|
| App name | MachSetu |
| Default language | English (India) – en-IN |
| App or game | App |
| Free or paid | Free |

---

## 2. Main store listing (Grow users → Store presence → Main store listing)

**App name** (max 30)
```
MachSetu: Buy & Sell Machines
```

**Short description** (max 80; this one is 75)
```
Buy & sell verified used CNC, VMC, lathe & industrial machines across India
```

**Full description** (max 4000)
```
MachSetu is India's B2B marketplace for pre-owned CNC, VMC and industrial machines. Buy a verified machine for your shop floor, or sell idle machines to serious buyers, all from one app.

WHY MACHSETU
• Verified listings: every machine is checked by our sourcing desk before it goes live
• Technical audits: spindle hours, service history and condition details on every listing
• Escrow protection: payment is held until your inspection window closes
• Clear pricing: brokerage, freight and GST are shown before you place an order

FOR BUYERS
• Browse CNC machines, VMC centres, lathes, grinders, EDM and more
• Filter by category, brand, price, year and location
• See full specifications, photos and audit details
• Send an inquiry or request a quote. A MachSetu broker negotiates for you
• Place orders and track every stage from dispatch to installation
• Save machines and get notified about your orders and inquiries

FOR SELLERS
• List a machine in four simple steps
• Upload photos and documents (invoice, ownership proof, maintenance records)
• Track your submission from review to approval
• Reach verified buyers across India without cold calling

BUILT FOR INDUSTRY
MachSetu is made for manufacturers, machine shops, dealers, traders and procurement teams in India's manufacturing sector, from Rajkot and Ahmedabad to Pune, Chennai and beyond.

Questions? Write to machsetu@gmail.com or call +91 84015 03169.
```

**Graphics**
- App icon → `icon-512.png`
- Feature graphic → `feature-graphic-1024x500.png`
- Phone screenshots → take 4–8 from a real phone (see section 10)

---

## 3. Store settings (Grow users → Store presence → Store settings)

| Field | Value |
|---|---|
| App category | Business |
| Tags | Business, Shopping, Marketplace (pick the closest offered) |
| Email | machsetu@gmail.com |
| Phone | +91 84015 03169 |
| Website | https://machsetu.com |

---

## 4. App content (Policy and programs → App content)

### Privacy policy
```
https://machsetu.com/privacy
```

### App access
Select **"All or some functionality is restricted"** → Add instructions:

- Name: `Reviewer login`
- Username: `playreview@machsetu.com` (create this account first, see section 9)
- Password: (the password you set for it)
- Any other information:
```
Sign in with the email and password above. No OTP is needed to sign in. To test account deletion: Profile → Security → Delete Account.
```

### Ads
**No, my app does not contain ads.**

### Content rating
Start questionnaire → Email: machsetu@gmail.com → Category: **"All Other App Types"**

| Question | Answer |
|---|---|
| Violence | No |
| Sexuality | No |
| Language | No |
| Controlled substances | No |
| Crude humour | No |
| Gambling | No |
| Users can interact or exchange content | **No** (inquiries go to MachSetu brokers, not user-to-user) |
| Shares user's location | No |
| Allows purchase of digital goods | No |
| Is it a web browser or search engine | No |

Expected rating: **Everyone / 3+**.

### Target audience and content
- Target age: **18 and over** only
- Appeals to children: **No**

### News app
**No**

### Data safety
**Data collection and security**

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **Yes** |
| Is all of the user data collected by your app encrypted in transit? | **Yes** |
| Do you provide a way for users to request that their data is deleted? | **Yes** |
| Delete account URL | `https://machsetu.com/delete-account` |

**Data types: tick ONLY these**

| Category → Type | Collected | Shared | Required or optional | Purposes |
|---|---|---|---|---|
| Personal info → Name | Yes | No | Required | App functionality, Account management |
| Personal info → Email address | Yes | No | Required | App functionality, Account management |
| Personal info → User IDs | Yes | No | Required | App functionality, Account management |
| Personal info → Address | Yes | No | Optional | App functionality |
| Personal info → Phone number | Yes | No | Required | App functionality, Account management |
| Personal info → Other info (company, GSTIN, PAN) | Yes | No | Optional | App functionality |
| Financial info → Purchase history | Yes | No | Optional | App functionality |
| Photos and videos → Photos | Yes | No | Optional | App functionality |
| Files and docs | Yes | No | Optional | App functionality |
| Messages → Other in-app messages | Yes | No | Optional | App functionality, Customer support |
| App activity → Other user-generated content | Yes | No | Optional | App functionality |

For every type above:
- "Is this data processed ephemerally?" → **No**
- "Shared?" → **No**. Passing details to the seller when the user raises an inquiry or order is a user-initiated transfer, and hosting or logistics are service providers. Google does not count either as "sharing".

Do **NOT** tick: Location, Contacts, Calendar, Health, Payment info, Credit score, Web browsing, Device IDs, Audio, App interactions, Crash logs, Diagnostics. The app has no analytics, ads or crash SDKs.

### Government apps
**No**

### Financial features
**My app doesn't provide any financial features.** (No loans, banking, payments or crypto are handled inside the app.)

### Health apps
**My app does not have any health features.**

### Account deletion (if asked separately)
```
https://machsetu.com/delete-account
```
In-app path: Profile → Security → Delete Account.

---

## 5. Closed testing release (Test and release → Testing → Closed testing)

1. Create track (or use **Alpha**) → Countries/regions: **India**
2. Testers → **Create email list** → name `MachSetu testers` → paste at least 12 Gmail addresses
3. Feedback URL or email: `machsetu@gmail.com`
4. **Create new release**
5. App signing: **Use Google-generated key** (Play App Signing)
6. Upload: `Machsetu_App\build\app\outputs\bundle\release\app-release.aab`
7. Release name: `1.0.0 (1)`
8. Release notes:
```
<en-IN>
First release of MachSetu: buy and sell verified used CNC, VMC and industrial machines.
</en-IN>
```
9. Next → Save → **Send changes for review**

---

## 6. Production access questions (after 14 days with 12+ testers)

Dashboard → **Apply for production**. Suggested answers (edit them to what actually happened):

- **How did you recruit testers?** Friends, colleagues and machine-shop owners in our network in Gujarat who buy and sell industrial machines.
- **How engaged were testers?** Testers browsed listings, raised inquiries, submitted machine listings and placed test orders over the 14 days.
- **Feedback received and changes made:** list the real feedback and the fixes you shipped in updates during testing.
- **Who is the app for?** Manufacturers, machine shops, dealers and traders in India buying or selling pre-owned CNC, VMC and industrial machines.
- **How is the app valuable?** It replaces phone calls and brokers with verified listings, technical audit details, transparent pricing and escrow protection.
- **Expected installs in the first year:** 1,000–10,000.

---

## 7. Every future update

1. Raise the version in `Machsetu_App/pubspec.yaml`: `1.0.0+1` → `1.0.1+2` → `1.0.2+3`. The number after `+` must always go up.
2. `flutter build appbundle --release`
3. Play Console → the track → Create new release → upload the new `.aab`.

---

## 8. Upload key (never lose this)

- Keystore: `Machsetu_App/android/upload-keystore.jks`
- Passwords: `Machsetu_App/android/key.properties`
- Both are git-ignored. **Back both up to Google Drive and a pendrive now.**
- With Play App Signing on, a lost upload key can be reset through Play support, but it takes days.

---

## 9. Before submitting: do these on the live site

1. Deploy the website so these open: https://machsetu.com/privacy, https://machsetu.com/terms and https://machsetu.com/delete-account
2. Create the reviewer account in the app: name `Play Review`, email `playreview@machsetu.com`, any 10-digit number you control, and a strong password. Finish the OTP step. Put those details into App access (section 4).

---

## 10. Screenshots checklist

Phone screenshots: PNG or JPEG, 16:9 or 9:16, each side between 320 px and 3840 px. Take them on a phone signed in with real-looking data:

1. Home screen (hero banner + categories)
2. Machine list with filters
3. Machine detail page (photos + specs)
4. Sell a machine: step 1
5. My Inquiries or order tracking
6. Profile screen
