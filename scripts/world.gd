extends Node3D

# OpenClaw Metaverse - Main World
# 3D 多代理元宇宙主場景
# 包含：玩家控制、房間傳送、對話泡泡、AI 行為

const AGENTS = [
    {"name": "Peter", "emoji": "🤖", "color": Color(1.0, 0.2, 0.2), "role": "System Leader", "tasks": ["管理團隊", "分配任務"]},
    {"name": "Lucas", "emoji": "📝", "color": Color(0.2, 0.8, 0.2), "role": "PM", "tasks": ["寫 GDD", "追蹤進度"]},
    {"name": "David", "emoji": "🎯", "color": Color(0.2, 0.4, 1.0), "role": "Analyst", "tasks": ["市場分析", "需求研究"]},
    {"name": "Eva", "emoji": "🎨", "color": Color(1.0, 0.8, 0.2), "role": "Art Director", "tasks": ["UI 設計", "3D 素材"]},
    {"name": "Jackson", "emoji": "⚡", "color": Color(0.8, 0.2, 1.0), "role": "Developer", "tasks": ["寫代碼", "修復 Bug"]},
    {"name": "Nora", "emoji": "🔧", "color": Color(0.2, 1.0, 0.8), "role": "Tester", "tasks": ["測試功能", "回報問題"]},
]

const ROOMS = [
    {"name": "Lobby", "emoji": "🏢", "pos": Vector3(0, 0, 0), "desc": "Welcome Hall", "color": Color(0.3, 0.5, 1.0)},
    {"name": "Document", "emoji": "📄", "pos": Vector3(20, 0, 0), "desc": "Document Center", "color": Color(0.2, 0.8, 0.5)},
    {"name": "Images", "emoji": "🖼️", "pos": Vector3(-20, 0, 0), "desc": "Image Studio", "color": Color(1.0, 0.5, 0.2)},
    {"name": "Memory", "emoji": "🧠", "pos": Vector3(0, 0, 20), "desc": "Memory Bank", "color": Color(0.5, 0.2, 1.0)},
    {"name": "Skills", "emoji": "⚡", "pos": Vector3(0, 0, -20), "desc": "Skills Forge", "color": Color(1.0, 0.8, 0.0)},
    {"name": "Gateway", "emoji": "🔗", "pos": Vector3(14, 0, 14), "desc": "API Gateway", "color": Color(0.2, 1.0, 0.2)},
    {"name": "Log", "emoji": "📋", "pos": Vector3(-14, 0, 14), "desc": "Log Center", "color": Color(0.8, 0.2, 0.2)},
    {"name": "MCP", "emoji": "🔧", "pos": Vector3(14, 0, -14), "desc": "MCP Services", "color": Color(0.2, 0.8, 0.8)},
    {"name": "Schedule", "emoji": "⏰", "pos": Vector3(-14, 0, -14), "desc": "Schedule Hub", "color": Color(0.8, 0.4, 0.2)},
]

# 玩家控制
var player: CharacterBody3D
var camera: Camera3D
var player_speed: float = 8.0
var mouse_sensitivity: float = 0.003
var velocity: Vector3 = Vector3.ZERO
var gravity: float = -20.0
var is_floating: bool = true  # 3D 世界不需要重力

# 對話系統
var chat_bubbles: Dictionary = {}
var current_room: String = "Lobby"

# AI 行為
var agent_data: Dictionary = {}
var agent_animations: Dictionary = {}

func _ready():
    print("🚀 OpenClaw Metaverse 啟動！")
    _setup_environment()
    _create_ground()
    _create_central_platform()
    _create_rooms()
    _create_agents()
    _setup_lighting()
    _setup_player()
    print("✅ 世界建設完成！")
    print("📍 目前位置：大廳 (Lobby)")

