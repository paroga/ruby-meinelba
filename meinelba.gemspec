Gem::Specification.new do |s|
  s.name        = 'meinelba'
  s.version     = '0.0.2'
  s.date        = '2019-05-29'
  s.summary     = 'Mein ELBA Scrapper'
  s.description = 'A gem to interact with mein.elba.raiffeisen.at'
  s.authors     = ['Patrick Gansterer', 'Rene Kapusta']
  s.email       = 'paroga@paroga.com'
  s.files       = ['lib/meinelba.rb']
  s.homepage    =
    'https://github.com/paroga/ruby-meinelba'
  s.license       = 'MIT'

  s.add_dependency 'mechanize'
end
