GAMES = [
  [ "fortnite", "Fortnite", 60 ], [ "league-of-legends", "League of Legends", 25 ], [ "valorant", "Valorant", 30 ], [ "counter-strike-2", "Counter-Strike 2", 45 ],
  [ "minecraft", "Minecraft", 35 ], [ "ea-sports-fc", "EA Sports FC", 70 ], [ "call-of-duty-warzone", "Call of Duty: Warzone", 110 ], [ "cyberpunk-2077", "Cyberpunk 2077", 150 ],
  [ "gta-v", "GTA V", 65 ], [ "baldurs-gate-3", "Baldur's Gate 3", 120 ], [ "marvel-rivals", "Marvel Rivals", 105 ], [ "monster-hunter-wilds", "Monster Hunter Wilds", 160 ],
  [ "elden-ring", "Elden Ring", 95 ], [ "apex-legends", "Apex Legends", 70 ], [ "microsoft-flight-simulator", "Microsoft Flight Simulator", 170 ]
].freeze

GAMES.each_with_index do |(slug, name, demand), index|
  Game.find_or_initialize_by(slug: slug).update!(name: name, demand: demand, position: index, active: true)
end
