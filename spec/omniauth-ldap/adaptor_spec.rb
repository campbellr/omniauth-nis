require 'spec_helper'
describe "OmniAuth::NIS::Adaptor" do

  describe "auth_user" do
    it "should return false if credentails are incorrect" do
      adaptor = OmniAuth::NIS::Adaptor.new({:domain => "campbellnet"})
      adaptor.stub(:yp_match).and_return("ryan:$6$hG77Vnzl$EDYbIeDDAlU755JWmqv4t2"\
                                         "9MjusTtJQ0n8/jR4Z0fbtg8MDLI1i42xCI00ISLO"\
                                         "vlP0SAXMuzjVMtEwF1y6msS/:500:500:Ryan Campbell:"\
                                         "/home/ryan:/bin/bash")
      user_info = adaptor.auth_user({:username => "ryan", :password => "oregon"})
      user_info['uid'].should == 'ryan'
      user_info['name'].should == "Ryan Campbell"
    end
    it "should properly handle passwd lines without names" do
      adaptor = OmniAuth::NIS::Adaptor.new({})
      adaptor.stub(:yp_match).and_return("ryan:$6$hG77Vnzl$EDYbIeDDAlU755JWmqv4t2"\
                                         "9MjusTtJQ0n8/jR4Z0fbtg8MDLI1i42xCI00ISLO"\
                                         "vlP0SAXMuzjVMtEwF1y6msS/:500:500::"\
                                         "/home/ryan:/bin/bash")
      user_info = adaptor.auth_user({:username => "ryan", :password => "oregon"})
      user_info['uid'].should == 'ryan'
      user_info['name'].should == "ryan"
      user_info['email'].should == ""
    end
    it "should properly handle passwd lines with only a first name" do
      adaptor = OmniAuth::NIS::Adaptor.new({})
      adaptor.stub(:yp_match).and_return("ryan:$6$hG77Vnzl$EDYbIeDDAlU755JWmqv4t2"\
                                         "9MjusTtJQ0n8/jR4Z0fbtg8MDLI1i42xCI00ISLO"\
                                         "vlP0SAXMuzjVMtEwF1y6msS/:500:500:Ryan:"\
                                         "/home/ryan:/bin/bash")
      user_info = adaptor.auth_user({:username => "ryan", :password => "oregon"})
      user_info['uid'].should == 'ryan'
      user_info['name'].should == "Ryan"
      user_info['email'].should == ""
    end
    it "should return an email address if email_domain is provided" do
      adaptor = OmniAuth::NIS::Adaptor.new({:email_domain => 'example.com'})
      adaptor.stub(:yp_match).and_return("ryan:$6$hG77Vnzl$EDYbIeDDAlU755JWmqv4t2"\
                                         "9MjusTtJQ0n8/jR4Z0fbtg8MDLI1i42xCI00ISLO"\
                                         "vlP0SAXMuzjVMtEwF1y6msS/:500:500:Ryan Campbell:"\
                                         "/home/ryan:/bin/bash")
      user_info = adaptor.auth_user({:username => "ryan", :password => "oregon"})
      user_info['uid'].should == 'ryan'
      user_info['name'].should == "Ryan Campbell"
      user_info['email'].should == "Ryan.Campbell@example.com"
    end
  end
end
