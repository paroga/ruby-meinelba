Gem::Specification.new do |s|
  s.name        = 'meinelba'
  s.version     = '0.0.1'
  s.date        = '2018-06-25'
  s.summary     = 'Mein ELBY Scrapper'
  s.description = 'A gem to interact with mein.elba.raiffeisen.at'
  s.authors     = ['Patrick Gansterer']
  s.email       = 'paroga@paroga.com'
  s.files       = ['lib/meinelba.rb']
  s.homepage    =
    'https://github.com/paroga/ruby-meinelba'
  s.license       = 'MIT'

  s.add_dependency 'mechanize'
end
