require 'open-uri'
require 'nokogiri'

class WP < Thor
  desc "download", "Downloads and assembles the Washington Post."
  class_option :date, :default => Time.now.strftime("%Y-%m-%d"), :banner => "YYYY-MM-DD", :desc => "date of paper to download (older than 2 weeks unavailable by WP policy)"
  class_option :location, :default => "~/.washingtonpost/", :banner => "/path/to/repo", :desc => "path to local paper repository"
  class_option :omit, :default => "D", :banner => "A,B,...", :desc => "sections to omit"
  def download
    root = File.expand_path(options[:location])

    # parse date
    begin
      date = Date.parse(options[:date]).to_s
    rescue
      puts "ERROR: Specified date is incorrectly formatted"
      exit 7
    end

    omit_list = options[:omit].split(/, ?/).map(&:upcase).sort
    sections_to_get = %w(A B C D) - omit_list
    
    puts "Fetching today's paper..."

    sections_to_get.each do |section|
      file = open("http://www.washingtonpost.com/todays_paper?dt=#{date}&bk=#{section}&pg=1")
      doc = Nokogiri::HTML(file)
      num_pages = doc.css("li.last a").first.content.to_i

      # if the Epaper hasn't come out yet...
      if num_pages == 0
        puts "ERROR: EPaper not out yet or scraping failure"
        exit 1
      end

      section_dir = File.join(root, date, section)
      unless system(%Q(mkdir -p #{section_dir}))
        puts %Q(ERROR: Unable to make directory "#{section_dir}")
        exit 2
      end

      puts "* Getting #{section} section (#{num_pages} pages)..."
      merge_list = ""
      for i in 1..num_pages do 
        puts "  - page " << i.to_s
        pdf_path = File.join(root, date, section,"#{section}x#{i}.pdf")
        wget_command = %Q(wget -q -O #{pdf_path} http://www.washingtonpost.com/rw/WashingtonPost/Content/Epaper/#{date}/#{section}x#{i}.pdf)
        unless system(wget_command)
          puts %Q(ERROR: Command failed: "#{wget_command}")
          exit 3
        end
        if File.zero?(pdf_path)
          puts "! SKIPPING UNEXPECTEDLY EMPTY FILE #{pdf_path}"
        elsif !File.exists?(pdf_path)
          puts "! SKIPPING UNEXPECTEDLY MISSING FILE #{pdf_path}"
        else
          merge_list << " " << pdf_path
        end
      end

      puts "* Merging #{section} section..."
      output_path = File.join(root, date, "#{section}_section.pdf")
      pdftk_command = %Q(pdftk #{merge_list} cat output #{output_path})
      unless system(pdftk_command)
        puts %Q(ERROR: Command failed: "#{pdftk_command}")
        exit 4
      end
    end

    puts "* Cleaning up..."
    sections_to_get.each do |section|
      section_path = File.join(root,date,section)
      rm_command = %Q(rm -rf #{section_path})
      unless system(rm_command)
        puts %Q(ERROR: Command failed: "#{rm_command}")
        exit 5
      end
    end
    puts "Done!"
  end
end
