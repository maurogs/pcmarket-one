require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test "returns typed defaults and stored values" do
    assert_equal false, Setting.get(:commissions_enabled)
    Setting.set(:commissions_enabled, "1")
    assert_equal true, Setting.get(:commissions_enabled)
    Setting.set(:commission_percent, "7,5")
    assert_in_delta 7.5, Setting.get(:commission_percent)
  end

  test "platform fee is zero while commissions are disabled" do
    assert_equal 0, PlatformFee.for(10_000)
    Setting.set(:commissions_enabled, true)
    Setting.set(:commission_percent, 5)
    assert_equal 500, PlatformFee.for(10_000)
    assert_equal 100, PlatformFee.for(1_000) # minimum fee
  end

  test "rejects unknown keys" do
    assert_raises(ArgumentError) { Setting.get(:nope) }
  end
end
