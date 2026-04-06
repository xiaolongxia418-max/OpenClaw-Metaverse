extends CanvasLayer

# Boss Command Interface
# Boss 專用指令界面 - 點擊 Agent 彈出指令面板

signal command_sent(agent_name: String, command: String, args: Dictionary)
signal panel_closed()

const PANEL_WIDTH: float = 350.0
const PANEL_HEIGHT: float = 450.0

var is_visible: bool = false
var current_agent: Dictionary = {}
var current_agent_name: String = ""

# UI 節點
var panel: Panel = null
var title_bar: HBoxContainer = null
var agent_info: VBoxContainer = null
var command_list: VBoxContainer = null
var quick_actions: HBoxContainer = null
var status_label: Label = null

# 命令定義
const COMMANDS = {
    "status": {"icon": "[S]", "label": "Status", "color": Color(0.3, 0.8, 0.3)},
    "task": {"icon": "[T]", "label": "Tasks", "color": Color(0.3, 0.5, 0.9)},
    "report": {"icon": "[R]", "label": "Report", "color": Color(0.9, 0.7, 0.2)},
    "assign": {"icon": "[A]", "label": "Assign", "color": Color(0.9, 0.4, 0.4)},
    "priority": {"icon": "[P]", "label": "Priority", "color": Color(0.8, 0.3, 0.8)},
    "stop": {"icon": "[X]", "label": "Stop", "color": Color(0.8, 0.2, 0.2)},
    "restart": {"icon": "[~]", "label": "Restart", "color": Color(0.2, 0.7, 0.9)},
    "help": {"icon": "[?]", "label": "Help", "color": Color(0.6, 0.6, 0.6)}
}

func _ready():
    _create_panel()
    print("👑 Boss UI 已就緒")

func _create_panel():
    # 主面板
    panel = Panel.new()
    panel.name = "BossCommandPanel"
    panel.custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
    panel.set_as_footer()
    panel.visible = false
    
    # 面板樣式
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.05, 0.02, 0.12, 0.98)
    style.border_width_left = 3
    style.border_width_right = 3
    style.border_width_top = 3
    style.border_width_bottom = 3
    style.border_color = Color(0.8, 0.6, 1.0, 0.8)
    style.set_corner_radius_all(12)
    style.content_margin_left = 15
    style.content_margin_right = 15
    style.content_margin_top = 15
    style.content_margin_bottom = 15
    panel.add_theme_stylebox_override("panel", style)
    
    # 標題列
    title_bar = HBoxContainer.new()
    title_bar.name = "TitleBar"
    
    var title_label = Label.new()
    title_label.name = "Title"
    title_label.text = "[BOSS] Command Panel"
    title_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
    title_label.add_theme_font_size_override("font_size", 18)
    
    var spacer = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    var close_btn = Button.new()
    close_btn.name = "CloseButton"
    close_btn.text = "X"
    close_btn.custom_minimum_size = Vector2(35, 35)
    close_btn.pressed.connect(hide_panel)
    
    title_bar.add_child(title_label)
    title_bar.add_child(spacer)
    title_bar.add_child(close_btn)
    panel.add_child(title_bar)
    
    # Separator
    var sep = HSeparator.new()
    sep.custom_minimum_size = Vector2(0, 2)
    var sep_style = StyleBoxFlat.new()
    sep_style.bg_color = Color(0.5, 0.3, 0.8, 0.5)
    sep.add_theme_stylebox_override("separator", sep_style)
    panel.add_child(sep)
    
    # Agent 資訊區
    agent_info = VBoxContainer.new()
    agent_info.name = "AgentInfo"
    agent_info.size_flags_vertical = Control.SIZE_FIXED
    agent_info.custom_minimum_size = Vector2(0, 80)
    
    var agent_name_label = Label.new()
    agent_name_label.name = "AgentName"
    agent_name_label.text = "選擇一個 Agent"
    agent_name_label.add_theme_color_override("font_color", Color(1, 1, 1))
    agent_name_label.add_theme_font_size_override("font_size", 16)
    
    var agent_role_label = Label.new()
    agent_role_label.name = "AgentRole"
    agent_role_label.text = ""
    agent_role_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
    agent_role_label.add_theme_font_size_override("font_size", 12)
    
    agent_info.add_child(agent_name_label)
    agent_info.add_child(agent_role_label)
    panel.add_child(agent_info)
    
    # Separator 2
    var sep2 = HSeparator.new()
    sep2.custom_minimum_size = Vector2(0, 2)
    sep2.add_theme_stylebox_override("separator", sep_style)
    panel.add_child(sep2)
    
    # 指令列表（滾動區域）
    var scroll = ScrollContainer.new()
    scroll.name = "CommandScroll"
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    command_list = VBoxContainer.new()
    command_list.name = "CommandList"
    command_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    command_list.add_theme_constant_override("separation", 8)
    
    scroll.add_child(command_list)
    panel.add_child(scroll)
    
    # Separator 3
    var sep3 = HSeparator.new()
    sep3.custom_minimum_size = Vector2(0, 2)
    sep3.add_theme_stylebox_override("separator", sep_style)
    panel.add_child(sep3)
    
    # 狀態列
    status_label = Label.new()
    status_label.name = "Status"
    status_label.text = "選擇要互動的 Agent"
    status_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
    status_label.add_theme_font_size_override("font_size", 11)
    panel.add_child(status_label)
    
    add_child(panel)
    _populate_commands()

