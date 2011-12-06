require "graebel/version"
require "date"
require "net/https"
require "ostruct"
require "nokogiri"

module Graebel

  class Job < OpenStruct

    DEFAULT_BASE_URL = 'https://graebel-hr.silkroad.com/epostings'

    def self.all(base_url = DEFAULT_BASE_URL)
      document = fetch_document(base_url + '/index.cfm?fuseaction=app.jobsearch')
      jobs = []

      document.search("table.cssSearchResults tr").each_with_index do |element, index|
        next if index == 0 # skip header

        cells = element.search("td")
        tracking_code = cells[0].text
        title = cells[1].text
        location = cells[2].text
        date_posted = Date.parse(cells[3].text)
        url = base_url + '/' + cells[1].at("a").attr('href')

        jobs << Job.new(:tracking_code => tracking_code,
                        :title         => title,
                        :location      => location,
                        :date_posted   => date_posted,
                        :url           => url)
      end

      jobs
    end

    def self.fetch_document(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      document = Nokogiri::HTML(response.body)
    end

    def self.clean_description(description)
      description.strip.gsub(/\302\240/, ' ').gsub(/\n/, '').gsub(/\t/, '')
    end

    DESCRIPTION_IDS = [
      'jobDesciptionDiv',
      'dspJobTxtReqSkillsDiv',
      'jobRequiredSkillsDiv',
      'dspJobTxtReqExpDiv',
      'jobExperienceRqdDiv',
    ]

    def description
      document = self.class.fetch_document(url)

      document.at(".ui-form").elements.select { |element|
        DESCRIPTION_IDS.include?(element.attr('id'))
      }.join
    end

  end

end
