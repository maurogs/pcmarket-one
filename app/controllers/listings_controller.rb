class ListingsController < ApplicationController
  include Catalogue

  before_action :require_active_user!, only: %i[new create edit update destroy]
  before_action :set_listing, only: %i[edit update destroy]

  def index
    render_catalogue
  end

  def show
    @listing = Listing.includes(:category, :region, user: { store_logo_attachment: :blob }).with_attached_photos.find(params[:id].to_i)
    visible = @listing.published? || @listing.sold? || @listing.editable_by?(current_user)
    raise ActiveRecord::RecordNotFound unless visible && (@listing.user.active? || current_user&.staff?)
    return redirect_to(listing_path(@listing), status: :moved_permanently) if params[:id] != @listing.to_param

    @listing.increment_views! unless @listing.user_id == current_user&.id || request.headers["Purpose"] == "prefetch"
    @details = ListingDetails.new(@listing, viewer: current_user)
  end

  def new
    @listing = current_user.listings.new(category_id: params[:category_id], allow_offers: current_user.allow_offers_default,
                                         region: current_user.region, city: current_user.city)
    @categories = Category.active.ordered
  end

  def create
    @listing = current_user.listings.new(listing_params)
    @listing.status = :draft
    if @listing.save
      submit_if_requested
    else
      @categories = Category.active.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @listing.category_id = params[:category_id] if params[:category_id].present?
    @categories = Category.active.ordered
  end

  def update
    @listing.assign_attributes(listing_params.except(:photos))
    attach_new_photos
    remove_photos
    if @listing.save
      submit_if_requested
    else
      @categories = Category.active.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @listing.order_items.exists?
      @listing.archive!(current_user)
    else
      @listing.destroy!
    end
    redirect_to seller_listings_path, notice: t(".success"), status: :see_other
  end

  private

  def set_listing
    @listing = Listing.find(params[:id].to_i)
    authorize!(@listing.editable_by?(current_user))
    authorize!(!@listing.sold? || current_user.staff?)
  end

  def listing_params
    params.require(:listing).permit(
      :title, :description, :brand, :category_id, :condition, :price, :original_price, :quantity,
      :shipping_available, :shipping_price, :local_pickup, :handling_days, :allow_offers,
      :region_id, :city, :postal_code, tag_list: [], specs: {}, photos: []
    ).tap do |permitted|
      permitted[:tags] = permitted.delete(:tag_list) if permitted.key?(:tag_list)
      permitted[:original_price] = nil if permitted[:original_price].blank? && permitted.key?(:original_price)
    end
  end

  def attach_new_photos
    uploads = Array(params.dig(:listing, :photos)).compact_blank
    return if uploads.empty?

    @listing.photos.attach(uploads)
    @listing.photos_changed!
  end

  def remove_photos
    ids = Array(params.dig(:listing, :remove_photo_ids)).map(&:to_i)
    return if ids.empty?

    @listing.photos.where(id: ids).each(&:purge_later)
    @listing.photos_changed!
  end

  def submit_if_requested
    if params[:commit_action] == "submit"
      @listing.submit!(current_user)
      notice = @listing.published? ? t("listings.submitted.published") : t("listings.submitted.pending")
    else
      notice = t("listings.saved_draft")
    end
    redirect_to listing_path(@listing), notice: notice
  rescue ActiveRecord::RecordInvalid
    @categories = Category.active.ordered
    render (action_name == "create" ? :new : :edit), status: :unprocessable_entity
  end
end
