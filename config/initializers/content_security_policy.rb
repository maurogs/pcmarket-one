# Strict Content Security Policy. Scripts must come from our origin or carry the
# per-request nonce (importmap and the inline theme bootstrap use it).
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data, :blob, :https
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self, :unsafe_inline
    policy.connect_src :self, :wss, :https
    policy.frame_ancestors :none
    policy.base_uri    :self
    policy.form_action :self, "https://checkout.stripe.com"
  end

  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_nonce_auto = true
end

Rails.application.config.action_dispatch.default_headers.merge!(
  "Permissions-Policy" => "camera=(), microphone=(), geolocation=(), payment=(self)",
  "Referrer-Policy" => "strict-origin-when-cross-origin"
)
