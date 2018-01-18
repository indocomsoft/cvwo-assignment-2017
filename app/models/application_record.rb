# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.names
    self.all.map { |e| e.name }
  end
end