func _setup_environment():
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.02, 0.01, 0.05)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.15, 0.15, 0.25)
    env.tonemap_mode = Environment.TONE_MAPPER_ACES
    env.glow_enabled = true
    env.glow_intensity = 0.6
    env.glow_bloom = 0.15
    env.fog_enabled = true
    env.fog_light_color = Color(0.1, 0.05, 0.2)
    env.fog_density = 0.01
    
    var world_env = WorldEnvironment.new()
    world_env.environment = env
    add_child(world_env)

func _create_ground():
    # 主地面
    var ground = MeshInstance3D.new()
    var ground_mesh = PlaneMesh.new()
    ground_mesh.size = Vector2(200, 200)
    ground.mesh = ground_mesh
    ground.position.y = -0.1
    
    var ground_mat = StandardMaterial3D.new()
    ground_mat.albedo_color = Color(0.06, 0.04, 0.12)
    ground_mat.roughness = 0.9
    ground.material = ground_mat
    add_child(ground)
    
    # 網格線
    var grid = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(200, 0.02, 200)
    grid.mesh = box
    grid.position.y = -0.01
    
    var grid_mat = StandardMaterial3D.new()
    grid_mat.albedo_color = Color(0.15, 0.1, 0.3)
    grid_mat.emission_enabled = true
    grid_mat.emission = Color(0.1, 0.05, 0.2)
    grid_mat.emission_energy_multiplier = 0.2
    grid.material = grid_mat
    add_child(grid)

func _create_central_platform():
    # 中央平台
    var platform = MeshInstance3D.new()
    var cylinder = CylinderMesh.new()
    cylinder.top_radius = 5.0
    cylinder.bottom_radius = 6.0
    cylinder.height = 0.5
    platform.mesh = cylinder
    platform.position.y = 0.25
    
    var plat_mat = StandardMaterial3D.new()
    plat_mat.albedo_color = Color(0.1, 0.08, 0.2)
    plat_mat.metallic = 0.3
    plat_mat.roughness = 0.7
    plat_mat.emission_enabled = true
    plat_mat.emission = Color(0.3, 0.2, 0.8)
    plat_mat.emission_energy_multiplier = 0.15
    platform.material = plat_mat
    add_child(platform)
    
    # OpenClaw 標誌
    var label = Label3D.new()
    label.text = "🏠 OpenClaw Hub"
    label.position = Vector3(0, 2.5, 0)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.pixel_size = 0.025
    label.modulate = Color(0.8, 0.8, 1.0)
    label.font_size = 64
    add_child(label)
    
    # 圓環光環（3層）
    for i in range(3):
        var ring = MeshInstance3D.new()
        var torus = TorusMesh.new()
        torus.inner_radius = 6 + i * 2.5
        torus.outer_radius = 6.3 + i * 2.5
        torus.rings = 64
        ring.mesh = torus
        ring.position.y = 0.1
        ring.rotation.x = PI / 2
        
        var ring_mat = StandardMaterial3D.new()
        var hue = 0.75 - i * 0.05
        ring_mat.albedo_color = Color.from_hsv(hue, 0.7, 0.5)
        ring_mat.emission_enabled = true
        ring_mat.emission = Color.from_hsv(hue, 0.8, 0.4)
        ring_mat.emission_energy_multiplier = 0.4 - i * 0.1
        ring.material = ring_mat
        ring.set("ring_index", i)  # 用於動畫
        add_child(ring)

