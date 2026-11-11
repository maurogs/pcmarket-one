class Account::AddressesController < Account::BaseController
  before_action :set_address, only: %i[edit update destroy]

  def index
    @addresses = current_user.addresses
  end

  def new
    @address = current_user.addresses.new(full_name: current_user.full_name, country_code: current_country.code)
  end

  def create
    @address = current_user.addresses.new(address_params)
    @address.default = true if current_user.addresses.none?
    if @address.save
      redirect_to safe_return_path || account_addresses_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @address.update(address_params)
      redirect_to account_addresses_path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to account_addresses_path, notice: t(".success"), status: :see_other
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:full_name, :company, :line1, :line2, :city, :region, :postal_code, :country_code, :phone, :default)
  end

  def safe_return_path
    path = params[:return_to].to_s
    path if path.start_with?("/") && !path.start_with?("//")
  end
end
