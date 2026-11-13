S = SeedSupport unless defined?(S)

COLLECTIONS = [
  [ "minimalist", :theme, S.t6("El minimalista", "The Minimalist", "Le minimaliste", "Der Minimalist", "Il minimalista", "O minimalista"),
   S.t6("Líneas limpias, cero ruido", "Clean lines, zero noise", "Lignes épurées, zéro bruit", "Klare Linien, kein Lärm", "Linee pulite, zero rumore", "Linhas limpas, zero ruído"),
   { category: "gaming-pcs", tags: %w[minimalist whiteout] }, "#d5d9e2" ],
  [ "anime-lover", :theme, S.t6("Fan del anime", "The Anime Lover", "Fan d'anime", "Anime-Fan", "Amante degli anime", "Fã de anime"),
   S.t6("Builds con mucha personalidad", "Builds with personality", "Des configs pleines de personnalité", "Builds mit Persönlichkeit", "Build con personalità", "Builds com personalidade"),
   { category: "gaming-pcs", tags: %w[anime sakura] }, "#f472b6" ],
  [ "competitive", :theme, S.t6("Jugador competitivo", "The Competitive Gamer", "Joueur compétitif", "Kompetitiver Gamer", "Giocatore competitivo", "Jogador competitivo"),
   S.t6("Máximos FPS para esports", "Max FPS for esports", "Un max de FPS pour l'esport", "Maximale FPS für E-Sport", "FPS al massimo per gli esport", "FPS máximos para esports"),
   { category: "gaming-pcs", tags: %w[competitive max_performance] }, "#06c4b0" ],
  [ "rgb-builds", :theme, S.t6("Amantes del RGB", "RGB Everything", "Tout en RVB", "Alles RGB", "Tutto RGB", "Tudo RGB"),
   S.t6("Cuanta más luz, mejor", "The more light the better", "Plus il y a de lumière, mieux c'est", "Je mehr Licht, desto besser", "Più luce c'è, meglio è", "Quanto mais luz, melhor"),
   { category: "gaming-pcs", tags: %w[rgb rainbow] }, "#a855f7" ],
  [ "minimalist-gamer", :gamer_profile, S.t6("El minimalista", "The Minimalist", "Le minimaliste", "Der Minimalist", "Il minimalista", "O minimalista"), nil, { category: "gaming-pcs", tags: %w[minimalist] }, nil ],
  [ "streamer", :gamer_profile, S.t6("El streamer", "The Streamer", "Le streamer", "Der Streamer", "Lo streamer", "O streamer"), nil, { category: "gaming-pcs", min_price: 1200 }, nil ],
  [ "budget-gamer", :gamer_profile, S.t6("Jugador con presupuesto", "The Budget Gamer", "Le joueur malin", "Der Sparfuchs", "Il gamer low cost", "Jogador económico"), nil, { category: "gaming-pcs", max_price: 800 }, nil ],
  [ "fortnite-pcs", :game, S.t6("Fortnite", "Fortnite", "Fortnite", "Fortnite", "Fortnite", "Fortnite"), nil, { category: "gaming-pcs", max_price: 1200, sort: "value" }, nil ],
  [ "warzone-pcs", :game, S.t6("Call of Duty", "Call of Duty", "Call of Duty", "Call of Duty", "Call of Duty", "Call of Duty"), nil, { category: "gaming-pcs", min_price: 900, sort: "performance" }, nil ],
  [ "lol-pcs", :game, S.t6("League of Legends", "League of Legends", "League of Legends", "League of Legends", "League of Legends", "League of Legends"), nil, { category: "gaming-pcs", max_price: 700 }, nil ],
  [ "rtx-50-series", :home_section, S.t6("NVIDIA RTX serie 40 y 50", "NVIDIA RTX 40 & 50 series", "NVIDIA RTX séries 40 et 50", "NVIDIA RTX 40er & 50er", "NVIDIA RTX serie 40 e 50", "NVIDIA RTX séries 40 e 50"), nil,
   { category: "gpus", f: { "gpu_model" => %w[rtx_4060 rtx_4060ti rtx_4070 rtx_4070s rtx_4070tis rtx_4080s rtx_4090 rtx_5060 rtx_5060ti rtx_5070 rtx_5070ti rtx_5080 rtx_5090] } }, nil ],
  [ "pcs-under-1000", :home_section, S.t6("PCs gaming por menos de 1.000 €", "Gaming PCs under €1,000", "PC gamer à moins de 1 000 €", "Gaming-PCs unter 1.000 €", "PC gaming sotto i 1.000 €", "PCs gaming abaixo de 1000 €"),
   S.t6("Listos para jugar sin arruinarte", "Ready to play without breaking the bank", "Prêts à jouer sans se ruiner", "Spielbereit, ohne pleite zu gehen", "Pronti a giocare senza spendere troppo", "Prontos a jogar sem gastar demais"),
   { category: "gaming-pcs", max_price: 1000, sort: "value" }, nil ],
  [ "free-shipping", :home_section, S.t6("Envío gratis", "Free shipping", "Livraison gratuite", "Kostenloser Versand", "Spedizione gratuita", "Envio grátis"), nil, { free_shipping: "1" }, nil ]
].freeze

COLLECTIONS.each_with_index do |(slug, kind, title, subtitle, query, color), index|
  Collection.find_or_initialize_by(slug: slug).update!(
    kind: kind, title_translations: title, subtitle_translations: subtitle || {}, query: query.deep_stringify_keys,
    accent_color: color, position: index, active: true, show_on_home: kind == :home_section
  )
end
