class Conversation < ApplicationRecord
  belongs_to :listing, optional: true
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  has_many :messages, -> { order(:created_at) }, dependent: :delete_all
  has_many :offers, dependent: :nullify

  validates :listing_id, uniqueness: { scope: %i[buyer_id seller_id] }, allow_nil: true
  validate { errors.add(:base, :cannot_message_yourself) if buyer_id == seller_id }

  scope :for_user, ->(user) { where(buyer_id: user.id).or(where(seller_id: user.id)) }
  scope :recent, -> { order(Arel.sql("last_message_at DESC NULLS LAST")) }

  def participant?(user) = user && [buyer_id, seller_id].include?(user.id)
  def other_participant(user) = user.id == buyer_id ? seller : buyer
  def role_of(user) = user.id == buyer_id ? :buyer : :seller

  def unread_count_for(user)
    role_of(user) == :buyer ? buyer_unread_count : seller_unread_count
  end

  def mark_read_for!(user)
    column = role_of(user) == :buyer ? :buyer_unread_count : :seller_unread_count
    update_column(column, 0) if public_send(column).positive?
  end

  def blocked? = Block.between?(buyer, seller)

  def post!(sender:, body: nil, kind: :text, offer: nil)
    raise ActiveRecord::RecordInvalid, self if blocked?

    message = messages.create!(sender: sender, body: body, kind: kind, offer: offer)
    unread_column = sender.id == buyer_id ? :seller_unread_count : :buyer_unread_count
    self.class.where(id: id).update_all(["last_message_at = ?, #{unread_column} = #{unread_column} + 1, updated_at = ?", message.created_at, message.created_at])
    message
  end
end
