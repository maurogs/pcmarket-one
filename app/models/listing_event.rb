class ListingEvent < ApplicationRecord
  belongs_to :listing
  belongs_to :actor, class_name: "User", optional: true
end
