require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    @listing = create_listing
  end

  def auth_headers
    post "/api/v1/session", params: { email: @user.email, password: "Password123!" }
    { "Authorization" => "Bearer #{response.parsed_body['token']}" }
  end

  test "public catalogue endpoints" do
    get "/api/v1/listings", params: { f: { gpu_model: [ "rtx_4070" ] } }
    assert_response :success
    assert_equal 1, response.parsed_body["data"].size
    assert_equal "1", response.headers["X-Total-Count"]
    get "/api/v1/listings/#{@listing.id}"
    assert_equal @listing.title, response.parsed_body.dig("data", "title")
    get "/api/v1/categories/gpus"
    assert response.parsed_body.dig("data", "filters").any?
  end

  test "login, profile, favourites and logout" do
    headers = auth_headers
    get "/api/v1/me", headers: headers
    assert_equal @user.email, response.parsed_body.dig("user", "email")
    post "/api/v1/listings/#{@listing.id}/favorite", headers: headers
    assert_response :created
    get "/api/v1/favorites", headers: headers
    assert_equal 1, response.parsed_body["data"].size
    delete "/api/v1/session", headers: headers
    get "/api/v1/me", headers: headers
    assert_response :unauthorized
  end

  test "rejects bad credentials and anonymous writes" do
    post "/api/v1/session", params: { email: @user.email, password: "wrong" }
    assert_response :unauthorized
    post "/api/v1/listings", params: { listing: { title: "x" } }
    assert_response :unauthorized
  end

  test "localised error messages" do
    get "/api/v1/me", headers: { "Accept-Language" => "es-ES" }
    assert_equal I18n.t("api.errors.unauthorized", locale: :es), response.parsed_body.dig("error", "message")
  end
end
