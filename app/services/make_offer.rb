# Creates an offer and posts it into the buyer/seller conversation.
class MakeOffer
  Result = Struct.new(:success?, :offer, :conversation, keyword_init: true)

  def initialize(listing:, buyer:, amount:, message: nil)
    @listing = listing
    @buyer = buyer
    @amount = amount
    @message = message.to_s.strip.first(Message::MAX_LENGTH)
  end

  def call
    offer = Offer.new(listing: @listing, buyer: @buyer, amount: @amount)
    if Block.between?(@buyer, @listing.user)
      offer.errors.add(:base, :blocked)
      return Result.new(success?: false, offer: offer)
    end

    conversation = nil
    ActiveRecord::Base.transaction do
      conversation = Conversation.find_or_create_by!(listing: @listing, buyer: @buyer, seller: @listing.user)
      offer.conversation = conversation
      offer.save!
      conversation.post!(sender: @buyer, kind: :offer, offer: offer, body: @message.presence)
    end
    Result.new(success?: true, offer: offer, conversation: conversation)
  rescue ActiveRecord::RecordInvalid
    Result.new(success?: false, offer: offer)
  end
end
