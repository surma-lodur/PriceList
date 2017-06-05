# encoding: UTF-8
class List < ActiveRecord::Base

  has_many :items, dependent: :destroy
  has_many(:available_items, -> { available }, foreign_key: 'list_id', class_name: 'Item')

  validates :title, uniqueness: true, presence: true

  scope :available, ->{
    self.where("id IS NOT NULL")
  }

end
