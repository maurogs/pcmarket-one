# Commission charged to the seller. Zero while the "commissions_enabled" flag is off.
module PlatformFee
  module_function

  def for(amount_cents)
    return 0 unless Setting.enabled?(:commissions_enabled) && amount_cents.positive?

    fee = (amount_cents * Setting.get(:commission_percent) / 100.0).round
    [ fee, Setting.get(:commission_min_cents) ].max.clamp(0, amount_cents)
  end
end
