class Ride < ActiveRecord::Base
	self.table_name = "rideshare_ride"
	self.primary_key = "id"
	
	belongs_to :person
	belongs_to :event
	has_many :rides, :foreign_key => "driver_ride_id"

  attr_accessible :driver_ride_id, :event_id, :person_id, :address1, :address2, :address3, :address4, :country, :city, :state, :zip, :phone,
                  :contact_method, :number_passengers, :drive_willingness, :depart_time, :special_info, :email, :situation, :change, :time_hour,
                  :time_minute, :time_am_pm, :spaces, :spaces_count, :special_info_check

  validates :situation, presence: true

  before_save :set_geocode, :set_drive_willingness
  before_validation :set_situation

  after_find :set_situation

	def self.drivers_by_event_id(event_id)
		Ride.where('rideshare_ride.drive_willingness in (1, 2, 3)').
			where('rideshare_ride.event_id' => event_id).
			includes(:person).
      includes(:rides)

	end
	
	def self.riders_by_event_id(event_id)
		result = where(:drive_willingness => 0).
      where(:event_id => event_id).
       includes(:person)
    result
	end
	
	def self.hidden_drivers_by_event_id(event_id)
		result = where(:drive_willingness => 2).
      where(:event_id => event_id).
      includes(:person)
    result
	end
	
	def current_passengers_number
		return nil unless drive_willingness.between?(1, 3)
		current_passengers.length
	end
	
	def current_passengers
		return nil unless drive_willingness.between?(1, 3)
		self.class.where(:driver_ride_id => id).where("id != driver_ride_id")
	end
	
	def address
		returnval=address1
		returnval+="<br />"+address2 unless address2.empty?
		returnval+="<br />"+city+", "+state+" "+zip
	end
	
	def address_single_line
		r = ""
		r += address1.strip
		r += ", " + address2.strip if address2.present?
		r += ", " + city.strip
		r += ", " + state.strip
		r += ", " + zip.strip
		r
	end
	
	def departureTime
		if (depart_time.nil?)
			"24:00"
		else
			if (depart_time.min < 10)
			  if (depart_time.hour < 10)
			    "0"+depart_time.hour.to_s+":0"+depart_time.min.to_s
			  else
			    depart_time.hour.to_s+":0"+depart_time.min.to_s
		    end
			else
			  if (depart_time.hour < 10)
			    "0"+depart_time.hour.to_s+":"+depart_time.min.to_s
	      else
				  depart_time.hour.to_s+":"+depart_time.min.to_s
			  end
			end
		end
	end
	
	def departureTimeNice
		if (depart_time.nil?)
			"12:00 AM"
		else
			if (depart_time.hour > 12)
				if (depart_time.min < 10)
					(depart_time.hour-12).to_s+":0"+depart_time.min.to_s+" PM"
				else
					(depart_time.hour-12).to_s+":"+depart_time.min.to_s+" PM"
				end
			else
				if (depart_time.min < 10)
				  # adding "0" to string for string substring operations, IE 01:15 AM
					depart_time.hour.to_s+":0"+depart_time.min.to_s+" AM"
				else
					depart_time.hour.to_s+":"+depart_time.min.to_s+" AM"
				end
			end
		end
  end

  # we don't driver_ride_id to be nil
  def driver_ride_id
    super || 0
  end

  def set_geocode
    [:address1, :address2, :address3, :address4, :country, :city, :state, :zip].each do |field|
      if changed.include?(field.to_s)
        results = Geocoder.search(address_single_line)
        coordinates = results.first if results.present?
        @latitude  = coordinates.latitude if coordinates
        @longitude = coordinates.longitude if coordinates

        self.latitude   = @latitude
        self.longitude  = @longitude

        break
      end
    end
  end

  def set_drive_willingness
    self.drive_willingness = case situation
                               when "ride"
                                 0
                               when "drive"
                                 1
                               else
                                 2
                             end
  end

  def set_situation
    if drive_willingness.present? && situation == nil
      self.situation = case drive_willingness
                        when 0
                          "ride"
                        when 1
                          "drive"
                        else
                          nil
                        end
    end
  end

end
