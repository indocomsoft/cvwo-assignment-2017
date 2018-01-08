# frozen_string_literal: true

class TasksController < ApplicationController
  helper_method :sortable, :choose_fgcolour

  # Helper to generate table header in view
  def sortable(column, title = nil)
    title ||= column.titleize
    title += "<i class=\"fa fa-sort-#{sort_direction}\"></i>" if column == sort_column
    direction = if column == sort_column && sort_direction == "asc" 
                  "desc"
                else
                  "asc"
                end
    view_context.link_to title.html_safe, {sort: column, direction: direction}
  end

  # Helper to choose foreground colour from a given background colour, following W3C Recommendation
  # https://www.w3.org/TR/WCAG20/#relativeluminancedef
  def choose_fgcolour(bgcolour)
    # Extract the red, green, blue components from the colour hexcode
    # then convert them according to the W3C recommendation 
    r,g,b = bgcolour.match(/#(..)(..)(..)/).to_a.drop(1).map do |e|
      a = e.hex / 255
      if a <= 0.03928
        a / 12.92
      else
        ((a + 0.055) / 1.055) ** 2.4
      end
    end
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    if luminance > 0.179
      "#000000"
    else
      "#FFFFFF"
    end
  end

  def index
    @tasks = Task.order(sort_column + " " + sort_direction)
  end

  def new
    @task = Task.new
  end

  def create
    task = Task.new task_params
    commit_categories(task, params[:category])
    if task.save
      redirect_to tasks_path
    else
      @task = task
      flash[:error] = task.errors.full_messages.join(', ')
      render new_task_path, status: :bad_request
    end
  end

  def edit
    @task = Task.find params[:id]
  end

  def update
    task = Task.find params[:id]
    commit_categories(task, params[:category])
    if task.update task_params
      redirect_to tasks_path
    else
      @task = task
      flash[:error] = task.errors.full_messages.join(', ')
      render :edit, status: :bad_request
    end
  end

  def destroy
    task = Task.find params[:id]
    redirect_to tasks_path if task.destroy
  end

  def done
    task = Task.find params[:id]
    task.done = params[:value]
    status = task.save
    render json: { success: status, name: task.name, value: params[:value] }
  end

  private

  # Sanitise parameter
  def task_params
    params.require(:task).permit(:name, :description, :priority, :done, :due_date)
  end

  # Extract the column to sort by. Else, priority is the default column sorting mode
  def sort_column
    Task.column_names.include?(params[:sort])? params[:sort] : "priority"
  end

  # Extract the direction to sort by. Else, ascending is the default direction
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  # Commit the categories for a given task into the database
  def commit_categories(task, categories)
    existing = task.categories.all.map { |c| c.name }
    input = categories.split(",")
    to_add = input - existing
    to_rm = existing - input

    to_add.each do |c|
      category = Category.find_or_create_by(name: c)
      Taskcategory.create(task: task, category: category)
    end

    to_rm.each do |c|
      category = Category.find_by(name: c)
      Taskcategory.find_by(task: task, category: category).destroy
    end
  end
end
