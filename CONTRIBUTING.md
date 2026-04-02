# Contributing to popcornrp-customs

Thank you for your interest in contributing to **popcornrp-customs**.  
This resource provides a fully featured vehicle customization system for FiveM, built with **ox_lib**, optional **QBCore** integration, and a lightweight NUI.

This document explains:

- how to set up your environment,  
- how the architecture is structured,  
- how to add new modification categories,  
- how to add new zones,  
- how to work with the codebase and submit changes,  
- coding style guidelines,  
- and the project’s code of conduct.

---

# 1. Introduction

This project aims to provide a clean, modular, and extensible vehicle customization system.  
Contributions are welcome — whether you want to fix bugs, improve performance, add new features, or enhance documentation.

---

# 2. Project Architecture Overview

## 2.1 High-level flow

### Player enters a zone
- `Config.Zones` defines polyzones.  
- `client/zones.lua` creates `lib.zones.poly` zones and blips.

### Player presses [E] in a zone
- `zones.lua` checks job restrictions and vehicle presence.  
- Calls `require('client.menus.main')()` to open the main menu.

### Main menu opens
- `client/menus/main.lua` builds the main options (repair, performance, cosmetics).  
- Starts the drag camera (`client/dragcam.lua`).  
- Disables vehicle controls while in menu.

### Player selects an option
- `main.lua` loads a specific submenu (e.g. `client.menus.performance`).  
- Submenus use `client/utils/installMod.lua` to handle payment and notifications.

### Server-side validation and payment
`server.lua` handles:
- QBCore integration (money, job, vehicle ownership),  
- free zones (`freeMods`, `freeRepair`),  
- pricing via `Config.Prices`,  
- saving vehicle props to DB (oxmysql).

### Vehicle properties saved
- On menu close, `main.lua` triggers `customs:server:saveVehicleProps`.  
- `server.lua` checks `player_vehicles` and updates `mods` JSON.

### UI feedback
- NUI (`web/index.html` + `web/script.js`) plays `sound.mp3` when Lua sends `{ sound = true }`.

---

## 2.2 Repository structure

### fxmanifest.lua
Declares scripts, shared config, NUI page, meta files.

### config.lua
Zones, prices, paints, wheels, xenon, tints, plates, neon, smoke, labels.

### server.lua
QBCore integration, payments, free zones, admin mode, DB persistence.

### client/zones.lua
Polyzone creation, blips, TextUI, [E] interaction, admin menu.

### client/menus/main.lua
Main menu, repair logic, submenu routing, drag camera, save props.

### client/dragcam.lua
Orbital camera around vehicle, zoom, mouse rotation, instructional buttons.

### client/utils/installMod.lua
Payment callback, notifications, sound trigger.

### client/menus/*.lua, client/options/*.lua, client/utils/enums/*.lua
Category menus, option handlers, enums.

### web/script.js
Plays sound on message with `{ sound: true }`.

### carcols_gen9.meta, carmodcols_gen9.meta, stream/vehicle_paint_ramps.ytd
Vehicle color and paint ramp data.

---

# 3. Environment Setup

## 3.1 Requirements

- Git  
- FiveM FXServer  
- FiveM client  
- QBCore (optional, required for paid mods + DB saving)  
- ox_lib and oxmysql  
- Visual Studio Code (recommended)  
- Node.js (only if extending NUI)

## 3.2 Recommended VS Code extensions

- Lua (sumneko)  
- FiveM Natives  
- EditorConfig  
- Prettier (for JS)

## 3.3 Cloning and installing

**HTTPS**
```
git clone https://github.com/alberttheprince/popcornrp-customs.git
cd popcornrp-customs
```

**SSH**
```
git clone git@github.com:alberttheprince/popcornrp-customs.git
cd popcornrp-customs
```

Place the folder in your server:

```
resources/[local]/popcornrp-customs
```

Add to `server.cfg`:

```
ensure ox_lib
ensure oxmysql
ensure qb-core      # if you use QBCore
ensure popcornrp-customs
```

---

# 4. Running and Testing Locally

1. Start your FXServer.  
2. Join with your FiveM client.  
3. Drive into one of the default zones from `Config.Zones`.  
4. Press **[E]** when the TextUI appears.  
5. Use the menu to:
   - test repair,  
   - test performance upgrades,  
   - test cosmetic changes.

Check:

- F8 console for client errors,  
- server console for oxmysql/QBCore errors,  
- DB table `player_vehicles` for updated `mods` JSON.

---

# 5. How to Add a New Zone

Zones are defined in `Config.Zones` in `config.lua` and used by `client/zones.lua`.

## 5.1 Basic zone structure

