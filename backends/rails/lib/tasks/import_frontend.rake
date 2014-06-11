namespace :frontend do
  desc "Import dist files from lineman frontend"
  task import: :environment do

    frontend_dir = ENV['FRONTEND_DIR'] || FRONTEND_DIR
    rails_public_dir = File.join(Rails.root, "public")
    
    FileUtils.cd(frontend_dir) { puts %x{lineman build} }

    if $?.exitstatus == 0
      from = File.join(frontend_dir, "dist", ".")
      FileUtils.cp_r(from, rails_public_dir)
      from = File.join(rails_public_dir, "index.html")
      to = File.join(Rails.root, "app", "views", "static_pages", "admin.html")
      FileUtils.mv(from, to)
    end
  end
end
