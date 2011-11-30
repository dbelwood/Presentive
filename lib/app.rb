require 'sinatra'
require 'presentation'
require 'slide'
require 'slide_part'
require 'omniauth/oauth'

class App < Sinatra::Base
	set :sessions, true
	set :root, File.join(File.dirname(__FILE__), '/..')
	set :method_override, true
	set :logging, true
	enable :sessions

	use OmniAuth::Builder do
		provider :facebook, '220068778060946', '837f9303fa42078183fc9ce39a128ade', { :scope => 'status_update, publish_stream' }
	end

	get '/' do
		haml :home
	end

	# Authorization paths
	get '/auth/facebook/callback' do
		session['fb_auth'] = request.env['omniauth.auth']
  		session['fb_token'] = session['fb_auth']['credentials']['token']
  		session['fb_error'] = nil
  		redirect '/presentations'
	end

	get '/auth/failure' do
	  	clear_session
	  	session['fb_error'] = 'In order to use this site you must allow us access to your Facebook data<br />'
	  	redirect '/'
	end

	get '/logout' do
  		clear_session
  		redirect '/'
	end

	def clear_session
  		session['fb_auth'] = nil
  		session['fb_token'] = nil
  		session['fb_error'] = nil
	end

	# -------------------------------- #

	get '/presentations' do
		@presentations = Presentation.all
		haml :presentations
	end

	get '/presentations/_new' do
		haml :new_presentation
	end

	post '/presentations' do
		begin
			presentation =  Presentation.create!(:name => params[:name], :author => params[:author])
			redirect to("/presentations/#{presentation.id}")
		rescue => e
			# ERROR !
			halt 500, e.to_s
		end
	end

	get '/presentations/:presentation_id' do
		@presentation = Presentation.find(params[:presentation_id])
		haml :presentation
	end

	get '/presentations/:presentation_id/view' do
		@presentation = Presentation.find(params[:presentation_id])
		haml :presentation_view
	end

	get '/presentations/:presentation_id/_edit' do
		@presentation = Presentation.find(params[:presentation_id])
		haml :edit_presentation
	end

	put '/presentations/:presentation_id' do
		begin
			@presentation = Presentation.find(params[:presentation_id])
			redirect to("/presentations/#{@presentation.id}") if @presentation.update_attributes(:name => params[:name], :author => params[:author])
		rescue => e
			# ERROR !
			halt 500, e.to_s
		end
	end

	delete '/presentations/:presentation_id' do
		begin
			@presentation = Presentation.find(params[:presentation_id])
			@presentation.destroy
			redirect to('/presentations')
		rescue => e
			halt 500, e.to_s
			#ERROR !
		end
	end

	get '/presentations/:presentation_id/slides' do
		@presentation = Presentation.find(params[:presentation_id])
	end

	get '/presentations/:presentation_id/slides/_new' do
		@presentation = Presentation.find(params[:presentation_id])
		haml :new_slide
	end

	post '/presentations/:presentation_id/slides' do
		@presentation = Presentation.find(params[:presentation_id])
		begin
			slide =  @presentation.slides.create!(:title => params[:title], :subtitle => params[:subtitle])
			redirect to("/presentations/#{@presentation.id}")
		rescue => e
			# ERROR !
			halt 500, e.to_s
		end
	end

	get '/presentations/:presentation_id/slides/:slide_index' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		haml :slide
	end

	put '/presentations/:presentation_id/slides/:slide_index' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		begin
			redirect to("/presentations/#{params[:presentation_id]}/slides/#{params[:slide_index]}") if @slide.update_attributes(:title => params[:title], :subtitle => params[:subtitle])
		rescue => e
			# ERROR !
			halt 500, e.to_s
		end
	end

	delete '/presentations/:presentation_id/slides/:slide_index' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		begin
			@slide.destroy
			redirect to("/presentations/#{params[:presentation_id]}")
		rescue => e
			#ERROR !
		end
	end

	get '/presentations/:presentation_id/slides/:slide_index/parts' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		@parts = @slide.slide_parts
		puts @parts[0]
	end

	get '/presentations/:presentation_id/slides/:slide_index/parts/_new' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		@part = @slide.slide_parts.build(:slide_type => :markdown)
		haml :new_slide_part
	end
	
	post '/presentations/:presentation_id/slides/:slide_index/parts' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]

		begin
			if (params[:slide_type] == "image")
				part = @slide.slide_parts.create!(:slide_type => params[:slide_type].to_sym, :image => params[:file])
			else
				part = @slide.slide_parts.create!(:slide_type => params[:slide_type].to_sym, :content => params[:content])
			end
			
			redirect to("/presentations/#{@presentation.id}/slides/#{params[:slide_index]}")
		rescue => e
			# ERROR !
			halt 500, e.to_s
		end
	end
	
	get '/presentations/:presentation_id/slides/:slide_index/parts/:part_index' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		@part = @slide.slide_parts[params[:part_index].to_i]
	end

	get '/presentations/:presentation_id/slides/:slide_index/parts/:part_index/_edit' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		@part = @slide.slide_parts[params[:part_index].to_i]
		haml :new_slide_part
	end
	
	put '/presentations/:presentation_id/slides/:slide_index/parts/:part_index' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		@part = @slide.slide_parts[params[:part_index].to_i]
		begin
			redirect to("/presentations/#{params[:presentation_id]}/slides/#{params[:slide_index]}") if @part.update_attributes(:content => params[:content], :path => params[:path])
		rescue => e
			# ERROR !
			halt 500, e.to_s
		end
	end
	
	delete '/presentations/:presentation_id/slides/:slide_index/parts/:part_index' do
		@presentation = Presentation.find(params[:presentation_id])
		@slide = @presentation.slides[params[:slide_index].to_i]
		@part = @slide.slide_parts[params[:part_index].to_i]
		begin
			@part.destroy
			redirect to("/presentations/#{params[:presentation_id]}/slides/#{params[:slide_index]}")
		rescue => e
			# ERROR !
			halt 500, e.to_s
		end
	end

	# Serve images
	get '/images/uploads/:file_name' do
		gridfs_file = Mongo::GridFileSystem.new(Mongoid.database).open("uploads/#{params[:file_name]}", 'r')
		content_type gridfs_file.content_type
		gridfs_file.read
	end

	# Facebook actions
	get '/presentations/:presentation_id/publish' do
		
	end
end