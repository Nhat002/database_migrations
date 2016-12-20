desc 'Run migration'
task :migrate, [:db, :version] do |task, args|
  require 'yaml'
  require 'sequel'
  Sequel.extension :migration
  config = YAML.load_file("#{args[:db]}/database.yml")
  db = Sequel.connect(config)
  if args[:version]
    puts "Migrating #{args[:db]} to version #{args[:version]}"
    Sequel::Migrator.run(db, args[:db], table: 'schema_info', target: args[:version].to_i)
  else
    puts "Migrating #{args[:db]} to latest"
    Sequel::Migrator.run(db, args[:db], table: 'schema_info')
  end
end
