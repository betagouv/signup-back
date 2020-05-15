require "csv"

INPUT_FILE = "./input.csv"
OUTPUT_FILE = "./email_to_validate.txt"

email_to_validate_file = File.open(OUTPUT_FILE, "w")

CSV.foreach(INPUT_FILE, headers: true, strip: true, liberal_parsing: true) do |row|
  sleep 0.75
  response = HTTP.get("https://entreprise.data.gouv.fr/api/sirene/v1/siret/#{row["siret"]}")
  unless response.status.success?
    puts "\e[31m#{row["siret"]} not found!\e[0m"
    next
  end

  activite_principale = response.parse["etablissement"]["activite_principale"]
  nom_raison_sociale = response.parse["etablissement"]["nom_raison_sociale"]
  libelle_activite_principale = response.parse["etablissement"]["libelle_activite_principale"]
  puts "#{row["siret"]} - #{libelle_activite_principale} - #{nom_raison_sociale}"

  unless [
    "84", # SERVICES D’ADMINISTRATION PUBLIQUE ET DE DÉFENSE ; SERVICES DE SÉCURITÉ SOCIALE OBLIGATOIRE
    "85", # ENSEIGNEMENT
    "86", # ACTIVITÉS POUR LA SANTÉ HUMAINE
    "88", # Action sociale sans hébergement
  ].include? activite_principale[0, 2]
    puts "\e[31m#{row["siret"]} does not appear to be of a public service organization siret!\e[0m"
  end

  email_to_validate_file.puts row["resp_traitement_email"]
end

puts "NB: please validate email list written in #{OUTPUT_FILE}"
puts "Submit the file on https://app.debounce.io/"
puts "Error code documentation can be found here: https://debounce.io/resources/help-desk/understanding-results/result-codes/"
