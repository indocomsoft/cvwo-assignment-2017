# frozen_string_literal: true
# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  colour     :string
#

class Category < ApplicationRecord
  has_many :taskcategories
  has_many :tasks, through: :taskcategories
  validates :name, uniqueness: true
end
