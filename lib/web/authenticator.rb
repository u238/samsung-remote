class Samsung::Web::Authenticator
  #
  # Login with a configured Mechanize agent to obtain a session cookie
  #
  def login(agent, user, pass, service_id)
    login_page = agent.post('https://account.samsung.com/account/check.do', {
      :actionID => "StartAP",
      :serviceID => "n7yqc6udv2",
      :serviceName => "SmartAppliance",
      :domain => "eu.samsungsmartappliance.com",
      :countryCode => "GB",
      :languageCode => "en",
      :registURL => "http://global.samsungsmartappliance.com/UserMgr/SSOSignIn",
      :returnURL => "http://global.samsungsmartappliance.com/Home/Index",
      :goBackURL => "http://global.samsungsmartappliance.com/Home/Index",
      :idCheckURL => "",
      :signInURL => "",
      :signUpURL => "http://global.samsungsmartappliance.com/UserMgr/SSOModifyUser",
      :profileUpdateURL => "http://global.samsungsmartappliance.com/UserMgr/SSOModifyGo",
      :termsURL => "http://global.samsungsmartappliance.com/UserMgr/termsGBen",
      :privacyPolicyURL => "http://global.samsungsmartappliance.com/UserMgr/privacyPolicyGBen"
    })

    login_page.form['inputUserID'] = user
    login_page.form['inputPassword'] = pass
    login_page.form['serviceID'] = service_id
    login_page.form['remIdCheck'] = 'on'
    login_page.form.action = 'https://account.samsung.com/account/startSignIn.do'

    start_sso = login_page.form.submit
    finish_sso = start_sso.form.submit

    agent.cookies
  end
end