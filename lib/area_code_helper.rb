require 'json'

module AreaCodeHelper
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def find_area_code phone
      $area_codes= $area_codes || JSON.parse(IO.read(File.expand_path("../../data/area_codes.json", __FILE__)))
      begin
        area = $area_codes.values.flatten.select { |e| e.values.flatten.include?(phone[0...4].to_i) }.first.keys.first
      rescue
      end if phone
      return area
    end
  end

end