```
{
    blipLabel = "Los Santos Customs - Vinewood",
    blipColor = 5,
    points = {
        vec3(-344.36, -121.92, 38.60),
        vec3(-319.43, -130.65, 38.60),
        vec3(-324.77, -147.93, 38.60),
        vec3(-348.59, -139.1, 38.60),
    }
}
```

## 5.2 Optional fields

- `job = { 'mechanic', 'police' }`  
- `freeMods = { 'mechanic' }`  
- `freeRepair = { 'mechanic' }`  
- `hideBlip = true`

## 5.3 Steps to add a new zone

1. Pick coordinates and ensure all `vec3` points share the same Z value.  
2. Add a new entry to `Config.Zones`.  
3. Restart the resource or server.  
4. Verify:
   - blip appears (unless `hideBlip`),  
   - TextUI appears when in a vehicle inside the zone,  
   - [E] opens the menu.

---

# 6. How to Add a New Modification Category

Categories are driven by:

- `client/menus/main.lua`  
- `client/menus/*.lua`  
- `client/options/*.lua`  
- `config.lua`  
- `client/utils/installMod.lua` + `server.lua`

## 6.1 Add a new category to the main menu

In `client/menus/main.lua`, `main()` builds the options:

```
local options = {
    {
        label = 'Performance',
        close = true,
        args = { menu = 'client.menus.performance' }
    },
    {
        label = 'Cosmetics - Parts',
        close = true,
        args = { menu = 'client.menus.parts' }
    },
    {
        label = 'Cosmetics - Colors',
        close = true,
        args = { menu = 'client.menus.colors' }
    },
}
```

To add a new category:

```
options[#options + 1] = {
    label = 'Cosmetics - Interior',
    close = true,
    args = {
        menu = 'client.menus.interior',
    }
}
```

## 6.2 Create the category menu file

Create `client/menus/interior.lua`:

- build a `lib.registerMenu` definition,  
- list options (e.g. dashboard, interior color),  
- call appropriate option handlers in `client/options/`,  
- use `installMod` when applying paid mods.

## 6.3 Create or reuse option handlers

Handlers typically:

- read current vehicle mods,  
- build a menu of choices,  
- apply preview mods,  
- call `installMod(duplicate, modType, notifyProps, level)`.

## 6.4 Update config if needed

If your new category uses new data, add them to `config.lua`.

---

# 7. Development Workflow

## 7.1 Branching

```
git checkout -b feature/my-change
```

## 7.2 Checklist before opening a PR

### Functionality

- [ ] Resource starts without errors  
- [ ] Zones work correctly  
- [ ] Main menu opens and closes correctly  
- [ ] Drag camera works  
- [ ] New categories/options behave as expected  
- [ ] Payment logic works (with and without QBCore)  
- [ ] Free zones behave correctly  
- [ ] Admin menu works and bypasses payment  
- [ ] Vehicle props save correctly  

### Code

- [ ] No unused requires or dead code  
- [ ] No debug prints left  
- [ ] Config changes documented  
- [ ] Names are descriptive and consistent  

### UI

- [ ] Sound plays when expected  
- [ ] No JS errors in NUI console  

---

# 8. Coding Style Guide

## 8.1 Lua

- Use descriptive names  
- Keep functions small and focused  
- Use `local` for all internal variables  
- Use `require('path.to.module')` for internal modules  
- Prefer early returns  
- Keep logic modular  

## 8.2 Config

- Keep `config.lua` as the single source of truth  
- Avoid hardcoding values in scripts  

## 8.3 Server

- Use `lib.callback.register` for request/response flows  
- Validate everything from the client  
- Keep DB access in `server.lua`  

## 8.4 UI / JS

- Keep `web/script.js` minimal  
- Communicate with Lua via `SendNUIMessage` and `window.postMessage`  
- Keep UI logic modular  

---

# 9. Reporting Issues

When opening an issue, include:

- Description of the problem  
- Steps to reproduce  
- Expected vs actual behavior  
- Relevant logs (server console, F8)  
- Whether QBCore is used  
- Any config changes you made  

---

# 10. Submitting Pull Requests

A good PR should:

- Have a clear, descriptive title  
- Explain what was changed and why  
- Mention any config changes  
- Include screenshots or short clips for UI/visual changes  
- Reference related issues if applicable  

Maintainers may request changes before merging.

---

# 11. Code of Conduct

By contributing, you agree to:

- Be respectful and constructive  
- Avoid harassment or discrimination  
- Collaborate in good faith  
- Keep discussions technical and solution-oriented  
- Accept feedback and be open to revisions  

Harassment, hate speech, or abusive behavior will not be tolerated.

---

# 12. License

By submitting a contribution, you agree that your work will be licensed under the same license as this project.

---

Thank you for helping improve **popcornrp-customs**!
