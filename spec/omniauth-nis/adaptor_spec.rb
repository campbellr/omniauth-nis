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
  end
end
