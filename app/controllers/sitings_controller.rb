require "open-uri"

class SitingsController < ApplicationController
	before_action :authenticate_user!, except: [:index, :show]

	def index 
		@title = 'Sightings'
		search = params[:search]
		if search && !search.empty?
			@sitings = Siting.search(search)
		else
			order = params[:order]
			if order && !order.empty?
				if order == "recent"
					@sitings = Siting.all.order(created_at: :desc)
				else
					@sitings = Siting.all.order(cached_votes_up: :desc)
				end
			else
				@sitings = Siting.all.order(cached_votes_up: :desc)
			end
		end
		@sitings = @sitings.paginate(page: params[:page], per_page: 6)
	end

	def show
		@siting = Siting.find(params[:id])
		@title = @siting.bird
	end

	def new
		@title = "Create Sighting"
		@siting = current_user.sitings.build
	end

	def create
		@siting = current_user.sitings.build(siting_params)

		location = Geocoder.search(@siting.location)[0]

		if(!location)
			@siting.errors.add(:location, "invalid")
			@title = "Create Sighting"
			render 'new' and return
		end

		@siting.location   = get_location_name(location)
		@siting.latitude   = location.latitude
		@siting.longitude  = location.longitude
		@siting.static_map = get_static_map(@siting.latitude, @siting.longitude)

		if(@siting.save)
			redirect_to @siting
		else
			render 'new' 
		end
	end

	def edit
		@title = "Edit Sighting"
		@siting = Siting.find(params[:id])
	end

	def update
		@siting = Siting.find(params[:id])

		if (@siting.location != params[:siting][:location])
			location = Geocoder.search(params[:siting][:location])[0]

			if(!location)
				@siting.errors.add(:location, "invalid")
				@title = "Edit Sighting"
				render 'edit' and return
			end

			params[:siting][:location] = get_location_name(location)

			@siting.latitude   = location.latitude
			@siting.longitude  = location.longitude
			@siting.static_map = get_static_map(@siting.latitude, @siting.longitude)
		end

		if(@siting.update(siting_params))
			redirect_to @siting
		else
			render 'edit' 
		end
	end

	def destroy
		@siting = Siting.find(params[:id])
		@siting.destroy

		redirect_to sitings_path
	end

	def like 
		@siting = Siting.find(params[:id])
		if @siting.liked_by current_user
			respond_to do |format|
				format.html { redirect_to :back }
				format.js
			end
		end
	end

	def unlike 
		@siting = Siting.find(params[:id])
		if @siting.unliked_by current_user
			respond_to do |format|
				format.html { redirect_to :back }
				format.js
			end
		end
	end  
  

	private def siting_params
		params.require(:siting).permit(:bird, :location, :image)
	end

	private def get_static_map(latitude, longitude)
		center = [ latitude, longitude ].join(',')
		key = ENV['GOOGLE_MAPS_KEY']
		zoom = 6;
		color = "red";
		size = "300x300";
		open("https://maps.googleapis.com/maps/api/staticmap?center=#{center}&size=#{size}&zoom=#{zoom}&markers=color:#{color}%7C#{center}&key=#{key}")
	end

	private def get_location_name(location)
		return [location.city, location.state, location.country] * ", "
	end
end
