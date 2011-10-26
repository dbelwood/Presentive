namespace :mongodb do
	desc "Starting mongodb"
	task :start do
		mkdir_p "db"
		system "mongod --dbpath db/"
	end
end

desc "Start everything."
task :default => ['mongodb:start']