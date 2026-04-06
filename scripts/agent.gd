extends CharacterBody3D
class_name Agent

# Agent 通用行為腳本
# 每個 Agent 化身都會有此腳本

signal state_changed(new_state: String)
signal command_received(command: String, args: Dictionary)
signal interaction_started()
signal interaction_ended()

# Agent 基本屬性
@export var agent_name: String = "Agent"
@export var agent_emoji: String = "🤖"
@export var agent_color: Color = Color(1.0, 1.0, 1.0)
@export var agent_role: String = "Assistant"

# 狀態機
enum State { IDLE, WALKING, TALKING, WORKING, WAITING }
var current_state: State = State.IDLE

# 屬性
var speed: float = 3.0
var float_amplitude: float = 0.1
var float_speed: float = 2.0

# 動畫參考
var body_mesh: MeshInstance3D = null
var head_mesh: MeshInstance3D = null
var name_label: Label3D = null
var chat_bubble: Node3D = null

# AI 數據
var tasks: Array = []
var current_task: String = ""
var task_progress: float = 0.0
var status_message: String = ""

# 互動
var is_interactable: bool = true
var interaction_range: float = 3.0
var last_interaction_time: float = 0.0

func _ready():
    _setup_visuals()
    _setup_name_label()
    _setup_chat_bubble()
    
    print("🤖 Agent %s 已就緒" % agent_name)

func _setup_visuals():
    # 確保有 MeshInstance3D
    body_mesh = get_node_or_null("Body")
    if not body_mesh and has_node("Body"):
        body_mesh = get_node("Body")
    
    # 設置預設顏色（如果還沒設置）
    if body_mesh and body_mesh.material:
        var mat = body_mesh.material as StandardMaterial3D
        if mat:
            mat.albedo_color = agent_color
            mat.emission = agent_color
            mat.emission_energy_multiplier = 0.4

func _setup_name_label():
    # 查找名稱標籤
    if has_node("NameLabel"):
        name_label = get_node("NameLabel")
        _update_name_label()

func _setup_chat_bubble():
    # 查找對話泡泡
    if has_node("ChatBubble"):
        chat_bubble = get_node("ChatBubble")
        chat_bubble.visible = false

func _update_name_label():
    if name_label:
        name_label.text = "%s %s" % [agent_emoji, agent_name]
        if name_label is Label3D:
            name_label.modulate = agent_color

func _process(delta: float):
    # 漂浮動畫
    _apply_float_animation(delta)
    
    # 狀態更新
    _update_state(delta)

func _apply_float_animation(delta: float):
    if current_state == State.WALKING:
        return  # 走路時不漂浮
    
    var time = Time.get_ticks_msec() / 1000.0
    var offset = sin(time * float_speed + agent_name.hash()) * float_amplitude
    position.y = offset

func _update_state(delta: float):
    match current_state:
        State.IDLE:
            _state_idle(delta)
        State.WALKING:
            _state_walking(delta)
        State.TALKING:
            _state_talking(delta)
        State.WORKING:
            _state_working(delta)
        State.WAITING:
            _state_waiting(delta)

func _state_idle(delta: float):
    # 待機狀態：微微漂浮
    pass

func _state_walking(delta: float):
    # 走路狀態：移動到目標
    pass

func _state_talking(delta: float):
    # 對話狀態：顯示泡泡
    pass

func _state_working(delta: float):
    # 工作狀態：顯示工作動畫
    if body_mesh:
        var time = Time.get_ticks_msec() / 1000.0
        rotation.y = sin(time * 2) * 0.1

func _state_waiting(delta: float):
    # 等待狀態：等待指令
    pass

# ===== 公開方法 =====

func set_state(new_state: State):
    if current_state == new_state:
        return
    
    current_state = new_state
    emit_signal("state_changed", State.keys()[new_state])

func receive_command(command: String, args: Dictionary = {}):
    emit_signal("command_received", command, args)
    
    match command:
        "status":
            _show_status()
        "task":
            _show_task()
        "report":
            _generate_report()
        "assign":
            _assign_task(args.get("task", ""))
        "priority":
            _set_priority(args.get("priority", 0))
        "stop":
            _stop_work()
        "restart":
            _restart()
        _:
            _handle_custom_command(command, args)

func _show_status():
    var status = "🟢 %s - %s" % [agent_name, agent_role]
    if current_task != "":
        status += "\n任務：%s" % current_task
    _show_chat(status)

func _show_task():
    if tasks.size() == 0:
        _show_chat("目前沒有分配的任務")
    else:
        var task_list = "📋 任務列表：\n"
        for i in range(tasks.size()):
            task_list += "• %s\n" % tasks[i]
        _show_chat(task_list)

func _generate_report():
    var report = "📊 %s 進度報告\n\n" % agent_name
    report += "狀態：%s\n" % State.keys()[current_state]
    report += "角色：%s\n" % agent_role
    if current_task != "":
        report += "當前任務：%s\n" % current_task
        report += "進度：%d%%\n" % int(task_progress * 100)
    report += "\n✅ 系統正常運作"
    _show_chat(report)

func _assign_task(task_name: String):
    if task_name == "":
        _show_chat("請指定任務內容")
        return
    
    current_task = task_name
    task_progress = 0.0
    set_state(State.WORKING)
    _show_chat("✓ 已接收任務：%s" % task_name)

func _set_priority(priority: int):
    _show_chat("優先權已設定為：%d" % priority)

func _stop_work():
    current_task = ""
    task_progress = 0.0
    set_state(State.IDLE)
    _show_chat("⏹ 已停止工作")

func _restart():
    current_task = ""
    task_progress = 0.0
    set_state(State.IDLE)
    _show_chat("🔄 已重新開始")

func _handle_custom_command(command: String, args: Dictionary):
    # 處理自定義命令
    _show_chat("收到命令：%s" % command)

# ===== 對話系統 =====

func _show_chat(text: String, duration: float = 3.0):
    if not chat_bubble:
        return
    
    # 找到 Label 節點
    var label = chat_bubble.get_node_or_null("Label")
    if label and label is Label3D:
        label.text = text
    
    chat_bubble.visible = true
    chat_bubble.rotation.y = 0  # 朝向玩家
    
    # 自動隱藏
    await get_tree().create_timer(duration).timeout
    chat_bubble.visible = false

func hide_chat():
    if chat_bubble:
        chat_bubble.visible = false

# ===== 互動系統 =====

func can_interact() -> bool:
    return is_interactable

func get_interaction_position() -> Vector3:
    return global_position

func start_interaction():
    emit_signal("interaction_started")
    set_state(State.TALKING)

func end_interaction():
    emit_signal("interaction_ended")
    if current_state == State.TALKING:
        set_state(State.IDLE)
    hide_chat()
