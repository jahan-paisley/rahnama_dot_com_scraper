require 'json'

module AreadCodeHelper

  @@aread_codes= JSON.parse(IO.read(File.expand_path("../../data/area_codes.json", __FILE__)))

  def find_aread_code phone
    begin
       area = aread_codes.values.flatten.select { |e| e.values.flatten.include?(phone[0...4].to_i) }.first.keys.first
    rescue
    end if phone
    return area
  end
end