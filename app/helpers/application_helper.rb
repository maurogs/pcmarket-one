module ApplicationHelper
  include IconsHelper
  include SeoHelper

  def site_name = Setting.get(:site_name)

  def money(cents, currency = "EUR")
    return "" if cents.nil?

    number_to_currency(cents / 100.0, unit: currency_symbol(currency), precision: (cents % 100).zero? ? 0 : 2)
  end

  def currency_symbol(currency)
    { "EUR" => "€", "GBP" => "£" }.fetch(currency.to_s, currency.to_s)
  end

  def flash_classes(type)
    type.to_s == "alert" ? "border-red-200 bg-red-50 text-red-900 dark:border-red-900 dark:bg-red-950 dark:text-red-100" : "border-brand-200 bg-brand-50 text-brand-900 dark:border-brand-900 dark:bg-brand-950 dark:text-brand-100"
  end

  def avatar_for(user, size: 40, css: "")
    initials = user.display_name.to_s.first(2).upcase
    image = user.store_logo.attached? ? user.store_logo : user.avatar
    if image.attached? && image.variable?
      image_tag image.variant(resize_to_fill: [size * 2, size * 2], format: :webp), alt: user.display_name,
                width: size, height: size, loading: "lazy", class: "rounded-full object-cover #{css}", style: "width:#{size}px;height:#{size}px"
    else
      tag.span initials, class: "inline-grid shrink-0 place-items-center rounded-full bg-brand-100 font-bold text-brand-800 dark:bg-brand-900 dark:text-brand-100 #{css}",
                         style: "width:#{size}px;height:#{size}px;font-size:#{(size * 0.38).round}px", "aria-hidden": "true"
    end
  end

  def stars(rating, css: "size-4")
    full = rating.to_f.round
    tag.span(class: "inline-flex text-accent-500", "aria-label": t("reviews.rating_label", rating: number_with_precision(rating, precision: 1))) do
      safe_join(5.times.map { |i| icon(:star, css: "#{css} #{i < full ? '' : 'opacity-25'}", filled: true, stroke: 1) })
    end
  end

  # Same page in another locale, preserving query parameters.
  def locale_url(locale)
    url_for(request.query_parameters.merge(locale: locale.to_s == I18n.default_locale.to_s ? nil : locale, only_path: false))
  rescue ActionController::UrlGenerationError
    root_url(locale: locale.to_s == I18n.default_locale.to_s ? nil : locale)
  end

  def nav_link_to(name, path, css: "", active_css: "text-brand-700 dark:text-brand-300 font-semibold", **options)
    active = current_page?(path)
    link_to name, path, class: "#{css} #{active_css if active}", "aria-current": (active ? "page" : nil), **options
  end

  def time_ago(time)
    return "" unless time

    tag.time(t("time.ago", time: time_ago_in_words(time)), datetime: time.iso8601, title: l(time, format: :long))
  end

  def field_errors(record, attribute)
    messages = record.errors.full_messages_for(attribute)
    return if messages.empty?

    tag.p(messages.to_sentence, class: "field-error", id: "#{record.model_name.param_key}_#{attribute}_error")
  end

  def pagination(pagy)
    render "shared/pagination", pagy: pagy, series: pagination_series(pagy) if pagy && pagy.last > 1
  end

  # [1, :gap, 4, 5, 6, :gap, 20] around the current page.
  def pagination_series(pagy, window: 2)
    pages = ([1, pagy.last] + ((pagy.page - window)..(pagy.page + window)).to_a).select { |p| p.between?(1, pagy.last) }.uniq.sort
    pages.each_with_index.flat_map { |page, i| i.positive? && page - pages[i - 1] > 1 ? [:gap, page] : [page] }
  end

  def status_badge(status, scope)
    css = case status.to_s
          when "published", "paid", "completed", "active", "resolved", "visible", "accepted" then "badge-success"
          when "pending_review", "pending_payment", "pending", "open", "reviewing", "disputed", "submitted" then "badge-warning"
          when "rejected", "cancelled", "refunded", "banned", "declined", "hidden" then "badge-danger"
          else "badge-muted"
          end
    tag.span t("#{scope}.#{status}"), class: css
  end
end
