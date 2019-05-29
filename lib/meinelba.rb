require 'json'
require 'mechanize'

class MeinELBA

  def self.login(*args)
    h = new(*args)
    yield h
    h.logout
  end

  def initialize(user, pin)
    user = user.upcase

    @agent = Mechanize.new
    @accessToken = ''

    @agent.get('https://mein.elba.raiffeisen.at')
    m = /window\.location\s*=\s*'(?<url>[^']*)'/.match(@agent.page.body)
    @agent.get(m['url'])

    loginForm = @agent.page.forms()[0]
    loginForm.submit nil, {'Origin' => 'https://sso.raiffeisen.at'}

    api_get('quer-kunde-login/kunde-login-ui-services/rest/config/context')
    api_get('quer-kunde-login/kunde-login-ui-services/rest/identify')
    api_post('quer-kunde-login/kunde-login-ui-services/rest/identify/' + user, '')

    loginData = {"verfuegerNr" => user, "pinHash" => Digest::SHA256.hexdigest(pin), "profile" => "", "bankengruppe" => "rbg"}
    # api_post('quer-kunde-login/kunde-login-ui-services/rest/login/pin', JSON.generate(loginData))
    @agent.post('https://sso.raiffeisen.at/api/quer-kunde-login/kunde-login-ui-services/rest/login/pin', JSON.generate(loginData), {'Content-Type' => 'application/json;charset=UTF-8'})

    # api_get('quer-kunde-login/kunde-login-ui-services/rest/identify/pushTanOnboarding')

    loginData = {"updateSession" => false, "accounts" => nil}
    # api_post('quer-kunde-login/kunde-login-ui-services/rest/login', JSON.generate(loginData))
    @agent.post('https://sso.raiffeisen.at/api/quer-kunde-login/kunde-login-ui-services/rest/login', JSON.generate(loginData), {'Content-Type' => 'application/json;charset=UTF-8'})

    @agent.redirect_ok = false
    @agent.get(URI.parse(JSON.parse(@agent.page.body)['resumeUrl']))
    location = URI.parse(@agent.page.header['location'])
    @agent.get(location)

    opt = {
      'response_type' => 'token',
      'client_id' => 'DRB-PFP-RBG',
      'scope' => 'edit',
      'redirect_uri' => 'https://mein.elba.raiffeisen.at/pfp-widgetsystem/',
      'state' => SecureRandom.hex(52)
    }
    @agent.get('https://sso.raiffeisen.at/as/authorization.oauth2', opt)
    uri = URI.parse(@agent.page.header['location'])
    @accessToken = URI.decode_www_form(uri.fragment).assoc('access_token').last

    @konten = api_get('pfp-pfm/vermoegen-ui-services/rest/vermoegen/konten')
  end

  def accessToken()
    return @accessToken
  end

  def balance(iban)
    item = konto iban
    return item[:kontostand][:amount] if item
  end

  def transactions(iban, from = '', &block)
    token = (from || '').split('@')

    umsaetze = api_post('pfp-umsatz/umsatz-ui-services/rest/umsatz-page-fragment/umsaetze', {
      'predicate' => {
        'ibans' => [iban],
        'buchungVon' => token[1]
      }
    })
    items = []
    umsaetze.each do |item|
      next if token[0] && item[:id] <= token[0].to_i

      name = item[:transaktionsteilnehmerZeile1]
      name += "\n" + item[:transaktionsteilnehmerZeile2]
      name += "\n" + item[:transaktionsteilnehmerZeile3]
      name = name.strip()

      text = item[:zahlungsreferenz]
      text += "\n" + item[:verwendungszweckZeile1]
      text += "\n" + item[:verwendungszweckZeile2]
      text = text.strip()

      iban = item[:urspruenglicherIban] || ''
      iban = iban.strip()
      iban = nil if iban.empty?

      items << {
        id: item[:id],
        date: item[:buchungstag],
        amount: item[:betrag] ? item[:betrag][:amount] : 0,
        name: name,
        iban: iban,
        text: text
      }
    end

    items.sort_by! { |item| item[:date] }
    items.each &block
    items.last && ("#{items.last[:id]}@#{items.last[:date]}T00:00:00")
  end

  def logout
    @agent.get('https://sso.raiffeisen.at/idp/startSLO.ping')
  end

  private

  def konto(iban)
    @konten.each do |item|
      return item if item[:iban] == iban
    end
    nil
  end

  def headers
    if @accessToken.length > 50
      { 'Authorization' => "Bearer #{@accessToken}", 'Content-Type' => 'application/json;charset=UTF-8'}
    else
      { 'Content-Type' => 'application/json;charset=UTF-8'}
    end
  end

  def parse(file)
    JSON.parse file.body, symbolize_names: true
  end

  def api_url(url)
    if @accessToken.length > 50
      "https://mein.elba.raiffeisen.at/api/#{url}"
    else
      "https://sso.raiffeisen.at/api/#{url}"
    end
  end

  def api_get(url, params = [])
    parse(@agent.get(api_url(url), params, nil, headers))
  end

  def api_post(url, data)
    if data != ''
      parse(@agent.post(api_url(url), JSON.generate(data), headers))
    else
      parse(@agent.post(api_url(url), '', headers))
    end
  end

end
