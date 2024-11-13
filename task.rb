class Task
  attr_reader :id, :title, :status, :created_at
  attr_accessor :due_date, :priority, :tags  # 新しい属性を追加

  PRIORITIES = [:low, :medium, :high]

  def initialize(title, due_date: nil, priority: :medium)
    @id = generate_id
    @title = title
    @status = :pending
    @created_at = Time.now
    @due_date = due_date
    @priority = priority if PRIORITIES.include?(priority)
    @tags = []
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

  def overdue?
    return false if @due_date.nil? || completed?
    @due_date < Time.now
  end

  def add_tag(tag)
    @tags << tag unless @tags.include?(tag)
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

  def add_task(title, **options)
    task = Task.new(title, **options)
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

  # タグによるフィルタリングを追加
  def filter_by_tag(tag)
    @tasks.select { |task| task.tags.include?(tag) }
  end

  # 優先度でソート (デフォルトは降順)
  def sort_by_priority(ascending = false)
    sorted = @tasks.sort_by { |task| Task::PRIORITIES.index(task.priority) }
    ascending ? sorted : sorted.reverse
  end

  # 期限切れのタスクを検索
  def find_overdue_tasks
    current_time = Time.now
    @tasks.select do |task|
      task.overdue?
    end
  end

  # タスクの統計情報を取得
  def get_statistics
    {
      total: @tasks.length,
      pending: pending_tasks.length,
      completed: completed_tasks.length,
      overdue: find_overdue_tasks.length,
      by_priority: {
        high: @tasks.count { |t| t.priority == :high },
        medium: @tasks.count { |t| t.priority == :medium },
        low: @tasks.count { |t| t.priority == :low }
      }
    }
  end
end

# 使用例
def create_sample_tasks
  manager = TaskManager.new

  # サンプルタスクの作成
  task1 = manager.add_task(
    "買い物に行く",
    due_date: Time.now + (60 * 60 * 24),  # 1日後
    priority: :high
  )
  task1.add_tag("個人")

  task2 = manager.add_task(
    "メールを送る",
    due_date: Time.now + (60 * 60 * 2),   # 2時間後
    priority: :medium
  )
  task2.add_tag("仕事")

  task3 = manager.add_task(
    "レポートを作成",
    due_date: Time.now - (60 * 60 * 24),  # 1日前（期限切れ）
    priority: :high
  )
  task3.add_tag("仕事")

  manager
end

# 動作確認
manager = create_sample_tasks
stats = manager.get_statistics
puts "タスク統計:"
puts stats.inspect

puts "\n優先度高のタスク:"
high_priority = manager.sort_by_priority.select { |t| t.priority == :high }
high_priority.each { |task| puts "- #{task.title}" }

puts "\n仕事関連のタスク:"
work_tasks = manager.filter_by_tag("仕事")
work_tasks.each { |task| puts "- #{task.title}" }

puts "\n期限切れのタスク:"
overdue = manager.find_overdue_tasks
overdue.each { |task| puts "- #{task.title}" }