func _populate_commands():
    if not command_list:
        return
    
    # 清空現有命令
    for child in command_list.get_children():
        child.queue_free()
    
    # 添加命令按鈕
    for cmd_name in COMMANDS:
        var cmd = COMMANDS[cmd_name]
        var btn = _create_command_button(cmd_name, cmd)
        command_list.add_child(btn)

func _create_command_button(cmd_name: String, cmd: Dictionary) -> Button:
    var btn = Button.new()
    btn.name = cmd_name
    btn.custom_minimum_size = Vector2(0, 50)
    btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
    
    # 按鈕樣式
    var btn_style = StyleBoxFlat.new()
    btn_style.bg_color = Color(0.1, 0.05, 0.2, 0.8)
    btn_style.border_width_left = 2
    btn_style.border_width_right = 2
    btn_style.border_width_top = 2
    btn_style.border_width_bottom = 2
    btn_style.border_color = cmd.color
    btn_style.set_corner_radius_all(8)
    btn_style.content_margin_left = 15
    btn_style.content_margin_right = 15
    btn.add_theme_stylebox_override("normal", btn_style)
    
    var hover_style = StyleBoxFlat.new()
    hover_style.bg_color = Color(0.15, 0.08, 0.25, 0.9)
    hover_style.border_color = cmd.color
    hover_style.set_corner_radius_all(8)
    hover_style.content_margin_left = 15
    hover_style.content_margin_right = 15
    btn.add_theme_stylebox_override("hover", hover_style)
    
    var pressed_style = StyleBoxFlat.new()
    pressed_style.bg_color = cmd.color.dark()
    pressed_style.border_color = cmd.color
    pressed_style.set_corner_radius_all(8)
    pressed_style.content_margin_left = 15
    pressed_style.content_margin_right = 15
    btn.add_theme_stylebox_override("pressed", pressed_style)
    
    # 按鈕內容
    var hbox = HBoxContainer.new()
    
    var icon = Label.new()
    icon.text = cmd.icon
    icon.add_theme_font_size_override("font_size", 20)
    
    var label = Label.new()
    label.text = cmd.label
    label.add_theme_color_override("font_color", Color(1, 1, 1))
    
    var spacer = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    var arrow = Label.new()
    arrow.text = ">"
    arrow.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
    
    hbox.add_child(icon)
    hbox.add_child(label)
    hbox.add_child(spacer)
    hbox.add_child(arrow)
    
    btn.add_child(hbox)
    
    # 連接點擊信號
    btn.pressed.connect(_on_command_clicked.bind(cmd_name))
    
    return btn

func show_panel_for_agent(agent_name: String, agent_data: Dictionary):
    current_agent_name = agent_name
    current_agent = agent_data
    
    # 更新 Agent 資訊
    var name_label = agent_info.get_node_or_null("AgentName")
    var role_label = agent_info.get_node_or_null("AgentRole")
    
    if name_label:
        name_label.text = "%s %s" % [agent_data.get("emoji", "🤖"), agent_name]
    
    if role_label:
        role_label.text = "角色：%s" % agent_data.get("role", "Unknown")
    
    # 顯示面板
    show_panel()
    
    # 更新狀態
    _update_status("已選擇 %s" % agent_name)

func show_panel():
    if not panel:
        return
    
    is_visible = true
    panel.visible = true
    
    # 定位到右上角
    var viewport_size = get_viewport_rect().size
    panel.position = Vector2(viewport_size.x - PANEL_WIDTH - 20, 20)

func hide_panel():
    is_visible = false
    current_agent_name = ""
    current_agent = {}
    
    if panel:
        panel.visible = false
    
    emit_signal("panel_closed")

func _on_command_clicked(cmd_name: String):
    if current_agent_name == "":
        _update_status("請先選擇一個 Agent")
        return
    
    var cmd = COMMANDS.get(cmd_name)
    if not cmd:
        return
    
    # 發送命令
    emit_signal("command_sent", current_agent_name, cmd_name, {})
    
    # 顯示發送成功的提示
    _update_status("Sent: %s to %s" % [cmd.icon, current_agent_name])
    
    # 播放音效（如果有的話）
    # AudioServer.play_sound("command_sent")
    
    # 自動關閉面板（可選）
    await get_tree().create_timer(1.0).timeout
    hide_panel()

func _update_status(text: String):
    if status_label:
        status_label.text = text

func _process(delta: float):
    # ESC 鍵關閉面板
    if is_visible and Input.is_action_just_pressed("interact"):
        hide_panel()
