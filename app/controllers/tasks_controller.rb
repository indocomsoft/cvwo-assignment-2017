# frozen_string_literal: true

class TasksController < ApplicationController
  def index
    @tasks = Task.order(sort_column + " " + sort_direction)
  end

  def show
    render json: Task.names.to_a if params[:id] == "all"
  end

  def new
    @task = Task.new
  end

  def create
    task = Task.new task_params
    task.assign_categories(params[:category])
    if task.save
      redirect_to tasks_path
    else
      @task = task
      flash[:error] = task.errors.full_messages.join(", ")
      render new_task_path, status: :bad_request
    end
  end

  def edit
    @task = Task.find params[:id]
  end

  def update
    task = Task.find params[:id]
    task.assign_categories(params[:category])
    if task.update task_params
      redirect_to tasks_path
    else
      @task = task
      flash[:error] = task.errors.full_messages.join(", ")
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
      if Task.column_names.include?(params[:sort])
        params[:sort]
      else
        "priority"
      end
    end

    # Extract the direction to sort by. Else, ascending is the default direction
    def sort_direction
      if %w[asc desc].include?(params[:direction])
        params[:direction]
      else
        "asc"
      end
    end

    # Helper to generate table header in view
    def sortable(column, title = nil)
      title ||= column.titleize
      title += "<i class=\"fa fa-sort-#{sort_direction}\"></i>" if column == sort_column
      direction =
        if column == sort_column && sort_direction == "asc"
          "desc"
        else
          "asc"
        end
      view_context.link_to title.html_safe, sort: column, direction: direction
    end

    helper_method :sortable
end
