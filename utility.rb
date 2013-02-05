# coding: utf-8
class Utility
  require 'net/http'
  require 'rails/application/route_inspector'

  private

  #--------------#
  # self.to_hash #
  #--------------#
  # ハッシュ変換
  def self.to_hash( element )
    ActiveSupport::JSON.decode( element.to_json )
  end

  #--------------------------------#
  # self.user_name_in_denide_list? #
  #--------------------------------#
  # ユーザ名使用禁止リスト(禁止リストにあれば => true)
  def self.user_name_in_denide_list?( username )
    return false if username.blank?

    check_name = username.downcase
    all_routes = Rails.application.routes.routes
    inspector = Rails::Application::RouteInspector.new
    route_list = inspector.collect_routes(all_routes).map{ |i| i[:path].split("/") }
    denide_list = Array.new
    route_list.map{ |x| denide_list.concat(x) }
    denide_list.map!{ |str| str.gsub('(.:format)', "").delete(':').downcase }.delete_if{ |x| x.blank? }
    denide_list.uniq!
    denide_list.concat( ["wonder", "thewonder", "thewonderit"] )

    return denide_list.index( check_name ).nil? ? false : true
  end

  #---------------------#
  # self.rand_file_name #
  #---------------------#
  # ランダムファイル名生成
  def self.rand_file_name
    Time.now.strftime("%Y_%m%d_%H%M_%S_") + Utility.rand_str(10)
  end

  #---------------#
  # self.rand_str #
  #---------------#
  # ランダム文字列生成
  def self.rand_str( digit=1 )
    ((0..9).to_a + ("a".."z").to_a + ("A".."Z").to_a).sample(digit).join
  end

  #---------------------#
  # self.get_image_file #
  #---------------------#
  # 画像データ取得(https対応)
  def self.get_image_file( url )
    response, data = Utility.get_response( url )

    if [Net::HTTPOK, Net::HTTPFound].index( response.class )
      return data, url.to_s.split("/").last
    else
      # エラーの場合
      return "", response.class
    end
  rescue => e
    return "", e
  end

  #-------------------#
  # self.get_response #
  #-------------------#
  # https対応レスポンス取得
  def self.get_response( url )
    begin
      url  = URI.parse( url )

      http = Net::HTTP.new( url.host, url.port )
      http.use_ssl     = true if url.port == 443
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if url.port == 443

      path = url.path
      path += "?" + url.query unless url.query.nil?
      response = http.get( path )

      return response, response.body, url.host
    rescue => e
      return e
    end
  end
end
