class MessageNotificationJob < ApplicationJob
  queue_as :default

  def perform(message_id, recipient_id)
    message = Message.find_by(id: message_id)
    recipient = User.find_by(id: recipient_id)
    return unless message && recipient

    kind = message.offer? ? :new_offer : :new_message
    path = AppRoutes.helpers.conversation_path(message.conversation)
    Notification.deliver(recipient, kind, path: path, sender: message.sender.display_name)
    MessageMailer.with(message: message, recipient: recipient).new_message.deliver_later if recipient.notify_by_email?(:messages)
  end
end
