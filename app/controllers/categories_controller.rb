# frozen_string_literal: true

class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    category = Category.new category_params
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
    params.require(:category).permit(:name)
  end
end