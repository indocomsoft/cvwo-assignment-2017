# frozen_string_literal: true

class CategoriesController < ApplicationController
  def index
    @categories = Category.all.sort
  end

  def show
    render json: Category.all.map { |e| e.name }.to_a if params[:id] == "all"
  end

  def new
    @category = Category.new
  end

  def create
    category = Category.new category_params
    commit_tasks(category, params[:task])
    if category.save
      redirect_to categories_path
    else
      @category = category
      flash[:error] = category.errors.full_messages.join(', ')
      render new_category_path, status: :bad_request
    end
  end

  def edit
    @category = Category.find params[:id]
  end

  def update
    category = Category.find params[:id]
    commit_tasks(category, params[:task])
    if category.update category_params
      redirect_to categories_path
    else
      @category = category
      flash[:error] = category.errors.full_messages.join(', ')
      render :edit, status: :bad_request
    end
  end

  def destroy
    category = Category.find params[:id]
    redirect_to categories_path if category.destroy
  end

  private

  def category_params
    params.require(:category).permit(:name, :colour)
  end

  def commit_tasks(category, tasks)
    existing = category.tasks.all.map { |t| t.name }
    input = tasks.split(",")
    to_add = input - existing
    to_rm = existing - input

    to_add.each do |t|
      task = Task.find_or_create_by(name: t)
      Taskcategory.create(task: task, category: category)
    end

    to_rm.each do |t|
      task = Task.find_by(name: t)
      Taskcategory.find_by(task: task, category: category).destroy
    end
  end
end