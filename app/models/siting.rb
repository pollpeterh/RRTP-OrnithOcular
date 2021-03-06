class Siting < ApplicationRecord
	belongs_to :user
	has_many :comments, dependent: :destroy

	has_attached_file :image, styles: {small: "300x300#"}
	has_attached_file :static_map

	validates :bird, presence: true
	validates :location, presence: true
	validates :longitude, presence: true
	validates :latitude, presence: true
	validates :image, presence: true

	# image must be less than 3MB
	validates_attachment_size :image, :less_than => 3.megabytes

	validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
	validates_attachment_content_type :static_map, content_type: /\Aimage\/.*\Z/

	acts_as_votable

	geocoded_by :location

	def self.search(search)
		near_relation = near(search, 100).order(created_at: :desc)
		like_relation = joins(:user).where("bird ILIKE ? OR username ILIKE ?", "%#{search}%", "%#{search}%").order(created_at: :desc)
		near_relation + (like_relation - near_relation)
	end
end
