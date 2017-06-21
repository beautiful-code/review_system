require 'rails_helper'

describe 'User' do
  [:name, :email].each do |attribute|
    it "should be invalid if #{attribute} is missing" do
      user = User.new(name: 'Anything', email: 'anyemail@gmail.com')
      user[attribute] = ''
      user.save

      expect(user).not_to be_valid
      expect(user.errors.messages.keys).to include(attribute)
    end
  end

  it "is valid with valid attributes" do
    expect(User.new(name: 'Anything', email: 'anyemail@gmail.com')).to be_valid
  end

  describe :from_omniauth do

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      info: {
        first_name: 'mouli',
        last_name: 'l',
        email: 'mouli@gmail.com'
      }
    })

    it 'should get all the user details from omniauth for successful authentication' do

      user = User.from_omniauth(OmniAuth.config.mock_auth[:google_oauth2])

      expect(user.name).to eq('mouli l')
      expect(user.email).to eq('mouli@gmail.com')
    end

    it 'should create a new User record if the user authenicated for the very first time' do

      expect(User.count).to eq(0)

      user = User.from_omniauth(OmniAuth.config.mock_auth[:google_oauth2])
      expect(User.count).to eq(1)
    end

    it 'should not create a new User record if the authenticated user already exists in the DB' do

      existing_user = User.create(name: 'mouli l', email: 'mouli@gmail.com')
      user_count = User.count

      user = User.from_omniauth(OmniAuth.config.mock_auth[:google_oauth2])
      expect(User.count).to eq(user_count)
    end
  end
end
