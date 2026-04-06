extends Node3D
class_name InteractionSystem

# Agent Interaction System
# 玩家靠近 Agent 按 E 鍵互動

signal agent_interacted(agent_name: String, command: String)
signal interaction_started(agent_name: String)
signal interaction_ended()

const INTERACTION_RANGE: float = 3.0
const MAX_CHAT_HISTORY: int = 10

var nearby_agent: Dictionary = {}
var is_interacting: bool = false
var current_agent: String = ""
var chat_history: Array = []
var player_ref: CharacterBody3D = null
var world_ref: Node = null

# UI 節點
var interaction_ui: Control = null
var prompt_label: Label = null
var chat_container: VBoxContainer = null
var input_line: LineEdit = null
var response_label: RichTextLabel = null

func _ready():
	print("🔔 InteractionSystem 初始化")
	_setup_ui()

func _setup_ui():
	# 創建 CanvasLayer
	var canvas = CanvasLayer.new()
	canvas.name = "InteractionUI"
	add_child(canvas)
	
	# 互動提示 UI（底部中央）
	var prompt_panel = Panel.new()
	prompt_panel.name = "PromptPanel"
	prompt_panel.custom_minimum_size = Vector2(400, 60)
	prompt_panel.position = Vector2(100, 100)
	prompt_panel.visible = false
	
	var prompt_style = StyleBoxFlat.new()
	prompt_style.bg_color = Color(0.1, 0.05, 0.2, 0.9)
	prompt_style.border_width_left = 2
	prompt_style.border_width_right = 2
	prompt_style.border_width_top = 2
	prompt_style.border_width_bottom = 2
	prompt_style.border_color = Color(0.5, 0.3, 1.0)
	prompt_style.set_corner_radius_all(8)
	prompt_panel.add_theme_stylebox_override("panel", prompt_style)
	
	prompt_label = Label.new()
	prompt_label.text = "按 [E] 與 Agent 互動"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	prompt_label.add_theme_color_override("font_color", Color(1, 1, 1))
	prompt_panel.add_child(prompt_label)
	canvas.add_child(prompt_panel)
	
	# 對話 UI（全屏面板）
	var chat_panel = Panel.new()
	chat_panel.name = "ChatPanel"
	chat_panel.custom_minimum_size = Vector2(500, 400)
	chat_panel.position = Vector2(100, 100)
	chat_panel.visible = false
	
	var chat_style = StyleBoxFlat.new()
	chat_style.bg_color = Color(0.08, 0.04, 0.15, 0.95)
	chat_style.border_width_left = 3
	chat_style.border_width_right = 3
	chat_style.border_width_top = 3
	chat_style.border_width_bottom = 3
	chat_style.border_color = Color(0.4, 0.2, 1.0)
	chat_style.set_corner_radius_all(12)
	chat_style.content_margin_left = 20
	chat_style.content_margin_right = 20
	chat_style.content_margin_top = 20
	chat_style.content_margin_bottom = 20
	chat_panel.add_theme_stylebox_override("panel", chat_style)
	
	# 標題列
	var title_bar = HBoxContainer.new()
	title_bar.name = "TitleBar"
	
	var agent_name_label = Label.new()
	agent_name_label.name = "AgentName"
	agent_name_label.text = "🤖 Agent"
	agent_name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	agent_name_label.add_theme_font_size_override("font_size", 24)
	
	var close_btn = Button.new()
	close_btn.text = " X "
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.pressed.connect(_close_interaction)
	
	title_bar.add_child(agent_name_label)
	title_bar.add_child(close_btn)
	title_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_panel.add_child(title_bar)
	
	# 聊天歷史
	var scroll = ScrollContainer.new()
	scroll.name = "ChatScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	chat_container = VBoxContainer.new()
	chat_container.name = "ChatContainer"
	chat_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_container.add_theme_constant_override("separation", 10)
	
	scroll.add_child(chat_container)
	chat_panel.add_child(scroll)
	
	# 輸入框
	var input_container = HBoxContainer.new()
	input_container.name = "InputContainer"
	
	input_line = LineEdit.new()
	input_line.name = "InputLine"
	input_line.placeholder_text = "輸入指令或問題..."
	input_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_line.custom_minimum_size = Vector2(300, 40)
	input_line.text_submitted.connect(_on_input_submitted)
	
	var send_btn = Button.new()
	send_btn.text = "發送"
	send_btn.pressed.connect(_send_command)
	
	input_container.add_child(input_line)
	input_container.add_child(send_btn)
	chat_panel.add_child(input_container)
	
	canvas.add_child(chat_panel)
	
	# 保存引用
	interaction_ui = canvas
	prompt_panel.visible = false
	chat_panel.visible = false

