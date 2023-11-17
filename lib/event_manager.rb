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

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]

  # if zipcode.nil?
  #   '00000'
  # elsif zipcode.length < 5
  #   zipcode.rjust(5, '0')
  # elsif zipcode.length > 5
  #   zipcode[0..4]
  # else
  #   zipcode
  # end
end


puts 'EventManager initialized.'

contents = CSV.open(
  'lib/event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = civic_info.representative_info_by_adress(
    addres: zipcode,
    levels: 'country',
    roles: ['legislatorUpperBody', 'legislatorLowerBody'],
  )

  legislators = legislators.officials

  puts "#{name} #{zipcode} #{legislators}"
end