func _create_rooms():
    for room in ROOMS:
        var room_pos = room["pos"]
        var room_color = room["color"]
        
        # 路徑地板（連接到中央平台）
        var path_mesh = MeshInstance3D.new()
        var path_box = BoxMesh.new()
        path_box.size = Vector3(2, 0.1, room_pos.length() - 8)
        path_mesh.mesh = path_box
        path_mesh.position = room_pos.normalized() * (room_pos.length() / 2 + 5)
        path_mesh.position.y = -0.05
        if room_pos.x != 0:
            path_mesh.rotation.y = PI / 2
        var path_mat = StandardMaterial3D.new()
        path_mat.albedo_color = Color(0.08, 0.06, 0.15)
        path_mat.emission_enabled = true
        path_mat.emission = room_color * 0.1
        path_mat.emission_energy_multiplier = 0.1
        path_mesh.material = path_mat
        add_child(path_mesh)
        
        # 房間地板
        var floor = MeshInstance3D.new()
        var floor_mesh = BoxMesh.new()
        floor_mesh.size = Vector3(10, 0.3, 10)
        floor.mesh = floor_mesh
        floor.position = room_pos + Vector3(0, 0.15, 0)
        
        var floor_mat = StandardMaterial3D.new()
        floor_mat.albedo_color = Color(0.08, 0.06, 0.15)
        floor_mat.emission_enabled = true
        floor_mat.emission = room_color * 0.15
        floor_mat.emission_energy_multiplier = 0.1
        floor.material = floor_mat
        add_child(floor)
        
        # 房間邊框發光
        var border = MeshInstance3D.new()
        var border_mesh = BoxMesh.new()
        border_mesh.size = Vector3(10.5, 0.1, 10.5)
        border.mesh = border_mesh
        border.position = room_pos + Vector3(0, 0.35, 0)
        
        var border_mat = StandardMaterial3D.new()
        border_mat.albedo_color = room_color * 0.3
        border_mat.emission_enabled = true
        border_mat.emission = room_color
        border_mat.emission_energy_multiplier = 0.3
        border.material = border_mat
        add_child(border)
        
        # 房間標誌柱
        var pillar_base = MeshInstance3D.new()
        var pillar_base_mesh = CylinderMesh.new()
        pillar_base_mesh.top_radius = 0.8
        pillar_base_mesh.bottom_radius = 1.0
        pillar_base_mesh.height = 0.3
        pillar_base.mesh = pillar_base_mesh
        pillar_base.position = room_pos + Vector3(0, 0.45, 0)
        
        var pillar_base_mat = StandardMaterial3D.new()
        pillar_base_mat.albedo_color = room_color * 0.5
        pillar_base_mat.emission_enabled = true
        pillar_base_mat.emission = room_color
        pillar_base_mat.emission_energy_multiplier = 0.2
        pillar_base.material = pillar_base_mat
        add_child(pillar_base)
        
        var pillar = MeshInstance3D.new()
        var pillar_mesh = CylinderMesh.new()
        pillar_mesh.top_radius = 0.4
        pillar_mesh.bottom_radius = 0.8
        pillar_mesh.height = 4
        pillar.mesh = pillar_mesh
        pillar.position = room_pos + Vector3(0, 2.5, 0)
        
        var pillar_mat = StandardMaterial3D.new()
        pillar_mat.albedo_color = Color(0.15, 0.1, 0.25)
        pillar.material = pillar_mat
        add_child(pillar)
        
        # 頂部發光球
        var orb = MeshInstance3D.new()
        var orb_mesh = SphereMesh.new()
        orb_mesh.radius = 0.5
        orb_mesh.height = 1.0
        orb.mesh = orb_mesh
        orb.position = room_pos + Vector3(0, 5, 0)
        
        var orb_mat = StandardMaterial3D.new()
        orb_mat.albedo_color = room_color
        orb_mat.emission_enabled = true
        orb_mat.emission = room_color
        orb_mat.emission_energy_multiplier = 0.8
        orb.material = orb_mat
        add_child(orb)
        
        # 房間名稱
        var room_label = Label3D.new()
        room_label.text = room["emoji"] + " " + room["name"]
        room_label.position = room_pos + Vector3(0, 6, 0)
        room_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        room_label.pixel_size = 0.02
        room_label.modulate = Color(1.0, 0.95, 0.9)
        room_label.font_size = 48
        add_child(room_label)
        
        # 房間描述
        var desc_label = Label3D.new()
        desc_label.text = room["desc"]
        desc_label.position = room_pos + Vector3(0, 5.3, 0)
        desc_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        desc_label.pixel_size = 0.012
        desc_label.modulate = Color(0.7, 0.7, 0.7)
        desc_label.font_size = 28
        add_child(desc_label)