func set_references(player: CharacterBody3D, world: Node):
	player_ref = player
	world_ref = world

func _process(delta: float):
	if is_interacting:
		return
	
	# 檢測附近的 Agent
	_check_nearby_agents()
	
	# 處理輸入
	if Input.is_action_just_pressed("interact") and nearby_agent.size() > 0:
		_start_interaction(nearest_agent_name())

func _check_nearby_agents():
	if not player_ref or not world_ref:
		return
	
	var player_pos = player_ref.global_position
	nearby_agent.clear()
	
	# 遍歷所有 Agent
	for agent_name in world_ref.agent_data:
		var data = world_ref.agent_data[agent_name]
		var agent_node = data.get("node")
		if agent_node:
			var dist = player_pos.distance_to(agent_node.global_position)
			if dist < INTERACTION_RANGE:
				nearby_agent[agent_name] = dist
	
	# 更新 UI
	_update_prompt_ui()

func nearest_agent_name() -> String:
	if nearby_agent.size() == 0:
		return ""
	var nearest = ""
	var min_dist = INF
	for agent_name in nearby_agent:
		var dist = nearby_agent[agent_name]
		if dist < min_dist:
			min_dist = dist
			nearest = agent_name
	return nearest

func _update_prompt_ui():
	var prompt_panel = interaction_ui.get_node_or_null("PromptPanel") if interaction_ui else null
	if not prompt_panel:
		return
	
	if nearby_agent.size() > 0:
		prompt_panel.visible = true
		var name = nearest_agent_name()
		if name != "":
			var agent_data = world_ref.agent_data.get(name) if world_ref else null
			var emoji = agent_data.get("emoji", "🤖") if agent_data else "🤖"
			prompt_label.text = "按 [E] 與 %s %s 互動" % [emoji, name]
	else:
		prompt_panel.visible = false

func _start_interaction(agent_name: String):
	if agent_name == "" or not world_ref:
		return
	
	is_interacting = true
	current_agent = agent_name
	
	var agent_data = world_ref.agent_data.get(agent_name)
	if not agent_data:
		is_interacting = false
		return
	
	# 隱藏提示
	var prompt_panel = interaction_ui.get_node_or_null("PromptPanel") if interaction_ui else null
	if prompt_panel:
		prompt_panel.visible = false
	
	# 顯示對話 UI
	var chat_panel = interaction_ui.get_node_or_null("ChatPanel") if interaction_ui else null
	if chat_panel:
		chat_panel.visible = true
		var title_bar = chat_panel.get_node_or_null("TitleBar")
		if title_bar:
			var name_label = title_bar.get_node_or_null("AgentName")
			if name_label:
				name_label.text = "%s %s" % [agent_data.get("emoji", "🤖"), agent_name]
	
	# 清空聊天歷史
	_clear_chat()
	
	# 添加歡迎消息
	var role = agent_data.get("role", "Assistant")
	var tasks = agent_data.get("tasks", ["工作中"])
	var task_text = ", ".join(tasks)
	_add_agent_message("我是 %s，負責 %s。有什麼需要幫忙的嗎？" % [role, task_text])
	
	# 發射信號
	emit_signal("interaction_started", agent_name)
	print("🔔 開始與 %s 互動" % agent_name)

func _close_interaction():
	is_interacting = false
	current_agent = ""
	chat_history.clear()
	
	if interaction_ui:
		var chat_panel = interaction_ui.get_node_or_null("ChatPanel") if interaction_ui else null
		if chat_panel:
			chat_panel.visible = false
	
	emit_signal("interaction_ended")
	print("🔔 互動結束")

func _on_input_submitted(text: String):
	_send_command()

func _send_command():
	if not input_line or current_agent == "":
		return
	
	var user_input = input_line.text.strip_edges()
	if user_input == "":
		return
	
	# 添加用戶消息
	_add_user_message(user_input)
	chat_history.append({"role": "user", "content": user_input})
	input_line.text = ""
	
	# 處理命令
	_process_command(user_input)

