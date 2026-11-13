module ConversationSerializer
  extend SerializerHelpers
  module_function

  def summary(conversation, viewer)
    other = conversation.other_participant(viewer)
    { id: conversation.id, listing_id: conversation.listing_id, listing_title: conversation.listing&.title,
      other: { username: other.username, name: other.display_name }, role: conversation.role_of(viewer),
      unread: conversation.unread_count_for(viewer), last_message_at: conversation.last_message_at }
  end

  def message(message)
    { id: message.id, kind: message.kind, body: message.body, sender: message.sender.username, created_at: message.created_at,
      offer: message.offer && { id: message.offer.id, amount: money(message.offer.amount_cents, message.offer.listing.currency), status: message.offer.status } }
  end
end
