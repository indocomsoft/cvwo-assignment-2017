# frozen_string_literal: true

class CategoriesController < ApplicationController
  def index
    if params[:search]
      @categories = current_user.categories.search(params[:search])
    else
      @categories = current_user.categories.all.sort
    end
  end

  def show
    render json: current_user.categories.names.to_a if params[:id] == "all"
  end

  def new
    @category = current_user.categories.new
  end

  def create
    category = current_user.categories.new category_params
    category.assign_tasks(params[:task], current_user)
    if category.save
      redirect_to categories_path
    else
      @category = category
      flash.now[:danger] = category.errors.full_messages.join(", ")
      render new_category_path, status: :bad_request
    end
  end

  def edit
    @category = current_user.categories.find params[:id]
  end

  def update
    category = current_user.categories.find params[:id]
    category.assign_tasks(params[:task], current_user)
    if category.update category_params
      redirect_to categories_path
    else
      @category = category
      flash.now[:danger] = category.errors.full_messages.join(", ")
      render :edit, status: :bad_request
    end
  end

  def destroy
    category = current_user.categories.find params[:id]
    redirect_to categories_path if category.destroy
  end

  private

    def category_params
      params.require(:category).permit(:name, :colour)
    end
end