func _process_command(user_input: String):
	if not world_ref:
		return
	
	var agent_data = world_ref.agent_data.get(current_agent)
	if not agent_data:
		_add_agent_message("抱歉，我目前無法回應。")
		return
	
	var response = ""
	var command_lower = user_input.to_lower()
	
	# 根據命令類型生成回應
	if command_lower.begins_with("status") or command_lower.begins_with("狀態"):
		response = _generate_status_response(agent_data)
	elif command_lower.begins_with("task") or command_lower.begins_with("任務"):
		response = _generate_task_response(agent_data)
	elif command_lower.begins_with("help") or command_lower.begins_with("幫助"):
		response = _generate_help_response()
	elif command_lower.begins_with("report") or command_lower.begins_with("報告"):
		response = _generate_report_response(agent_data)
	else:
		# 通用問答
		response = _generate_conversational_response(user_input, agent_data)
	
	_add_agent_message(response)
	chat_history.append({"role": "agent", "content": response})
	
	# 限制歷史長度
	if chat_history.size() > MAX_CHAT_HISTORY:
		chat_history.pop_front()
	
	# 發射信號
	emit_signal("agent_interacted", current_agent, user_input)

func _generate_status_response(agent_data: Dictionary) -> String:
	var state = agent_data.get("state", "idle")
	var emoji = agent_data.get("emoji", "🤖")
	var name = agent_data.get("name", "Agent")
	
	var state_text = "空閒"
	match state:
		"idle": state_text = "🟢 空閒"
		"walking": state_text = "🚶 移動中"
		"talking": state_text = "💬 對話中"
		"working": state_text = "⚡ 工作中"
	
	return "%s %s 目前狀態：%s" % [emoji, name, state_text]

func _generate_task_response(agent_data: Dictionary) -> String:
	var tasks = agent_data.get("tasks", [])
	if tasks.size() == 0:
		return "目前沒有進行的任務。"
	return "正在負責：\n• " + "\n• ".join(tasks)

func _generate_help_response() -> String:
	return """可用指令：
• status - 查看狀態
• task - 查看當前任務
• report - 生成進度報告
• help - 顯示幫助
• [任意問題] - 直接問答"""

func _generate_report_response(agent_data: Dictionary) -> String:
	var name = agent_data.get("name", "Agent")
	var role = agent_data.get("role", "Unknown")
	var state = agent_data.get("state", "idle")
	var tasks = agent_data.get("tasks", [])
	
	var report = "📊 %s 進度報告\n\n" % name
	report += "角色：%s\n" % role
	report += "狀態：%s\n" % state
	report += "任務：\n"
	for task in tasks:
		report += "  ✓ %s\n" % task
	report += "\n隨時可以執行新任務。"
	
	return report

func _generate_conversational_response(user_input: String, agent_data: Dictionary) -> String:
	var name = agent_data.get("name", "Agent")
	var emoji = agent_data.get("emoji", "🤖")
	var input_lower = user_input.to_lower()
	
	# 簡單的關鍵詞匹配
	if input_lower.find("好") != -1 or input_lower.find("hello") != -1 or input_lower.find("hi") != -1:
		return "%s %s 問候收到！有什麼需要幫忙的？" % [emoji, name]
	elif input_lower.find("謝謝") != -1 or input_lower.find("thanks") != -1:
		return "不客氣！隨時為你服務。"
	elif input_lower.find("工作") != -1 or input_lower.find("project") != -1:
		var tasks = agent_data.get("tasks", [])
		if tasks.size() > 0:
			return "目前正在處理：%s" % tasks[0]
		return "目前沒有進行中的工作。"
	elif input_lower.find("問題") != -1 or input_lower.find("issue") != -1 or input_lower.find("bug") != -1:
		return "發現任何問題我會立即回報。"
	else:
		return "%s 收到你的訊息：%s\n我會持續推進工作。" % [emoji, user_input]

func _add_user_message(text: String):
	if not chat_container:
		return
	
	var msg_panel = HBoxContainer.new()
	
	var avatar = Label.new()
	avatar.text = "👤"
	avatar.add_theme_font_size_override("font_size", 20)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	label.text_wrap_enabled = true
	
	msg_panel.add_child(avatar)
	msg_panel.add_child(label)
	chat_container.add_child(msg_panel)
	_scroll_to_bottom()

func _add_agent_message(text: String):
	if not chat_container:
		return
	
	var msg_panel = HBoxContainer.new()
	
	var avatar = Label.new()
	avatar.text = "🤖"
	avatar.add_theme_font_size_override("font_size", 20)
	
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = text
	label.fit_content = true
	label.custom_minimum_size = Vector2(350, 0)
	
	msg_panel.add_child(avatar)
	msg_panel.add_child(label)
	chat_container.add_child(msg_panel)
	_scroll_to_bottom()

func _clear_chat():
	if not chat_container:
		return
	for child in chat_container.get_children():
		child.queue_free()

func _scroll_to_bottom():
	if not chat_container:
		return
	var scroll = chat_container.get_parent()
	if scroll is ScrollContainer:
		await get_tree().process_frame
		scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value
