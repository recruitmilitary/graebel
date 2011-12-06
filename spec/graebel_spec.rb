require 'spec_helper'

describe Graebel::Job do

  def read_fixture(name)
    File.read(File.dirname(__FILE__) + "/fixtures/#{name}")
  end

  describe '.all' do
    use_vcr_cassette

    it 'returns a list of jobs' do
      jobs = Graebel::Job.all

      jobs.size.should == 26
      job = jobs.first

      job.tracking_code.should == '140-263'
      job.title.should == 'Training Manager'
      job.location.should == 'Aurora, CO, US'
      job.date_posted.should == Date.new(2011, 11, 30)
      job.url.should == 'https://graebel-hr.silkroad.com/epostings/index.cfm?fuseaction=app.jobinfo&jobid=140&company_id=16263&source=ONLINE&JobOwner=992458&bycountry=&bystate=&bylocation=&keywords=&byCat=&tosearch=no'
      Graebel::Job.clean_description(job.description).should == Graebel::Job.clean_description(read_fixture('description.html'))
    end
  end

end
