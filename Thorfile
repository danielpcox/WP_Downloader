require 'open-uri'
require 'nokogiri'
require 'date'

class WP < Thor
  desc "download", "Downloads and assembles the 'Washington Post.'"
  method_option :date, :default => Time.now.strftime("%Y-%m-%d"), :banner => "YYYY-MM-DD", :desc => "date of paper to download (older than 2 weeks unavailable by WP policy)"
  method_option :location, :default => "~/.washingtonpost/", :banner => "/path/to/repo", :desc => "path to local paper repository"
  method_option :omit, :default => "D", :banner => "A,B,...", :desc => "sections to omit"
  def download
    # parse options
    root = File.expand_path(options[:location])
    date = parse_date
    omit_list = options[:omit] ? options[:omit].split(/, ?/).map(&:upcase).sort : []
    sections_to_get = %w(A B C D) - omit_list
    
    puts "Fetching paper for #{date}..."

    sections_to_get.each do |section|
      # use nokogiri to get the number of pages for section
      file = open("http://www.washingtonpost.com/todays_paper?dt=#{date}&bk=#{section}&pg=1")
      doc = Nokogiri::HTML(file)
      num_pages = doc.css("li.last a").first.content.to_i

      # if the Epaper hasn't come out yet...
      if num_pages == 0
        puts "ERROR: EPaper not out yet or scraping failure"
        exit 1
      end

      # make temporary directory for a section's pages
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

  desc "view [SECTION_LETTER]", "Views a downloaded 'Washington Post' section"
  method_option :viewer, :default => "evince 2>/dev/null"
  method_option :location, :default => "~/.washingtonpost/", :banner => "/path/to/repo", :desc => "path to local paper repository"
  method_option :date, :default => Time.now.strftime("%Y-%m-%d"), :banner => "YYYY-MM-DD", :desc => "date of paper to view"
  def view(section_letter = 'A')
    # parse options
    root = File.expand_path(options[:location])
    section = section_letter.upcase
    unless %w(A B C D).include?(section)
      puts %Q(ERROR: Invalid section letter "#{section_letter}")
      exit 9
    end
    date = parse_date
    section_path = File.join(root, date, "#{section}_section.pdf")

    # check for paper and prompt to download
    unless File.exist?(section_path)
      puts "Selected paper does not appear to exist. Download it? [y/N]"
      response = STDIN.gets.chomp
      if %w(y Y yes Yes YES).include?(response)
        invoke :download, [], options
      else
        exit 0
      end
    end

    # execute viewer on paper
    view_command = %Q(#{options[:viewer]} #{section_path} &)
    unless system(view_command)
      puts %Q(ERROR: View command failed: "#{view_command}")
      exit 8
    end
  end

  desc "clean", "Removes all but today's paper from the local paper repository"
  method_option :location, :default => "~/.washingtonpost/", :banner => "/path/to/repo", :desc => "path to local paper repository"
  def clean
    # parse option
    root = File.expand_path(options[:location])

    # foreach entry in the repo location, if date != today, delete it
    Dir.entries(root).each do |entry|
      date = Date.parse(entry) rescue next
      next if date == Date.today
      entry_path = File.join(root, entry)
      rm_command = %Q(rm -rf #{entry_path})
      if system(rm_command)
        puts %Q(Removed #{entry} paper from #{options[:location]})
      else
        puts %Q(ERROR: Command failed: "#{rm_command}")
        exit 9
      end
    end
  end

  private

  def parse_date
    begin
      return Date.parse(options[:date]).to_s
    rescue
      puts "ERROR: Specified date is incorrectly formatted"
      exit 7
    end
  end
end
