require 'faraday'
require 'nokogiri'
require 'json'

class TPost
  attr_accessor :item
  BASE_URL = 'https://twitter.com'

  def initialize raw
    self.item = raw
  end

  def text
    self.item.css('p.tweet-text').text
  end

  def permalink
    BASE_URL + item.css('.js-permalink').first['href']
  end

  def status_id
    resp = permalink.split '/'
    resp.size == 6 ? resp[-1] : nil
  end

  def lpage
    begin
      page = Faraday.get(
        BASE_URL + "/i/activity/favorited_popup?id=" + status_id, 
        {}, 
        {}
      )
    rescue
      nil
    else
      JSON.parse(page.body)
    end
  end

  def liked_list num = 3
    page = lpage
    resp = []
    if page
      doc = Nokogiri::HTML page['htmlUsers']
      doc.css('a.account-group')[0..num-1].each do |el|
        tu = TwiUser.new el
        puts " - #{tu.link}"
      end
    else
      ['oops']
    end
  end

end

class TwiUser
  attr_accessor :item

  BASE_URL = 'https://twitter.com'

  def initialize raw
    self.item = raw
  end

  def fullname
    item.css('strong.fullname').text
  end

  def username
    item.css('span.username').text
  end

  def link
    BASE_URL + item['href']
  end
end

begin 
  address = 'https://twitter.com/elonmusk'
  begin
    response = Faraday.get address
  rescue
  else
    doc = Nokogiri::HTML response.body
    # p doc
    doc.css('div .content')[0..2].each_with_index do |article,i|
      twit = TPost.new article
      puts "\n"
      puts "Post #{i+1}"
      puts twit.text
      twit.liked_list
    end
  end
end


