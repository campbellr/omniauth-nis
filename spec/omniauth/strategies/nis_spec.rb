require 'spec_helper'
describe "OmniAuth::Strategies::NIS" do
  # :title => "My NIS",
  # :domain => "spgear",
  class MyNISProvider < OmniAuth::Strategies::NIS; end

  let(:app) do
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use MyNISProvider, :name => 'nis', :title => 'MyNIS Form', :domain => 'spgear', :name_proc => Proc.new {|name| name.gsub(/@.*$/,'')}
      run lambda { |env| [404, {'Content-Type' => 'text/plain'}, [env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  let(:session) do
    last_request.env['rack.session']
  end

  it 'should add a camelization for itself' do
    OmniAuth::Utils.camelize('nis').should == 'NIS'
  end

  describe '/auth/nis' do
    before(:each){ get '/auth/nis' }

    it 'should display a form' do
      last_response.status.should == 200
      last_response.body.should be_include("<form")
    end

    it 'should have the callback as the action for the form' do
      last_response.body.should be_include("action='/auth/nis/callback'")
    end

    it 'should have a text field for each of the fields' do
      last_response.body.scan('<input').size.should == 2
    end
    it 'should have a label of the form title' do
      last_response.body.scan('MyNIS Form').size.should > 1
    end
  end

  describe 'post /auth/nis/callback' do
    before(:each) do
      @adaptor = double(OmniAuth::NIS::Adaptor, {:uid => 'ping'})
      @adaptor.stub(:auth_user)
      OmniAuth::NIS::Adaptor.stub(:new).and_return(@adaptor)
    end

    context 'failure' do
      before(:each) do
        @adaptor.stub(:auth_user).and_return(false)
      end

      context "when username is not preset" do
        it 'should redirect to error page' do
          post('/auth/nis/callback', {})

          last_response.should be_redirect
          last_response.headers['Location'].should =~ %r{missing_credentials}
        end
      end

      context "when username is empty" do
        it 'should redirect to error page' do
          post('/auth/nis/callback', {:username => ""})

          last_response.should be_redirect
          last_response.headers['Location'].should =~ %r{missing_credentials}
        end
      end

      context "when username is present" do
        context "and password is not preset" do
          it 'should redirect to error page' do
            post('/auth/nis/callback', {:username => "ping"})

            last_response.should be_redirect
            last_response.headers['Location'].should =~ %r{missing_credentials}
          end
        end

        context "and password is empty" do
          it 'should redirect to error page' do
            post('/auth/nis/callback', {:username => "ping", :password => ""})

            last_response.should be_redirect
            last_response.headers['Location'].should =~ %r{missing_credentials}
          end
        end
      end

      context "when username and password are present" do
        context "and communication with NIS server caused an exception" do
          before :each do
            @adaptor.stub(:auth_user).and_throw(Exception.new('connection_error'))
          end

          it 'should redirect to error page' do
            post('/auth/nis/callback', {:username => "ping", :password => "password"})

            last_response.should be_redirect
            last_response.headers['Location'].should =~ %r{nis_error}
          end
        end
      end
    end

    context 'success' do
      let(:auth_hash){ last_request.env['omniauth.auth'] }

      before(:each) do
        @adaptor.stub(:auth_user).and_return({
          'uid' => 'ryan',
          'email'=> 'Ryan.Campbell@emc.com',
          'first_name' => 'Ryan',
          'last_name' => 'Campbell',
              })
      end

      it 'should not redirect to error page' do
        post('/auth/nis/callback', {:username => 'ryan', :password => 'oregon'})
        last_response.should_not be_redirect
      end

      it 'should map user info to Auth Hash' do
        post('/auth/nis/callback', {:username => 'ryan', :password => 'oregon'})
        auth_hash.uid.should == 'ryan'
        auth_hash.info.email.should == 'Ryan.Campbell@emc.com'
        auth_hash.info.first_name.should == 'Ryan'
        auth_hash.info.last_name.should == 'Campbell'
      end
    end
  end
end
