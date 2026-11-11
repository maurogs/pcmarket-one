class Admin::SettingsController < Admin::BaseController
  before_action :require_admin!

  def show
    @groups = Setting::DEFINITIONS.group_by { |_, definition| definition.last }
  end

  def update
    submitted = params.fetch(:settings, {}).permit(Setting::DEFINITIONS.keys.map { |k| Setting::DEFINITIONS[k][0] == :list ? { k => [] } : k })
    Setting.transaction do
      submitted.each { |key, value| Setting.set(key, value) }
    end
    audit!("settings.updated", nil, submitted.to_h)
    redirect_to admin_settings_path(group: params[:group]), notice: t("admin.flash.updated")
  end
end
