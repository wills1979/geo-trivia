desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do
  puts "Sample data task running"

  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end

  if Rails.env.development?
    User.destroy_all
    Game.destroy_all
    Question.destroy_all
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

  # add a game
  game = Game.new
  game.latitude = 41.789010656307404
  game.longitude = -87.59731226902139
  game.search_radius = 3
  game.number_of_questions = 5
  game.correct_answers = 3
  game.incorrect_answers = 2
  game.difficulty = "easy"
  game.user_id = User.where({ :email => "alice@example.com" }).at(0).id
  game.save

  # add a topic
  

  # add some questions
  10.times do
    first_number = rand(0..10)
    second_number = rand(0..10)

    question = Question.new
    question.challenge = "What is #{first_number} + #{second_number}?"
    question.image = "question_mark.jpg"

    quetion.topic_id = Topic.all.sample.id

    correct_answer = (first_number + second_number).to_s
    question.correct_answer = correct_answer

    # Generate 3 incorrect answers and shuffle them with the correct one
    options = [correct_answer, rand(0..20).to_s, rand(0..20).to_s, rand(0..20).to_s].shuffle

    question.option_a = options[0]
    question.option_b = options[1]
    question.option_c = options[2]
    question.option_d = options[3]

    # Add stats
    question.correct_answers = 0
    question.attempts = 0
    question.share_correct = 0

    question.save
  end


  puts "There are now #{User.count} rows in the users table."
  puts "There are now #{Game.count} rows in the games table."
  puts "There are now #{Question.count} rows in the questions table."
end
