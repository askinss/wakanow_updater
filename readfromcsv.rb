require 'csv'
require './wakanow'
class ReadFromCsv
  include Wakanow 
  def initialize
    @csvarray = []
  end

  def reader(filename)
    CSV.foreach(filename, { :col_sep => load_config['csv_separator'] }) { |row| @csvarray << adjuster_for_nil(row) unless row.empty?}
    @csvarray
  end

  def adjuster_for_nil(row) #this method converts :SEP: to an empty string
    row.map { |str| (str == ":SEP:" || str == "") ? (str = "") : str }
  end

end