func _create_agents():
    for i in range(AGENTS.size()):
        var data = AGENTS[i]
        var angle = i * (2 * PI / AGENTS.size())
        var radius = 12.0
        var base_pos = Vector3(cos(angle) * radius, 0.8, sin(angle) * radius)
        
        # Agent 化身
        var agent = CharacterBody3D.new()
        agent.position = base_pos
        agent.name = data["name"]
        
        # 膠囊碰撞
        var collision = CollisionShape3D.new()
        var shape = CapsuleShape3D.new()
        shape.radius = 0.4
        shape.height = 1.2
        collision.shape = shape
        collision.position = Vector3(0, 0.8, 0)
        agent.add_child(collision)
        
        # 化身本體
        var body = MeshInstance3D.new()
        var body_mesh = CapsuleMesh.new()
        body_mesh.radius = 0.35
        body_mesh.height = 1.0
        body.mesh = body_mesh
        body.position = Vector3(0, 0.8, 0)
        
        var mat = StandardMaterial3D.new()
        mat.albedo_color = data["color"]
        mat.metallic = 0.2
        mat.roughness = 0.8
        mat.emission_enabled = true
        mat.emission = data["color"]
        mat.emission_energy_multiplier = 0.4
        body.material = mat
        agent.add_child(body)
        
        # 頭部
        var head = MeshInstance3D.new()
        var head_mesh = SphereMesh.new()
        head_mesh.radius = 0.3
        head_mesh.height = 0.6
        head.mesh = head_mesh
        head.position = Vector3(0, 1.7, 0)
        head.material = mat
        agent.add_child(head)
        
        # 眼睛發光
        var eye_l = MeshInstance3D.new()
        var eye_r = MeshInstance3D.new()
        var eye_mesh = SphereMesh.new()
        eye_mesh.radius = 0.08
        eye_l.mesh = eye_mesh
        eye_r.mesh = eye_mesh
        eye_l.position = Vector3(-0.12, 1.75, 0.25)
        eye_r.position = Vector3(0.12, 1.75, 0.25)
        
        var eye_mat = StandardMaterial3D.new()
        eye_mat.albedo_color = Color.WHITE
        eye_mat.emission_enabled = true
        eye_mat.emission = Color.WHITE
        eye_mat.emission_energy_multiplier = 2.0
        eye_l.material = eye_mat
        eye_r.material = eye_mat
        agent.add_child(eye_l)
        agent.add_child(eye_r)
        
        add_child(agent)
        
        # 存儲 Agent 數據
        agent_data[data["name"]] = {
            "node": agent,
            "base_pos": base_pos,
            "target_pos": base_pos,
            "color": data["color"],
            "emoji": data["emoji"],
            "role": data["role"],
            "tasks": data["tasks"],
            "state": "idle",  # idle, walking, talking, working
            "talk_timer": randf() * 5.0,
            "walk_timer": randf() * 8.0
        }
        
        # 名字標籤（跟著 Agent 移動）
        var name_label = Label3D.new()
        name_label.text = data["emoji"] + " " + data["name"]
        name_label.position = Vector3(0, 2.5, 0)
        name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        name_label.pixel_size = 0.008
        name_label.modulate = data["color"]
        name_label.font_size = 20
        name_label.name = "NameLabel"
        agent.add_child(name_label)
        
        # 對話泡泡（預設隱藏）
        var chat_bubble = _create_chat_bubble()
        chat_bubble.position = Vector3(0, 2.8, 0)
        chat_bubble.visible = false
        chat_bubble.name = "ChatBubble"
        agent.add_child(chat_bubble)

