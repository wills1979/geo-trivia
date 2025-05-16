Rails.application.routes.draw do

  devise_for :users

  root to: "games#index"
  
  #------------------------------

  # Routes for the Game resource:

  # CREATE
  post("/insert_game", { :controller => "games", :action => "create" })
          
  # READ
  get("/games", { :controller => "games", :action => "index" })
  
  get("/games/:path_id", { :controller => "games", :action => "show" })
  
  # UPDATE
  
  # post("/modify_game/:path_id", { :controller => "games", :action => "update" })
  
  # DELETE
  get("/delete_game/:path_id", { :controller => "games", :action => "destroy" })

  # READ
  get("/results/:path_id", { :controller => "games", :action => "show_results" })

  #------------------------------

  # Routes for the Question resource:

  # CREATE
  post("/insert_question", { :controller => "questions", :action => "create" })
  
  # READ
  get("/questions", { :controller => "questions", :action => "index" })
  
  get("/questions/:path_id", { :controller => "questions", :action => "show" })
  
  # UPDATE
  
  post("/modify_question/:path_id", { :controller => "questions", :action => "update" })
  
  # DELETE
  get("/delete_question/:path_id", { :controller => "questions", :action => "destroy" })

  #------------------------------

  # Routes for the Topic resource:

  # CREATE
  post("/insert_topic", { :controller => "topics", :action => "create" })
          
  # READ
  get("/topics", { :controller => "topics", :action => "index" })
  
  get("/topics/:path_id", { :controller => "topics", :action => "show" })
  
  # UPDATE
  
  post("/modify_topic/:path_id", { :controller => "topics", :action => "update" })
  
  # DELETE
  get("/delete_topic/:path_id", { :controller => "topics", :action => "destroy" })

  #------------------------------

  # Routes for the Game topic resource:

  # CREATE
  # post("/insert_game_topic", { :controller => "game_topics", :action => "create" })
          
  # # READ
  # get("/game_topics", { :controller => "game_topics", :action => "index" })
  
  # get("/game_topics/:path_id", { :controller => "game_topics", :action => "show" })
  
  # # UPDATE
  
  # post("/modify_game_topic/:path_id", { :controller => "game_topics", :action => "update" })
  
  # # DELETE
  # get("/delete_game_topic/:path_id", { :controller => "game_topics", :action => "destroy" })
  
  #------------------------------

    # Routes for the Game question resource:

  # CREATE
  # post("/insert_game_question", { :controller => "game_questions", :action => "create" })
          
  # # READ
  # get("/game_questions", { :controller => "game_questions", :action => "index" })
  
  # get("/game_questions/:path_id", { :controller => "game_questions", :action => "show" })
  
  # # UPDATE
  
  # post("/modify_game_question/:path_id", { :controller => "game_questions", :action => "update" })
  
  # # DELETE
  # get("/delete_game_question/:path_id", { :controller => "game_questions", :action => "destroy" })
  
end
