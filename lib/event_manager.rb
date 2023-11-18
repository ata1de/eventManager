# puts "Event Manager Initialize!"

# contents = File.read('lib/event_attendees.csv')
# lines = File.readlines('lib/event_attendees.csv')

# #Extracting only the names from the spreadsheet
# lines.each_with_index do |line,index|
#   next if index == 0
#   colums = line.split(',')
#   name = colums[2]
#   puts name
# end

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

#função criada para tornar um padrão o zip de 5 números
#Se tiver menos ele completa com 0
#se tiver mais que 5, ocorre um slice até o 5 número
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

#Funçãi criada para o output de agradecimento ser individual com base no id
def save_thank_your_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thank_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

#Função criada para usar a api
def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  #forma de testar se funciona e se não sai outro output
  begin
    #Extrai os representantes, com base no codigo zip, pais e o seu cargo
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )

    #pega os oficiais
    legislators = legislators.officials

    #Extrai os nomes e se houver mais de um junta com uma virgula
    legislator_names = legislators.map(&:name)
    legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts 'EventManager initialized.'

#Abre o arquivo CSV, modificando a primeira linha para ser o header e não intereferir nos outros como symbolo
contents = CSV.open(
  'lib/event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
#Le o arquivo erb e o transforma para erb
template_letter = File.read('index.erb')
erb_templates = ERB.new template_letter

contents.each do |row|
  id = row[:ID]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  #Extrai o resultado do erb usando o método binding (preciso estuda-lo)
  form_letter = erb_templates.result(binding)

  save_thank_your_letter(id,form_letter)
end