func _create_chat_bubble() -> Node3D:
    var bubble = Node3D.new()
    
    # 泡泡背景
    var bg = MeshInstance3D.new()
    var bg_mesh = BoxMesh.new()
    bg_mesh.size = Vector3(2.0, 0.6, 0.1)
    bg.mesh = bg_mesh
    bg.position.z = 0.1
    
    var bg_mat = StandardMaterial3D.new()
    bg_mat.albedo_color = Color(1.0, 1.0, 0.9)
    bg_mat.emission_enabled = true
    bg_mat.emission = Color(0.3, 0.3, 0.2)
    bg_mat.emission_energy_multiplier = 0.1
    bg.material = bg_mat
    bubble.add_child(bg)
    
    # 泡泡文字
    var label = Label3D.new()
    label.text = "Hello!"
    label.position = Vector3(0, 0.1, 0.2)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.pixel_size = 0.006
    label.modulate = Color(0.1, 0.1, 0.1)
    label.font_size = 16
    label.name = "Label"
    bubble.add_child(label)
    
    return bubble

func _setup_lighting():
    # 主光源
    var main_light = DirectionalLight3D.new()
    main_light.rotation_degrees = Vector3(-45, 30, 0)
    main_light.light_energy = 0.8
    main_light.shadow_enabled = true
    main_light.light_color = Color(0.9, 0.85, 1.0)
    add_child(main_light)
    
    # 補光
    var fill_light = DirectionalLight3D.new()
    fill_light.rotation_degrees = Vector3(45, -120, 0)
    fill_light.light_energy = 0.3
    fill_light.light_color = Color(0.7, 0.7, 1.0)
    add_child(fill_light)
    
    # 環境光
    var ambient = OmniLight3D.new()
    ambient.position = Vector3(0, 15, 0)
    ambient.light_energy = 0.3
    ambient.omni_range = 80
    ambient.light_color = Color(0.5, 0.4, 0.8)
    add_child(ambient)

func _setup_player():
    # 創建玩家
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 1.6, 8)  # 起始位置（大廳邊緣）
    
    # 碰撞
    var collision = CollisionShape3D.new()
    var shape = CapsuleShape3D.new()
    shape.radius = 0.4
    shape.height = 1.2
    collision.shape = shape
    collision.position = Vector3(0, 0.8, 0)
    player.add_child(collision)
    
    # 玩家本體
    var body = MeshInstance3D.new()
    var body_mesh = CapsuleMesh.new()
    body_mesh.radius = 0.35
    body_mesh.height = 1.0
    body.mesh = body_mesh
    body.position = Vector3(0, 0.8, 0)
    
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.3, 0.9, 1.0)  # 青色代表玩家
    mat.metallic = 0.5
    mat.roughness = 0.3
    mat.emission_enabled = true
    mat.emission = Color(0.2, 0.8, 1.0)
    mat.emission_energy_multiplier = 0.5
    body.material = mat
    body.name = "Body"
    player.add_child(body)
    
    # 攝影機
    camera = Camera3D.new()
    camera.position = Vector3(0, 1.6, 0)
    camera.fov = 70
    camera.name = "Camera"
    player.add_child(camera)
    
    # 攝影機支架（用於視角控制）
    var camera_pivot = Node3D.new()
    camera_pivot.name = "CameraPivot"
    camera_pivot.position = Vector3(0, 1.4, 0)
    camera.position = Vector3(0, 0, 0)
    camera_pivot.add_child(camera)
    player.add_child(camera_pivot)
    
    add_child(player)
    
    # 隱藏滑鼠
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        var mouse_event = event as InputEventMouseMotion
        # 旋轉玩家（左右）
        player.rotate_y(-mouse_event.relative.x * mouse_sensitivity)
        # 旋轉攝影機（上下）
        var camera_pivot = player.get_node("CameraPivot")
        camera_pivot.rotate_x(-mouse_event.relative.y * mouse_sensitivity)
        # 限制上下旋轉角度
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/3, PI/3)

