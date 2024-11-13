class Task
  attr_reader :id, :title, :status, :created_at

  def initialize(title)
    @id = generate_id
    @title = title
    @status = :pending
    @created_at = Time.now
  end

  def complete
    @status = :completed
  end

  def pending?
    @status == :pending
  end

  def completed?
    @status == :completed
  end

  private

  def generate_id
    Time.now.to_i.to_s(36) + rand(36**3).to_s(36)
  end
end

class TaskManager
  def initialize
    @tasks = []
  end

  def add_task(title)
    task = Task.new(title)
    @tasks << task
    task
  end

  def find_task(id)
    @tasks.find { |task| task.id == id }
  end

  def all_tasks
    @tasks.dup
  end

  def pending_tasks
    @tasks.select(&:pending?)
  end

  def completed_tasks
    @tasks.select(&:completed?)
  end
end

# 使用例
task_manager = TaskManager.new
task1 = task_manager.add_task("買い物に行く")
task2 = task_manager.add_task("メールを送る")
task1.complete

puts "全てのタスク: #{task_manager.all_tasks.length}"
puts "未完了のタスク: #{task_manager.pending_tasks.length}"
puts "完了したタスク: #{task_manager.completed_tasks.length}"
