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
      render new_category_path
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
      redirect_to edit_category_path(params[:id]), flash: { error: category.errors.full_messages.join(', ') }
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end