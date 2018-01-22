# frozen_string_literal: true

class TasksController < ApplicationController
  def index
    if params[:search]
      @tasks = current_user.tasks.search(params[:search])
    else
      @tasks = current_user.tasks.all
    end
    @tasks = @tasks.order(sort_column + " " + sort_direction)
  end

  # For show AJAX call
  def show
    render json: current_user.tasks.names.to_a if params[:id] == "all"
  end

  def new
    @task = current_user.tasks.new
  end

  def create
    task = current_user.tasks.new task_params
    task.assign_categories(params[:category], current_user)
    if task.save
      redirect_to tasks_path
    else
      @task = task
      flash.now[:danger] = task.errors.full_messages.join(", ")
      render new_task_path, status: :bad_request
    end
  end

  def edit
    @task = current_user.tasks.find params[:id]
  end

  def update
    task = current_user.tasks.find params[:id]
    task.assign_categories(params[:category], current_user)
    if task.update task_params
      redirect_to tasks_path
    else
      @task = task
      flash.now[:danger] = task.errors.full_messages.join(", ")
      render :edit, status: :bad_request
    end
  end

  def destroy
    task = current_user.tasks.find params[:id]
    redirect_to tasks_path if task.destroy
  end

  def done
    task = current_user.tasks.find params[:id]
    task.done = params[:value]
    status = task.save
    render json: { success: status, name: task.name, value: params[:value] }
  end

  private

    # Sanitise parameter
    def task_params
      params.require(:task).permit(:name, :description, :priority, :done, :due_date)
    end

    # Extract the column to sort by, while also sanitising the input
    # Else, priority is the default column sorting mode
    def sort_column
      if current_user.tasks.column_names.include?(params[:sort])
        params[:sort]
      else
        "priority"
      end
    end

    # Extract the direction to sort by, while also sanitising the input
    # Else, ascending is the default direction
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
      [title.html_safe, sort: column, direction: direction]
    end

    helper_method :sortable
end
