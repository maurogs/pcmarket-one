S = SeedSupport unless defined?(S)

PC_FILTERS = %w[cpu_brand cpu_model cpu_cores cpu_cooler_type cpu_cooler_brand gpu_chipset gpu_model gpu_memory memory_capacity memory_type
                storage_capacity storage_interface motherboard_brand motherboard_form_factor motherboard_networking case_brand case_form_factor case_color
                psu_brand psu_wattage lighting keyboard_layout warranty].freeze
INPUT_FILTERS = %w[peripheral_brand connection lighting includes_box warranty].freeze

# slug => [icon, names, parent, filters, description]
CATEGORIES = [
  [ "gaming-pcs", :gamepad, S.t6("PCs gaming", "Gaming PCs", "PC gamer", "Gaming-PCs", "PC da gaming", "PCs gaming"), nil, PC_FILTERS - %w[keyboard_layout],
   S.t6("Ordenadores gaming de segunda mano y nuevos, montados por vendedores particulares y tiendas especializadas.", "Second-hand and new gaming PCs built by private sellers and specialist shops.",
        "PC gamer d'occasion et neufs, montés par des particuliers et des boutiques spécialisées.", "Gebrauchte und neue Gaming-PCs von privaten Verkäufern und Fachhändlern.",
        "PC da gaming usati e nuovi, assemblati da privati e negozi specializzati.", "PCs gaming usados e novos, montados por particulares e lojas especializadas.") ],
  [ "gpus", :layers, S.t6("Tarjetas gráficas", "Graphics cards", "Cartes graphiques", "Grafikkarten", "Schede video", "Placas gráficas"), nil, %w[gpu_chipset gpu_model gpu_memory lighting includes_box warranty],
   S.t6("Compra y vende GPUs NVIDIA, AMD e Intel con protección al comprador.", "Buy and sell NVIDIA, AMD and Intel GPUs with buyer protection.", "Achetez et vendez des GPU NVIDIA, AMD et Intel avec protection acheteur.",
        "Kaufe und verkaufe NVIDIA-, AMD- und Intel-GPUs mit Käuferschutz.", "Compra e vendi GPU NVIDIA, AMD e Intel con protezione acquirente.", "Compre e venda GPUs NVIDIA, AMD e Intel com proteção do comprador.") ],
  [ "components", :cpu, S.t6("Componentes", "Components", "Composants", "Komponenten", "Componenti", "Componentes"), nil, %w[includes_box warranty], nil ],
  [ "cpus", :cpu, S.t6("Procesadores", "CPUs", "Processeurs", "Prozessoren", "Processori", "Processadores"), "components", %w[cpu_brand cpu_model cpu_cores cpu_socket includes_box warranty], nil ],
  [ "cpu-coolers", :zap, S.t6("Refrigeración", "CPU coolers", "Refroidissement", "CPU-Kühler", "Dissipatori", "Refrigeração"), "components", %w[cpu_cooler_type cpu_cooler_brand cpu_socket lighting], nil ],
  [ "motherboards", :grid, S.t6("Placas base", "Motherboards", "Cartes mères", "Mainboards", "Schede madri", "Motherboards"), "components", %w[motherboard_brand motherboard_form_factor motherboard_networking cpu_socket memory_type], nil ],
  [ "memory", :layers, S.t6("Memoria RAM", "Memory", "Mémoire RAM", "Arbeitsspeicher", "Memoria RAM", "Memória RAM"), "components", %w[memory_capacity memory_type memory_brand memory_modules memory_form_factor lighting], nil ],
  [ "storage", :package, S.t6("Almacenamiento", "Storage", "Stockage", "Speicher", "Archiviazione", "Armazenamento"), "components", %w[storage_capacity storage_interface storage_brand storage_form_factor], nil ],
  [ "cases", :package, S.t6("Cajas", "Cases", "Boîtiers", "Gehäuse", "Case", "Caixas"), "components", %w[case_brand case_form_factor case_color lighting], nil ],
  [ "case-fans", :refresh, S.t6("Ventiladores", "Case fans", "Ventilateurs", "Lüfter", "Ventole", "Ventoinhas"), "components", %w[lighting cpu_cooler_brand], nil ],
  [ "power-supplies", :zap, S.t6("Fuentes de alimentación", "Power supplies", "Alimentations", "Netzteile", "Alimentatori", "Fontes de alimentação"), "components", %w[psu_brand psu_wattage psu_form_factor psu_efficiency], nil ],
  [ "other-components", :settings, S.t6("Otros componentes", "Other components", "Autres composants", "Sonstige Komponenten", "Altri componenti", "Outros componentes"), "components", [], nil ],
  [ "peripherals", :keyboard, S.t6("Periféricos", "Peripherals", "Périphériques", "Peripherie", "Periferiche", "Periféricos"), nil, %w[includes_box warranty], nil ],
  [ "monitors", :monitor, S.t6("Monitores", "Monitors", "Écrans", "Monitore", "Monitor", "Monitores"), "peripherals", %w[peripheral_brand monitor_size monitor_resolution refresh_rate panel_type], nil ],
  [ "keyboards", :keyboard, S.t6("Teclados", "Keyboards", "Claviers", "Tastaturen", "Tastiere", "Teclados"), "peripherals", %w[peripheral_brand keyboard_layout keyboard_switch keyboard_size connection lighting], nil ],
  [ "mice", :sparkles, S.t6("Ratones", "Mice", "Souris", "Mäuse", "Mouse", "Ratos"), "peripherals", %w[peripheral_brand connection lighting], nil ],
  [ "headsets", :headphones, S.t6("Auriculares", "Headsets", "Casques", "Headsets", "Cuffie", "Auscultadores"), "peripherals", %w[peripheral_brand connection], nil ],
  [ "speakers", :headphones, S.t6("Altavoces", "Speakers", "Enceintes", "Lautsprecher", "Altoparlanti", "Colunas"), "peripherals", %w[peripheral_brand connection], nil ],
  [ "controllers", :gamepad, S.t6("Mandos", "Controllers", "Manettes", "Controller", "Controller", "Comandos"), "peripherals", %w[peripheral_brand console_platform connection], nil ],
  [ "webcams", :eye, S.t6("Webcams y streaming", "Webcams & streaming", "Webcams et streaming", "Webcams & Streaming", "Webcam e streaming", "Webcams e streaming"), "peripherals", %w[peripheral_brand], nil ],
  [ "vr", :eye, S.t6("Realidad virtual", "VR", "Réalité virtuelle", "VR", "Realtà virtuale", "Realidade virtual"), "peripherals", %w[peripheral_brand], nil ],
  [ "sim-racing", :gamepad, S.t6("Simracing", "Sim racing", "Sim racing", "Sim-Racing", "Sim racing", "Sim racing"), "peripherals", %w[peripheral_brand console_platform], nil ],
  [ "laptops", :laptop, S.t6("Portátiles", "Laptops", "Ordinateurs portables", "Laptops", "Notebook", "Portáteis"), nil, %w[laptop_brand cpu_model gpu_model memory_capacity storage_capacity laptop_screen keyboard_layout battery_health warranty], nil ],
  [ "gaming-laptops", :laptop, S.t6("Portátiles gaming", "Gaming laptops", "PC portables gamer", "Gaming-Laptops", "Notebook da gaming", "Portáteis gaming"), "laptops", [], nil ],
  [ "everyday-laptops", :laptop, S.t6("Portátiles y ultrabooks", "Laptops & ultrabooks", "Portables et ultrabooks", "Notebooks & Ultrabooks", "Notebook e ultrabook", "Portáteis e ultrabooks"), "laptops", [], nil ],
  [ "macbooks", :laptop, S.t6("MacBook", "MacBook", "MacBook", "MacBook", "MacBook", "MacBook"), "laptops", [], nil ],
  [ "mobile", :phone, S.t6("Móviles y tablets", "Phones & tablets", "Smartphones et tablettes", "Handys & Tablets", "Smartphone e tablet", "Telemóveis e tablets"), nil, %w[phone_brand phone_storage battery_health includes_box warranty], nil ],
  [ "phones", :phone, S.t6("Móviles", "Phones", "Smartphones", "Smartphones", "Smartphone", "Telemóveis"), "mobile", %w[network], nil ],
  [ "tablets", :phone, S.t6("Tablets", "Tablets", "Tablettes", "Tablets", "Tablet", "Tablets"), "mobile", %w[network], nil ],
  [ "smartwatches", :clock, S.t6("Smartwatches", "Smartwatches", "Montres connectées", "Smartwatches", "Smartwatch", "Smartwatches"), "mobile", [], nil ],
  [ "consoles", :gamepad, S.t6("Consolas", "Consoles", "Consoles", "Konsolen", "Console", "Consolas"), nil, %w[console_platform includes_box warranty], nil ],
  [ "home-consoles", :gamepad, S.t6("Consolas de sobremesa", "Home consoles", "Consoles de salon", "Heimkonsolen", "Console da casa", "Consolas de mesa"), "consoles", %w[console_edition storage_capacity], nil ],
  [ "handhelds", :gamepad, S.t6("Consolas portátiles", "Handhelds", "Consoles portables", "Handhelds", "Console portatili", "Consolas portáteis"), "consoles", %w[storage_capacity], nil ],
  [ "retro-gaming", :gamepad, S.t6("Retro", "Retro gaming", "Rétrogaming", "Retro-Gaming", "Retrogaming", "Retro"), "consoles", [], nil ],
  [ "video-games", :sparkles, S.t6("Videojuegos", "Video games", "Jeux vidéo", "Videospiele", "Videogiochi", "Videojogos"), "consoles", [], nil ],
  [ "workstations", :monitor, S.t6("Workstations", "Workstations", "Stations de travail", "Workstations", "Workstation", "Workstations"), nil, PC_FILTERS - %w[keyboard_layout case_color lighting], nil ],
  [ "creator-pcs", :monitor, S.t6("PCs para creadores", "Creator PCs", "PC pour créateurs", "Creator-PCs", "PC per creator", "PCs para criadores"), "workstations", [], nil ],
  [ "ai-rigs", :cpu, S.t6("Equipos para IA local", "Local AI rigs", "Machines pour IA locale", "Lokale KI-Rigs", "PC per IA locale", "Equipamentos para IA local"), "workstations", [], nil ],
  [ "servers-nas", :layers, S.t6("Servidores y NAS", "Servers & NAS", "Serveurs et NAS", "Server & NAS", "Server e NAS", "Servidores e NAS"), "workstations", [], nil ],
  [ "more", :sparkles, S.t6("Más", "More", "Plus", "Mehr", "Altro", "Mais"), nil, [], nil ],
  [ "accessories", :tag, S.t6("Accesorios", "Accessories", "Accessoires", "Zubehör", "Accessori", "Acessórios"), "more", [], nil ],
  [ "software", :grid, S.t6("Software", "Software", "Logiciels", "Software", "Software", "Software"), "more", [], nil ],
  [ "collectibles", :star, S.t6("Coleccionables", "Collectibles", "Objets de collection", "Sammlerstücke", "Collezionabili", "Colecionáveis"), "more", [], nil ]
].freeze

filters = FilterDefinition.all.index_by(&:key)
CATEGORIES.each_with_index do |(slug, icon, names, parent_slug, filter_keys, description), index|
  category = Category.find_or_initialize_by(slug: slug)
  category.update!(icon: icon, name_translations: names, parent: parent_slug && Category.find_by!(slug: parent_slug), position: index,
                   show_in_menu: parent_slug.nil?, active: true, pc_finder: slug == "gaming-pcs", description_translations: description || category.description_translations)
  filter_keys.each_with_index do |key, position|
    CategoryFilter.find_or_create_by!(category: category, filter_definition: filters.fetch(key)) { |cf| cf.position = position }
  end
end
