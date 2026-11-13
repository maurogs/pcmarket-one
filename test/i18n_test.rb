require "test_helper"
require "i18n/tasks"

class I18nTest < ActiveSupport::TestCase
  test "no missing translation keys in any locale" do
    missing = I18n::Tasks::BaseTask.new.missing_keys
    assert_empty missing, "Missing keys:\n#{missing.inspect}"
  end
end
