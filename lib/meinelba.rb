require 'json'
require 'mechanize'

class MeinELBA

  def self.login(*args)
    h = new(*args)
    yield h
    h.logout
  end

  def initialize(madn, vfnr, pin)
    @agent = Mechanize.new

    @agent.get('https://mein.elba.raiffeisen.at')
    m = /window\.location\s*=\s*'(?<url>[^']*)'/.match(@agent.page.body)
    @agent.get(m['url'])

    loginForm = @agent.page.forms()[0]
    loginForm.submit nil, {'Origin' => 'https://sso.raiffeisen.at'}

    loginForm = @agent.page.form_with(:name => 'loginCenterRedirect')
    loginForm.field_with(:name => 'resumeHostLC').value = 'https://sso.raiffeisen.at'
    loginForm.field_with(:name => 'currentUrl').value = @agent.page.uri.to_s
    loginForm.submit

    loginForm = @agent.page.form_with(:name => 'loginform')
    loginForm.field_with(:name => 'loginform:LOGINMAND').value = madn
    loginForm.field_with(:name => 'loginform:LOGINVFNR').value = vfnr
    loginForm.add_field!('loginform:checkVerfuegereingabe', 'loginform:checkVerfuegereingabe')
    loginForm.submit

    loginForm = @agent.page.form_with(:name => 'loginpinform')
    loginForm.field_with(:name => 'loginpinform:LOGINPIN').value = pin
    loginForm.field_with(:name => 'loginpinform:PIN').value = '*****'
    loginForm.add_field!('loginpinform:anmeldenPIN', 'loginpinform:anmeldenPIN')
    loginForm.submit

    opt = {
      'response_type' => 'token',
      'client_id' => 'DRB-PFP-RBG',
      'scope' => 'edit',
      'redirect_uri' => 'https://mein.elba.raiffeisen.at/pfp-widgetsystem/',
      'state' => SecureRandom.hex(52)
    }
    @agent.redirect_ok = false
    @agent.get('https://sso.raiffeisen.at/as/authorization.oauth2', opt)
    uri = URI.parse(@agent.page.header['location'])
    @accessToken = URI.decode_www_form(uri.fragment).assoc('access_token').last

    @konten = api_get('pfp-pfm/vermoegen-ui-services/rest/vermoegen/konten')
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
    { 'Authorization' => "Bearer #{@accessToken}", 'Content-Type' => 'application/json'}
  end

  def parse(file)
    JSON.parse file.body, symbolize_names: true
  end

  def api_url(url)
    "https://mein.elba.raiffeisen.at/api/#{url}"
  end

  def api_get(url)
    parse(@agent.get(api_url(url), [], nil, headers))
  end

  def api_post(url, data)
    parse(@agent.post(api_url(url), JSON.generate(data), headers))
  end

end
