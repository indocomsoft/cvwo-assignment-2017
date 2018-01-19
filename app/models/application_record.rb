# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.names
    self.all.map { |e| e.name }
  end

  def self.search(keyword)
    self.where("name ILIKE ?", "%#{keyword}%")
  end
end
