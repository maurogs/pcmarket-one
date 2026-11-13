# Read-only access to conversations for dispute and fraud investigations. Every view is audited.
class Admin::ConversationsController < Admin::BaseController
  def index
    scope = Conversation.includes(:buyer, :seller, :listing).recent
    if params[:user].present?
      user = User.find_by("lower(username) = ?", params[:user].downcase)
      scope = user ? scope.for_user(user) : scope.none
    end
    @pagy, @conversations = paginate(scope)
  end

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages.includes(:sender)
    audit!("conversation.viewed", @conversation)
  end
end
