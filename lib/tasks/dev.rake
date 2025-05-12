desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do
  puts "Sample data task running"

  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end

  if Rails.env.development?
    User.destroy_all
    Game.destroy_all
    # Question.destroy_all
  end

  usernames = ["alice", "bob", "carol", "dave", "eve"]

  usernames.each do |username|
    user = User.new
    user.email = "#{username}@example.com"
    user.password = "password"
    user.nickname = username.titlecase
    user.active = true
    user.save
  end

  game = Game.new
  game.latitude = 41.789010656307404
  game.longitude = -87.59731226902139
  game.search_radius = 3
  game.number_of_questions = 5
  game.correct_answers = 3
  game.incorrect_answers = 2
  game.difficulty = "easy"
  game.user_id = User.where( { :email => "alice@example.com"} ).at(0).id
  game.save

  # 5.times do
  #   board = Board.new
  #   board.name = Faker::Address.community
  #   board.user_id = User.all.sample.id
  #   board.save

  #   rand(10..50).times do
  #     post = Post.new
  #     post.user_id = User.all.sample.id
  #     post.board_id = board.id
  #     post.title = rand < 0.5 ? Faker::Commerce.product_name : Faker::Job.title
  #     post.body = Faker::Lorem.paragraphs(number: rand(1..5), supplemental: true).join("\n\n")
  #     post.created_at = Faker::Date.backward(days: 120)
  #     post.expires_on = post.created_at + rand(3..90).days
  #     post.save
  #   end
  # end

  puts "There are now #{User.count} rows in the users table."
  puts "There are now #{Game.count} rows in the games table."
  puts "There are now #{Question.count} rows in the questions table."
end
