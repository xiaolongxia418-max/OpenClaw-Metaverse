# 🦞 OpenClaw Metaverse

> 3D Multi-Agent Metaverse built with Godot 4.x

## 🚀 Quick Start

1. Open **Godot 4.x**
2. Click **Import** → select `project.godot`
3. Press **F5** or click **Play**

## 🎮 Controls

| Key | Action |
|-----|--------|
| W / A / S / D | Move |
| Mouse | Look Around |
| Space | Interact with Agent |
| ESC | Release Mouse |

## ✨ Features

### ✅ Implemented
- [x] Central Platform with animated glowing rings
- [x] 6 Agent avatars (Peter, Lucas, David, Eva, Jackson, Nora)
- [x] 9 Room entrances (Lobby, Document, Images, Memory, Skills, Gateway, Log, MCP, Schedule)
- [x] **Player Character** - WASD movement + First-person style camera
- [x] **Room Teleportation** - Walk to room entrances to enter
- [x] **Chat Bubbles** - Agents display random dialogues
- [x] **AI Behaviors** - Agents idle, walk, talk, and work autonomously
- [x] Beautiful lighting, fog, and glow effects
- [x] Grid floor with purple theme
- [x] Floating animations

### ⏳ Coming Soon
- [ ] Room interior scenes
- [ ] Task assignment UI
- [ ] Multiplayer sync
- [ ] Sound effects
- [ ] More agent interactions

## 🏗️ Architecture

```
OpenClaw-Metaverse/
├── project.godot          # Godot project file
├── icon.svg              # Project icon
├── README.md             # This file
├── scenes/
│   └── world.tscn        # Main world scene
├── scripts/
│   └── world.gd          # World script (all logic)
└── resources/
    ├── meshes/           # 3D models (future)
    └── textures/         # Textures (future)
```

## 👥 Agents

| Agent | Emoji | Role | Color | Tasks |
|-------|-------|------|-------|-------|
| Peter | 🤖 | System Leader | 🔴 Red | 管理團隊、分配任務 |
| Lucas | 📝 | PM | 🟢 Green | 寫 GDD、追蹤進度 |
| David | 🎯 | Analyst | 🔵 Blue | 市場分析、需求研究 |
| Eva | 🎨 | Art Director | 🟡 Yellow | UI 設計、3D 素材 |
| Jackson | ⚡ | Developer | 🟣 Purple | 寫代碼、修復 Bug |
| Nora | 🔧 | Tester | 🔵 Cyan | 測試功能、回報問題 |

## 🚪 Rooms

| Room | Emoji | Description |
|------|-------|-------------|
| Lobby | 🏢 | Welcome Hall - Starting area |
| Document | 📄 | Document Center |
| Images | 🖼️ | Image Studio |
| Memory | 🧠 | Memory Bank |
| Skills | ⚡ | Skills Forge |
| Gateway | 🔗 | API Gateway |
| Log | 📋 | Log Center |
| MCP | 🔧 | MCP Services |
| Schedule | ⏰ | Schedule Hub |

## 📜 License

MIT

---

**Built with Godot 4.6.1** 🎮
