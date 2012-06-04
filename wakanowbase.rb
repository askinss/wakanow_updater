require './sugar'
require './wakanow'
require './readfromcsv'
class Wakanowbase
  include Wakanow
  def initialize
    @csv_to_arry = ReadFromCsv.new
    @sugar = Sugar.new
    @customerfiles = file_in_dir_matching_month_to_a('Customer')
    @flight = file_in_dir_matching_month_to_a('Flight')
    @hotel = file_in_dir_matching_month_to_a('Hotel')
    @customercount = 0
    @flightcount = 0
    @hotelcount = 0
  end

  def contactmapping(csv_array)
    [{:name => "cstm_customer_id_c", :value => csv_array[0]}, {:name => "cstm_contacts_agency_id_c", :value => csv_array[1]}, {:name => "salutation", :value => csv_array[2]}, {:name => "first_name", :value => csv_array[3]}, {:name => "last_name", :value => csv_array[4]}, {:name => "email1", :value  => csv_array[5]}, {:name => "phone_mobile", :value => csv_array[6]}, {:name => "phone_work", :value => csv_array[7]}, {:name => "cstm_idproof_type_c", :value => csv_array[8]}, {:name => "cstm_idproof_type_no_c", :value => csv_array[9]}, {:name => "primary_address_street", :value => csv_array[10]}, {:name => "primary_address_state", :value => csv_array[11]}, {:name => "primary_address_city", :value => csv_array[12]}, {:name => "primary_address_postalcode", :value => csv_array[13]}, {:name => "date_entered", :value => csv_array[15]}]
  end 

  def accountmapping(csv_array)
    [{:name => "cstm_customer_id_c", :value => csv_array[0]}, {:name => "name", :value => "#{csv_array[2]} #{csv_array[3]} #{csv_array[4]}"}, {:name => "phone_office", :value => csv_array[6]}, {:name => "phone_alternate", :value => csv_array[7]}, {:name => "billing_address_street", :value => csv_array[10]}, {:name => "billing_address_state", :value => csv_array[11]}, {:name => "billing_address_city", :value => csv_array[12]}, {:name => "billing_address_postalcode", :value => csv_array[13]}, {:name => "date_entered", :value => csv_array[15]}, {:name => "date_modified", :value => Time.now.strftime("%Y-%m-%d %H:%m:%S")}]
  end

  def hotelsmapping(csv_array)
    [{:name => "cstm_hotel_transaction_id_c", :value => csv_array[0]}, {:name => "name", :value => csv_array[12]}, {:name => "cstm_hotel_checkin_date", :value => csv_array[1]}, {:name => "cstm_hotel_checkout_date", :value => csv_array[2]}, {:name => "cstm_booking_date_c", :value => csv_array[3]}, {:name => "cstm_reference_no_c", :value => csv_array[4]}, {:name => "cstm_order_amount_c", :value => csv_array[6]}, {:name => "cstm_hotel_booking_status", :value => csv_array[7]}, {:name => "cstm_hotel_source", :value => csv_array[8]}, {:name => "cstm_noof_passengers", :value => csv_array[10]}, {:name => "cstm_payment_method_c", :value => csv_array[11]}, {:name => "billing_address_city", :value => csv_array[13]}, {:name => "cstm_room_type_c", :value => csv_array[14]}, {:name => "date_entered", :value => csv_array[15]}, {:name => "date_modified", :value => Time.now.strftime("%Y-%m-%d %H:%m:%S")}, {:name => "date_entered", :value => Time.now.strftime("%Y-%m-%d %H:%m:%S")}, {:name => "cstm_customer_id_c", :value => csv_array[9]}]
  end

  def flightsmapping(csv_array)
    [{:name => "cstm_flights_transaction_id_c", :value => csv_array[0]}, {:name => "name", :value => "#{csv_array[0]}-#{csv_array[4]}"}, {:name => "cstm_flight_departure_date_c", :value => csv_array[1]}, {:name => "cstm_flight_arrival_date_c", :value => csv_array[2]}, {:name => "cstm_flight_cancellation_dat_c", :value => csv_array[3]}, {:name => "cstm_flight_amount_c", :value => csv_array[5]}, {:name => "cstm_flight_id_proof_type_c", :value => csv_array[6]}, {:name => "cstm_flight_status_c", :value => csv_array[8]}, {:name => "cstm_flight_source_c", :value => csv_array[9]}, {:name => "cstm_flight_mobileno_c", :value => csv_array[10]}, {:name => "cstm_flight_product_desc_c", :value => csv_array[12]}, {:name => "description", :value => csv_array[13]}, {:name => "cstm_flight_payment_method_c", :value => csv_array[14]}, {:name => "cstm_flight_airline_name_c", :value => csv_array[15]}, {:name => "cstm_flight_depart_airport_c", :value => csv_array[18]}, {:name => "cstm_flight_arrival_airport_c", :value => csv_array[19]}, {:name => "cstm_flight_trip_type_c", :value => csv_array[20]}, {:name => "cstm_customer_id_c", :value => csv_array[11]}]
  end

  def runner
    begin
      @customerfiles.each { |customer| puts @csv_to_arry.reader(customer); @csv_to_arry.reader(customer).each { |customers| puts "This is customer mapping #{contactmapping(customers)}"; @sugar.set_relationship("Accounts", @sugar.set_entry("Accounts", contactmapping(customers)), "Contacts", @sugar.set_entry("Contacts", contactmapping(customers))); @customercount += 1 } }
    rescue
      logger.info "No customer records to process"
    end

    begin
      @flight.each { |flight| puts @csv_to_arry.reader(flight); @csv_to_arry.reader(flight).each { |flights| puts "This is flight mapping #{flightsmapping(flights)}"; begin; @sugar.set_relationship("wk_flights", @sugar.set_entry("wk_flights", flightsmapping(flights)), "Contacts", @sugar.set_entry("Contacts", @sugar.sugar_object_id("Contacts", flightsmapping(flights).last[:value]))); rescue; logger.info "No record found for customer id #{hotelsmapping(hotels).last[:value]}"; end;  @flightcount += 1 } }
      #@flight.each { |flight| flight.each { |flights| @sugar.set_relationship("wk_flights", @sugar.set_entry("wk_flights", contactmapping(@csv_to_arry.reader(flights))), "Contacts", @sugar.sugar_object_id("Contacts", contactmapping(@csv_to_arry.reader(flights).last[:value]))) } }
    rescue
      logger.info "No flights to process"
    end

    begin
      @hotel.each { |hotel| puts @csv_to_arry.reader(hotel); @csv_to_arry.reader(hotel).each { |hotels| puts "This is hotel mapping #{hotelsmapping(hotels)}"; begin ; @sugar.set_relationship("wk__hotels", @sugar.set_entry("wk__hotels", hotelsmapping(hotels)), "Contacts", @sugar.set_entry("Contacts", @sugar.sugar_object_id("Contacts", hotelsmapping(hotels).last[:value]))); rescue; logger.info "No record found for customer id #{hotelsmapping(hotels).last[:value]}"; end;  @hotelcount += 1 } }
      #@hotel.each { |hotel| hotel.each { |hotels| @sugar.set_relationship("wk__hotels", @sugar.set_entry("wk__hotels", contactmapping(@csv_to_arry.reader(hotels))), "Contacts", @sugar.sugar_object_id("Contacts", contactmapping(@csv_to_arry.reader(hotels).last[:value]))) } }
    rescue
      logger.info "No hotels to process"
    end
    logger.info "Completed processing #{@customercount} Customers, #{@flightcount} flights, #{@hotelcount} hotels"
  end
end

a = Wakanowbase.new
a.runner
