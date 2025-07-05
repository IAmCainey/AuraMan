# AuraMan - Multi-Class Cooldown Tracker

A comprehensive cooldown tracking addon for Classic World of Warcraft (1.12.1), specifically designed for Turtle WoW. AuraMan provides a clean, persistent HUD that displays all your important class abilities and their cooldown statuses at a glance.

## Features

### 🎯 **Persistent HUD Display**
- Clean, grid-based layout showing all learned abilities
- Icons turn gray when on cooldown, green when ready
- Real-time cooldown timers with smart formatting (seconds, minutes, hours)
- Only shows abilities you have actually learned (no clutter from unlearned spells)

### 🎮 **Interactive Interface**
- **Movable HUD**: Hold Shift and drag to reposition anywhere on screen
- **Scalable**: Toggle between different HUD sizes (0.5x, 0.8x, 1.0x, 1.2x)
- **Adjustable Opacity**: Change background transparency (0%, 30%, 50%, 70%)
- **Customizable Layout**: Adjust icon size and icons per row
- **Hide/Show Toggle**: Quickly hide the HUD when not needed

### 🔧 **Smart Configuration**
- Automatic position and settings saving
- Robust error handling for corrupted settings
- Safe defaults for all configuration options
- Persistent settings across game sessions

### 🏆 **Multi-Class Support**
Tracks important cooldowns for all Classic WoW classes:

- **Rogue**: Stealth, Vanish, Kidney Shot, Cold Blood, Preparation, Evasion, Sprint, Blind, Thistle Tea
- **Warrior**: Shield Wall, Last Stand, Bloodthirst, Whirlwind, Intimidating Shout, Recklessness, Retaliation
- **Mage**: Counterspell, Blink, Ice Block, Presence of Mind, Evocation, Combustion, Cold Snap
- **Priest**: Psychic Scream, Fade, Inner Fire, Power Word: Shield, Fear Ward, Desperate Prayer
- **Paladin**: Lay on Hands, Divine Protection, Consecration, Hammer of Justice, Divine Favor, Forbearance
- **Hunter**: Rapid Fire, Deterrence, Freezing Trap, Concussive Shot, Bestial Wrath, Intimidation
- **Warlock**: Death Coil, Howl of Terror, Shadow Ward, Amplify Curse, Soul Burn, Conflagrate
- **Druid**: Bash, Frenzied Regeneration, Barkskin, Nature's Swiftness, Innervate, Swiftmend
- **Shaman**: Earth Elemental Totem, Fire Elemental Totem, Grounding Totem, Nature's Swiftness, Elemental Mastery, Stormstrike

## Installation

1. Download the addon files
2. Extract to your `World of Warcraft/Interface/AddOns/` directory
3. Ensure the folder is named `AuraMan`
4. Restart World of Warcraft or reload UI (`/reload`)
5. The HUD will appear automatically when you log in

## Usage

### Basic Operation
- The HUD automatically appears when you log in
- Icons show green when abilities are ready
- Icons turn gray with countdown timers when on cooldown
- Only learned abilities are displayed (unlearned abilities are hidden)

### Commands

| Command | Description |
|---------|-------------|
| `/auraman` or `/am` | Show help and available commands |
| `/auraman toggle` | Enable/disable the cooldown tracker |
| `/auraman reset` | Reset HUD position to center of screen |
| `/auraman scale` | Cycle through HUD scale sizes (1.0x → 0.8x → 0.5x → 1.2x) |
| `/auraman opacity` | Cycle through background opacity levels (30% → 50% → 70% → 0%) |
| `/auraman hide` | Toggle HUD visibility |
| `/auraman list` | List all tracked abilities and learning status |

### Moving the HUD
- Hold **Shift** and **left-click drag** the HUD to move it
- Position is automatically saved when you release the mouse
- Use `/auraman reset` to return to center if needed

## Configuration

AuraMan automatically saves your preferences, including:
- HUD position (X, Y coordinates)
- HUD scale (0.5x, 0.8x, 1.0x, or 1.2x)
- Background opacity (0%, 30%, 50%, or 70%)
- Icon size (20-100 pixels)
- Icons per row (1-10)
- Enabled/disabled state

All settings are stored in the `AuraManDB` saved variable and persist across sessions.

## Technical Details

- **Addon Version**: Compatible with Classic WoW 1.12.1
- **Target Server**: Turtle WoW (works on other Classic servers)
- **Memory Usage**: Lightweight, minimal impact on performance
- **Update Frequency**: 0.1 seconds for responsive cooldown tracking
- **Frame Management**: Robust error handling for UI operations

## Troubleshooting

### Common Issues

**HUD not appearing:**
- Make sure the addon is enabled in the character select screen
- Try `/reload` to refresh the UI
- Use `/auraman list` to verify abilities are being tracked

**HUD in wrong position:**
- Use `/auraman reset` to center the HUD
- Hold Shift and drag to reposition

**Missing abilities:**
- Only learned abilities are shown
- Check your spellbook to ensure you have the ability
- Some abilities may be talent-based

**Performance issues:**
- The addon is designed to be lightweight
- If experiencing lag, try `/auraman toggle` to disable temporarily

### Error Recovery
AuraMan includes robust error handling:
- Corrupted settings are automatically reset to safe defaults
- Invalid frame operations are caught and handled gracefully
- Saved variables are validated on load

## Development

### File Structure
```
AuraMan/
├── AuraMan.toc          # Addon metadata
├── main.lua             # Core functionality
├── localization.lua     # Text localization
└── README.md           # This file
```

### Key Features
- **Smart Spell Detection**: Automatically scans spellbook for learned abilities
- **Dynamic HUD**: Icons are created/removed based on learned abilities
- **Safe Operations**: All frame operations include error checking
- **Persistent State**: Settings survive addon reloads and game restarts

## Contributing

This addon is designed for Classic WoW 1.12.1. When adding new features or abilities:
1. Ensure compatibility with the Classic WoW API
2. Test with multiple classes
3. Follow the existing code structure and error handling patterns
4. Update the README with any new features or commands

## License

Free to use and modify. Created for the Classic WoW community.

## Changelog

### Version 1.1
- Added 0.5x scale option for ultra-compact HUD
- Added adjustable background opacity (0%, 30%, 50%, 70%)
- Enhanced slash commands with `/auraman opacity` 
- Improved HUD customization options
- Updated scale cycling: 1.0x → 0.8x → 0.5x → 1.2x → repeat
- All new settings are automatically saved and persist across sessions

### Version 1.0
- Initial release
- Multi-class cooldown tracking
- Persistent HUD with movable interface
- Smart ability detection (learned abilities only)
- Robust error handling and configuration management
- Full slash command support

---

*AuraMan - Track your cooldowns, master your class!*

![Screenshot From 2025-07-05 10-57-50](https://github.com/user-attachments/assets/6dffb861-c79b-4a18-819d-44a86af1e9b4)
![Screenshot From 2025-07-05 10-59-19](https://github.com/user-attachments/assets/b8152a4a-c2a9-40fc-86c0-e7b2945c81e1)
![Screenshot From 2025-07-05 10-59-12](https://github.com/user-attachments/assets/7a0105da-c405-4c2f-9199-150a560f99be)
![Screenshot From 2025-07-05 11-56-37](https://github.com/user-attachments/assets/894e8e5a-7988-4c6f-991a-af7903420647)
![Screenshot From 2025-07-05 11-56-22](https://github.com/user-attachments/assets/ddf864db-cd44-4fd9-b6b3-4bf9d09901c9)
