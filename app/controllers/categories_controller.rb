# frozen_string_literal: true

class CategoriesController < ApplicationController
  helper_method :choose_fgcolour

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
    params.require(:category).permit(:name, :colour)
  end
end