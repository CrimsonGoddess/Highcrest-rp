# Highcrest RP: Project Brief

The owner's creative and development direction. Use this as the foundation for all server work.

**HIGHCREST RP**
*Luxury nightlife meets underground street culture.*
*Everybody wants the top. Not everybody makes it.*
Semi-Serious Roleplay | High Stakes | Original GTA V Map

## 1. Server identity

- **Server name:** Highcrest RP
- **Full branding:** HIGHCREST ROLEPLAY
- **Theme:** Luxury nightlife meets underground street culture.
- **Roleplay style:** Semi-Serious RP
- **Tagline:** "Everybody wants the top. Not everybody makes it."
- **Secondary theme:** High Stakes: risk, ambition, money, power and reputation.
- **Map:** Original GTA V map, including Los Santos and Blaine County. The map is not being replaced.

### Vision

Highcrest RP is a modern city where high-end luxury lifestyles coexist with underground street culture.

By day, players can build careers, manage businesses, work in law enforcement, provide emergency services or establish themselves as entrepreneurs.

By night, the city comes alive with exclusive clubs, luxury parties, underground car meets, street racing, music events and criminal organizations.

The goal is a unique, immersive city where players build reputations, establish businesses, form connections and create memorable stories.

This is a semi-serious server: a balance between realistic roleplay and enjoyable gameplay, without overly restrictive mechanics.

## 2. Branding

**Primary colors**

- Crimson Red: `#C8102E`
- Jet Black: `#0B0B0D`

**Secondary colors**

- Metallic Gold: `#D4AF37`
- Charcoal: `#1C1C22`
- Soft White: `#F5F5F5`

**All custom interfaces should use:**

- Modern, sleek designs
- Dark backgrounds with subtle crimson gradients
- Metallic gold accents for premium features
- Clean, readable typography
- Smooth, lightweight animations
- Professional layouts with intuitive navigation
- Responsive designs for different screen resolutions

Avoid overly bright neon, cartoonish graphics or cluttered interfaces. The overall aesthetic should feel expensive, sophisticated and slightly dangerous.

## 3. Official artwork

The files are in `branding\`. Use these rather than generating replacement artwork.

| File | Size | Use |
|---|---|---|
| `highcrest_cfx_banner_1865x200.png` | 1865 x 200 | CFX server banner |
| `highcrest_rp_icon_512x512.png` | 512 x 512 | Server icon |
| `highcrest_rp_icon_original_1254x1254.png` | 1254 x 1254 | Full-size icon source |
| `highcrest_banner_2172x724.png` | 2172 x 724 | Wide banner |

## 4. Loading screen

The loading screen should feature:

- The official Highcrest RP branding
- A cinematic nighttime Los Santos aesthetic
- Luxury exotic cars and upscale nightlife
- A black, crimson and metallic gold color scheme
- The tagline: "Everybody wants the top. Not everybody makes it."
- A clean, immersive layout
- Optional Discord and community information once provided

Do not place a fake or decorative loading bar directly into the background image. Any progress indicator is built separately with HTML, CSS and JavaScript, and reflects actual loading progress where supported.

## 5. Gameplay direction

Highcrest RP supports both civilian and criminal roleplay.

**Civilian life**

- Player-owned businesses
- Employment and career progression
- Real estate and property ownership
- Vehicle dealerships
- Mechanic businesses and custom vehicle modifications
- Restaurants, bars and nightclubs
- Entertainment and community events

**Emergency services**

- Police roleplay
- EMS and medical roleplay
- Dispatch and emergency response systems
- Professional department management

**Underground street culture**

- Street racing and car meets
- Criminal organizations and gangs
- Underground vehicle culture
- Criminal progression
- Black-market activities
- Reputation-based opportunities

**Luxury nightlife**

- VIP clubs and exclusive events
- Player-owned nightclubs
- Music and entertainment businesses
- Premium vehicle culture
- Luxury properties and businesses

The goal is a balanced economy where legitimate careers and criminal opportunities both feel worthwhile.

## 6. Signature custom features

These are future goals, not features that are already implemented.

1. **Empire System:** A comprehensive player-owned business system with ownership, employees, business banking, inventory, finances and long-term growth.
2. **Reputation & Influence:** Players develop reputations through their activities, businesses, relationships and accomplishments. Reputation creates opportunities without unfairly restricting new players.
3. **High Stakes Club:** An exclusive social club with VIP membership, special events, luxury networking and prestige-based opportunities.
4. **City Spotlight:** A custom event system for car shows, nightlife events, competitions, business expos and community activities.
5. **Risk & Consequence:** Meaningful but balanced consequences for criminal activity, financial decisions and reputation. Avoid overly punishing systems that make semi-serious RP frustrating.

## 7. Development priorities

Follow this order.

**Phase 1: Server foundation**

- Confirm the server boots successfully.
- Verify the selected framework and dependencies.
- Check the database connection.
- Verify player joining and character creation.
- Confirm inventory, banking, jobs and core systems function.
- Update the server name, description, tags, icon and branding.

**Phase 2: Highcrest UI**

- Implement the branded loading screen.
- Apply consistent colors across custom interfaces.
- Set up branded notifications and welcome messages.
- Ensure all interfaces function correctly.

**Phase 3: Empire System MVP**

- Business ownership
- Employee management
- Employee ranks and permissions
- Business bank accounts
- Database persistence
- Secure server-side transactions

**Phase 4: Feature expansion**

- Advanced business inventory
- Supply chains and deliveries
- Business upgrades
- Reputation and influence
- High Stakes Club
- City Spotlight events

## 8. Development requirements

- Work with the existing FiveM framework and installed resources.
- Do not assume which framework, inventory, banking, phone or target system is installed. Inspect and confirm them first.
- Avoid duplicating existing resources unnecessarily.
- Write modular, maintainable code.
- Use secure server-side validation for all financial transactions and sensitive actions.
- Never trust client-provided money amounts or permissions.
- Keep scripts optimized for multiplayer performance.
- Test each system before moving to the next.
- Provide clear installation instructions and configuration files.
- Do not overwrite working systems without reviewing them.
- Explain any dependencies or compatibility requirements.

The aim is for Highcrest RP to feel like a professionally developed, cohesive server rather than a collection of unrelated scripts.
