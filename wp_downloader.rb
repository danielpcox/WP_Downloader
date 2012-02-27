#!/home/danielpcox/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

# ############# The Washington Post Downloader #############
#
# Downloads and merges the day's Epaper into three sections. Ignores the Sports section.
# (requires pdftk, wget, and the nokogiri gem)

require 'open-uri'
require 'nokogiri'

todays_date = Time.now.strftime("%Y-%m-%d")

puts "Fetching today's paper..."

["A", "B", "C"].each do |section|
  file = open("http://www.washingtonpost.com/todays_paper?dt=#{todays_date}&bk=#{section}&pg=1")
  doc = Nokogiri::HTML(file)
  num_pages = doc.css("li.last a").first.content.to_i

  # if the Epaper hasn't come out yet...
  if num_pages == 0
    puts "EPAPER NOT OUT YET."
    exit 0
  end

  %x(mkdir -p #{todays_date}/#{section})

  puts "* Getting #{section} section (#{num_pages} pages)..."
  merge_list = ""
  for i in 1..num_pages do 
    puts "  - page " << i.to_s
    %x(wget -q -O #{todays_date}/#{section}/#{section}x#{i}.pdf http://www.washingtonpost.com/rw/WashingtonPost/Content/Epaper/#{todays_date}/#{section}x#{i}.pdf)
    this_pdf_path = "#{todays_date}/#{section}/#{section}x#{i}.pdf"
    if File.zero?(this_pdf_path)
      puts "! SKIPPING UNEXPECTEDLY EMPTY FILE #{this_pdf_path}"
    elsif !File.exists?(this_pdf_path)
      puts "! SKIPPING UNEXPECTEDLY MISSING FILE #{this_pdf_path}"
    else
      merge_list << " " << this_pdf_path
    end
  end

  puts "* Merging #{section} section..."
  %x(pdftk #{merge_list} cat output #{todays_date}/#{section}_section.pdf)
end

puts "* Cleaning up..."
%x(rm -rf #{todays_date}/A)
%x(rm -rf #{todays_date}/B)
%x(rm -rf #{todays_date}/C)
puts "Done!"
