require 'spec_helper'

describe OmniAuth::Strategies::Dwolla do
  subject do
    OmniAuth::Strategies::Dwolla.new(nil, @options || {})
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'should have the correct dwolla site' do
      expect(subject.client.site).to eq("https://www.dwolla.com")
    end

    it 'should have the correct authorization url' do
      expect(subject.client.options[:authorize_url]).to eq("/oauth/v2/authenticate")
    end

    it 'should have the correct token url' do
      expect(subject.client.options[:token_url]).to eq('/oauth/v2/token')
    end

    #TODO find a way to set :provider_ignores_state to true by default
    # and add a test for it. -masukomi
  end

  describe 'getting info' do
    before do
      @access_token = double(
        :token => 'test_token',
        :params => {'account_id' => '12345'})
      @dwolla_user  = {       'Id' => '12345',
                              'Name' => 'Test Name',
                              'Latitude' => '123',
                              'Longitude' => '321',
                              'City' => 'Sample City',
                              'State' => 'TT',
                              'Type' => 'Personal' }

      @access_token_response = double(:parsed => {
        'Response' => @dwolla_user})
      subject.stub(:access_token) { @access_token }
    end

    context 'when successful' do
      it 'sets the correct info based on user' do
        @access_token.should_receive(:get).with('/oauth/rest/users/').and_return(@access_token_response)
        # note that the keys are all lowercase
        # unlike the response that came back from Dwolla
        expect(subject.info).to eq({ 'name'      => 'Test Name',
                                     'latitude'  => '123',
                                     'longitude' => '321',
                                     'city'      => 'Sample City',
                                     'state'     => 'TT',
                                     'type'      => 'Personal' })
      end

      it 'sets the correct uid based on user' do
        subject.uid.should == '12345'
      end
    end
  end

  describe '#authorize_params' do
    it 'includes default scope for email and offline access' do
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:scope].should eq('accountinfofull')
    end
  end
end

