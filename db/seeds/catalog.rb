# Demo product catalogue: category slug => [image query, [[title, min €, max €, specs, brand]]].
# Gaming PCs, GPUs and laptops are generated from the filter options instead.
DEMO_CATALOG = {
  "cpus" => ["computer processor cpu", [
    ["AMD Ryzen 7 7800X3D", 300, 380, { "cpu_brand" => "amd", "cpu_model" => "r7_7800x3d", "cpu_cores" => "c8", "cpu_socket" => "am5" }, "AMD"],
    ["AMD Ryzen 5 5600X", 85, 120, { "cpu_brand" => "amd", "cpu_model" => "r5_5600x", "cpu_cores" => "c6", "cpu_socket" => "am4" }, "AMD"],
    ["AMD Ryzen 7 5800X3D", 210, 270, { "cpu_brand" => "amd", "cpu_model" => "r7_5800x3d", "cpu_cores" => "c8", "cpu_socket" => "am4" }, "AMD"],
    ["Intel Core i5-12400F", 85, 115, { "cpu_brand" => "intel", "cpu_model" => "i5_12400f", "cpu_cores" => "c6", "cpu_socket" => "lga1700" }, "Intel"],
    ["Intel Core i7-13700K", 260, 330, { "cpu_brand" => "intel", "cpu_model" => "i7_13700k", "cpu_cores" => "c16", "cpu_socket" => "lga1700" }, "Intel"],
    ["AMD Ryzen 9 7950X", 420, 520, { "cpu_brand" => "amd", "cpu_model" => "r9_7950x", "cpu_cores" => "c16", "cpu_socket" => "am5" }, "AMD"],
    ["Intel Core Ultra 7 265K", 280, 340, { "cpu_brand" => "intel", "cpu_model" => "ultra7_265k", "cpu_cores" => "c20", "cpu_socket" => "lga1851" }, "Intel"]]],
  "cpu-coolers" => ["cpu cooler fan heatsink", [
    ["Noctua NH-D15 chromax.black", 80, 110, { "cpu_cooler_type" => "air", "cpu_cooler_brand" => "noctua", "lighting" => "none" }, "Noctua"],
    ["Thermalright Peerless Assassin 120 SE", 30, 40, { "cpu_cooler_type" => "air", "cpu_cooler_brand" => "thermalright", "lighting" => "none" }, "Thermalright"],
    ["Arctic Liquid Freezer III 360", 75, 105, { "cpu_cooler_type" => "aio", "cpu_cooler_brand" => "arctic", "lighting" => "argb" }, "Arctic"],
    ["NZXT Kraken 280 RGB", 110, 150, { "cpu_cooler_type" => "aio", "cpu_cooler_brand" => "nzxt", "lighting" => "argb" }, "NZXT"]]],
  "motherboards" => ["computer motherboard", [
    ["MSI MAG B650 Tomahawk WiFi", 150, 190, { "motherboard_brand" => "msi", "motherboard_form_factor" => "atx", "motherboard_networking" => "eth_wifi", "cpu_socket" => "am5", "memory_type" => "ddr5" }, "MSI"],
    ["ASUS ROG Strix B550-F Gaming", 100, 140, { "motherboard_brand" => "asus", "motherboard_form_factor" => "atx", "motherboard_networking" => "eth", "cpu_socket" => "am4", "memory_type" => "ddr4" }, "Asus"],
    ["Gigabyte B760M DS3H DDR4", 75, 100, { "motherboard_brand" => "gigabyte", "motherboard_form_factor" => "matx", "motherboard_networking" => "eth", "cpu_socket" => "lga1700", "memory_type" => "ddr4" }, "Gigabyte"],
    ["ASRock B650I Lightning WiFi", 150, 190, { "motherboard_brand" => "asrock", "motherboard_form_factor" => "itx", "motherboard_networking" => "eth_wifi", "cpu_socket" => "am5", "memory_type" => "ddr5" }, "ASRock"]]],
  "memory" => ["ram memory modules", [
    ["Corsair Vengeance RGB 32GB (2x16) DDR5 6000 CL30", 85, 120, { "memory_capacity" => "32gb", "memory_type" => "ddr5", "memory_brand" => "corsair", "memory_modules" => "m2", "memory_form_factor" => "dimm", "lighting" => "argb" }, "Corsair"],
    ["G.Skill Trident Z5 Neo 64GB DDR5 6000", 170, 230, { "memory_capacity" => "64gb", "memory_type" => "ddr5", "memory_brand" => "g_skill", "memory_modules" => "m2", "memory_form_factor" => "dimm", "lighting" => "argb" }, "G.Skill"],
    ["Kingston Fury Beast 16GB (2x8) DDR4 3200", 30, 45, { "memory_capacity" => "16gb", "memory_type" => "ddr4", "memory_brand" => "kingston", "memory_modules" => "m2", "memory_form_factor" => "dimm", "lighting" => "none" }, "Kingston"],
    ["Crucial 32GB DDR5 SO-DIMM 5600 (portátil)", 60, 85, { "memory_capacity" => "32gb", "memory_type" => "ddr5", "memory_brand" => "crucial", "memory_modules" => "m2", "memory_form_factor" => "sodimm", "lighting" => "none" }, "Crucial"]]],
  "storage" => ["ssd solid state drive", [
    ["Samsung 990 Pro 2TB NVMe", 140, 190, { "storage_capacity" => "2tb", "storage_interface" => "nvme_ssd", "storage_brand" => "samsung", "storage_form_factor" => "m2" }, "Samsung"],
    ["WD Black SN850X 1TB", 75, 100, { "storage_capacity" => "1tb", "storage_interface" => "nvme_ssd", "storage_brand" => "wd_black", "storage_form_factor" => "m2" }, "WD"],
    ["Crucial MX500 1TB SATA", 55, 70, { "storage_capacity" => "1tb", "storage_interface" => "sata_ssd", "storage_brand" => "crucial", "storage_form_factor" => "2_5" }, "Crucial"],
    ["Seagate IronWolf 8TB NAS", 160, 210, { "storage_capacity" => "8tb", "storage_interface" => "sata_hdd", "storage_brand" => "seagate", "storage_form_factor" => "3_5" }, "Seagate"],
    ["Kingston NV2 500GB NVMe", 25, 38, { "storage_capacity" => "512gb", "storage_interface" => "nvme_ssd", "storage_brand" => "kingston", "storage_form_factor" => "m2" }, "Kingston"]]],
  "cases" => ["computer case tower", [
    ["Lian Li O11 Dynamic EVO blanca", 120, 160, { "case_brand" => "lian_li", "case_form_factor" => "mid_tower", "case_color" => "white", "lighting" => "none" }, "Lian Li"],
    ["Fractal Design North Charcoal", 110, 140, { "case_brand" => "fractal_design", "case_form_factor" => "mid_tower", "case_color" => "black", "lighting" => "none" }, "Fractal Design"],
    ["Hyte Y60 roja", 150, 190, { "case_brand" => "hyte", "case_form_factor" => "mid_tower", "case_color" => "red", "lighting" => "none" }, "Hyte"],
    ["NZXT H5 Flow negra", 70, 95, { "case_brand" => "nzxt", "case_form_factor" => "mid_tower", "case_color" => "black", "lighting" => "none" }, "NZXT"],
    ["Mars Gaming MC-ART ARGB", 45, 60, { "case_brand" => "mars_gaming", "case_form_factor" => "mid_tower", "case_color" => "black", "lighting" => "argb" }, "Mars Gaming"]]],
  "case-fans" => ["computer cooling fans rgb", [
    ["Pack 3 ventiladores Lian Li UNI FAN SL120 V2", 60, 85, { "lighting" => "argb", "cpu_cooler_brand" => "lian_li" }, "Lian Li"],
    ["Noctua NF-A12x25 PWM (x2)", 45, 60, { "lighting" => "none", "cpu_cooler_brand" => "noctua" }, "Noctua"],
    ["Arctic P12 PWM PST (pack 5)", 25, 35, { "lighting" => "none", "cpu_cooler_brand" => "arctic" }, "Arctic"]]],
  "power-supplies" => ["computer power supply", [
    ["Corsair RM850x 80+ Gold modular", 95, 130, { "psu_brand" => "corsair", "psu_wattage" => "850w", "psu_form_factor" => "atx", "psu_efficiency" => "gold" }, "Corsair"],
    ["be quiet! Pure Power 12 M 750W", 80, 105, { "psu_brand" => "be_quiet", "psu_wattage" => "750w", "psu_form_factor" => "atx", "psu_efficiency" => "gold" }, "be quiet!"],
    ["Seasonic Focus GX-1000", 140, 180, { "psu_brand" => "seasonic", "psu_wattage" => "1000w", "psu_form_factor" => "atx", "psu_efficiency" => "gold" }, "Seasonic"],
    ["Cooler Master V850 SFX Gold", 110, 150, { "psu_brand" => "cooler_master", "psu_wattage" => "850w", "psu_form_factor" => "sfx", "psu_efficiency" => "gold" }, "Cooler Master"]]],
  "other-components" => ["computer parts", [["Tarjeta Wi-Fi 6E PCIe con Bluetooth", 20, 40, {}, "TP-Link"], ["Cables extensores mallados 24 pines", 15, 30, {}, "CableMod"]]],
  "monitors" => ["computer monitor desk", [
    ["LG UltraGear 27GP850 27\" 1440p 180Hz", 220, 290, { "peripheral_brand" => "lg", "monitor_size" => "27", "monitor_resolution" => "1440p", "refresh_rate" => "165", "panel_type" => "ips" }, "LG"],
    ["Samsung Odyssey G9 49\" curvo", 650, 900, { "peripheral_brand" => "samsung", "monitor_size" => "gt34", "monitor_resolution" => "other", "refresh_rate" => "240", "panel_type" => "va" }, "Samsung"],
    ["AOC 24G2SP 24\" 165Hz", 110, 145, { "peripheral_brand" => "aoc", "monitor_size" => "24", "monitor_resolution" => "1080p", "refresh_rate" => "165", "panel_type" => "ips" }, "AOC"],
    ["ASUS ROG Swift OLED PG27AQDM 240Hz", 600, 780, { "peripheral_brand" => "asus", "monitor_size" => "27", "monitor_resolution" => "1440p", "refresh_rate" => "240", "panel_type" => "oled" }, "Asus"],
    ["Dell S3423DWC 34\" ultrapanorámico", 300, 380, { "peripheral_brand" => "dell", "monitor_size" => "34", "monitor_resolution" => "uwqhd", "refresh_rate" => "other", "panel_type" => "va" }, "Dell"]]],
  "keyboards" => ["mechanical keyboard", [
    ["Keychron Q1 Pro ISO-ES", 150, 200, { "peripheral_brand" => "keychron", "keyboard_layout" => "es", "keyboard_switch" => "tactile", "keyboard_size" => "75", "connection" => "bluetooth", "lighting" => "argb" }, "Keychron"],
    ["Logitech G915 TKL", 140, 190, { "peripheral_brand" => "logitech", "keyboard_layout" => "es", "keyboard_switch" => "linear", "keyboard_size" => "tkl", "connection" => "wireless", "lighting" => "argb" }, "Logitech"],
    ["Razer Huntsman V3 Pro", 170, 230, { "peripheral_brand" => "razer", "keyboard_layout" => "us", "keyboard_switch" => "optical", "keyboard_size" => "full", "connection" => "wired", "lighting" => "argb" }, "Razer"],
    ["Wooting 60HE+", 150, 190, { "peripheral_brand" => "wooting", "keyboard_layout" => "uk", "keyboard_switch" => "optical", "keyboard_size" => "60", "connection" => "wired", "lighting" => "argb" }, "Wooting"]]],
  "mice" => ["gaming mouse", [
    ["Logitech G Pro X Superlight 2", 110, 145, { "peripheral_brand" => "logitech", "connection" => "wireless", "lighting" => "none" }, "Logitech"],
    ["Razer DeathAdder V3 Pro", 100, 140, { "peripheral_brand" => "razer", "connection" => "wireless", "lighting" => "none" }, "Razer"],
    ["Logitech G502 X Plus", 90, 130, { "peripheral_brand" => "logitech", "connection" => "wireless", "lighting" => "argb" }, "Logitech"],
    ["SteelSeries Rival 3", 20, 30, { "peripheral_brand" => "steelseries", "connection" => "wired", "lighting" => "argb" }, "SteelSeries"]]],
  "headsets" => ["gaming headset headphones", [
    ["HyperX Cloud II Wireless", 80, 110, { "peripheral_brand" => "hyperx", "connection" => "wireless" }, "HyperX"],
    ["SteelSeries Arctis Nova Pro Wireless", 250, 320, { "peripheral_brand" => "steelseries", "connection" => "wireless" }, "SteelSeries"],
    ["Sony WH-1000XM5", 220, 290, { "peripheral_brand" => "sony", "connection" => "bluetooth" }, "Sony"]]],
  "speakers" => ["computer speakers desk", [["Logitech Z407 2.1", 55, 75, { "peripheral_brand" => "logitech", "connection" => "bluetooth" }, "Logitech"], ["Creative Pebble V3", 25, 35, { "peripheral_brand" => "other", "connection" => "wired" }, "Creative"]]],
  "controllers" => ["game controller gamepad", [
    ["Mando DualSense Edge PS5", 150, 190, { "peripheral_brand" => "sony", "console_platform" => "ps5", "connection" => "wireless" }, "Sony"],
    ["Mando Xbox Elite Series 2", 110, 150, { "peripheral_brand" => "microsoft", "console_platform" => "xbox_series", "connection" => "wireless" }, "Microsoft"],
    ["8BitDo Ultimate Bluetooth", 45, 60, { "peripheral_brand" => "other", "console_platform" => "pc", "connection" => "bluetooth" }, "8BitDo"]]],
  "webcams" => ["webcam streaming camera", [["Elgato Facecam MK.2", 110, 150, { "peripheral_brand" => "elgato" }, "Elgato"], ["Logitech C920 HD Pro", 45, 65, { "peripheral_brand" => "logitech" }, "Logitech"], ["Elgato Stream Deck MK.2", 120, 150, { "peripheral_brand" => "elgato" }, "Elgato"]]],
  "vr" => ["virtual reality headset", [["Meta Quest 3 128GB", 380, 460, { "peripheral_brand" => "meta" }, "Meta"], ["Valve Index kit completo", 600, 800, { "peripheral_brand" => "other" }, "Valve"]]],
  "sim-racing" => ["racing simulator wheel", [["Fanatec CSL DD 8Nm + pedales", 450, 600, { "peripheral_brand" => "fanatec", "console_platform" => "pc" }, "Fanatec"], ["Logitech G29 + palanca de cambios", 170, 230, { "peripheral_brand" => "logitech", "console_platform" => "ps5" }, "Logitech"], ["Thrustmaster T300 RS GT", 220, 280, { "peripheral_brand" => "thrustmaster", "console_platform" => "ps5" }, "Thrustmaster"]]],
  "phones" => ["smartphone", [
    ["iPhone 15 Pro 256GB titanio natural", 780, 950, { "phone_brand" => "apple", "phone_storage" => "256gb", "network" => "5g", "battery_health" => "b90" }, "Apple"],
    ["Samsung Galaxy S24 Ultra 512GB", 800, 1000, { "phone_brand" => "samsung", "phone_storage" => "512gb", "network" => "5g", "battery_health" => "b100" }, "Samsung"],
    ["Google Pixel 8 Pro 128GB", 450, 580, { "phone_brand" => "google", "phone_storage" => "128gb", "network" => "5g", "battery_health" => "b90" }, "Google"],
    ["Xiaomi Redmi Note 13 Pro 256GB", 200, 260, { "phone_brand" => "xiaomi", "phone_storage" => "256gb", "network" => "5g", "battery_health" => "b100" }, "Xiaomi"],
    ["iPhone 13 128GB", 330, 420, { "phone_brand" => "apple", "phone_storage" => "128gb", "network" => "5g", "battery_health" => "b80" }, "Apple"]]],
  "tablets" => ["tablet ipad", [["iPad Air M2 11\" 128GB Wi-Fi", 520, 620, { "phone_brand" => "apple", "phone_storage" => "128gb", "network" => "wifi", "battery_health" => "b100" }, "Apple"], ["Samsung Galaxy Tab S9 FE", 280, 360, { "phone_brand" => "samsung", "phone_storage" => "128gb", "network" => "wifi", "battery_health" => "b90" }, "Samsung"]]],
  "smartwatches" => ["smartwatch", [["Apple Watch Series 9 45mm", 280, 360, { "phone_brand" => "apple", "battery_health" => "b90" }, "Apple"], ["Garmin Forerunner 265", 250, 320, { "phone_brand" => "other", "battery_health" => "b100" }, "Garmin"]]],
  "home-consoles" => ["playstation xbox console", [
    ["PlayStation 5 Slim con lector + 2 mandos", 400, 480, { "console_platform" => "ps5", "console_edition" => "disc", "storage_capacity" => "1tb" }, "Sony"],
    ["Xbox Series X 1TB", 380, 460, { "console_platform" => "xbox_series", "console_edition" => "disc", "storage_capacity" => "1tb" }, "Microsoft"],
    ["PlayStation 5 Pro", 650, 750, { "console_platform" => "ps5", "console_edition" => "digital", "storage_capacity" => "2tb" }, "Sony"],
    ["Xbox Series S 512GB", 190, 240, { "console_platform" => "xbox_series", "console_edition" => "digital", "storage_capacity" => "512gb" }, "Microsoft"]]],
  "handhelds" => ["handheld game console", [
    ["Steam Deck OLED 512GB", 470, 560, { "console_platform" => "steam_deck", "storage_capacity" => "512gb" }, "Valve"],
    ["Nintendo Switch OLED blanca", 240, 300, { "console_platform" => "switch", "storage_capacity" => "other" }, "Nintendo"],
    ["Nintendo Switch 2 + Mario Kart World", 450, 520, { "console_platform" => "switch_2", "storage_capacity" => "256gb" }, "Nintendo"],
    ["ASUS ROG Ally Z1 Extreme", 420, 520, { "console_platform" => "rog_ally", "storage_capacity" => "512gb" }, "Asus"]]],
  "retro-gaming" => ["retro video game console", [["Super Nintendo PAL con caja", 120, 200, { "console_platform" => "retro" }, "Nintendo"], ["Sega Mega Drive II + 5 juegos", 90, 150, { "console_platform" => "retro" }, "Sega"], ["Game Boy Color edición Pokémon", 110, 180, { "console_platform" => "retro" }, "Nintendo"]]],
  "video-games" => ["video games collection", [["Lote 10 juegos PS5", 120, 200, { "console_platform" => "ps5" }, nil], ["The Legend of Zelda: Tears of the Kingdom", 35, 50, { "console_platform" => "switch" }, "Nintendo"], ["Elden Ring Collector's Edition", 180, 260, { "console_platform" => "ps5" }, nil]]],
  "servers-nas" => ["server rack nas", [["Synology DS923+ con 4x4TB", 700, 900, { "storage_capacity" => "4tb" }, "Synology"], ["Dell PowerEdge R730 2x Xeon 128GB", 450, 700, { "memory_capacity" => "128gb" }, "Dell"]]],
  "accessories" => ["desk setup accessories", [["Alfombrilla XXL 90x40 Artisan", 30, 50, {}, "Artisan"], ["Brazo de monitor doble con gas", 40, 70, {}, "Ergotron"], ["Silla gaming Secretlab Titan Evo", 330, 420, {}, "Secretlab"]]],
  "software" => ["software box", [["Windows 11 Pro licencia retail", 90, 140, {}, "Microsoft"]]],
  "collectibles" => ["collectible figure", [["Figura Master Chief 30 cm edición limitada", 90, 160, {}, nil], ["Teclado retro IBM Model M 1989", 120, 200, {}, "IBM"]]]
}.freeze

DEMO_IMAGES = {
  "gaming-pcs" => ["gaming computer", "computer case rgb", "custom pc build"], "gpus" => ["graphics card", "nvidia geforce"], "laptops" => ["gaming laptop", "laptop computer"],
  "macbooks" => ["macbook"], "creator-pcs" => ["workstation computer"], "ai-rigs" => ["computer server gpu"]
}.freeze