func _process(delta: float):
    var time = Time.get_ticks_msec() / 1000.0
    
    # ===== 玩家移動 =====
    _handle_player_movement(delta)
    
    # ===== 光環動畫 =====
    _animate_rings(delta)
    
    # ===== Agent AI 行為 =====
    _update_agent_ai(delta)
    
    # ===== 房間傳送檢測 =====
    _check_room_teleport()

func _handle_player_movement(delta: float):
    var input_dir = Vector3.ZERO
    
    # 獲取向前和向右方向（考慮玩家視角）
    var forward = -player.global_transform.basis.z
    var right = player.global_transform.basis.x
    forward.y = 0
    right.y = 0
    forward = forward.normalized()
    right = right.normalized()
    
    if Input.is_action_pressed("move_forward"):
        input_dir += forward
    if Input.is_action_pressed("move_backward"):
        input_dir -= forward
    if Input.is_action_pressed("move_left"):
        input_dir -= right
    if Input.is_action_pressed("move_right"):
        input_dir += right
    
    if input_dir.length() > 0:
        input_dir = input_dir.normalized()
        player.position += input_dir * player_speed * delta
        # 更新面向方向
        player.look_at(player.position + input_dir, Vector3.UP)
    
    # 保持在地面上（浮動模式）
    player.position.y = 1.6

func _animate_rings(delta: float):
    var time = Time.get_ticks_msec() / 1000.0
    for ring in get_children():
        if ring is MeshInstance3D and ring.mesh is TorusMesh:
            var idx = ring.get("ring_index")
            if idx != null:
                ring.rotation.y += delta * (0.2 - idx * 0.05)
                ring.position.y = 0.1 + sin(time * 2 + idx) * 0.05

func _update_agent_ai(delta: float):
    var time = Time.get_ticks_msec() / 1000.0
    
    for name in agent_data:
        var data = agent_data[name]
        var agent = data["node"]
        var state = data["state"]
        
        # 計時器
        data["walk_timer"] -= delta
        data["talk_timer"] -= delta
        
        # 狀態機
        match state:
            "idle":
                # 待機：微微漂浮
                var base_y = data["base_pos"].y
                agent.position.y = base_y + sin(time * 2 + name.hash()) * 0.1
                
                # 隨機移動
                if data["walk_timer"] <= 0:
                    if randf() < 0.3:
                        # 開始走路
                        data["state"] = "walking"
                        var offset = Vector3(
                            randf_range(-2, 2),
                            0,
                            randf_range(-2, 2)
                        )
                        data["target_pos"] = data["base_pos"] + offset
                        data["walk_timer"] = randf_range(2, 5)
                    else:
                        data["walk_timer"] = randf_range(3, 8)
                
                # 隨機對話
                if data["talk_timer"] <= 0:
                    if randf() < 0.4:
                        _agent_speak(name, _get_random_dialogue(name))
                        data["talk_timer"] = randf_range(8, 15)
                    else:
                        data["talk_timer"] = randf_range(5, 10)
            
            "walking":
                # 走路：移動到目標位置
                var dir = (data["target_pos"] - agent.position)
                dir.y = 0
                if dir.length() > 0.1:
                    dir = dir.normalized()
                    agent.position += dir * 3.0 * delta
                    # 面向移動方向
                    agent.look_at(agent.position + dir, Vector3.UP)
                    # 漂浮動畫
                    agent.position.y = data["base_pos"].y + sin(time * 4) * 0.1
                else:
                    data["state"] = "idle"
                    data["walk_timer"] = randf_range(2, 5)
            
            "talking":
                # 對話中：保持不動
                agent.position.y = data["base_pos"].y + sin(time * 2) * 0.1
                # 對話結束後
                if data["talk_timer"] <= 0:
                    _agent_stop_talking(name)
                    data["state"] = "idle"
                    data["walk_timer"] = randf_range(3, 6)
            
            "working":
                # 工作中：左右搖擺
                agent.position.y = data["base_pos"].y + sin(time * 3) * 0.15
                agent.rotation.y = sin(time * 2) * 0.1
                # 工作結束
                if data["walk_timer"] <= 0:
                    data["state"] = "idle"
                    data["walk_timer"] = randf_range(5, 10)

