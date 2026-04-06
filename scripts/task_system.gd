extends Node

# Task System - 任務系統
# 負責管理、分配、追蹤所有任務

signal task_created(task: Dictionary)
signal task_assigned(task_id: String, agent_name: String)
signal task_completed(task_id: String)
signal task_updated(task_id: String, progress: float)
signal all_tasks_completed()

const MAX_ACTIVE_TASKS: int = 20

var tasks: Dictionary = {}  # task_id -> task_data
var agent_tasks: Dictionary = {}  # agent_name -> [task_ids]

# 任務狀態
enum TaskStatus { PENDING, IN_PROGRESS, COMPLETED, FAILED, CANCELLED }

func _ready():
    print("📋 Task System 已就緒")

# ===== 任務管理 =====

func create_task(title: String, description: String, priority: int = 0, assigned_to: String = "") -> String:
    var task_id = "task_%d" % Time.get_ticks_msec()
    
    var task = {
        "id": task_id,
        "title": title,
        "description": description,
        "status": TaskStatus.PENDING,
        "priority": priority,  # 0-10, 10 = highest
        "progress": 0.0,
        "assigned_to": assigned_to,
        "created_at": Time.get_ticks_msec(),
        "updated_at": Time.get_ticks_msec(),
        "completed_at": 0,
        "tags": []
    }
    
    tasks[task_id] = task
    
    if assigned_to != "":
        _assign_task_to_agent(task_id, assigned_to)
    
    emit_signal("task_created", task)
    print("📋 任務建立: %s" % title)
    
    return task_id

func get_task(task_id: String) -> Dictionary:
    return tasks.get(task_id, {})

func get_all_tasks() -> Array:
    return tasks.values()

func get_tasks_by_status(status: TaskStatus) -> Array:
    var result = []
    for task in tasks.values():
        if task.get("status") == status:
            result.append(task)
    return result

func get_tasks_by_agent(agent_name: String) -> Array:
    var result = []
    var task_ids = agent_tasks.get(agent_name, [])
    for tid in task_ids:
        var task = tasks.get(tid)
        if task:
            result.append(task)
    return result

# ===== 任務操作 =====

func assign_task(task_id: String, agent_name: String) -> bool:
    var task = tasks.get(task_id)
    if not task:
        return false
    
    # 移除舊的分配
    if task.assigned_to != "":
        _unassign_task_from_agent(task_id, task.assigned_to)
    
    # 分配到新 Agent
    task.assigned_to = agent_name
    task.status = TaskStatus.IN_PROGRESS
    task.updated_at = Time.get_ticks_msec()
    
    _assign_task_to_agent(task_id, agent_name)
    
    emit_signal("task_assigned", task_id, agent_name)
    print("📋 任務分配: %s -> %s" % [task.title, agent_name])
    
    return true

func update_progress(task_id: String, progress: float) -> bool:
    var task = tasks.get(task_id)
    if not task:
        return false
    
    task.progress = clamp(progress, 0.0, 1.0)
    task.updated_at = Time.get_ticks_msec()
    
    emit_signal("task_updated", task_id, task.progress)
    
    return true

func complete_task(task_id: String) -> bool:
    var task = tasks.get(task_id)
    if not task:
        return false
    
    task.status = TaskStatus.COMPLETED
    task.progress = 1.0
    task.completed_at = Time.get_ticks_msec()
    task.updated_at = Time.get_ticks_msec()
    
    # 從 Agent 的任務列表移除
    if task.assigned_to != "":
        _unassign_task_from_agent(task_id, task.assigned_to)
    
    emit_signal("task_completed", task_id)
    print("✅ 任務完成: %s" % task.title)
    
    # 檢查是否所有任務都完成
    _check_all_completed()
    
    return true

func cancel_task(task_id: String) -> bool:
    var task = tasks.get(task_id)
    if not task:
        return false
    
    task.status = TaskStatus.CANCELLED
    task.updated_at = Time.get_ticks_msec()
    
    if task.assigned_to != "":
        _unassign_task_from_agent(task_id, task.assigned_to)
    
    return true

func fail_task(task_id: String) -> bool:
    var task = tasks.get(task_id)
    if not task:
        return false
    
    task.status = TaskStatus.FAILED
    task.updated_at = Time.get_ticks_msec()
    
    if task.assigned_to != "":
        _unassign_task_from_agent(task_id, task.assigned_to)
    
    return true

# ===== 內部方法 =====

func _assign_task_to_agent(task_id: String, agent_name: String):
    if not agent_tasks.has(agent_name):
        agent_tasks[agent_name] = []
    
    if not task_id in agent_tasks[agent_name]:
        agent_tasks[agent_name].append(task_id)

func _unassign_task_from_agent(task_id: String, agent_name: String):
    if agent_tasks.has(agent_name):
        agent_tasks[agent_name].erase(task_id)

func _check_all_completed():
    var all_done = true
    for task in tasks.values():
        if task.status != TaskStatus.COMPLETED and task.status != TaskStatus.CANCELLED:
            all_done = false
            break
    
    if all_done and tasks.size() > 0:
        emit_signal("all_tasks_completed")
        print("🎉 所有任務完成！")

# ===== 查詢方法 =====

func get_pending_tasks() -> Array:
    return get_tasks_by_status(TaskStatus.PENDING)

func get_in_progress_tasks() -> Array:
    return get_tasks_by_status(TaskStatus.IN_PROGRESS)

func get_completed_tasks() -> Array:
    return get_tasks_by_status(TaskStatus.COMPLETED)

func get_task_summary() -> Dictionary:
    var summary = {
        "total": tasks.size(),
        "pending": 0,
        "in_progress": 0,
        "completed": 0,
        "failed": 0,
        "cancelled": 0
    }
    
    for task in tasks.values():
        match task.status:
            TaskStatus.PENDING:
                summary.pending += 1
            TaskStatus.IN_PROGRESS:
                summary.in_progress += 1
            TaskStatus.COMPLETED:
                summary.completed += 1
            TaskStatus.FAILED:
                summary.failed += 1
            TaskStatus.CANCELLED:
                summary.cancelled += 1
    
    return summary

func get_high_priority_tasks() -> Array:
    var result = []
    for task in tasks.values():
        if task.priority >= 7 and task.status == TaskStatus.PENDING:
            result.append(task)
    # 按優先級排序
    result.sort_custom(func(a, b): return a.priority > b.priority)
    return result

# ===== 快捷方法 =====

func quick_assign(title: String, agent_name: String, priority: int = 5) -> String:
    """快速建立並分配任務"""
    var task_id = create_task(title, "", priority, agent_name)
    return task_id

func get_agent_workload(agent_name: String) -> int:
    """獲取 Agent 的工作負擔（正在進行的任務數）"""
    var count = 0
    var task_ids = agent_tasks.get(agent_name, [])
    for tid in task_ids:
        var task = tasks.get(tid)
        if task and task.status == TaskStatus.IN_PROGRESS:
            count += 1
    return count
