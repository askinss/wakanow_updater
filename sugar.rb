require './wakanow'
require 'digest/md5'
require 'date'

class Sugar
  include Wakanow 
  def initialize
    wsdl = SOAP::WSDLDriverFactory.new(load_config['sugar_url'])
    @soap = wsdl.create_rpc_driver
    #@soap.wiredump_dev = STDOUT
    begin 
      XSD::Charset.encoding = 'UTF8'
      user = load_config['sugar_username']
      pass = Digest::MD5.hexdigest(load_config['sugar_password'])
      user_auth = {:user_name => user, :password => pass, :version => "1.0"}
      loginRequest = user_auth
      response = @soap.login(loginRequest, '')
      (response.error.name == "No Error") ? logger.info("Successfully connected to Sugar") : logger.error("Connection to Sugar failed #{response.error.name} #{response.error.description}")
      @sugar_connect = response['id']
    rescue => err
      logger.info "Connection to Sugar failed #{err.message}"
    end
  end

  def sugar_object_id(module_name, unique_identifier_value, max_result=1) #sugar_check is used to determine if the record returned exists with the unique identifier in sugar, where Accounts is cnum_c, Deals is
    if module_name == 'Accounts'
      unique_identifier_var = 'cstm_customer_id_c'
    elsif module_name == 'Contacts'
      unique_identifier_var = 'cstm_customer_id_c'
    elsif module_name == 'wk_flights'
      unique_identifier_var = "cstm_flights_transaction_id_c"
    elsif module_name == 'wk__hotels'
      unique_identifier_var = 'cstm_hotel_transaction_id_c'
    end
    query = "#{unique_identifier_var} = \'#{unique_identifier_value}\'"
    order_by, get_field, jy = '', get_module_fields(module_name), ''
    response = @soap.get_entry_list(@sugar_connect, module_name, query, order_by, 0, get_field, max_result, 0)
    (response.error.name == "No Error") ? logger.info("Successfully got #{module_name} id") : logger.error("Getting #{module_name} failed #{response.error.name} #{response.error.description}")
    z = response.entry_list
    begin
      z.first.name_value_list.map { |x| "#{x.name} = #{x.value}" }
    rescue
      logger.info("The object does not have any matching record")
    end
    z.each do |jj|
      logger.info "object id is #{jj}"
      jj['id'].is_a?(Array) ? (jy << jj['id'].first) : (jy << jj['id'])
    end
    logger.info("Id is #{jy} for #{unique_identifier_var} in #{module_name}")
    jy
  end

  def get_available_modules
    response = @soap.get_available_modules(@sugar_connect)
    (response.error.name == "No Error") ? logger.info("Got #{response.modules.size} modules") : logger.error("Getting modules failed #{response.error.name} #{response.error.description}")
    response.modules
  end

  def login
    @sugar_connect
  end

  def logout
    response = @soap.logout(@sugar_connect)
    (response.name == "No Error") ? logger.info("Successfully logged out...") : logger.error("Logging out failed #{response.error.name} #{response.error.description}")
  end

  def get_module_fields(module_name)
    response = @soap.get_module_fields(@sugar_connect, module_name)
    fields = response.module_fields.map { |field| field.name }
    #(response.error.name == "No Error") ? logger.info("Got #{fields.size} module fields from #{module_name} module") : logger.error("Getting module fields for#{module_name} module failed #{response.error.name} #{response.error.description}")
    response.module_fields.map { |field| field.name }
  end

  def set_entry(module_name, csv_to_sugar_object_hash)#this method inserts records into sugar
    XSD::Charset.encoding = 'UTF8'
    puts "the bug is #{csv_to_sugar_object_hash[0][:value]}"
    puts "The id is #{sugar_object_id(module_name, csv_to_sugar_object_hash[0][:value])}"
    (csv_to_sugar_object_hash = csv_to_sugar_object_hash + [{:name => 'id', :value => sugar_object_id(module_name, csv_to_sugar_object_hash[0][:value])}]) unless sugar_object_id(module_name, csv_to_sugar_object_hash[0][:value]).empty?
    response = @soap.set_entry(@sugar_connect, module_name, csv_to_sugar_object_hash)
    p response
    response['id']
  end

  def set_relationship(module1_name, module1_id, module2_name, module2_id)
    relationship_hashmap = {:module1 => module1_name,  :module1_id => module1_id, :module2 => module2_name, :module2_id => module2_id}
    response = @soap.set_relationship(@sugar_connect, relationship_hashmap)
  end	

end

