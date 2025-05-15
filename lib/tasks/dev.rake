desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do
  puts "Sample data task running"

  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end

  if Rails.env.development?
    User.destroy_all
    Game.destroy_all
    Topic.destroy_all
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
  wiki_text = "The University of Chicago is a private research university located in the Hyde Park neighborhood on Chicago's South Side, approximately 7 miles from downtown. Established in 1890 by the American Baptist Education Society with a significant donation from John D. Rockefeller, the university has become renowned for its rigorous academic programs and influential research. It comprises an undergraduate college, multiple graduate divisions, and several professional schools, including the Booth School of Business, Law School, Pritzker School of Medicine, and Harris School of Public Policy.

  The university is known for its strong emphasis on academic freedom and interdisciplinary research. It has been instrumental in the development of various academic disciplines, such as economics (notably the Chicago School of Economics), sociology, law, and literary criticism. The university's commitment to research is evident in its administration of national laboratories like Argonne and Fermi, as well as its own Marine Biological Laboratory.

  The main campus spans 217 acres and features a blend of Gothic and modern architecture. Notable facilities include the Regenstein Library, the Joe and Rika Mansueto Library with its distinctive glass dome, and the Rockefeller Chapel. The university also maintains international centers in cities like London, Paris, Beijing, Delhi, and Hong Kong, reflecting its global engagement.

  As of recent data, the university enrolls approximately 18,452 students, with around 7,559 undergraduates and 10,893 graduate students. The admissions process is highly selective, reflecting the university's commitment to academic excellence.

  The University of Chicago boasts a distinguished list of alumni and faculty, including 101 Nobel laureates, 10 Fields Medalists, and 4 Turing Award winners. Its contributions to various fields have solidified its reputation as one of the leading research universities globally."

  # Data for each topic
  topics_data = [
    { name: "Chicago Math", lat: 41.7926, lon: -87.60559 },
    { name: "NYC History", lat: 40.7128, lon: -74.0060 },
    { name: "San Francisco Tech", lat: 37.7749, lon: -122.4194 },
    { name: "Tokyo Culture", lat: 35.6895, lon: 139.6917 },
    { name: "London Politics", lat: 51.5074, lon: -0.1278 },
  ]

  topics_data.each do |data|
    topic = Topic.new
    topic.name = data[:name]
    topic.latitude = data[:lat]
    topic.longitude = data[:lon]
    topic.image = "clouds.jpg"
    topic.wikipedia_text = wiki_text
    topic.save
  end

  # add some questions
  10.times do
    first_number = rand(0..10)
    second_number = rand(0..10)

    question = Question.new
    question.challenge = "What is #{first_number} + #{second_number}?"
    question.image = "question_mark.jpg"

    question.topic_id = Topic.all.sample.id

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
  puts "There are now #{Topic.count} rows in the topics table."
  puts "There are now #{Question.count} rows in the questions table."
end
