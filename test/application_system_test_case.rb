require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  Capybara.enable_aria_label = true

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ]

  teardown { page.driver.browser.manage.window.resize_to(1400, 1000) }

  def accept_cookies
    within("[aria-labelledby=cookie-title]") { click_on I18n.t("cookies.accept_all") }
  end

  def resize_to_phone
    page.driver.browser.manage.window.resize_to(390, 844)
  end
end
