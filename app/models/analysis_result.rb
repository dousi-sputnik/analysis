class AnalysisResult < ApplicationRecord
  belongs_to :analysis_session
  has_one :user, through: :analysis_session

  def yahoo_product_url
    app_id = ENV['YAHOO_APP_ID']
    base_url = "https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch"
    url = "#{base_url}?appid=#{app_id}&jan_code=#{jan_code}"

    response = HTTParty.get(url, format: :plain)
    data = JSON.parse(response, symbolize_names: true)

    if data[:hits].present?
      data[:hits].first[:url]
    else
      "#"
    end
  end
end