func _agent_speak(agent_name: String, text: String):
    var data = agent_data.get(agent_name)
    if not data:
        return
    
    var agent = data["node"]
    var chat_bubble = agent.get_node_or_null("ChatBubble")
    if chat_bubble:
        var label = chat_bubble.get_node_or_null("Label")
        if label:
            label.text = text
        chat_bubble.visible = true
        chat_bubble.rotation.y = player.rotation.y  # 朝向玩家
    
    data["state"] = "talking"
    data["talk_timer"] = randf_range(2, 4)
    
    print("💬 " + agent_name + ": " + text)

func _agent_stop_talking(agent_name: String):
    var data = agent_data.get(agent_name)
    if not data:
        return
    
    var agent = data["node"]
    var chat_bubble = agent.get_node_or_null("ChatBubble")
    if chat_bubble:
        chat_bubble.visible = false

func _get_random_dialogue(agent_name: String) -> String:
    var dialogues = {
        "Peter": ["持續推進！", "下一個任務是什麼？", "團隊狀態良好。", "讓事情被完成。💪", "專案進度如何了？"],
        "Lucas": ["GDD 更新了。", "我在追蹤進度。", "文件都整理好了。", "隨時可以報告。📝"],
        "David": ["市場分析完成。", "有新想法。", "數據看起來不錯。", "🎯 分析中..."],
        "Eva": ["素材準備好了。", "新設計圖完成了。", "🎨 UI 很漂亮！"],
        "Jackson": ["代碼寫完了。", "正在 debug。", "⚡ 功能實作中..."],
        "Nora": ["測試通過。", "發現一個 bug。", "🔧 準備測試報告。"]
    }
    var agent_dialogues = dialogues.get(agent_name, ["..."])
    return agent_dialogues[randi() % agent_dialogues.size()]

func _check_room_teleport():
    var player_pos = player.position
    
    # 檢查每個房間
    for room in ROOMS:
        var room_pos = room["pos"]
        var distance = Vector2(player_pos.x - room_pos.x, player_pos.z - room_pos.z).length()
        
        # 如果靠近房間
        if distance < 5:
            if current_room != room["name"]:
                current_room = room["name"]
                print("📍 進入房間：" + room["emoji"] + " " + room["name"])
                # 可以在這裡載入房間內容
        
        # 如果在房間中央（傳送觸發）
        if distance < 2:
            # 顯示房間功能表（預留）
            pass

func _unhandled_input(event: InputEvent):
    # ESC 釋放滑鼠
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    # 空白鍵：和 Agent 互動
    if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
        _interact_with_nearest_agent()

func _interact_with_nearest_agent():
    var nearest_agent = null
    var nearest_distance = INF
    var nearest_name = ""
    
    for name in agent_data:
        var data = agent_data[name]
        var agent = data["node"]
        var dist = player.position.distance_to(agent.position)
        if dist < nearest_distance:
            nearest_distance = dist
            nearest_agent = agent
            nearest_name = name
    
    if nearest_agent and nearest_distance < 5:
        var data = agent_data[nearest_name]
        var tasks = data["tasks"]
        var task_text = tasks[randi() % tasks.size()] if tasks.size() > 0 else "工作中"
        
        _agent_speak(nearest_name, "我在 " + task_text + "！")
        data["state"] = "working"
        data["walk_timer"] = randf_range(3, 6)
        
        print("🤝 和 " + nearest_name + " 互動")
