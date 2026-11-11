# Downloads freely licensed demo photos once and caches them in tmp/seed_images.
# Providers: Openverse (no key needed), plus Unsplash, Pexels and Pixabay when
# UNSPLASH_ACCESS_KEY, PEXELS_API_KEY or PIXABAY_API_KEY are present.
require "mini_magick"

module SeedImages
  CACHE = Rails.root.join("tmp/seed_images")
  PER_QUERY = Integer(ENV.fetch("SEED_IMAGES_PER_QUERY", 6))

  module_function

  def blobs_for(query)
    @blobs ||= {}
    @blobs[query] ||= files_for(query).filter_map { |file, meta| blob_for(file, meta) }
  end

  def files_for(query)
    dir = CACHE.join(query.parameterize)
    FileUtils.mkdir_p(dir)
    cached = Dir[dir.join("*.jpg")].sort
    return cached.map { |file| [ file, read_meta(file) ] } if cached.size >= PER_QUERY / 2 && cached.any?

    candidates(query).first(PER_QUERY * 2).each_with_index do |candidate, index|
      break if Dir[dir.join("*.jpg")].size >= PER_QUERY

      path = dir.join(format("%02d.jpg", index))
      next unless download(candidate[:url], path) || (candidate[:fallback] && download(candidate[:fallback], path))

      File.write("#{path}.json", candidate.except(:url, :fallback).to_json)
    end
    Dir[dir.join("*.jpg")].sort.map { |file| [ file, read_meta(file) ] }
  end

  def candidates(query)
    results = []
    results += unsplash(query) if ENV["UNSPLASH_ACCESS_KEY"].present?
    results += pexels(query) if ENV["PEXELS_API_KEY"].present?
    results += pixabay(query) if ENV["PIXABAY_API_KEY"].present?
    results + openverse(query)
  rescue StandardError => e
    warn "  image search failed for #{query}: #{e.message}"
    []
  end

  def openverse(query)
    base = "https://api.openverse.org/v1/images/?q=#{CGI.escape(query)}&page_size=20&mature=false"
    data = get_json("#{base}&license_type=commercial")
    data = get_json(base) if Array(data["results"]).empty?
    Array(data["results"]).map do |item|
      { url: item["url"], fallback: item["thumbnail"], source: "Openverse (#{item['provider']})", source_url: item["foreign_landing_url"],
        title: item["title"], creator: item["creator"], license: "CC #{item['license'].to_s.upcase} #{item['license_version']}".strip, license_url: item["license_url"] }
    end
  end

  def unsplash(query)
    data = get_json("https://api.unsplash.com/search/photos?query=#{CGI.escape(query)}&per_page=10", "Authorization" => "Client-ID #{ENV['UNSPLASH_ACCESS_KEY']}")
    Array(data["results"]).map do |item|
      { url: "#{item.dig('urls', 'raw')}&w=1400&q=80&fm=jpg", source: "Unsplash", source_url: item.dig("links", "html"), title: item["alt_description"],
        creator: item.dig("user", "name"), license: "Unsplash License", license_url: "https://unsplash.com/license" }
    end
  end

  def pexels(query)
    data = get_json("https://api.pexels.com/v1/search?query=#{CGI.escape(query)}&per_page=10", "Authorization" => ENV["PEXELS_API_KEY"])
    Array(data["photos"]).map do |item|
      { url: item.dig("src", "large"), source: "Pexels", source_url: item["url"], title: item["alt"], creator: item["photographer"],
        license: "Pexels License", license_url: "https://www.pexels.com/license/" }
    end
  end

  def pixabay(query)
    data = get_json("https://pixabay.com/api/?key=#{ENV['PIXABAY_API_KEY']}&q=#{CGI.escape(query)}&image_type=photo&per_page=10&safesearch=true")
    Array(data["hits"]).map do |item|
      { url: item["largeImageURL"], source: "Pixabay", source_url: item["pageURL"], title: item["tags"], creator: item["user"],
        license: "Pixabay Content License", license_url: "https://pixabay.com/service/license-summary/" }
    end
  end

  def get_json(url, headers = {}, attempts = 2)
    uri = URI(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 50) do |http|
      http.get(uri.request_uri, headers.merge("User-Agent" => "PCMarketSeeds/1.0", "Accept" => "application/json"))
    end
    return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

    attempts > 1 ? get_json(url, headers, attempts - 1) : {}
  rescue Net::ReadTimeout, Net::OpenTimeout, JSON::ParserError
    attempts > 1 ? get_json(url, headers, attempts - 1) : {}
  end

  # Downloads all queries concurrently (network bound); blobs are created afterwards.
  def prefetch(queries, threads: 6)
    queue = Queue.new
    queries.each { |query| queue << query }
    Array.new(threads) do
      Thread.new do
        while (query = (queue.pop(true) rescue nil))
          count = files_for(query).size
          puts "  #{query}: #{count} images"
        end
      end
    end.each(&:join)
  end

  def download(url, path, redirects = 3)
    return false if url.blank?

    uri = URI(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 8, read_timeout: 20) do |http|
      http.get(uri.request_uri, "User-Agent" => "PCMarketSeeds/1.0")
    end
    return download(URI.join(url, response["location"]).to_s, path, redirects - 1) if response.is_a?(Net::HTTPRedirection) && redirects.positive?
    return false unless response.is_a?(Net::HTTPSuccess) && response.body.bytesize > 5_000

    tmp = "#{path}.download"
    File.binwrite(tmp, response.body)
    image = MiniMagick::Image.open(tmp)
    image.combine_options { |c| c.auto_orient; c.resize "1400x1400>"; c.strip; c.quality 82 }
    image.format "jpg"
    image.write(path)
    true
  rescue StandardError
    false
  ensure
    FileUtils.rm_f("#{path}.download")
  end

  def read_meta(file)
    JSON.parse(File.read("#{file}.json"))
  rescue StandardError
    {}
  end

  def blob_for(file, meta)
    blob = ActiveStorage::Blob.create_and_upload!(io: File.open(file), filename: "#{File.basename(File.dirname(file))}-#{File.basename(file)}", content_type: "image/jpeg")
    if meta["source"].present?
      ImageCredit.create!(blob: blob, title: meta["title"].to_s.first(250), creator: meta["creator"].to_s.first(250), source: meta["source"],
                          source_url: meta["source_url"], license: meta["license"], license_url: meta["license_url"])
    end
    blob
  rescue StandardError => e
    warn "  could not store #{file}: #{e.message}"
    nil
  end
end
