# Default per-country legal references used to render the legal pages. Values are
# proper names of statutes and authorities, so they are kept in their official
# language. Admins can override any key through Country#legal.
class LegalFacts
  COMMON = {
    "company_name" => "PCMarket Marketplace S.L.",
    "company_address" => "Calle de Ejemplo 1, 28001 Madrid, España",
    "company_tax_id" => "B00000000",
    "company_registry" => "Registro Mercantil de Madrid, Tomo 0000, Folio 00, Hoja M-000000",
    "privacy_email" => "privacidad@pcmarket.example",
    "legal_email" => "legal@pcmarket.example",
    "dsa_contact_email" => "dsa@pcmarket.example",
    "dsa_regulation" => "Regulation (EU) 2022/2065 (Digital Services Act)",
    "dac7" => "Council Directive (EU) 2021/514 (DAC7)",
    "gdpr" => "Regulation (EU) 2016/679 (GDPR)"
  }.freeze

  BY_COUNTRY = {
    "ES" => {
      "data_authority" => "Agencia Española de Protección de Datos (AEPD) — www.aepd.es",
      "data_law" => "Ley Orgánica 3/2018 (LOPDGDD)",
      "consumer_law" => "Real Decreto Legislativo 1/2007 (TRLGDCU)",
      "consumer_authority" => "Dirección General de Consumo de la comunidad autónoma correspondiente y Juntas Arbitrales de Consumo",
      "ecommerce_law" => "Ley 34/2002 (LSSI-CE)",
      "cookie_law" => "Artículo 22.2 LSSI-CE",
      "courts" => "los juzgados y tribunales del domicilio del consumidor",
      "warranty_years" => "3",
      "withdrawal_days" => "14",
      "complaints" => "Hojas de reclamaciones oficiales disponibles a petición del usuario"
    },
    "FR" => {
      "data_authority" => "Commission Nationale de l'Informatique et des Libertés (CNIL) — www.cnil.fr",
      "data_law" => "Loi n° 78-17 du 6 janvier 1978 (Informatique et Libertés)",
      "consumer_law" => "Code de la consommation (articles L221-1 et suivants)",
      "consumer_authority" => "DGCCRF et médiateur de la consommation désigné",
      "ecommerce_law" => "Loi n° 2004-575 du 21 juin 2004 (LCEN)",
      "cookie_law" => "Article 82 de la loi Informatique et Libertés",
      "courts" => "les juridictions du domicile du consommateur",
      "warranty_years" => "2",
      "withdrawal_days" => "14",
      "complaints" => "Médiation de la consommation (article L612-1 du Code de la consommation)"
    },
    "GB" => {
      "data_authority" => "Information Commissioner's Office (ICO) — ico.org.uk",
      "data_law" => "UK GDPR and Data Protection Act 2018",
      "consumer_law" => "Consumer Rights Act 2015 and Consumer Contracts (Information, Cancellation and Additional Charges) Regulations 2013",
      "consumer_authority" => "Trading Standards and Citizens Advice consumer service",
      "ecommerce_law" => "Electronic Commerce (EC Directive) Regulations 2002",
      "cookie_law" => "Privacy and Electronic Communications Regulations 2003 (PECR)",
      "courts" => "the courts of England and Wales, or of Scotland or Northern Ireland if you live there",
      "warranty_years" => "6",
      "withdrawal_days" => "14",
      "complaints" => "Alternative dispute resolution through an approved ADR provider"
    },
    "DE" => {
      "data_authority" => "Zuständige Landesdatenschutzbehörde bzw. BfDI — www.bfdi.bund.de",
      "data_law" => "Bundesdatenschutzgesetz (BDSG)",
      "consumer_law" => "§§ 312 ff., 355 BGB",
      "consumer_authority" => "Verbraucherzentralen der Länder",
      "ecommerce_law" => "§ 5 Digitale-Dienste-Gesetz (DDG)",
      "cookie_law" => "§ 25 Telekommunikation-Digitale-Dienste-Datenschutz-Gesetz (TDDDG)",
      "courts" => "die Gerichte am Wohnsitz des Verbrauchers",
      "warranty_years" => "2",
      "withdrawal_days" => "14",
      "complaints" => "Wir sind nicht bereit und nicht verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen (§ 36 VSBG)."
    },
    "IT" => {
      "data_authority" => "Garante per la protezione dei dati personali — www.garanteprivacy.it",
      "data_law" => "D.Lgs. 196/2003 (Codice privacy) come modificato dal D.Lgs. 101/2018",
      "consumer_law" => "D.Lgs. 206/2005 (Codice del Consumo)",
      "consumer_authority" => "Autorità Garante della Concorrenza e del Mercato (AGCM)",
      "ecommerce_law" => "D.Lgs. 70/2003",
      "cookie_law" => "Art. 122 Codice privacy e Linee guida cookie del Garante (2021)",
      "courts" => "il foro del luogo di residenza del consumatore",
      "warranty_years" => "2",
      "withdrawal_days" => "14",
      "complaints" => "Procedure ADR ai sensi degli artt. 141 e ss. del Codice del Consumo"
    },
    "PT" => {
      "data_authority" => "Comissão Nacional de Proteção de Dados (CNPD) — www.cnpd.pt",
      "data_law" => "Lei n.º 58/2019",
      "consumer_law" => "Decreto-Lei n.º 24/2014 e Decreto-Lei n.º 84/2021",
      "consumer_authority" => "Direção-Geral do Consumidor e entidades de Resolução Alternativa de Litígios (RAL)",
      "ecommerce_law" => "Decreto-Lei n.º 7/2004",
      "cookie_law" => "Lei n.º 41/2004",
      "courts" => "os tribunais do domicílio do consumidor",
      "warranty_years" => "3",
      "withdrawal_days" => "14",
      "complaints" => "Livro de Reclamações Eletrónico — www.livroreclamacoes.pt"
    }
  }.freeze

  def self.for(code)
    COMMON.merge(BY_COUNTRY.fetch(code.to_s.upcase, {}))
  end
end
