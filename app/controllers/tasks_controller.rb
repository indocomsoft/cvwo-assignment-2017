# frozen_string_literal: true

class TasksController < ApplicationController
  helper_method :sortable

  def sortable(column, title = nil)
    title ||= column.titleize
    title += (column == sort_column ? "<i class=\"fa fa-sort-#{sort_direction}\"></i>" : "")
    direction = (column == sort_column && sort_direction == "asc" ? "desc" : "asc")
    view_context.link_to title.html_safe, {sort: column, direction: direction}
  end

  def index
    @tasks = Task.order(sort_column + " " + sort_direction)
  end

  def new
    @task = Task.new
  end

  def create
    task = Task.new task_params
    # task.due_date = Date.strptime(params[:task][:due_date], "%d/%m/%Y")
    if task.save
      redirect_to tasks_path
    else
      @task = task
      flash[:error] = task.errors.full_messages.join(', ')
      render new_task_path
    end
  end

  def edit
    @task = Task.find params[:id]
  end

  def update
    task = Task.find params[:id]
    if task.update task_params
      redirect_to tasks_path
    else
      redirect_to edit_task_path(params[:id]), flash: { error: task.errors.full_messages.join(', ') }
    end
  end

  def destroy
    task = Task.find params[:id]
    redirect_to tasks_path if task.destroy
  end

  private

  def task_params
    params.require(:task).permit(:name, :description, :priority, :done, :due_date)
  end

  def sort_column
    Task.column_names.include?(params[:sort])? params[:sort] : "priority"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
