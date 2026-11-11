# Filter definitions shown in the catalogue sidebar and the listing form.
# Options are [value, label] where label is a String (same in every language)
# or a Hash of locale => label. Non-featured options appear under "show more".
S = SeedSupport
OTHER = [ "other", S::OTHER ].freeze
YES_NO = [ [ "yes", S.t6("Sí", "Yes", "Oui", "Ja", "Sì", "Sim") ], [ "no", S.t6("No", "No", "Non", "Nein", "No", "Não") ] ].freeze

def brands(*names, more: [])
  names.map { |n| [ n.parameterize(separator: "_"), n ] } + [ OTHER ] + more.map { |n| [ n.parameterize(separator: "_"), n, false ] }
end

def sizes(list, unit = "GB", more: [])
  list.map { |n| [ n.to_s.downcase.tr(".", "_") + unit.downcase, "#{n}#{unit}" ] } + [ OTHER ] + more.map { |n| [ n.to_s.downcase.tr(".", "_") + unit.downcase, "#{n}#{unit}", false ] }
end

FILTERS = {
  cpu_brand: [ S.t6("Marca de CPU", "CPU brand", "Marque du CPU", "CPU-Marke", "Marca CPU", "Marca do CPU"), brands("Intel", "AMD", "Apple", "Qualcomm") ],
  cpu_model: [ S.t6("Procesador", "Processor", "Processeur", "Prozessor", "Processore", "Processador"), [
    [ "i3_12100f", "Intel Core i3-12100F", true, 9_000 ], [ "i5_10400f", "Intel Core i5-10400F", true, 8_500 ], [ "i5_12400f", "Intel Core i5-12400F", true, 12_000 ],
    [ "i5_13400f", "Intel Core i5-13400F", true, 14_000 ], [ "i5_14600k", "Intel Core i5-14600K", true, 18_500 ], [ "i7_6700", "Intel Core i7-6700", false, 6_000 ],
    [ "i7_12700k", "Intel Core i7-12700K", true, 18_000 ], [ "i7_13700k", "Intel Core i7-13700K", true, 20_000 ], [ "i7_14700k", "Intel Core i7-14700K", true, 21_000 ],
    [ "i9_13900k", "Intel Core i9-13900K", true, 22_500 ], [ "i9_14900k", "Intel Core i9-14900K", true, 23_000 ], [ "ultra7_265k", "Intel Core Ultra 7 265K", true, 21_500 ],
    [ "ultra9_285k", "Intel Core Ultra 9 285K", true, 23_500 ], [ "r5_3600", "AMD Ryzen 5 3600", true, 8_000 ], [ "r5_5600", "AMD Ryzen 5 5600", true, 11_000 ],
    [ "r5_5600x", "AMD Ryzen 5 5600X", true, 11_500 ], [ "r5_7600", "AMD Ryzen 5 7600", true, 15_000 ], [ "r5_9600x", "AMD Ryzen 5 9600X", true, 17_000 ],
    [ "r7_5700x3d", "AMD Ryzen 7 5700X3D", true, 15_500 ], [ "r7_5800x3d", "AMD Ryzen 7 5800X3D", true, 16_500 ], [ "r7_7700x", "AMD Ryzen 7 7700X", true, 18_000 ],
    [ "r7_7800x3d", "AMD Ryzen 7 7800X3D", true, 21_000 ], [ "r7_9800x3d", "AMD Ryzen 7 9800X3D", true, 24_000 ], [ "r9_7950x", "AMD Ryzen 9 7950X", true, 22_000 ],
    [ "r9_9950x3d", "AMD Ryzen 9 9950X3D", true, 25_000 ], [ "tr_7970x", "AMD Threadripper 7970X", false, 20_000 ], [ "xeon_w5", "Intel Xeon W5-2455X", false, 15_000 ],
    [ "apple_m2", "Apple M2", false, 14_000 ], [ "apple_m3", "Apple M3", false, 16_000 ], [ "apple_m4", "Apple M4", false, 18_000 ], [ "apple_m4_pro", "Apple M4 Pro", false, 20_000 ],
    [ "snapdragon_x_elite", "Snapdragon X Elite", false, 15_000 ], OTHER
  ].map { |v, l, f = true, score = nil| [ v, l, f, score && { "score" => score, "buyback_cents" => [ ((score - 7_000) / 6.0).round * 100, 0 ].max } ] } ],
  cpu_cores: [ S.t6("Núcleos de CPU", "CPU core count", "Nombre de cœurs", "CPU-Kerne", "Core CPU", "Núcleos de CPU"),
              [ 4, 6, 8, 10, 12, 14, 16, 20, 24 ].map { |n| [ "c#{n}", S.t6("#{n} núcleos", "#{n} cores", "#{n} cœurs", "#{n} Kerne", "#{n} core", "#{n} núcleos") ] } + [ OTHER ] +
              [ 2, 18, 28, 32, 64 ].map { |n| [ "c#{n}", S.t6("#{n} núcleos", "#{n} cores", "#{n} cœurs", "#{n} Kerne", "#{n} core", "#{n} núcleos"), false ] } ],
  cpu_cooler_type: [ S.t6("Refrigeración CPU", "CPU cooler type", "Type de refroidissement", "Kühlertyp", "Tipo di dissipatore", "Tipo de refrigeração"), [
    [ "air", S.t6("Aire", "Air", "Air", "Luft", "Aria", "Ar") ], [ "aio", "AIO" ], [ "custom_loop", S.t6("Custom loop", "Custom loop", "Watercooling custom", "Custom-Loop", "Custom loop", "Custom loop") ],
    [ "passive", S.t6("Pasiva", "Passive / fanless", "Passif", "Passiv", "Passivo", "Passiva"), false ], OTHER ] ],
  cpu_cooler_brand: [ S.t6("Marca del disipador", "CPU cooler brand", "Marque du ventirad", "Kühler-Marke", "Marca dissipatore", "Marca do cooler"),
                     brands("Arctic", "be quiet!", "Cooler Master", "Corsair", "Deepcool", "EK", "Lian Li", "Noctua", "NZXT", "Thermalright", "Thermaltake",
                            more: [ "Alphacool", "Endorfy", "Fractal Design", "Gelid Solutions", "ID-Cooling", "Scythe", "Silverstone" ]) ],
  cpu_socket: [ S.t6("Socket", "Socket", "Socket", "Sockel", "Socket", "Socket"), [ [ "lga1851", "LGA 1851" ], [ "lga1700", "LGA 1700" ], [ "lga1200", "LGA 1200" ], [ "am5", "AM5" ], [ "am4", "AM4" ], OTHER, [ "str5", "sTR5", false ], [ "lga4677", "LGA 4677", false ] ] ],
  gpu_chipset: [ S.t6("Chipset gráfico", "GPU chipset", "Chipset graphique", "GPU-Chipsatz", "Chipset GPU", "Chipset gráfico"),
                [ [ "nvidia", "NVIDIA" ], [ "amd", "AMD" ], [ "intel", "Intel" ], [ "apple", "Apple" ], [ "integrated", S.t6("Integrada", "Integrated", "Intégré", "Integriert", "Integrata", "Integrada") ], [ "none", S.t6("Ninguna", "None", "Aucun", "Keine", "Nessuna", "Nenhuma") ] ] ],
  gpu_model: [ S.t6("Tarjeta gráfica", "Graphics card", "Carte graphique", "Grafikkarte", "Scheda video", "Placa gráfica"), [
    [ "gtx_1060", "GeForce GTX 1060 6GB", false, 4_200 ], [ "gtx_1660s", "GeForce GTX 1660 Super", true, 6_000 ], [ "rtx_2060", "GeForce RTX 2060", true, 7_500 ],
    [ "rtx_3060", "GeForce RTX 3060", true, 8_700 ], [ "rtx_3060ti", "GeForce RTX 3060 Ti", true, 11_500 ], [ "rtx_3070", "GeForce RTX 3070", true, 13_500 ],
    [ "rtx_3080", "GeForce RTX 3080", true, 17_500 ], [ "rtx_3090", "GeForce RTX 3090", false, 19_500 ], [ "rtx_4060", "GeForce RTX 4060", true, 10_500 ],
    [ "rtx_4060ti", "GeForce RTX 4060 Ti", true, 13_500 ], [ "rtx_4070", "GeForce RTX 4070", true, 17_800 ], [ "rtx_4070s", "GeForce RTX 4070 Super", true, 20_500 ],
    [ "rtx_4070tis", "GeForce RTX 4070 Ti Super", true, 24_000 ], [ "rtx_4080s", "GeForce RTX 4080 Super", true, 28_500 ], [ "rtx_4090", "GeForce RTX 4090", true, 36_000 ],
    [ "rtx_5060", "GeForce RTX 5060", true, 12_000 ], [ "rtx_5060ti", "GeForce RTX 5060 Ti 16GB", true, 15_000 ], [ "rtx_5070", "GeForce RTX 5070", true, 22_000 ],
    [ "rtx_5070ti", "GeForce RTX 5070 Ti", true, 27_000 ], [ "rtx_5080", "GeForce RTX 5080", true, 32_000 ], [ "rtx_5090", "GeForce RTX 5090", true, 48_000 ],
    [ "rx_580", "Radeon RX 580 8GB", false, 4_300 ], [ "rx_6600", "Radeon RX 6600", true, 8_000 ], [ "rx_6700xt", "Radeon RX 6700 XT", true, 12_500 ],
    [ "rx_6800xt", "Radeon RX 6800 XT", true, 19_000 ], [ "rx_7600", "Radeon RX 7600", true, 10_800 ], [ "rx_7700xt", "Radeon RX 7700 XT", true, 17_000 ],
    [ "rx_7800xt", "Radeon RX 7800 XT", true, 20_000 ], [ "rx_7900xtx", "Radeon RX 7900 XTX", true, 30_000 ], [ "rx_9060xt", "Radeon RX 9060 XT 16GB", true, 15_500 ],
    [ "rx_9070", "Radeon RX 9070", true, 24_000 ], [ "rx_9070xt", "Radeon RX 9070 XT", true, 28_000 ], [ "arc_b580", "Intel Arc B580", true, 14_000 ],
    [ "rtx_a4000", "NVIDIA RTX A4000", false, 15_000 ], [ "rtx_6000_ada", "NVIDIA RTX 6000 Ada", false, 38_000 ], OTHER
  ].map { |v, l, f = true, score = nil| [ v, l, f, score && { "score" => score, "buyback_cents" => [ ((score - 5_000) / 3.5).round * 100, 0 ].max } ] } ],
  gpu_memory: [ S.t6("Memoria gráfica", "GPU memory", "Mémoire GPU", "Grafikspeicher", "Memoria GPU", "Memória gráfica"), sizes([ 4, 6, 8, 10, 12, 16, 20, 24, 32 ], more: [ 2, 3, 48 ]) ],
  memory_capacity: [ S.t6("Memoria RAM", "Memory capacity", "Mémoire vive", "Arbeitsspeicher", "Memoria RAM", "Memória RAM"), sizes([ 8, 16, 24, 32, 48, 64, 128 ], more: [ 4, 96, 192, 256 ]) ],
  memory_type: [ S.t6("Tipo de memoria", "Memory type", "Type de mémoire", "Speichertyp", "Tipo di memoria", "Tipo de memória"), [ [ "ddr3", "DDR3" ], [ "ddr4", "DDR4" ], [ "ddr5", "DDR5" ], [ "lpddr5", "LPDDR5", false ], OTHER ] ],
  memory_brand: [ S.t6("Marca de memoria", "Memory brand", "Marque de mémoire", "Speicher-Marke", "Marca memoria", "Marca da memória"),
                 brands("ADATA", "Corsair", "Crucial", "G.Skill", "Kingston", "Patriot Memory", "Samsung", "TeamGroup", more: [ "Lexar", "Patriot", "SK hynix", "Micron", "Thermaltake" ]) ],
  memory_modules: [ S.t6("Número de módulos", "Number of modules", "Nombre de barrettes", "Anzahl Module", "Numero di moduli", "Número de módulos"), [ [ "m1", "1" ], [ "m2", "2" ], [ "m4", "4" ], [ "m8", "8", false ], OTHER ] ],
  memory_form_factor: [ S.t6("Formato de memoria", "Memory form factor", "Format de mémoire", "Speicher-Formfaktor", "Formato memoria", "Formato da memória"),
                       [ [ "dimm", S.t6("DIMM (sobremesa)", "DIMM (desktop)", "DIMM (bureau)", "DIMM (Desktop)", "DIMM (desktop)", "DIMM (desktop)") ], [ "sodimm", S.t6("SO-DIMM (portátil)", "SO-DIMM (laptop)", "SO-DIMM (portable)", "SO-DIMM (Laptop)", "SO-DIMM (notebook)", "SO-DIMM (portátil)") ], OTHER ] ],
  storage_capacity: [ S.t6("Almacenamiento", "Storage capacity", "Stockage", "Speicherkapazität", "Archiviazione", "Armazenamento"),
                     [ [ "lt256gb", "< 256GB" ], [ "256gb", "256GB" ], [ "512gb", "512GB" ], [ "1tb", "1TB" ], [ "2tb", "2TB" ], [ "4tb", "4TB" ], [ "8tb", "8TB" ], OTHER, [ "128gb", "128GB", false ], [ "16tb", "16TB", false ] ] ],
  storage_interface: [ S.t6("Tipo de almacenamiento", "Storage interface", "Type de stockage", "Speicher-Schnittstelle", "Tipo di archiviazione", "Tipo de armazenamento"),
                      [ [ "sata_hdd", "SATA HDD" ], [ "sata_ssd", "SATA SSD" ], [ "nvme_ssd", "NVMe SSD" ], OTHER ] ],
  storage_brand: [ S.t6("Marca de almacenamiento", "Storage brand", "Marque de stockage", "Speicher-Marke", "Marca archiviazione", "Marca do armazenamento"),
                  brands("Crucial", "Kingston", "Samsung", "Seagate", "Western Digital", "WD Black", "Sabrent", "Lexar", more: [ "SK hynix", "Toshiba", "Intenso", "PNY", "MSI" ]) ],
  storage_form_factor: [ S.t6("Formato de almacenamiento", "Storage form factor", "Format de stockage", "Speicher-Formfaktor", "Formato archiviazione", "Formato do armazenamento"),
                        [ [ "m2", "M.2" ], [ "2_5", "2.5\"" ], [ "3_5", "3.5\"" ], OTHER ] ],
  motherboard_brand: [ S.t6("Marca de placa base", "Motherboard brand", "Marque de carte mère", "Mainboard-Marke", "Marca scheda madre", "Marca da motherboard"),
                      brands("ASRock", "Asus", "Gigabyte", "MSI", "NZXT", more: [ "Biostar", "Supermicro" ]) ],
  motherboard_form_factor: [ S.t6("Formato de placa base", "Motherboard form factor", "Format de carte mère", "Mainboard-Formfaktor", "Formato scheda madre", "Formato da motherboard"),
                            [ [ "atx", "ATX" ], [ "matx", "Micro-ATX" ], [ "itx", "Mini-ITX" ], [ "eatx", "E-ATX", false ], OTHER ] ],
  motherboard_networking: [ S.t6("Conectividad de placa", "Motherboard networking", "Réseau de la carte mère", "Mainboard-Netzwerk", "Rete scheda madre", "Rede da motherboard"),
                           [ [ "eth_wifi", S.t6("Ethernet y Wi-Fi", "Ethernet and Wi-Fi", "Ethernet et Wi-Fi", "Ethernet und WLAN", "Ethernet e Wi-Fi", "Ethernet e Wi-Fi") ], [ "eth", S.t6("Solo Ethernet", "Ethernet only", "Ethernet seulement", "Nur Ethernet", "Solo Ethernet", "Apenas Ethernet") ], OTHER ] ],
  case_brand: [ S.t6("Marca de caja", "Case brand", "Marque du boîtier", "Gehäuse-Marke", "Marca case", "Marca da caixa"),
               brands("Antec", "be quiet!", "Corsair", "Cooler Master", "Fractal Design", "Hyte", "Lian Li", "Montech", "NZXT", "Phanteks", "Thermaltake", "Mars Gaming",
                      more: [ "Asus", "Deepcool", "Jonsbo", "MSI", "Nox", "Sharkoon", "Silverstone", "Tempest", "Zalman" ]) ],
  case_form_factor: [ S.t6("Tipo de caja", "Case form factor", "Format du boîtier", "Gehäuse-Formfaktor", "Formato case", "Formato da caixa"), [
    [ "mid_tower", S.t6("Semitorre", "Mid-tower", "Moyen tour", "Midi-Tower", "Middle tower", "Torre média") ], [ "mini_tower", S.t6("Minitorre", "Mini-tower", "Mini tour", "Mini-Tower", "Mini tower", "Mini torre") ],
    [ "full_tower", S.t6("Torre completa", "Full-tower", "Grand tour", "Big-Tower", "Full tower", "Torre completa") ], [ "sff", S.t6("Formato pequeño (SFF)", "Small form factor", "Petit format (SFF)", "Small Form Factor", "Small form factor", "Formato pequeno (SFF)") ],
    OTHER, [ "open_frame", S.t6("Bancada abierta", "Open frame", "Châssis ouvert", "Open Frame", "Open frame", "Estrutura aberta"), false ] ] ],
  case_color: [ S.t6("Color de la caja", "Case colour", "Couleur du boîtier", "Gehäusefarbe", "Colore case", "Cor da caixa"), [
    [ "black", S.t6("Negro", "Black", "Noir", "Schwarz", "Nero", "Preto") ], [ "white", S.t6("Blanco", "White", "Blanc", "Weiß", "Bianco", "Branco") ],
    [ "silver", S.t6("Plata", "Silver", "Argent", "Silber", "Argento", "Prateado") ], [ "gray", S.t6("Gris", "Grey", "Gris", "Grau", "Grigio", "Cinzento") ],
    [ "multicolor", S.t6("Multicolor", "Multicolour", "Multicolore", "Mehrfarbig", "Multicolore", "Multicolor") ], OTHER,
    [ "pink", S.t6("Rosa", "Pink", "Rose", "Rosa", "Rosa", "Rosa"), false ], [ "blue", S.t6("Azul", "Blue", "Bleu", "Blau", "Blu", "Azul"), false ],
    [ "red", S.t6("Rojo", "Red", "Rouge", "Rot", "Rosso", "Vermelho"), false ], [ "green", S.t6("Verde", "Green", "Vert", "Grün", "Verde", "Verde"), false ],
    [ "wood", S.t6("Madera", "Wood", "Bois", "Holz", "Legno", "Madeira"), false ] ] ],
  psu_brand: [ S.t6("Marca de fuente", "Power supply brand", "Marque d'alimentation", "Netzteil-Marke", "Marca alimentatore", "Marca da fonte"),
              brands("be quiet!", "Corsair", "Cooler Master", "EVGA", "MSI", "NZXT", "Seasonic", "Thermaltake", more: [ "Antec", "Deepcool", "FSP", "Gigabyte", "Mars Gaming", "Nox", "Super Flower", "Tempest" ]) ],
  psu_wattage: [ S.t6("Potencia de la fuente", "Power supply wattage", "Puissance d'alimentation", "Netzteil-Leistung", "Potenza alimentatore", "Potência da fonte"),
                [ [ "lt500w", "< 500W" ], [ "500w", "500W" ], [ "550w", "550W" ], [ "650w", "650W" ], [ "750w", "750W" ], [ "850w", "850W" ], [ "1000w", "1000W" ], [ "1200w", "1200W" ], OTHER, [ "1600w", "1600W", false ] ] ],
  psu_form_factor: [ S.t6("Formato de fuente", "Power supply form factor", "Format d'alimentation", "Netzteil-Formfaktor", "Formato alimentatore", "Formato da fonte"),
                    [ [ "atx", "ATX" ], [ "sfx", "SFX" ], [ "sfx_l", "SFX-L" ], OTHER ] ],
  psu_efficiency: [ S.t6("Certificación", "Efficiency rating", "Certification", "Effizienz", "Certificazione", "Certificação"),
                   [ [ "bronze", "80+ Bronze" ], [ "gold", "80+ Gold" ], [ "platinum", "80+ Platinum" ], [ "titanium", "80+ Titanium" ], OTHER ] ],
  lighting: [ S.t6("Iluminación", "Lighting", "Éclairage", "Beleuchtung", "Illuminazione", "Iluminação"),
             [ [ "argb", S.t6("RGB direccionable", "Addressable RGB", "RGB adressable", "Adressierbares RGB", "RGB indirizzabile", "RGB endereçável") ], [ "static", S.t6("Estática", "Static", "Statique", "Statisch", "Statica", "Estática") ], [ "none", S.t6("Sin iluminación", "None", "Aucun", "Keine", "Nessuna", "Sem iluminação") ] ] ],
  monitor_size: [ S.t6("Tamaño de pantalla", "Screen size", "Taille d'écran", "Bildschirmgröße", "Dimensione schermo", "Tamanho do ecrã"),
                 [ [ "24", "24\"" ], [ "27", "27\"" ], [ "32", "32\"" ], [ "34", "34\"" ], [ "gt34", "> 34\"" ], OTHER ] ],
  monitor_resolution: [ S.t6("Resolución", "Resolution", "Résolution", "Auflösung", "Risoluzione", "Resolução"),
                       [ [ "1080p", "1080p (Full HD)" ], [ "1440p", "1440p (QHD)" ], [ "2160p", "2160p (4K)" ], [ "uwqhd", "3440×1440 (UWQHD)" ], OTHER ] ],
  refresh_rate: [ S.t6("Frecuencia", "Refresh rate", "Taux de rafraîchissement", "Bildwiederholrate", "Frequenza di aggiornamento", "Taxa de atualização"),
                 [ [ "60", "60 Hz" ], [ "144", "144 Hz" ], [ "165", "165 Hz" ], [ "240", "240 Hz" ], [ "360", "360 Hz" ], OTHER ] ],
  panel_type: [ S.t6("Panel", "Panel type", "Type de dalle", "Panel-Typ", "Tipo di pannello", "Tipo de painel"), [ [ "ips", "IPS" ], [ "va", "VA" ], [ "tn", "TN" ], [ "oled", "OLED" ], OTHER ] ],
  keyboard_layout: [ S.t6("Distribución de teclado", "Keyboard layout", "Disposition du clavier", "Tastaturlayout", "Layout tastiera", "Disposição do teclado"),
                    [ [ "es", S.t6("Español (ES)", "Spanish (ES)", "Espagnol (ES)", "Spanisch (ES)", "Spagnolo (ES)", "Espanhol (ES)") ], [ "pt", S.t6("Portugués (PT)", "Portuguese (PT)", "Portugais (PT)", "Portugiesisch (PT)", "Portoghese (PT)", "Português (PT)") ],
                     [ "fr", S.t6("Francés (AZERTY)", "French (AZERTY)", "Français (AZERTY)", "Französisch (AZERTY)", "Francese (AZERTY)", "Francês (AZERTY)") ], [ "de", S.t6("Alemán (QWERTZ)", "German (QWERTZ)", "Allemand (QWERTZ)", "Deutsch (QWERTZ)", "Tedesco (QWERTZ)", "Alemão (QWERTZ)") ],
                     [ "it", S.t6("Italiano", "Italian", "Italien", "Italienisch", "Italiano", "Italiano") ], [ "uk", S.t6("Inglés (UK)", "English (UK)", "Anglais (UK)", "Englisch (UK)", "Inglese (UK)", "Inglês (UK)") ],
                     [ "us", S.t6("Inglés (US)", "English (US)", "Anglais (US)", "Englisch (US)", "Inglese (US)", "Inglês (US)") ], OTHER ] ],
  keyboard_switch: [ S.t6("Tipo de switch", "Switch type", "Type de switch", "Switch-Typ", "Tipo di switch", "Tipo de switch"),
                    [ [ "linear", S.t6("Lineal", "Linear", "Linéaire", "Linear", "Lineare", "Linear") ], [ "tactile", S.t6("Táctil", "Tactile", "Tactile", "Taktil", "Tattile", "Tátil") ],
                     [ "clicky", "Clicky" ], [ "optical", S.t6("Óptico", "Optical", "Optique", "Optisch", "Ottico", "Ótico") ], [ "membrane", S.t6("Membrana", "Membrane", "Membrane", "Rubberdome", "Membrana", "Membrana") ], OTHER ] ],
  keyboard_size: [ S.t6("Formato de teclado", "Keyboard size", "Format du clavier", "Tastaturgröße", "Formato tastiera", "Formato do teclado"),
                  [ [ "full", "100%" ], [ "tkl", "TKL (80%)" ], [ "75", "75%" ], [ "65", "65%" ], [ "60", "60%" ], OTHER ] ],
  connection: [ S.t6("Conexión", "Connection", "Connexion", "Verbindung", "Connessione", "Ligação"),
               [ [ "wired", S.t6("Con cable", "Wired", "Filaire", "Kabelgebunden", "Cablata", "Com fios") ], [ "wireless", S.t6("Inalámbrica 2,4 GHz", "Wireless 2.4GHz", "Sans fil 2,4 GHz", "Kabellos 2,4 GHz", "Wireless 2,4 GHz", "Sem fios 2,4 GHz") ], [ "bluetooth", "Bluetooth" ] ] ],
  peripheral_brand: [ S.t6("Marca", "Brand", "Marque", "Marke", "Marca", "Marca"),
                     brands("Logitech", "Razer", "SteelSeries", "Corsair", "HyperX", "Asus", "Keychron", "Sony", "Microsoft", "Samsung", "LG", "Dell", "BenQ", "AOC",
                            more: [ "Alienware", "Glorious", "Ducky", "Wooting", "Fanatec", "Thrustmaster", "Meta", "Elgato", "Cooler Master", "Audio-Technica", "Sennheiser", "Beyerdynamic", "Gigabyte", "MSI", "Philips", "Acer" ]) ],
  laptop_screen: [ S.t6("Pantalla del portátil", "Laptop screen", "Écran du portable", "Laptop-Bildschirm", "Schermo notebook", "Ecrã do portátil"),
                  [ [ "13", "13\"" ], [ "14", "14\"" ], [ "15", "15-15.6\"" ], [ "16", "16\"" ], [ "17", "17-18\"" ], OTHER ] ],
  laptop_brand: [ S.t6("Marca del portátil", "Laptop brand", "Marque du portable", "Laptop-Marke", "Marca notebook", "Marca do portátil"),
                 brands("Apple", "Asus", "Acer", "Dell", "HP", "Lenovo", "MSI", "Razer", "Microsoft", "Samsung", more: [ "Alienware", "Gigabyte", "Huawei", "LG", "Medion", "Framework" ]) ],
  phone_brand: [ S.t6("Marca", "Brand", "Marque", "Marke", "Marca", "Marca"), brands("Apple", "Samsung", "Google", "Xiaomi", "OnePlus", "Motorola", "Nothing", more: [ "Oppo", "Realme", "Sony", "Huawei", "Honor", "Fairphone" ]) ],
  phone_storage: [ S.t6("Capacidad", "Storage", "Capacité", "Speicher", "Memoria", "Capacidade"), sizes([ 64, 128, 256, 512 ], more: [ 32 ]) + [ [ "1tb", "1TB" ] ] ],
  network: [ S.t6("Conectividad móvil", "Mobile network", "Réseau mobile", "Mobilfunk", "Rete mobile", "Rede móvel"), [ [ "5g", "5G" ], [ "4g", "4G" ], [ "wifi", S.t6("Solo Wi-Fi", "Wi-Fi only", "Wi-Fi uniquement", "Nur WLAN", "Solo Wi-Fi", "Apenas Wi-Fi") ] ] ],
  battery_health: [ S.t6("Salud de la batería", "Battery health", "Santé de la batterie", "Akkuzustand", "Salute batteria", "Saúde da bateria"),
                   [ [ "b100", "100%" ], [ "b90", "90-99%" ], [ "b80", "80-89%" ], [ "blt80", "< 80%" ] ] ],
  console_platform: [ S.t6("Plataforma", "Platform", "Plateforme", "Plattform", "Piattaforma", "Plataforma"), [
    [ "ps5", "PlayStation 5" ], [ "ps4", "PlayStation 4" ], [ "xbox_series", "Xbox Series X|S" ], [ "xbox_one", "Xbox One" ], [ "switch_2", "Nintendo Switch 2" ], [ "switch", "Nintendo Switch" ],
    [ "steam_deck", "Steam Deck" ], [ "rog_ally", "ROG Ally" ], [ "legion_go", "Legion Go" ], [ "retro", S.t6("Retro", "Retro", "Rétro", "Retro", "Retro", "Retro") ], [ "pc", "PC" ], OTHER ] ],
  console_edition: [ S.t6("Edición", "Edition", "Édition", "Edition", "Edizione", "Edição"),
                    [ [ "disc", S.t6("Con lector de discos", "Disc edition", "Édition standard (lecteur)", "Disc-Edition", "Con lettore", "Com leitor de discos") ], [ "digital", S.t6("Digital", "Digital", "Numérique", "Digital", "Digitale", "Digital") ], OTHER ] ],
  includes_box: [ S.t6("Incluye caja original", "Original box included", "Boîte d'origine incluse", "Originalverpackung", "Scatola originale inclusa", "Caixa original incluída"), YES_NO ],
  warranty: [ S.t6("Garantía", "Warranty", "Garantie", "Garantie", "Garanzia", "Garantia"), [
    [ "manufacturer", S.t6("Garantía del fabricante vigente", "Manufacturer warranty", "Garantie constructeur", "Herstellergarantie", "Garanzia del produttore", "Garantia do fabricante") ],
    [ "seller", S.t6("Garantía del vendedor", "Seller warranty", "Garantie du vendeur", "Verkäufergarantie", "Garanzia del venditore", "Garantia do vendedor") ],
    [ "none", S.t6("Sin garantía", "No warranty", "Sans garantie", "Keine Garantie", "Nessuna garanzia", "Sem garantia") ] ] ],
  product_labels: [ S.t6("Etiquetas", "Product labels", "Étiquettes", "Produkt-Labels", "Etichette", "Etiquetas"), [
    [ "value_pc", S.t6("PCs económicos", "Value PCs", "PC petit budget", "Preiswerte PCs", "PC economici", "PCs económicos") ], [ "midrange_pc", S.t6("PCs gama media", "Mid-range PCs", "PC milieu de gamme", "Mittelklasse-PCs", "PC fascia media", "PCs gama média") ],
    [ "pro_pc", S.t6("PCs gama alta", "Pro gamer PCs", "PC haut de gamme", "High-End-PCs", "PC fascia alta", "PCs topo de gama") ], [ "value_gpu", S.t6("GPUs económicas", "Value GPUs", "GPU petit budget", "Preiswerte GPUs", "GPU economiche", "GPUs económicas") ],
    [ "midrange_gpu", S.t6("GPUs gama media", "Mid-range GPUs", "GPU milieu de gamme", "Mittelklasse-GPUs", "GPU fascia media", "GPUs gama média") ], [ "pro_gpu", S.t6("GPUs gama alta", "Pro gamer GPUs", "GPU haut de gamme", "High-End-GPUs", "GPU fascia alta", "GPUs topo de gama") ],
    [ "featured", S.t6("Destacado", "Featured", "En vedette", "Empfohlen", "In evidenza", "Destaque") ], [ "rare", S.t6("Rareza", "Rare", "Rare", "Selten", "Raro", "Raro") ] ] ],
  seller_tags: [ S.t6("Estilo", "Style tags", "Style", "Stil", "Stile", "Estilo"),
                %w[anime blackout compact competitive cozy glass lofi luxe max_performance minimalist noctua rainbow retro rgb sakura scifi space steampunk whiteout wood].map do |tag|
                  [ tag, { "en" => tag.tr("_", " ").capitalize.sub("Lofi", "Lo-fi").sub("Rgb", "RGB").sub("Scifi", "Sci-fi"),
                          "es" => { "anime" => "Anime", "blackout" => "Todo negro", "compact" => "Compacto", "competitive" => "Competitivo", "cozy" => "Acogedor", "glass" => "Cristal",
                                    "lofi" => "Lo-fi", "luxe" => "Lujo", "max_performance" => "Máximo rendimiento", "minimalist" => "Minimalista", "noctua" => "Noctua", "rainbow" => "Arcoíris",
                                    "retro" => "Retro", "rgb" => "RGB", "sakura" => "Sakura", "scifi" => "Ciencia ficción", "space" => "Espacial", "steampunk" => "Steampunk", "whiteout" => "Todo blanco", "wood" => "Madera" }[tag] } ]
                end ]
}.freeze

CARD_KEYS = %w[gpu_model cpu_model memory_capacity storage_capacity].freeze
COLLAPSED = %w[cpu_cooler_brand cpu_socket memory_brand storage_brand motherboard_brand motherboard_networking case_brand psu_brand psu_form_factor psu_efficiency includes_box warranty cpu_cores].freeze
NOT_IN_FORM = %w[product_labels seller_tags].freeze

FILTERS.each_with_index do |(key, (name, options)), index|
  definition = FilterDefinition.find_or_initialize_by(key: key.to_s)
  definition.update!(name_translations: S.translations(name), position: index, active: true, kind: :multi_select,
                     show_on_card: CARD_KEYS.include?(key.to_s), collapsed: COLLAPSED.include?(key.to_s),
                     in_listing_form: !NOT_IN_FORM.include?(key.to_s))
  options.each_with_index do |(value, label, featured, metadata), position|
    option = definition.filter_options.find_or_initialize_by(value: value)
    option.update!(label_translations: S.translations(label), position: position, featured: featured != false, metadata: metadata || option.metadata || {})
  end
end
