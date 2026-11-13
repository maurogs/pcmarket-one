require "test_helper"

class ListingSearchTest < ActiveSupport::TestCase
  setup do
    @cheap = create_listing(title: "RTX 3060 Gaming OC", price: 200, specs: { "gpu_model" => "rtx_3060" }, condition: :good)
    @expensive = create_listing(title: "RTX 4070 Founders", price: 500, specs: { "gpu_model" => "rtx_4070" }, condition: :brand_new)
    @pending = create_listing(title: "RTX 4070 pending", status: :pending_review)
  end

  def ids(params) = ListingSearch.new(params).results.pluck(:id)

  test "only returns visible listings" do
    assert_not_includes ids({}), @pending.id
  end

  test "filters by price, condition and specs" do
    assert_equal [ @cheap.id ], ids(max_price: "300")
    assert_equal [ @expensive.id ], ids(condition: [ "brand_new" ])
    assert_equal [ @cheap.id ], ids(f: { "gpu_model" => [ "rtx_3060" ] })
    assert_equal [ @cheap.id, @expensive.id ].sort, ids(f: { "gpu_model" => %w[rtx_3060 rtx_4070] }).sort
  end

  test "full text search with typo tolerance" do
    assert_includes ids(q: "3060"), @cheap.id
    assert_includes ids(q: "founders"), @expensive.id
  end

  test "sorting by price" do
    assert_equal [ @cheap.id, @expensive.id ], ids(sort: "price_asc")
  end

  test "ignores unknown filters and sorts" do
    assert_equal 2, ids(f: { "hack'; drop" => [ "x" ] }, sort: "evil").size
  end

  test "hides listings from disabled countries" do
    spain.update!(enabled: false)
    assert_empty ids({})
  ensure
    spain.update!(enabled: true)
  end
end