a = Sugar.new
#p a.sugar_object_id("Contacts", "cstm_customer_id_c", "8434") 
csv_array = ["26357", "2", "Mr.", "Kyaudai", "Abdullahi", "akyaudai@yahoo.com", "08033109062", "", "Passport", "", "Block 11 kano street area 1 Garki Abuja", "", "Abuja", "113", "", "2012-05-15 19:32:14"]
contacts_mapping_hash = {:name => "cstm_customer_id_c", :value => csv_array[0]}, {:name => "cstm_contacts_agency_id_c", :value => csv_array[1].to_i}, {:name => "salutation", :value => csv_array[2]}, {:name => "first_name", :value => csv_array[3]}, {:name => "last_name", :value => csv_array[4]}, {:name => "email1", :value  => csv_array[5]}, {:name => "phone_mobile", :value => csv_array[6]}, {:name => "phone_work", :value => csv_array[7]}, {:name => "cstm_idproof_type_c", :value => csv_array[8]}, {:name => "cstm_idproof_type_no_c", :value => csv_array[9]}, {:name => "primary_address_street", :value => csv_array[10]}, {:name => "primary_address_state", :value => csv_array[11]}, {:name => "primary_address_city", :value => csv_array[12]}, {:name => "primary_address_postalcode", :value => csv_array[13]}, {:name => "date_entered", :value => csv_array[15]}
accounts_mapping_hash = [{:name => "cstm_customer_id_c", :value => csv_array[0]}, {:name => "name", :value => "#{csv_array[2]} #{csv_array[3]} #{csv_array[4]}"}, {:name => "phone_office", :value => csv_array[6]}, {:name => "phone_alternate", :value => csv_array[7]}, {:name => "billing_address_street", :value => csv_array[10]}, {:name => "billing_address_state", :value => csv_array[11]}, {:name => "billing_address_city", :value => csv_array[12]}, {:name => "billing_address_postalcode", :value => csv_array[13]}, {:name => "date_entered", :value => csv_array[15]}, {:name => "date_modified", :value => Time.now.strftime("%Y-%m-%d %H:%m:%S")}]
hotels_mapping_hash = [{:name => "cstm_hotel_transaction_id_c", :value => csv_array[0]}, {:name => "name", :value => csv_array[12]}, {:name => "cstm_hotel_checkin_date", :value => csv_array[1]}, {:name => "cstm_hotel_checkout_date", :value => csv_array[2]}, {:name => "cstm_booking_date_c", :value => csv_array[3]}, {:name => "cstm_reference_no_c", :value => csv_array[4]}, {:name => "cstm_order_amount_c", :value => csv_array[6]}, {:name => "cstm_hotel_booking_status", :value => csv_array[7]}, {:name => "cstm_hotel_source", :value => csv_array[8]}, {:name => "cstm_customer_id_c", :value => csv_array[9]}, {:name => "cstm_noof_passengers", :value => csv_array[10]}, {:name => "cstm_payment_method_c", :value => csv_array[11]}, {:name => "billing_address_city", :value => csv_array[13]}, {:name => "cstm_room_type_c", :value => csv_array[14]}, {:name => "date_entered", :value => csv_array[15]}, {:name => "date_modified", :value => Time.now.strftime("%Y-%m-%d %H:%m:%S")}, {:name => "date_entered", :value => Time.now.strftime("%Y-%m-%d %H:%m:%S")}]
flights_mapping_hash = [{:name => "cstm_flights_transaction_id_c", :value => csv_array[0]}, {:name => "name", :value => "#{csv_array[0]}-#{csv_array[4]}"}, {:name => "cstm_flight_departure_date_c", :value => csv_array[1]}, {:name => "cstm_flight_arrival_date_c", :value => csv_array[2]}, {:name => "cstm_flight_cancellation_dat_c", :value => csv_array[3]}, {:name => "cstm_flight_amount_c", :value => csv_array[5]}, {:name => "cstm_flight_id_proof_type_c", :value => csv_array[6]}, {:name => "cstm_flight_status_c", :value => csv_array[8]}, {:name => "cstm_flight_source_c", :value => csv_array[9]}, {:name => "cstm_flight_mobileno_c", :value => csv_array[10]}, {:name => "cstm_customer_id_c", :value => csv_array[11]}, {:name => "cstm_flight_product_desc_c", :value => csv_array[12]}, {:name => "description", :value => csv_array[13]}, {:name => "cstm_flight_payment_method_c", :value => csv_array[14]}, {:name => "cstm_flight_airline_name_c", :value => csv_array[15]}, {:name => "cstm_flight_depart_airport_c", :value => csv_array[18]}, {:name => "cstm_flight_arrival_airport_c", :value => csv_array[19]}, {:name => "cstm_flight_trip_type_c", :value => csv_array[20]}]
#p a.set_entry("Accounts", accounts_mapping_hash)
#p a.set_entry("Contacts", contacts_mapping_hash)
p a.sugar_object_id("Contacts", "cstm_customer_id_c", "11418")
#p a.sugar_object_id("Accounts", "26537")
#p a.set_relationship("Accounts", a.set_entry("Accounts", accounts_mapping_hash), "Contacts", a.set_entry("Contacts", contacts_mapping_hash))
#p a.sugar_object_id("wk__hotels", "cstm_hotel_transaction_id_c", "13542")
#p a.sugar_object_id("wk_flights", "cstm_flights_transaction_id_c", "10297")
#p a.get_module_fields("wk_flights")
#p a.get_module_fields("wk__hotels")
#p a.file_in_dir_matching_month_to_a("Customer".downcase)
