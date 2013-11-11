module RequestUserHelpers
  def log_in( user, password = 'secret' )
    visit root_path

    within '#header-navigation' do
      click_link 'Sign in'
    end

    within '#new_account' do
      fill_in 'account_email', with: user.email
      fill_in 'account_password', with: password

      click_button 'Sign in'
    end
  end
end
