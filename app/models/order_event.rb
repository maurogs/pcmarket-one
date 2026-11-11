class OrderEvent < ApplicationRecord
  belongs_to :order
  belongs_to :actor, class_name: "User", optional: true
end
