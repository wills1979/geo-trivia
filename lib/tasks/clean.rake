desc "Fill the database tables with some sample data"
task({ :clean_data => :environment }) do
  puts "Sample data task running"

  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end

  if Rails.env.development?
    User.destroy_all
    Game.destroy_all
    Topic.destroy_all
    Question.destroy_all
    GameQuestion.destroy_all
    GameTopic.destroy_all
  end

  # add users
  usernames = ["alice", "bob", "carol", "dave", "eve"]

  usernames.each do |username|
    user = User.new
    user.email = "#{username}@example.com"
    user.password = "password"
    user.nickname = username.titlecase
    user.active = true
    user.save
  end

  puts "There are now #{User.count} rows in the users table."
  puts "There are now #{Game.count} rows in the games table."
  puts "There are now #{Topic.count} rows in the topics table."
  puts "There are now #{Question.count} rows in the questions table."
  puts "There are now #{GameTopic.count} rows in the game_topics table."
  puts "There are now #{GameQuestion.count} rows in the game_questions table."
end
