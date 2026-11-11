class ApiToken < ApplicationRecord
  belongs_to :user

  attr_reader :plain_token

  before_validation :generate_token, on: :create
  validates :token_digest, presence: true, uniqueness: true

  scope :usable, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def self.digest(token) = OpenSSL::Digest::SHA256.hexdigest(token.to_s)

  def self.authenticate(token)
    return if token.blank?

    api_token = usable.includes(:user).find_by(token_digest: digest(token))
    return unless api_token&.user&.active_for_authentication?

    api_token.touch(:last_used_at) if api_token.last_used_at.nil? || api_token.last_used_at < 5.minutes.ago
    api_token
  end

  private

  def generate_token
    @plain_token = SecureRandom.base58(40)
    self.token_digest = self.class.digest(@plain_token)
    self.expires_at ||= 90.days.from_now
  end
end
