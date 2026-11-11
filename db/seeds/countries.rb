REGIONS = {
  "ES" => [ "A Coruña", "Álava", "Albacete", "Alicante", "Almería", "Asturias", "Ávila", "Badajoz", "Barcelona", "Bizkaia", "Burgos", "Cáceres", "Cádiz",
           "Cantabria", "Castellón", "Ceuta", "Ciudad Real", "Córdoba", "Cuenca", "Gipuzkoa", "Girona", "Granada", "Guadalajara", "Huelva", "Huesca",
           "Illes Balears", "Jaén", "La Rioja", "Las Palmas", "León", "Lleida", "Lugo", "Madrid", "Málaga", "Melilla", "Murcia", "Navarra", "Ourense",
           "Palencia", "Pontevedra", "Salamanca", "Santa Cruz de Tenerife", "Segovia", "Sevilla", "Soria", "Tarragona", "Teruel", "Toledo", "Valencia",
           "Valladolid", "Zamora", "Zaragoza" ],
  "FR" => [ "Auvergne-Rhône-Alpes", "Bourgogne-Franche-Comté", "Bretagne", "Centre-Val de Loire", "Corse", "Grand Est", "Hauts-de-France", "Île-de-France",
           "Normandie", "Nouvelle-Aquitaine", "Occitanie", "Pays de la Loire", "Provence-Alpes-Côte d'Azur" ],
  "GB" => [ "England", "Scotland", "Wales", "Northern Ireland" ],
  "DE" => [ "Baden-Württemberg", "Bayern", "Berlin", "Brandenburg", "Bremen", "Hamburg", "Hessen", "Mecklenburg-Vorpommern", "Niedersachsen",
           "Nordrhein-Westfalen", "Rheinland-Pfalz", "Saarland", "Sachsen", "Sachsen-Anhalt", "Schleswig-Holstein", "Thüringen" ],
  "IT" => [ "Abruzzo", "Basilicata", "Calabria", "Campania", "Emilia-Romagna", "Friuli-Venezia Giulia", "Lazio", "Liguria", "Lombardia", "Marche", "Molise",
           "Piemonte", "Puglia", "Sardegna", "Sicilia", "Toscana", "Trentino-Alto Adige", "Umbria", "Valle d'Aosta", "Veneto" ],
  "PT" => [ "Aveiro", "Beja", "Braga", "Bragança", "Castelo Branco", "Coimbra", "Évora", "Faro", "Guarda", "Leiria", "Lisboa", "Portalegre", "Porto",
           "Santarém", "Setúbal", "Viana do Castelo", "Vila Real", "Viseu", "Açores", "Madeira" ]
}.freeze

COUNTRY_DEFAULTS = {
  "ES" => { enabled: true, default_locale: "es", currency: "EUR", vat_rate: 21, position: 1 },
  "FR" => { enabled: false, default_locale: "fr", currency: "EUR", vat_rate: 20, position: 2 },
  "GB" => { enabled: false, default_locale: "en", currency: "GBP", vat_rate: 20, position: 3 },
  "DE" => { enabled: false, default_locale: "de", currency: "EUR", vat_rate: 19, position: 4 },
  "IT" => { enabled: false, default_locale: "it", currency: "EUR", vat_rate: 22, position: 5 },
  "PT" => { enabled: false, default_locale: "pt", currency: "EUR", vat_rate: 23, position: 6 }
}.freeze

COUNTRY_DEFAULTS.each do |code, attributes|
  country = Country.find_or_initialize_by(code: code)
  # Never re-disable a country an admin already launched.
  country.assign_attributes(attributes.except(:enabled))
  country.enabled = attributes[:enabled] if country.new_record?
  country.save!
  REGIONS.fetch(code).each_with_index do |name, index|
    region = country.regions.find_or_initialize_by(code: "#{code.downcase}-#{name.parameterize}")
    region.update!(name: name, position: index)
  end
end
