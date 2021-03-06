require 'puppet'                                                                                                                                                                                                                           
require 'puppet/type/gnupg_key'                                                                                                                                                                                                        
describe Puppet::Type.type(:gnupg_key) do
  before :each do
    @gnupg_key = Puppet::Type.type(:gnupg_key).new(:name => 'foo')
  end
  it 'should accept a user' do
    @gnupg_key[:user] = 'root'
    @gnupg_key[:user].should == 'root'
  end
  it 'should require a key_source or key_server if ensure present' do
    expect {
      Puppet::Type.type(:gnupg_key).new(:name => 'foo', :user => 'root', :ensure => 'present')
    }.to raise_error(/You need to specify at least one of*/)
  end
  it 'should ignore key_source or key_server value if ensure absent' do
    @gnupg_key[:ensure] = 'absent'
    @gnupg_key[:ensure].should == :absent
  end
  it 'should require a name' do
    expect {
      Puppet::Type.type(:gnupg_key).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end
  it 'should not allow invalid formated user' do
    expect {
      @gnupg_key[:user] = '1foo'
    }.to raise_error(Puppet::Error, /Invalid username format for*/)
  end
  ['http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key', 'ldap://keys.puppetlabs.com', 'hkp://pgp.mit.edu/'].each do |val|
    it "should accept key_server #{val}" do
      @gnupg_key[:key_server] = val
      @gnupg_key[:key_server].should == val.to_s
    end
  end  
  ['puppet:///modules/gnupg/random.key', 'http://www.puppetlabs.com/key.key', 'https://www.puppetlabs.com/key.key', 'file:///etc/foo.key', '/etc/foo.key'].each do |val|
    it "should accept key_source #{val}" do
      @gnupg_key[:key_source] = val
      @gnupg_key[:key_source].should == val.to_s.gsub("file://", "")
    end
  end
  it "should not accept invalid formated key_source URI" do
    expect {
      @gnupg_key[:key_source] = 'httk://foo.bar/'
    }.to raise_error(Puppet::Error)
  end
  ['20BC0A86', 'D50582e6', '20BC0a86', '9B7D32F2D50582E6', '3CCe8BC520bc0A86'].each do |val|
    it "should allow key_id with #{val}" do
      @gnupg_key[:key_id] = val
      @gnupg_key[:key_id].should == val.upcase.intern
    end
  end
  ['ABCD', '1234567G', 'ASA1321', 'q321asd'].each do |val|
    it "should not allow key_id with #{val}" do
      expect {
        @gnupg_key[:key_id] = val
      }.to raise_error(/Invalid key id*/)
    end
  end
end
