defmodule LearnflowWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_cookies)
    plug(LearnflowWeb.Plugs.SecurityHeaders)
    plug(LearnflowWeb.Plugs.RateLimit, limit: 100, bucket: :api)
    plug(LearnflowWeb.Plugs.CSRFProtection)
  end

  pipeline :auth do
    plug(LearnflowWeb.Plugs.RequireAuth)
  end

  pipeline :auth_rate_limit do
    plug(LearnflowWeb.Plugs.RateLimit, limit: 10, bucket: :auth)
  end

  pipeline :webhook do
    plug(:accepts, ["json"])
    plug(LearnflowWeb.Plugs.SecurityHeaders)
  end

  scope "/webhooks", LearnflowWeb do
    pipe_through([:webhook])

    post("/stripe", PaymentController, :webhook)
  end

  scope "/api", LearnflowWeb do
    pipe_through([:api])

    get("/health", HealthController, :show)

    scope "/auth" do
      pipe_through([:auth_rate_limit])

      post("/register", AuthController, :register)
      post("/login", AuthController, :login)
    end

    get("/feed", FeedController, :index)
    get("/courses", CourseController, :index)
    get("/courses/:slug", CourseController, :show)
    get("/videos/:slug", VideoController, :show)
    get("/search", SearchController, :index)
    get("/users/search", UserController, :search)
    get("/users/username-available", UserController, :username_available)
    get("/users/avatar/:key", UserController, :avatar_file)
    get("/users/:username", UserController, :show)
    get("/users/:username/videos", UserController, :videos)
    get("/users/:username/followers", UserController, :followers)
    get("/users/:username/following", UserController, :following)
  end

  scope "/api", LearnflowWeb do
    pipe_through([:api, :auth])

    delete("/auth/logout", AuthController, :logout)
    get("/auth/me", AuthController, :me)

    post("/videos", VideoController, :create)
    post("/videos/:id/upload-url", VideoController, :upload_url)
    post("/videos/:id/thumbnail-url", VideoController, :thumbnail_url)
    post("/videos/:id/confirm", VideoController, :confirm)
    post("/videos/:id/chapters", VideoController, :chapters)
    get("/videos/:id/view-url", VideoController, :view_url)
    get("/videos/:id/progress", VideoController, :progress)
    post("/videos/:id/progress", VideoController, :progress)
    post("/videos/:id/complete", VideoController, :complete)
    post("/videos/:id/like", SocialController, :like)
    delete("/videos/:id/like", SocialController, :unlike)
    post("/videos/:id/save", SocialController, :save)
    delete("/videos/:id/save", SocialController, :unsave)
    get("/videos/:id/comments", SocialController, :comments)
    post("/videos/:id/comments", SocialController, :comment)
    delete("/comments/:id", SocialController, :delete_comment)
    post("/users/:id/follow", SocialController, :follow)
    delete("/users/:id/follow", SocialController, :unfollow)
    get("/dashboard/stats", DashboardController, :stats)
    get("/dashboard/history", DashboardController, :history)
    delete("/dashboard/history/:video_id", DashboardController, :delete_history)
    get("/dashboard/saved", DashboardController, :saved)
    get("/dashboard/export", DashboardController, :export)
    get("/admin/analytics", AdminController, :analytics)
    get("/dashboard/courses", CourseController, :my_courses)
    get("/recommendations", AIController, :recommendations)
    get("/videos/:id/subtitles/:lang", AIController, :subtitles)
    post("/videos/:id/transcribe", AIController, :transcribe)
    get("/videos/:id/summary", AIController, :summary)
    get("/notifications", NotificationController, :index)
    get("/notifications/unread-count", NotificationController, :unread_count)
    post("/notifications/:id/read", NotificationController, :mark_read)
    post("/notifications/read-all", NotificationController, :mark_all_read)
    get("/conversations", ConversationController, :index)
    post("/conversations", ConversationController, :create)
    get("/conversations/:id/messages", ConversationController, :messages)
    post("/conversations/:id/messages", ConversationController, :send_message)
    post("/conversations/:id/read", ConversationController, :read)
    post("/groups", ConversationController, :create_group)
    post("/groups/:id/members", ConversationController, :add_member)
    delete("/groups/:id/members/:user_id", ConversationController, :remove_member)
    put("/groups/:id", ConversationController, :update_group)
    post("/courses", CourseController, :create)
    put("/courses/:id", CourseController, :update)
    post("/courses/:id/publish", CourseController, :publish)
    post("/courses/:id/videos", CourseController, :add_video)
    put("/courses/:id/videos/reorder", CourseController, :reorder)
    get("/courses/:id/progress", CourseController, :progress)
    get("/courses/:id/purchase", PaymentController, :access)
    post("/courses/:id/purchase", PaymentController, :purchase)
    get("/creator/onboarding", PaymentController, :onboarding)
    get("/creator/stats", PaymentController, :stats)
    get("/creator/payouts", PaymentController, :payouts)
    get("/certificates/:id/download", CertificateController, :download)
    get("/quizzes", QuizController, :index)
    post("/quizzes", QuizController, :create)
    post("/quizzes/images", QuizController, :image)
    post("/quizzes/join", QuizController, :join)
    get("/quizzes/images/:token", QuizController, :image_file)
    get("/quizzes/:id", QuizController, :show)
    post("/quizzes/:id/start", QuizController, :start)
    post("/quizzes/:id/finish", QuizController, :finish)
    post("/quizzes/:id/submit", QuizController, :submit)
    get("/quizzes/:id/results", QuizController, :results)
    put("/settings/profile", UserController, :update)
    put("/users/me", UserController, :update)
    put("/users/me/password", UserController, :password)
    post("/users/me/avatar", UserController, :avatar)
    delete("/settings/account", UserController, :delete)
  end

  scope "/api", LearnflowWeb do
    pipe_through([:api])

    get("/notifications/unsubscribe/:user_id", NotificationController, :unsubscribe)
  end

  scope "/", LearnflowWeb do
    pipe_through([:api])

    get("/auth/google", AuthController, :google_request)
    get("/auth/google/callback", AuthController, :google_callback)
    get("/auth/google/session", AuthController, :google_session)
    get("/health", HealthController, :show)
    get("/metrics", MetricsController, :index)
  end
end
